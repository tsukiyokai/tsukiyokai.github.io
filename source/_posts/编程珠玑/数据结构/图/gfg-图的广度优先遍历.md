---
title: gfg-图的广度优先遍历
abbrlink: 3acb628c
categories:
  - 编程珠玑
  - 数据结构
tags:
  - 图
date: 2021-05-02 15:14:05
---
图的BFS和树的层序遍历差不多，但是要加个访问标记位，因为图可能有环，而树一定没有环，标记位可以避免再次访问已经访问过的顶点。

```c++
#include<iostream>
#include<vector>
#include<queue>
using namespace std;

class Graph {
    int V;
    vector<int>* adj;
public:
    Graph(int V);
    void addEdge(int v, int w);
    void BFS(int s);
};

Graph::Graph(int V) {
    this->V = V;
    adj = new vector<int>[V];
}

void Graph::addEdge(int v, int w) {
    adj[v].push_back(w);
}

void Graph::BFS(int s) {
    bool* visited = new bool[V];
    for (int i = 0; i < V; i++)
        visited[i] = false;

    queue<int> queue;
    visited[s] = true;
    queue.push(s);

    while (!queue.empty()) {
        s = queue.front();
        cout << s << " ";
        queue.pop();
        for (auto it = adj[s].begin(); it != adj[s].end(); ++it) {
            if (!visited[*it]) {
                visited[*it] = true;
                queue.push(*it);
            }
        }
    }
    cout << endl;
}

int main() {
    Graph graph(4);
    graph.addEdge(0, 1);
    graph.addEdge(0, 2);
    graph.addEdge(1, 2);
    graph.addEdge(2, 0);
    graph.addEdge(2, 3);
    graph.addEdge(3, 3);

    cout << "从顶点2开始的深度优先遍历如下：\n";
    graph.BFS(2);
    return 0;
}
```