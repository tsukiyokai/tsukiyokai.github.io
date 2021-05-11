---
title: gfg-冒泡排序
abbrlink: 3ab69650
categories:
  - 编程珠玑
  - 算法分析
tags:
  - 排序
date: 2021-05-01 22:16:44
---

![](https://upload.wikimedia.org/wikipedia/commons/3/37/Bubble_sort_animation.gif)

冒泡排序1

```c++
#include <iostream>
#include <vector>
using namespace std;

void bubbleSort(vector<int>& arr) {
    size_t N = arr.size();
    for (size_t i = 0; i < N - 1; i++)
        for (size_t j = 0; j < N - 1 - i; j++)
            if (arr[j] > arr[j + 1]) swap(arr[j], arr[j + 1]);
}

void printArray(vector<int>& arr) {
    for (auto& i : arr)
        cout << i << '\t';
    cout << endl;
}

int main() {
    vector<int> arr = { 64, 34, 25, 12, 22, 11, 90 };
    cout << "冒泡排序前: ";
    printArray(arr);
    bubbleSort(arr);
    cout << "冒泡排序后: ";
    printArray(arr);

    return 0;
}
```

备注
如果传入数组，比如int arr[]，就已经相当于传地址了，不是传参，所以可以原地修改。
而如果传入容器`vector<int>`，就一定要记得写成传引用。不然就成传引用了，不能原地修改了。

冒泡排序2

上面的排序中，哪怕对初始有序的数组排序，也始终持有n^2的时间复杂度。
我们希望算法少做无用功。

当某趟排序中，只有比较，没有交换，说明此时已经有序了，后面的循环部分就不需要再继续下去。

只更改上面程序中的bubbleSort函数体。

```c++
void bubbleSort(vector<int>& arr) {
    size_t N = arr.size();
    bool swapped;
    for (size_t i = 0; i < N - 1; i++) {
        swapped = false;
        for (size_t j = 0; j < N - i - 1; j++) {
            if (arr[j] > arr[j + 1]) {
                swap(arr[j], arr[j + 1]);
                swapped = true;
            }
        }
        if (!swapped) break;
    }
}
```

现在的最差和平均时间复杂度都是(n^2)，最好时间复杂度是(1)，即数组已经排序的情况。

应用和变体

冒泡是最简单的排序算法，所以没什么性能优势。它一般用来引入排序算法的概念。但它真的没用吗？
其实还是有点用的。
In computer graphics bubble sort is popular for its capability to detect a very small error (like swap of just two elements) in almost-sorted arrays and fix it with just linear complexity (2n). For example, it is used in a polygon filling algorithm, where bounding lines are sorted by their x coordinate at a specific scan line (a line parallel to the x axis) and with incrementing y their order changes (two elements are swapped) only at intersections of two lines. Bubble sort is a stable sort algorithm, like insertion sort.

Variations
Odd–even sort is a parallel version of bubble sort, for message passing systems.
Passes can be from right to left, rather than left to right. This is more efficient for lists with unsorted items added to the end.
Cocktail shaker sort alternates leftwards and rightwards passes.

助记码，来自中文维基：

```c++
i∈[0,N-1)               //循环N-1遍
    j∈[0,N-1-i)         //每遍循环要处理的无序部分
        swap(j,j+1)     //两两排序（升序/降序）
```

示意图

![](https://upload.wikimedia.org/wikipedia/commons/6/6e/%E5%86%92%E6%B3%A1%E6%8E%92%E5%BA%8F.jpg)