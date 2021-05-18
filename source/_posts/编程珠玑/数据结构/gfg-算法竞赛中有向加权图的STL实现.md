---
title: gfg-算法竞赛中有向加权图的STL实现
abbrlink: 2f46aa37
categories:
  - 编程珠玑
  - 数据结构
tags:
  - 图
date: 2021-05-02 14:15:51
---

我们同时用两个 STL 容器来表示图。
vector：序列容器。用它存储所有顶点的邻接表。用顶点号作为这个向量的索引。
pair：存储一对元素的简单容器。用来存储相邻的顶点号和连接到相邻顶点的边的权重。

```c++
#include<iostream>
#include<vector>
using namespace std;

void addEdge(vector<pair<int, int>> adj[], int u, int v, int w) {
    adj[u].push_back(make_pair(v, w));
}

void printGraph(vector<pair<int, int>> adj[], int V) {
    int v, w;
    for (int u = 0; u < V; u++) {
        cout << "顶点 " << u << " 可以指向 \n";
        for (auto it = adj[u].begin(); it != adj[u].end(); it++) {
            v = it->first;
            w = it->second;
            cout << "\t顶点 " << v << "，其权重为 " << w << "\n";
        }
        cout << "\n";
    }
}

int main() {
    int V = 5;
    vector<pair<int, int>>* adj = new vector<pair<int, int>>[V];
    addEdge(adj, 0, 1, 10);
    addEdge(adj, 0, 4, 20);
    addEdge(adj, 1, 2, 30);
    addEdge(adj, 1, 3, 40);
    addEdge(adj, 1, 4, 50);
    addEdge(adj, 2, 3, 60);
    addEdge(adj, 3, 4, 70);
    printGraph(adj, V);
    return 0;
}
```
