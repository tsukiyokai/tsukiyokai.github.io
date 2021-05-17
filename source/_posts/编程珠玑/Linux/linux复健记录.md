---
title: linux复健记录
abbrlink: 4d4fc466
categories:
  - 编程珠玑
  - Linux
tags:
  - OS
date: 2021-05-14 16:13:03
---

> 最近开始 linux 复建，记点东西。

- **进入 ubt 子系统的图形界面**

```powershell
$ xfce4-session
```

- **获取包的更新信息并安装更新**

```powershell
$ sudo apt-get update && sudo apt-get upgrade
```

- **查看 ascii 表**

```powershell
$ man ascii
```

- **查看历史上的今天**

```powershell
$ calendar -t 1997.04.09
```

- **查看万年历**

```powershell
$ cal 1997
```

- **编译 cpp 源文件并将编译产生的输出文件命名为 -o 后面的内容**

```powershell
$ g++ lixing.cpp -o lixing
```

gcc = GNU Compiler Collection
g++ 是它的 C++ 版
`-o` 用来指明编译后所输出文件的名字

- **执行上一步中的输出文件**

```powershell
$ ./lixing
```

`./` 的意思是执行当前目录下的某个可执行文件

- **新建文件夹 test2**

```powershell
$ mkdir test2
```

- **切换到用户的根目录**

```powershell
$ cd
```

- **切换到系统根目录**

```powershell
$ cd /
```

- **打印当前路径**

```powershell
$ pwd
```

- **将 test1 重命名为 test2，可以是文件或文件夹**

```powershell
$ mv test1 test2
```

注意，mv 是 move 而非 remove，它除了重命名外还可以移动文件。直接把它的含义理解为 “搬家” 即可，用 mv 进行重命名的本质其实就是：把名为 test1 的源文件的全部内容搬家到名为 test2 的目标文件中。如果 test2 原本就存在则会被覆写。

- **在当前目录下创建一个名为 test.new 的新文件**

```powershell
$ touch test.new
```

这个 touch 关键词的命名真的很浪漫，让人想起来那副著名壁画《创造亚当》。程序员就像上帝，通过触碰就可以创造新的文件，颇有点石成金、妙笔生花之韵味。

{% asset_img Creación_de_Adán_(Miguel_Ángel).jpg %}

touch 还可以用來更新檔案的最後修改時間（如果檔案已经存在的話）。这个微小的变化是通过 `stat lixing.cpp` 命令来查看的。此用法只更新修改时间而不涉及文件内容。

- **在當前目錄產生一個內容為 “根目錄檔案列表結果” 且名为 test.ls 的文件**

```powershell
$ ls /> test.ls
```

讓我們解讀這個命令：“ls” 是 list 的意思 (下面我會再講)：“/” 應該知道吧？“>” 呢，是一個重導向功能，用來將命令的輸出結果產生檔案，如果該檔案已經存在的話，那麼原來內容都會丟失：如果您想保留原有內容，而把輸出產生在檔案結尾部份，可以使用 “>>”。

- **ls 可以列出从 / 出发任何路径下的文件，而无需亲自进入那个路径**

注意，是列出文件，而不是列出文件和文件夹。为什么这么强调呢？因为要加深一个印象：Linux 下，万物皆文件。文件是文件，文件夹也是文件，IO 设备也是文件。万物的物是一切实体，不包括权限这种抽象的东西。

```powershell
$ ls
Desktop  Documents  Downloads  Music  Pictures等
$ ls /
boot  etc  init  lib32  libx32  mnt  proc  run  snap  sys  usr等
$ ls /home
tsukiyokai
$ ls /home/tsukiyokai/Documents/
test1  test2
$ ls /home/tsukiyokai/Documents
test1  test2
```

- **將 test.ls 進行複製 (copy)，產生一個 test.ls.copy 的副本**

```powershell
$ cp test.ls test.ls.copy
```

复制文件时直接用 cp 即可，如果想复制文件夹，需要像删除时一样，加上 -r 表示递归地进行操作。

```powershell
tsukiyokai@DESKTOP-81NVB8G:~/Documents$ ls
test1  test2
tsukiyokai@DESKTOP-81NVB8G:~/Documents$ cp test1 test3
cp: -r not specified; omitting directory 'test1'
tsukiyokai@DESKTOP-81NVB8G:~/Documents$ cp -r test1 test3
tsukiyokai@DESKTOP-81NVB8G:~/Documents$ ls
test1  test2  test3
```

新增的 test3 文件夹下拥有原文件夹 test1 中的一切。

- **删除某个目录下的所有文件**

实际上不是简单地删除“目录”这个对象，而是“递归地”进入到该目录内的每个子目录，分别删除所有子文件。`-r`就是“递归地”的意思。`-f`就不用解释了，表示强制。

```powershell
tsukiyokai@DESKTOP-81NVB8G:~/Documents$ ls
test1  test2  test3
tsukiyokai@DESKTOP-81NVB8G:~/Documents$ rm test3
rm: cannot remove 'test3': Is a directory
tsukiyokai@DESKTOP-81NVB8G:~/Documents$ rm -f test3
rm: cannot remove 'test3': Is a directory
tsukiyokai@DESKTOP-81NVB8G:~/Documents$ rm -rf test3
tsukiyokai@DESKTOP-81NVB8G:~/Documents$ ls
test1  test2
```

- **块的占用**

在计算机虚拟内存的概念中，页、内存页或者虚拟页是指内存中的一段固定长度的块，这个内存块在物理地址和虚拟内存地址上都是连续的。一个页通常是以下操作的最小单元：操作系统为程序分配空间；内存和外存传输，比如说硬盘。

系统给我们提供真正的内存时，用页为单位提供，一次最少提供一页的真实内存空间。我们用下面命令来获取系统所设定的页的大小。

```powershell
$ getconf PAGESIZE
4096
```

显然 4096=1024×4=4Kbytes=4KB（其实绝大多数处理器上的内存页的默认大小都是 4KB）。4KB 的内存页其实是一个历史遗留问题，在上个世纪 80 年代确定的 4KB 一直保留到了今天。虽然今天的硬件比过去丰富了很多，但是我们仍然沿用了过去主流的内存页大小。

现在我在一个目录下执行下面的指令，这个目录预先存在一些大小不等的文件。

{% asset_img ls-lsh.png %}

`ls -lsh`的意思是：列出这个目录下的文件，以：详细列表、文件有序、人类可读（-h = human readable）的形式。

解释一下执行结果，特别是总用量（total）的由来：加上-a 选项之后明显出来了更多的文件，其中以点开头的文件表示隐藏文件，单独点表示当前目录，而点点表示上一层目录（cd 点点取的就是这个意思）。在用`ls -lsh`命令获得的总用量中，只包括目录下的文件用量，不包括目录本身，本着 Linux 中万物皆为文件的重要思想，则文件夹也是一个文件，因此 24K 并非 test 文件夹的总用量。

{% asset_img ls-lsha.png %}

这次的 32K 也不是正确的 test 文件夹总占地。32K=`.`+`..`+`xing`+`xing.cpp`=4K+4K+20K+4K。其中点表示当前目录的占地，显然，因为当前目录和上一层目录都非空，因此当前目录或上层目录这两个文件也要占用一定空间，它其中的文件并不多，所以一页（4K）就足矣储存所有数量信息。

“test 文件夹总占地”真正的数值是 28K，它通过`.`+`xing`+`xing.cpp`=4K+20K+4K=28K 计算得到。

28K 可以通过 du 指令来获取。在 Linux 下可能经常需要查看目录的大小，所以很有必要掌握 du 命令。du 的全拼为 disk usage，它用来计算每个文件的磁盘用量，如果目标是目录则取总用量。在使用 du 命令时，记住默认情况下它统计的大小是根据文件占用的 block 来统计。

插曲：最开始我是用 win10 子系统来进行的实验，结果结果有点毛病，跟理论不太符合，查了好久资料，最后换成正儿八经的虚拟机才解决，win10 子系统垃圾！

{% asset_img subsys.png %}



参考资料

https://arkingc.github.io/2017/11/30/2017-11-30-linux-du/