---
title: gfg-插入排序
abbrlink: 96555fb2
categories:
  - 编程珠玑
  - 算法分析
tags:
  - 排序
date: 2021-05-01 22:54:43
---
![](https://upload.wikimedia.org/wikipedia/commons/0/0f/Insertion-sort-example-300px.gif)

插入排序可类比打扑克时整理手牌。算法从index=1开始（前面还有index=0），也就是从第二项开始。最差时间复杂度：O(n^2)，最好时间复杂度：O(n)。当元素数较少时，可以使用插入排序。当输入数组几乎有序时，只有很少的元素在完整的大数组中错放了，它也很有用。

```c++
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

void printArray(vector<int>& arr) {
    for (auto& i : arr)
        cout << i << '\t';
    cout << endl;
}

void insertionSort(vector<int>& arr) {
    size_t N = arr.size();
    size_t i, j;
    int key;
    for (i = 1; i != N; i++) {
        key = arr[i];
        j = i - 1;
        while (j >= 0 && key < arr[j]) {
            arr[j + 1] = arr[j];
            j--;
        }
        arr[j + 1] = key;
    }
}

int main() {
    vector<int> arr(10);
    srand(static_cast<unsigned>(time(0)));
    generate(arr.begin(), arr.end(), rand);
    cout << "排序前: ";
    printArray(arr);
    insertionSort(arr);
    cout << "排序后: ";
    printArray(arr);

    return 0;
}
```
