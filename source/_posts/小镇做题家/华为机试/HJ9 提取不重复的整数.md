---
title: HJ9 提取不重复的整数
categories:
  - 小镇做题家
  - 华为机试
abbrlink: 2d4ad067
tags:
  - 字符串
date: 2021-05-02 16:32:39
---
输入一个int型整数，按照从右向左的阅读顺序，返回一个不含重复数字的新的整数。
保证输入的整数最后一位不是0。
输入描述:
输入一个int型整数

输出描述:
按照从右向左的阅读顺序，返回一个不含重复数字的新的整数

输入：
1551
输出：
15

```c++
#include<iostream>
#include<string>

using namespace std;

int main() {
    int n;
    cin >> n;
    string s = to_string(n);
    reverse(s.begin(), s.end());

    string res;
    for (auto& c : s)
        if (res.find(c) == string::npos)
            res += c;

    cout << stoi(res);

    return 0;
}
```