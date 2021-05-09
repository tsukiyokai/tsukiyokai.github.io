---
title: HJ90 合法IP
categories:
  - 小镇做题家
  - 华为机试
abbrlink: 44cbe9f3
tags:
  - 字符串
date: 2021-05-03 01:17:04
---
题目描述
现在IPV4下用一个32位无符号整数来表示，一般用点分方式来显示，点将IP地址分成4个部分，每个部分为8位，表示成一个无符号整数（因此不需要用正号出现），如10.137.17.1，是我们非常熟悉的IP地址，一个IP地址串中没有空格出现（因为要表示成一个32数字）。
现在需要你用程序来判断IP是否合法。

注意本题有多组样例输入。

输入描述:
输入一个ip地址，保证是xx.xx.xx.xx的形式（xx为整数）
输出描述:
返回判断的结果YES or NO

示例1
输入
10.138.15.1
255.0.0.255
255.255.255.1000
输出
YES
YES
NO

```c++
#include<iostream>
#include<string>
#include<vector>
#include<sstream>

using namespace std;

bool isright(string& s) {
    return stoi(s) >= 0 && stoi(s) <= 255;
}

int main() {
    string s;
    while (getline(cin, s)) {
        vector<string> v;
        string tmp;
        stringstream ss(s);
        while (getline(ss, tmp, '.'))
            v.push_back(tmp);
        bool flag = 1;
        for (string& str : v)
            if (!isright(str)) {
                flag = 0;
                break;
            }
        if (flag == 0) cout << "NO" << endl;
        else cout << "YES" << endl;
    }

    return 0;
}
```