##vim script 编程基础
---

简单扼要的介绍vim script的语法和编程基础，可以有空的时候瞄一瞄。

### 1. vim  语法基本特征

"	注释
\	续行
let	关键字为变量赋值

### 2. Vimscript 变量范围

前缀	   |  含义
-----------|---------
g: varname |  变量为全局变量
s: varname |  变量的范围为当前的脚本文件
w: varname |  变量的范围为当前的编辑器窗口
t: varname |  变量的范围为当前的编辑器选项卡
b: varname |  变量的范围为当前的编辑器缓冲区
l: varname |  变量的范围为当前的函数
a: varname |  变量是当前函数的一个参数
v: varname |  变量是 Vim 的预定义变量

### 3. Vimscript 伪变量

脚本可以使用如下变量访问 Vim 提供的值容器。

前缀		|	含义
------------|-----
&varname	|	一个Vim 选项
&l:varname	|	本地变量(局部变量)
&g:varname	|	全局变量
@varname	|	一个 Vim 寄存器
$varname	|	一个环境变量

### 4. 比较操作(condition) 
在 Vimscript 中，比较函数始终执行数字比较，除非两个运算对象都是字符串。
特别的，如果一个运算对象是字符串，另一个是数字，那么字符串将被转换为数字，然后再对两个数字进行数值比较

```
let ident = 'Vim'
if ident == 0		"Always true (string 'Vim' converted to number 0)
```

在这种情况下，一种更健壮的解决方案是：
	if ident == '0'

任何字符串比较函数都可以被显式地标记为大小写敏感（通过附加一个 #）或大小写不敏感（通过附加一个 ?）：
	if name == ?'vim'
	if name == #'Vim'

### 5. 算术运算，注意整数和实数差别

	let filecount = 234
	echo filecount/100			" 显示2
	echo filecount/100.0		" 显示2.34

### 6. 语句 (statement)

赋值语句：let
	let {variable} = {expression}

条件控制if 语句：

```
if {condition}
    {statements}
elseif {condition}
    {statements}
else
    {statements}
endif
```

while 语句：
```
while {condition}
    {statements}
    [ continue ]
    [ break ]
endwhile
```

for 语句：
```
for {varname} in {listexpression}
    {statements}
endfor
```

### 7. command
vim script 语句可以直接支持:命令。
加上normal关键字，也支持normal模式命令。起码，把script做成批命令是没有问题了。

### 8. 函数
vim 有许多内置函数。还可以自定义函数。
内置函数，内置寄存器，:命令等构成与编辑缓冲的连接，使可以编程控制。
自定义函数，按照如下函数格式：
```
function {name}({var1}, {var2}, ...)
    {body}
    [ return ]
endfunction
```

例：求两数中最小值函数：
```
function! s:Min(num1, num2)
    return a:num1 < a:num2 ? a:num1 : a:num2
endfunction
```

