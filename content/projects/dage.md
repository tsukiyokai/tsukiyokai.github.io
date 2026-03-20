+++
title       = "dage"
description = "DAG-based Agent Workflow Orchestrator — 把AI工作流写成YAML，按下run，走开"
weight      = 2

[extra]
lang = "Python"
repo = "https://github.com/shanshan/dage"
+++

编排AI agent曾经意味着写胶水脚本、逐步看护、祈祷第三步不要在你睡着前崩溃。dage是解药。

## 定位

把工作流写成一份YAML DAG，按下run，走开。节点按拓扑序执行，gate失败即短路，能并行的全部并行。你回来时只剩一份干净的日志，告诉你什么成了、什么没成。

## 核心特性

- YAML DAG定义 — 声明式工作流，节点间依赖自动解析
- 拓扑排序执行 — 基于`graphlib.TopologicalSorter`，自动检测循环依赖
- Gate节点 — 机械约束检查点，失败时跳过所有下游节点
- 并行执行 — `ThreadPoolExecutor`驱动，同层无依赖节点自动并行
- 双节点类型 — `claude`节点(AI agent子进程) + `shell`节点(任意命令)

## 工作流示例

```
  你                       dage                         AI agents
   │                         │                              │
   │  dage run workflow.yaml │                              │
   │ ───────────────────────>│                              │
   │                         │  topo sort -> layer 0        │
   │                         │  ├─ scan ───────────────────>│
   │                         │  └─ read_docs ─────────────>│
   │                         │  gate_test (cargo test)       │
   │                         │  ├─ impl_ir ───────────────>│
   │                         │  └─ impl_topo ─────────────>│
   │                         │  gate -> auto-commit + push  │
```

## 技术栈

纯Python实现，标准库为主:

- `graphlib` — 拓扑排序(Python 3.9+)
- `concurrent.futures` — 线程池并行
- `PyYAML` — 工作流定义解析
- `subprocess` — 子进程管理
