+++
title       = "Planck"
description = "Ascend NPU集合通信库 — Plan Compilation + Hardware Exploitation"
weight      = 1

[extra]
lang = "Rust"
repo = "https://github.com/shanshan/planck"
+++

Plan + Communication + Link — 为Ascend NPU上PanGu大模型全栈特化的集合通信库。

如同Planck常数定义了物理学的最小量子，Planck把通信优化做到最小粒度——chunk-level pipeline，编译期确定一切。

## 定位

独立通信库(类NCCL)，通过AOT Plan Compilation实现跨操作全局优化，同时面向训练和推理。

## 核心特性

三层竞争壁垒(相乘关系):

- Pattern Specialization — PanGu通信pattern先验，skip/prefetch/partial-reduce
- Plan Compilation — AOT全图编译，cross-op buffer reuse / schedule reorder
- Hardware Exploitation — MTE+AIV+Cube物理隔离，通信/压缩/计算零竞争

## 技术栈

| 层     | 技术                | 用途                          |
|:-------|:--------------------|:------------------------------|
| Rust   | petgraph, PyO3      | Plan Compiler (决策, 编译期)  |
| C++20  | AscendC, ACL Runtime| Custom Ops + Executor (运行期)|
| Python | torchair, pytest    | Graph pass + PyO3 bindings    |

## 架构

Plan IR三层设计: CommGraph(做什么) → LogicalPlan(怎么分解) → ExecutionPlan(怎么执行)。
9条单边原语，6个编译Pass(算法选择 → 分块流水 → Buffer规划 → 依赖细化 → 指令融合 → 内联变换)。

## 当前进展

Phase A (Rust + Python, macOS, 无硬件依赖) 已完成:

- 29/29 Rust tests + 4/4 Python tests，零warnings
- 编译延迟 ~1.36us (红线 <1ms)，模板实例化 ~73ns (红线 <1us)
- 1,615行Rust + 73行Python，repr(C) Plan IR支持零拷贝FFI
