---
abbrlink: 101de459
title: C++引用
categories:
  - 编程珠玑
  - CPP
tags:
  - 语法
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
想象一个函数必须接收一个庞大的对象。如果我们在没有引用的情况下传递它，就会创建一个新的副本，从而导致 CPU 时间和内存的浪费。我们可以使用引用来避免这种情况。

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

### 在基于范围的 for 循环中修改所有对象

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

1.指针可以被声明为 void 但引用不行。

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

3.引用不如指针功能强大

引用必须在声明时进行初始化，指针没有这种限制。由于上述限制，C++中的引用不能用于实现链表，树等数据结构。在 Java 中，引用没有上述限制，可以用于实现所有数据结构。Java 中引用功能更强大是 Java 不需要指针的主要原因。

4.引用更安全更容易使用

## 什么是 void 指针?

void 指针一般被称为通用指针或叫泛指针。它是 C 语言关于纯粹地址的一种约定。当某个指针是 void 型指针时，所指向的对象不属于任何类型。因为 void 指针不属于任何类型，则不可以对其进行算术运算，比如自增，编译器不知道其自增需要增加多少。比如`char*`型指针，自增一定是指针指向的地址加 1，`short*`型指针自增，则偏移 2。

在 C/C++中，在任意时刻都可以使用其它类型指针来代替 void 指针，或者用 void 指针来代替其他类型指针。由这些特性就可以衍生出很多比较有用的技巧。指针的本质，是其值为一个地址，那么延伸一下：

当使用关键字 void 声明指针变量时，它将成为通用指针变量。任何数据类型的任何变量的地址都可以赋值给 void 指针变量。

对指针变量的解引用，使用间接寻址运算符\*达到目的。但是在使用空指针的情况下，需要先转换指针变量再解引用。这是因为空指针没有与之关联的数据类型。编译器无法知道 void 指针指向的数据类型。因此，要获取由 void 指针指向的数据，需要使用在 void 指针位置内保存的正确类型的数据进行显式类型转换。

## 参数传递（传值、传引用、传指针）

```c++
#include<iostream>
using namespace std;

void change1(int n) {
    cout << "传值方式的函数操作地址：：" << &n << endl;
    n++;
}

void change2(int& n) {
    cout << "传引用方式的函数操作地址：" << &n << endl;
    n++;
}

void change3(int* n) {
    cout << "传指针方式的函数操作地址： " << n << endl;
    *n += 1;
}

int main() {
    int n = 10;
    cout << "实参的初值：" << n << endl;
    cout << "实参的地址：" << &n << endl;
    change1(n);
    cout << "after change1() n= " << n << endl;
    change2(n);
    cout << "after change2() n= " << n << endl;
    change3(&n);
    cout << "after change3() n= " << n << endl;
    return true;
}
```

运行结果

```
实参的初值：10
实参的地址：0019FED8
传值方式的函数操作地址：：0019FE04
after change1() n= 10
传引用方式的函数操作地址：0019FED8
after change2() n= 11
传指针方式的函数操作地址： 0019FED8
after change3() n= 12
请按任意键继续. . .
```

## 什么时候使用传引用或传指针？

1.修改对象

```c++
#include <iostream>
using namespace std;
void fun(int& x) { x = 20; }
int main() {
    int x = 10;
    fun(x);
    cout << "New value of x is " << x;
    return 0;
}
```

2.传递大类型

```c++
class Employee {
private:
    string name;
    string desig;
    // More attributes and operations
};

void printEmpDetails(Employee emp)
{
    cout << emp.getName();
    cout << emp.getDesig();
    // Print more attributes
}

void printEmpDetails(const Employee& emp)
{
    cout << emp.getName();
    cout << emp.getDesig();
    // Print more attributes
}
```

这一点仅对结构体和类变量有效，因为对于 int，char 等基本数据类型，我们没有任何效率上的优势。

3.避免切片

如果我们将子类的对象传递给需要超类对象的函数，则如果按值传递，传递的对象会被切片。

```c++
#include <iostream>
#include <string>

using namespace std;

class Pet {
public:
    virtual string getDescription() const {
        return "This is Pet class";
    }
};

class Dog : public Pet {
public:
    virtual string getDescription() const {
        return "This is Dog class";
    }
};

void describe(Pet p) { // Slices the derived class object
    cout << p.getDescription() << endl;
}

int main() {
    Dog d;
    describe(d);
    return 0;
}
```

运行结果

```
This is Pet class
请按任意键继续. . .
```

我们创建的明明是子类狗对象，结果输出的却是超类宠物的语句。
如果我们在上述程序中改成使用按引用传递，则它会正确打印 This is Dog Class。请参阅以下修改的程序。

```c++
void describe(const Pet& p)
{ // Doesn't slice the derived class object.
    cout << p.getDescription() << endl;
}

int main()
{
    Dog d;
    describe(d);
    return 0;
}
```

运行结果

```
This is Dog class
请按任意键继续. . .
```

值得注意的是，这一点也对基本数据类型无效。仅对结构体和类变量有效。

尝试做一个小的归纳：

- 传值：基类对象会以自己为标准切割派生类对象。
- 传地址：基类指针可以指向派生类对象（把男女老少当人，把金毛泰迪当狗。）。虚函数这里需要注意的是使用基类指针调用派生类函数时遵循的中心思想是——根据指向或引用的对象实例的类型调用来虚函数，而非根据指针或引用的类型。

  4.在函数中实现运行时多态（RunTime Polymorphism）

多态分为运行时多态和编译时多态。

通过将对象作为引用或指针传递给函数，我们可以使函数具有多态性。其原理依旧是上面基类指针指向派生类对象时调用派生类函数的叙述。

例如，在下面的程序中，print()接收对基类对象的引用。如果传递了基类对象，print()调用基类中的 show()，如果传递了派生类对象，则调用派生类中的 show()。

```c++
#include <iostream>
using namespace std;

class base {
public:
    virtual void show()
    { // Note the virtual keyword here
        cout << "In base \n";
    }
};

class derived : public base {
public:
    void show() { cout << "In derived \n"; }
};

// Since we pass b as reference, we achieve run time polymorphism here.
void print(base& b) { b.show(); }

int main(void)
{
    base b;
    derived d;
    print(b);
    print(d);
    return 0;
}
```

运行结果

```
In base
In derived
请按任意键继续. . .
```

如果把上面程序中的`void print(base& b) { b.show(); }`传递的参数修改为`void print(base b) { b.show(); }`，则运行结果会变成输出两次 In base，不具备多态性。

考虑另一种情况，把上面程序中`void print(base& b) { b.show(); }`的传参部分修改成`void print(derived& b) { b.show(); }`，此时会报错：无法用"base"类型的值初始化"derived &"类型的引用(非常量限定)

这是因为原来的 print()期待一个基类对象的引用，也可以识别从基类派生出来的子类。但是修改后的 print()期待的是一个子类对象的引用。期待父类时勉强也可以接受只有子类的现实；但期待子类的时候，这一目的变得更加明确，动机也更加强烈，它只愿意接受自己所期待的子类，而不愿用父类对象来凑活一下。

这就像，A 和 B 是学生时代最好的朋友，A 和 B 各自成家立业后依然是最好的朋友，此外 A 也很关照 B 的儿子 b，B 也很关照 A 的儿子 a。虽然 a 和 b 也是好朋友，但作为小辈的 a 和 b 则一般不会对对方的父辈（像对方父辈关照自己一样）那么亲近了。这在现实世界是很常见的。

说明：

```c++
A: void print1(base& b); // 期待基类对象的函数，也愿意接收基类的子类
B: base b; // 基类对象
a: void print2(derived& b); // 期待子类对象的函数，但不愿意接收子类的父类
b: derived d; // 子类对象
```

结果：A 既认 B 也认 b，但 a 不认 B 只认 b。

这个例子其实举得并不好，因为基类和子类的关系实际上比伦理的父与子的关系更加紧密。好好体会上述事实和背后的原理。

（与运行时多态这个例子无关）顺带说明一下，对函数传引用时，建议的做法是：如果只是出于对上面所提到第 2（传递大类型）或 3（避免切片）条的考虑而选择通过引用传递参数，请将引用参数设置为 const。这是为了避免对对象造成意外修改。比如：`void describe(const Pet& p)`。
