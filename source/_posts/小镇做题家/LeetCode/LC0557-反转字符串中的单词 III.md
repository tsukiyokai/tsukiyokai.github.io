---
title: LC557 反转字符串中的单词 III
abbrlink: 813d
categories:
  - 小镇做题家
  - LeetCode
tag: 字符串
date: 2021-03-01 00:00:00
---

## 题目

给定一个字符串，你需要反转字符串中每个单词的字符顺序，同时仍保留空格和单词的初始顺序。

输入："Let's take LeetCode contest"
输出："s'teL ekat edoCteeL tsetnoc"

在字符串中，每个单词由单个空格分隔，并且字符串中不会有任何额外的空格。

## 解法：巧用迭代器

**代码**

```c++
class Solution {
public:
    string reverseWords(string s) {
        auto bg = s.begin();
        for (auto it = s.begin(); it != s.end(); ++it) {
            if (*it == ' ') {
                reverse(bg, it);
                bg = it + 1;
            }
        }
        reverse(bg, s.end());
        return s;
    }
};
```

**注释**

reverse()：Reverses the order of the elements in the range [first,last).
注意两点：第一，区间左闭右开；第二，reverse()是原地操作。

**拓展**

[浅析编程语言的区间为何常是左闭右开](https://blog.csdn.net/weixin_43896318/article/details/99618264)