---
title: C++中的mutable关键字
abbrlink: 4edf765f
categories:
  - 编程珠玑
  - CPP
tags:
  - 语法
date: 2021-05-18 20:03:02
---

## 前言

I've seen too many tutorials and lessons that get the "mutable" keyword in C++ entirely wrong. The result is terrible C++ code. Here's my attempt to clear things up: "C++'s mutable and conceptual constness."

## 正文

关键字 mutable 用于允许修改 const 对象的特定数据成员。如果大多数成员应该是常量，但少数成员需要是可更新的，则这一点特别有用。假设我们在 Employee 类中添加一个 salary 成员。虽然员工姓名和 id 可能是固定的，但工资不应该是固定的。

```c++
#include<bits/stdc++.h>
using namespace std;

class Employee {
private:
    string _name;
    string _id;
    mutable double _salary;
public:
    Employee(string name = "No Name", string id = "000-00-0000", double salary = 0) : _name(name), _id(id) { _salary = salary; }
    string getName() const { return _name; }
    void setName(string name) { _name = name; }
    string getid() const { return _id; }
    void setid(string id) { _id = id; }
    double getSalary() const { return _salary; }
    void setSalary(double salary) { _salary = salary; }
    void promote(double salary) const { _salary = salary; }
};

int main() {
    return 0;
}
```

现在，即使对于以常量描述的 Employee 对象，也可以修改 salary：

```c++
const Employee john("JOHN", "007", 5000.0);
john.promote(20000.0);
```

大部分介绍 mutable 的网站和文章都是对其作如上解释的。

不，不！一千次，不！

我以前见过这种可怕的想法。这种疯狂导致代码错误，并破坏了 C++ 中 CONST 的全部目的。我只能得出结论，写这种废话的人自己并不理解 mutable 的目的。所以他们会犯这个错误，把这个废话传给下一组 C++程序员。这必须停止。

当标记变量 const 时，您承诺（并要求 C++强制执行）您将永远不会在逻辑上修改该对象的内容。这样做的最有用的原因可能是当您通过引用或指针将对象传递到函数中时。通过使其为常量，该函数保证不会与您的对象混淆。例如，假设您有一个从 Person 继承的 Robot 类。您想将您的机器人对象作为参数传递给函数 take_pulse。您希望 take_pulse 使用 Robot 的重写方法，因此 take_pulse 通过引用获取对象。因为它是 const，所以您可以确信 take_pulse 不会修改机器人，只需从中读取：

```c++
class Person {
public:
    virtual bool has_pulse() const { return true; }
    void set_name() { /* ... */ }
};

class Robot : public Person {
public:
    virtual bool has_pulse() const { return false; }
    void set_name() { /* ... */ }
};

/*
Because Person is const, take_pulse cannot call set_name().
Because Person is a reference, we can pass in a Robot robot and get the correct answer (false).
*/
bool take_pulse(const Person& X) { return X.has_pulse(); }
// const对象只能调用cosnt函数，所以常对象X只能调用常成员函数has而不能调用set。
```

It's nonsense to make the salary mutable; you're just making it possible for code that gets a constant object to mess with the salary. If the employee is constant, you shouldn't be messing with his salary.

那么，如果你想让员工的姓名和身份证维持 const，而不是工资呢？好吧，就这么说吧！

```c++
class Employee {
private:
    const string _name;
    const string _id;
    double _salary;
public:
    Employee(string name = "No Name", string id = "000-00-0000", double salary = 0) : _name(name), _id(id) { _salary = salary; }
    string getName() const { return _name; }
    string getid() const { return _id; }
    double getSalary() const { return _salary; }
    void setSalary(double salary) { _salary = salary; }
    void promote(double salary) { _salary = salary; }
};
```

现在它们是恒定的。当然，这意味着您只能在构造函数中设置它们。

所以，如果上述疯狂不是 mutable 的目的，那它是为了什么？这里有一个微妙的例子：mutable 是指一个对象在逻辑上是常量，但实际上需要改变的情况。这些案例很少，但确实存在。

> mutable is for the case where an object is logically constant, but in practice needs to change.

这是一个示例：您有一个常量对象，但是出于调试目的，想要跟踪在其上调用常量方法的频率。从逻辑上讲，您没有更改对象。请注意，如果您是基于可变变量在程序中进行决策，则几乎可以肯定您违反了逻辑常数，需要重新考虑。

```c++
class Employee {
private:
    string _name;
    mutable int _access_count;
public:
    Employee(const string& name) : _name(name), _access_count(0) { }
    void set_name(const string& name) { _name = name; }
    string get_name() const {
        _access_count++;
        return _name;
    }
    int get_access_count() const { return _access_count; }
};
```

作为一个更复杂的示例，您可能希望缓存代价高昂的操作的结果：

```c++
class MathObject {
private:
    mutable bool pi_cached;
    mutable double pi;
public:
    MathObject() : pi_cached(false) { }
    double pi() const {
        if (!pi_cached) {
            /* This is an insanely slow way to calculate pi. */
            pi = 4;
            for (long step = 3; step < 1000000000; step += 4)
                pi += ((-4.0 / (double)step) + (4.0 / ((double)step + 2)));
            pi_cached = true;
        }
        return pi;
    }
};
```

Now we don't calculate pi until someone asks for it, but when they do we cache the result, which is good because we're calculating it in a really slow and stupid way. Logically the function is still const (pi isn't about to change).

Ultimately you almost certainly do not need mutable at any given moment. I've gone years between wanting the mutable keyword. If you think you need mutable, think twice. Be sure that the object will still be logically constant, even as its internals change.

## 其它

**成员函数定义后面加 const 是什么意思？**

1. c++的一个机制，让该函数的权限为只读，禁止改变成员变量的值。
2. 同时，如果一个对象为 const，它只有权利调用 const 函数，因为成员变量不能改变。

**C++中的 mutable 存储类说明符**

auto、register、static 和 extern 是 C 中的存储类说明符。typedef 在 C 中也被认为是存储类说明符。C++支持所有这些存储类说明符。此外 C++还添加了一个重要的存储类说明符，名为 mutable。

**有什么是需要 mutable 的？**

有时，即使您不希望一个函数更新类或结构体的其他成员，也需要通过 const 函数来修改类或结构体的一个或多个数据成员。使用 mutable 关键字可以轻松地执行此任务。

关键字 mutable 主要用于允许修改 const 对象的特定数据成员。当我们将函数声明为 const 时，传递给函数的 this 指针就变成了 const。向变量添加 mutable 允许常量指针更改成员。

## 参考资料

http://www.highprogrammer.com/alan/rants/mutable.html#aboutbroken

## 堆栈溢出

C++ class methods have an implicit this parameter which comes before all the explicit ones. So a function declared within a class like this:

```c++
class C {
    void f(int x);
};
```

You can imagine really looks like this:

```c++
void f(C* this, int x);
```

Now, if you declare it this way:

```c++
void f(int x) const;
```

It's as if you wrote this:

```c++
void f(const C* this, int x);
```
