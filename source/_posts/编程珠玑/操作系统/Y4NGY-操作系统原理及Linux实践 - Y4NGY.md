---
title: Y4NGY-OS原理及Linux实践 CH2
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