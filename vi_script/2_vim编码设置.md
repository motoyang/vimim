# vim字符编码理解和设置说明


## 1 字符编码基础知识

字符编码是计算机技术中最基本和最重要的知识之一。如果缺乏相关知识，请自行恶补之。这里仅做最简要的说明。

### 1.1 字符编码概述

所谓的字符编码，就是对人类发明的每一个文字进行数字化表示。最经典的ASCII编码就是西方人发明的针对英文字符的编码方法，包括26个英文字母、数字、标点、特殊字符等。问题是，这种编码的范围是0-127，只能对128个字符进行编码。当计算机来到其他国家后发现，除了英语，还有大量的其他语言，而且涵盖的字符也远远多于128个。为此，各个国家开始针对自己的语言进行编码工作，例如中国的GBK，日本的CJK，等等。

这虽然解决了ASCII编码不够用的问题，但是却带来了另外一个更加严重的问题。那就是各个国家的字符编码不统一，导致无法进行统一处理。于是乎，著名的UNICODE出现了，UNICODE编码范围非常大，可以涵盖全球所有语言的字符。

### 1.2 区分字符集（Charset）和字符编码（Char Encoding)

这两个术语有时候不进行区分的使用，但是理解其区别对于理解字符编码至关重要。

#### 代码点（Code Point） 

也就是我们前面说到的，为每一个字符分配一个数字序号。例如在ASCII字符集中，字符A被分配成65号，那就是说A的代码点是65。一种编码规范中，所有的代码点的集合就是字符集。

#### 字符编码 

字符编码是代码点的二进制存储格式。还是前面的例子，在ASCII字符集中，A的代码点是65。而这个65究竟是怎么用二进制0和1序列表示呢？这就是字符编码的工作。在ASCII编码中，这个65被存储为01000001，一共占据一个字节（8个二进制位）。

说到这里也许你会觉得，这中区别也没什么啊，这主要是因为在我们的例子中ASCII字符集的代码点只有一种字符编码方式，也就是ASCII字符编码。而这在其他字符集中却不总是这样，例如UNICODE字符集。

UNICODE字符集，规定了全球每一个字符的代码点，例如英文字母A在UNICODE字符集中的代码点是65（哈哈，这个代码点与ASCII是兼容的），然而65的存放格式却有很多方式：例如在UTF-8字符编码规范中被存储为8个二进制位：01000001，而在UCS-16中被存储为16个二进制位：0000000001000001，而在UCS-32中被存储为32个二进制位：00000000000000000000000001000001。

说到这里，就明白了，UNICODE字符集对应有很多不同的字符编码方式：UTF-8，UCS-16，UCS-32等等。 

而ASCII字符集只有一种编码方式：ASCII字符编码。

UNICODE字符集的不同编码方式是为了适应不同的环境而被创造出来的，例如UTF-8被用来网络传输，文件存放，UCS-16则被用来作为内存中的存放方式，以利于快速统一计算。

现如今，虽然UNICODE字符集已经获得广泛采用，然而历史遗留的其他字符集仍大量存在。 

近年来，字符集的概念很少被提及，字符编码则更多的被使用。

### 1.3 字符编码与显示

对字符进行编码只是完成了存放、处理和传输，要想把字符的形状绘制出来，还要有对应的字体以及渲染手段。

对于GUI程序，操作系统都会提供API来对指定字符进行渲染绘制。对于终端来说，终端有一个字符编码的属性，从而把接收到的二进制字节流按照这个字符编码进行解析，然后调用相应的渲染引擎来对其进行显示，详情请参考我的一篇博文：从调用printf()到显示器上看到字符串。

## 2 VIM读取、显示、保存文本文件过程分析

### 2.1 VIM涉及到的字符编码

1. 磁盘文件的字符编码 

存放在磁盘上的文本文件，是按照一定的字符编码进行保存的，不同的文件可能使用了不同的字符编码。 

这在VIM中被叫做：fileencoding。

2. VIM缓冲区以及界面的字符编码 

VIM运行时，其菜单、标签、以及各个缓冲区统一使用一种字符编码方式。 

这在VIM中被叫做：encoding。

3. 终端使用的字符编码 

终端同一时刻只能使用一种字符编码，并按照这种编码从接收到的字节流中识别字符，并显示，终端的字符编码是可以动态调整的。 

这在VIM中被叫做：termencoding。

### 2.2 vim读、显、存分析

1. 读文件 

VIM打开文件时，并不知道文件的字符编码，所以不得不进行探测。探测是按照一定的优先顺序进行测试。依据的标准就是：fileencodings。VIM逐一测试fileencodings变量指定的字符编码方式，直到找到认为合适的然后把这种字符编码方式设置为fileencoding变量。

然后把文件中的编码转换成encoding指定的编码方式，存入文件缓冲区中。 

2. 显示文件 

vim把文件读取完毕并以encoding编码存放到缓冲区内存之后，会根据termencoding指定的终端编码方式，转换成termencoding编码后，写入到终端。此时，终端按照自身的编码属性识别出一个个的字符，调用渲染引擎绘制到屏幕上。

3. 保存文件 

VIM把缓冲区中的encoding编码的字节集合转换成fileencoding编码后写入磁盘，完成文件保存。

可以看出，VIM涉及到的3种字符编码之间的转换：

| 对文件的操作 | 编码的转换                    |
| ------ | ------------------------ |
| 读      | fileencoding –> encoding |
| 显      | encoding –> termencoding |
| 写      | encoding –> fileencoding |

只要这三种转换都不会出现问题，那么VIM就可以正常工作，不会出现乱码。 

然而，并不是所有的字符编码之间都能够无损转换，例如GBK字符编码转换为ASCII编码时，由于ASCII并不能完全包含GBK的字符，所以会出现问题。

## 3 常见乱码情况分析

### 3.1 读文件时，VIM探测fileencoding不准确

这很好理解，比如以GBK编码方式存储的文件，VIM把fileencoding探测成了ASCII，则肯定会出现问题。

#### 【解决方法】

一是靠VIM自身提高探测水平；二是设置合适的fileencodings变量，把最可能用到的编码方式放到最前面。如果VIM实在是探测不对，那么就只能通过 `:set fileencoding=xxx` 命令来手动探测了。

### 3.2 fileencoding编码无法正确转换到encoding编码

例如，文件采用GBK编码，而ecoding使用ASCII，这样大量的汉字字符无法被转换，从而导致乱码。 

#### 【解决方法】

把encoding设置成UTF-8，目前为止UTF-8能包含所有字符，所以其他的任何编码方式都可以无损的转换为UTF-8。

### 3.3 encoding无法正确转换到termencoding

这个问题，与3.2类似。 

#### 【解决办法】

把termencoding设置为何encoding相同。默认termencoding=”“的情况下，这两者就是相同的。

### 3.4 termencoding与实际的终端字符编码不一致

例如本来字符终端的编码属性为GBK，而termencoding却为UTF-8，那么VIM就会错误的认为终端就是UTF-8编码的，导致向终端输出UTF-8编码的字节流，而终端却按照GBK来识别，当然就会识别成乱码。 

#### 【解决办法】

把终端实际的编码方式和VIM的termencoding统一起来。

### 3.5 终端显示能力欠缺

例如，传统的字符终端，本身不具备显示汉字的能力，虽然它可以识别出UTF-8编码的汉字，但是渲染引擎无法正确绘制，也就显示成了乱码。 

#### 【解决办法】

尽量还是使用Putty等伪终端软件，避免直接使用字符终端设备；如果实在不能避免，就要避免使用ASCII字符集以外的字符，好好学习英文吧。

## 4 杜绝乱码的最佳实践

所有编码统统设置为utf-8。这样既能够识别人类所有语言，又避免了各种编码之间转换的性能损失。

### 4.1 VIM设置

>set encoding=utf-8  
>set termencoding=utf-8  
>set fileencodings=utf-8,ucs-bom,shift-jis,gb18030,gbk,gb2312,cp936  


如果无特殊要求和限制，磁盘文件也以UTF-8方式存储。

>set fileencoding=utf-8

### 4.2 终端设置

常用的几种终端软件都设置为utf-8。 

