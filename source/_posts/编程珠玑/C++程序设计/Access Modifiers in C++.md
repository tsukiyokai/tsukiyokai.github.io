---
title: C++访问修饰符
abbrlink: ede8
categories:
  - 编程珠玑
  - C++程序设计
tags:
  - OOP
date: 2021-04-26 19:45:47
---
访问修饰符用于实现OOP的一个重要方面——数据封装。

类中的访问修饰符或访问说明符用于将可访问性分配给类成员。
也就是说，它对类成员设置了一些限制，使其不能被外部函数随意访问。

There are 3 types of access modifiers available in C++: 
- Public
- Private
- Protected

Note: If we do not specify any access modifiers for the members inside the class then by default the access modifier for the members will be Private.

## Public

公开，可以被内外部其它类或函数随便访问。

```c++
#include<iostream>
using namespace std;

class Circle {
public:
    double radius;
    double compute_area() { return 3.14 * radius * radius; }
};

int main() {
    Circle obj;
    obj.radius = 5.5;
    cout << "Radius is: " << obj.radius << "\n";
    cout << "Area is: " << obj.compute_area();
    return 0;
}
```

## Private

基类本身、友元可以直接访问。
派生类、外部、陌生类不能访问。

```c++
#include<iostream>
using namespace std;

class Circle {
private:
    double radius;
public:
    double compute_area() { return 3.14 * radius * radius; }
};

int main() {
    Circle obj;
    obj.radius = 1.5;
    cout << "Area is:" << obj.compute_area();
    return 0;
}
```
这段程序发生编译错误：E0265	成员 "Circle::radius" (已声明 所在行数:6) 不可访问

但是，我们可以通过类的公共成员函数来间接访问类的私有数据成员。例如：

```c++
#include<iostream>
using namespace std;

class Circle {
private:
    double radius;
public:
    void compute_area(double r) {
        radius = r;
        double area = 3.14 * radius * radius;
        cout << "Radius is: " << radius << endl;
        cout << "Area is: " << area;
    }
};

int main() {
    Circle obj;
    obj.compute_area(1.5);
    return 0;
}
```

## Protected

基类本身、派生类、友元可以访问。
陌生类和外部不能访问。

```c++
#include <iostream>
using namespace std;

class Parent {
protected:
    int id_protected;
};

class Child : public Parent {
public:
    void setId(int id) { id_protected = id; }
    void displayId() { cout << "id_protected is: " << id_protected << endl; }
};

int main() {
    Child obj1;
    obj1.setId(81);
    obj1.displayId();
    return 0;
}
```