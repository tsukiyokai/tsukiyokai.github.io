---
title: HJ3 明明的随机数
categories:
  - 小镇做题家
  - 华为机试
abbrlink: 3d113277
tags:
  - 集合
date: 2021-05-03 19:25:22
---

明明想在学校中请一些同学一起做一项问卷调查，为了实验的客观性，他先用计算机生成了 N 个 1 到 1000 之间的随机整数（N≤1000），对于其中重复的数字，只保留一个，把其余相同的数去掉，不同的数对应着不同的学生的学号。然后再把这些数从小到大排序，按照排好的顺序去找同学做调查。请你协助明明完成“去重”与“排序”的工作(同一个测试用例里可能会有多组数据(用于不同的调查)，希望大家能正确处理)。

注：测试用例保证输入参数的正确性，答题者无需验证。测试用例不止一组。当没有新的输入时，说明输入结束。

```c++
#include <iostream>
#include <set>

using namespace std;

int main() {
    int N;
    while (cin >> N) {
        set<int> uset;
        while (N--) {
            int n;
            cin >> n;
            uset.insert(n);
        }
        for (auto& num : uset) {
            cout << num << endl;
        }
    }

    return 0;
}
```

利用 map 的两个性质：元素互斥、自动有序
