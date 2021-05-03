---
title: 竞争编程中STL的图形实现（无向无权图）
abbrlink: '827'
categories:
  - 编程珠玑
  - 数据结构
tags:
  - 图
date: 2021-05-02 13:03:00
---

下面的DFS基于图的邻接表表示

## 初始化

在VS中，下面构造邻接表的语句编译错误，因为VS要求`vector<int> adj[V];`表达式中必须含有常量值。

```c++
int V = 5;
vector<int> adj[V];
```

所以要用

```c++
int V = 5;
vector<int>* adj = new vector<int>[V];
```

## `vector<int> adj[]` 和 `vector<vector<int>> adj` 的区别

这个程序里用的是前者，我还第一次见到，在堆栈溢出上搜了一下，有一个比较好的回答：

`vector<int> adj[]` is an array of vectors.
`vector<vector<int>> adj` is a vector of vectors.

Using arrays are C-style coding, using vectors are C++-style coding.

When you want to work with a fixed number of std::vector elements, you can use `vector<int> adj[]`.
When you want to work with a dynamic array of std::vector, you can use `vector<vector<int>> adj`.

简单来说，因为这个程序里顶点数是固定的，最多会加几条边，
所以：`vector<int>* adj = new vector<int>[V];`中，邻接表的行数是固定的V，但是可以向后面无限拓展。
如果V不是固定的，就用vector of vectors，如果V是固定的，就用array of vectors。因为array是定长的，vector是变长的。

## 实现

```c++
// 使用STL的图的简单表示，用于编程竞赛。
#include<iostream>
#include<vector>
using namespace std;

// 在无向图中添加边的一个辅助函数。
void addEdge(vector<int> adj[], int u, int v) {
    adj[u].push_back(v);
    adj[v].push_back(u);
}

// 从给定顶点u递归地进行图DFS的一个辅助函数。
void DFSUtil(vector<int> adj[], int u, vector<bool>& visited) {
    cout << u << " ";
    visited[u] = true;
    for (size_t i = 0; i < adj[u].size(); i++)
        if (visited[adj[u][i]] == false)
            DFSUtil(adj, adj[u][i], visited);
}

// 此函数对所有未访问的顶点执行DFSUtil()。
void DFS(vector<int> adj[], int V) {
    vector<bool> visited(V, false);
    for (int u = 0; u < V; u++)
        if (visited[u] == false)
            DFSUtil(adj, u, visited);
    cout << endl;
}

int main() {
    int V = 5;
    vector<int>* adj = new vector<int>[V];
    addEdge(adj, 0, 1);
    addEdge(adj, 0, 4);
    addEdge(adj, 1, 2);
    addEdge(adj, 1, 3);
    addEdge(adj, 1, 4);
    addEdge(adj, 2, 3);
    addEdge(adj, 3, 4);
    DFS(adj, V);
    delete[]adj;
    return 0;
}
```