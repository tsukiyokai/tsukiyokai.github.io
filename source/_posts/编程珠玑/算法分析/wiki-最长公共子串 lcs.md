---
title: wiki-最长公共子串 lcs
abbrlink: 104c52bc
categories:
  - 编程珠玑
  - 算法分析
tags:
  - DP
date: 2021-05-06 13:49:53
---

最长公共子串和最长公共子序列的区别是：子序列不必连续，子串必须连续。最长公共子串问题是寻找一个最长的字符串，它同时是两个或多个已知字符串的子串。

此问题有多种解法，其应用包括重复数据消除和剽窃检测。当我们在多个文本中搜索相似性时，最长公共子序列的问题就会出现。一个特别重要的应用是在 DNA 序列中找到一致性。构建特定蛋白质的基因随着时间的推移而进化，但功能区必须保持一致才能正常工作。通过在不同物种中找到同一基因最长的共同子序列，我们了解了什么是随时间而保持不变的。

## 算法

如果利用广义后缀树，我们可以在`O(m+n)`时间内求出 S 和 T 的最长公共子串长度和它们的起始位置，之所以说它们是因为 LCS 未必唯一。如果利用动态规划，则时间复杂度为`O(m*n)`。

最长公共子串问题是编辑距离的一个特例, when substitutions are forbidden and only exact character match, insert, and delete are allowable edit operations.

https://algorist.com/problems/Longest_Common_Substring.html

## 动态规划

**伪码**

```
function LCSubstr(S[1..r], T[1..n])
    L := array(1..r, 1..n)
    z := 0
    ret := {}

    for i := 1..r
        for j := 1..n
            if S[i] = T[j]
                if i = 1 or j = 1
                    L[i, j] := 1
                else
                    L[i, j] := L[i − 1, j − 1] + 1
                if L[i, j] > z
                    z := L[i, j]
                    ret := {S[i − z + 1..i]}
                else if L[i, j] = z
                    ret := ret ∪ {S[i − z + 1..i]}
            else
                L[i, j] := 0
    return ret
```

**解释**

数组 L[i][j]存储分别以 S[i]和 T[j]为结尾的前缀——S[1...i]和 T[1...j]的最长公共子序列的长度。变量 z 表示到目前为止找到的最长公共子串的长度。集合 ret 用来保存长度为 z 的子串。

为什么求最长公共子串的 L 表示的是最长公共子序列的长度？lcs 问题相当于给 LCS 问题加上了一个连续的限制。lcs 的 dp[][]根源于 LCS 的数组，但又有些改变。

为什么 S[i]!=T[j]的时候 L[i,j]:=0？因为最长公共子串需要连续！如果不等于的话，那么前面再多的相等都没用。这里的 dp[i][j]更像是以 i 结尾且以 j 结尾的字符串最长的长度（粗略理解）。

**代码**

大概思路就是按自底向上顺序寻找最长公共后缀，有空还要去学一下后缀树。

```c++
#include <bits/stdc++.h>
using namespace std;

int LCS(string X, string Y) {
    int m = X.length(), n = Y.length();
    vector<vector<int>> dp(m + 1, vector<int>(n + 1, 0));
    int res = 0;
    for (int i = 0; i <= m; i++) {
        for (int j = 0; j <= n; j++) {
            if (i == 0 || j == 0)
                dp[i][j] = 0;
            else if (X[i - 1] == Y[j - 1]) {
                dp[i][j] = dp[i - 1][j - 1] + 1;
                res = max(res, dp[i][j]);
            }
            else dp[i][j] = 0;
        }
    }
    return res;
}

int main() {
    string X = "OldSite:GeeksforGeeks.org";
    string Y = "NewSite:GeeksQuiz.com";
    cout << "最长公共子串长度为：" << LCS(X, Y);
    return 0;
}
```
