---
abbrlink: f148
title: C++引用
categories:
  - 编程珠玑
  - C++程序设计
tags:
  - 指针
date: 2021-04-18 22:35:02
---

## 概念

引用是已存在的对象的别名。

```c++
#include<iostream>
using namespace std;

int main() {
    int x = 10;
    int& ref = x;

    ref = 20;
    cout << "x = " << x << endl;

    x = 30;
    cout << "ref = " << ref << endl;

    return 0;
}
```

## 应用

### 修改函数中传递的参数

如果函数收到对变量的引用，则可以修改变量的值。例如，下面的程序里使用了引用来交换变量。

```c++
#include<iostream>
using namespace std;
void swap(int& x, int& y) {
    int temp = x;
    x = y;
    y = temp;
}
int main() {
    int a = 5, b = 10;
    swap(a, b);
    cout << a << " " << b << endl;
    return 0;
}
```

### 避免复制大型结构

函数传参，什么都不加就是传值方式，加上引用就是传引用。传值是通过赋值实现的，对象越大消耗越大。
想象一个函数必须接收一个庞大的对象。如果我们在没有引用的情况下传递它，就会创建一个新的副本，从而导致CPU时间和内存的浪费。我们可以使用引用来避免这种情况。

```c++
struct Student {
    string name;
    string address;
    int rollNo;
};
void print(const Student& s) {
    cout << s.name << " " << s.address << " " << s.rollNo << endl;
}
```

### 在基于范围的for循环中修改所有对象

```c++
#include <bits/stdc++.h>
using namespace std;
int main() {
    vector<int> vect{ 10, 20, 30, 40 };
    for (int& x : vect) x += 5;
    for (int x : vect) cout << x << " ";
    return 0;
}
```

### 为每个循环避免对象的副本

当对象很大时，我们可以在每个循环中使用引用来避免产生单个对象的副本。

```c++
#include <bits/stdc++.h>
using namespace std;
int main() {
    vector<string> vect{ "geeksforgeeks practice", "geeksforgeeks write", "geeksforgeeks ide" };
    for (const auto& x : vect) cout << x << endl;
    return 0;
}
```

## 指针和引用的区别

1.指针可以被声明为void但引用不行。

```c++
int a = 10;
void* aa = &a; // it is valid
void& ar = a; // it is invalid
```

2.指针可以有多级间接关系，比如二级指针、三级指针等；引用只能有一层间接关系。

```c++
#include <iostream>
using namespace std;

int main() {
    int i = 10;
    int* p = &i; // 一级指针
    int** pt = &p; // 二级指针
    int*** ptr = &pt; // 三级指针
    cout << "i=" << i << "\t" << "p=" << p << "\t"
        << "pt=" << pt << "\t" << "ptr=" << ptr << "\n";

    int a = 5;
    int& S = a;
    int& S0 = S;
    int& S1 = S0;
    cout << "a=" << a << "\t" << "S=" << S << "\t"
        << "S0=" << S0 << "\t" << "S1=" << S1 << "\n";
}
```

输出结果
```
i=10    p=0019FED8      pt=0019FECC     ptr=0019FEC0
a=5     S=5             S0=5            S1=5
请按任意键继续. . .
```

## 什么是void指针?

void指针一般被称为通用指针或叫泛指针。它是C语言关于纯粹地址的一种约定。当某个指针是void型指针时，所指向的对象不属于任何类型。因为void指针不属于任何类型，则不可以对其进行算术运算，比如自增，编译器不知道其自增需要增加多少。比如`char*`型指针，自增一定是指针指向的地址加1，`short*`型指针自增，则偏移2。

在C/C++中，在任意时刻都可以使用其它类型指针来代替void指针，或者用void指针来代替其他类型指针。由这些特性就可以衍生出很多比较有用的技巧。指针的本质，是其值为一个地址，那么延伸一下：

当使用关键字void声明指针变量时，它将成为通用指针变量。任何数据类型的任何变量的地址都可以赋值给void指针变量。

对指针变量的解引用，使用间接寻址运算符*达到目的。但是在使用空指针的情况下，需要先转换指针变量再解引用。这是因为空指针没有与之关联的数据类型。编译器无法知道void指针指向的数据类型。因此，要获取由void指针指向的数据，需要使用在void指针位置内保存的正确类型的数据进行显式类型转换。

![](https://img2020.cnblogs.com/blog/2028254/202005/2028254-20200505094248280-1172805575.png)