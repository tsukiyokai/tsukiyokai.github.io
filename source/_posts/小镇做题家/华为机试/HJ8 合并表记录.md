---
title: HJ8 合并表记录
categories:
  - 小镇做题家
  - 华为机试
abbrlink: c13b
tags:
  - map
date: 2021-04-28 23:14:46
---

## 题目

数据表记录包含表索引和数值（int范围的正整数），请对表索引相同的记录进行合并，即将相同索引的数值进行求和运算，输出按照key值升序进行输出。

输入：
先输入键值对的个数
然后输入成对的index和value值，以空格隔开
输出：
输出合并后的键值对（多行）

示例
输入：
4
0 1
0 2
1 2
3 4
输出：
0 3
1 2
3 4

## 解法：map

**代码**

```c++
#include <iostream>
#include <map>
using namespace std;

int main() {
    int n;
    cin >> n;
    map<int, int> iimap;
    int key, value;
    while (n--) {
        cin >> key >> value;
        iimap[key] += value;
    }
    for (auto it = iimap.begin(); it != iimap.end(); ++it) {
        cout << it->first << " " << it->second << endl;
    }

    return 0;
}
```