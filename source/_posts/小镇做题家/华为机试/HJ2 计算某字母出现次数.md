---
title: HJ2 计算某字母出现次数
categories:
  - 小镇做题家
  - 华为机试
abbrlink: c680c3f7
tags:
  - 字符串
date: 2021-05-01 02:38:43
---
## 题目

题目描述
写出一个程序，接受一个由字母、数字和空格组成的字符串，和一个字母，然后输出输入字符串中该字母的出现次数。不区分大小写，字符串长度小于500。

输入描述:
第一行输入一个由字母和数字以及空格组成的字符串，第二行输入一个字母。

输出描述:
输出输入字符串中含有该字符的个数。

示例1
输入
ABCabc
A
输出
2

## 解法

```c++
#include <iostream>
#include <cctype>
#include <string>

using namespace std;
int main() {
    string str;
    getline(cin, str);
    char target;
    cin >> target;
    target = static_cast<char>(tolower(target));
    int num = 0;
    for (auto c : str) {
        if (tolower(c) == target) num++;
    }
    cout << num;
}
```

注意点
1.tolower记得转成char
2.tolower在cctype里