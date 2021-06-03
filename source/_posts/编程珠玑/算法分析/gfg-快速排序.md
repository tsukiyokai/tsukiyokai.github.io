---
title: gfg-快速排序
abbrlink: d1d00f7b
categories:
  - 编程珠玑
  - 算法分析
tags:
  - 排序
date: 2021-05-02 01:15:30
---

快排是典型的分治算法，其中 partition 是关键。分区的目标是：经过一趟排序后使基准元素落在最终位置，同时，满足 p 左边都小于 p 和 p 右边都大于 p 两个要求。

```
性能分析
平均时间复杂度 Θ(nlogn)
最坏时间复杂度 Θ(n^2)
最优时间复杂度 Θ(nlogn)
```

下面的快排要熟悉到信手拈来。

```c++
int partition(vector<int>& arr, int left, int right) {
    int pivot = arr[right];
    while (left < right) {
        while (left < right && arr[left] < pivot) left++;
        arr[right] = arr[left];
        while (left < right && arr[right] > pivot) right--;
        arr[left] = arr[right];
    }
    arr[left] = pivot;
    return left;
}

void quickSortu(vector<int>& arr, int low, int high) {
    if (low < high) {
        // p is partitioning index, arr[p] is now at right place
        // 最强之人已在阵中
        int p = partition(arr, low, high);
        quickSortu(arr, low, p - 1);
        quickSortu(arr, p + 1, high);
    }
}

void quickSort(vector<int>& arr) {
    size_t low = 0, high = arr.size() - 1;
    quickSortu(arr, low, high);
}
```

补充几个视频，曾经对我很有帮助

C 语言快速排序算法实现 - code_frank
https://www.bilibili.com/video/BV1nr4y1P7d6
45 种常用算法的 C++讲解
https://www.bilibili.com/video/BV13E411d75X
快速排序算法 - 秒懂算法
https://www.bilibili.com/video/BV1at411T75o
