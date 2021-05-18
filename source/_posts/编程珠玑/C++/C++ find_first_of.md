---
title: "C++ std::find_first_of"
abbrlink: cec9b026
categories:
  - 编程珠玑
  - C++
tags:
  - STL
date: 2021-04-28 22:51:14
---

`std::find_first_of`用于比较两个容器之间的元素。它将[first1，last1)范围内的所有元素与[first2，last2)范围内的所有元素进行比较：

如果在第一个范围内找到第二个范围内的任何元素，则返回一个指向第一个容器中的该元素的迭代器。
如果两个范围中有多个公共元素，则返回第一个容器中第一个公共元素的迭代器。
如果没有匹配项，则返回指向 last1 的迭代器。

有下面两种用法：

## 直接判等

语法：

```
模板
ForwardIterator1 find_first_of(ForwardIterator1 first1,
                               ForwardIterator1 last1,
                               ForwardIterator2 first2,
                               ForwardIterator2 last2);

first1: 一个正向迭代器，指向第一个范围里的第一个元素。
last1: 一个正向迭代器，指向第一个范围里的最后一个元素。
first2: 一个正向迭代器，指向第二个范围里的第一个元素。
last2: 一个正向迭代器，指向第一个范围里的最后一个元素。
```

**代码**

```c++
#include<iostream>
#include<vector>
#include<algorithm>
using namespace std;
int main() {
    vector<int>v = { 1, 3, 3, 3, 10, 1, 3, 3, 7, 7, 8 }, i;
    vector<int>v1 = { 1, 3, 10 };
    vector<int>::iterator ip;
    ip = std::find_first_of(v.begin(), v.end(), v1.begin(), v1.end());
    cout << *ip << "\n"; // 1
    ip = std::find_first_of(ip + 1, v.end(), v1.begin(), v1.end());
    cout << *ip << "\n"; // 3

    return 0;
}
```

## 利用预定义函数

语法

```
Template
   ForwardIterator1 find_first_of (ForwardIterator1 first1,
                                   ForwardIterator1 last1,
                                   ForwardIterator2 first2,
                                   ForwardIterator2 last2,
                                   BinaryPredicate pred );

这里的f1 l1 f2 l3含义均与上例相同。
```

注

Pred: Binary function that accepts two elements as arguments (one of each of the two sequences, in the same order), and returns a value convertible to bool. The value returned indicates whether the elements are considered to match in the context of this function.The function shall not modify any of its arguments. This can either be a function pointer or a function object.

代码

```c++
#include<iostream>
#include<vector>
#include<algorithm>
using namespace std;

// Defining the BinaryFunction
bool Pred(int a, int b) {
    if (a % b == 0) return 1;
    else return 0;
}
int main() {
    // Defining first container
    vector<int>v = { 1, 5, 7, 11, 13, 15, 30, 30, 7 }, i;

    // Defining second container
    vector<int>v1 = { 2, 3, 4 };

    vector<int>::iterator ip;

    // Using std::find_first_of
    ip = std::find_first_of(v.begin(), v.end(), v1.begin(), v1.end(), Pred);

    // 显示首个满足Pred()要求的元素
    cout << *ip << "\n";

    return 0;
}
```

pred 函数返回布尔类型，它希望 a 是 b 的整数倍。a 代表第一个容器里的数据，b 代表第二个容器里的数据。这个程序返回指向 v1 中第一个满足是 v2 中任一元素整数倍的元素的迭代器。在此例中，程序输出 15，因为 15 是第一个 v1 中元素之一（3）的倍数，而 1、5、7、11、13 均不是 v2 中哪个元素的整数倍。

这两个基本用法可以延伸出一些实际应用：

## 应用

std::find_first_of 可用于查找另一个容器中存在的任一元素的第一次出现位置。

1.比如找出句子中的第一个元音字母。

```c++
#include<iostream>
#include<vector>
#include<string>
#include<algorithm>
using namespace std;
int main() {
    string s1 = "You are reading about std::find_first_of";
    string s2 = {'a','A','e','E','i','I','o','O','u','U'};

    auto ip = std::find_first_of(s1.begin(), s1.end(), s2.begin(), s2.end());

    cout << "First vowel found at index " << (ip - s1.begin()) << endl;
    return 0;
}
```

2.用于查找列表中出现的第一个奇数或偶数。

```c++
#include<iostream>
#include<vector>
#include<algorithm>
using namespace std;

bool pred(int a, int b) {
    if (a % b != 0) return 1;
    else return 0;
}

bool pred1(int a, int b) {
    if (a % b == 0) return 1;
    else return 0;
}

int main() {
    vector<int>v1 = { 1, 3, 4, 5, 6, 7, 8, 10 };
    vector<int>v2 = { 2 };

    vector<int>::iterator ip;
    ip = std::find_first_of(v1.begin(), v1.end(), v2.begin(), v2.end(), pred);

    cout << "First odd occurs at index " << (ip - v1.begin()) << endl;

    ip = std::find_first_of(v1.begin(), v1.end(), v2.begin(), v2.end(), pred1);

    cout << "First even occurs at index " << (ip - v1.begin()) << endl;

    return 0;
}
```

运行结果

```
First odd occurs at index 0
First even occurs at index 2
请按任意键继续. . .
```

最后，std::find_first_of()的时间复杂度为：O(n1\*n2)，n1 和 n2 分别为两个区间中的元素数。
