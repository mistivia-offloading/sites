// Lisp风格的C++模板元编程
#import "/template.typ": *

#doc-template(
title: "Lisp风格的\nC++模板元编程",
date: "2026年3月20日",
body: [

首先，本文假设作者对C++模板和Lisp都有一些基本的了解。对于C++模板，至少要能够编写简单的泛型函数；对于Lisp，至少要达到SICP这本书的前三章的程度。

= 原子

在Lisp中，空列表`'()`、整数，这些被称为“原子”。而在C++模板元编程当中，类似的概念是一个“类型”。定义类型最简单的方法就是定义一个`class`或者`struct`。因为`struct`默认所有成员都是`public`，用起来比较方便，所以模板元编程的时候我们一般都用`struct`。

Lisp中的空列表又被叫做`nil`，所以我们也定义一个`nil`：

```cpp
struct nil {};
```

我们也可以定义一些其他的名字，这些都有点类似于Lisp当中的symbol：

```cpp
struct foo {};
struct bar {};
```

然后是数字，这里稍微麻烦一点。在C++模板元编程当中，数字是可以直接当成模板参数的，例如这样：

```cpp
template<int N>
struct MyType {
  int func() { return N; }
};
```

但是，考虑到其他的原子都是一个struct类型，为了方便统一处理，达到像Lisp一样的动态类型的效果，我们也用`struct`封装一下，大概像这样：

```cpp
template<int N>
struct Integer {
  static constexpr int value = N;
}
```

然后我们就可以这样创建一个带整数数值的类型，并且获取其中的整数值：

```cpp
using MyInt = Integer<42>;

int x = MyInt::value;
```

其实，C++标准库已经提供了这样的封装：`std::integral_constant<>`。我们可以直接使用：


```cpp
template<int N>
using Int = std::integral_constant<int, N>;
```

布尔类型也是一样：

```cpp
template<bool B>
using bool_constant = std::integral_constant<bool, B>;
```

= 函数



= Cons Cell

= 列表

= 惰性求值

= 分支

= 递归和循环

= 无穷列表

= 字符串

= 实用例子：构建一个类型安全的EDSL

])