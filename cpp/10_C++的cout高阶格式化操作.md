# C++的cout高阶格式化操作

这篇文章主要讲解如何在C++中使用cout进行高级的格式化输出操作，包括数字的各种计数法（精度）输出，左或右对齐，大小写等等。通过本文，您可以完全脱离scanf/printf，仅使用cout来完成一切需要的格式化输入输出功能（从非性能的角度而言）。更进一步而言，您还可以在sstream、fstream上使用这些格式化操作，从而代替sprintf和fprintf函数。为方便描述，下文仅以cout为例进行介绍。

## 一、综述
cout是STL库提供的一个iostream实例，拥有ios_base基类的全部函数和成员数据。进行格式化操作可以直接利用setf/unsetf函数和flags函数。cout维护一个当前的格式状态，setf/unsetf函数是在当前的格式状态上追加或删除指定的格式，而flags则是将当前格式状态全部替换为指定的格式。cout为这个函数提供了如下参数（可选格式）：

* ios::dec  以10进制表示整数
* ios::hex  以16进制表示整数
* ios::oct  以8进制表示整数
* ios::showbase  为整数添加一个表示其进制的前缀
* ios::internal  在符号位和数值的中间插入需要数量的填充字符以使串两端对齐
* ios::left  在串的末尾插入填充字符以使串居左对齐
* ios::right  在串的前面插入填充字符以使串居右对齐
* ios::boolalpha  将bool类型的值以true或flase表示，而不是1或0
* ios::fixed  将符点数按照普通定点格式处理（非科学计数法）
* ios::scientific  将符点数按照科学计数法处理（带指数域）
* ios::showpoint  在浮点数表示的小数中强制插入小数点（默认情况是浮点数表示的整数不显示小数点）
* ios::showpos  强制在正数前添加+号
* ios::skipws  忽略前导的空格（主要用于输入流，如cin）
* ios::unitbuf  在插入（每次输出）操作后清空缓存
* ios::uppercase  强制大写字母

以上每一种格式都占用独立的一位，因此可以用“|”（位或）运算符组合使用。调用setf/unsetf或flags设置格式一般按如下方式进行：

```cpp 
cout.setf(ios::right | ios::hex); //设置16进制右对齐
cout.setf(ios::right, ios::adjustfield); //取消其它对齐，设置为右对齐
``` 

setf可接受一个或两个参数，一个参数的版本为设置指定的格式，两个参数的版本中，后一个参数指定了删除的格式。三个已定义的组合格式为：

* ios::adjustfield  对齐格式的组合位
* ios::basefield  进制的组合位
* ios::floatfield  浮点表示方式的组合位

设置格式之后，下面所有使用cout进行的输出都会按照指定的格式状态执行。但是如果在一次输出过程中需要混杂多种格式，使用cout的成员函数来处理就显得很不方便了。STL另提供了一套<iomanip>库可以满足这种使用方式。<iomanip>库中将每一种格式的设置和删除都进行了函数级的同名封装，比如fixed函数，就可以将一个ostream的对象作为参数，在内部调用setf函数对其设置ios::fixed格式后再返回原对象。此外<iomanip>还提供了setiosflags、setbase、setfill、setw、setprecision等方便的格式控制函数，下文会逐一进行介绍。大多数示例代码都会使用到<iomanip>，因此默认包含的头文件均为：
```cpp
#include <iomanip>
#include <iostream>
``` 

## 二、缩进
将输出内容按指定的宽度对齐，需要用到ios::right、ios::left、ios::internal和iomanip里的setw。其中setw用于指定要输出内容的对齐宽度。以下两段代码的结果完全相同，前面是一个浮点数-456.98，后面紧跟着一个字符串“The End”以及换行符“endl”。

代码一：
```cpp
#include <iomanip>
#include <iostream>
using namespace std;
int main(void) {
    cout.flags(ios::left); //左对齐
    cout << setw(10) << -456.98 << "The End" << endl;
    cout.flags(ios::internal); //两端对齐
    cout << setw(10) << -456.98 << "The End" << endl;
    cout.flags(ios::right); //右对齐
    cout << setw(10) << -456.98 << "The End" << endl;
    return 0;
}
``` 

代码二：
```cpp
#include <iomanip>
#include <iostream>
using namespace std;
int main(void) {
    cout << left << setw(10) << -456.98 << "The End" << endl; //左对齐
    cout << internal << setw(10) << -456.98 << "The End" << endl; //两端对齐
    cout << right << setw(10) << -456.98 << "The End" << endl; //右对齐
    return 0;
}
``` 

结果：
```cpp
-456.98   The End
-   456.98The End
   -456.98The End
```
 
这里要额外说明的一点是，setw函数会用当前的填充字符控制对齐位置，默认的填充字符是空格。可以通过<iomanip>的setfill来设置填充字符，比如下面的代码用字符“0”作为填充字符：
```cpp
#include <iomanip>
#include <iostream>
using namespace std;
int main(void) {
    cout << setfill('0') << setw(10) << 45698 << endl;
    return 0;
}
``` 

结果：
```cpp
0000045698
```
 
## 三、整数

输出整数的格式有按不同进制数出：ios::hex（16进制）、ios::dec（10进制）、ios::oct（8进制），也可强制其输出符号（正数也加上“+”号前缀），对于16进制的输出还可配合ios::uppercase使所有字母以大写表示。代码示例如下：
```cpp
#include <iomanip>
#include <iostream>
using namespace std;
int main(void) {
    cout.setf(ios::showpos | ios::uppercase);
    cout << hex << setw(4) << 12 << setw(12) << -12 << endl;
    cout << dec << setw(4) << 12 << setw(12) << -12 << endl;
    cout << oct << setw(4) << 12 << setw(12) << -12 << endl;
    cout.unsetf(ios::showpos | ios::uppercase);
    cout << hex << setw(4) << 12 << setw(12) << -12 << endl;
    cout << dec << setw(4) << 12 << setw(12) << -12 << endl;
    cout << oct << setw(4) << 12 << setw(12) << -12 << endl;
    return 0;
}
``` 

结果：
```cpp
   C    FFFFFFF4
 +12         -12
  14 37777777764
   c    fffffff4
  12         -12
  14 37777777764
```

利用<iomanip>的setbase函数同样可以设置整数的三种进制，参数分别为8、10和16，但使用起来比上面的方法还更复杂一些，除非是特殊的代码规范要求（有些规范要求避免将常量直接作为表达式），一般不建议使用setbase。此外，还可以利用ios::showbase来为整数的前面加一个表示进制的前缀，代码如下：
```cpp
#include <iomanip>
#include <iostream>
using namespace std;
int main(void) {
    cout << showbase << setw(4) << hex << 32 << setw(4) << oct << 32 << endl;
    cout << noshowbase << setw(4) << hex << 32 << setw(4) << oct << 32 << endl;
    return 0;
}
``` 

结果：
```cpp
0x20 040
  20  40
```

上面代码中的showbase/noshobase也可以用cout的setf来代替，其结果是完全相同的：
```cpp
#include <iomanip>
#include <iostream>
using namespace std;
int main(void) {
    cout.setf(ios::showbase);
    cout << setw(4) << hex << 32 << setw(4) << oct << 32 << endl;
    cout.unsetf(ios::showbase);
    cout << setw(4) << hex << 32 << setw(4) << oct << 32 << endl;
    return 0;
}
``` 

## 四、小数
小数可分为两种格式类型，一种是定点表示“ios::fixed”（不带指数域），另一种是科学计数法表示“ios::scientific”（带指数域）。与<iomanip>的setprecision配合使用，可以表示指定小数点后面的保留位数（四舍五入）。示例代码如下：
```cpp
#include <iomanip>
#include <iostream>
using namespace std;
int main(void) {
    cout.setf(ios::fixed);
    cout << setprecision(0) << 12.05 << endl;
    cout << setprecision(1) << 12.05 << endl;
    cout << setprecision(2) << 12.05 << endl;
    cout << setprecision(3) << 12.05 << endl;
    cout.setf(ios::scientific, ios::floatfield);
    cout << setprecision(0) << 12.05 << endl;
    cout << setprecision(1) << 12.05 << endl;
    cout << setprecision(2) << 12.05 << endl;
    cout << setprecision(3) << 12.05 << endl;
    return 0;
}
``` 

结果：
```cpp
12
12.1
12.05
12.050
1.205000e+001
1.2e+001
1.21e+001
1.205e+001
```

需要注意的是，有时会因为机器的精度问题导致四舍五入的结果不正确。这种问题一般需要手动修正，见如下代码示例：
```cpp
#include <iomanip>
#include <iostream>
using namespace std;
int main(void) {
    cout << fixed << setprecision(1) << 2.05 << endl;
    cout << fixed << setprecision(1) << 2.05 + 1e-8 << endl;
    return 0;
}
``` 

结果：
```cpp
2.0
2.1
```

## 四、字符串
字符串的输出处理主要是对齐，这一点在第二部分已经介绍过了，下面主要介绍字符串的输入方法。为了方便起见，我们使用<string>库。在输入字符串时，可以利用<string>库提供的getline函数读取整行数据。getline函数有两个版本，第一个版本有两个参数，第一个参数指定输入流（比如cin），第二个参数指定一个string对象。getline会读取屏幕上输入的字符，直到遇到换行符“\n”为止；第二个版本有三个参数，前两个与第一个版本相同，第三个参数为指定的结束字符。注意，getline不会读入默认或指定的结束字符，但在调用之后读取的位置已经跳过结束字符。调用示例代码如下：
```cpp
#include <iomanip>
#include <iostream>
#include <string>
using namespace std;
int main(void) {
    string str1, str2;
    getline(cin, str1);
    cin >> str2;
    cout << str1 << endl << str2 << endl;
    return 0;
}
``` 

输入：
```cpp
   abc
   abc
```

结果：
```cpp
   abc
abc
```

## 五、缓冲区

由于调用系统函数在屏幕上逐个显示字符是很慢的，因此cin/cout为了加快速度使用缓冲区技术，粗略的讲就是暂时不输出指定的字符，而是存放在缓冲区中，在合适的时机一次性输出到屏幕上。如果单纯使用C++的输入/输出流来操作字符是不存在同步的问题的，但是如果要和C标准库的stdio库函数混合使用就必须要小心的处理缓冲区了。如果要与scanf和printf联合使用，务必在调用cout前加上cout.sync_with_stdio()，设置与stdio同步，否则输出的数据顺序会发生混乱。

flush和endl都会将当前缓冲区中的内容立即写入到屏幕上，而unitbuf/nounitbuf可以禁止或启用缓冲区。示例代码如下：
```cpp
#include <iomanip>
#include <iostream>
using namespace std;
int main(void) {
    cout << 123 << flush << 456 << endl;
    cout << unitbuf << 123 << nounitbuf << 456 << endl;
    return 0;
}
``` 

结果：
```cpp
123456
123456
```

## 六、综合使用
示例代码：
```cpp
#include <iomanip>
#include <iostream>
#include <string>
using namespace std;
struct COMMODITY { string Name; int Id; int Cnt; double Price; };
int main(void) {
    COMMODITY cmd[] = {
        {"Fruit", 0x101, 50, 5.268},
        {"Juice", 0x102, 20, 8.729},
        {"Meat", 0x104, 30, 10.133},
    };
    cout << left << setw(8) << "NAME" << right << setw(8) << "ID";
    cout << right << setw(8) << "COUNT" << right << setw(8) << "PRICE" << endl;
    for (int i = 0; i < sizeof(cmd) / sizeof(cmd[0]); ++i) {
        cout << left << setw(8) << cmd[i].Name;
        cout << right << hex << showbase << setw(8) << cmd[i].Id;
        cout << dec << noshowbase << setw(8) << cmd[i].Cnt;
        cout << fixed << setw(8) << setprecision(2) << cmd[i].Price << endl;
    }
    return 0;
}
``` 

结果：
```cpp
NAME          ID   COUNT   PRICE
Fruit      0x101      50    5.27
Juice      0x102      20    8.73
Meat       0x104      30   10.13
```



