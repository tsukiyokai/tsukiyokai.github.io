---
title: Y4NGY-CH2 操作系统结构
abbrlink: 26a4cad
categories:
  - 编程珠玑
  - 操作系统
tags:
  - OS
date: 2021-05-11 01:22:02
---
小破站的一个OS系列视频，讲者是南京森林警察学院的一位教师，说实话比我当年吉大计院的老师讲的易懂，计划这周之内（20210511-20210516）速览一遍，回顾一下基础。

### 中断

OS is a INTERRUPT driven system.
中断之于OS正如矛盾之于事物。

### 存储层次图

**volatile mempry 易失性存储**
- register 寄存器
- cache 缓存（高速缓存）
- main memory 主存

**nonvolatile memory 非易失性存储**
- solid-state disk SSD（固态硬盘）
- magnetic disk 磁盘（硬盘）
- optical disk 光盘
- magnetic tapes 磁带

### 计算机体系结构

- 单处理器系统
- 多处理器系统
  - 非对称处理（一个主CPU和一些从CPU）
  - 对称处理（所有CPU互相独立，现代OS使用）
- 集群系统 clustered system
  集群系统由若干节点通过网络连接在一起，每个节点可为单或多处理器系统，节点之间是松耦合关系。适用于高可用性、高性能计算。集群系统演变出了现代的云计算。

### 操作系统结构

- 单用户单道模式
- 多道程序设计（处理机和IO设备具备并行工作能力）
- 分时系统（是多道程序设计思想的自然延伸，也称多任务系统）
    - CPU调度：暂时不用或长时间不用的进程，交换出去到虚拟内存
    - 虚拟内存：所有东西进入内存才能被执行；处于虚拟内存中的指令不可以马上被执行。
    - 磁盘、File
    - 同步=有商量，有通信的，有联系的；
      异步=随机，不经过商量的，不知道下一秒会发生什么的。

### 本讲内容

- 操作系统的服务
  - 为用户（使用）
  - 为程序员（创造）
- 操作系统的构建方式（OS的设计原则）
- GNU/Linux

### OS提供哪些服务？

USER INTERFACE(面对USER)
GUI+batch+command_line

system call(面对PROGRAMMER)
services: 程序执行+IO操作+文件系统+通信(IPC)+资源分配+记账+错误检测+安全机制

OS

Hardwares

### USER INTERFACE

为用户与OS交互提供方式。

- CLI 命令行接口
  - command interpreter(shell 壳)
- GUI 图形化用户界面
  - a user friendly graphical user interface.
- Batch 批处理
  - it is a file which contains commands and directives.

什么是接口？接口就是交界处，并非一定要插进什么地方才能叫接口。从这个意义上讲，USB和API是同一种东西，USB工作在硬件与硬件的交界处，API工作在硬件与软件或软件与软件的交界处，他们都是接口。

### 系统调用

- 系统调用提供了访问和使用操作系统所提供的服务的接口。
  - 系统调用的实现代码是操作系统级的
  - 这个接口通常是面向程序员的
- API指明了参数和返回值的一组函数。
  - 应用程序App的开发人员透过API间接访问了系统调用
  - Windows API/POSIX API/JAVA API

### 标准C程序

- printf是standard C Library提供的API
- printf函数的调用引发了对应的系统调用write的执行（把显示器当成一个文件，对这个文件执行写的命令，结果就是显示器显示出我们写的内容）
- write执行结束时的返回值（成功输出的字符的个数）传递回标准C库，标准C库再返回给用户程序的。

### 双重模式 DUAL MODE

- MOS有一个特殊的硬件，用于划分系统运行的状态，至少有两种单独运行模式：
  - 用户模式：执行用户代码
  - 内核模式：执行OS代码

- 目的：确保操作系统正确的运行，特权指令不能让用户程序随便运行
- 实现方式
 - 用一个硬件模式位来表示当前模式：0表示内核模式，1表示用户模式

### 运行模式的切换

- sys call需要在哪种模式下执行？kernel mode
- 捏的应用程序运行在哪种模式下？user mode
- 调用API函数printf时，运行模式如何切换？

### TRAP MECHANISM 陷阱机制

陷入 mode bit置0
返回 mode bit置1

### 系统调用的实现机制

- 每个系统调用都有一个唯一的数字编号，被称为系统调用号。
- 用户代码调用API时，API会向系统调用接口指明其所要用的系统调用号，操作系统内核中维护了一张索引表，依据这个调用号可以检索到访系统调用代码在内核中的位置。

### OS的构建方式（设计模式）

- MULTICS SYSTEM 多路信息计算系统

### OS设计成为一门学科

- 多道系统涉及的思想使用操作系统的复杂性变得难以控制。
  - MULTICS
  - OS 360
- 操作系统设计逐渐形成一门学科
  - 如何处理硬件的复杂性？
  - UNIX基于MULTICS系统开发，但已经大大简化

## OS的设计思路

- 设计目标
  - 用户目标
  - 系统目标
- 机制与策略分离
  - 机制：如何做
  - 策略：做什么
  - 微内核操作系统Mach->Darwin->macOS（核心极小，策略不属于微内核，可以灵活加载，微内核OS是机制与策略分离的成功代表）

## GNU/Linux

- Open-source, closed-source, hybrid OS (L\W\M)
- Source code (高级语言) and binary code (01)
  源码编译链接到binarycode容易，反编译很难（逆向工程）
  如果不开源就很难知道代码的原理。

## 开源历史

- 初衷：自由分享
- 阻碍：版权保护和商业利益
- 1983年GNU项目（GNU = GNU is Not Unix），旨在创建一个免费开源兼容的Unix的操作系统。
- GPL（GNU General Public License）：源码和二进制码一起发布，源码任何修改应按照同样的GPL许可发布。
- 1990年第一个GNU核心（Alix）Hurd完成开发
- 1991年Linus开发出类Unix内核的Linux并于次年开源，GNU系统和Linux合并后成为今日的GNU/Linux。
