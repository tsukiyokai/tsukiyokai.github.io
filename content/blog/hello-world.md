+++
title = "hello world — markdown格式预览"
date  = 2026-03-20
description = "本站所有Markdown格式的渲染预览，兼作多语种排版测试。"
[taxonomies]
tags = ["meta"]
+++

这是本站的格式预览页，用来验证所有Markdown元素的渲染效果。

<!-- more -->

## 行内格式

普通文本。*斜体*。**粗体**。***粗斜体***。`行内代码`。~~删除线~~。

链接：[danluu.com](https://danluu.com)，自动链接：<https://github.com/tsukiyokai>

## 标题层级

### 三级标题

#### 四级标题

##### 五级标题

## 列表

无序列表：

- Rust — 系统编程
- Python — 胶水与编排
- C++ — 硬件交互层

有序列表：

1. 先让它跑起来
2. 再让它跑对
3. 最后让它跑快

嵌套列表：

- 编译期
  - 类型检查
  - 算法选择
  - Buffer规划
- 运行期
  - 执行调度
  - 异常恢复

## 引用

> The purpose of abstracting is not to be vague,
> but to create a new semantic level in which one can be absolutely precise.
>
> — Edsger W. Dijkstra

嵌套引用：

> 有人问我为什么选Rust写编译器。
>
> > Because if it compiles, it works.
> > — Every Rust evangelist, ever
>
> 倒也没那么绝对，但ownership确实帮你拦住了一大类bug。

## 代码

行内：用`zola serve`启动本地预览。

Rust：

```rust
/// Plan IR的核心：一个通信操作被编译成什么
pub enum ExecutionStep {
    Send   { dst: RankId, buf: BufferId, bytes: usize },
    Recv   { src: RankId, buf: BufferId, bytes: usize },
    Reduce { bufs: Vec<BufferId>, op: ReduceOp },
    Barrier,
}
```

Python：

```python
def topo_sort(graph: dict[str, list[str]]) -> list[str]:
    """Kahn's algorithm — O(V+E), stable."""
    in_deg = {n: 0 for n in graph}
    for deps in graph.values():
        for d in deps:
            in_deg[d] += 1
    queue = [n for n, d in in_deg.items() if d == 0]
    order = []
    while queue:
        n = queue.pop(0)
        order.append(n)
        for m in graph.get(n, []):
            in_deg[m] -= 1
            if in_deg[m] == 0:
                queue.append(m)
    return order
```

YAML：

```yaml
nodes:
  read_design:
    role: context
    prompt: "精读设计文档，提炼核心决策。"

  implement:
    deps: [read_design]
    prompt: "根据设计文档实现功能。"

  gate_test:
    role: gate
    type: shell
    cmd:  "cargo test 2>&1"
```

Shell：

```bash
# 一行看站点大小
find public -name '*.html' | wc -l && du -sh public/
```

无语法标注的代码块（纯文本）：

```
CommGraph → LogicalPlan → ExecutionPlan
   what        how           where
```

## 表格

| 项目   | 语言   | 定位                 | 状态     |
|:-------|:-------|:---------------------|:---------|
| planck | Rust   | NPU集合通信编译器    | Phase A  |
| dage   | Python | DAG工作流编排        | 已上线   |

右对齐数字表格：

| Benchmark       |  Latency |  Throughput |
|:----------------|----------:|------------:|
| plan_compile    |   1.36 μs |    735k/s  |
| template_inst   |     73 ns |  13.7M/s   |
| ffi_roundtrip   |    220 ns |   4.5M/s   |

## 分隔线

---

## 脚注

Zola的Markdown引擎是pulldown-cmark[^1]，支持CommonMark规范加一些扩展[^2]。

[^1]: [pulldown-cmark](https://github.com/raphlinus/pulldown-cmark)，纯Rust实现。
[^2]: 包括表格、脚注、删除线、任务列表等。

## 任务列表

- [x] 初始化Zola项目
- [x] 基础模板
- [x] 博客功能
- [x] 作品展示
- [ ] 写第一篇真正的技术文章
- [ ] 部署到自定义域名

## 多语种排版测试

### 中文

天地玄黄，宇宙洪荒。日月盈昃，辰宿列张。寒来暑往，秋收冬藏。

技术写作中的中英文混排：Rust的`ownership`模型通过`borrow checker`在编译期保证内存安全，无需garbage collector。这让它在系统编程领域（OS kernel、embedded、HPC）获得了广泛采用。

### English

The quick brown fox jumps over the lazy dog. Pack my box with five dozen liquor jugs.

Systems programming is the art of building software that other software depends on. It demands precision, because a bug in a library or an OS kernel can cascade into millions of affected programs.

### 日本語

吾輩は猫である。名前はまだ無い。どこで生まれたかとんと見当がつかぬ。

プログラミングとは、問題を解決するための道具を作ることである。

### 混排段落

在danluu的[web bloat](https://danluu.com/web-bloat/)一文中，他测量了rural America的网络状况 — latency 500ms-1000ms, packet loss 1%-10%，和90年代的56k modem差不多。他的结论是：大部分modern web对这些用户是不可用的。而他自己的站点，因为zero CSS/JS的极简设计，在任何网络条件下都能秒开。これは「less is more」の最も良い例だと思う。
