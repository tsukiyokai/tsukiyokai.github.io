---
title: HJ1 字符串最后一个单词的长度
categories:
  - 小镇做题家
  - 华为机试
abbrlink: 3494f0ab
tags:
  - 字符串
date: 2021-05-01 00:59:49
---

计算字符串最后一个单词的长度，单词以空格隔开，字符串长度小于5000。

## 解法1：find

```c++
#include<iostream>
#include<string>
using namespace std;

int main() {
    string s;
    while (getline(cin, s)) {
        cout << s.length() - s.find_last_of(" ") - 1 << endl;
    }
    return 0;
}
```

## 解法2：vector

输入是一行带空格的字符串，可以用循环+cin>>来让它自动被空格分开，各自存到`vector<string> vec`中去。

```c++
#include<iostream>
#include<string>
#include<vector>
using namespace std;

int main() {
    string word;
    vector<string> vec;
    while (cin >> word) {
        vec.push_back(word);
    }
    cout << vec.back().size() << endl;
    return 0;
}
```