---
abbrlink: 99c27b28
title: C++智能指针
categories:
  - 编程珠玑
  - C++
tags:
  - 指针
date: 2021-04-22 14:19:05
---
## 指针的重要性

指针用于访问程序外部的资源，如堆内存。因此，如果在堆内存中创建了任何内容，则使用指针访问堆内存。

## 普通指针出现的问题

普通指针需要手动释放内存。

## 引入智能指针

使用智能指针，我们可以使指针不需要以显式调用delete的方式工作。智能指针是指针的包装类，带有*和->重载的运算符。智能指针类的对象看起来像一个指针，但是可以执行普通指针无法完成的许多自动销毁操作和引用计数等。

其思想是采用一个带有指针、析构函数和重载运算符（如*和->）的类。由于对象超出作用域时自会动调用析构函数，因此动态分配的内存将自动删除（或者可以减少引用计数）。考虑以下简单的智能ptr类。

```c++
#include <iostream>
using namespace std;

class SmartPtr {
    int* ptr; 
public:
    explicit SmartPtr(int* p = NULL) { ptr = p; } 
    ~SmartPtr() { delete ptr; } 
    int& operator*() { return *ptr; }

int main() {
    SmartPtr ptr(new int());
    *ptr = 20;
    cout << *ptr << endl;
    return 0;
}
```

编写一个适用于所有类型的智能指针类。

```c++
#include <iostream>
using namespace std;

template <class T>
class SmartPtr {
T* ptr; public:
    explicit SmartPtr(T* p = NULL) { ptr = p; }
    ~SmartPtr() { delete (ptr); }
    T& operator*() { return *ptr; }
    T* operator->() { return ptr; }
};

int main() {
    SmartPtr<int> ptr(new int());
    *ptr = 20;
    cout << *ptr << endl;
    return 0;
}
```

注：智能指针在资源管理（例如文件句柄或网络套接字）中也很有用。

## 智能指针的类型

### unique_ptr

如果使用唯一指针（独享内存的智能指针），则如果创建了一个对象并且指针P1指向该对象，则一次只能有一个指针可以指向该对象。因此我们无法与其他指针共享，但是我们可以通过删除P1来讲控制权转移到P2。

```c++
#include <iostream>
#include <memory>
using namespace std;

class Rectangle {
    int length;
    int width;
public:
    Rectangle(int l, int w) { length = l; width = w; }
    int area() { return length * width; }
};

int main() {
    unique_ptr<Rectangle> P1(new Rectangle(10, 5));
    cout << P1->area() << endl; // 50
    unique_ptr<Rectangle> P2;
    P2 = move(P1); // 把P1拥有的对某块内存的控制权移交出来，赋给P2
    cout << P2->area() << endl; // 50
    cout << P1->area() << endl;
    return 0;
}
```

### shared_ptr

如果您使用的是shared_ptr，那么一次可以有多个指针指向这一个对象，它将使用use_count()方法来维护一个引用计数器（有几个指针指向这个对象）。

```c++
#include <iostream>
using namespace std;
#include <memory>

class Rectangle {
    int length;
    int breadth;
public:
    Rectangle(int l, int b) { length = l; breadth = b; }
    int area() { return length * breadth; }
};

int main() {
    shared_ptr<Rectangle> P1(new Rectangle(10, 5));
    cout << P1->area() << endl; // 50
    shared_ptr<Rectangle> P2;
    P2 = P1;
    cout << P2->area() << endl; // 50
    cout << P1->area() << endl; // 50
    cout << P1.use_count() << endl; // 2
    return 0;
}
```

### weak_ptr

除了不维护引用计数器外，它与shared_ptr非常相似。在这种情况下，指针不会对对象产生强烈的影响。原因是如果假设指针持有该对象并请求其他对象，则它们可能会形成死锁。

最后，C++库已经以auto_ptr，unique_ptr，shared_ptr和weak_ptr的形式提供了智能指针的实现。

注：auto_ptr是一个C++标准库中的早期类模板，现在已经被unique_ptr类所取代了。