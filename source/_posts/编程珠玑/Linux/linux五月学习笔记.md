---
title: linux五月学习笔记
abbrlink: f3bf7ee2
categories:
  - 编程珠玑
  - Linux
tags:
  - OS
date: 2021-05-14 16:13:03
---
> 刚开始linux复建，记点东西。

#### 进入界面

进入ubt子系统的图形界面

```shell
$ xfce4-session
```

#### Super User DO

获取包的更新信息并安装更新

```shell
$ sudo apt-get update && sudo apt-get upgrade
```

#### man

查看ascii表

```shell
$ man ascii
```

#### cal|calendar|date

查看历史上的今天

```shell
$ calendar -t 1997.04.09
```

查看万年历

```shell
$ cal 1997
```

#### gcc|g++

```shell
$ g++ lixing.cpp -o lixing
```

gcc = GNU Compiler Collection
g++是它的C++版
`-o`标志用来指明编译后所输出文件的名字

```shell
$ ./lixing
```

`./`的意思是执行当前目录下的某个可执行文件