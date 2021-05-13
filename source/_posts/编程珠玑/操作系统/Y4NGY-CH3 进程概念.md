---
title: Y4NGY-CH3 进程概念
abbrlink: af3f7656
categories:
  - 编程珠玑
  - 操作系统
tags:
  - OS
date: 2021-05-13 00:54:19
---

### 程序和进程

- a program is a passive entity, such as a file containing a list of instructions stored on disk(often called an executable file).

- a program becomes a process when an executable file is loaded into memory.

- a process is an active entity, with a program counter specifying the next instruction to executue.

### PROGRAM COUNTER

- PC是一个CPU中的寄存器，里面存放着下一条要执行指令的内存地址。在Intel x86和Itanium微处理器中，它叫做指令指针（Instruction Pointer, IP），又称指令地址寄存器、指令计数器。
- 通常，CPU在取完一条指令之后会将PC寄存器的值+1，以计算下条要执行指令的地址。PC=PC+1，对指针+1其实不是指向原先后面，而是移动一整个指针的大小。

### POCESS IN MEMORY

STACK 存放局部变量、函数返回地址
HEAP 运行时（而非编译时）的动态内存分配
DATA 全局和静态变量数据
TEXT 代码

### 并发的进程

- Concurrency: the fact of two or more events or circumstances happening or existing at the same time.
- 并发与并行的区别：并行的行=runing
- 进程并发的动机：多道程序设计
- 为什么不叫“并行的进程”？并发：宏观上共存，但微观上轮流执行。

### 并发进程共享CPU

- 并发进程可能无法一次性执行完毕，会走走停停
- 一个进程在执行过程中可能会被另一个进程替换并占有CPU，这个过程称作“进程切换”。

### 进程的定义

- 进程是一个程序的依次执行过程
    - 能完成具体的功能
    - 是在某个数据集合上完成的
    - 执行过程是可并发的
- 进程是资源分配的最小单位。（线程是CPU调度的最小单位）

### 进程状态

- 进程有三种基本状态
  - 运行态（running）
  - 就绪态（ready） 等待CPU
  - 阻塞态、等待态（waiting）等待某些事件的发生比如IO

### 进程何时离开CPU

- 内部事件
  - 进程主动放弃（yield）CPU进入阻塞、终止状态
  - e.g. 使用IO设备
- 外部事件
  - 进程被剥夺CPU使用权进入就绪态。这个动作叫抢占（preempt）。
  - e.g.最常见的情况：时间片到达，高优先级进程到达。
