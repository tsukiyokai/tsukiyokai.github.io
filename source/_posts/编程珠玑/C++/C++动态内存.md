---
title: C++动态内存
abbrlink: f9c32828
categories:
  - 编程珠玑
  - C++
tags:
  - 底层技术
  - 内存
date: 2021-04-17 13:25:26
---

## 内存分配的概念

C/C++的内存分配方式有两种：静态内存分配（编译时分配）和动态内存分配（运行时分配）。

动态内存分配是指由程序员手动执行的内存分配。
动态内存是指通过动态内存分配方式分配的内存。

动态分配的内存位于堆上，非静态（即临时的）局部变量则位于栈上。有关详细信息，请参阅[C的内存布局](https://www.geeksforgeeks.org/memory-layout-of-c-program/)。

### 动态内存分配有什么用？

- 动态内存分配的一个用途是分配可变大小的内存，这是编译时内存分配做不到的（可变长度数组除外）。
- 动态内存分配最大的作用是为程序员提供了灵活性。无论何时需要或不再需要，我们都可以自由地分配和释放内存。很多情况下这种灵活性是大有帮助的，例如链表、树等。

### 动态内存与分配给普通变量的内存有何不同？

对于声明像`int a`、`char str[]`这样的常规变量，编译器将自动分配和释放内存。
对于用new-delete动态分配的内存，如`int* p = new int[10]`，程序员必须在使用结束后手动释放内存。否则将导致内存泄漏（直到程序终止内存才被动地释放）。

### 什么是内存泄漏，怎么确定内存泄漏？

内存泄漏（memory leak）是指由于疏忽或错误造成了程序未能释放掉已经不再使用的内存的情况。内存泄漏并非指内存在物理上的消失，而是应用程序分配某段内存后，由于设计错误，在程序的后续运行中失去了对该段内存的控制，因而造成了内存的浪费。内存泄漏通常是由于调用了malloc/new等内存申请的操作，但是缺少了对应的free/delete。

为了判断内存是否泄露，我们一方面可以使用linux环境下的Valgrind或mtrace内存泄漏检查工具，另一方面可以在写代码时可以添加内存申请和释放的统计功能，统计当前申请和释放的内存是否一致，以此来判断内存是否泄露。

### 如何在C++中分配/释放内存？

C语言使用malloc()和callol()函数来在运行时动态分配内存，并使用free()函数释放这些动态分配的内存。
C++中也支持上面这些函数，此外还有new()和delete()两个新的操作符，它们可以以更好和更轻松的方式执行分配和释放内存的任务。
本文全部是关于new和delete操作符的。

注：new和delete应该叫操作符还是运算符？我本来觉得应该是叫操作符，操作符是嵌在每一条指令中的，我理解的是计算机系统中的术语，比如赋值、判等。运算符主要侧重信息的提取和转化，比如取地址运算符和间接寻址运算符。简而言之，操作符的作用比较直观，而运算符的作用比较抽象和本质。我一开始混淆着用，后来想想两者还是有些不同的，再后来我又感觉这两者其实还是差不多……

## new运算符

new运算符表示请求在空闲内存上分配一块内存，如果有足够的内存可用，则new运算符将初始化该内存，并将新分配和初始化的内存的地址返回给指针变量。

### 语法

要分配任何数据类型的内存，其语法为：
pointer-variable = new data-type;

这里，pointer-variable是指向某种数据类型的指针，数据类型可以是任何内置数据类型（包括数组），也可以是用户定义的任何数据类型（包括结构体和类）。

例如：`int* p = new int;`

### 初始化内存

内存的初始化的意思是，赋予这块内存上的变量一个缺省值。new运算符能够支持内存初始化的重要原理是：new会自动调用构造函数，而且delete销毁对象的时候也会调用对象的析构函数。这是C++动态内存和C语言的重要不同。

例如：`int* p = new int(25);`

### 分配内存块

内存块就是在一起的一些内存的集合，也就是俗话说的数组。
new运算符还可以用于分配data-type类型的内存块（数组）。

例如：`int* p = new int[10];`

动态地为int类型的10个整数连续分配内存，并返回序列中第一个元素的地址给指针p。p[0]表示第一个元素，p[1]表示第二个元素，依此类推。

### Normal Array Declaration vs Using new

以普通方式声明的数组与使用new分配的内存块之间是有区别的。最重要的区别是，常规数组由编译器释放（如果数组在局部声明，则在函数返回或完成时释放）。但是，动态分配的数组始终保留在那里，直到程序员主动将其释放或程序彻底结束为止。

### 运行时可用内存不足怎么办？

如果堆中没有足够的内存可供分配，则新请求通过抛出std::bad_alloc类型的异常来指示内存分配失败了，如果new运算符使用了nothrow则不会抛出异常，但会返回一个空指针（请参阅[new运算符的异常处理](https://aticleworld.com/dynamic-memory-and-new-operator-c/)一文）。因此，在使用new出来的对象之前，最好先检查指针变量是否为空。

例如：

```c++
int* p = new(nothrow) int;
if (!p) {
    cout << "Memory allocation failed.\n";
}
```

## delete运算符

由于程序员有责任释放自己动态分配的内存，因此C++为程序员提供了delete运算符。

### 语法

// Release memory pointed by pointer-variable
`delete pointer-variable;`

### 销毁内存块（数组）

連續配置得來的空間，不使用時要使用 delete[] 歸還給記憶體，必須加上 []，表示歸還的是整個連續空間：
`delete[] pointer-variable;`

若要動態配置連續空間，並當成二維陣列來操作，就記得二維（或多維）陣列，就是以陣列的陣列來實作，二維陣列就是多段一維陣列，如果你的二維陣列有兩段一維陣列，那就是如下用法：
`int **arr = new int*[2];`

### delete例子

```c++
#include <iostream>
using namespace std;

int main() {
    int* p = NULL;
    p = new(nothrow) int;
    if (!p) cout << "memory allocation failed\n";
    else {
        *p = 29;
        cout << "Value of p: " << *p << endl;
    }

    float* r = new float(75.25);
    cout << "Value of r: " << *r << endl;

    int n = 5;
    int* q = new(nothrow) int[n];

    if (!q) cout << "allocation of memory failed\n";
    else {
        for (int i = 0; i < n; i++) q[i] = i + 1;
        cout << "Value store in block of memory: ";
        for (int i = 0; i < n; i++) cout << q[i] << " ";
    }

    delete p;
    delete r;
    delete[] q;

    return 0;
}
```

注：
`int* p = NULL;` 意思是“p哪也不指”，而非“p指向的地方是空”。
`p = new(nothrow) int;` nothrow与标准new的区别是，new在分配内存失败时会抛出异常，而new(std::nothrow)在分配内存失败时会返回一个空指针。