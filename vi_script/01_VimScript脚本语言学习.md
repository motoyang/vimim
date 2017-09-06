## 01_VimScript脚本语言学习
---

vim配置文件、语法文件、插件文件中使用的都是vim专用的脚本语言VimScript。它能运行于vim平台之上。从本文开始，将记录作者本人学习这门语言的一些心得体会。

大概的学习思路是：
- 语言定位
- 数据类型与转换
- 基本语法
- 函数
- 平台API
- 实用插件编写

### 1 VimScript简介

VimScript是用于配置、扩展vim的专用脚本语言。具有动态类型、面向对象（不太完整）、异常处理等现代语言特征。大体上属于PHP语言派别，但没有PHP干净利索。是编写vim插件的基本语言，但不是唯一语言，因为vim也支持通过python,perl等语言编写其插件。

与其他语言入门一样，先来一个HelloWorld示例。脚本语言与编译语言不同，往往都支持在线编程调试，同时也支持把代码写入文件中，然后再执行。我们分两种情况给出例子。

#### 1.1 交互模式

启动vim后，在Normal模式下输入
>:echo 'Hello, VimScript!' 

然后回车，命令行窗口会打印出
>Hello, VimScript!


#### 1.2 文件模式
新建一个名为hello.vim的文本文件。写入如下内容:

```
" 这是注释  
echo ‘Hello, VimScript!'  
```

然后在vim的Normal模式下输入
>:source hello.vim

同样会在命令行窗口打印出
>Hello, VimScript!

通过这个简单的示例，我们学到了最基本的VimScript知识：
1. 双引号以及后面的文字属于注释内容
2. 输出使用:echo关键字
3. 以行为执行单位
4. 使用:source命令来执行外部VimScript文件

另外VimScript是严格区分大小写的。


### 2 VimScript的数据类型

数据类型在任何编程语言中都占有极其重要的地位，VimScript也不例外。VimScript支持6种数据类型，分别是：Number-有符号整数、Float-浮点数、String-字节串（字符串）、Funcref-函数引用、List-有序链表、Dictionary-无序关联数组。下面分别详细解释。

1. Number
  32位有符号整数，等同于C或PHP语言的int。如果从引用和值来分类，此种类型属于值类型。

2. Float
  浮点类型，等同于C或PHP语言中的float。值类型。

3. String
  字符串类型，等同于C或PHP语言中的字符串。值类型。

4. Funcref
  函数引用，等同于C或PHP语言中的函数类型。引用类型。

5. List
  有序链表，这个在C语言中没有对应项，因为List中的每个元素的类型可以不同，类似于PHP中的索引数组。引用类型。

6. Dictionary
  字典类型，实质是哈希表，类似于PHP中的关联数组。引用类型。

VimScript提供了内置函数type用于识别一个数据的类型，示例：
```
echo type(1)  
echo type('hello')  
echo type(function("getline"))  
echo type([1,2])  
echo type({})  
echo type(1.1)  
```

输出结果为:
```
0  
1  
2  
3  
4  
5  
```

对应6种数据类型。Float被排到最后，很可能是因为一开始并没有这种类型，而后根据需要又增加的。

### 3 变量声明与赋值及数据类型转换

#### 3.1 变量命名
变量是任何语言中必备要素，VimScript中的变量与PHP变量类似，但不相同。变量的命名规则与C相同，只能使用数字、字母、下划线，且不能以数字开头。另外，VimScript变量名可以推迟到运行时确定，这点与PHP中可变变量类似。

#### 3.2 变量声明、使用与删除
在 VimScript中，变量无需声明即可使用，不过它使用了一种特殊的赋值语法。例如：

	let age=29  

等号=左右可以有空格。
要删除这个变量，需要:

	unlet age

这与PHP中的unset类似。

一个变量删除以后不能在被使用。

再给出一个动态变量名的例子：
```
let age=2  
let my{age}="hello"  
echo my2  
```

动态名字需要使用{}语法。

#### 3.3 各种类型变量的赋值语法
给出一个例子

```
" 各种数据类型赋值示例  
  
" 整数  
let n1 = 23  
let n2 = -23  
let n3 = 012  
let n4 = 0x12  
let n5 = n1 + 1  
  
" 浮点数  
let f1 = 0.23  
let f2 = 1.02E12  
  
" 字符串  
let s1 = "Hello"  " 双引号字符串，支持转义  
let s2 = 'Hello'  " 单引号字符串，不支持转义  
let s3 = s1 . s2  " 字符串连接  
  
" List  
let list1 = [1,2,3,5]  
let list2 = [1, 'hello', 34.3, [1, 2]] " 可以存储不同类型的数据  
  
" Dictionary  
let dic1 = {'name':'张三', 'age':18, 'sex':'男', 'score':89.2}  
  
echo n1  
echo n2  
echo n3  
echo n4  
echo n5  
echo f1  
echo f2  
echo s1  
echo s2  
echo s3  
echo list1  
echo list2  
echo dic1  
```

几个需要注意的地方：
1. 字符串同时支持单引号和双引号，区别在于双引号字符串能识别转义，这一点与PHP类似；
2. 字符串连接使用专门的点号运算符，这一点也与PHP类似；

#### 3.4 自动类型转换与非自动类型转换
在 VimScript中，Number和String之间是自动转换的，其他的转换都不是自动的。还是看例子吧。

```
" 自动类型转换  
let v1 = 'hello' + 23  
let v2 = 'hello' . 23  
let v3 = '23fs' + 2  
let v4 = 'h23f' + 2  
let v5 = "3.4" + 23.3  " 3.4会被自动转换为Number而不是Float, 要想转为Float需要str2float("3.4")  
let v6 = 23.3 + 4  
  
echo v1  
echo v2  
echo v3  
echo v4  
echo v5  
echo v6  
```

可以看出Number和String是根据语法需要自动转换的，但是Float和String不能自动转换，也就是如下行不通
let s = 'hello'. 2.3
另外，Number和Float参与一起运算时，Number先自动转换为Float再参与运算，这与C相同。

#### 3.5 不完整的动态类型
VimScript可以说是动态类型语言，前面在使用的时候并没有明确指定类型，而是由解释器动态确定的。但是它又不是完全的动态化。看下面的例子：

```
let a = 2  
let a = 'Hello'  
let a = 2.2  " 这里会报错  
```

变量a一开始是Number类型，然后变成了String类型，当变成Float类型时，解释器会报错。这说明在VimScript里，一个变量的类型不会随便动态改变。这显然与动态语言类型有些不太符合。实际上，只有Number和String可以相互改变，其他类型都不可以。这对于习惯了PHP的开发人员来说，可能感到非常奇怪。我想这与VimScript的类型底层实现是由关系的，希望以后能改进。变通的方法是，先删除这个变量，然后重新定义其类型，如下：

```
let a = 2  
let a = 'Hello'  
unlet a  
let a = 2.2  
```

虽然看起来变量名字还是a，但是其实已经不是同一个变量了，所以当然可以有不同的数据类型。


