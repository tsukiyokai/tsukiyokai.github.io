---
title: C++中的static关键字
abbrlink: c39717db
categories:
  - 编程珠玑
  - CPP
tags:
  - 语法
date: 2021-05-25 00:25:17
---

static 是 C++ 中的关键字，用以赋予元素特殊的性质。静态元素在程序生存期内仅在静态存储区域中分配一次存储。而且它们的作用范围一直到程序生存期。static 关键字可以用于以下情况：

1. Static variable in functions
2. Static Class Objects
3. Static member Variable in class
4. Static Methods in class

## Static Variables inside Functions

静态变量在函数中使用时只初始化一次，然后即使通过函数调用它们也会保持值。静态变量存储在静态存储区，而不是堆栈中。

```c++
void counter() {
    static int count = 0; // cnt具有文件作用域
    cout << count++;
}

int main() {
    for (int i = 0; i < 5; i++)
        counter();
}
```

OUTPUT

```
01234
```

让我们在不使用静态关键字的情况下使用相同程序的输出。

```c++
void counter() {
    int count = 0; // cnt具有块作用域
    cout << count++;
}

int main() {
    for (int i = 0; i < 5; i++)
        counter();
}
```

OUTPUT

```
00000
```

如果我们不使用 static 关键字，那么每次调用 counter()函数时，变量 count 都会重新初始化，而在 counter()函数结束时，变量 count 会被销毁。但是，如果我们将其设为静态，则一旦初始化的 count 就会一直作用到 main()函数的结尾，并且它也将通过函数调用来携带其值。

## Static Class Objects

静态关键字对于类对象也以相同的方式起作用。声明为静态的对象被分配到静态存储区中，并且其作用域一直到程序结束。

静态对象也使用其他普通对象一样的构造函数进行初始化。使用 static 关键字分配为零仅适用于原始数据类型，不适用于用户定义的数据类型。

```c++
class Abc {
    int i = 0;
public:
    Abc() { cout << "constructor"; }
    ~Abc() { cout << "destructor"; }
};

void f() { static Abc obj; }

int main() {
    {
        f();
    }
    cout << "END";
}
```

OUTPUT

```
constructorENDdestructor请按任意键继续. . .
```

不适用静态关键字的情况

```c++
class Abc {
    int i = 0;
public:
    Abc() { cout << "constructor"; }
    ~Abc() { cout << "destructor"; }
};

void f() { Abc obj; }

int main() {
    {
        f();
    }
    cout << "END";
}
```

OUTPUT

```
constructordestructorEND请按任意键继续. . .
```

## 静态数据成员

类的静态数据成员是所有对象共享的那些成员。静态数据成员只有一个存储空间，不能像其他非静态数据成员一样作为每个对象的单独副本使用。

静态成员变量（数据成员）不使用构造函数初始化，因为它们不依赖于对象初始化。

此外，必须在类外部始终显式初始化它。如果未初始化，链接器将给出错误。

```c++
class X {
public:
    static int i;
    X()
    {
        // construtor
    };
};

int X::i = 1;

int main() {
    X obj;
    cout << obj.i; // prints value of i
}
```

一旦定义了静态数据成员，用户就不能重新定义它。不过，可以对它执行算术运算。

## 静态成员函数

这些函数对整个类有用，而不是对类的特定对象起作用。

可以使用对象和`.`运算符来调用它。但是，使用类名和作用域解析运算符`::`来调用静态成员函数更为典型。

```c++
class X {
public:
    static void f()
    {
        // statement
    }
};

int main() {
    X::f(); // calling member function directly with class name
}
```

这些函数不能访问普通数据成员和成员函数，只能访问静态数据成员和静态成员函数。

它没有任何`this`关键字，这就是它无法访问普通成员的原因。

**参考资料**

https://www.studytonight.com/cpp/static-keyword.php
