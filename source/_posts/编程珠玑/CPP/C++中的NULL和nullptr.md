---
title: C++中的NULL和nullptr
categories:
    - 编程珠玑
    - CPP
abbrlink: 45f33b90
tags:
    - C++语法
date: 2021-04-23 18:51:07
---

观察下面一段程序。

```c++
#include <iostream>
using namespace std;

int fun(int N) { cout << "fun(int)"; }
int fun(char* s) { cout << "fun(char *)"; }

int main() {
    fun(NULL);
}
```

我们一般认为 NULL 是空指针，按照这个想法，我们推测 fun(NULL)应该去调用`fun(char* s)`。然而它输出了 fun(int)。
原因是虽然 NULL 通常定义为`void*`，但它允许将 NULL 转换为整型 0。因此，函数调用 fun(NULL)变得模棱两可。
什么是 void 指针？void 指针一般被称为通用指针或叫泛指针。它是 C 语言关于纯粹地址的一种约定。

为了解决 NULL 的二义性，我们引入了 nullptr。在上面的程序中，如果将 NULL 替换为 nullptr，则输出为`fun(char*)`。
nullptr 可以在所有本来期望 NULL 的地方使用。像 NULL 一样，nullptr 也可以进行某些隐式转换，并可以与任何指针类型进行比较。与 NULL 不同是，它不能隐式转换为整数类型 0。

下面程序产生编译错误，因为它试图将 nullptr 转换为 int。

```c++
// This program does NOT compile
#include<stdio.h>
int main() {
    int x = nullptr;
}
```

顺便说一下，nullptr 可转换为 bool。
下面程序输出 false。

```c++
#include<iostream>
using namespace std;

int main() {
    int* ptr = nullptr;
    if (ptr) { cout << "true"; }
    else { cout << "false"; }
    return 0;
}
```
