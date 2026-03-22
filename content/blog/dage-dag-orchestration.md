+++
title = "dage: 一条命令从零建站的DAG编排器"
date  = 2026-03-21
description = "把AI工作流写成YAML DAG，按下run，走开。Gate驱动的质量检查点、worktree并行隔离、自动修复。"
[taxonomies]
tags = ["python", "devtools", "ai"]
+++

这个博客不是手动搭建的。它是一条命令的产物。

```bash
dage run blog.yaml
```

22个节点、5个验证关卡、3条并行链路。从`git init`到`zola build`通过、从爬取111篇文章到GitHub Actions部署配置，全部自动完成。我按下回车，去吃了顿饭，回来时站点已经上线了。

dage是我写的DAG工作流编排器。1,821行Python，核心依赖只有`graphlib`、`concurrent.futures`和`PyYAML`。它解决的问题是：如何让多个AI agent并行协作完成一个复杂任务，同时保证每一步的产出质量。

<!-- more -->

## 为什么不用Makefile

Makefile能做依赖管理和并行执行。但它解决不了三个问题：

1. AI agent不是deterministic的 — 同样的prompt可能产出不同质量的代码。你需要一个验证机制来判断产出是否合格，合格了才能继续。
2. Agent之间需要传递上下文 — 节点A读了设计文档，提炼出的信息需要注入到节点B的prompt里。Makefile的变量系统做不了这种动态插值。
3. 并行的agent不能写同一个git仓库 — 两个agent同时修改文件会冲突。你需要隔离机制。

dage的设计围绕这三个问题展开。

## YAML → DAG

一个dage工作流长这样：

```yaml
vars:
  repo_dir: /path/to/project

nodes:
  read_design:
    role: context
    prompt: "精读设计文档，提炼核心决策。"

  init_project:
    deps: [read_design]
    prompt: |
      设计文档: ${nodes.read_design.output}
      任务: 初始化项目结构。

  gate_base:
    role: gate
    deps: [init_project]
    type: shell
    cmd: "zola build 2>&1"
```

每个节点有三个关键属性：

- `type` — `claude`（调用AI agent）或`shell`（执行命令）
- `role` — `context`（只读采集）、`produce`（写代码）、`gate`（验证检查点）、`meta`（生成报告）
- `deps` — 依赖哪些节点

dage加载YAML后，用`graphlib.TopologicalSorter`做循环检测和拓扑排序，然后按层执行。

## 动态调度

静态分层（先算出所有层，再逐层执行）有一个问题：如果中途replan新增了节点，静态分层没法感知。

dage用的是动态调度 — 一个while循环不断调用`next_runnable()`：

```python
def next_runnable(nodes, results, blocked) -> list[str]:
    runnable = []
    for name, node in nodes.items():
        if results[name].status != Status.PENDING:
            continue
        if name in blocked:
            continue
        if all(results[d].status in (Status.SUCCESS, Status.SKIPPED)
               for d in node.deps):
            runnable.append(name)
    return sorted(runnable)
```

每一轮找出"所有依赖已完成、自身还没跑、没被阻断"的节点，全部扔进线程池并行执行。等这一批完成后，再找下一批。

这种设计的好处是：DAG可以在运行时动态变化（replan），调度器不需要任何修改就能自动拾起新节点。

## Gate：机械约束检查点

Gate是dage最核心的设计。它是一个shell节点，唯一的职责是验证前驱节点的产出是否合格。

```yaml
gate_blog:
  role: gate
  deps: [blog_post]
  type: shell
  cmd: >
    zola build 2>&1 &&
    test -f public/blog/index.html &&
    test -f public/blog/hello-world/index.html &&
    echo 'blog pages OK'
```

Gate的行为很简单：命令返回0就通过，非0就失败。但它的影响是传递性的 — gate失败后，它的所有下游节点（传递闭包）全部被标记为`SKIPPED`。

```python
def find_blocked(nodes, failed_gate) -> set[str]:
    # BFS遍历依赖图的反向边，找出所有下游节点
    children = {n: [] for n in nodes}
    for name, node in nodes.items():
        for dep in node.deps:
            children[dep].append(name)
    blocked = set()
    queue = list(children[failed_gate])
    while queue:
        n = queue.pop(0)
        if n not in blocked:
            blocked.add(n)
            queue.extend(children[n])
    return blocked
```

为什么叫"机械约束"？因为gate不做任何主观判断。它不评价代码写得好不好，只检查"zola build能不能通过"、"文件是否存在"、"测试是否全绿"。这种判断是machine-verifiable的，不依赖任何AI的理解能力。

在本博客的`blog.yaml`中，5个gate把22个节点分成5个chunk：

```
init → base_template → [gate_base]
  → blog_list → blog_post → [gate_blog] → crawl → [gate_crawl]
  → read_projects → projects → [gate_projects]
    → homepage → [gate_homepage] → deploy
```

每过一个gate，意味着这个chunk的产出经过了机械验证。即使后面的chunk全部失败，前面gate通过的部分也是可用的。

## Worktree并行隔离

当同一层有多个claude节点需要并行执行时，它们不能同时修改同一个git仓库。dage的解决方案是git worktree。

```python
# 当同层有>1个并行claude节点时，自动分配worktree
claude_no_wt = [n for n in to_run
                if nodes[n].type == NodeType.CLAUDE
                and not nodes[n].worktree
                and nodes[n].role != Role.CONTEXT]
auto_wt = ({n: f"dage-{n}" for n in claude_no_wt}
           if len(claude_no_wt) > 1 else {})
```

逻辑：如果只有一个claude节点，直接在主仓库跑。如果有多个，每个都分配一个worktree `dage-{node_name}`，存放在`.dage/worktrees/`下。

Worktree是git的内置功能 — 同一个仓库可以有多个工作目录，各自在不同的分支上。这意味着两个agent可以同时写代码、同时commit，互不干扰。

执行完成后，dage把每个worktree的改动合并回主库：

```python
def _merge_worktrees(auto_wt, repo_dir, run_id):
    for node_name, wt_name in auto_wt.items():
        # Step 1: worktree上commit
        git add -A && git commit -m "dage: {node_name}"
        # Step 2: 合并回主库
        git merge --no-edit "{wt_name}"
        # Step 3: 重置worktree（下次run复用）
        git reset --hard main
```

本博客的构建过程中，`projects`和`blog_post`两个节点就是在各自的worktree里并行执行的，最后汇聚到`homepage`节点。

## 自动修复

Gate失败不一定意味着要中断整个流程。如果开启了`autofix: true`（默认），dage会自动生成一个临时的修复节点。

流程：

1. Gate的shell命令失败了，比如`zola build`报了一个模板语法错误
2. dage创建一个`_autofix_gate_blog`临时节点，把gate的错误输出（最后3000字符）和上游节点的prompt（最多500字符）拼成修复prompt
3. 调用claude agent执行修复
4. 修复完成后，重新运行gate的shell命令
5. 如果gate通过了，继续执行下游；如果还是失败，阻断下游

```python
def _autofix_gate(gate, gate_result, ...):
    prompt = _AUTOFIX_PROMPT.format(
        cmd           = gate.cmd,
        error_output  = gate_result.output[-3000:],
        upstream_context = upstream_prompts[:500],
    )
    fix_node = Node(name=f"_autofix_{gate.name}", ...)
    fix_result = run_claude(fix_node, prompt, ...)
    if fix_result.status != Status.SUCCESS:
        return None
    # 修复后重试gate
    return run_shell(gate, gate.cmd, cwd=repo_dir)
```

每个gate最多autofix一次，防止无限循环。在本博客的构建中，`_autofix_gate_blog`确实被触发了一次 — blog模板有个语法错误，autofix自动修了，gate重试通过。

## 变量插值

节点之间通过`${...}`语法传递上下文：

```yaml
init_project:
  deps: [read_design, read_plan]
  prompt: |
    设计文档: ${nodes.read_design.output}
    实现计划: ${nodes.read_plan.output}
    仓库现状: ${nodes.scan_repo.output}
```

`${nodes.read_design.output}`会被替换成`read_design`节点执行后写入notes文件的内容。每个claude节点都有一个notes文件，执行完成后它的内容就成了`output`。

插值发生在节点即将执行时，不是在YAML加载时。这意味着前驱节点的产出可以动态地影响后继节点的prompt。

还支持`${vars.repo_dir}`（顶级变量）和`${nodes.gate_base.status}`（节点状态："success"/"failed"/"skipped"）。

## blog.yaml：一个真实案例

这个博客的完整构建流程用一个YAML文件描述，22个节点：

```
Layer 0: read_design, read_plan, scan_repo    (3个context并行)
Layer 1: init_project                          (依赖3个context)
Layer 2: base_template                         (依赖init)
Layer 3: gate_base                             (验证: zola build)
Layer 4: blog_list + read_projects             (两条链并行开始)
   链A: blog_list → blog_post → gate_blog → crawl_danluu → gate_crawl
   链B: read_projects → projects → gate_projects
Layer 5: homepage                              (汇聚两条链)
Layer 6: gate_homepage
Layer 7: deploy_config → final_check → report
```

首次运行结果（`results.json`）：

| 节点 | 耗时(秒) | 状态 |
|:-----|-------:|:-----|
| init_project | 1194 | success |
| base_template | 323 | success |
| blog_list | 456 | success |
| blog_post | 473 | success |
| crawl_danluu | 720 | success |
| projects | 835 | success |
| homepage | 456 | success |
| deploy_config | 240 | success |

22个节点全部success，零retry。总耗时约90分钟，但因为链A和链B是并行的，实际wall time更短。

这个YAML文件本身就展示了dage的几个核心模式：

1. Context节点先行 — `read_design`和`read_plan`只读设计文档，提炼信息，不写任何代码。它们的output通过`${nodes.read_design.output}`注入到后续所有实现节点的prompt中。

2. Gate驱动提交 — 每个gate通过后自动`git commit`。commit message格式是`feat(gate_name): upstream_nodes verified`。这意味着git history里的每个commit都对应一个机械验证通过的里程碑。

3. 并行worktree — `projects`和`blog_post`分别在`dage-projects`和`dage-blog_post`两个worktree里执行，完成后merge回main。

4. Autofix实战 — `_autofix_gate_blog`在运行日志中出现，说明`gate_blog`第一次失败后被自动修复了。

## 设计哲学

dage的三个设计选择背后有一个共同的信念：AI agent的输出是不可信的，但可以被机械验证。

- Gate不评判代码质量，只检查"能不能build"、"文件存不存在"。这是因为机械判断永远比AI判断更可靠。
- Worktree隔离不是因为git不能处理并发（git有锁机制），而是因为两个agent同时修改同一个文件时，merge conflict的解决本身又需要AI介入，引入了不确定性。隔离消除了这一层不确定性。
- 自动修复只给一次机会。如果autofix修不好，宁可阻断下游，也不要陷入"修 → 失败 → 再修 → 再失败"的循环。

这些选择的代价是灵活性 — dage不能处理需要人类判断的场景（比如"这个API设计好不好"）。但在它的能力范围内，它是可靠的。按下run，走开，回来时要么全部成功，要么你能从git history和gate日志里精确地知道哪一步出了什么问题。
