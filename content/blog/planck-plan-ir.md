+++
title = "Planck: 为什么集合通信需要一个编译器"
date  = 2026-03-22
description = "从9条原语到6个编译Pass，一个1.42微秒的Plan Compiler如何把AllReduce编译成可执行计划。"
[taxonomies]
tags = ["systems", "rust", "hpc"]
+++

NCCL是一个运行时库。每次调用`ncclAllReduce`，它在运行时选算法、分chunk、调度流水线。这意味着同一个通信pattern在训练的每一步都重新做一遍决策。

Planck的核心假设是：大模型训练的通信pattern是静态的。PanGu的AllReduce在第1步和第10000步的参数完全相同 — 同样的消息大小、同样的rank数、同样的拓扑。既然如此，为什么不把决策提前到编译期？

这就是Plan Compiler的出发点。

<!-- more -->

## 三层IR：从"做什么"到"怎么执行"

编译器的核心是一个三层Plan IR：

```
CompileRequest    "256MB AllReduce, 8 ranks, 4 chunks"
     |
     v
  AlgoStep        "第3步: rank 0 发送chunk 5给rank 1, 接收chunk 4并reduce"
     |
     v
ExecutionPlan     "Wait(rank=7) -> LocalReduce(buf3,buf5) -> Put(rank=1,buf2)"
```

每一层回答不同的问题：

- CompileRequest — 做什么？（集合操作类型、消息大小、rank数）
- AlgoStep — 怎么分解？（Ring的每一步发什么、收什么、从谁那里）
- ExecutionPlan — 怎么执行？（具体的原语序列、buffer编号、stream分配）

层与层之间的信息是单向流动的：上层决定下层的结构，但下层不能反过来影响上层的决策。这让每个Pass可以独立推理、独立测试。

## 9条原语

ExecutionPlan由9条原语组成。它们都是单边操作 — 发送方主动推数据，接收方被动等待：

```rust
pub enum Opcode {
    Put            = 0,   // 异步写入远端HBM
    Signal         = 1,   // 通知远端rank
    Wait           = 2,   // 阻塞等待信号
    LocalCopy      = 3,   // 本地HBM拷贝
    LocalReduce    = 4,   // 本地reduce (sum/max/min)
    PutWithSignal  = 5,   // 融合: Put + Signal
    WaitReduceCopy = 6,   // 融合: Wait + Reduce + Copy
    WaitReducePut  = 7,   // 融合: Wait + Reduce + Put
    Noop           = 8,   // 同步点
}
```

前5条是基础原语，后3条是融合原语。为什么要融合？因为Ascend NPU上MTE（数据搬运）和AIV（向量计算）是物理隔离的执行单元，可以真正并行。`WaitReducePut`把"等信号 → reduce → 发送"三个操作融合成一条指令，让reduce和put在硬件上重叠执行。

这3条融合原语不是手动设计的，而是编译器的Pass 5自动发现的。

## 6个编译Pass

一个`CompileRequest`经过6个Pass变成`ExecutionPlan`：

### Pass 1: Topology

从硬件拓扑构建链路图。8卡HCCS全连接 = 56条有向链路，每条30 GB/s带宽、1.5us延迟。

```rust
pub fn hccs_8card() -> Self {
    // 8 ranks x 7 neighbors = 56 directed links
    // per-link: 30 GB/s bandwidth, 1.5 us latency
}
```

这一步的产出是一张图，不是一个数字。后续Pass会查这张图来做决策。

### Pass 2: Cost Model

从拓扑提取alpha-beta-gamma参数：

```
T = 2(n-1) * alpha + 2(n-1)/n * M * beta + (n-1)/n * M * gamma
```

alpha是启动延迟，beta是传输时间，gamma是计算时间。这个公式的意义不在于精确预测延迟（那是仿真器的工作），而在于给Pass 3提供算法选择的依据。

### Pass 3: Algorithm

把AllReduce分解为ReduceScatter + AllGather两个阶段，每个阶段n-1步。8卡Ring = 14步。

```rust
pub struct AlgoStep {
    pub phase: Phase,         // ReduceScatter or AllGather
    pub step: u16,            // 0..n-2
    pub send_chunk: u16,      // ring chunk to send
    pub recv_chunk: u16,      // ring chunk to receive
    pub dst_rank: u16,        // send to (rank+1) % n
    pub src_rank: u16,        // receive from (rank-1+n) % n
    pub needs_reduce: bool,   // true for ReduceScatter
}
```

Ring chunk的索引公式：对于rank r、第k步，ReduceScatter发送的chunk是`(r-k+n)%n`，接收的是`(r-k-1+n)%n`。这保证每个rank在n-1步后收到了所有chunk各恰好一次。

### Pass 4: Scheduler

这是最复杂的一个Pass。它把AlgoStep展开成具体的OpEntry序列，同时做两件事：

1. Buffer分配 — 每个pipeline chunk需要n个input子buffer、n个output子buffer、2个scratch buffer（双缓冲）。4个pipeline chunk × 8 ranks = 72个buffer entry。

2. 流水线编排 — 把不同pipeline chunk分配到不同stream，让chunk k在compute时chunk k+1可以同时在传输。

每个AlgoStep展开为4条原语：
- ReduceScatter步: `Put → Signal → Wait → LocalReduce`
- AllGather步: `Put → Signal → Wait → LocalCopy`

双缓冲的技巧：第i步用`scratch_a`(i%2==0)或`scratch_b`(i%2==1)，这样上一步的数据还在被reduce时，下一步的数据已经可以写入另一个scratch buffer了。

### Pass 5: Fusion

贪心最长匹配，3种融合模式：

| 模式 | 输入 | 输出 | 收益 |
|:-----|:-----|:-----|:-----|
| Wait + Reduce + Put | 3 ops | WaitReducePut | MTE/AIV并行 |
| Wait + Reduce + Copy | 3 ops | WaitReduceCopy | MTE/AIV并行 |
| Put + Signal | 2 ops | PutWithSignal | 省一次kernel launch |

融合后有一个实现细节值得注意：`WaitReducePut`需要知道put的目标buffer，但OpEntry只有16字节、字段已经用完了。解决方案是复用`_pad`字段 — 这个原本保留的2字节被赋予了语义。C++执行器必须理解这个约定。

```rust
OpEntry {
    opcode: Opcode::WaitReducePut as u8,
    src_buf: reduce_src,       // reduce的源
    dst_buf: reduce_dst,       // reduce的目标
    dst_rank: put_dst_rank,    // put的目标rank
    _pad: put_dst_buf,         // put的目标buffer (字段复用!)
    ...
}
```

融合效果：256MB/8rank/4chunk的计划从224条op压缩到约60条，压缩率约73%。

### Pass 6: Serialization

把ExecutionPlan序列化为`repr(C)`字节流：

```
[PlanHeader: 32B] [BufEntry x N: 12B each] [OpEntry x M: 16B each]
```

PlanHeader的magic是`0x4B4E_4C50`（"PLNK"小端序），version=1。整个256MB计划的序列化结果约1.9KB — 比一条推文还短。

这个格式的设计目标是零拷贝FFI：C++执行器拿到字节流后，直接cast成结构体指针就能用，不需要任何解析。

## repr(C)：Rust和C++之间的契约

三个核心结构体都标记了`#[repr(C)]`，保证内存布局和C一致：

```rust
#[repr(C)]
pub struct PlanHeader {
    pub magic: u32,          // 0x4B4E_4C50
    pub version: u16,
    pub num_ops: u16,
    pub num_buffers: u16,
    pub num_streams: u8,
    pub num_events: u8,
    pub num_ranks: u16,
    pub my_rank: u16,
    pub flags: u32,
    pub _reserved: [u8; 12],
}  // exactly 32 bytes

#[repr(C)]
pub struct BufEntry {
    pub pool: u32,           // Input/Output/Scratch
    pub offset: u32,
    pub size: u32,
}  // exactly 12 bytes

#[repr(C)]
pub struct OpEntry {
    pub opcode: u8,
    pub stream_id: u8,
    pub reduce_op: u8,
    pub flags: u8,
    pub src_buf: u16,
    pub dst_buf: u16,
    pub dst_rank: u16,
    pub wait_event: u16,
    pub signal_event: u16,
    pub _pad: u16,
}  // exactly 16 bytes
```

每个结构体的大小都是固定的、编译期可知的。测试里有`assert_eq!(size_of::<PlanHeader>(), 32)`这样的断言。这不是可选的 — 如果C++那边的结构体大小不一致，零拷贝就会读到垃圾数据。

## Template：编译一次，实例化无限次

一个观察：同一个AllReduce配置，只有`msg_size`变化时，op图的形状是不变的。变化的只是每个buffer的大小 — 而且大小是`msg_size`的线性函数。

Template把这两部分分离：

```rust
pub struct PlanTemplate {
    pub frozen_ops: Vec<OpEntry>,        // 不变的op图
    pub buf_formulas: Vec<LinearFormula>, // size = a * msg_size + b
}

impl PlanTemplate {
    pub fn instantiate(&self, msg_size: usize) -> ExecutionPlan {
        // 只需要遍历buf_formulas算一遍大小，O(num_buffers)
    }
}
```

效果：编译1.42us，实例化73.75ns。差了19倍。对于推理场景（不同batch size对应不同msg_size），template instantiation可以在热路径上调用而不成为瓶颈。

## 仿真器：没有硬件也能验证

Planck内嵌了一个离散事件仿真器(DES)，用`--features sim`开启。它不模拟数据搬运，只模拟时序 — 每条op何时开始、何时结束、链路竞争如何影响延迟。

两个时序模型：

- SimpleModel: `T = latency + size / bandwidth`，用于快速验证
- AscendModel: 硬件感知 — HCCS三轮握手(3x latency)、GET模式传输(2x latency + transfer)、InlineReduce重叠(`notify + max(reduce, put)`)

仿真器输出Chrome Trace格式的JSON，可以在Perfetto里可视化每个rank、每个stream的时序甘特图。这让你在macOS上就能看到8卡AllReduce的流水线行为，不需要接触任何硬件。

## 现状

Phase A（macOS，纯Rust + Python）已完成：

| 指标 | 数值 |
|:-----|:-----|
| 代码量 | 2,542行Rust + PyO3 |
| 测试 | 44 Rust + 7 Python，全通过 |
| 编译延迟 | 1.42us (预算 <1ms，余量704x) |
| 实例化延迟 | 73.75ns (预算 <1us，余量14x) |
| 计划大小 | ~1.9KB (256MB/8rank/4chunk) |

Phase B需要Ascend硬件：C++执行器、HCCS传输层、自定义AscendC算子。Plan Compiler本身的工作已经完成 — 它产出的`repr(C)`字节流就是两个phase之间的契约。
