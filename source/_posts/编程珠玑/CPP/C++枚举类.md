---
title: C++枚举类
abbrlink: ba489a63
categories:
    - 编程珠玑
    - CPP
tags:
    - 语法
date: 2021-05-21 22:52:53
---

C++ 中的枚举类型继承于 C 语言。就像其他从 C 语言继承过来的很多特性一样，C++ 枚举也有缺点，这其中最显著的莫过于作用域问题：在枚举类型中定义的常量，属于定义枚举的作用域，而不属于这个枚举类型。例如下面的示例：

```c++
enum FileAccess {
    Read = 0x1,
    Write = 0x2,
};

FileAccess access = ::Read; // 正确
FileAccess access = FileAccess::Read; // 错误
```

C++ 枚举的这个特点对于习惯面向对象和作用域概念的人来说是不可接受的。首先，`FileAccess::Read` 显然更加符合程序员的直觉，因为上面的枚举定义理应等价于如下的定义（实际上，.NET 中的枚举类型便是如此实现的）：

```c++
class FileAccess {
    static const int Read = 0x1;
    static const int Write = 0x2;
};
```

其次，这导致我们无法在同一个作用域中定义两个同样名称的枚举值。也就是说，以下的代码是编译错误：

```c++
enum FileAccess {
    Read = 0x1,
    Write = 0x2,
};

enum FileShare {
    Read = 0x1, // 重定义
    Write = 0x2, // 重定义
};
```

如果这一点没有让你恼怒过的话，你可能还没写过多少 C++ 代码。实际上，在最新的 C++ 0X 标准草案中就有关于枚举作用域问题的提案，但最终的解决方案会是怎样的就无法未卜先知了，毕竟对于像 C++ 这样使用广泛的语言来说，任何特性的增删和修改都必须十分小心谨慎。枚举中的重定义是这样的现象：第一个枚举列表里的成员和第二个枚举列表的成员可以有相同的值（都是从每次枚举第一个为 0 开始往后分配），但不能有相同的名字。

以上是无作用域枚举。本文主要讲有作用域枚举。

虽然枚举类型是 C++ 中不同的类型，但它们不是类型安全的，在某些情况下，允许你做一些没有意义的事情。考虑以下情况：

```c++
#include <iostream>

int main () {
    enum Color {
        color_red,
        color_blue
    };

    enum Fruit {
        fruit_banana,
        fruit_apple
    };

    Color color { color_red };
    // C26812 枚举类型 “main::Color” 未设定范围。
    // 相比于 "enum"，首选 "enum class" (Enum.3)。
    Fruit fruit { fruit_banana };

    if (color == fruit)
        std::cout << "color and fruit are equal\n";
    else
        std::cout << "color and fruit are not equal\n";

    return 0;
}
```

输出

```
color and fruit are equal
```

当 C++ 比较颜色和水果时，它隐式地将颜色和水果转换成整数，并比较整数。由于 color 和 fruit 都被设置为计算值为 0 的枚举数据，这意味着在上面的示例中，color 将等于 fruit。这绝对不是期望的，因为颜色和水果是从不同的枚举，是不打算进行比较！对于标准枚举数据，无法阻止比较不同枚举的枚举数据。

C++ 11 定义了一个新概念，即枚举类（也称为范围枚举），它使枚举都具有强类型和强范围。要生成 enum 类，我们在 enum 关键字之后使用关键字 class。举个例子：

```c++
#include <iostream>

int main () {
    enum class Color {
        red, //red is inside the scope of Color
        blue
    };

    enum class Fruit {
        banana, //banana is inside the scope of Fruit
        apple
    };

    Color color { Color::red }; //note: red is not directly accessible any more, we have to use Color::red
    Fruit fruit { Fruit::banana }; //note: banana is not directly accessible any more, we have to use Fruit::banana

    if (color == fruit) // 编译错误，因为编译器不知道怎么比较不同类型的 Color 和 Fruit
        std::cout << "color and fruit are equal\n";
    else
        std::cout << "color and fruit are not equal\n";

    return 0;
}
```

对于普通枚举，枚举数据与枚举本身放在同一范围内，因此通常可以直接访问枚举数据（例如 red）。但是，对于枚举类，强作用域规则意味着所有枚举数据都被视为枚举的一部分，因此必须使用范围限定符来访问枚举数据（例如 Color::red）。这有助于减少名称污染和名称冲突的可能性。

因为枚举器是枚举类的一部分，所以不需要在枚举器名称前加前缀（例如，可以将它们命名为 “red” 而不是 “color_red”，因为 color::color_red 是多余的）。

强类型规则意味着每个枚举类都被认为是唯一的类型。这意味着编译器不会隐式比较来自不同枚举的枚举数据。如果您尝试这样做，编译器将抛出一个错误，如上面的示例所示。

但是，请注意，您仍然可以比较同一枚举类中的枚举数据（因为它们的类型相同）：

```c++
#include <iostream>

int main () {
    enum class Color {
        red,
        blue
    };

    Color color { Color::red };

    if (color == Color::red) //this is okay
        std::cout << "The color is red!\n";
    else if (color == Color::blue)
        std::cout << "The color is blue!\n";

    return 0;
}
```

对于枚举类，编译器将不再隐式地将枚举数值转换为整数。这基本上是件好事。然而，偶尔也有这样做有用的情况。在这些情况下，您可以使用静态转换为 int，将枚举类枚举数显式转换为整数：

```c++
#include <iostream>

int main () {
    enum class Color {
        red,
        blue
    };

    Color color { Color::blue };

    std::cout << color; //won't work, because there's no implicit conversion to int
    std::cout << static_cast<int>(color); //will print 1

    return 0;
}
```

没有什么理由使用普通枚举类型而不是枚举类。

注意，类关键字，以及静态关键字，是 C++ 语言中最重载的关键字之一，并且可以根据上下文而具有不同的含义。虽然 EnUM 类使用类关键字，但它们在传统 C++ 意义上并不被认为是 “类”。我们稍后会讲到实际的课程。

另外，万一您遇到它，“enum struct” 等同于 “enum class”。但这种用法并不推荐，也不常用。
