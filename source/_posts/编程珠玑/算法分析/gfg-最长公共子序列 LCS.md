---
title: gfg-最长公共子序列 LCS
abbrlink: 4078a159
categories:
  - 编程珠玑
  - 算法分析
tags:
  - DP
date: 2021-05-05 14:34:28
---

The longest common subsequence (LCS) problem is the problem of finding the longest subsequence common to all sequences in a set of sequences (often just two sequences).

序列ABCDGH和AEDFHR的LCS是长度为3的ADH。
序列AGGTAB和GXTXAYB的LCS是长度为4的GTAB。

这个题的朴素解法是暴力穷举出所有子序列后再进行判断，具有指数级时间复杂度。本文主要考虑DP解法，因此需要从递归开始思考。

假设输入序列分别为长度为m和n的`X[0..m-1]`和`Y[0..n-1]`。设`L(X[0..m-1],Y[0..n-1])`是两个序列X和Y的LCS的长度。以下是`L(X[0..m-1],Y[0..n-1])`的递归定义：

若两个序列的最后一个字符匹配(X[m-1]==Y[n-1])，则：
`L(X[0..m-1],Y[0..n-1])=1+L(X[0..m-2],Y[0..n-2])`

若两个序列的最后一个字符不匹配(X[m-1]!=Y[n-1])，则：
`L(X[0..m-1],Y[0..n-1])=MAX(L(X[0..m-2],Y[0..n-1]),L(X[0..m-1],Y[0..n-2]))`

举例说明：

考虑输入字符串“AGGTAB”和“GXTXAYB”。最后一个字符与字符串匹配。因此，LCS的长度可以写为：`L(“AGGTAB”,“GXTXAYB”)=1+L(“AGGTA”,“GXTXAY”)`

考虑输入字符串“ABCDGH”和“AEDFHR”。字符串的最后字符不匹配。因此，LCS的长度可以写为：`L(“ABCDGH”,“AEDFHR”)=MAX(L(“ABCDG”,“AEDFHR”),L(“ABCDGH”,“AEDFHR”))`

以下是LCS问题的简单递归实现。该实现仅遵循上述的朴素递归结构。

## 递归解法

```c++
#include <bits/stdc++.h>
using namespace std;

int lcs(string X, string Y) {
    int m = X.length();
    int n = Y.length();
    if (m == 0 || n == 0)
        return 0;
    if (X[m - 1] == Y[n - 1])
        return 1 + lcs(X.substr(0, m - 1), Y.substr(0, n - 1));
    else
        return max(
            lcs(X, Y.substr(0, n - 1)),
            lcs(X.substr(0, m - 1), Y)
        );
}

int main() {
    string X = "AGGTAB";
    string Y = "GXTXAYB";
    cout << "Length of LCS is " << lcs(X, Y);
    return 0;
}
```

最坏情况下，上述朴素递归方法的时间复杂度为O(2^n)，最坏情况发生在X和Y的所有字符不匹配时，即LCS的长度为0。考虑到以上实现，下面是输入字符串“AXYT”和“AYZX”的部分递归树。

```
                         lcs("AXYT", "AYZX")
                       /                \ 
         lcs("AXY", "AYZX")            lcs("AXYT", "AYZ")
         /        \                     /               \
lcs("AX", "AYZX") lcs("AXY", "AYZ")   ...
```

在上面的部分递归树中，lcs(“AXY”,“AYZ”)被求解两次。如果我们绘制完整的递归树，则可以看到有很多子问题可以一次又一次地解决。因此，此问题具有“重叠子结构”属性，可以通过使用“记忆化”或“制表”来避免相同子问题的重新计算。以下是LCS问题的制表法实现。

## DP解法

```c++
#include <bits/stdc++.h>
using namespace std;

int lcs(string X, string Y) {
    int m = X.length();
    int n = Y.length();
    vector<vector<int>> L(m + 1, vector<int>(n + 1, 0));
    for (int i = 0; i <= m; i++) {
        for (int j = 0; j <= n; j++) {
            if (i == 0 || j == 0)
                L[i][j] = 0;
            else if (X[i - 1] == Y[j - 1])
                L[i][j] = L[i - 1][j - 1] + 1;
            else
                L[i][j] = max(L[i - 1][j], L[i][j - 1]);
        }
    }
    return L[m][n];
}

int main() {
    string X = "AGGTAB";
    string Y = "GXTXAYB";
    cout << "Length of LCS is " << lcs(X, Y);
    return 0;
}
```

Note that L[i][j] contains length of LCS of X[0..i-1] and Y[0..j-1].

上述实现的时间复杂度为O(m*n)，这比朴素递归实现的最坏情况下的时间复杂度要好得多。