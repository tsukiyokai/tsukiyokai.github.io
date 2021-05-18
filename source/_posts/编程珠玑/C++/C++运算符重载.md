---
title: 运算符重载
abbrlink: 2bf420ab
categories:
  - 编程珠玑
  - C++
tags:
  - OOP
date: 2021-04-27 17:49:24
---

C++中，运算符是作为函数被实现的。严格来说，运算符重载也是一种函数重载。

当你看到 a+b 时，可以把它脑补成+(x,y)，其中+是函数名。

通过重载运算符，可以让已有的运算符为用户定义的类工作
例如，我们可以在 String 之类的类中重载运算符+，以便仅使用+即可连接两个字符串。
算术运算符可能会重载的其他示例类是复数，小数，大整数等。

```c++
#include<iostream>
using namespace std;

class Complex {
private:
    int real, imag;
public:
    Complex(int r = 0, int i = 0) :real(r), imag(i) { }
    // 当加号+被用于两个复数对象时，下面代码会被自动调用
    Complex operator + (Complex const& obj) {
        Complex res;
        res.real = real + obj.real;
        res.imag = imag + obj.imag;
        return res;
    }
    void print() { cout << real << " + i" << imag << endl; }
};

int main() {
    Complex c1(10, 5), c2(2, 4);
    Complex c3 = c1 + c2; // An example call to "operator+"
    c3.print();
}
```

输出：12+i9

operator 函数和普通函数的区别？

一个全局运算符重载的例子

```c++
#include<iostream>
using namespace std;

class Complex {
private:
    int real, imag;
public:
    Complex(int r = 0, int i = 0) { real = r; imag = i; }
    void print() { cout << real << " + i" << imag << endl; }

    // The global operator function is made friend of this class so
    // that it can access private members
    friend Complex operator + (Complex const&, Complex const&);
};

Complex operator + (Complex const& c1, Complex const& c2) {
    return Complex(c1.real + c2.real, c1.imag + c2.imag);
}

int main() {
    Complex c1(10, 5), c2(2, 4);
    Complex c3 = c1 + c2; // An example call to "operator+"
    c3.print();
    return 0;
}
```

上例中，通过将重载的运算符声明为类的友元，使其可以访问类中的私有成员。

可以被重载的运算符：

```
+    -    *    /      %        ^
&    |    ~    !,        =
    =      ++        --
    ==    !=      &&        ||
+=    -=    /=    %=      ^=        &=
|=    *=    =      []        ()
->    ->*    new    new []      delete    delete []
```

不能重载的运算符：
.(dot)
::
?:
sizeof

运算符重载的一些要点

1. 为了使运算符重载起作用，至少一个操作数必须是用户定义的类对象。
2. 赋值运算符：编译器会自动为每个类创建一个默认的赋值运算符。默认的赋值运算符确实将右侧的所有成员分配到左侧，并且在大多数情况下都可以正常工作（此行为与复制构造函数相同）。
3. 转换运算符：我们还可以编写可用于将一种类型转换为另一种类型的转换运算符。
