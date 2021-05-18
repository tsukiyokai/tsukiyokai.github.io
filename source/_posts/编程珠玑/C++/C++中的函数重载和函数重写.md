---
title: 函数重载和函数重写
abbrlink: c98307e3
categories:
  - 编程珠玑
  - C++
tags:
  - OOP
date: 2021-04-27 15:38:27
---

函数重载在编译时实现。
它通过修改函数签名来提供函数的多种定义。比如参数个数、参数类型。
修改返回值类型不能实现重载。// functions can not be overloaded if they differ only in the return type.
它既可以在基类中也可以在派生类中完成。

```c++
#include <iostream>
using namespace std;

void test(int);
void test(float);
void test(int, float);

int main() {
    int a = 5;
    float b = 5.5;
    test(a);
    test(b);
    test(a, b);

    return 0;
}

void test(int var) {
    cout << "Integer number: " << var << endl;
}

// Method 2
void test(float var) {
    cout << "Float number: " << var << endl;
}

// Method 3
void test(int var1, float var2) {
    cout << "Integer number: " << var1;
    cout << " and float number: " << var2 << endl;
}
```

函数重写（在运行时实现）
它是基类函数在其派生类中的重新定义，具有相同的签名，即返回类型和参数。
它只能在派生类中完成。

```c++
// CPP program to illustrate
// Function Overriding
#include<iostream>
using namespace std;

class BaseClass {
public:
    virtual void Display() { cout << "基类Display()\n"; }
    void Show() { cout << "基类Show()\n"; }
};

class DerivedClass : public BaseClass {
public:
    void Display() { cout << "子类Display()\n"; }
};

// Driver code
int main() {
    DerivedClass dr;
    BaseClass& bs = dr;
    bs.Display();
    dr.Show();
}
```

以上代码输出：

```
子类Display()
基类Show()
请按任意键继续. . .
```

解释一下这条语句：
`BaseClass& bs = dr;`

调用函数的时候，关键看对象的类型。
调用函数的时候，关键看对象的类型。
调用函数的时候，关键看对象的类型！
记住是对象的类型，不管是指针还是引用（同样是对象的类型）。
比如，bs 是对象 dr 的引用，bs 调用 display 时，其实是 bs 引用的对象 dr 取调用 display。所以输出：子类 Display()

或者看这句话：其思想是根据指向或引用的对象实例的类型调用虚拟函数，而不是根据指针或引用的类型。

再看下面代码

```c++
class Father {
public:
    void FunctionA() const { cout << "父类FunctionA" << endl; }
    virtual void FunctionB() const { cout << "父类FunctionB" << endl; }
};
class Child : public Father {
public:
    void FunctionA() const { cout << "子类FunctionA" << endl; }
    virtual void FunctionB() const { cout << "子类FunctionB" << endl; }
};
```

在将父类对象的指针指向子类对象的时候
`Father* father = new Child;`
如 father->FunctionA()，则执行的是 Father 中的实现；
father->FunctionB()，则执行的是 Child 中的实现。

C++函数重载和 const
C++ allows functions to be overloaded on the basis of const-ness of parameters only if the const parameter is a reference or a pointer.
https://www.geeksforgeeks.org/function-overloading-and-const-functions/

不能重载的函数：

1. 不能重载只有返回值不同的两个函数
2. 不能重载具有相同参数类型的静态和非静态成员函数
3. 在参数声明中，一维数组和一级指针在参数声明中是等价的，在参数类型中，只有第二维和后续数组维才有意义。例如下面两个声明完全等价：`int fun(int* ptr);`和`int fun(int ptr[]);`（发生了重定义）
4. 参数 const 和非 const

不能重载的函数参见
https://www.geeksforgeeks.org/function-overloading-in-c/

重载可以与继承一起使用吗？

```c++
#include <iostream>
using namespace std;
class Base {
public:
    int f(int i) {
        cout << "f(int): ";
        return i + 3;
    }
};
class Derived : public Base {
public:
    double f(double d) {
        cout << "f(double): ";
        return d + 3.3;
    }
};
int main() {
    Derived* dp = new Derived;
    cout << dp->f(3) << '\n';
    cout << dp->f(3.3) << '\n';
    delete dp;
    return 0;
}
```

上面程序输出：
f(double): 6.3
f(double): 6.6
请按任意键继续. . .

可见，子类 f 遮蔽了父类 f，在 C++语言中，重载对派生类不起作用。基和派生之间没有重载解析。编译器检查派生函数的作用域，找到单个函数“double f（double）”并调用它。它从不干扰基础的（封闭的）范围。在 C++中，跨范围没有重载——派生类作用域对这个一般规则也不例外。更多示例见此）

结论：重载要限定在同一个作用域。父类和子类不在一个范围。

重载的二义性

观察下面代码：

```c++
#include<iostream>
using namespace std;

void test(float s, float t) { cout << "Function with float called "; }
void test(int s, int t) { cout << "Function with int called "; }

int main() {
    test(3.5, 5.6);
    return 0;
}
```

尝试编译它时会发生错误：test:对重载函数的调用不明确。有多个重载函数 test 实例与参数列表匹配。

原因是：浮点数 3.5 和 5.6 通常是被编译器作为 double 对待的。
根据 C++标准，除非后缀明确指定，否则浮点文字（编译时间常数）将被视为 double（请参见此处的 C +++标准 2.14.4）。
由于编译器无法找到带有 double 参数的函数，因此如果将值从 double 转换为 int 或 float 会感到困惑。

纠正错误的方法：(3.5f, 5.6f)即可
