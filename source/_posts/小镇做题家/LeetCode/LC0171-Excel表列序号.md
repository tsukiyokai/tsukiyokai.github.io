---
title: LC171 Excel表列序号
abbrlink: 58bc01b9
categories:
  - 小镇做题家
  - LeetCode
tag: 模拟
date: 2021-02-25 00:00:00
---

## 题目

给定一个Excel表格中的列名称，返回其相应的列序号。

例如：
A -> 1
B -> 2
C -> 3
...
Z -> 26
AA -> 27
AB -> 28 
...    

## 解法1：找规律

**代码**

```c++
class Solution {
public:
    int titleToNumber(string s) {
        int len = s.size();
        int prev = 0;
        int diff = 0;

        if (len <= 1) return 1 + s[0] - 'A';
        for (int i = 1; i <= len - 1; i++) prev += (int)pow(26, i);
        for (int i = 1; i <= len; i++) diff += (s[i - 1] - 'A') * (int)pow(26, len - i);

        return prev + diff + 1;
    }
};
```

**注释**

我提交的第一个版本，prev表示上一级的数字，如要计算AAA，则prev就是ZZ的数值。diff是prev与目标数字的差，即(prev, AAA]。
大概逻辑很容易想出来，但是实现起来还是挺乱的。后来发现可以利用其本质继续优化，见方法二。
其实这个方法很接近创造进制的思路了，只是还不够接近，没有完全体现出进制法的整洁和优美。

## 解法2：26进制

**代码**

```c++
class Solution {
public:
    int titleToNumber(string s) {
        int ans = 0;
        for (auto c : s) {
            int num = c - 'A' + 1;
            ans = ans * 26 + num;
        }
        return ans;
    }
};
```

**注释**

A    1
Z    26
AA    27
AZ    26+26
BA    26+26+1
ZZ    26+26*26=702
AAA    703

每一位上的数：int num = c - 'a' + 1;
每一位的权重是26：ans = ans * 26 + num;

从左到右遍历，其实连续乘以26并保存下来就行，不是非得要只乘一次pow(26, len-i)，脑子不要这么耿直。

