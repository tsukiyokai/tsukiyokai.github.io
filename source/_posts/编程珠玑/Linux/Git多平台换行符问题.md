---
title: Git多平台换行符问题
abbrlink: acc4d763
categories:
  - 编程珠玑
  - Linux
date: 2021-05-27 00:47:02
---

**参考资料**

https://blog.csdn.net/ljheee/article/details/82946368
https://blog.csdn.net/qq_39994406/article/details/105723178?utm_medium=distribute.pc_relevant.none-task-blog-baidujs_title-0&spm=1001.2101.3001.4242
https://www.zhihu.com/question/50862500

**具体问题**

```powershell
12776@DESKTOP-81NVB8G MINGW64 ~/Documents/GITpractice/awesome_project (master)
$ git add README
warning: LF will be replaced by CRLF in README.
The file will have its original line endings in your working directory
```

**解决方案**

```powershell
$ git config --global core.autocrlf true
```

我稍微研究了一下，git config 文件貌似放在系统盘的 User 目录下面，也可以直接拿文本编辑器修改。
