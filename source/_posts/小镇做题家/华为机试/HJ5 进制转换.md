---
title: HJ5 进制转换
categories:
  - 小镇做题家
  - 华为机试
abbrlink: dfb3
tags:
  - 字符串
  - 数学
  - 模拟
date: 2021-05-01 01:14:07
---
## 题目

写出一个程序，接受一个十六进制的数，输出该数值的十进制表示。

输入描述:
输入一个十六进制的数值字符串。
输出描述:
输出该数值的十进制字符串。不同组的测试用例用\n隔开。

示例1
输入
0xA
0xAA
输出
10
170

## 解法：模拟+umap

```c++
#include<iostream>
#include<string>
#include<unordered_map>

using namespace std;

int main() {
    string hex;
    unordered_map<char, int> m = {
        {'0',0},
        {'1',1},
        {'2',2},
        {'3',3},
        {'4',4},
        {'5',5},
        {'6',6},
        {'7',7},
        {'8',8},
        {'9',9},
        {'A',10},
        {'B',11},
        {'C',12},
        {'D',13},
        {'E',14},
        {'F',15}
    };
    while (cin >> hex) {
        int res = 0;
        hex.erase(hex.begin(), hex.begin() + 1);
        for (auto& c : hex) {
            res *= 16;
            res += m[c];
        }
        cout << res << endl;
    }
    return 0;
}
```

没有自动排序需求的话，就不用map，而是用unordered_map，因为map内部是红黑树，而unordered_map内部是哈希，红黑树还是更复杂一些。