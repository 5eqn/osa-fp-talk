#import "template.typ": *

#show: project.with(
  title: "带你用 FP 手搓自己的编程语言",
  authors: (
    "5eqn（电子鼠会梦见仿生猫猫虫吗）",
  ),
)

= 前言

== 自我介绍

哈深大二 CS 人，有较多工业编程实践 #footnote[在 GitHub 和某实验室。] 的同时爱好编程语言理论，喜欢发猫猫虫表情包以及玩 Eggy Party。如果愿意的话，考虑关注我的 GitHub 账号 #footnote[https://github.com/5eqn] qwq

== 前置知识

只需要在高中学会函数是什么，会基本的四则运算即可，不需要编程基础！

== 名词解释

因标题字数受限，我使用了一些缩略性的表述：

- #tag[FP] Functional Programming，函数式编程，一种编程范式，在 talk 中我将详细讲述
- #tag[手搓] 这里指从 Haskell 语言开始，不依赖任何外部库（待定）

== 如果你真的想跟着做……

你需要安装 Haskell，Linux 用户可参考这篇文章 #footnote[https://zhuanlan.zhihu.com/p/455688955]，Windows 用户考虑安装 WSL2 #footnote[https://learn.microsoft.com/zh-cn/windows/wsl/install]。如果懒得安装 Haskell，可以选择使用在线编辑器 #footnote[例如 https://www.w3cschool.cn/tryrun/runcode?lang=haskell]。  

= 正文

== Haskell 语法基础

以下内容没有超出高中数学中函数的概念，只是在 Haskell 语言中语法略有不同。以定义一个整数到整数的函数为例：

数学表述：

$ f : ZZ -> ZZ \ f(x) = x + 1 $

Haskell 表述：

#sect[
```haskell
f : Int -> Int
f x = x + 1
```
]

That's all! 匿名函数 #footnote[http://learnyouahaskell.com/higher-order-functions#lambdas]、代数数据类型 #footnote[http://learnyouahaskell.com/making-our-own-types-and-typeclasses#algebraic-data-types] 和模式匹配 #footnote[http://learnyouahaskell.com/syntax-in-functions#pattern-matching] 有专门的语法，但很一目了然，我觉得大家看到就能立刻明白。

== 语法分析

最朴素的语法分析模块采用从「初始字符串 #footnote[顾名思义，一串字符。]」映射到「该模块分析结果」的函数，其中分析结果有两种可能：

- #tag[分析成功] 返回「处理结果」`res` 和「处理后剩余字符串」`str`，记为 `Success res str`
- #tag[分析失败] 啥也不返回，记为 `Fail`

把上面的东西翻译成 Haskell，设 `res` 的类型为 `a`，整个模块分析结果的类型为 `ParseResult a`，则模块可以记为：

#sect[
```haskell
f : String -> ParseResult a
```
]

而 `ParseResult` 的定义如下：

#sect[
```haskell
data ParseResult a =
  | Success a String -- option 1: 
                     -- success with result and remaining string
                     -- here `a` and `String` are types
  | Fail -- option 2:
         -- fail with no result
```
]

这就是代数数据类型，是不是很符合直觉？可惜绝大部分语言都不原生支持它。

=== 拼接

现在假设我们需要读入一个形如 `2+4` 的加法算式，返回加法结果，但我们只有两个小模块：

- #tag[`char x`] 判断字符串是否以 `x` 开头，如果是，吞掉字符 `x`，返回 `()`
  - `char 'A' "Anqur" = Success () "nqur"`
- #tag[`num`] 判断字符串是否以数字开头，如果是，吞掉开头的数字，返回这个数字
  - `num "51121 511121" = Success 51121 " 511121"`

若要用小模块拼接成大模块：

#sect[```haskell
plus : String -> ParseResult Int
plus str = case num str of -- is the result of `num str` success or fail?
  Fail => Fail -- if fail, the whole module fails
  Success a str1 => case (char '+') str1 of -- otherwise check `(char '+') str1`
    Fail => Fail -- if fail, the whole module fails
    Success _ str2 => case num str2 of -- otherwise check `num str2`
      Fail => Fail -- if fail, the whole module fails
      Success b str3 => Success (a + b) str3 -- otherwise success with `a + b`
```]

注意到代码中每用一个 `String -> ParseResult x`，都会被迫进行一次模式匹配，还要产生一个新的字符串变量，这很坏。如果有某种方法能让我们一构造出 `String -> ParseResult a` 就直接摆烂，委托神秘力量得到下一步的成功结果 `a`，再用它构造出最终结果 `String -> ParseResult b`，该有多好？

幸运的是，只需要一个函数就能搞定：

#sect[
```haskell
bind : (prev : String -> ParseResult a) -> (next : a -> (String -> ParseResult b)) -> (String -> ParseResult b)
```
]

等等，这好像有点长！但别急，这刻画的其实就是上面的「摆烂」：

- #tag[prev] 摆烂前构造出的语法分析模块
- #tag[next] 摆烂后的行动，参数是摆烂前模块结果的类型 `a`，返回最终结果类型
- #tag[返回值类型] 把摆烂前模块和摆烂后行动绑定在一起，返回的结果就是摆烂后行动的结果，因此返回值类型也是摆烂后行动结果的类型

为了方便理解 `bind` 到底是什么，让我们看看有了 `bind` 原程序能得到怎样的简化，其中 `\param => body` 表示参数为 `param`，返回 `body` 的匿名函数：

#sect[
```haskell
plus : String -> ParseResult Int
plus = 
  bind (num) ( -- run `num` first
    \a => -- zzz and wake up with result `a`
      bind (char '+') ( -- then run `char '+'`
        \_ => -- zzz and wake up with result `()`, discard it
          bind (num) ( -- then run `num`
            \b => -- zzz and wake up with result `b`
              Success (a + b) -- set `a + b` as the final result
                              -- equivalent to \str => Success (a + b) str
          )
      )
  )
```
]

由于这种模式在 FP 中特别重要，Haskell 专门给这种模式设计了一个语法糖 #footnote[就是一套更好看的语法。]。若令 `Parser a = String -> ParseResult a`，为 `Parser` 实现 `Monad` Typeclass #footnote[http://learnyouahaskell.com/types-and-typeclasses]，就可以：

#sect[
```haskell
plus : Parser Int
plus = do
  a <- num -- run `num`, get `a`
  char '+' -- run `char '+'`, get `()`
  b <- num -- run `num`, get `b`
  Success (a + b) -- set `a + b` as the final result
```
]



但摆烂是有代价的：你需要实现 `bind` 函数。要不要试着实现一下？如果不熟悉 Haskell 语法的话，用伪码也行😋

3, 2, 1...

啊哈哈哈，实现来咯！

#sect[
```haskell
bind : (prev : String -> ParseResult a) -> (next : a -> (String -> ParseResult b)) -> (String -> ParseResult b)
bind prev next str =
  case prev str of -- is result of `prev str` success or fail?
    Fail => Fail -- if fail, the whole module fails
    Success res str' => next res str' -- otherwise run `next` with
                                      -- result and consumed string
```
]

可以看到新变量定义和模式匹配全被转移到了 `bind`，因此实现了复用！

=== 选择

假设我们要读入形如 `x+y` 或 `x-y` 的算式，返回算式结果，但我们只有两个小模块：

- `plus` 判断字符串是否以 `x+y` 形式开头，如果是，返回加法结果
- `minus` 判断字符串是否以 `x-y` 形式开头，如果是，返回减法结果

若要用小模块拼接成大模块：

#sect[
```haskell
plusOrMinus : Parser Int
plusOrMinus str = case plus str of -- is `plus str` success or fail?
  Success res str' => Success res str' -- if success, module success
  Fail => minus str of -- if fail, check `minus str`
    Success res str' => Success res str' -- if success, module success
    Fail => Fail -- if both fail, module fail
```
]

可以看出和前面「拼接」的程序非常相似，因此仿照前面尝试定义一个函数消除嵌套的分支。我们希望拿到两个模块之后，直接把这两个模块绑定在一起，绑定之后的新模块等效于先执行前面那个模块，如果寄了，再执行后面那个模块：

#sect[
```haskell
alt : Parser a -> Parser a -> Parser a
```
] 

注意出现箭头串联的时候右边的会被看成一个整体 #footnote[也就是常说的「右结合」。]，例如 `alt` 函数也等价于：

#sect[
```haskell
alt : Parser a -> (Parser a -> Parser a)
```
] 

如果要使用 `alt`，只需要连续地传递两个参数即可：

#sect[
```haskell
plusOrMinus : Parser Int
plusOrMinus = alt plus minus
```
] 

如果把 `alt` 简写成 `<|>`，还可以采用中缀运算符的写法：

#sect[
```haskell
plusOrMinus : Parser Int
plusOrMinus = plus <|> minus
```
] 

要不要试试实现 `alt` 呢？比 `bind` 容易哦！

啊哈哈哈，实现又来咯！

#sect[
```haskell
alt : Parser a -> Parser a -> Parser a
alt mod mod' str = case mod str of
  Success res str' => Success res str'
  Fail => mod' str
```
]

用这些知识足以实现一个自己的玩具编程语言，我会现场带大家实现。

=== 扩展阅读：其他有用的函数

#sect(color: "blue", title: "pure 函数")[
`pure` 用于把值直接转换成对应的语法分析模块，不修改字符串：

```haskell
pure : a -> Parser a
pure x str = Success x str -- alternatively, pure = Success, but why?
```

`pure` 有时也写作 `return`。
]

#sect(color: "blue", title: "map 函数")[
`map` 用于「偷天换日」，直接对模块的结果进行修改：
```haskell
map : (a -> b) -> Parser a -> Parser b
map f mod str = case mod str of
  Fail => Fail
  Success res str' => Success (f res) str'
```

`map` 也被写作 `<$>`。
]

#sect(color: "blue", title: "apply 函数")[
`apply` 用于把「产生函数的模块」当作「函数」进行应用：

```haskell
apply : Parser (a -> b) -> Parser a -> Parser b
apply mf mod str = case mf str of
  Fail => Fail
  Success f str' => map f mod str'
```

`apply` 也被写作 `<*>`。
]

=== 扩展阅读：左递归

如果要处理任意长度、没打括号的加减法串，该怎么做呢？

主要难点在于处理左递归。我们希望把形如 `1-2-3-4` 的东西拆成 `((1-2)-3)-4`。起初我们可能想这样写：

#sect[
```haskell
series : Parser Int
series = do
  left <- series
  char '-'
  next <- num
  pure (left + next)
```
]

但是，这段代码会死循环！因为 `series` 没有经过任何其他模块，就直接调用了它自身。

其实，处理左递归是一个相当困难的问题，在 Parser Combinator #footnote[其实就是这种模块化的语法分析。] 被第一次提出的 19 年 #footnote[这篇文章说的 19 年，但我考证不了：https://zhuanlan.zhihu.com/p/25867784] 后（2008 年）才得到解决 #footnote[https://www.semanticscholar.org/paper/Parser-Combinators-for-Ambiguous-Left-Recursive-Frost-Hafiz/cc524e8e95294be0491aa3b4bdf7e1125b85a39c]（我之前扩展了一下 Parser Combinator 才解决这个问题 #footnote[https://github.com/5eqn/aevum-lang/blob/8f92acdc0ab0dde2aa43cf4e29b36ca2141a83c9/src/Aevum/Main.idr#L81-L84]，并不是标准解法，虽然当时我都不知道 Parser Combinator）。如果使用正常的自底向上 #footnote[大白话就是读一点处理一点，不像现在这样搞模块化。现在这种叫自顶向下。] 写法就没有这个问题，这或许也是优美代码的代价吧……

参考 Parsec 库 #footnote[https://github.com/haskell/parsec/blob/c5add8bd1da56ee11fd327409b3b46aa8015a974/src/Text/Parsec/Combinator.hs#L217-L241] 的做法，设想如果不使用 `left <- series` 来引用左侧括号内的内容，而是从外部获取左边的结果，会发生什么？代码将发生以下三个改变：

- 函数签名变成 `(left : Int) -> Parser Int`，因为需要接受外部参数
- 结束时不能直接用 `pure` 返回，而是把结果塞给自己
- 需要专门读取第一个数作为初始的 `left` 值

于是我们这样实现（顺带加上了加减法的选择）：

#sect[
```haskell
series : Parser Int
series = do
  left <- num
  rest left where
    rest : Int -> Parser Int
    rest left = (do char '+'; next <- num; rest (left + next))
            <|> (do char '-'; next <- num; rest (left - next))
            <|> pure left
```
] 

= 后记

== FP 的工业应用

在目前工业实践中，FP 不仅可以以单独的函数式语言的形式存在，而且可以融合在一些主流语言的主流框架之中，且后者的应用显著更广泛。以下是几个例子：

- #tag[前端] React.js 的设计模式和 FP 非常共通，例如提倡使用不可变变量
- #tag[后端] Rocket.rs 基于 Rust 语言，Rust 本身大量借鉴 FP 元素，该框架还沾类型论
- #tag[AI] PyTorch 中模型的模块其实就是一个个函数，自动求导也能用类似的方式实现
- #tag[游戏开发] Unity 中 ECS 架构中的 System 可以被视为上一状态到下一状态的函数

同时也有不少工业向的 FP or FP-ish 语言，例如：

- #tag[Rust] 相当通用的语言，有独特的生命周期和所有权，编程语言中的「原神」（？
- #tag[Kotlin] Java 家族成员，主要用于安卓开发，沾 FP 但只沾一点点
- #tag[Clojure] 基于 JVM 的 Lisp 方言，比较通用
- #tag[PureScript] 和 Haskell 很像，编译成 JavaScript，主要用于 Web 前端
- #tag[Elm] 专门用来写 Web 前端的语言
- #tag[Idris2] 不仅 FP 而且 Type-driven，希望消灭所有运行时错误

== 深入研究方向

- #tag[源码] PL Zoo #footnote[http://plzoo.andrej.com/]，各种编程语言实现技巧的代码演示，使用 OCaml 语言。 
- #tag[类型论] FP 和类型论高度相关，考虑从无穷类型咖啡 #footnote[https://space.bilibili.com/3494366737861355/video?tid=0&pn=2&keyword=&order=pubdate] 开始入门类型论，我下次也会讲。

== 我为什么选择这个题材

显然有不少人对怎么自己搓出编程语言感兴趣，用这个题材能吸引更多人来听，这样就不会出现观众全部比我懂 FP 的尴尬情况，我也可以真的为传播美的事物 #footnote[这里指 FP。] 做出一点点贡献。 

如果搞成「单子的应用举例」这种标题，可能会有些人看在这是近期第一次协会 talk 的份上进来围观，但其实又不是真的想看内容，然后出于礼貌在会议室挂机 #footnote[如果有会议室的话。]，这不是我希望看到的局面。

还有一个原因，我希望我的 talk 中出现手搓代码的情节，这样看起来比较有趣。如果观众能产生「我们一起写成了」的感觉，那真的是泰裤辣！

Fun Fact: 我原先打算讲怎么用 FP 搓 AI 中的自动求导，但感觉讲起来太过困难，听众对 AI 基础原理有一定了解之后才容易接受，因此这次没有选择 AI 话题。如果大家真的很希望我（而不是哈深随处可见的 AI 力比我强的大佬）讲的话，我还是很愿意找个时间讲的（

== 下期预告，如果有

利用丰富的类型把 Bug 限制在编译期！
