## 03_VimScript脚本语言学习
---

前面学习VimScript数据类型的时候，介绍了Number, Float, String, List, Dictionary五种的基本用法，本节将学习最后一种数据类型：Funcref。当然之前必须要对函数进行介绍。

### 1 函数

VimScript支持编程语言中通用函数的概念，而且内建了大量的函数供用户使用，如用于查询的serach()，获取行的getline()等等，今后的例子中将会逐渐使用这些函数来完成更有意思的功能。

#### 1.1 函数调用的两种方式

有两种调用VimScript函数的方式。

1. 不关心返回值
```
call search("Date: ", "W")
```

使用关键字call 来显式调用函数。

2. 关心返回值
```
let line = getline(".")  
let repl = substitute(line, '\a', "*", "g")  
call setline(".", repl)  
```

上例子，getline(".")返回当前光标所在的行文本，substitue()则返回替换后的文本， 这种情况下自动调用函数，无需使用call。

其实函数调用的call与变量赋值的let类似，看起来好像真的是多余的，C和PHP都没有这种用法，也能工作的很好啊，搞不懂VimScript的开发者是如何想的。

#### 1.2 自定义函数

VimScript内建了大量的函数供用户使用，同时也支持用户自定义函数。基本语法如下面例子。
```
function Min(num1, num2)
    if a:num1 < a:num2
        let smaller =a:num1
    else
        let smaller = a:num2
    endif
    return smaller
endfunction

echo Min(23,24)  
```

第一眼看起来与PHP中的函数非常相似。需要注意的是：

函数的名字首字母必须大写。Vim为了避免用户自定义函数与内置函数命名冲突，强制要求用户自定义函数名的首字母必须是大写字母。

函数的参数在函数体内使用的时候前面加上了a:，这表示是一个函数参数，否则运行时会报错，并提示num1是没有定义的变量。这就引出了一个很重要的话题：变量的作用域。

函数名称属于全局命名空间，在所有脚本中可用

### 2 变量的作用域（名字空间）

#### 2.1 基本变量命名空间

在VimScript中默认的作用域是全局作用域，也就是说你在一个脚本文件中定义了一个变量，在其他脚本中也可以读取和修改这个变量。在任何编程语言中，全局变量的滥用都会造成混乱，所以VimScript提供了更多的非全局作用域。

变量名 | 作用域说明
-------|--------------
s:name | 脚本文件作用域，此时s:name这个变量只在当前脚本文件中有效，其他的脚本文件中如果也定义了同名的s:name也没关系，因为这两者彼此独立。这一点与C中的static关键字类似。
b:name | 缓冲区作用域，b:name只在指定的缓冲区中有效
w:name | 窗口作用域，w:name只在指定的窗口中有效
g:name | 全局作用域，函数外定义的变量的默认值
v:name | vim预定义的变量，注意预定义变量不同于vim的选项(option)变量。
l:name | 函数内部的局部变量，函数内部定义的变量的默认值

注意这些作用域只针对变量名，而不能作用于函数名。

几个例子：

```
" 作用域  
let local = 10  
function MyFunc()  
    echo local  
endfunction  
```

单独运行上面的代码，并不会出错。但是当真正调用这个MyFunc()函数时，会报错，提示未定义变量local。这是因为定义函数的代码只是描述函数功能，只有运行时才会发现并不存在局部变量local，从而报错。需要修改为：
```
" 作用域  
let local = 10  
function MyFunc()  
    echo g:local  
endfunction  
```

#### 2.2 特殊变量空间

除了上面的各种名字空间，vim还提供了几个特殊的名字空间。

##### 环境变量：

如果变量的名字以$开头，那么这个变量被认为是环境变量， 如：

```
" 环境变量  
echo $HOME  
echo $VIM  
echo $VIMRUNTIME  
echo $notexist  
echo type($HOME)  
echo type($notexist)  
```
环境变量的数据类型都是String，如果没有定义一个环境变量，使用也不会报错，默认值是空字符串。

##### option:

如果变量名以&开头，那么这个变量是一个vim内部变量。vim提供了很多可以配置的选项，也被称为vim内部变量。

同一个名称的内部变量往往有很多副本，一个是全局的，还有buffer和window局部的，而且提供了不同的读写命令set和setlocal。

内部变量共使用了三种数据类型：boolean，Number, String。其实VimScript并不支持boolean，而是用Number模仿而已。

改变一个option有两种方法：一是使用set命令，如 set number， set tabstop=4； 二是给变量直接赋值，如 let &number=1, let &tabstop=4。两种方法达到的效果是一样的。不过需要注意的是：
- set命令可以使用简写形式的option名字，如set nu，而直接赋值必须使用完整的内部变量名称；
- 直接赋值时要在变量名之前添加&，否则会新建一个同名变量，而不是使用vim的内部变量。如 let number=1不会修改vim的number内部变量。

##### register:

如果变量名以@开头，那么这本变量是暂存区变量，注意register在这里的含义与CPU中的寄存器没有直接关系。

register其实就是一块内存，用来存放各种临时性的东西，比如拷贝的文本，文件的名称，最近删除的文本等等。共有9种类型的register。分别是：
1. 无名register "" ， 在vim中register使用引号开头
2. 以数字为名的register，"0到"9，共10个
3. 小删除register, “-（连接符）
4. 以字母为名的register, ”a到"z，共26个
5. 只读register，共有4个，分别是 ", ，“。，”%，"#
6. 表达式register，"=
7. 选择与删除register，共3个，分别是 "\*，"+以及"~
8. 黑洞register, "\_（下划线），注意与"-区别
9. 上次查找模式register, ”/

这些register中，有一些是vim自身使用的，有些则是共用户使用的。

在VimScript中，使用@+暂存区名的语法来读取和设置暂存区。如下：

```
echo @"  
let @/ = "hello"  " 写入register  
echo type(@/)  
echo type(@_)  
```

通过实验得知，所有的register类型变量的数据类型都是String。

