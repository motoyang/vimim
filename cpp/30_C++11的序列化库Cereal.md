# 30\_C++11的序列化库Cereal

Cereal是一个只有头文件的C++11序列化库，支持将自定义数据类型使用压缩二进制、XML、JSON文件存储。Cereal是一个轻量级、快速，且极易扩展的库。特别的是Cereal不依赖任何三方库，非常容易使用。

## 全面支持C++11

Cereal几乎支持C++11标准中的所有类型，不仅如此还支持继承和多态两种特性。但是由于Cereal设计的初衷是轻量、快速，所以其在对象跟踪方面的性能与Boost有较大差异。因此，Cereal并不支持指针和引用，但是支持智能指针（例如`std::shared_ptr`、`std::unique_ptr`）。

## Cereal支持大部分C++11的编译器 

由于Cereal使用了大量C++11中的新特性，因此需要一个能支持C++11的编译器。Cereal已经支持g++4.7.3、chang++3.3、和MSVC2013（及新版）。Cereal也许能在较老版本的编译器上工作，例如ICC，但是我们并不推崇和建议尝试。注意，当使用g++和chang++时，Cereal需要libstdc++和libc++支持。

## 简洁快速

经过简单的性能测试，对于简单的数据类型，Cereal比Boost的序列化库更快（包括其他序列化库），并且在二进制存储时使用更少的存储空间。Cereal使用了高效的XML、JSON解析器和生成器。与Boost相比，Cereal更简单和更容易使用。

## 易扩展 

Cereal具有非常优秀的二进制、XML、JSON序列化标准库。如果你想对其进行扩充，Cereal将非常适合您的使用。

## 可测试 

可喜可贺！为了保证Cereal能够正常完成指定的工作，我们编写了基本的单元测试代码（已经完成了部分测试）。测试单元的编译需要Boost unit test framework。

## 简单易用

Cereal使用非常简单，只需要Include头文件和编写一个serialization函数。Cereal具有非常完善的文档。当您在编译代码时，Cereal竭尽全力提供足够多的语法提示（自己翻译的：descriptive static assertions ）。

## 语法简易 

如果您使用过Boost，或者计划使用Boost，那么使用Cereal并不会对你造成较大困扰。Cereal会寻找定义在数据结构中的serialization函数，当然serialization函数也可以是非成员函数。与Boost不同，Cereal并不需要指定serialization函数，而且也会在编译时提示您的错误。最后，如果您已经使用过Boost，请移步到“Boost到Cereal和的过渡”。
```cpp
#include <cereal/types/unordered_map.hpp>
#include <cereal/types/memory.hpp>
#include <cereal/archives/binary.hpp>
#include <fstream>

struct MyRecord
{
  uint8_t x, y;
  float z;
  //第一种序列化方式
  template <class Archive>
  void serialize( Archive & ar )
  {
    ar( x, y, z );
  }
};

struct SomeData
{
  int32_t id;
  std::shared_ptr<std::unordered_map<uint32_t, MyRecord>> data;

  // 第二种序列化方式
  template <class Archive>
  void save( Archive & ar ) const
  {
    ar( data );
  }

  template <class Archive>
  void load( Archive & ar )
  {
    static int32_t idGen = 0;
    id = idGen++;
    ar( data );
  }
};

int main()
{
  std::ofstream os("out.cereal", std::ios::binary);
  cereal::BinaryOutputArchive archive( os );

  SomeData myData;
  archive( myData );

  return 0;
}
```

## 自由协议 

Cereal使用了BSD协议，可满足大部分人群使用需求。

## Working with a C style array

Anyway, here's a working example of serializing a C style array:
```cpp
#include <cereal/archives/binary.hpp>
#include <iostream>

int main()
{
  std::stringstream ss;

  {
    cereal::BinaryOutputArchive ar(ss);
    std::uint8_t data[] = {1, 2, 3};
    ar( cereal::binary_data( data, sizeof(std::uint8_t) * 3 ) );
  }

  {
    cereal::BinaryInputArchive ar(ss);
    std::uint8_t data[3];
    ar( cereal::binary_data( data, sizeof(std::uint8_t) * 3 ) );

    for( int i : data )
      std::cout << i << " ";
  }

  return 0;
}
```

If you wanted to serialize a C style array to a text based archive, or if your array wasn't over POD types, you would need to iterate over each object and serialize it individually.


