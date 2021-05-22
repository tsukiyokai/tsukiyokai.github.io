---
title: C++标准输入输出
abbrlink: dca56101
categories:
  - 编程珠玑
  - CPP
tags:
  - STL
date: 2021-04-13 14:59:55
---

C++的 IO 发生在流中，流是字节序列。
如果字节流是从设备（如键盘、磁盘驱动器、网络连接等）流向内存，这叫做输入操作。
如果字节流是从内存流向设备（如显示屏、打印机、磁盘驱动器、网络连接等），这叫做输出操作。

## cin

cin 在头文件`<iostream>`中。
cin 的字面意思：c=character，in=input。cin=字符输入。

### cin 与提取运算符

cin 对象可以与提取运算符>>协同使用。

插入运算符（Insertion operator）：<<
提取运算符（Extraction operator）：>>

**工作原理**

1.cin 对象与提取运算符>>一起使用以接收字符流。

2.cin 函数从输入缓冲区中取数据而非直接保存键盘输入。

cin 建有一个缓冲区，即输入缓冲区。一次输入过程是这样的，当一次键盘输入结束时会将输入的数据存入输入缓冲区，而 cin 函数直接从输入缓冲区中取数据。正因为 cin 函数是直接从缓冲区取数据的，所以有时候当缓冲区中有残留数据时，cin 函数会直接取得这些残留数据而不会请求键盘输入，这就是为什么有时会出现输入语句失效的原因。

例如当我们输入一些数据按下回车时，这些数据会被第一条输入语句读入，但有一些函数却不会把这个回车符读入并舍弃掉（比如 gets)，这时第二条输入语句便会直接读取到这个回车符从而认定已经完成了输入直接跳过了输入语句。

缓冲区有残留数据导致跳过键盘输入的案例：

```c++
#include <iostream>
using namespace std;
int main() {
    string str1, str2;
    cin >> str1;
    cout << str1;
    cin >> str2;
    cout << str2;
    return 0;
}
```

分析：第一次输入 aaa bbb，第一次输出为 aaa 并舍弃使第一次输入终止的空格符。第二次输入时因为缓冲区有残留数据所以 cin 不从键盘读入而是直接从缓冲区读入，因此不会请求用户键盘输入，表面上就出现了输入语句失效的现象，实际上这是由 cin 的工作原理所决定的，第二次输出 bbb。

3.`cin >>`从缓冲区接收字符流时，遇 Space、Tab、Enter 就结束，并且丢弃缓冲区中导致输入结束的结束符（空格、制表、换行）。例如：

```
input: aaabbbccc
output: aaabbbccc

input: aaa bbb ccc
output: aaa
```

分析：aaa bbb ccc 进入缓冲区，cin>>从缓冲区接收字符流 aaa，然后遇到第一个空格使 cin>>行为中止，于是舍弃这个空格，完成 cin>>行为。下一次从缓冲区中读取数据时接收空格后面的 bbb，然后遇到并舍弃第二个空格。

4.提取运算符>>可以被多次使用以连续接收多个输入，例如：

```c++
string name;
int age;
cin >> name >> age;
```

分析：反正缓冲区中有残留数据时键盘输入会被跳过，索性直接连续输入，让电脑自己从缓冲区读入并断句。不同对象之间的输入用空格分开，之后 cin>>读缓冲区时会自动断句并舍弃空格。

### cin 与成员函数

#### cin.get()

cin.get(数组名,长度,结束符)

其中结束符为可选参数，读入的字符个数最多为长度-1 个，结束符规定结束字符串读取的字符，默认为 Enter。

1.读取单个字符的情况

若要读取一个字符，直接`cin.get(char ch);`或`ch=cin.get();`即可，二者是等价的。
输入结束条件：按下 Enter
对结束符的处理：不丢弃缓冲区中的 Enter

例如：

```c++
#include <iostream>
using namespace std;
int main()
{
    char c1, c2;
    cin.get(c1);
    cin.get(c2);
    cout << c1 << " " << c2 << endl;
    cout << static_cast<int>(c1) << " " << static_cast<int>(c2) << endl;
    return 0;
}
```

测试一

```
a
a

97 10
请按任意键继续. . .
```

分析：'a'的 ASCII 值为 97，'\n'的 ASCII 值为 10。

本来输入 a 后换行是为了准备输入第二个字符，发现似乎直接跳过了第二个 get，只执行了一次从键盘输入，显然第一个字符变量取的'a'，第二个变量取的是'Enter'(ASCII 值为 10)。这是因为 get()函数不丢弃上次输入结束时的 Enter 字符，所以第一次输入结束时缓冲区中残留的是上次输入结束时的 Enter 字符！

再次理清一点：get 并没有直接把 Enter 作为第二个字符读入，而是因为，作为第一个字符变量结束条件的 Enter 没有被 cin.get()丢弃，得以继续留在缓冲区中，所以下一次输入时就能读到缓冲区头部的残留 Enter。

~~如果是 cin.get()直接把 Enter 当成第二个字符，你会发现字符'a'和字符'\n'之间是没有能作为断句依据的其它字符的，那 Enter"直接"作为第二个字符也就不成立了。~~理解错了，cin.get()能够正确断句，因为一个字符变量只能存一个字符，就算两个字符之间什么也没有，也能正确分配输入。

测试二

```
a b
a
97 32
请按任意键继续. . .
```

分析：'a'的 ASCII 值为 97，' '的 ASCII 值为 32。原因同上，没有丢弃 Space 字符。

测试三

```
ab
a b
97 98
请按任意键继续. . .
```

分析：输入输出符合预期。

2.读取字符串的情况

输入结束条件：默认为 Enter 键，因此可接受空格和 Tab 键，可在第三个参数上自定义结束符
对结束符处理：丢弃缓冲区中的 Enter

```c++
#include <iostream>
using namespace std;
int main() {
    char ch, a[20];
    cin.get(a, 5, 'd');
    cin >> ch;
    cout << a << endl;
    cout << ch << endl;
    return 0;
}
```

测试一

```
12345
1234
5
请按任意键继续. . .
```

分析：12345 进缓冲区，cin.get()读走 5-1=4 个，剩'5'残留在缓冲区。
第二次输入不从键盘读取，直接取走'5'，所以打印的是字符'5'。

测试二

```
12d45
12
d
请按任意键继续. . .
```

分析：12d45 进缓冲区，cin.get()准备读走 4 个，读到'd'时发现 d 是自定义的结束符，于是 cin.get()实际读走 12。
第二次输出什么呢？输出残留在缓冲区中的第一个字符。输出 d 还是 4 呢？取决于自定义的结束符是否被丢弃。
实际输出的是'd'，说明如果是自定义结束符，则不丢弃缓冲区中的结束符。而如果没自定义，默认使用的是 Enter，则丢弃换行符。

#### cin.getline()

cin.getline(数组名,长度,结束符)

首先明确一点，在 C++中 cin.getline()和 getline()是两码事。cin.getline()属于 istream 流，使用前需包含`#include<iostream>`；而 getline()属于 string 流，使用前需包含`#include<string>`。

cin.getline()用于接收一个字符串，可以接收空格并输出，比如长度 N=5 时接收 5 个字符到字符串中，其中最后一个为'\0'，所以只看到 4 个字符输出。

cin.getline()可以接收空格并输出！
cin.getline()可以接收空格并输出！
cin.getline()可以接收空格并输出！

cin.getline(数组名,长度,结束符)大体与 cin.get()相似。区别在于：cin.get()当输入的字符串超长时，不会引起 cin 函数的错误，后面的 cin 操作会继续执行，只是直接从缓冲区中取数据。而 cin.getline()当输入超长时，会引起 cin 函数的错误，后面的 cin 操作将不再执行。
注意，1.这里的输入超长指的是用户键盘的输入超过了 cin.getline()计划从缓冲区取走数据的长度。2.后面的 cin 操作不再执行指的是该 cin 下面的其它 cin 不再执行了，不是从这次 cin 开始后面的程序崩溃了。

```c++
#include <iostream>
using namespace std;
int main() {
    char ch, a[20];
    cin.getline(a, 5);
    cin >> ch;
    cout << a << endl;
    cout << ch << endl;
    return 0;
}
```

测试一

```
abcd
e
abcd
e
请按任意键继续. . .
```

测试二

```
abcde
abcd

请按任意键继续. . .
```

分析：与 cin.get()比较发现，这里的 ch 并没有读取缓冲区中的 e，而是返回了无效结果，这里其实 cin>>ch 语句没有执行，是因为 cin 出错了！cin 的错误处理以后介绍。

测试三

```
ab cde
ab c

请按任意键继续. . .
```

分析：ab c 进字符数组 a[]，同时因为输入长度 len=6 超出上限 4，所以产生错误，第二个 cin 不再执行，返回无效结果。

#### getline()

`getline(cin,str);`的意义：从输入流中提取一行字符存入字符串 str。

如果程序中既有 cin>>又有 getline()时，需要注意的是：在 cin>>输入流完成之后，getline()之前，需要通过

```c++
mystr = "\n";
getline(cin, mystr);
```

的方式来将换行符作为输入流 cin 以清除缓存。否则在控制台上就不会出现 getline()的输入提示，而直接跳过，因为程序默认地将之前的变量作为输入流。

完整的例子看下面一段程序：

```c++
#include<iostream>
#include<string>
using namespace std;

int main() {
    string mystr;
    cout << "What's your name? ";
    getline(cin, mystr);
    cout << "Hello," << mystr << ".\n";

    int age;
    cout << "Please enter an integer value as your age: ";
    cin >> age;
    cout << "Your ager is: " << age << ".\n";

    char sex;
    cout << "Please enter a F or M as your sex: ";
    cin >> sex;
    cout << "Your sex is: " << sex << endl;

    cout << "What's your favorite team? ";
    mystr = "\n";
    getline(cin, mystr);
    getline(cin, mystr);
    cout << "I like " << mystr << ".\n";

    return 0;
}
```

补充：
Windows 下命令行模拟文件结束符 EOF 的方式为 Ctrl+z，Linux 为 Ctrl+d。按下这两个键，就相当于对 eofbit 进行了置位。

### cin 的条件状态

使用 cin 读取键盘输入时难免会发生错误，比如上面说过的 cin.getline()发生输入超长导致后续 cin 不再执行。出错时，cin 将设置不同的条件状态（condition state）以传达自身信息，条件状态位主要有：

```c++
goodbit(0x0)：无错误
eofbit(0x1)：已到达文件尾
failbit(0x2)：非致命的输入输出错误，可以挽回
badbit(0x4)：致命的输入输出错误，无法挽回
```

以上状态的官方叫法是 error state flags，即错误状态标记。虽然有的看起来并不是错误，比如 goodbit 和 eofbit，但就是这么叫的。可以这么理解，good 是一种错误状态，它表示的错误状态是“无错误的状态”。eof 也同理，因为到达文件尾也可以看作是一种错误状态。
与其对应的使设置、读取、判断条件状态的成员函数。成员函数主要有：

```c++
s.good()：若流s的goodbit置位，则返回true
s.eof()：若流s的eofbit置位，则返回true
s.fail()：若流s的failbit置位，则返回true
s.bad()：若流s的badbit置位，则返回true

s.clear(flags)：清空当前状态,然后把状态设置为flags，返回void
s.setstate(flags)：不清空当前状态，设置给定的状态flags，返回void
s.rdstate()：返回流s的当前条件状态，返回值类型为ios_base::iostate
```

注：置位就是置 1，即为真。搜了一下好像是嵌入式里的叫法。

举例子来说明一下。这个例子因输入缓冲区未读取完造成状态位 failbit 被置位，后通过 clear()成功复位。

```c++
#include <iostream>
using namespace std;

int main() {
    char ch, str[20];
    cin.getline(str, 5);
    cout << "goodbit:" << cin.good() << endl;
    cin.clear();
    cout << "goodbit:" << cin.good() << endl;
    cin >> ch;
    cout << "str:" << str << endl;
    cout << "ch:" << ch << endl;
    return 0;
}
```

运行结果：

```
abcde
goodbit:0
goodbit:1
str:abcd
ch:e
Press any key to continue . . .
```

这个例子解决了 cin.getline()里所讲的输入超长问题。

可以看出，因输入缓冲区未读取完造成的输入异常，通过 clear()可以清除输入流对象 cin 的异常状态，从而不影响后面的 cin>>ch 从输入缓冲区读取数据。
因为 cin.getline()读取之后，输入缓冲区中残留的字符串是：5\n，所以 cin>>ch 将 5 读取并存入 ch，打印输入并输出 5。

如果将 cin.clear()一行注释掉，则 cin>>ch;将读取失败，ch 为空。
cin.clear()等同于`cin.clear(ios::goodbit);`。因为 cin.clear()的默认参数是`ios::goodbit`，所以不需显示传递，故而你最常看到的就是 cin.clear()。

### cin 清空输入缓冲区

上一次的输入操作很有可能使输入缓冲区中残留数据，影响下一次输入。
如何解决这个问题呢？我们自然想到在进行输入时对输入缓冲区进行清空和状态条件的复位。条件状态的复位使用 clear()，清空输入缓冲区应该使用 cin.ignore()。

函数原型：
istream& ignore (streamsize n = 1, int delim = EOF);
delim 表示分隔符、划界字符、终止字符。
此函数的作用是跳过输入流中的 n 个字符，或在遇到指定的终止字符时提前结束（此时跳过包括终止字符在内的若干字符）。哪个条件先满足就按哪个执行。因为两个参数都有默认值，所以 cin.ignore()就等效于 cin.ignore(1, EOF)，即跳过一个字符。
该函数常用于跳过输入中的无用部分，以便提取有用的部分。

使用示例：

```c++
#include <iostream>
using namespace std;

int main() {
    char str1[20] = { NULL }, str2[20] = { NULL };
    cin.getline(str1, 5);
    cin.clear();
    cin.ignore(numeric_limits<std::streamsize>::max(), '\n');
    cin.getline(str2, 20);
    cout << "str1:" << str1 << endl;
    cout << "str2:" << str2 << endl;
    return 0;
}
```

运行结果：

```
12345
success
str1:1234
str2:success
Press any key to continue . . .
```

分析：

（1）程序中使用 cin.ignore 清空了输入缓冲区的当前行，使上次的输入残留下的数据没有影响到下一次的输入，这就是 ignore()函数的主要作用。其中，`numeric_limits<std::streamsize>::max()`是`<limits>`头文件定义的流使用的最大值，你也可以用一个足够大的整数代替它。如果想清空输入缓冲区的所有内容，去掉换行符即可，即：
`cin.ignore(numeric_limits<std::streamsize>::max());`
这里要注意的是，如果缓冲区中没有 EOF(-1)，cin.ignore()会阻塞等待。如果在命令行，我们可以使用 Ctrl+Z 然后回车（Windows 命令行）或直接 Ctrl+D（Linux 命令行）输入 EOF。

（2）cin.ignore()；当输入缓冲区没有数据时，没法清空已经为空的缓冲区，此时也会阻塞等待数据的到来。

（3）请不要使用 cin.sync()来清空输入缓冲区，本人测试了一下，VC++和 GNU C++都不行，请使用 cin.ignore()。

## 参考资料

https://social.microsoft.com/Forums/zh-CN/c8ae82d8-18ed-42f1-aabf-e3c1de4f4d9f
