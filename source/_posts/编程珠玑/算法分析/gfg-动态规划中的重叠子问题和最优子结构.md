---
title: gfg-动态规划中的重叠子问题和最优子结构
abbrlink: e74d463b
categories:
  - 编程珠玑
  - 算法分析
tags:
  - DP
date: 2021-04-29 15:40:16
---
动态规划是一种算法范式，它通过将给定的复杂问题分解为子问题来求解，并存储子问题的结果，以避免再次计算相同的结果。下面是一个问题的两个主要性质，表明给定的问题可以用动态规划来解决。

在这篇文章中，我们将详细讨论第一个属性（重叠子问题）。下一篇文章将讨论动态规划的第二个性质，见[Set2](https://www.geeksforgeeks.org/dynamic-programming-set-2-optimal-substructure-property/)。

1. 重叠子问题 Overlapping Subproblems
2. 最优子结构 Optimal Substructure

## 重叠子问题

像分而治之一样，动态规划将解决方案结合到子问题中。动态规划主要用于需要反复求解同一子问题时。在动态规划中，子问题的计算解存储在一个表中，这样就不必重新计算。因此，当没有公共（重叠）子问题时，动态规划是没有用的，因为如果不再需要这些解决方案，就没有必要存储解决方案。例如，二分查找就没有公共子问题。以斐波那契数的递推程序为例，有许多子问题需要反复求解。

在数学上，斐波那契数列以如下被以递推的方法定义：
`F(0)=0,F(1)=1,F(n)=F(n-1)+F(n-2)(n≥2，n∈N*)`

```c++
int fib(int n) {
    if (n <= 1) return n;
    return fib(n - 1) + fib(n - 2);
}
```

fib(5)执行的递归树：

```
                        fib(5)
                     /             \
               fib(4)                fib(3)
             /      \                /     \
         fib(3)      fib(2)         fib(2)    fib(1)
        /     \        /    \       /    \
  fib(2)   fib(1)  fib(1) fib(0) fib(1) fib(0)
  /    \
fib(1) fib(0)
```

我们可以看到函数fib(3)被调用了两次。如果我们存储了fib(3)的值，那么我们就可以重用旧的存储值，而不是再次计算它。有以下两种不同的方法来存储值，以便可以重用这些值：

1. Memoization (Top Down) - 记忆化（自上而下）
2. Tabulation (Bottom Up) - 表格化（自下而上）

#### 记忆化

一个问题的记忆程序类似于递归版本，只是做了一个小小的修改，即在计算解决方案之前先查看查找表。我们初始化一个所有初始值都为NIL的查找数组。每当我们需要子问题的解决方案时，我们首先查看查找表。如果存在预先计算的值，则返回该值，否则，计算该值并将结果放入查找表中，以便以后可以重用。

注：NIL好像是pascal里的东西，大概理解成相当于C++的NULL吧。

下面是第n个斐波那契数的记忆版本。

```c++
#include <iostream>
using namespace std;
constexpr auto NIL = -1;
constexpr auto MAX = 100;

int lookup[MAX];

void _initialize() {
    int i;
    for (i = 0; i < MAX; i++)
        lookup[i] = NIL;
}

int fib(int n) {
    if (lookup[n] == NIL) {
        if (n <= 1) lookup[n] = n;
        else lookup[n] = fib(n - 1) + fib(n - 2);
    }
    return lookup[n];
}

int main() {
    int n = 40;
    _initialize();
    cout << "Fibonacci number is " << fib(n) << endl; // 102334155
    return 0;
}
```

#### 制表化

针对给定问题的制表程序以自下而上的方式构建一个表，并从表中返回最后一个条目。例如，对于相同的Fibonacci数，我们首先计算fib(0)，然后计算fib(1)，然后计算fib(2)，然后计算fib(3)，依此类推。所以从字面上说，我们是自下而上建立子问题的解决方案。
下面是第n个斐波那契数的表格版本。

```c++
#include<stdio.h>
using namespace std;

int fib(int n) {
    int* f = new int[n + 1];
    int i;
    f[0] = 0; f[1] = 1;
    for (i = 2; i <= n; i++)
        f[i] = f[i - 1] + f[i - 2];
    return f[n];
}

int main() {
    int n = 40;
    printf("Fibonacci number is %d \n", fib(n)); // 102334155
    return 0;
}
```

表格化和记忆化存储子问题的解。在记忆化中，表格是按需填写的，而在表格化中，从第一个条目开始，所有条目都是逐个填写的。与表格化的版本不同，查寻表的所有条目不一定都填写在记忆化的版本中。例如，lcs问题的记忆解决方案不一定会填满所有条目。

## 最优子结构

动态规划是一种在多项式时间内解决某些特定类型问题的技术。动态规划解的速度比指数暴力法快，并且易于证明其正确性。在研究如何动态思考问题之前，我们需要了解：

重叠子问题
最优子结构

最优子结构：如果给定问题的最优解可以由其子问题的最优解得到，则给定问题具有最优子结构性质。

例如，最短路径问题具有以下最优子结构性质：
如果节点x位于从源节点u到目的节点v的最短路径中，则从u到v的最短路径是从u到x的最短路径和从x到v的最短路径的组合。像Floyd–Warshall和Bellman–Ford等标准的最短路径算法都是动态规划的典型例子。

另一方面，最长路径问题则不具有最优子结构性质。这里所说的最长路径是指两个节点之间最长的简单路径（没有循环的路径）。考虑CLRS手册中给出的以下未加权图。从q到t有两条最长的路径：q→r→t和q→s→t。与最短路径不同，这些最长路径不具有最优子结构特性。
例如，最长路径q→r→t不是从q到r的最长路径和从r到t的最长路径的组合
因为从q到r的最长路径是q→s→t→r，而从r到t的最长路径是r→q→s→t。

![](https://media.geeksforgeeks.org/wp-content/cdn-uploads/LongestPath.gif)