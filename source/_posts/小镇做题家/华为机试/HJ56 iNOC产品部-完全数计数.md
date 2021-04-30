---
title: HJ56 iNOC产品部-完全数计数
categories:
  - 小镇做题家
  - 华为机试
abbrlink: e9b0
tags:
  - 字符串
date: 2021-04-29 11:31:17
---

## 题目

完全数（Perfect number），又称完美数或完备数，是一些特殊的自然数。
它所有的真因子（即除了自身以外的约数）的和（即因子函数），恰好等于它本身。
例如：28，它有约数1、2、4、7、14、28，除去它本身28外，其余5个数相加，1+2+4+7+14=28。
输入n，请输出n以内(含n)完全数的个数。计算范围, 0 < n <= 500000
本题输入含有多组样例。

## 解法：暴力

代码

```c++
#include <iostream>
#include <cmath>
using namespace std;

bool isperfect(int n) {
    int sum = 0;
    for (int i = 1; i < sqrt(n); i++) {
        if (n % i == 0) sum += i + n / i;
    }
    sum -= n; // 除去它自身外
    if (pow(static_cast<int>(sqrt(n)), 2) == n) sum -= sqrt(n);
    if (n == sum) return true;
    return false;
}

int main() {
    int n;
    while (cin >> n) {
        int cnt = 0;
        if (n > 500000 || n < 0) cout << "-1" << endl;
        for (int i = 1; i <= n; i++) {
            if (isperfect(i)) cnt++;
        }
        cout << cnt << endl;
    }
    return 0;
}
```