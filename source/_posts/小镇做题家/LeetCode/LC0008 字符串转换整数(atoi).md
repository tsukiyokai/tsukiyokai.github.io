---
title: LC8 字符串转换整数(atoi)
abbrlink: 11334fc8
categories:
    - 小镇做题家
    - LeetCode
tag: 字符串
date: 2021-04-30 17:42:03
---

## 题目

请你来实现一个 `myAtoi(string s)`  函数，使其能将字符串转换成一个 32 位有符号整数（类似 C/C++中的 atoi 函数）。

函数 `myAtoi(string s)` 的算法如下：

读入字符串并丢弃无用的前导空格。
检查下一个字符（假设还未到字符末尾）为正还是负号，读取该字符（如果有）。确定最终结果是负数还是正数。如果两者都不存在，则假定结果为正。
读入下一个字符，直到到达下一个非数字字符或到达输入的结尾。字符串的其余部分将被忽略。
将前面步骤读入的这些数字转换为整数（即，"123"->123，"0032"->32）。如果没有读入数字，则整数为 0。必要时更改符号（从步骤 2 开始）。
如果整数数超过 32 位有符号整数范围`[−2^31,2^31−1]`，需要截断这个整数，使其保持在这个范围内。具体来说，小于 −2^31 的整数应该被固定为 −2^31，大于 2^31−1 的整数应该被固定为 2^31−1。
返回整数作为最终结果。

注意：
本题中的空白字符只包括空格字符' '。
除前导空格或数字后的其余字符串外，请勿忽略任何其他字符。

## 解法 1：阅读理解

对着 case 改了 8 遍后才通过。

```c++
class Solution {
public:
    int myAtoi(string& s) {
        while (s[0] == ' ')
            s.erase(s.begin());

        char symbol;

        if (s[0] == '-') {
            symbol = '-';
            s = s.substr(1, s.length() - 1);
        }
        else if (s[0] == '+') {
            symbol = '+';
            s = s.substr(1, s.length() - 1);
        }
        else if (isdigit(s[0])) symbol = '+';
        else return 0;
        s = s.substr(0, s.find_first_not_of("0123456789"));
        long res = 0;
        for (auto& c : s) {
            if (res >= INT32_MAX) {
                break;
            }
            else {
                res *= 10;
                res += c - '0';
            }
        }
        if (symbol == '-') res *= -1;
        else res *= 1;
        if (res <= INT32_MIN) return INT32_MIN;
        else if (res >= INT32_MAX) return INT32_MAX;
        else return res;
    }
};
```

貌似有更优美的解法，有空再去评论区学习一下。
有正则表达式做的，还有编译原理里面一个方法做的。

著名的 erase-remove 惯用法，可以熟记或者背诵。

```c++
string s = "lixing";
s.erase(remove(s.begin(), s.end(), 'i'), s.end());
cout << s << endl;
```

输出为 lxng

但是本题没有用到。（本来用到了，结果发现只让修掉开头的空格而非全部的空格，只好又重新写一次）
