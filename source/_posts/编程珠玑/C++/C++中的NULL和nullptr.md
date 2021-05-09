---
title: C++中的NULL和nullptr
categories:
  - 编程珠玑
  - C++
abbrlink: 45f33b90
tags:
  - 底层技术
  - 指针
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

我们一般认为NULL是空指针，按照这个想法，我们推测fun(NULL)应该去调用`fun(char* s)`。然而它输出了fun(int)。
原因是虽然NULL通常定义为void*，但它允许将NULL转换为整型0。因此，函数调用fun(NULL)变得模棱两可。
什么是void指针？void指针一般被称为通用指针或叫泛指针。它是C语言关于纯粹地址的一种约定。

为了解决NULL的二义性，我们引入了nullptr。在上面的程序中，如果将NULL替换为nullptr，则输出为fun(char*)。
nullptr可以在所有本来期望NULL的地方使用。像NULL一样，nullptr也可以进行某些隐式转换，并可以与任何指针类型进行比较。与NULL不同是，它不能隐式转换为整数类型0。

下面程序产生编译错误，因为它试图将nullptr转换为int。

```c++
// This program does NOT compile
#include<stdio.h>
int main() {
    int x = nullptr;
}
```

顺便说一下，nullptr可转换为bool。
下面程序输出false。

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