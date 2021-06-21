# Student-Management-System
本科时的汇编作业，命令行实现对学生信息（姓名/年龄/学号/成绩）的录入、排序、展示等

## 实验环境
Win10 + Dosbox

## 实验思路
### 一. 存储数据

#### 1. 对学生信息的存储
一开始我准备用一个结构体表示学生信息。但实际操作的时候发现EMU8086好像不支持结构体，转到dosbox运行时发现用结构体存储信息还是没有用四个分别的数组来存储直观且操作简单。最终我使用了四个数组来分别保存学生的四种信息（姓名、年龄、学号、成绩）。

#### 2. 对学生成绩、学号、年龄的存储

这里我认为有两种方法：第一：用字符串存储，第二：用二进制数存储：
- 第一种方法优点在于输入---存储---输出都很简单。但缺点在于排序时数据比较会比较烦。
- 第二种方法优点是排序时两数据比较大小非常便利且节约存储空间，缺点是需要将输入的字符串转换成二进制数，输出的时候也要特殊处理。

综合考虑后我选择二进制数存储，因为我觉得这样更加自然。

#### 3. 对学生成绩的存储

我认为有两种好方法
- 第一种：高字节和低字节分别存整数和小数部分
- 第二种：直接将输入的数乘十后存储，输出的时候特殊处理

使用第一种方法在于排序比较时需要先比较整数位，在整数位相等的情况下比小数位，而第二种方法直接比较即可，在这个方面第二种方法比较方便。但在输出的时候，我认为第一种方法较为方便，可能只需要调用两次功能为二进制转十进制数并输出的函数，并在两次调用之间插入输出一个小数点；第二种方法则需要特殊处理后输出。

综合考虑后最终选择第二种方法。

### 二. 输入输出

输入的时候麻烦的地方在于需要正确读入成绩。由于我使用将输入的数乘10存储，就需要有一个对输入为整数或浮点数的判断和处理。

输出的时候难的地方是二进制转十进制输出，有的时候会发现寄存器不够用。众所周知二进制数转十进制数只需要除10取余。这里如何存余数是个问题。

具体地，利用其先进后出特性，将余数先全部依次push再依次pop输出。由于学号需要大范围，只能最少用16位存，然后除10后的余数也必须使用16位存，不然会丢失数据，所以在除10取余的过程中只能使用(DX:AX)/BX，此时CX正在用于计数，这时就发现寄存器不够用了，只能在这段指令前将si、di压栈，这段指令后pop出来以增加该段程序可用寄存器数量。


## 实验结果
首先进入选择分支界面 输入数字1-6选择模式
[![REk5pF.png](https://z3.ax1x.com/2021/06/21/REk5pF.png)](https://imgtu.com/i/REk5pF)

若输入数字1-6以外的字符 会出现错误提示并回到选择界面
[![REkjfO.png](https://z3.ax1x.com/2021/06/21/REkjfO.png)](https://imgtu.com/i/REkjfO)

此时由于没有学生数据。输入2(根据学生学号排序)、3(根据学生成绩排序)、4(显示学生信息和平均成绩)都没有效果

若此时输入5（统计学生成绩分布）
[![REAkAP.png](https://z3.ax1x.com/2021/06/21/REAkAP.png)](https://imgtu.com/i/REAkAP)

录入几个学生信息。这里就仅录入三个，使dosbox界面可以全部展示出来
[![REAMBn.png](https://z3.ax1x.com/2021/06/21/REAMBn.png)](https://imgtu.com/i/REAMBn)

[![REA8hT.png](https://z3.ax1x.com/2021/06/21/REA8hT.png)](https://imgtu.com/i/REA8hT)

[![REAtc4.png](https://z3.ax1x.com/2021/06/21/REAtc4.png)](https://imgtu.com/i/REAtc4)

此时我们选择显示学生信息，发现还是按照输入的顺序来输出的
[![REAwH1.png](https://z3.ax1x.com/2021/06/21/REAwH1.png)](https://imgtu.com/i/REAwH1)


选择模式2，即按照id排序 再选择模式4输出

[![REAgjH.png](https://z3.ax1x.com/2021/06/21/REAgjH.png)](https://imgtu.com/i/REAgjH)

再选择模式3，即按照成绩排序，再选择模式4输出

[![REAWDA.png](https://z3.ax1x.com/2021/06/21/REAWDA.png)](https://imgtu.com/i/REAWDA)

选择模式5，查看成绩分布

[![REAbvQ.png](https://z3.ax1x.com/2021/06/21/REAbvQ.png)](https://imgtu.com/i/REAbvQ)

选择模式6 退出

[![REAXbn.png](https://z3.ax1x.com/2021/06/21/REAXbn.png)](https://imgtu.com/i/REAXbn)
