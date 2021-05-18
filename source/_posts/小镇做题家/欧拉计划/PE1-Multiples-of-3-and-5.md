---
title: PE1 Multiples of 3 and 5
categories:
  - 小镇做题家
  - 欧拉计划
tags: 组合数学
abbrlink: f5248637
date: 2021-04-05 03:32:15
---

## 题目

If we list all the natural numbers below 10 that are multiples of 3 or 5, we get 3, 5, 6 and 9. The sum of these multiples is 23. Find the sum of all the multiples of 3 or 5 below 1000.

如果我们列出所有低于 10 的自然数，它们是 3 或 5 的倍数，则得到 3、5、6 和 9。这些倍数的总和为 23。求 1000 以下所有 3 或 5 的倍数之和。

## 解法 1：暴力

**代码**

```c++
#include <iostream>
using namespace std;

int main() {
    unsigned int sum = 0;
    const int N = 1000;
    for (int i = 1; i < N; ++i)
        if (i % 3 == 0 || i % 5 == 0)
            sum += i;
    cout << sum << endl;
    return 0;
}
```

## 解法 2：容斥原理

**代码**

```c++
#include <iostream>
using namespace std;

// 求N以内所有n的倍数之和
unsigned sumu(int n, const int N) {
    // (首项n+末项)*项数/2
    return (n + (N - 1) / n * n) * ((N - 1) / n) / 2;
}

int main() {
    const int N = 1000;
    unsigned sum_3 = sumu(3, N);
    unsigned sum_5 = sumu(5, N);
    unsigned sum_15 = sumu(15, N);
    unsigned sum = sum_3 + sum_5 - sum_15;
    cout << sum << endl;
    return 0;
}
```

## 参考资料

https://www.xarg.org/puzzle/project-euler/problem-1/
