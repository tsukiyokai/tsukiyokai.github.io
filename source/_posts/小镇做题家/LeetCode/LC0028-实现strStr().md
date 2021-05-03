---
title: LC28 实现strStr()
abbrlink: 47ba
categories:
  - 小镇做题家
  - LeetCode
tag: 模拟
date: 2021-03-02 00:00:00
---

## 题目

给定一个haystack字符串和一个needle字符串，在haystack字符串中找出needle字符串出现的第一个位置(从0开始)。如果不存在，则返回-1。

输入: haystack="hello",needle="ll"
输出: 2

## 解法

**代码**

```c++
class Solution {
public:
    int strStr(string haystack, string needle) {
        if (needle.size() > haystack.size()) return -1;
        if (needle.size() == 0) return 0;
        for (int i = 0; i < haystack.size() - needle.size() + 1; i++) {
            int j = i;
            bool flag = true;
            for (auto c : needle) {
                if (c == haystack[j]) j++;
                else {
                    flag = false;
                    break;
                }
            }
            if (flag) return i;
        }
        return -1;
    }
};
```

**注释**

第一层for循环写的很好，如此设置可以直接确保needle的尾巴不会超过haystack的末尾而发生上溢。

