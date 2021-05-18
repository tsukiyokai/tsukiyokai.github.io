---
title: HJ6 质数因子
categories:
  - 小镇做题家
  - 华为机试
abbrlink: "8e9984"
tags:
  - 数学
date: 2021-05-02 17:17:35
---

输入一个正整数，按照从小到大的顺序输出它的所有质因子（重复的也要列举），如 180 的质因子为 2 2 3 3 5。

```c++
#include<iostream>

using namespace std;

int main() {
    long n;
    cin >> n;
    while (n != 1) {
        for (int i = 2; i <= n; i++) {
            if (n % i == 0) {
                cout << i << " ";
                n /= i;
                break;
            }
        }
    }
    return 0;
}
```

以前可以通过，现在超时了
