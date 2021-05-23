---
title: OS原理及Linux实践课堂笔记
abbrlink: 1086390c
categories:
    - 编程珠玑
    - 操作系统
tags:
    - OS
date: 2021-05-13 00:54:19
---

### 中断

OS is a INTERRUPT driven system.
中断之于 OS 正如矛盾之于事物。

### 存储层次图

**volatile memory 易失性存储**

-   register 寄存器
-   cache 缓存（高速缓存）
-   main memory 主存

**nonvolatile memory 非易失性存储**

-   solid-state disk SSD（固态硬盘）
-   magnetic disk 磁盘（硬盘）
-   optical disk 光盘
-   magnetic tapes 磁带

### 计算机体系结构

-   单处理器系统
-   多处理器系统
    -   非对称处理（一个主 CPU 和一些从 CPU）
    -   对称处理（所有 CPU 互相独立，现代 OS 使用）
-   集群系统 clustered system
    集群系统由若干节点通过网络连接在一起，每个节点可为单或多处理器系统，节点之间是松耦合关系。适用于高可用性、高性能计算。集群系统演变出了现代的云计算。

### 操作系统结构

-   单用户单道模式
-   多道程序设计（处理机和 IO 设备具备并行工作能力）
-   分时系统（是多道程序设计思想的自然延伸，也称多任务系统）
    -   CPU 调度：暂时不用或长时间不用的进程，交换出去到虚拟内存
    -   虚拟内存：所有东西进入内存才能被执行；处于虚拟内存中的指令不可以马上被执行。
    -   磁盘、File
    -   同步=有商量，有通信的，有联系的；
        异步=随机，不经过商量的，不知道下一秒会发生什么的。

### OS 提供哪些服务？

USER INTERFACE(面对 USER)
GUI+batch+command_line

system call(面对 PROGRAMMER)
services: 程序执行+IO 操作+文件系统+通信(IPC)+资源分配+记账+错误检测+安全机制

OS

Hardwares

### USER INTERFACE

为用户与 OS 交互提供方式。

-   CLI 命令行接口
    -   command interpreter(shell 壳)
-   GUI 图形化用户界面
    -   a user friendly graphical user interface.
-   Batch 批处理
    -   it is a file which contains commands and directives.

什么是接口？接口就是交界处，并非一定要插进什么地方才能叫接口。从这个意义上讲，USB 和 API 是同一种东西，USB 工作在硬件与硬件的交界处，API 工作在硬件与软件或软件与软件的交界处，他们都是接口。

### 系统调用

-   系统调用提供了访问和使用操作系统所提供的服务的接口。
    -   系统调用的实现代码是操作系统级的
    -   这个接口通常是面向程序员的
-   API 指明了参数和返回值的一组函数。
    -   应用程序 App 的开发人员透过 API 间接访问了系统调用
    -   Windows API/POSIX API/JAVA API

### 标准 C 程序

-   printf 是 standard C Library 提供的 API
-   printf 函数的调用引发了对应的系统调用 write 的执行（把显示器当成一个文件，对这个文件执行写的命令，结果就是显示器显示出我们写的内容）
-   write 执行结束时的返回值（成功输出的字符的个数）传递回标准 C 库，标准 C 库再返回给用户程序的。

### 双重模式 DUAL MODE

-   MOS 有一个特殊的硬件，用于划分系统运行的状态，至少有两种单独运行模式：

    -   用户模式：执行用户代码
    -   内核模式：执行 OS 代码

-   目的：确保操作系统正确的运行，特权指令不能让用户程序随便运行
-   实现方式
-   用一个硬件模式位来表示当前模式：0 表示内核模式，1 表示用户模式

### 运行模式的切换

-   sys call 需要在哪种模式下执行？kernel mode
-   捏的应用程序运行在哪种模式下？user mode
-   调用 API 函数 printf 时，运行模式如何切换？

### TRAP MECHANISM 陷阱机制

陷入 mode bit 置 0
返回 mode bit 置 1

### 系统调用的实现机制

-   每个系统调用都有一个唯一的数字编号，被称为系统调用号。
-   用户代码调用 API 时，API 会向系统调用接口指明其所要用的系统调用号，操作系统内核中维护了一张索引表，依据这个调用号可以检索到访系统调用代码在内核中的位置。

### OS 的构建方式（设计模式）

-   MULTICS SYSTEM 多路信息计算系统

### OS 设计成为一门学科

-   多道系统涉及的思想使用操作系统的复杂性变得难以控制。
    -   MULTICS
    -   OS 360
-   操作系统设计逐渐形成一门学科
    -   如何处理硬件的复杂性？
    -   UNIX 基于 MULTICS 系统开发，但已经大大简化

## OS 的设计思路

-   设计目标
    -   用户目标
    -   系统目标
-   机制与策略分离
    -   机制：如何做
    -   策略：做什么
    -   微内核操作系统 Mach->Darwin->macOS（核心极小，策略不属于微内核，可以灵活加载，微内核 OS 是机制与策略分离的成功代表）

## GNU/Linux

-   Open-source, closed-source, hybrid OS (L\W\M)
-   Source code (高级语言) and binary code (01)
    源码编译链接到 binarycode 容易，反编译很难（逆向工程）
    如果不开源就很难知道代码的原理。

## 开源历史

-   初衷：自由分享
-   阻碍：版权保护和商业利益
-   1983 年 GNU 项目（GNU = GNU is Not Unix），旨在创建一个免费开源兼容的 Unix 的操作系统。
-   GPL（GNU General Public License）：源码和二进制码一起发布，源码任何修改应按照同样的 GPL 许可发布。
-   1990 年第一个 GNU 核心（Alix）Hurd 完成开发
-   1991 年 Linus 开发出类 Unix 内核的 Linux 并于次年开源，GNU 系统和 Linux 合并后成为今日的 GNU/Linux。

## 程序和进程

-   a program is a passive entity, such as a file containing a list of instructions stored on disk(often called an executable file).

-   a program becomes a process when an executable file is loaded into memory.

-   a process is an active entity, with a program counter specifying the next instruction to executue.

## PROGRAM COUNTER

-   PC 是一个 CPU 中的寄存器，里面存放着下一条要执行指令的内存地址。在 Intel x86 和 Itanium 微处理器中，它叫做指令指针（Instruction Pointer, IP），又称指令地址寄存器、指令计数器。
-   通常，CPU 在取完一条指令之后会将 PC 寄存器的值+1，以计算下条要执行指令的地址。PC=PC+1，对指针+1 其实不是指向原先后面，而是移动一整个指针的大小。

## POCESS IN MEMORY

STACK 存放局部变量、函数返回地址
HEAP 运行时（而非编译时）的动态内存分配
DATA 全局和静态变量数据
TEXT 代码

## 并发的进程

-   Concurrency: the fact of two or more events or circumstances happening or existing at the same time.
-   并发与并行的区别：并行的行=runing
-   进程并发的动机：多道程序设计
-   为什么不叫“并行的进程”？并发：宏观上共存，但微观上轮流执行。

## 并发进程共享 CPU

-   并发进程可能无法一次性执行完毕，会走走停停
-   一个进程在执行过程中可能会被另一个进程替换并占有 CPU，这个过程称作“进程切换”。

## 进程的定义

-   进程是一个程序的依次执行过程
    -   能完成具体的功能
    -   是在某个数据集合上完成的
    -   执行过程是可并发的
-   进程是资源分配的最小单位。（线程是 CPU 调度的最小单位）

## 进程状态

-   进程有三种基本状态
    -   运行态（running）
    -   就绪态（ready） 等待 CPU
    -   阻塞态、等待态（waiting）等待某些事件的发生比如 IO

## 进程何时离开 CPU？

-   内部事件
    -   进程主动放弃（yield）CPU 进入阻塞、终止状态
    -   e.g. 使用 IO 设备
-   外部事件
    -   进程被剥夺 CPU 使用权进入就绪态。这个动作叫抢占（preempt）。
    -   e.g.最常见的情况：时间片到达，高优先级进程到达。
