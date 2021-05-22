---
title: C++中的const
abbrlink: "25399e28"
categories:
    - 编程珠玑
    - CPP
tags:
    - C++语法
date: 2021-05-22 20:20:08
---

#### const 含义

常类型是指使用类型修饰符 const 说明的类型，常类型的变量或对象的值是不能被更新的。

#### const 作用

(1) 可以定义常量

```c++
const int a = 100;
```

(2) 类型检查

https://github.com/Light-City/CPlusPlusThings/issues/5

const 定义的变量只有类型为整数或枚举，且以常量表达式初始化时才能作为常量表达式。其他情况下它只是一个 const 限定的变量，不要将与常量混淆。

(3) 防止修改，起保护作用，增加程序健壮性

```c++
void f (const int i) {
    i++; //error
}
```

(4) 可以节省空间，避免不必要的内存分配

const 定义常量从汇编的角度来看，只是给出了对应的内存地址，而不是像 #define 一样给出的是立即数，所以，const 定义的常量在程序运行过程中只有一份拷贝，而 #define 定义的常量在内存中有若干个拷贝。

#### const 对象具有文件作用域

注意：非 const 变量默认为 extern。要使 const 变量能够在其他文件中访问，必须在文件中显式地指定它为 extern。

**非 const 变量在不同文件的访问**

```c++
//file1.cpp
int ext;

//file2.cpp
#include<iostream>

extern int ext;

int main () {
    std::cout << (ext + 10) << std::endl;
}
```

**const 常量在不同文件的访问**

```c++
//extern_file1.cpp

extern const int ext = 12;

//extern_file2.cpp
#include<iostream>

extern const int ext;

int main () {
    std::cout << ext << std::endl;
}
```

小结：

非 const 变量不需要 extern 显式声明；
const 常量需要显式声明 extern，并且需要初始化。

#### 定义常量

```c++
const int b = 10;
b = 0; //error: assignment of read-only variable ‘b’
const string s = "helloworld";
const int i; //error: uninitialized const ‘i’
```

上述有两个错误，第一：b 为常量，不可更改！第二：“i”: 如果不是外部的，则必须初始化常量对象！（因为常量在定义后就不能被修改，所以定义时必须初始化。）

#### 指针与 const

与指针相关的 const 有几种：

```c++
int n = 10;
//pointer to const 并非必须初始化，但 cosnt pointer 必须初始化
const int* p = &n; // 指向 const 对象的指针或者说指向常量的指针。同 char const* p;
int* const p = &n; // 指向类型对象的 const 指针。或者说常指针、const 指针。
const int* const p = &n; // 指向 const 对象的 const 指针。
```

小结：

如果 const 位于`*`的左侧，则 const 就是用来修饰指针所指向的变量，即指针指向为常量；
如果 const 位于`*`的右侧，const 就是修饰指针本身，即指针本身是常量。

具体使用如下：

（1）指向常量的指针

```c++
int n = 10;
const int* ptr;
ptr = &n;
*ptr = 10; // error
```

ptr 是一个指向 int 类型 const 对象的指针，const 定义的是 int 类型，也就是 ptr 所指向的对象类型，而不是 ptr 本身，所以 ptr 可以不用赋初始值。但不能通过 ptr 去修改所指对象的值。

除此之外，也不能使用`void*`指针保存 const 对象的地址，必须使用`const void*`类型的指针保存 const 对象的地址。如：

```c++
const int p = 10;
const void* vp = &p;
void* vp = &p; // error
```

> 什么是 void 指针？void 指针一般被称为通用指针或叫泛指针。它是 C 语言关于纯粹地址的一种约定。

另外一个重点是：允许把非 const 对象的地址赋给指向 const 对象的指针。
