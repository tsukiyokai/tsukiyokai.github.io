---
abbrlink: 5082990a
title: C++中的this指针
categories:
  - 编程珠玑
  - C++
tags:
  - 指针
date: 2021-04-22 15:29:10
---

## 概念

要理解 this 指针，重要的是要了解对象如何是看待类的函数和数据成员的。

1. 每个对象都拥有属于自己的数据成员的副本。
2. 所有函数都访问与代码段中相同的函数定义。

这分别意味着每个对象都有自己的数据成员副本以及所有对象共享一个成员函数副本。

现在的问题是，如果每个成员函数只存在一个副本，并且被多个对象使用，那么如何访问和更新适当的数据成员？编译器了提供一个隐式指针 this。

## 使用 this 指针的几种情况

### 当作为参数传递的局部变量的名称与成员名称相同时

```c++
#include<iostream>
using namespace std;

class Test {
private:
    int x;
public:
    void setX(int x) { this->x = x; }
    void print() { cout << "x = " << x << endl; }
};

int main() {
    Test obj;
    int x = 20;
    obj.setX(x);
    obj.print();
    return 0;
}
```

解释一下：
不太科学的解释：`这个->x = x;`的意思是，这个类里的成员 x=参数 x

知乎上一个 0 赞的匿名回答完美解释了我好几年来的疑问，如下：
问题：C++中 this 指针藏在哪里？this 指针应该是指向对象的，那么这个指针不是应该存在对象中的吗？
回答：答主。面向对象编程在编译过后并不存在所谓对象这个东西。对象的概念只存在在高层次的抽象中。所谓对象方法，实际上只是个普通的函数，只不过在你写代码的时候，这个函数是归属于某个对象或者某个类的，而编译成程序后，这个方法和普通的函数没有区别。实际上，在方法中使用 this 的原理非常简单，**就是在传参时把对象所在的内存地址传进去**。就像在 python 中类方法生命时需要有 self 变量。
解决我长久迷惑的那一句：就是在传参时把对象所在的内存地址传进去。
就是在传参时把对象所在的内存地址传进去。
就是在传参时把对象所在的内存地址传进去。
适用到上面的程序中就是，在把参数 x 传进 setX()时，把 obj 这个 Test 类型的对象所在的地址也传进去。

这时就可以完美理解百度百科上的那个例子了。

（来自百度百科）关于 this 指针的一个经典回答:
当你进入一个房子后，
你可以看见桌子、椅子、地板等，
但是房子你是看不到全貌了。
对于一个类的实例来说，
你可以看到它的成员函数、成员变量，
但是实例本身呢？
this 是一个指针，它时时刻刻指向你这个实例本身。

啊，至此终于全部畅通了。

### 返回对调用对象的引用

```c++
/* Reference to the calling object can be returned */
Test& Test::func() {
    // Some processing
    return *this;
}
```

当一个局部对象返回引用时，返回的引用可以做为一个对象调用下一个函数。这就是链式函数调用。

```c++
#include<iostream>
using namespace std;

class Test {
private:
    int x;
    int y;
public:
    Test(int x = 0, int y = 0) { this->x = x; this->y = y; }
    Test& setX(int a) { x = a; return *this; }
    Test& setY(int b) { y = b; return *this; }
    void print() { cout << "x = " << x << " y = " << y << endl; }
};

int main() {
    Test obj1(5, 5);
    // 链式函数调用。所有调用都修改同一个对象，因为引用返回了同一个对象
    obj1.setX(10).setY(20);
    obj1.print();
    return 0;
}
```

## this 指针的类型

在 C++中，this 指针作为一个隐藏参数传递给所有非静态成员函数调用。它的类型取决于函数声明。如果将类 X 的成员函数声明为 const，则其类型为`const X*`（请参见下面的代码 1），如果将成员函数声明为 volatile，则其类型为`volatile X*`（请参见下面的代码 2），如果成员函数声明为`const volatile`，则其类型为 const `volatile X*`（请参见下面的代码 3）。

Code1

```c++
class X {
    void fun() const {
        // this is passed as hidden argument to fun().
        // Type of this is const X* const
    }
};
```

Code2

```c++
class X {
    void fun() volatile {
        // this is passed as hidden argument to fun().
        // Type of this is volatile X* const
    }
};
```

Code3

```c++
class X {
    void fun() const volatile {
        // this is passed as hidden argument to fun().
        // Type of this is const volatile X* const
    }
};
```

## this 的销毁

理想情况下，不应将 delete 运算符用于 this 指针。但是，如果使用，则必须考虑以下几点。

1. delete 运算符仅适用于使用 new 运算符分配的对象。如果对象是使用 new 创建的，那么我们可以删除它，否则会发生未定义行为。
2. delete 完成后，已删除对象的任何成员都不应被访问。

最好压根就不要适用 delete this。
