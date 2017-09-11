# 02\_C++11\_深入右值引用，move语义和完美转发

乍看起来，move语义使得你可以用廉价的move赋值替代昂贵的copy赋值，完美转发使得你可以将传来的任意参数转发给 其他函数，而右值引用使得move语义和完美转发成为可能。然而，慢慢地你发现这不那么简单，你发现std::move并没有move任何东西，完美转发也并不完美，而T&&也不一定就是右值引用……

### move语义

最原始的左值和右值定义可以追溯到C语言时代，左值是可以出现在赋值符的左边和右边，然而右值只能出现在赋值符的右边。在C++里，这种方法作为初步判断左值或右值还是可以的，但不是那么准确了。你要说C++中的右值到底是什么，这真的很难给出一个确切的定义。你可以对某个值进行取地址运算，如果不能得到地址，那么可以认为这是个右值。例如：

```cpp
int& foo();
foo() = 3; //ok, foo() is an lvalue

int bar();
int a = bar(); // ok, bar() is an rvalue
```

为什么要move语义呢？它可以让你写出更高效的代码。看下面代码：

```cpp
string foo();
string name("jack");
name = foo();
```

第三句赋值会调用string的赋值操作符函数，发生了以下事情：

首先要销毁name的字符串吧  
把foo()返回的临时字符串拷贝到name吧  
最后还要销毁foo()返回的临时字符串吧

这就显得很不高效，在C++11之前，你要想高效点，可以是swap交换资源。

C++11的move语义就是要做这事，这时重载move赋值操作符。

```cpp
string& string::operator=(string&& rhs);
```
move语义不仅仅用于右值，也用于左值。标准库提供了std::move方法，将左值转换成右值。因此，对于swap函数，我们可以这样实现：

```cpp
template<class T>
void swap(T& a, T& b)
{
    T temp(std::move(a));
    a = std::move(b);
    b = std::move(temp);
}
```

### 右值引用

string&& 这个类型就是所谓的右值引用，而把T&称之为左值引用。注意，不要见到T&&就认为是右值引用，例如，下面这个就不是右值引用：

```
T&& foo = T(); //右值引用
auto&& bar = foo; // 不是右值引用
```

实际上，T&&有两种含义，一种就是常见的右值引用；另一种是即可以是右值引用，也可以是左值引用，Scott Meyers把这种称为Universal Reference，后来C++委员把这个改成forwarding reference，毕竟forwarding reference只在某些特定上下文才出现。

有了右值引用，C++11增加了move构造和move赋值。考虑这个情况：

```cpp
void foo(X&& x)
{
  // ...
}
```

那么问题来了，x的类型是右值引用，指向一个右值，但x本身是左值还是右值呢？C++11对此做出了区分：

> Things that are declared as rvalue reference can be lvalues or rvalues. The distinguishing criterion is: if it has a name, then it is an lvalue. Otherwise, it is an rvalue.

由此可知，x是个左值。考虑到派生类的move构造，我们因这样写才正确：

```cpp
Derived(Derived&& rhs):Base(std::move(rhs) //std::move不可缺
{ ... }
```

有一点必须明白，那就是std::move不管接受的参数是lvalue,还是rvalue都返回rvalue。因此我们可以给出std::move的实现如下（很接近于标准实现）：

```cpp
template <typename T>
typename remove_reference<T>::type&& move(T&& t) 
{
    using RRefType = typename remove_reference<T>::type&&;
    return static_cast<RRefType>(t);
}
```

### 完美转发

假设有一个函数foo，我们写出如下函数，把接受到的参数转发给foo：

```cpp
template<class T>
void fwd(TYPE t)
{
    foo(t);
}
```

我们一个个来分析：

如果TYPE是T的话，假设foo的参数引用类型，我会修改传进来的参数，那么fwd(t)和foo(t)将导致不一样的效果。  
如果TYPE是T&的话，那么fwd传一个右值进来，没法接受，编译出错。  
如果TYPE是T&，而且重载个const T&来接受右值，看似可以，但如果多个参数呢，你得来个排列组合的重载，因此是不通用的做法。

你很难找到一个好方法来实现它，右值引用的引入解决了这个问题，在这种上下文时，它成为forwarding reference。 这就涉及到两条原则。第一条原则是引用折叠原则：

A& & 折叠成 A&  
A& && 折叠成 A&  
A&& & 折叠成 A&  
A&& && 折叠成 A&&

第二条是特殊模板参数推导原则：

1. 如果fwd传进的是个A类型的左值，那么T被决议为A&。  
2. 如果fwd传进的是个A类型的右值，那么T被决议为A。  

将两条原则结合起来，就可以实现完美转发。

```cpp
A x; 
fwd(x); //推导出fwd(A& &&) 折叠后fwd(A&)

A foo();
fwd(foo());//推导出fwd(A&& &&) 折叠后 fwd(A&&)
std::forward应用于forwarding reference，代码看起来如下：

template<class T>
void fwd(T&& t)
{
    foo(std::forward<T>(t));
}
```
要想展开完美转发的过程，我们必须写出forward的实现。接下来就尝试forward该如何实现，分析一下，std::forward是条件cast的，T的推导类型取决于传参给t的是左值还是右值。因此，forward需要做的事情就是当且仅当右值传给t时，也就是当T推导为非引用类型时,forward需要将t（左值）转成右值。forward可以如下实现:

```cpp
template<class T>
T&& forward(typename remove_reference<T>::type& t)
{
    return static_cast<T&&>(t);
}
```
现在来看看完美转发是怎么工作的，我们预期当传进fwd的参数是左值，从forward返回的是左值引用；传进的是右值，forward返回的是右值引用。假设传给fwd是A类型的左值，那么T被推导为A&:

```cpp
void fwd(A& && t)
{
    foo(std::forward<A&>(t));
}
```
forward<A&>实例化：

```cpp
A& && forward(typename remove_reference<A&>::type& t)
{
    return static_cast<A& &&>(t);
}
```

引用折叠后：

```cpp
A& forward(A& t)
{
    return static_cast<A&>(t);
}
```

可见，符合预期。再看看传入fwd是右值时，那么T被推导为A:

```cpp
void fwd(A && t)
{
    foo(std::forward<A>(t));
}
```

forward<A>实例化如下：

```cpp
A&& forward(typename remove_reference<A>::type& t)
{
    return static_cast<A&&>(t);
}
```
也就是：

```cpp
A&& forward(A& t)
{
    return static_cast<A&&>(t);
}
```

forward返回右值引用，很好，完全符合预期。

### 一些例外的说明

如果声明个指向引用的引用类型的变量，比如你写出如下代码：

```cpp
int a = 3;
auto & & b = a;
```

这是不合法，编译器会报错。再看看完美转发:

```cpp
void f(vector<int> vi);
f({1,2,3});//ok
fwd({1,2,3})//error
```

还有些其他情况，你需要明白，完美转发也不完美。

### 总结

C++11之前，auto\_ptr不能放入容器中，C++11的move语义解决了这个问题，unique\_ptr就是auto\_ptr的替代版。

