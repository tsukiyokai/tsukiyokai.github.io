---
title: Y4NGY-操作系统原理及Linux实践
abbrlink: 26a4cad
categories:
  - 编程珠玑
  - 操作系统
tags:
  - OS
date: 2021-05-11 01:22:02
---
小破站的一个OS系列视频，讲者是南京森林警察学院的一位教师，说实话比我当年吉大计院的老师讲的易懂，计划这周之内（20210511-20210516）速览一遍，回顾一下基础。

## 2 操作系统体系结构

### 中断

OS is a INTERRUPT driven system.
中断之于OS正如矛盾之于马哲。

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

### 体系结构

- 单处理器系统
- 多处理器系统
  - 非对称处理（一个主CPU和一些从CPU）
  - 对称处理（所有CPU互相独立，现代OS使用）
- 集群系统 clustered system
  集群系统由若干节点通过网络连接在一起，每个节点可为单或多处理器系统，节点之间是松耦合关系。适用于高可用性、高性能计算。集群系统演变出了现代的云计算。

### OS结构

- 单用户单道模式
- 多道程序设计（处理机和IO设备具备并行工作能力）
- 分时系统（是多道程序设计思想的自然延伸，也称多任务系统）
