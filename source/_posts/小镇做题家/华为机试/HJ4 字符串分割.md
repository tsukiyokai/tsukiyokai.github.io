---
title: HJ4 字符串分割
categories:
  - 小镇做题家
  - 华为机试
abbrlink: 1d849351
tags:
  - 字符串
date: 2021-05-01 14:09:00
---

连续输入字符串，请按长度为 8 拆分每个字符串后输出到新的字符串数组；长度不是 8 整数倍的字符串请在后面补数字 0，空字符串不处理。

代码

```c++
#include <iostream>
#include <string>
using namespace std;

int main() {
    string s;
    while (cin >> s) {
        while (s.length() > 8) {
            cout << s.substr(0, 8) << endl;
            s = s.substr(8);
        }
        s.resize(8, '0');
        cout << s << endl;
    }
    return 0;
}
```

碰到的一个错误
这道题需要循环判定字符串的当前长度，所以不能输入之后直接求长度然后`while (len > 8)`，这样判定的是静态的，而且会报错。

学习一下 resize 用法
这个函数重定义容器大小，然后让新元素默认初始化为第二个参数
比如，`s.resize(8, '0');`，就是让 s 长度变为固定 8，然后让容器中新增的位置默认为'0'
比如"9"变成"90000000"

再复习一下 substr 的用法
s.substr(8)的意思是，s 从第八位到最后构成的子串
