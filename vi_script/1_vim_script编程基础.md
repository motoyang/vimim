## Vim脚本Vimscript 简述

前面已经学习了Vim的简单使用，可以在Vim内部输入:help获得帮助，在学习的过程中，尽可能使用高版本的Vim，因为它将包含更多有趣的东西，如果不知道Vim的版本，只需在终端下输入 vim --version就可以得到Vim的版本信息。

Vim的脚本语言是Vimscript，学习Vimscript，能更好的帮助我们配置Vim，可以根据自己的偏好设置Vim，将Vim打造成适合自己的IDE，让Vim使用起来更加得心应手。

### 一 背景

Vim的脚本语言被称为Vimscript，是典型的动态式命令语言，提供一些常用的语言特征：变量、表达式、控制结构、内置函数、用户自定义函数、一级字符串、列表、字典、终端、文件IO、正则表达式模式匹配、异常和集成调试器等。

在学习Vimscript时，你可以学习Vim自带的Vimscript文档，打开Vim自带的Vimscript很简单，只需在Vim内部执行：help vim-script-intro（Normal模式下）

### 二 执行Vim脚本

执行Vim脚本的方法很多，最简单的做法就是将命令放到一个文件中(通常使用.vim做为扩展名)，然后在Vim内部使用命令:source ~/test.vim执行该文件（假设文件名为test.vim,存放目录为当前用户主目录下）

当然你也可以在Vim内部直接在冒号后面输入命令然后执行命令(:set number)，但是这样可能会重复输入命令，不如使用脚本文件方便，所以很少这样使用。

在Vim内部使用:call MyBackupFunc(expand('%'), { 'all':1, 'save':'recent'})执行脚本命令，但是很少人这么做，这样输入的东西过多，不好记忆等等，因此，调用Vim脚本的最普通的方法就是创建新的键盘映射，使用如下方法（关于map的使用请在Vim内部查看帮助文档）：
>:nmap ;s :source ~/test.vim<CR>
>:nmap \b :call MyBackupFunc(expand('%'), { 'all': 1 })<CR>

### 三 初窥Vimscript

在正式学习Vimscript之前，先来看一个简单的例子：

1. 在终端下输入 vim first.vim新建一个vim脚本文件

2. 在first.vim中输入如下内容
```
:let i = 1
:while i < 5
    : echo "count is" i
    : let i += 1
:endwhile
```

3. 输入:w后保存文件，然后输入:source ~/first.vim（假设first.vim存放在当前用户的主目录下）执行vim脚本，后看到如下输出：
```
count is 1
count is 2
count is 3
count is 4
```

注意：Vim命令时冒号：开头的，但是在vim脚本文件中编写脚本时，冒号：是可以省略不写的的。

### 四 变量(Variables)

通过上面的例子，能够学习到如何编写一个简单的Vimscript，并在Vim中执行Vimscript，接下来学习Vimscript中的变量，在Vimscript中使用let命令按如下方式定义变量
```
let {variable} = {expression}
```

但是在Vimscript中变量根据作用域的不同可以分为很多种类型，现在主要学习常见的几种类型，完整的Vimscript变量类型见下图：

1. 定义一个全局变量 var 其可以在任何地方使用
```
let var = 1
#或者这样写
let g:var = 1
```

2. 定义一个局部变量 var 其只能在某个脚本文件中使用
```
let s:var = 1
```

3. 定义一个变量 var 其只能在某个 buffer 中使用
```
let b:var = 1
```

4. 定义一个变量 var 其只能在某个 window 中使用
```
let w:var = 1s
```

注意：
+ Vimscript还有一些伪变量，脚本可以使用它们访问Vim提供的其他类型的值容器，完整的VimScript伪变量类型见下图：
+ 在VimScript中，0为false，非0为true，Vimscript很多时候会自动转换一个字符串为一个数值以确定其为true还是false，比如下面的例子中
	```
	if !exists("s:hahaya")
	```

+ Vimscript中字符串可以使用双引号”也可以使用单引号’包裹。

### 五 表达式

Vimscript中的表达式和其他语言中的表达式很类似，下面有个例子进行简单说明
```
a > 1 ？1 : 0
```

### 六 语句

1. 逻辑运算符

Vimscript运算符及优先级关系如下图

2. 条件控制语句

Vimscript的条件和C语言等其他语言的条件控制语句类似，下面是Vimscript条件控制语句的一般结构，其中elseif和else是可选的。
```
if {condition}
    {statements}
elseif {condition}
    {statements}
else
    {statements}
endif
```

3. 字符串匹配

+ a =~ b 字符串匹配
+ a !~ b 字符串不匹配

注意: 在字符串比较和匹配是，经常会受到大小写选项ignorecase的影响。

你可以避免此选项的影响：
- 在操作符后添加 # 表示不忽略大小写
- 在操作符后添加 ? 表示忽略大小写

4. while循环语句

在前面的Vimscript初窥中已经看到while语句的使用，while语句中和C语言等其他语言一样可以使用continue、break等(continue 命令用于跳转到循环的开始，break 命令用于结束循环)，这里不再详细介绍。

### 七  函数
在Vimscript中，直接调用函数使用call命令，我们可以使用如下方式定义函数：
```
function {name}({var1}, {var2}, ...)
    {body}
endfunction
```

在Vimscript中，用户自定义函数的函数名第一个字母必须大写，下面展示一个自定义的Min函数：
```
function! s:Min(num1, num2)
    if a:num1 < a:num2
let smaller = a:num1
    else
let smaller = a:num2
    endif
return smaller
endfunction
```

注意：
- function后面加上强制命令修饰符!表示该函数如果存在则替换，这样做是有必要的，假设该Min函数位于某个脚本文件中，如果没有加上强制命令修饰符，脚本文件被载入两次时会报错：函数已存在。
- Vimscript中有许多内置函数，大约超过200过，你可以在Vim内部输入 :help functions来学习。

### 八 list列表

一个list包含一组有序的元素，和C++不同的是，Vimscript中list的每个元素可以为任意类型。元素通过索引访问，第一个元素的索引为0。list使用两个中括号[ ]包裹。

1. 创建list
```
" 创建一个空的 list
let list1 = []
" 创建一个 list，其中含有两个类型不同的元素
let list2 = ['a', 2]
```

2. list元素的访问
```
let list[0] = 1
echo list[0]
```

3. list增加新的元素
```
" 添加新的值到 list 的尾部
call add(list, val)
" 添加新的值到 list 的头部
call insert(list, val)
```

4. list删除元素
```
" 删除索引为 index 的元素并返回此元素
call remove(list, index)
" 删除索引为 startIndex 到 endIndex（含 endIndex）的元素
" 返回一个 list 包含了这些被删除的元素
call remove(list, startIndex, endIndex)
" 清空 list，这里索引 -1 对应 list 中最后一个元素
call remove(list, 0, -1)
```

5. 判断list是否为空
```
if empty(list)
" ...
endif
```

6. 获取list的大小
```
echo len(list)
```

7. 拷贝list
```
" 浅拷贝 list
let copyList = copy(list)
" 深拷贝 list
let deepCopyList = deepcopy(list)
call deepcopy()
```

8. 使用for遍历list
```
let list = ['one', 'two', 'three']
for element in list
    echo element
endfor
```

### 九 dictionary字典

dictionary是一个关联数组。每个元素都有一个key和一个value，和C++中map类似，我们可以通过key来获取value。dictionary使用两个大括号{ }包裹。

1. 创建dictionary
```
" 创建一个空的 dictionary
let dict = {}
" 创建一个非空的 dictionary
let dict = {'one': 1, 'two': 2, 'three': 3 }
```

2. dictionary元素的访问和修改
```
let dict = {'one': 1, 'two': 2}
" 通过 key 访问
echo dict['one']
" 当 key 为 ASCII 字符串时还可以这样访问
echo dict.one
" 修改元素的 value
```

3. dictionary元素的增加和删除
```
" 增加一个元素
let dict[key] = value
" 删除一个元素
unlet dict[key]
```

4. 获取dictionary的大小
```
echo len(dict)
```

5. 使用for语句遍历一个dictionary
```
let dict = {'one': 1, 'two': 2}
for key in keys(dict)
    echo key
endfor
" 遍历时 key 是未排序的，如果希望按照一定顺序访问可以这么做：
for key in sort(keys(dict))
    " ...
endfor
 
" keys 函数用于返回一个 list，包含 dictionary 的所有 key
" values 函数用于返回一个 list，包含 dictionary 的所有 value
" items 函数用于返回一个 list，包含 dictionary 的 key-value 对
for value in values(dict)
    echo value
endfor

for item in items(dict)
    echo item
endfor
```

Vimscript可以用来重组和扩展Vim编辑器，可以将Vim根据自己的需求来定制。如果想Vim具备某些功能，完全可以自己通过Vimscript扩展Vim 。

