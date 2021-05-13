---
title: ACM模式下C++标准输入输出惯用法汇总
abbrlink: dc62c34d
categories:
  - 编程珠玑
  - C++
tags:
  - 语法
date: 2021-04-14 04:23:23
---

## 引言：从核心代码到ACM

现在主流的在线编程环境分为两种：核心代码模式和ACM模式。

核心代码模式顾名思义就是，测试用的数据已经放入容器里，你只负责写出核心逻辑，系统自动进行调用。LeetCode用的是这种。

而在ACM程序设计竞赛中，一道题目的所有测试数据是放在一个文本文件中，选手将一道题目的程序提交给评判系统运行，程序从该文件中读取测试数据，再把运行结果输出到另一个文本文件中。系统把输出文件与标准答案比对，来评判程序编写得正确与否。ACM现场赛采用的输入输出形式有三种：

1. 文件输入、标准输出；
2. 文件输入、文件输出；
3. 标准输入，标准输出。

所谓ACM模式就是自己构造输入，自己把要需要处理的容器填充好，OJ不会给你任何代码，包括include哪些文件都要自己写，最后再自己控制返回数据的格式。ACM竞赛、POJ和部分公司笔试采取这种模式。Web形式的ACM程序设计在线评判系统一般采用标准输入和标准输出，

从核心代码到ACM模式一般需要提前适应自己亲手处理输入输出的过程，但实际上ACM模式输入输出语句的模板化也比较严重，本文尝试对其惯用法进行汇总。

## 四种基本输入模式

### 一组输入数据

示例：整数求和
http://acm.njupt.edu.cn/acmhome/problemdetail.do?&method=showdetail&id=1001

```c++
#include<iostream>
using namespace std;
int main() {
    int a, b;
    cin >> a >> b;
    cout << a + b << endl;
    return 0;
}
```

### 多组输入数据：无限组，直到EOF

有的题目不指定输入多少组，也没有给出结束的条件，要求处理所有数据，这时用文件尾的EOF标记。好像EOF等于-1来着。

示例：A + B Problem (1)
http://acm.njupt.edu.cn/acmhome/problemdetail.do?&method=showdetail&id=1084

```c++
#include<iostream>
using namespace std;
int main() {
    int a, b;
    while (cin >> a >> b)
        cout << a + b << endl;
    return 0;
}
```

注：cin读入发生错误时返回0，否则返回cin的地址。

或者

```c++
while (scanf(_dates_) != EOF){
    ...
}
```

### 多组输入数据：无限组，直到某种结束标志

不说明多少组，以某特殊输入为结束标志。

示例：A + B Problem (2)
http://acm.njupt.edu.cn/acmhome/problemdetail.do?&method=showdetail&id=1085

这个题目是以`0 0`为标志代表输入结束。反过来想，只要a和b不同时为假，即至少有一个真，就维持输入状态。很容易写出循环条件为`while(cin>>a>>b&&(a||b))`。

```c++
#include<iostream>
using namespace std;
int main() {
    int a, b;
    while (cin >> a >> b && (a || b)) {
        cout << a + b << endl;
    }
    return 0;
}
```

### 多组输入数据：有限组，输入完就结束

开始输入一个N，接下来是N组数据

示例：A + B Problem (3)
http://acm.njupt.edu.cn/acmhome/problemdetail.do?&method=showdetail&id=1086

```c++
#include<iostream>
using namespace std;
int main() {
    int a, b, n;
    cin >> n;
    while (n--) {
        cin >> a >> b;
        cout << a + b << endl;
    }
    return 0;
}
```

## 三种字符串输入

### 每个字符串中不含空格、制表符及回车

这种情况使用scanf_s("%s", str, buffersize)是再好不过的了。比如，测试数据中只有两个字符串：abc def。要读入abc与def，可以这样写：

```c++
#include<iostream>
using namespace std;
int main() {
    char str[1000];
    scanf_s("%s", str, static_cast<unsigned>_countof(str));
    return 0;
}
```
知识点：

（1）scanf_s用法：在用VS2019进行C++编程时，输入函数要写成scanf_s。传统的scanf()在读取时不检查边界，所以可能会造成内存访问越界，比如分配了5字节的空间但是读入了10字节。多出来的部分会被写到别的空间上去。而在调用scanf_s时，必须提供一个数字以表明最多读取多少位字符。读取单个字符也需要限定长度，否则编译器会报错。

使用示范：
```c++
char s[10];
scanf_s("%s", s, (unsigned)_countof(s));
```

（2）_countof，Windows宏，用来计算一个静态分配的数组中的元素的个数用法为_countof(array)。另外，确保array是一个静态分配的数组，而不是一个指针。如果array是一个指针，在C语言中_countof会产生错误的结果；在C++中_countof会产生编译错误。

_countof和sizeof的区别：

```c++
#include<iostream>
using namespace std;
int main() {
    int arr[20], * p;
    printf("sizeof(arr) = %d bytes\n", sizeof(arr));
    printf("_countof(arr) = %d elements\n", _countof(arr));
    printf("%d\n", _countof(p));
    return 0;
}
```

运行结果：
```
sizeof(arr) = 80 bytes
_countof(arr) = 20 elements
请按任意键继续. . .
```

（3）The size parameter is of type unsigned, not size_t. Use a static cast to convert a size_t value to unsigned for 64-bit build configurations.

参考阅读：
https://docs.microsoft.com/zh-tw/cpp/c-runtime-library/reference/scanf-s-scanf-s-l-wscanf-s-wscanf-s-l?view=msvc-160

### 字符串中含有空格、制表符，但不含回车

对于这种情况，scanf_s("%s", str)无能为力，因为scanf_s用空格、制表符及回车作为字符串的分界符。对于一个含有空格、制表符及回车的字符串，如果用scanf_s("%s",str)来读，将读到若干个字符串，这个字符串被scanf_s分开了。可以用另外一个函数gets_s，gets_s函数用回车作为字符串的分界符。比如，有以下的一个字符串："Hello world!"。要读入这个字符串，这样写：

```c++
char str[1000];
gets_s(str);
```
gets_s返回NULL时表示出错或抵达end of file。

### 字符串中含有回车

这种情况下如果没有题目的说明，程序无法知道哪里是字符串的分界。则用scanf("%c",&ch)来读，一边读，一边判断分界条件是否满足，如果满足，则把当前读到的东西存到一个字符串中。

输入部分小结：

- 如果用string buf;来保存：getline(cin, buf);
- 如果用char buf[255];来保存：cin.getline(buf, 255);
- 多个字符串之间用一个或多个空格分隔：scanf("%s %s", str1, str2);
- 字符串之间用回车作分隔：gets(str1); gets(str2);
- 通常情况下，接受短字符用scanf，接受长字符用gets。
- getchar函数每次只接受一个字符，经常c = getchar()这样来使用。
- getline函数可以接受用户的输入的字符直到已达指定个数或者用户输入了特定的字符。
- C++的输入输出流用起来比较方便，但速度较C慢得多。在输入输出量巨大时，用C++可能超时，应改为采用C的输入输出。

## 输出

在初次接触ACM程序设计竞赛时，可能认为：样例中都是输入数据和输入数据在一起，输出结果和输出结果在一起，可能会开个数组，把每组的结果存起来，等输入完了再一起输出。当遇到不知有多少组测试数据的题，就难以处理了。其实在ACM程序设计竞赛中，输入数据和输出数据是分别在两个不同的文件中进行的，程序的输入和输出是相互独立的，所以读入一组数据就输出一组结果，跟先读入所有数据再输出所有的结果，效果是完全一样的。因此，每当处理完一组测试数据，就应当按题目要求进行相应的输出操作。而不必将所有结果储存起来一起输出。在处理输出时，一般要注意：每行输出均以回车符结束，包括最后一行。

几乎所有题目都是换行输出，而有的题目还要求空（去声）行输出。

### 关于空（平声）行

很多题目都要求在输出数据的恰当位置加空行。一个空行就是一个单独的"\n"。
这里，有的题目说：“After each test case, you should output one blank line”，而有的题目说：“Between each test case, you should ouput one blank line”。要注意After和Between的区别。
输出有不同的格式要求，如果多了或少了空行的话经常会出现Presentation Error，而且OJ很多时候还判断不出来输出格式错误，就简单的判为Wrong Answer，所以输出格式一定要注意。

示例：A + B Problem (4)

```c++
#include<iostream>
using namespace std;
int main() {
    int n, sum, a;
    while (cin >> n && n != 0) {
        sum = 0;
        while (n--) {
            cin >> a;
            sum += a;
        }
        cout << sum << endl;
        cout << endl;
    }
    return 0;
}
```

运行结果：
```
3
1
2
3
6

3
1 2 3
6

3
1 2 3 4
6
```
### 字符串输出后缀技巧

字符串要输出后面的一部分没必要重新搞一个，可以用以下方式：

```c++
cout << s + 2 << endl;
```

这样就会从s[2]开始输出。