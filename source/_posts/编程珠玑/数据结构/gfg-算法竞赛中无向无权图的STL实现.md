---
title: gfg-算法竞赛中无向无权图的STL实现
abbrlink: 9c1f087d
categories:
  - 编程珠玑
  - 数据结构
tags:
  - 图
date: 2021-05-02 13:03:00
---

```c++
#include<iostream>
#include<vector>
using namespace std;

void addEdge(vector<int> adj[], int u, int v) {
    adj[u].push_back(v);
    adj[v].push_back(u);
}

void DFSUtil(vector<int> adj[], int u, vector<bool>& visited) {
    cout << u << " ";
    visited[u] = true;
    for (size_t i = 0; i < adj[u].size(); i++)
        if (visited[adj[u][i]] == false)
            DFSUtil(adj, adj[u][i], visited);
}

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

```tex
vector<int> adj[] is an array of vectors.
vector<vector<int>> adj is a vector of vectors.

When you want to work with a fixed number of vector elements,
you can use vector<int> adj[].

When you want to work with a dynamic array of vector,
you can use vector<vector<int>> adj.
```
