---
title: C++虚函数
abbrlink: 14dee7b5
categories:
  - 编程珠玑
  - CPP
tags:
  - OOP
date: 2021-04-27 20:35:11
---

虚函数是运行时多态，不是编译时多态，编译时多态是函数重载和运算符重载。

继承机制中规定：基类指针可以指向派生类对象。一句话，把男女老少当人，把金毛泰迪当狗。

虚函数这里需要注意的是使用基类指针调用派生类函数的情况。其思想是，根据指向或引用的对象实例的类型调用来虚函数，而非根据指针或引用的类型。

先举个没用到虚函数的例子：

```c++
#include <iostream>
using namespace std;

class Shape {
public:
    Shape(int l, int w) :length(l), width(w) {}
    void get_Area() { cout << "调用基类Shape的求面积函数" << endl; }
protected:
    int length, width;
};

class Square : public Shape {
public:
    Square(int l = 0, int w = 0) : Shape(l, w) {}
    void get_Area() {
        cout << "Square area: " << length * width << endl;
    }
};

class Rectangle : public Shape {
public:
    Rectangle(int l = 0, int w = 0) : Shape(l, w) {}
    void get_Area() {
        cout << "Rectangle area: " << length * width << endl;
    }
};

int main(void) {
    Shape* s;
    Square sq(5, 5);
    Rectangle rec(4, 5);

    s = &sq;
    s->get_Area(); // 调用基类Shape的求面积函数
    s = &rec;
    s->get_Area(); // 调用基类Shape的求面积函数

    return 0;
}
```

这段程序的原意是调用各子类的求面积函数求出并打印面积。但实际运行结果只是调用了两次基类面积函数。

为了达成初衷，只需要改写基类中的 getArea 函数如下：

```c++
virtual void get_Area() {
    cout << "调用基类Shape的求面积函数" << endl;
}
```

虚函数应用例子

```c++
class Employee {
public:
    virtual void raiseSalary() { /* 涨薪 */ }

    virtual void promote() { /* 升职 */ }
};

class Manager : public Employee {
    virtual void raiseSalary() {
        /* Manager specific raise salary code, may contain
        increment of manager specific incentives*/
    }

    virtual void promote() {
        /* Manager specific promote */
    }
};

// Similarly, there may be other types of employees

// We need a very simple function
// to increment the salary of all employees
// Note that emp[] is an array of pointers
// and actual pointed objects can
// be any type of employees.
// This function should ideally
// be in a class like Organization,
// we have made it global to keep things simple
void globalRaiseSalary(Employee* emp[], int n) {
    for (int i = 0; i < n; i++)

        // Polymorphic Call: Calls raiseSalary()
        // according to the actual object, not
        // according to the type of pointer
        emp[i]->raiseSalary();
}
```

## 编译器如何执行运行时解析？

编译器维护两件事来实现此目的：

1.vtable：指向虚函数的指针的表格，按类维护。
2.vptr：指向 vtable 的指针，按对象实例维护（参见[此](https://www.geeksforgeeks.org/c-virtual-functions-question-12/)示例）。

预测下面程序的输出：

```c++
#include <iostream>
using namespace std;

class A {
public:
    virtual void fun();
};

class B {
public:
    void fun();
};

int main() {
    int a = sizeof(A), b = sizeof(B);

    if (a == b) cout << "a == b";
    else if (a > b) cout << "a > b";
    else cout << "a < b";

    return 0;
}
```

结果：a>b
分析：A 类有一个在 B 类中不存在的 VPTR。在虚拟函数的典型实现中，编译器为每个对象放置一个 VPTR。编译器秘密地在每个构造函数中添加一些代码。

## 默认参数和虚函数

考虑下面程序的运行结果：

```c++
#include <iostream>
using namespace std;

class Base {
public:
    virtual void fun(int x = 0) { cout << "Base::fun(), x = " << x << endl; }
};

class Derived : public Base {
public:
    virtual void fun(int x) { cout << "Derived::fun(), x = " << x << endl; }
};

int main() {
    Derived d1;
    Base* bp = &d1;
    bp->fun();
    return 0;
}
```

运行结果：

```
Derived::fun(), x = 0
请按任意键继续. . .
```

默认参数不参与函数签名。因此，基类和派生类中 fun()的签名被认为是相同的，因此基类的 fun()被重写。另外，默认值在编译时使用。当编译器发现函数调用中缺少参数时，它将替换给定的默认值。因此，在上述程序中，x 的值在编译时被替换，并在运行时调用派生类的 fun()。

现在稍加变动后，预测以下程序的输出。

```c++
#include <iostream>
using namespace std;

class Base {
public:
    virtual void fun(int x = 0) { cout << "Base::fun(), x = " << x << endl; }
};

class Derived : public Base {
public:
    virtual void fun(int x = 10) { cout << "Derived::fun(), x = " << x << endl; }
};

int main() {
    Derived d1;
    Base* bp = &d1;
    bp->fun();
    return 0;
}
```

运行结果：

```
Derived::fun(), x = 0
请按任意键继续. . .
```

原因跟上一个相同，默认值在编译时被替换。fun()在基类型的指针 bp 上调用。所以编译器将其替换为 0（不是 10）。

注意一点，编译时用基类默认值替换，不妨碍运行时调用的是派生类的函数。
正如这篇文章开头所说的：
使用基类指针调用派生类的函数的思想是，根据指向或引用的对象实例的类型调用虚拟函数，而不是根据指针或引用的类型。

调用发生在运行时，静态替换发生在编译时。
C++里跟静态两个字沾边的术语，其背后多多少少都是编译时实现或者发生的。

想起来去年接触的一句话：数学公式里有 pi 的地方背后一定藏着一个圈，即使这个公式和圆看起来八竿子打不着。

总结：通常，最佳做法是避免使用虚函数中的默认值，以免造成混淆。

## 派生类中的虚函数

在 C++中，一旦在基类中将成员函数声明为虚函数，则该函数在从该基类派生的每个类中都将变为虚函数。换句话说，在声明虚拟基类函数的重新定义版本时，不必在派生类中使用关键字 virtual。

例如，以下程序将打印“C::fun() called”，因为 B::fun()虽然没写 virtual，但实质上已经自动变为虚了，所以自 B 派生出的 C 自然也是虚的 fun()。

```c++
#include<iostream>
using namespace std;

class A {
public:
    virtual void fun() { cout << "\n A::fun() called "; }
};

class B : public A {
public:
    void fun() { cout << "\n B::fun() called "; }
};

class C : public B {
public:
    void fun() { cout << "\n C::fun() called "; }
};

int main() {
    C c;
    B* b = &c;
    b->fun();
    return 0;
}
```

## C++中的静态函数是否可以是虚拟的？

不能。C++中，类的静态成员函数不能是虚函数，也不能为 const 和 volatile。
以下举个反例：

```c++
#include<iostream>
using namespace std;

class Test {
public:
    virtual static void fun() { } // 错误1
    static void fun() const { } // 错误2
};
```

上述代码有编译错误。
分析一下：
错误 1：仅非静态成员函数可以是虚拟的（要去掉 virtual）
错误 2：静态成员函数上不允许使用类型限定符（要去掉 const）

## 虚析构函数

使用具有非虚析构函数的基类指针删除派生类对象会导致未定义的行为。为了纠正这种情况，应该使用虚拟析构函数来定义基类。

分析下面一段代码

```c++
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

输出：

```
Constructing base
Constructing derived
Destructing base
请按任意键继续. . .
```

可以发现，派生类的析构函数没有被正确调用。基类指针 b 没有调用派生类析构函数。为了解决这个问题，应该让基类析构函数为虚，这样可以保证派生类的对象被正确地析构。即基类和派生类的析构函数都被调用。

```c++
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
    ~derived() { cout << "Destructing derived \n"; }
};

int main(void) {
    derived* d = new derived();
    base* b = d;
    delete b;
    return 0;
}
```

运行结果

```
Constructing base
Constructing derived
Destructing derived
Destructing base
请按任意键继续. . .
```

原则上，任何时候在类中具有虚函数时，都应立即添加虚析构函数（即使它不执行任何操作）。这样，您可以确保以后不会出现任何意外情况。

## 虚构造函数

我们可以在 C++中使类构造函数虚拟化以创建多态对象吗？
不可以。C++是静态类型的（RTTI 的目的有所不同）语言，对于 C++编译器来说，创建多态对象是没有意义的。编译器必须知道创建对象的类类型。换句话说，从 C++编译器的角度来看，要创建哪种类型的对象是编译时的决定。如果我们将构造函数设为虚拟，则编译器会标记错误。实际上，除内联函数外，构造函数的声明中不允许使用其他关键字。
在实际场景中，我们需要基于一些输入在类层次结构中创建派生类对象。换言之，对象创建和对象类型紧密耦合，这迫使修改扩展。虚拟构造函数的目的是使对象创建与其类型脱钩。

我们如何在运行时创建所需的对象类型？请参见下面的示例程序。

回头再复习，先空着
https://www.geeksforgeeks.org/advanced-c-virtual-constructor/

## RTTI 和 dynamic_cast

在 C++中，RTTI（运行时类型信息）是一种在运行时公开有关对象数据类型的信息的机制，并且仅对具有至少一个虚函数的类可用。它允许在程序执行期间确定对象的类型。

思考下面一段代码

```C++
#include<iostream>
using namespace std;
class B { };
class D : public B {};

int main() {
    B* b = new D;
    D* d = dynamic_cast<D*>(b);
    if (d != NULL) cout << "works";
    else cout << "cannot cast B* to D*";
    return 0;
}
```

报错
运行时 dynamic_cast 的操作数必须包含多态类类型
这是因为基类中没有虚函数。

为了修正程序，应该在基类 B 中添加虚函数，如下

```c++
#include<iostream>
using namespace std;
class B { virtual void fun() {} };
class D : public B {};

int main() {
    B* b = new D;
    D* d = dynamic_cast<D*>(b);
    if (d != NULL) cout << "works";
    else cout << "cannot cast B* to D*";
    return 0;
}
```

程序通过。

## 纯虚函数和抽象类

有时，由于我们不知道具体实现，因此无法在基类中提供所有功能的具体实现。这样的类称为抽象类。
例如，让 Shape 为基类。我们无法在 Shape 中提供功能 draw()的实现，但是我们知道每个派生类都必须具有 draw()的实现。同样，动物类也没有 move()的实现（假设所有动物都在移动），但是所有动物都必须知道如何移动。我们不能创建抽象类的对象。（抽象类不能实例化）

C++中的纯虚函数（或抽象函数）是一个虚拟函数，我们可以实现它，但是必须在派生类中重写该函数，否则，派生类也将成为抽象类（有关我们在何处为此类函数提供实现的更多信息，请参阅https://stackoverflow.com/questions/2089083/pure-virtual-function-with-implementation). 纯虚函数是通过在声明中赋值 0 来声明的。请参见下面的示例。

```c++
class Test {
public:
    virtual void show() = 0;
};
```

一个完整的例子： 
纯虚函数是由抽象类派生的类实现的。下面是一个简单的例子来说明同样的问题。

```c++
#include<iostream>
using namespace std;

class Base {
    int x;
public:
    virtual void fun() = 0;
    int getX() { return x; }
};

class Derived : public Base {
    int y;
public:
    void fun() { cout << "fun() called"; }
};

int main(void) {
    Derived d;
    d.fun();
    return 0;
}
```

运行结果

```
fun() called请按任意键继续. . .
```

一些有趣的事实：
如果一个类至少有一个纯虚函数，那么它就是抽象的。
可以有抽象类类型的指针和引用。
如果不重写派生类中的纯虚函数，则派生类也会变成抽象类。
抽象类可以有构造函数。

C++使用抽象类来实现接口。可以当成抽象类就是接口。设计面向对象的系统时可以使用一个抽象基类为所有的外部应用程序提供一个适当的、通用的、标准化的接口。然后，派生类通过继承抽象基类，就把所有类似的操作都继承下来。

---

## 面试题

最后再趁热打铁复习一下以前背过的 C++八股里的虚函数部分，加深一下理解。

#### 为什么析构函数总是设为虚函数？如果这是必要的，那么为什么 C++不把虚析构函数直接作为默认值？

将可能会被继承的基类的析构函数设置为虚函数，使用基类指针指向其子类对象，当释放基类指针时可以释放掉子类的空间，防止内存泄漏。

C++默认的析构函数不是虚函数是因为虚函数需要额外的虚函数表和虚表指针，占用额外的内存。而对于不会被继承的类来说，其析构函数如果是虚函数，就会浪费内存。因此 C++默认的析构函数不是虚函数，而是只有当需要当作基类时，设置为虚函数。

#### 请你来说一下静态函数和虚函数的区别

静态函数在编译的时候就已经确定运行时机，虚函数在运行的时候动态绑定。虚函数因为用了虚函数表机制，调用的时候会增加一次内存开销。

#### C++中虚函数与纯虚函数的区别

子类可以不复写基类虚函数，但必须复写基类纯虚函数。
