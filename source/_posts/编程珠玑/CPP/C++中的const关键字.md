---
title: C++中的const关键字
abbrlink: 97c58f51
categories:
  - 编程珠玑
  - CPP
tags:
  - 语法
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

（1）pointer to const

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

将非 const 对象的地址赋给 const 对象的指针：

```c++
const int* ptr;
int val = 3;
ptr = &val; // ok
*ptr1 = 4; // err
```

我们不能通过 ptr 指针来修改 val 的值，即使它指向的是非 const 对象。

小结：对于指向常量的指针，不能通过指针来修改对象的值。也不能使用`void*`指针保存 const 对象的地址，必须使用`const void*`类型的指针保存 const 对象的地址。允许把非 const 对象的地址赋值给 const 对象的指针，如果要修改指针所指向的对象值，必须通过其他方式修改，不能直接通过当前指针直接修改。

（2）const pointer

const 指针必须进行初始化，且 const 指针的值不能修改。

当把一个 const 常量的地址赋值给 ptr 时候，由于 ptr 指向的是一个变量，而不是 const 常量，所以会报错。

```c++
#include<iostream>
using namespace std;
int main() {
    const int num = 0;
    int* const ptr = &num; //error! const int* -> int*
    cout << *ptr << endl;
}
```

（3）const pointer to const

```c++
const int p = 3;
const int* const ptr = &p;
```

#### 函数中使用 const

**cost 修饰函数返回值**

（1）`const int`

```c++
const int func1();
```

这个本身无意义，因为参数返回本身就是赋值给其他的变量.

（2）`const int*`

```c++
const int* func2();
```

Function func2 returning a Pointer variables which refer to a int number and cannot be modified.

指针指向的内容不变。

（3）`int* const`

```c++
int* const func2();
```

指针本身不可变。

**const 修饰函数参数**

（1）传递过来的参数及指针本身在函数内不可变，无意义！

```c++
void func(const int var); // 传递过来的参数不可变
void func(int* const var); // 指针本身不可变
```

表明参数在函数体内不能被修改，但此处没有任何意义，var 本身就是形参，在函数内不会改变。包括传入的形参是指针也是一样。

输入参数采用“值传递”，由于函数将自动产生临时变量用于复制该参数，该输入参数本来就无需保护，所以不要加 const 修饰。

（2）参数指针所指内容为常量不可变

```c++
void StringCopy(char* dst, const char* src);
```

其中 src 是输入参数，dst 是输出参数。给 src 加上 const 修饰后，如果函数体内的语句试图改动 src 的内容，编译器将指出错误。这就是加了 const 的作用之一。

（3）参数为引用，为了增加效率同时防止修改。

```c++
void func(const A &a);
```

对于非内部数据类型的参数而言，像 void func(A a) 这样声明的函数注定效率比较低。因为函数体内将产生 A 类型的临时对象用于复制参数 a，而临时对象的构造、复制、析构过程都将消耗时间。

为了提高效率，可以将函数声明改为`void func(A &a)`，因为“引用传递”仅借用一下参数的别名而已，不需要产生临时对象。但是函数`void func(A &a)`存在一个缺点：“引用传递”有可能改变参数 a，这是我们不期望的。解决这个问题很容易，加 const 修饰即可，因此函数最终成为`void func(const A &a)`。

以此类推，是否应将`void func(int x)`改写为`void func(const int &x)`以便提高效率？完全没有必要，因为内部数据类型的参数不存在构造、析构的过程，而复制也非常快，“值传递”和“引用传递”的效率几乎相当。

小结：对于非内部数据类型的输入参数，应该将“值传递”的方式改为“const 引用传递”，目的是提高效率。例如将`void func(A a)`改为`void func(const A &a)`。

对于内部数据类型的输入参数，不要将“值传递”的方式改为“const 引用传递”。否则既达不到提高效率的目的，又降低了函数的可理解性。例如 void func(int x) 不应该改为 void func(const int &x)。

以上解决了两个面试问题：

（1）如果函数需要传入一个指针，是否需要为该指针加上 const，把 const 加在指针不同的位置有什么区别；

（2）如果写的函数需要传入的参数是一个复杂类型的实例，传入值参数或者引用参数有什么区别，什么时候需要为传入的引用参数加上 const。

#### 类中的 const

在一个类中，任何不会修改数据成员的函数都应该声明为 const 类型。如果在编写常成员函数的函数体时，不慎修改数据成员，或者调用了其它非常成员函数，编译器将指出错误，这无疑会提高程序的健壮性。使用 const 关键字进行说明的成员函数，称为常成员函数。只有常成员函数才有资格操作常量或常对象，非常成员函数不能用来操作常对象。

对于类中的常成员变量必须通过初始化列表进行初始化，如下所示：

```c++
class Test {
private:
    const int a;
public:
    Test() :a(10) {}
};
```

常对象只能调用常成员函数，不能调用非常成员函数。
非常对象既可以调用常成员函数，也可以调用非常成员函数。
非常成员函数不能操作常对象。
