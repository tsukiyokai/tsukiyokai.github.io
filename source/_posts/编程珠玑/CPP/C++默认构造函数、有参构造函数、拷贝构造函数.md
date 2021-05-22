---
abbrlink: 6bc1a2de
title: C++默认构造函数、有参构造函数、拷贝构造函数
categories:
  - 编程珠玑
  - CPP
tags:
  - OOP
date: 2021-04-22 00:03:12
---

## 什么是构造函数？

构造函数是类的成员函数，用于初始化类的对象。在 C++中，创建对象（类的实例）时会自动调用 Constructor。它是该类的特殊成员函数。

## 构造函数与普通成员函数有何不同？

1. 构造函数与类本身具有相同的名称。
2. 构造函数没有返回类型。
3. 在创建对象时会自动调用构造函数。
4. 如果不指定构造函数，C++编译器为我们生成默认构造函数（不带参数，具有空函数体）。

## C++中的构造函数有哪几种？

1. 默认构造函数（无参）
2. 有参构造函数
3. 拷贝构造函数

gfg 有上一个非常好的比喻，没有生词，我就不翻译了，试着翻了一下感觉没有原文生动。

Let us understand the types of constructors in C++ by taking a real-world example.

Suppose you went to a shop to buy a marker. When you want to buy a marker, what are the options?

The first one you go to a shop and say give me a marker. So just saying give me a marker mean that you did not set which brand name and which color, you didn’t mention anything just say you want a marker. So when we said just I want a marker so whatever the frequently sold marker is there in the market or in his shop he will simply hand over that. And this is what a default constructor is!（默认构造函数）

The second method you go to a shop and say I want a marker a red in color and XYZ brand. So you are mentioning this and he will give you that marker. So in this case you have given the parameters. And this is what a parameterized constructor is!（有参构造函数）

Then the third one you go to a shop and say I want a marker like this(a physical marker on your hand). So the shopkeeper will see that marker. Okay, and he will give a new marker for you. So copy of that marker. And that’s what copy constructor is!（拷贝构造函数）

## 三种构造函数

### 默认构造函数

默认构造函数是不接受任何参数的构造函数。它没有参数。

```c++
#include <iostream>
using namespace std;
class construct {
public:
    int a, b;
    construct() { a = 10; b = 20; }
};

int main() {
    construct c;
    cout << "a: " << c.a << endl << "b: " << c.b << endl;
    return 1;
}
```

即使我们没有显式地定义任何构造函数，编译器也会自动隐式地提供默认构造函数。

### 有参构造函数

可以将参数传递给构造函数。通常，这些参数有助于在创建对象时初始化对象。要创建有参构造函数，只需像向其他函数一样添加参数即可。定义构造函数的函数体时，请使用参数初始化对象。

```c++
#include <iostream>
using namespace std;
class Point {
private:
    int x, y;
public:
    Point(int x1, int y1) { x = x1; y = y1; }
    int getX() { return x; }
    int getY() { return y; }
};

int main() {
    Point p1(10, 15);
    cout << "p1.x = " << p1.getX() << ", p1.y = " << p1.getY() << endl;
    return 0;
}
```

有参构造函数可以显式或隐式地调用。

```c++
Example e = Example(0, 50); // 显式调用
Example e(0, 50); // 隐式调用
```

有参构造函数的使用

1. 创建对象时，使用它来初始化具有不同值的不同对象的各种数据元素。
2. 它用于重载构造函数。

一个类中可以有多个构造函数吗？
是的，这称为构造函数重载。

构造函数重载

在 C++中，我们可以在一个同名的类中拥有多个构造函数，只要每个构造函数具有不同的参数列表即可。

```c++
#include <iostream>
using namespace std;

class construct {
public:
    float area;
    construct() { area = 0; }
    construct(int a, int b) { area = a * b; }
    void disp() { cout << area << endl; }
};

int main() {
    construct o;
    construct o2(10, 20);
    o.disp();
    o2.disp();
    return 1;
}
```

### 拷贝构造函数

#### 概念

拷贝构造函数是一个成员函数，它使用同一类的另一个对象初始化一个对象。拷贝构造函数具有以下一般函数原型：`ClassName (const ClassName &old_obj);`。

下面是一个拷贝构造函数的简单例子。

```c++
#include<iostream>
using namespace std;

class Point {
private:
    int x, y;
public:
    Point(int x1, int y1) { x = x1; y = y1; }
    Point(const Point& p1) { x = p1.x; y = p1.y; }
    int getX() { return x; }
    int getY() { return y; }
};

int main() {
    Point p1(10, 15);
    Point p2 = p1; // 这里不是赋值语句，而是调用拷贝构造函数。注意是不用的。
    cout << "p1.x = " << p1.getX() << ", p1.y = " << p1.getY() << endl;
    cout << "p2.x = " << p2.getX() << ", p2.y = " << p2.getY() << endl;
    return 0;
}
```

每当我们为一个类定义一个或多个非默认的有参构造函数时，也应显式定义一个默认的无参构造函数，因为在这种情况下编译器将不提供默认构造函数。虽然这不是必须的，但是始终定义默认构造函数一般被认为是最佳实践。

```c++
#include <iostream>
using namespace std;
class point {
private:
    double x, y;
public:
    // Non-default Constructor & default Constructor
    point(double px, double py) { x = px, y = py; }
};

int main(void) {
    // Define an array of size 10 & of type point
    // This line will cause error
    point a[10];

    // Remove above line and program will compile without error
    point b = point(5, 6);
}
```

错误：E0291 类 "point" 不存在默认构造函数

#### 什么时候需要用户定义的拷贝构造函数？

如果我们不定义自己的拷贝构造函数，则 C++编译器会为每个类创建一个默认的拷贝构造函数，以在对象之间进行成员级复制。编译器创建的拷贝构造函数通常可以正常工作。仅当对象具有指针或文件句柄，网络连接等资源的任何运行时分配（runtime allocation）时，才需要定义我们自己的拷贝构造函数。

默认构造函数只执行浅拷贝。
只有用户定义的拷贝构造函数才可以进行深层复制。

#### 拷贝构造函数 vs 赋值语句

```c++
MyClass t1, t2;
MyClass t3 = t1;
t2 = t1;
```

赋值只能是两个已存在的对象，而拷贝构造可以是正在声明的对象。

#### 为什么必须将拷贝构造函数的参数作为引用传递？

按值传递对象时，将调用拷贝构造函数。拷贝构造函数本身就是一个函数。因此，如果我们在拷贝构造函数中按值传递参数，则将调用拷贝构造函数来调用拷贝构造函数，这将成为一个无终止的调用链。因此，编译器不允许参数按值传递。

#### 为什么拷贝构造函数参数应为 const？

1. 我们应尽可能在 C++中使用 const，以免意外修改对象。
2. 修改编译器创建的临时对象是没有意义的，因为它们随时都可能死亡。

## C++的内部视角：默认构造函数

一个问题：编译器是否会在幕后向用户实现的默认构造函数插入任何代码？

考虑从另一个具有默认构造函数的类派生而来的类，或者包含另一个具有默认构造函数的类对象的类。编译器需要插入代码来调用基类或嵌入对象的默认构造函数。

```c++
#include <iostream>
using namespace std;

class Base {
public:
};

class A {
public:
    A() { cout << "A Constructor" << endl; }
    int size;
};

class B : public A {
};

class C : public A {
public:
    C() { cout << "C Constructor" << endl; }
};

class D {
public:
    D() { cout << "D Constructor" << endl; }
private:
    A a; // a是嵌入D的一部分，欲构造整体的D，先构造局部的a
};

int main() {
    Base base;
    B b; // A
    C c; // A C
    D d; // A D

    return 0;
}
```

## 参考资料

http://www.fredosaurus.com/notes-cpp/oop-condestructors/copyconstructors.html
