## 04_VimScript脚本语言学习
---

### 1 平台API的重要性

要使用任何一门语言写出点真正有用的程序来，都离不开平台API的调用。使用C/C++开发Windows程序需要大量调用Win32API，开发Linux程序需要大量调用Linux API，开发Java程序，需要调用使用Java封装好的平台API。API大体上分为两种，一种是以函数的形式体现，如Win32API, Linux API, Socket API等，另一种则是以类的形式体现，供面向对象的语言使用。也有混合的，如PHP的平台库中既有函数，又有类。

对于VimScript来说，其底层平台就是vim，API的形式是函数库。vim 7.3版本提供了近300个内建函数供用户使用，要想轻松的操控vim，必须熟练掌握常用的内置函数。不要重复实现与内置函数相同功能的函数，因为内置函数是C编写的编译好的二进制代码，执行速度远远高于VimScript编写的函数。

### 2 Vim平台内建API分类介绍

vim提供的近300个内建函数，从功能上可以分为几个大类。

#### 2.1 字符串操作类

1. nr2char({expr})

number to char。返回一个作为ASCII码的值（整数）对应的字符串。

2. char2nr({expr})

char to number。返回一个字符串的首字母的ASCII码值。

3. str2nr( {expr} [, {base}] )

string to number。把一个字符串转换为整数，参数base是进制数，可以是8，10，16。如果不提供base参数，那么默认按照10进制转换。这与字符串到整数的自动转换不同。自动转换会根据字符串的前缀自动判别进制数。

4. str2float( {expr} )

string to float。把一个字符串转换为浮点数。

5. printf( {fmt}, {expr1} ...)

格式化，返回格式化后的字符串，而不是打印出来。与C版本的printf类似，只是这个函数不打印，而是返回格式化后的字符串。

下面 给出个小例子，试验试验。
```
echo nr2char(65)
echo char2nr('ABC')
echo str2nr('0x12', 16)
echo str2nr('0x12')
echo str2float('23.2221')
echo printf('%d, %s, %f', 10, '张三', 98.3)
```

结果为：
```
A
65
18
0
23.2221
10, 张三, 98.300000
```

6. escape( {string}, {chars} )

如果string中存在chars中任意一个字符，则使用\对这个字符进行转义，然后返回处理过的字符串。

7. shellescape( {string}, [, {special}] )

对string中出现的特殊字符进行转义，以满足操作系统shell要求的格式。

8. fnameescape( {string} )

对指定的文件名string进行转义，主要是对里面的%等在vim中是特殊字符的字符进行转义。

9. tr( {src}, {fromstr}, {tostr} )

对src中出现的formstr中的字符，按照位置对应关系替换为tostr中的字符。

10. strtrans( {expr} )

对字符串中的不可打印字符转换为可打印字符后返回。

11. tolower( {expr} )

把大写字母转换为小写字母。

12. toupper( {expr} )

把小写字母转换为大写字母。

下面测试一下：
```
let str = "Hello, VimScript!"
echo tolower(str)
echo toupper(str)
echo tr(str, 'eo', 'EO')

echo escape(str, 'Vim')
echo shellescape(str)
echo fnameescape('/usr/share/file name.txt')

let str = nr2char(10)  " 不可打印字符
echo  strtrans(str)
```

运行结果：
```
hello, vimscript!
HELLO, VIMSCRIPT!
HEllO, VimScript!
Hello, \V\i\mScr\ipt!
'Hello, VimScript!'
/usr/share/file\ name.txt
^@
```

13. match( {expr}, {pat}[, {start} [, {count}]] }

找到匹配位置索引值，并返回这个值。{expr}可以是两种数据类型，一是String，此时返回开始匹配模式d第一个字符的索引；而是List类型，每个元素都是String，此时返回的是匹配模式的那个字符串元素在List中的索引。如果没有找到匹配项，则返回-1。

14. matchend( {expr}, {pat}[, {start} [, {count}]] }

与match相同，只是返回的不是匹配的开始索引，而是返回匹配后面的索引。

15. matchstr( {expr}, {pat}[, {start} [, {count}]] }

与match相同，只是返回的是匹配的字符串。如果没有匹配则返回空字符串。

16. matchlist( {expr}, {pat}[, {start} [, {count}]] }

与matchstr相同，只是返回的是一个List，第一个元素是匹配的字符串，后面d元素是匹配的子串，如“\1”，“\2"。（正则表达式的反向引用）

这四个函数是对正则表达式的支持。下面给出例子：
```
let str = "Hello, VimScript!"
let pat = 'V.m'
echo match(str, pat)
echo matchend(str, pat)
echo matchstr(str, pat)
echo matchlist(str, pat)
```

运行结果：
```
7
10
Vim
['Vim', 'i', '', '', '', '', '', '', '', '']
```

17. stridx( {haystack}, {needle} [, {start}] )

返回数值，给出字符串{haystack}里第一个字符串{needle}出现的字节位置。如果给出{start}，搜索从{start}位置开始。可用来寻找第二个匹配。

18. strridex( {haystack}, {needle} [, {start}] )

反向查找第一个匹配的字符串。

19. strlen( {expr} )

返回给定字符串的长度，以字节为单位。

20. substitute( {expr}, {pat}, {sub}, {flags})

字符串替换，与命令:substitute类似。

21. submatch( {nr} )

子匹配。相当于正则表达式中的反向引用。只能用在:substitute命令的参数中。

22. strpart( {src}, {start} [, {len}] )

返回字符串的子串。类似于其他语言中的substr()。

这几个函数是基本的字符串操作函数，示例如下：
```
let str = "Hello, VimScript!"
echo stridx(str, 'i')
echo strridx(str, 'i')
echo strlen(str)
echo substitute(str, 'Vim', 'VIM', "")
echo strpart(str, 3, 2)
```

运行结果：
```
8
13
17
Hello, VIMScript!
lo
```

23. expand( {expr} [, {flag}] )

把字符串中的特殊元字符展开后返回。

24. iconv( {expr}, {from}, {to} )

字符串字符集转换。如从UTF-8转为latin1.

25. byteidx( {expr}, {nr})

返回第nr个字符的开始字节索引。对于单字节编码的ASCII来说，返回值为nr，对于多字节字符集才有价值。

26. repeat( {expr}, {count})

把一个字符串复制多个后返回。

这几个大概与字符编码有关：
```
let str = "%"
echo expand(str)

let str = '张三'
echo strlen(str)
echo strlen(iconv(str, 'UTF-8', 'latin1'))

echo byteidx(str, 1)
echo repeat(str, 3)
```

运行结果：
```
t4.vim
6
4
3
张三张三张三
```

27. eval( {string} )

把一个数据的描述字符串，转为数据自身。

28. string( {expr})

返回一个数据的描述字符串。

这两个函数作用正好相反，类似于数据的序列化和反序列化。
示例如下：
```
unlet! v
let str =  string([1,2,3])
let v = eval(str)
echo str
echo type(v)

unlet v
let str = string(2.338)
let v = eval(str)
echo str
echo type(v)

unlet v
let str = string('hello')
let v = eval(str)
echo str
echo type(v)
```

结果如下：
```
[1, 2, 3]
3
2.338
5
'hello'
1
```

#### 2.2 List 类型的操作

List和Dictionary是VimScript中的重要数据类型，本节来介绍操纵List数据类型的内置函数。

1. get( {list}, {idx} [, {default}] )

返回list的第idx个元素。需要注意的是，即使索引值idx超出了有效范围，该函数仍然会返回一个值，这个值或者是0，或者是给定的default参数。

2. len ( {expr} )

返回数组的长度。

3. empty( {expr} )

判断一个数组是否为空，等同于 return len( {expr}) == 0，但是效率比len()高。

4. insert( {list}, {item [, {idx} ])

在数组中插入一个元素，位于idx之前。如果idx=0或者不提供idx参数，就插入在开头。返回结果数组的引用。

5. add( {list}, {expr})

在数组末尾增加一个元素。返回结果数组的引用。

6. extend( {expr}, {expr2} )

把第二个数组中的元素加入第一个数组中，返回结果数组的引用。

7. remove( {list}, {idx} [, {end] )

删除数组中的一个或多个元素。

以上都是对于集合类数据类型的基本操作。测试代码如下：
```
let list = [1,2,3]
let e = get(list, 2)
echo e

unlet e
let e = get(list, 3)  " 索引不在范围，也不报错
echo e

" echo list[3] 索引不在范围会报错

unlet e
let e = get(list, 3, 99)
echo e

let len = len(list)
echo len

echo empty(list)
echo empty([])

call insert(list, 0)
call add(list, 4)
echo list

call add(list, [1,2,3,4])
call extend(list, [11,12,13])
echo list

call remove(list, 2)
echo list
call remove(list, 2, len(list)-1)
echo list
```

注意：get()函数和数组方式的索引（方括号语法）类似，只是索引值无效时，get()不会报错，而数组语法会报错。

8. copy( {expr} )

返回给定数组的浅拷贝。所有涉及引用类型的复制操作都会涉及到深浅拷贝的问题。

9. deepcopy( {expr} [, {noref} ] )

返回给定数组的深拷贝。如果有交叉循环引用，可能会导致深拷贝出错。尽量少使用深拷贝。

测试代码：
```
let sublist = ['hello']
let list = [1,2,3,sublist,5]
" let list2 = copy(list)
let list2 = deepcopy(list)

echo list

let list2[3][0] = 99
echo list2

echo list
```

10. filter( {expr}, {string} )

删除不满足要求的元素，string用于描述过滤规则。

11. map ( {expr}, {string} )

修改数组的每一个元素，修改规则在string中描述。

测试代码：
```
let list = [1, 2, 3, 4, 5, 6]
call filter(list, 'v:val >= 3')  " 删除所有小于3的元素
echo list

call map(list, '"<" . v:val . ">"') " 为每个元素添加修饰
echo list
```

运行结果：
```
[3, 4, 5, 6]
['<3>', '<4>', '<5>', '<6>']
```

12. sort （{list} [, {func})

按照指定的规则对数组排序。

13. reverse ({list})

反序数组中的元素。
示例代码：
```
[plain] view plain copy
let list = [23, 33, 2 ]
call sort(list)
echo list

call reverse(list)
echo list
```

14. split（ {expr} [, {pattern} [, {keepempty}]] )

把一个字符串按照特定的边界标记进行分割，返回各个部分为元素的数组。

15. join （{list} [, {sep}])

与split（）正好相反，把一个数组中的各个元素的字符串描述连接成一个大字符串返回。

示例代码：
```
let str = "I am a good boy"
let parts = split(str)
echo parts

echo join(parts)
```

16. range( {expr} [, {max} [, {stride}]])

返回一个整数数组，具体还是看例子。

示例代码：
```
echo range(4)
echo range(2,4)
echo range(2,9,3)
echo range(2,-2,-1)
echo range(0)
echo range(2,0) " 会出错
```

运行结果：
```
[0, 1, 2, 3]
[2, 3, 4]
[2, 5, 8]
[2, 1, 0, -1, -2]
[]
Error detected while processing /root/t4.vim:
```

默认初值为0，默认步进为1，这么理解就可以了。

17. string（{expr} )

这个在前面字符串操作函数中已经说过了，string()用于所有数据类型的序列化。当然也包括List。这里有一个知识点，就是VimScript的一个函数的参数可以是不同的数据类型。注意这与C++里的重载不同，因为不存在同名的多个函数，而是只有一个函数就能处理多种数据类型，更像是OO中的多态。

18. call( {func}, {arglist} [, {dict}])

使用参数arglist指定的参数，调用参数func指定的函数。要把这个函数与vim的: call 命令区别开，尽管:call命令最终也是调用这个函数的，不过两者的工作层级不同。

对于dict参数，在学习Dictionary操作函数时再去讲解。
示例代码：
```
function! MyFun(num1, num2)
    return a:num1 + a:num2
endfunction

let sum = call("MyFun", [1,2])
echo sum

let sum = call(function("MyFun"), [1,2])
echo sum
```

19. index({list}, {expr} [, {start} [, {ic} ]] )

返回数组中元素值与给定值相同的第一个元素的索引，就是查找。

20. max( {list} )

返回数组中值最大的元素的值，如果数组为空，则返回0

21. min( {list} )

返回数组中值最小的元素的值，如果数组为空，则返回0

22. count( )

返回值为给定参数的元素的个数。

23. repeat({expr}, {count})

这个函数在前面字符串操作函数中已经学习过了。

示例代码：
```
let list = [1,2,3, 'a', 'a', 'b', 'c', 'hello']
echo index(list, 'hello')
echo max(list)
echo min(list)
echo count(list, 'a')
echo repeat(list, 3)
```

结果：
```
7
3
0
2
[1, 2, 3, 'a', 'a', 'b', 'c', 'hello', 1, 2, 3, 'a', 'a', 'b', 'c', 'hello', 1, 2, 3, 'a', 'a', 'b', 'c', 'hello']
```

#### 2.3 Dictionary 类型的操作

Dictionary是VimScript中最复杂的数据类型，等同于PHP中的关联数组，其本质是以字符串为键的哈希表。在PHP中，索引数组和关联数组统一为Array数据类型，而在VimScript里则分成了List和Dictionary两个类型。个人觉得还是PHP的做法更好。

下面就来看看Vim为我们提供了那些内置的与Dictionary有关的函数。

1. get( {dict}, {key} [, {defaut}])

这个与操作list的get完全同理，只是使用键代替了索引值。

2. len（{expr})

这个与操作List的len完全同理。

3. has_key({dict}, {key})

判断dict是否含有键key。有则返回1， 没有则返回0

4. empty { {exprt} )

判断是否为空，与List的empty（）同理。

5. remvoe（{dict}, {key})

删除dict中具有指定键值的元素。

6. extned( {expr1}, {expr2} [, {expr3}])

在前面List操作函数中也出现了，用于合并两个dict。

7. filter({expr}, {string})

在前面List操作函数中也出现了，用于删除不满足要求的元素。

8. map（{expr}， {string})

在前面List操作函数中也出现了，用于修改每一个元素。

9. keys({dict})

返回一个数组，数组中的元素是dict的所有键值。

10. values({dict})

返回一个数组，数组中的元素是dict的所有值。

11. itmes（{dict}）

返回一个数组，数组中的元素是dict的键值对组成的子数组。

12. copy(),deepcopy()

在前面List操作函数中也出现了，深浅复制。

13. string()

序列化为字符串，前面也讲过了。

14. max(),min(),count()

统统与List的函数类似。

可以看出，List和Dictionary共享很多函数，毕竟两者都是集合数据类型。难怪PHP直接把两者统一为同一种类型。下面给出Dictonary特有的函数的示例用法：
```
let dict = {"id":1, "name": '张三', "score": 98.5}
echo keys(dict)
echo values(dict)
echo items(dict)
echo len(dict)

echo get(dict, "name")
echo get(dict, "sex")

echo dict["sex"]

let dict["sex"] = '男'
echo dict["sex"]
```

结果:
```
['score', 'id', 'name']
[98.5, 1, '张三']
[['score', 98.5], ['id', 1], ['name', '张三']]
3
张三
0
Error detected while processing /root/t4.vim:
line   10:
E716: Key not present in Dictionary: sex
E15: Invalid expression: dict["sex"]
男
```

另外，我们发现vim并没有提供增加一个元素的函数，其实这没有必要，因为可以直接通过let dict["key"]=xxx来完成，上面的例子也演示了。

#### 2.4 Float 类型的操作

Float是VimScript中的最后一种数据类型，可能是后来加入的，所以排在最后。在非科学计算的编程领域，其实浮点数用的确实很少。虽然如此，它也是一个不可或缺的数据类型，这一节我们来看看vim提供了那些操纵Float类型的内建函数。

1. float2nr({expr})

把浮点数转换为整数，返回给定浮点数的整数部分。注意：这里不是四舍五入，而是所有小数都舍去。

2. abs({expr})

求一个浮点的绝对值。该函数也适用于整数。

3. round({expr})

对一个浮点数进行四舍五入。

4. ceil( {expr} )

对一个浮点数进行向大取整。 如ceil(2.1)=2， ceil(-2.8)=-2。

5. floor({expr})

对一个浮点数进行向小取整。

6. trunc({expr})

对一个浮点数舍去小数部分，这一点与float2nr（）相同，只是返回的不是整数而是浮点数。

7. log10({expr})

求以10为底数的给定浮点数的对数。如 log10(1000) = 3。

8. pw({x}, {y})

返回x的y次方。

9. sqrt({exprt})

返回浮点数的平方根。当expr是个负数时，返回NaN。（无效值）

10. sin({expr})

求正弦值。

11. cos（{expr}）

求余弦值。

12. atan({expr})

求反正切。

13. atan2({expr1}, {expr2})

求{expr1}/{exrp2}的反正切。此函数从7.3版本才提供。

示例代码：
```
echo float2nr(1.9)
echo round(1.9)
echo floor(1.9)
echo ceil(1.9)
echo trunc(1.9)
echo sin(30*3.14/180)
echo cos(60*3.14/180)
echo atan(-1)
echo pow(2,16)
echo sqrt(100)
echo log10(1000)
```

结果：
```
1
2.0
1.0
2.0
1.0
0.49977
0.50046
-0.785398
65536.0
10.0
3.0
```

