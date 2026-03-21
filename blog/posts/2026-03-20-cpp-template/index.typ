// Lisp风格的C++模板元编程
#import "/template.typ": *

#doc-template(
title: "Lisp风格的\nC++模板元编程",
date: "2026年3月20日",
body: [

首先，本文假设读者对C++模板和Lisp都有一些基本的了解。对于C++模板，至少要能够编写简单的泛型函数；对于Lisp，至少要达到能理解SICP这本书前三章的程度。

= 原子

在Lisp中，空列表`'()`、整数，这些被称为“原子”。而在C++模板元编程当中，类似的概念是一个“类型”。定义类型最简单的方法就是定义一个`class`或者`struct`。因为`struct`默认所有成员都是`public`，用起来比较方便，所以模板元编程的时候我们一般都用`struct`。

Lisp中的空列表又被叫做`nil`，所以我们也定义一个`nil`：

```
struct nil {};
```

我们也可以定义一些其他的名字，这些都有点类似于Lisp当中的symbol：

```
struct foo {};
struct bar {};
```

然后是数字，这里稍微麻烦一点。在C++模板元编程当中，数字是可以直接当成模板参数的，例如这样：

```
template<int N>
struct MyType {
  int func() { return N; }
};
```

但是，考虑到其他的原子都是一个struct类型，为了方便统一处理，达到像Lisp一样的动态类型的效果，我们也用`struct`封装一下，大概像这样：

```
template<int N>
struct Integer {
  static constexpr int value = N;
}
```

然后我们就可以这样创建一个带整数数值的类型，并且获取其中的整数值：

```
using MyInt = Integer<42>;

int x = MyInt::value;
```

其实，C++标准库已经提供了这样的封装：`std::integral_constant<>`。我们可以直接使用：


```
template<int N>
using Int = std::integral_constant<int, N>;
```

布尔类型也是一样：

```
template<bool B>
using bool_constant = std::integral_constant<bool, B>;
```

= 函数

C++模板元编程中的“函数”，标准库中就有很多例子。比如`remove_pointer`，可以输入一个指针类型，返回其原本的类型。

它的实现大概是这样的：

```
template<class T>
struct remove_pointer<T*> { 
  typedef T type;
};
```

`typedef`也可以用`using`取代：

```
template<class T>
struct remove_pointer<T*> { 
  using type = T;
};
```

这样，我们就能输入一个类型，得到一个类型：

```
using MyType = typename remove_pointer<int*>::type;
// --> int
```

在模板元编程当中，类型起到了值的作用，所以这就可以看成是一个编译期的函数。

比如我们可以实现两个整数相加的函数:

```
template<class A, class B>
struct add {
  using type = Int<(A::value + B::value)>;
};
```

其调用方式如下：

```
using sum = typename add<Int<1>, Int<2>>::type;
// --> Int<3>
```

像这种`typename xxx<yyy, zzz>::type`的格式，就可以看成是“函数调用”。

= Cons Cell

= 列表

= 惰性求值

= 分支

= 递归和循环

= 无穷列表

= 字符串

= 实用例子：构建一个类型安全的EDSL

])