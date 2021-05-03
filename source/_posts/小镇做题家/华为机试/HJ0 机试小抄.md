---
title: HJ0 机试小抄
categories:
  - 小镇做题家
  - 华为机试
abbrlink: 69b5
date: 2021-05-02 15:22:00
---
## queue

```c++
#include<queue>

queue::push(); 进队
queue::pop(); 出队
queue::empty(); 判空
queue::back(); 队尾
queue::front(); 对头
queue::size(); 队长
```

## string

```c++
#include<string>

s.find(str)
在s中找子串str；
用s.find(str) == string::npos表示找不到这样的子串

s.find_first_not_of("lixing")
在目标串s中进行查找，返回第一个与"lixing"中任一字符都不匹配的元素的位置。

stoi(s)
不能把空串转成数字，会跳异常
string str = "1010";
int a = stoi(str, 0, 8); // a = 520
把str即1010从索引0开始到末尾的串视为8进制并转为10进制整数，得8^3+8^1=520
一般还是用单参数得比较多，而且第二个位置得0最好不要轻易改动
```

## set

```c++
#include<set>
set是一个内部自动有序且不含重复元素的容器。
set最主要的作用就是自动去重并按升序排序。
适用于需要去重但是又不方便直接开数组的情况。
```