---
title: HJ64 MP3光标位置
categories:
  - 小镇做题家
  - 华为机试
abbrlink: c8a39177
tags:
  - 数组
date: 2021-05-03 21:05:03
---

MP3 Player因为屏幕较小，显示歌曲列表的时候每屏只能显示几首歌曲，用户要通过上下键才能浏览所有的歌曲。为了简化处理，假设每屏只能显示4首歌曲，光标初始的位置为第1首歌。

现在要实现通过上下键控制光标移动来浏览歌曲列表，控制逻辑如下：

歌曲总数<=4的时候，不需要翻页，只是挪动光标位置。
光标在第一首歌曲上时，按Up键光标挪到最后一首歌曲；光标在最后一首歌曲时，按Down键光标挪到第一首歌曲。
其他情况下用户按Up键，光标挪到上一首歌曲；用户按Down键，光标挪到下一首歌曲。

歌曲总数大于4的时候（以一共有10首歌为例）：
特殊翻页：屏幕显示的是第一页（即显示第1 – 4首）时，光标在第一首歌曲上，用户按Up键后，屏幕要显示最后一页（即显示第7-10首歌），同时光标放到最后一首歌上。同样的，屏幕显示最后一页时，光标在最后一首歌曲上，用户按Down键，屏幕要显示第一页，光标挪到第一首歌上。
一般翻页：屏幕显示的不是第一页时，光标在当前屏幕显示的第一首歌曲时，用户按Up键后，屏幕从当前歌曲的上一首开始显示，光标也挪到上一首歌曲。光标当前屏幕的最后一首歌时的Down键处理也类似。
其他情况，不用翻页，只是挪动光标就行。

```c++
#include <iostream>
#include <string>

using namespace std;

int main() {
    int n;
    string order;
    while (cin >> n >> order) {
        int pos = 1, first = 1;
        if (n <= 4) {
            for (int i = 0; i < order.size(); i++) {
                if (pos == 1 && order[i] == 'U') pos = n;
                else if (pos == n && order[i] == 'D') pos = 1;
                else if (order[i] == 'U') pos--;
                else  pos++;
            }
            for (int i = 1; i <= n; i++) cout << i << ' ';
            cout << '\n' << pos << '\n';
        }
        else {
            for (int i = 0; i < order.size(); i++) {
                if (first == 1 && pos == 1 && order[i] == 'U') { first = n - 3; pos = n; }
                else if (first == n - 3 && pos == n && order[i] == 'D') { first = 1; pos = 1; }
                else if (first != 1 && pos == first && order[i] == 'U') { first--; pos--; }
                else if (first != n - 3 && pos == first + 3 && order[i] == 'D') { first++; pos++; }
                else if (order[i] == 'U') pos--;
                else pos++;
            }
            for (int i = first; i <= first + 3; i++) cout << i << ' ';
            cout << '\n' << pos << '\n';
        }
    }
    return 0;
}
```

纯阅读理解题，不用总结啥规律，什么求余、循环啥的。只要ifelse够多，就能通过。保持冷静和思路清晰很重要。还有，要抓到关键，比如这个题里面，要把pos和first抽象出来，只要判断这两个记号的状态，就能分析出所有情况。因为一个屏幕内能容纳下的歌曲是固定的，所以不用额外维护一个last标记来指向屏幕下面的歌曲。