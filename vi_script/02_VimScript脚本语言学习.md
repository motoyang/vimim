## 02_VimScript脚本语言学习
---

条件和循环结构是几乎所有的编程语言都提供的基本功能，VimScript也不例外。

### 1 条件语句
由于VimScript中并没有布尔类型，所以对真和假的判断依据就是是否为Number类型的0，如果是则为假，否则为真。当进行比较运算和逻辑运算时，其结果为真则用1表示，否则用0表示。这一点与C语言类似。

不同之处在于：C中只能使用整数做条件，而VimScript中除了Number还可以使用String类型，因为String可以自动转换为Number。

条件表达式不需要使用（）包裹，当然加上也没有错误，如 if (3>2) 与 if 3>2 是相同的。

#### 1.1 if else
if 语句是基本的条件语句，使用方法与C大致相同。
```
" 条件语句  
" if else endif  
let a = 2  
let b = 1  
if(a > b)  
    echo "a大于b"  
else  
    echo "a不大于b"  
endif  
  
" if endif  
let score=87.2  
if(score >= 60)  
    echo "及格"  
endif  
  
" if elseif elseif ... else endif  
if(score > 90)  
    echo "优秀"  
elseif(score > 80)  
    echo "良好"  
elseif(score >= 60)  
    echo "及格"  
else  
    echo "不及格"  
endif  
  
" 条件表达式最后结果必为Number类型  
if("ture")  " 字符串自动转换为Number, 此处转换后是0  
    echo "true"  
else  
    echo "false"  
endif  
```

#### 1.2 ?: 三元运算符
这个三元运算符与C中的使用方式相同。

```
let a = 80  
let result = a > 60 ? '及格' : '不及格'  
echo result  
[plain] view plain copy
```

VimScript目前不支持switch case语法。

### 2 循环语句
VimScript支持while和for in两大类循环，不支持do while。条件表达式也不需要括号包裹。

#### 2.1 while
```
let i=100  
let sum = 0  
while i>0  
    let sum +=  i  
    let i -= 1  
endwhile  
echo sum  
```

注意，VimScript不支持一元运算符++和--。

#### 2.3 for in
```
let sum = 0  
for i in range(1,100)  
    let sum += i  
endfor  
echo sum  
```

上面代码中range()函数返回一个List类型的值[1,2,3,....,100]。

无论是在while还是for in语句中，都可以使用continue和break来改变循环，这与C完全一样。
