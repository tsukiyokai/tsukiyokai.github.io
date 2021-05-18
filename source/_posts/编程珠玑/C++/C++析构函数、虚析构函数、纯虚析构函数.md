---
abbrlink: c106687b
title: C++析构函数、虚析构函数、纯虚析构函数
categories:
  - 编程珠玑
  - C++
tags:
  - 类
  - OOP
date: 2021-04-21 01:28:14
---

## 概念

当对象被销毁时，来完成诸如清理和释放资源工作的函数。

## 语法

`~类名();`

## 析构函数的性质

1. 销毁对象时会自动调用析构函数。
2. 析构函数不能声明为 static 或 const。
3. 析构函数没有参数。
4. 它没有返回类型，甚至没有 void。
5. 具有析构函数的类的对象不能成为联合的成员。
6. 应该在类的公共部分声明析构函数。
7. 程序员无法访问析构函数的地址。

## 什么时候调用析构函数？

当对象超出范围时，将自动调用析构函数：

1. 功能结束
2. 程序结束
3. 包含局部变量的块结尾
4. 调用删除操作符

## 析构函数与普通成员函数有何不同？

析构函数的名称与带波浪号（〜）的类名相同
析构函数不接受任何参数，也不返回任何内容

代码示例

```c++
class String {
private:
    char* s;
    int size;
public:
    String(char*); // constructor
    ~String(); // destructor
};

String::String(char* c) {
    size = strlen(c);
    s = new char[size + 1];
    strcpy(s, c);
}

String::~String() { delete[] s; }
```

## 我们什么时候需要编写用户定义的析构函数？

如果我们不在类中编写自己的析构函数，则编译器会为我们创建一个默认的析构函数。除非我们在类中动态分配了内存或指针，否则默认析构函数可以正常工作。当一个类包含指向在该类中分配的内存的指针时，我们应该编写一个析构函数以释放该类实例之前的内存。必须这样做以避免内存泄漏。

## 析构函数可以是虚的吗？

是的，事实上，当我们有一个虚函数时，在基类中使析构函数虚化总是一个好主意。有关详细信息，请参见[虚析构函数](https://www.geeksforgeeks.org/g-fact-37/)。

## 虚析构函数

Deleting a derived class object using a pointer of base class type that has a non-virtual destructor results in undefined behavior.
（使用普通析构函数的）基类指针不能用来释放派生类对象。
要纠正这种情况，应使用虚拟析构函数定义基类。

运行以下程序：

```c++
// CPP program without virtual destructor
// causing undefined behavior
#include<iostream>
using namespace std;

class base {
public:
    base() { cout << "Constructing base \n"; }
    ~base() { cout << "Destructing base \n"; }
};

class derived : public base {
public:
    derived() { cout << "Constructing derived \n"; }
    ~derived() { cout << "Destructing derived \n"; }
};

int main(void) {
    derived* d = new derived();
    base* b = d;
    delete b;
    return 0;
}
```

将导致

```
Constructing base
Constructing derived
Destructing base
请按任意键继续. . .
```

发现实际上只调用了父类的析构函数，没有调用子类析构函数。可想而知，如果在子类的构造函数中对某个成员函数在堆内存中分配了空间，而子类没有被析构，是不是会造成内存泄漏呢？答案是肯定的，那有什么办法可以解决这种情况下出现的内存泄漏呢？那就是把父类的析构函数写为虚析构函数，

如果使用虚析构函数

```c++
// CPP program without virtual destructor
// causing undefined behavior
#include<iostream>
using namespace std;

class base {
public:
    base() { cout << "Constructing base \n"; }
    virtual ~base() { cout << "Destructing base \n"; }
};

class derived : public base {
public:
    derived() { cout << "Constructing derived \n"; }
    virtual ~derived() { cout << "Destructing derived \n"; }
};

int main(void) {
    derived* d = new derived();
    base* b = d; // 派生类可以为基类赋值，而基类不能给派生类赋值
    delete b;
    return 0;
}
```

则正常输出

```
Constructing base
Constructing derived
Destructing derived
Destructing base
请按任意键继续. . .
```

分析一下

构造函数和析构函数调用的次序是：

首先，创建派生类对象时必须调用基类构造函数，这是语法规定。
其次，销毁基类对象时，反过来必须先调用派生类析构函数。

子类的析构函数其实不止只有析构子类的这些代码，C++语言隐式生成了很多其他代码，即析构顺序，在调用析构函数时会先调用子类的析构函数，然后反向依次析构子类的成员变量，然后再反向析构各基类，如果有多个基类，按照先非 virtual 基类后 virtual 基类的顺序。并且子类的析构函数不是立刻返回的，而是等到上述函数全部调用完才返回。

这个例子是向上转型，将派生类赋值给基类，非常安全，可以由编译器自动完成。
而向下转型是将基类赋值给派生类，有未定义的风险，需要程序员手动干预。

换句话说，基类指针指向派生类对象，只需要切除多于的部分。
但派生类指针指向基类对象，派生类多出来的空余没法填满，会产生编译错误。因为派生类中可能具有只有派生类才有的成员或成员函数。

再换句话说，把男女老少当人看；把鸡鸭猫狗当动物看。有那么难理解吗？
派生类对象本来就能当基类用，

内存视角为什么 C++中，基类指针可以指向派生类对象？
在内存中，一个基类类型的指针是覆盖 N 个单位长度的内存空间。
当其指向派生类的时候，由于派生类元素在内存中堆放是：前 N 个是基类的元素，N 之后的是派生类的元素。
于是基类的指针就可以访问到基类也有的元素了，但是此时无法访问到派生类（就是 N 之后）的元素。

原则上，任何时候在类中有虚函数时，都应立即添加虚析构函数（即使它不执行任何操作）。这样，您可以确保以后不会出现任何意外情况。
