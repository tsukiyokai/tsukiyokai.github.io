---
title: PE1 Multiples of 3 and 5
categories:
  - 小镇做题家
  - Project Euler
tags: 组合数学
abbrlink: '73e1'
date: 2021-04-05 03:32:15
---

## 题目

If we list all the natural numbers below 10 that are multiples of 3 or 5, we get 3, 5, 6 and 9. The sum of these multiples is 23.
Find the sum of all the multiples of 3 or 5 below 1000.

如果我们列出所有低于10的自然数，它们是3或5的倍数，则得到3、5、6和9。这些倍数的总和为23。
求1000以下所有3或5的倍数之和。

## 解法1：暴力法

**代码**

```c++
#include <iostream>
#include <ctime>

using namespace std;

int main() {
    unsigned int sum = 0;
    const int N = 1000;
    for (int i = 1; i < N; ++i) {
        if (i % 3 == 0 || i % 5 == 0) sum += i;
    }
    cout << sum << endl;

    return 0;
}
```

## 解法2：容斥原理

**代码**

```c++
#include <iostream>
#include <ctime>

using namespace std;

unsigned int sumN(int n, const int N) {
    return (n + (N - 1) / n * n) * ((N - 1) / n) / 2;
}

int main() {
    unsigned int sum_3 = 0, sum_5 = 0, sum_15 = 0;
    const int N = 1000;
    sum_3 = sumN(3, N);
    sum_5 = sumN(5, N);
    sum_15 = sumN(15, N);
    unsigned int sum = sum_3 + sum_5 - sum_15;
    cout << sum << endl;

    return 0;
}
```