# 50\_Boost\_Serialization介绍

程序开发中，序列化是经常需要用到的。像一些相对高级语言，比如JAVA, C#都已经很好的支持了序列化，那么C++呢？当然一个比较好的选择就是用Boost，这个号称C++准标准库的东西。

什么时候需要序列化呢？举个例子，我们定义了一个class，比如：
```cpp
class CCar  
{  
public:  
    void SetName(std::string& strName){m_strName = strName;}  
    std::string GetName() const{return m_strName;}  
private:  
    std::string m_strName;  
};  
```

然后我们想把这个类的一个对象保存到文件中或者通过网络发出去，怎么办呢？答案就是：把这个对象序列化，然后我们可以得到一个二进制字节流，或者XML格式表示等等。

这样我们就可以保存这个对象到文件中或者通过网络发出去了。把序列化的数据进行反序列化，就可以得到一个CCar对象了。

Boost已经很好的支持了序列化这个东西，很好很强大。

Boost网站上有介绍： http://www.boost.org/doc/libs/1_51_0/libs/serialization/doc/index.html

对于序列化，Boost是这么定义的：

> Here, we use the term "serialization" to mean the reversible deconstruction of an arbitrary set of C++ data structures to a sequence of bytes.  Such a system can be used to reconstitute an equivalent structure in another program context.  Depending on the context, this might used implement object persistence, remote parameter passing or other facility. In this system we use the term"archive" to refer to a specific rendering of this stream of bytes.  This could be a file of binary data, text data,  XML, or some other created by the user of this library.

这段英文很简单，我相信大多数程序员都能看的懂。

基本上Boost序列化可以分为两种模式：侵入式（intrusive）和非侵入式（non-intrusive）

 

### 侵入式（intrusive）

先来看看侵入式。我们先来定义一个类，这个类支持序列化：
```cpp
class CMyData  
{  
private:  
    friend class boost::serialization::access;  
  
    template<class Archive>  
    void serialize(Archive& ar, const unsigned int version)  
    {  
        ar & _tag;  
        ar & _text;  
    }  
  
public:  
    CMyData():_tag(0), _text(""){}  
  
    CMyData(int tag, std::string text):_tag(tag), _text(text){}  
  
    int GetTag() const {return _tag;}  
    std::string GetText() const {return _text;}  
  
private:  
    int _tag;  
    std::string _text;  
};  
```

其中，我们可以看到这些代码：
```cpp
	friend class boost::serialization::access;  
  
    template<class Archive>  
    void serialize(Archive& ar, const unsigned int version)  
    {  
        ar & _tag;  
        ar & _text;  
    }  
```

这些代码就是用来实现序列化的，这些代码存在于类CMyData中，也就是为什么称这种模式是“侵入式”的原因了。

看看怎么把这个对象序列化。这里，我把这个对象以二进制的方式保存到了一个ostringstream中了，当然也可以保存为其他形式，比如XML。也可以保存到文件中。代码都是类似的。
```cpp
void TestArchive1()  
{  
    CMyData d1(2012, "China, good luck");  
    std::ostringstream os;  
    boost::archive::binary_oarchive oa(os);  
    oa << d1;//序列化到一个ostringstream里面  
  
    std::string content = os.str();//content保存了序列化后的数据。  
  
    CMyData d2;  
    std::istringstream is(content);  
    boost::archive::binary_iarchive ia(is);  
    ia >> d2;//从一个保存序列化数据的string里面反序列化，从而得到原来的对象。  
  
    std::cout << "CMyData tag: " << d2.GetTag() << ", text: " << d2.GetText() << "\n";  
}  
```

先生成一个CMyData的对象，然后序列化保存到一个ostringstream中，接着再把这个序列化的数据反序列化，得到原来的对象，打印出来，我们会发现反序列化的对象的数据成员跟序列化前的对象一模一样。哈哈，成功了，简单吧。至于Boost怎么实现这个过程的，看Boost源代码吧，Boost的网站上也有一些介绍。Boost确实设计的很巧妙，不得不佩服那帮家伙。

那么可以序列化CMyData的子类吗，答案是肯定的。其实很简单就是在子类的序列化函数里面先序列化基类的。看看代码就明白了：
```cpp
class CMyData_Child: public CMyData  
{  
private:  
    friend class boost::serialization::access;  
  
    template<class Archive>  
    void serialize(Archive& ar, const unsigned int version)  
    {  
        // serialize base class information  
        ar & boost::serialization::base_object<CMyData>(*this);  
        ar & _number;  
    }  
  
  
public:  
    CMyData_Child():_number(0.0){}  
  
    CMyData_Child(int tag, std::string text, float number):CMyData(tag, text), _number(number){}  
  
    float GetNumber() const{return _number;}  
  
private:  
    float _number;  
};  
  
void TestArchive3()  
{  
    CMyData_Child d1(2012, "China, good luck", 1.2);  
    std::ostringstream os;  
    boost::archive::binary_oarchive oa(os);  
    oa << d1;//序列化到一个ostringstream里面  
  
    std::string content = os.str();//content保存了序列化后的数据。  
  
    CMyData_Child d2;  
    std::istringstream is(content);  
    boost::archive::binary_iarchive ia(is);  
    ia >> d2;//从一个保存序列化数据的string里面反序列化，从而得到原来的对象。  
  
    std::cout << "CMyData_Child tag: " << d2.GetTag() << ", text: " << d2.GetText() << ", number: "<<d2.GetNumber() << "\n";  
}  
```

### 非侵入式（non-intrusive）

侵入式的缺点就是需要在class里面加一些代码，那么有时候可能这个class已经存在了，或者我们并不想往里面加入这么些代码，那么怎么办呢？ok，轮到非侵入式出场了。

比方说我们有这么个类：
```cpp
class CMyData2  
{  
public:  
    CMyData2():_tag(0), _text(""){}  
  
    CMyData2(int tag, std::string text):_tag(tag), _text(text){}  
  
    int _tag;  
    std::string _text;  
};  
那么我们可以这么序列化：
[cpp] view plain copy
namespace boost {  
    namespace serialization {  
  
        template<class Archive>  
        void serialize(Archive & ar, CMyData2 & d, const unsigned int version)  
        {  
            ar & d._tag;  
            ar & d._text;  
        }  
  
    } // namespace serialization  
} // namespace boost  
```

 然后调用还是跟侵入式一模一样，看：
```cpp
void TestArchive2()  
{  
    CMyData2 d1(2012, "China, good luck");  
    std::ostringstream os;  
    boost::archive::binary_oarchive oa(os);  
    oa << d1;//序列化到一个ostringstream里面  
  
    std::string content = os.str();//content保存了序列化后的数据。  
  
    CMyData2 d2;  
    std::istringstream is(content);  
    boost::archive::binary_iarchive ia(is);  
    ia >> d2;//从一个保存序列化数据的string里面反序列化，从而得到原来的对象。  
  
    std::cout << "CMyData2 tag: " << d2._tag << ", text: " << d2._text << "\n";  
}  
```

成功。跟侵入式相比，非侵入式省去了在具体类里面加入序列化代码。但是我们看看非侵入式模式里面的类的定义，我们会发现我们把数据成员搞成public的了。这是为什么呢？看看这个就明白了：
```cpp
template<class Archive>  
        void serialize(Archive & ar, CMyData2 & d, const unsigned int version)  
        {  
            ar & d._tag;  
            ar & d._text;  
        }  
```

原来序列化函数需要访问数据成员。这就是非侵入式的一个缺点了：需要把数据成员暴露出来。通过直接访问数据成员也好，通过函数访问也好，总之需要这个类把数据成员暴露出来，这样序列化函数才能访问。世界上没有十全十美的东西，有时我们得到一个东西，往往会失去另外一个东西，不是吗？

侵入式和非侵入式各有各的用处，看具体情况来决定用哪个了。

非侵入式可以支持子类序列化吗？可以。跟侵入式一样，其实也就是先序列化一下基类，然后再序列化子类的数据成员。看代码：
```cpp
class CMyData2_Child: public CMyData2  
{  
public:  
    CMyData2_Child():_number(0.0){}  
  
    CMyData2_Child(int tag, std::string text, float number):CMyData2(tag, text), _number(number){}  
  
    float _number;  
};  
  
namespace boost {  
    namespace serialization {  
  
        template<class Archive>  
        void serialize(Archive & ar, CMyData2_Child & d, const unsigned int version)  
        {  
            // serialize base class information  
            ar & boost::serialization::base_object<CMyData2>(d);  
            ar & d._number;  
        }  
  
    } // namespace serialization  
} // namespace boost  
  
void TestArchive4()  
{  
    CMyData2_Child d1(2012, "test non-intrusive child class", 5.6);  
    std::ostringstream os;  
    boost::archive::binary_oarchive oa(os);  
    oa << d1;//序列化到一个ostringstream里面  
  
    std::string content = os.str();//content保存了序列化后的数据。  
  
    CMyData2_Child d2;  
    std::istringstream is(content);  
    boost::archive::binary_iarchive ia(is);  
    ia >> d2;//从一个保存序列化数据的string里面反序列化，从而得到原来的对象。  
  
    std::cout << "CMyData2_Child tag: " << d2._tag << ", text: " << d2._text << ", number: "<<d2._number<<"\n";  
}  
``` 

好了，以上就是序列化的简单用法。接下里我们来重点关注一下数据成员的序列化，假如我们的类里面有指针，那么还能序列化吗？比如下面的代码，会发生什么事？

### 序列化指针数据成员
```cpp
class CMyData  
{  
private:  
    friend class boost::serialization::access;  
  
    template<class Archive>  
    void serialize(Archive& ar, const unsigned int version)  
    {  
        ar & _tag;  
        ar & _text;  
    }  
  
public:  
    CMyData():_tag(0), _text(""){}  
  
    CMyData(int tag, std::string text):_tag(tag), _text(text){}  
  
    int GetTag() const {return _tag;}  
    std::string GetText() const {return _text;}  
  
private:  
    int _tag;  
    std::string _text;  
};  

class CMyData_Child: public CMyData  
{  
private:  
    friend class boost::serialization::access;  
  
    template<class archive="">  
    void serialize(Archive& ar, const unsigned int version)  
    {  
        // serialize base class information  
        ar & boost::serialization::base_object<cmydata>(*this);  
        ar & _number;  
    }  
  
  
public:  
    CMyData_Child():_number(0.0){}  
  
    CMyData_Child(int tag, std::string text, float number):CMyData(tag, text), _number(number){}  
  
    float GetNumber() const{return _number;}  
  
private:  
    float _number;  
};  

class CMyData_Container  
{  
private:  
    friend class boost::serialization::access;  
  
    template<class Archive>  
    void serialize(Archive& ar, const unsigned int version)  
    {  
        for(int i = 0; i < 3; i++)  
        {  
            ar & pointers[i];  
        }  
    }  

public:  
    CMyData* pointers[3];  
};  
  
void TestPointerArchive()  
{  
    std::string content;  
    {  
        CMyData d1(1, "a");  
        CMyData_Child d2(2, "b", 1.5);  
  
        CMyData_Container containter;  
        containter.pointers[0] = &d1;  
        containter.pointers[1] = &d2;  
        containter.pointers[2] = &d1;  
  
        std::ostringstream os;  
        boost::archive::binary_oarchive oa(os);  
        oa << containter;  
  
        content = os.str();  
    }  
  
    //反序列化  
    {  
        CMyData_Container container;  
        std::istringstream is(content);  
        boost::archive::binary_iarchive ia(is);  
        ia >> container;  
  
        for (int i = 0; i < 3; i++)  
        {  
            CMyData* d = container.pointers[i];  
            std::cout << "pointer" << i + 1 <<": " << d->GetText() << "\n";  
  
            if (i == 1)  
            {  
                CMyData_Child* child = reinterpret_cast<CMyData_Child*>(d);  
                std::cout << "pointer" << i + 1 <<", number: " << child->GetNumber() << "\n";  
            }  
        }  
    }  
}
```

注意，我们在CMyData\_Container对象里面放进去了3个指针，其中第二个指针是CMyData的子类。

然后进行序列化，再反序列化，我们会发现，第一个，第三个指针输出了正确的信息，然而第二个指针有点问题，本身我们存进去的时候是个CMyData\_Child 对象，通过测试我们可以发现，CMyData\_Child的基类部分，我们可以正确的输出，但是CMyData\_Child的成员\_number,却得不到正确信息。这是个问题。

也就是说，序列化指针是可以的，但是需要注意多态的问题。假如我们不需要考虑多态，那么以上的代码就可以正常工作了。但是如果要考虑多态的问题，那么就得特殊处理了。下面再来介绍序列化多态指针。

### 序列化多态指针数据成员

上一个章节里面演示了如果序列化指针成员，但是有个问题，就是当基类指针指向一个派生类对象的时候，然后序列化这个指针，那么派生类的信息就被丢掉了。这个很不好。那么怎么来解决这个问题呢？很幸运，Boost的开发人员已经考虑到了这个问题。再一次感受到Boost的强大。

有两种方法可以解决这个问题：

1. registration  
2. export

具体可以参考： http://www.boost.org/doc/libs/1_51_0/libs/serialization/doc/serialization.html#derivedpointers

这里我们介绍第二种方式，这种方式比较简单，也用的比较好。就是通过一个宏把派生类给命名一下。

这个关键的宏是：`BOOST_CLASS_EXPORT_GUID`

相关解释：

> The macro BOOST_CLASS_EXPORT_GUID associates a string literal with a class. In the above example we've used a string rendering of the class name. If a object of such an "exported" class is serialized through a pointer and is otherwise unregistered, the "export" string is  included in the archive. When the archive  is later read, the string literal is used to find the class which  should be created by the serialization library. This permits each class to be in a separate header file along with its  string identifier. There is no need to maintain a separate "pre-registration"  of derived classes that might be serialized.  This method of registration is referred to as "key export".

如何使用这个神奇的宏`BOOST_CLASS_EXPORT_GUID`来实现序列化指向派生类的指针呢？先给出代码：
```cpp
class CMyData  
{  
private:  
    friend class boost::serialization::access;  
  
    template<class Archive>  
    void serialize(Archive& ar, const unsigned int version)  
    {  
        ar & _tag;  
        ar & _text;  
    }  
  
      
public:  
    CMyData():_tag(0), _text(""){}  
  
    CMyData(int tag, std::string text):_tag(tag), _text(text){}  
    virtual ~CMyData(){}  
  
    int GetTag() const {return _tag;}  
    std::string GetText() const {return _text;}  
  
private:  
    int _tag;  
    std::string _text;  
};  
  
class CMyData_Child: public CMyData  
{  
private:  
    friend class boost::serialization::access;  
  
    template<class Archive>  
    void serialize(Archive& ar, const unsigned int version)  
    {  
        // serialize base class information  
        ar & boost::serialization::base_object<CMyData>(*this);  
        ar & _number;  
    }  
  
  
public:  
    CMyData_Child():_number(0.0){}  
  
    CMyData_Child(int tag, std::string text, float number):CMyData(tag, text), _number(number){}  
  
    float GetNumber() const{return _number;}  
  
private:  
    float _number;  
};  
  
BOOST_CLASS_EXPORT_GUID(CMyData_Child, "CMyData_Child")  
  
class CMyData_Container  
{  
private:  
    friend class boost::serialization::access;  
  
    template<class Archive>  
    void serialize(Archive& ar, const unsigned int version)  
    {  
        for(int i = 0; i < 3; i++)  
        {  
            ar & pointers[i];  
        }  
    }  
public:  
    CMyData* pointers[3];  
};  
  
void TestPointerArchive()  
{  
    std::string content;  
    {  
        CMyData d1(1, "a");  
        CMyData_Child d2(2, "b", 1.5);  
  
        CMyData_Container containter;  
        containter.pointers[0] = &d1;  
        containter.pointers[1] = &d2;  
        containter.pointers[2] = &d1;  
  
        std::ostringstream os;  
        boost::archive::binary_oarchive oa(os);  
        oa << containter;  
  
        content = os.str();  
    }  
  
    {  
        CMyData_Container container;  
        std::istringstream is(content);  
        boost::archive::binary_iarchive ia(is);  
        ia >> container;  
  
        for (int i = 0; i < 3; i++)  
        {  
            CMyData* d = container.pointers[i];  
            std::cout << "pointer" << i + 1 <<": " << d->GetText() << "\n";  
  
            if (i == 1)  
            {  
                CMyData_Child* child = reinterpret_cast<CMyData_Child*>(d);  
                std::cout << "pointer" << i + 1 <<", number: " << child->GetNumber() << "\n";  
            }  
        }  
    }  
}  
```

这次我们可以正确的读取到第二个指针指向的对象了，可以看到\_number的争取值了。

把代码和上个版本想比较，我们会发现2个不同：

1. CMyData类里面多了个虚的析构函数；  
2. 调用BOOST_CLASS_EXPORT_GUID给派生类CMyData_Child绑定一个字符串。

第二点很容易理解，就是给某个派生类命名一下，这样就可以当作一个key来找到相应的类。那么第一点为什么要增加一个虚析构函数呢？是我无意中添加的吗？当然不是，其实这个是序列化指向派生类的指针的其中一个关键。先看Boost网站上面的一段描述：

> It turns out that the kind of object serialized depends upon whether the base class (base in this case) is polymophic or not. Ifbase is not polymorphic, that is if it has no virtual functions, then an object of the typebasewill be serialized. Information in any derived classes will be lost. If this is what is desired (it usually isn't) then no other effort is required.

> If the base class is polymorphic, an object of the most derived type (derived_oneorderived_twoin this case) will be serialized.  The question of which type of object is to be serialized is (almost) automatically handled by the library.

ok，通过这段描述，我们发现Boost序列化库会判断基类是不是多态的。判断的依据就是这个基类里面有没有虚函数。我们知道，当一个类里面有虚函数的时候，C++编译器会自动给这个类增加一个成员：\_vfptr,就是虚函数表指针。我没有花太多时间去看Boost有关这部分的源代码，但是我猜测Boost是根据这个\_vfptr来判断是需要序列化基类，还是派生类的。我们增加一个虚析构函数的目的也就是让CMyData产生一个\_vfptr。我们可以试一下把上面的代码里面的析构函数改成非虚的，那么派生类序列化就会失败，跟上一个章节得到相同的结果。至于Boost怎么知道该序列化哪个派生类，相信这个是`BOOST_CLASS_EXPORT_GUID`的功劳，至于怎么实现，还是需要看源代码，但是我自己没有仔细研究过，有兴趣的朋友可以学习Boost的源代码。Boost的设计很巧妙，我们可以学到不少东西。当然这个得有时间细细学习。好了，序列化指向派生类指针就2个要点：

1. 让Boost知道基类是多态的，其实就是确保基类里面有个虚函数；  
2. 通过`BOOST_CLASS_EXPORT_GUID`给派生类绑定一个字符串，当作一个key。

至于第一种序列化指向派生类的基类指针：registration，可以参考http://www.boost.org/doc/libs/1_51_0/libs/serialization/doc/serialization.html#derivedpointers，上面讲的非常清楚。我本人很少使用这种方式，这里也就略过不讲了。

### 序列化数组

一个小细节，上面讲到的序列化指针章节里面，我们看到代码：
```cpp
class CMyData_Container  
{  
private:  
    friend class boost::serialization::access;  
  
    template<class Archive>  
    void serialize(Archive& ar, const unsigned int version)  
    {  
        for(int i = 0; i < 3; i++)  
        {  
            ar & pointers[i];  
        }  
    }  
public:  
    CMyData* pointers[3];  
};  
```

其中的序列化函数里面有个for循环，难道每次序列化一个数组都需要弄一个for语句吗，这个是不是可以改进呢？答案是肯定的。Boost自己会检测数组。也就是说我们可以把代码改成下面的形式：
```cpp
class CMyData_Container  
{  
private:  
    friend class boost::serialization::access;  
  
    template<class Archive>  
    void serialize(Archive& ar, const unsigned int version)  
    {  
        ar & pointers;  
    }  
public:  
    CMyData* pointers[3];  
};  
```

代码短了很多，方便吧。
 
### 支持STL容器

 上面我们使用了一个普通数组来保存指针，我相信在平常写程序过程中，大家都会使用STL容器，比如list，map，array等等。至少我自己是经常使用的。那么Boost序列化库可以序列化STL容器吗？很幸运，Boost序列化库已经支持了STL容器。原话是：

> The above example uses an array of members.  More likely such an application would use an STL collection for such a purpose. The serialization library contains code for serialization of all STL classes.  Hence, the reformulation below will also work as one would expect.

我们一开始就是用std::string作为CMyData的一个成员，我们不需要做任何工作就可以直接序列化std::string,这是因为Boost序列化库已经支持std::string了。从上面的英文描述里面可以看到Boost serialization库可以支持所有STL类，神奇吧。至少我本人经常使用std::list, vector, map, string等，都可以正常工作。下面的代码使用std::vector代替了普通数组，可以正常工作。
```cpp
class CMyData  
{  
private:  
    friend class boost::serialization::access;  
  
    template<class Archive>  
    void serialize(Archive& ar, const unsigned int version)  
    {  
        ar & _tag;  
        ar & _text;  
    }  
  
      
public:  
    CMyData():_tag(0), _text(""){}  
  
    CMyData(int tag, std::string text):_tag(tag), _text(text){}  
    virtual ~CMyData(){}  
  
    int GetTag() const {return _tag;}  
    std::string GetText() const {return _text;}  
  
private:  
    int _tag;  
    std::string _text;  
};  
  
class CMyData_Child: public CMyData  
{  
private:  
    friend class boost::serialization::access;  
  
    template<class Archive>  
    void serialize(Archive& ar, const unsigned int version)  
    {  
        // serialize base class information  
        ar & boost::serialization::base_object<CMyData>(*this);  
        ar & _number;  
    }  
  
public:  
    CMyData_Child():_number(0.0){}  
  
    CMyData_Child(int tag, std::string text, float number):CMyData(tag, text), _number(number){}  
  
    float GetNumber() const{return _number;}  
  
private:  
    float _number;  
};  
  
BOOST_CLASS_EXPORT_GUID(CMyData_Child, "CMyData_Child")  
  
//Ê¹ÓÃSTLÈÝÆ÷  
class CMyData_ContainerSTL  
{  
private:  
    friend class boost::serialization::access;  
  
    template<class Archive>  
    void serialize(Archive& ar, const unsigned int version)  
    {  
        ar & vPointers;  
    }  
public:  
    std::vector<CMyData*> vPointers;  
};  

void TestPointerArchiveWithSTLCollections()  
{  
    std::string content;  
    {  
        CMyData d1(1, "parent obj");  
        CMyData_Child d2(2, "child obj", 2.5);  
  
        CMyData_ContainerSTL containter;  
        containter.vPointers.push_back(&d1);  
        containter.vPointers.push_back(&d2);  
        containter.vPointers.push_back(&d1);  
          
  
        std::ostringstream os;  
        boost::archive::binary_oarchive oa(os);  
        oa << containter;  
  
        content = os.str();  
    }  
  
    //·´ÐòÁÐ»¯  
    {  
        CMyData_ContainerSTL container;  
        std::istringstream is(content);  
        boost::archive::binary_iarchive ia(is);  
        ia >> container;  
  
        std::cout<<"Test STL collections:\n";  
        BOOST_FOREACH(CMyData* p, container.vPointers)  
        {  
            std::cout << "object text: " << p->GetText() << "\n";  
  
            CMyData_Child* child = dynamic_cast<CMyData_Child*>(p);  
            if (child)  
            {  
                std::cout << "child object number: " << child->GetNumber() << "\n";  
            }  
        }  
    }  
}  
```

一不小心就用到了`BOOST_FOREACH`,看来这个确实很好用啊，呵呵。省去了写很长的iterator来遍历整个vector。

### class版本

再来考虑一个问题，比方说现在我们程序升级了，然后把某个类给升级了一下，加了一个成员，那么之前保存的序列化的数据还能匹配到新的类吗？看一下序列化函数，我们会发现这个序列化函数有个参数，叫做version
```cpp
template<class Archive>
 void serialize(Archive& ar, const unsigned int version)
```

通过这个参数，我们就可以解决class版本的问题。看这段描述

> In general, the serialization library stores a version number in the archive for each class serialized.  By default this version number is 0. When the archive is loaded, the version number under which it was saved is read.

也就是说如果我们不刻意指定version，那么Boost序列化库就会默认设置为0并且保存到序列化结果中。

如果我们要标记不同的class版本，可以使用宏`BOOST_CLASS_VERSION`，比如
```cpp
BOOST_CLASS_VERSION(CMyData, 1)
```

 具体这里就不举例了。参考Boost说明。

### save和load分开

 一直到现在我们都是用了一个序列化函数
```cpp
template<class Archive>
 void serialize(Archive& ar, const unsigned int version)
```

其实，序列化包括序列化和发序列化两部分，或者称之为save和load，甚至mashalling，unmarshalling。反正就这个意思。

还有一个奇怪的地方，就是通常我们输入输出是用<<和>>的，那么在函数serialize里面我们用了&。其实这个是Boost对&做了一个封装。假如现在是做序列化，那么&就等同于<<,假如是反序列化，那么&就等同于>>。然后序列化和反序列化统统用一个函数serialize来实现。这也体现了Boost的巧妙设计。

那么如果有特殊需求，我们需要把序列化和反序列化分开，应该怎么实现呢？

就好比上面的class版本问题，save和load可能就是不一样的，因为load需要考虑兼容旧的版本。这里就偷懒使用Boost文档上的例子了。我们可以看到save和load是分开的。
```cpp
#include <boost/serialization/list.hpp>  
#include <boost/serialization/string.hpp>  
#include <boost/serialization/version.hpp>  
#include <boost/serialization/split_member.hpp>  
  
class bus_route  
{  
    friend class boost::serialization::access;  
    std::list<bus_stop *> stops;  
    std::string driver_name;  
    template<class Archive>  
    void save(Archive & ar, const unsigned int version) const  
    {  
        // note, version is always the latest when saving  
        ar  & driver_name;  
        ar  & stops;  
    }  
    template<class Archive>  
    void load(Archive & ar, const unsigned int version)  
    {  
        if(version > 0)  
            ar & driver_name;  
        ar  & stops;  
    }  
    BOOST_SERIALIZATION_SPLIT_MEMBER()  
public:  
    bus_route(){}  
};  
  
BOOST_CLASS_VERSION(bus_route, 1)  
```

注意需要使用宏`BOOST_SERIALIZATION_SPLIT_MEMBER()`来告诉Boost序列化库使用save和load代替serialize函数。
到这里，我们几乎把Boost序列化库所有的内容都介绍完毕了。这个库是相当的nice，基本可以cover所有的case。而且就开源库来讲，Boost的说明文档真的算是很好的了。基本上都有详细的说明，就序列化库而言，直接看这个页面就基本ok了，http://www.boost.org/doc/libs/1_51_0/libs/serialization/doc/tutorial.html 相当的详细。尽管读英文比较累，但是可以获得原汁原味的第一手权威资料，花这些功夫还是值得的。

我的例子里面使用了二进制流来保存序列化后的数据，其实还有其他的archive格式，比如text，XML等等。甚至我们可以自己来实现序列化格式。Boost已经定义了一个统一的接口，我们要实现自己的格式，只需要继承相应的Boost::archive里面的类就可以了。

好了，写完了，希望对大家有点帮助。如有错误，欢迎指出。


## 附录

完整测试代码，使用这段代码前需要确保VISUAL STUDIO已经设置了Boost的路径。
```cpp
// Serialization.cpp : Defines the entry point for the console application.  
//  
  
#include "stdafx.h"  
  
#include "boost/serialization/serialization.hpp"  
#include "boost/archive/binary_oarchive.hpp"  
#include "boost/archive/binary_iarchive.hpp"  
#include <boost/serialization/export.hpp>  
#include "boost/foreach.hpp"  
#include "boost/any.hpp"  
#include <boost/serialization/vector.hpp>  
  
  
  
#include <string>  
#include <Windows.h>  
#include <iostream>  
#include <sstream>  
#include <vector>  
  
  
//测试序列化  
class CMyData  
{  
private:  
    friend class boost::serialization::access;  
  
    template<class Archive>  
    void serialize(Archive& ar, const unsigned int version)  
    {  
        ar & _tag;  
        ar & _text;  
    }  
  
      
public:  
    CMyData():_tag(0), _text(""){}  
  
    CMyData(int tag, std::string text):_tag(tag), _text(text){}  
    virtual ~CMyData(){}  
  
    int GetTag() const {return _tag;}  
    std::string GetText() const {return _text;}  
  
private:  
    int _tag;  
    std::string _text;  
};  
  
  
void TestArchive1()  
{  
    std::string content;  
  
    {  
        CMyData d1(2012, "China, good luck");  
        std::ostringstream os;  
        boost::archive::binary_oarchive oa(os);  
        oa << d1;//序列化到一个ostringstream里面  
  
        content = os.str();//content保存了序列化后的数据。  
    }  
      
  
    {  
        CMyData d2;  
        std::istringstream is(content);  
        boost::archive::binary_iarchive ia(is);  
        ia >> d2;//从一个保存序列化数据的string里面反序列化，从而得到原来的对象。  
  
        std::cout << "CMyData tag: " << d2.GetTag() << ", text: " << d2.GetText() << "\n";  
    }  
      
}  
  
  
class CMyData2  
{  
public:  
    CMyData2():_tag(0), _text(""){}  
  
    CMyData2(int tag, std::string text):_tag(tag), _text(text){}  
  
    int _tag;  
    std::string _text;  
};  
  
namespace boost {  
    namespace serialization {  
  
        template<class Archive>  
        void serialize(Archive & ar, CMyData2 & d, const unsigned int version)  
        {  
            ar & d._tag;  
            ar & d._text;  
        }  
  
    } // namespace serialization  
} // namespace boost  
  
void TestArchive2()  
{  
    CMyData2 d1(2012, "China, good luck");  
    std::ostringstream os;  
    boost::archive::binary_oarchive oa(os);  
    oa << d1;//序列化到一个ostringstream里面  
  
    std::string content = os.str();//content保存了序列化后的数据。  
  
    CMyData2 d2;  
    std::istringstream is(content);  
    boost::archive::binary_iarchive ia(is);  
    ia >> d2;//从一个保存序列化数据的string里面反序列化，从而得到原来的对象。  
  
    std::cout << "CMyData2 tag: " << d2._tag << ", text: " << d2._text << "\n";  
}  
  
  
//序列化子类,侵入式  
class CMyData_Child: public CMyData  
{  
private:  
    friend class boost::serialization::access;  
  
    template<class Archive>  
    void serialize(Archive& ar, const unsigned int version)  
    {  
        // serialize base class information  
        ar & boost::serialization::base_object<CMyData>(*this);  
        ar & _number;  
    }  
  
  
public:  
    CMyData_Child():_number(0.0){}  
  
    CMyData_Child(int tag, std::string text, float number):CMyData(tag, text), _number(number){}  
  
    float GetNumber() const{return _number;}  
  
private:  
    float _number;  
};  
  
BOOST_CLASS_EXPORT_GUID(CMyData_Child, "CMyData_Child")  
  
  
void TestArchive3()  
{  
    CMyData_Child d1(2012, "China, good luck", 1.2);  
    std::ostringstream os;  
    boost::archive::binary_oarchive oa(os);  
    oa << d1;//序列化到一个ostringstream里面  
  
    std::string content = os.str();//content保存了序列化后的数据。  
  
    CMyData_Child d2;  
    std::istringstream is(content);  
    boost::archive::binary_iarchive ia(is);  
    ia >> d2;//从一个保存序列化数据的string里面反序列化，从而得到原来的对象。  
  
    std::cout << "CMyData_Child tag: " << d2.GetTag() << ", text: " << d2.GetText() << ", number: "<<d2.GetNumber() << "\n";  
}  
  
//序列化子类，非侵入式  
class CMyData2_Child: public CMyData2  
{  
public:  
    CMyData2_Child():_number(0.0){}  
  
    CMyData2_Child(int tag, std::string text, float number):CMyData2(tag, text), _number(number){}  
  
    float _number;  
};  
  
namespace boost {  
    namespace serialization {  
  
        template<class Archive>  
        void serialize(Archive & ar, CMyData2_Child & d, const unsigned int version)  
        {  
            // serialize base class information  
            ar & boost::serialization::base_object<CMyData2>(d);  
            ar & d._number;  
        }  
  
    } // namespace serialization  
} // namespace boost  
  
void TestArchive4()  
{  
    CMyData2_Child d1(2012, "test non-intrusive child class", 5.6);  
    std::ostringstream os;  
    boost::archive::binary_oarchive oa(os);  
    oa << d1;//序列化到一个ostringstream里面  
  
    std::string content = os.str();//content保存了序列化后的数据。  
  
    CMyData2_Child d2;  
    std::istringstream is(content);  
    boost::archive::binary_iarchive ia(is);  
    ia >> d2;//从一个保存序列化数据的string里面反序列化，从而得到原来的对象。  
  
    std::cout << "CMyData2_Child tag: " << d2._tag << ", text: " << d2._text << ", number: "<<d2._number<<"\n";  
}  
  
  
//指针数据成员  
  
class CMyData_Container  
{  
private:  
    friend class boost::serialization::access;  
  
    template<class Archive>  
    void serialize(Archive& ar, const unsigned int version)  
    {  
        ar & pointers;  
    }  
public:  
    CMyData* pointers[3];  
};  
  
  
  
void TestPointerArchive()  
{  
    std::string content;  
    {  
        CMyData d1(1, "a");  
        CMyData_Child d2(2, "b", 1.5);  
  
        CMyData_Container containter;  
        containter.pointers[0] = &d1;  
        containter.pointers[1] = &d2;  
        containter.pointers[2] = &d1;  
  
        std::ostringstream os;  
        boost::archive::binary_oarchive oa(os);  
        oa << containter;  
  
        content = os.str();  
    }  
  
    //反序列化  
    {  
        CMyData_Container container;  
        std::istringstream is(content);  
        boost::archive::binary_iarchive ia(is);  
        ia >> container;  
  
        for (int i = 0; i < 3; i++)  
        {  
            CMyData* d = container.pointers[i];  
            std::cout << "pointer" << i + 1 <<": " << d->GetText() << "\n";  
  
            if (i == 1)  
            {  
                CMyData_Child* child = reinterpret_cast<CMyData_Child*>(d);  
                std::cout << "pointer" << i + 1 <<", number: " << child->GetNumber() << "\n";  
            }  
        }  
    }  
}  
  
//使用STL容器  
class CMyData_ContainerSTL  
{  
private:  
    friend class boost::serialization::access;  
  
    template<class Archive>  
    void serialize(Archive& ar, const unsigned int version)  
    {  
        ar & vPointers;  
    }  
public:  
    std::vector<CMyData*> vPointers;  
};  
  
  
  
void TestPointerArchiveWithSTLCollections()  
{  
    std::string content;  
    {  
        CMyData d1(1, "parent obj");  
        CMyData_Child d2(2, "child obj", 2.5);  
  
        CMyData_ContainerSTL containter;  
        containter.vPointers.push_back(&d1);  
        containter.vPointers.push_back(&d2);  
        containter.vPointers.push_back(&d1);  
          
  
        std::ostringstream os;  
        boost::archive::binary_oarchive oa(os);  
        oa << containter;  
  
        content = os.str();  
    }  
  
    //反序列化  
    {  
        CMyData_ContainerSTL container;  
        std::istringstream is(content);  
        boost::archive::binary_iarchive ia(is);  
        ia >> container;  
  
        std::cout<<"Test STL collections:\n";  
        BOOST_FOREACH(CMyData* p, container.vPointers)  
        {  
            std::cout << "object text: " << p->GetText() << "\n";  
  
            CMyData_Child* child = dynamic_cast<CMyData_Child*>(p);  
            if (child)  
            {  
                std::cout << "child object number: " << child->GetNumber() << "\n";  
            }  
        }  
    }  
}  
  
int _tmain(int argc, _TCHAR* argv[])  
{  
    TestArchive1();  
  
    TestArchive2();  
  
    TestArchive3();  
  
    TestArchive4();  
  
    TestPointerArchive();  
  
    TestPointerArchiveWithSTLCollections();  
  
    return 0;  
} 
```

