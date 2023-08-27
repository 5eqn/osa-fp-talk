#import "template.typ": *

#show: project.with(
  title: "如何用 143 行代码搓出新编程语言？",
  authors: (
    "5eqn",
  ),
)

= 前言

答案是用「函数式编程」！

本次 Talk 是个科普，旨在描绘函数式编程的美，不会深入进行逻辑推导。

即使你只是单纯好奇，也可以来听！

#figure(
  image("res/tenet.png", width: 50%),
  caption: [
    《信条》剧照 / 不要试图理解它，要感受它
  ],
)

== 目标受众

推荐学习过 C 语言或其它相似语言的人参加本次 Talk，以获得最佳体验。

== 自我介绍

哈深大二 CS 人，有较多工业编程实践 #footnote[在 GitHub 和某实验室。] 的同时爱好编程语言理论。

喜欢发猫猫虫表情包以及玩 Eggy Party。

如果有条件的话，考虑在 GitHub 给本次 Talk 讲义点个星 #footnote[https://github.com/5eqn/osa-fp-talk] qwq

== 鸣谢

本讲义能有现在的质量，离不开大量同学的建议和帮助，我在此表达真诚的感谢。

下面是鸣谢名单（按照字典序），但只有征得同意的一部分，且可能有疏漏：

#columns(3)[
- AntibodyGame
- Clouder
- harpsichord
- San_Cai
- SeparateWings
#colbreak()
- toaster
- yyx
- zc
- zly
- ...（这个列表还会增长）
]

== 计划（草稿）

- 线上，媒介待定，取决于预估参与人数
- 时间：9.9 10:00-10:40, 15:00-15:40; 9.10 10:00-10:40（可能会改）
- Talk 前提供讲义
- 40 分钟内包含思考和提问时间

#pagebreak()

== 导语

你是否好奇过，机器是如何把编程语言转化成执行结果的？

#figure(
  image("res/lang.png", width: 50%),
  caption: [
    ？
  ],
)

业界有很多种实现方式，本次 Talk 我们讲最简单的一种：再写一个程序来转化！

#figure(
  image("res/code.png", width: 50%),
  caption: [
    ！
  ],
)

但是，写程序处理一个编程语言，一看就是个大工程！真的能在一节课内搞定吗？

可以！

只需要拆成两步，一切都会变得简单：

#figure(
  image("res/pi.png", width: 50%),
  caption: [
    两步
  ],
)

可以看到中间是棵树，存储着程序的「意思」，以更简单地算出程序的运行结果。

理论存在，实践开始！

#pagebreak()

先看第一个步骤，正常而言这一步代码量非常大，感受下规模就好：

#figure(
  image("res/cpp.png", width: 10%),
  caption: [
    这只是部分代码 #footnote[https://github.com/drmenguin/minilang-interpreter/blob/master/src/parser/parser.cpp] 
  ],
)

#pagebreak()

但用函数式编程，核心代码可以被减少到 50 行之内：

#figure(
  image("res/parser.png", width: 50%),
  caption: [
    我的程序 #footnote[https://github.com/5eqn/osa-fp-talk/blob/main/defect-lang/src/main/scala/Main.scala] 
  ],
)

#pagebreak()

下面的 Python 代码可以完成第二步：

#figure(
  image("res/python.png", width: 50%),
  caption: [
    keleshev/mini #footnote[https://github.com/keleshev/mini/blob/master/mini.py]
  ],
)

#pagebreak()

是不是比你想象的短很多？

你先别急，因为用函数式编程实现几乎相同的功能，只需要：

#figure(
  image("res/carbon.png", width: 50%),
  caption: [
    我的程序
  ],
)

经过本系列 Talk，你也将大致知道怎么搓出自己的编程语言！

#sect(title: "补充：如果你真的想跟着做……", color: "blue")[
你需要安装 Scala3 #footnote[https://www.scala-lang.org/download/]。  
]

#pagebreak()

= 第一章 / 横看成岭侧成峰

惯常把程序看成一条一条指令的我们，或许从未想过，换个视角便能看到不同的美。

如果说 C 语言是在问「怎么做」，那函数式编程便是在问「是什么」。

#figure(
  image("res/swap.png", width: 50%),
  caption: [
    C 语言和函数式编程解决交换问题
  ],
)

听完本章，你将收获：

- 了解「函数式编程」的基本概念
- 掌握用函数式编程处理「字符串」的技巧
- 学会用函数式编程建模简单的东西

预计时间：40 分钟

#pagebreak()

== 1 / 4 什么是函数式编程？

考虑在 C 语言中，你会怎么写一个函数，用于把数加一？

一种方法是直接写函数：

#sect[```c
int f(int x) {
  return x + 1;
}
```] 

一种方法是「修改」一个数：

#sect[```c
void f(int *x) {
  *x++;
}```]

在函数式编程中，相比 C 语言最大的不同就是：不能「修改」一个数。

若要采用函数式编程的写法把数加一，你只能：


#sect[
#grid(columns: (auto, auto), gutter: 10pt, [
=== Scala3 代码
```scala
def f(x: Int): Int = x + 1
```
], [
=== 意义
定义 $f$ 使得 $f(x) = x + 1$，其中 $x$ 和 $f(x)$ 的类型是整数。
])]

#sect(title: "一些例题", color: "blue")[

不用在意语法，只要不修改数就行。

1. 请写一个函数 `isNumeric`，判断一个字符是不是数字。
2. 请写一个函数 `isAlphabetic`，判断一个字符是不是字母。

答案在 GitHub #footnote[https://github.com/5eqn/osa-fp-talk/blob/ab7c09acf7e7ac38242d675984cb2888edccbcb4/defect-lang/src/main/scala/Main.scala#L6-L7]，我在 Talk 里也会讲。] 

#pagebreak()

== 2 / 4 来点更难的问题

我们是要处理编程语言，而不是 $f(x) = x + 1$，因此我们需要有能力处理字符串。

如果我们要从一个字符串 `str = "you are new bee"` 里面提取出第一个单词，可以怎么做？

你可能会想用一个指针从 `str[0]` 往后扫，扫到不是字母的东西，就把指针前面的作为结果。

但这背后的逻辑其实很简单：你希望从前往后处理。

在函数式编程中，我们可以「不依赖外界值，直接用数据表达顺序」：

#figure(
  image("res/string.png", width: 50%),
  caption: [
    C 和函数式编程对字符串的不同处理方式
  ],
)

具体地，我们可以把字符串看成一个「有两种情况的东西」：

#sect(title: "两种情况", color: "blue")[

1. 由一个字符 `head` 和一个字符串 `tail` 拼接而成，例如 `"Au5" = 'A' + "u5"`
2. 为空，例如 `""`] 

这两个规则便可以完整地描述字符串的概念！

现在我们尝试来写提取出第一个单词的函数，`collect`：

#sect[
#grid(columns: (auto, auto), gutter: 10pt, [
=== Scala3 代码
```scala
def collect(str: String): String =

  str.headOption match
    case Some(head) if isAlphabetic(head) => // ?
    case _                                => // ?
```
], [
=== 意义

若要提取 `str` 的第一个单词：

- 讨论 `head` 的情况
  - `head` 存在且为字母
  - 其他情况
])]

若 `head` 存在且为字母，那我们自然要保留这个 `head`：

考虑到 `head == 'y'`，`collect("ou are new bee") == "ou"`，结果可以写成：

#sect[
#grid(columns: (40%, 60%), gutter: 10pt, [
=== Scala3 代码
```scala
val res = collect(str.tail)
head + res
```
], [
=== 意义
- 设 `collect(str.tail)` 的结果为 `res`
- 则 `collect(str)` 的结果为 `head + res`
])]

若 `head` 不存在或者不是字母，显然什么都提取不出，返回空字符串即可。

#pagebreak()

=== 选读：How it works?

#sect[```scala
collect("you are new bee")
== (val res = collect("ou are new bee"); 'y' + res)

collect("ou are new bee")
== (val res = collect("u are new bee"); 'o' + res)

collect("u are new bee")
== (val res = collect(" are new bee"); 'u' + res)

collect(" are new bee")
== ""

collect("u are new bee")
== (val res = collect(" are new bee"); 'u' + res)
== (val res = ""; 'u' + res)
== "u"

collect("ou are new bee")
== (val res = collect("u are new bee"); 'o' + res)
== (val res = "u"; 'o' + res)
== "ou"

collect("you are new bee")
== (val res = collect("ou are new bee"); 'y' + res)
== (val res = "ou"; 'y' + res)
== "you"
```]

#pagebreak()

== 3 / 4 再难一点

在处理编程语言的时候，我们总不能读入一个东西，就把后面的字符串全部丢掉吧！

#figure(
  image("res/recycle.png", width: 50%),
  caption: [
    你不想这样做
  ],
)

如果我们需要同时收集剩下的字符串，可以怎么修改这个函数？

#sect[
#grid(columns: (auto, auto), gutter: 10pt, [
=== Scala3 代码
```scala
def collect(str: String): (String, String) =

  str.headOption match
    case Some(head) if isAlphabetic(head) => // ?
    case _                                => // ?
```
], [
=== 意义

若要同时收集剩下的字符串：

- 讨论 `head` 的情况
  - `head` 存在且为字母
  - 其他情况
])]

第一种情况下，注意到 `collect("ou are new bee") = ("ou", " are new bee")`，

我们希望返回 `("you", " are new bee")`，剩下的字符串不会变化，因此考虑写成：

#sect[
#grid(columns: (auto, auto), gutter: 10pt, [
=== Scala3 代码
```scala
val (res, rem) = collect(str.tail)
(head + res, rem)
```
], [
=== 意义
- 设 `collect(str.tail)` 的结果为 `(res, rem)`
- 则 `collect(str)` 的结果为 `(head + res, rem)`
])]

第二种情况下，整个字符串都是被剩下的，所以结果是 `("", str)`。

#pagebreak()

=== 选读：How it works?

#sect[```scala
collect(" are new bee")
== ("", " are new bee")

collect("u are new bee")
== (val (res, rem) = collect(" are new bee"); ('u' + res, rem))
== (val (res, rem) = ("", " are new bee"); ('u' + res, rem))
== ("u", " are new bee")

collect("ou are new bee")
== (val (res, rem) = collect("u are new bee"); ('o' + res, rem))
== (val (res, rem) = ("u", " are new bee"); ('o' + res, rem))
== ("ou", " are new bee")

collect("you are new bee")
== (val (res, rem) = collect("ou are new bee"); ('y' + res, rem))
== (val (res, rem) = ("ou", " are new bee"); ('y' + res, rem))
== ("you", " are new bee")
```]

#pagebreak()

== 4 / 4 现实是有失败的

设想你已经写好了一个编程语言，但有人给你：

#sect[```c
#include <studio.h>
int mian() {
  printf("Hell Word!")
  remake 0;
}
```]

这不找茬吗？

事实上，你永远不能指望用户给你的输入是正确的，因此你需要先准备好处理错误。

假设我们希望 `collect` 遇到 `114514` 这种不以字母开头的字符串就直接报错，该怎么办？

我们又遇到了一种「有两种情况的东西」：处理结果。

#sect[
#grid(columns: (auto, auto), gutter: 10pt, [
=== Scala3 写法
```scala
enum Result[+A]:

  case Success(res: A, rem: String)
  case Fail
```
], [
=== 意义

分析结果有两种可能，

- 分析成功：返回「值」`res` 和「剩余字符串」`str`
- 分析失败：啥也不返回，记为 `Fail`
])]

#figure(
  image("res/cases.png", width: 30%),
  caption: [
    无论成功还是失败，都是结果！
  ],
)

我们可以把 `collect` 包装起来：

#sect[
#grid(columns: (auto, auto), gutter: 10pt, [
=== Scala3 写法
```scala
def ident(str: String) =

  val (res, rem) = collect(str)
  if res.length() > 0
  then Result.Success(res, rem)
  else Result.Fail
```
], [
=== 意义

定义一个新函数 `ident`：

- 设 `collect(str)` 的结果为 `(res, rem)`
- 若 `res` 的长度大于 $0$
- 则 `ident(str)` 为 `Success(res, rem)`
- 否则 `ident(str)` 为 `Fail`
])]

#sect(title: "一些例题", color: "blue")[

1. 请写一个函数 `exact`，判断字符串是否以字符 `exp` 开头。
2. 请写一个函数 `exact`，判断字符串是否以字符串 `exp` 开头。
3. 请写一个函数 `number`，读入字符串开头的非负数字，可能有多位。] 

#pagebreak()

=== 选读：How it works?

#sect[```scala
collect("you are new bee")
== ("you", " are new bee")

res
== "you"

rem
== " are new bee"

res.length() > 0
== true

ident("you are new bee")
== Result.Success("you", " are new bee")
```] 

#pagebreak()

= 第二章：只用 143 行的秘密

上面讲述的只是函数式编程的「普通玩法」。

在下面的「进阶玩法」中，我们可以激进地提取出代码中的共同逻辑，从而有效减少行数！

#figure(
  image("res/reduce.png", width: 50%),
  caption: [
    提取共同逻辑
  ],
)

听完本章，你将收获：

- 了解一种提取共同逻辑的方式

预计时间：40 分钟

#pagebreak()

== 1 / 4 提取！

现在我们就来尝试提取一下 `ident`、`exact` 和 `number` 的共同特征：

它们都是从 `String` 到某种 `Result` 的函数。

不妨给 `String => Result[A]` 套一层盒子，叫做 `Parser[A]`：

#sect[```scala
case class Parser[A](run: String => Result[A]):
```] 

#figure(
  image("res/box.png", width: 50%),
  caption: [
    `Parser` 是盒子，`run` 是拆开盒子的剪刀
  ],
)

把 `ident` 写成 `Parser[String]`，就是：

#sect[
#grid(columns: (auto, auto), gutter: 10pt, [
=== Scala3 写法
```scala
def ident = Parser(

  str =>
    val (res, rem) = collect(str)
    if res.length() > 0
    then Result.Success(res, rem)
    else Result.Fail
)
```
], [
=== 意义

定义 `ident` 为一个 `Parser`，装着：

- 一个接受 `str` 作为参数的函数
  - 设 `collect(str)` 的结果为 `(res, rem)`
  - 若 `res` 的长度大于 $0$
  - 则返回 `Success(res, rem)`
  - 否则返回 `Fail`
])]

#sect(title: "补充", color: "blue")[
注意 `Parser` 装着的那个函数没有名字，被直接以 `str => ...` 的形式创建！

这样的函数也叫「匿名函数」。] 

要使用 `ident`，本来我们 `ident("some str")` 就可以，现在要 `ident.run("some str")`。

……

现在 `ident`、`exact` 和 `number` 都是某种 `Parser`，已经蓄势待发。

接下来，请见证表达力的起飞！

#pagebreak()

=== 选读：How it works?

#sect[```scala
ident
== Parser(str => val (res, rem) = collect(str); ...)

ident.run
== str => val (res, rem) = collect(str); ...

ident.run("you are new bee")
== (val (res, rem) = collect("you are new bee"); ...)
== Result.Success("you", " are new bee")
```] 

#pagebreak()

== 2 / 4 截胡

现在假设我们的编程语言里只会出现变量和数字：

#sect[
#grid(columns: (auto, auto), gutter: 10pt, [
=== Scala3 写法
```scala
enum Term:

  case Num(value: Int)
  case Var(name: String)
```
], [
=== 意义
表达式有两种可能：

- 数字，例如 `51121` 会被处理成 `Num(51121)`
- 变量，例如 `oiiai` 会被处理成 `Var("oiiai")`
])]

要用已有的 `number` 来写一个读取 `Term.Num` 的 `Parser`，最简单的方式是什么？

已知 `number.run("51121cat") = Success(51121, "cat")`，

我们希望结果变成 `Success(Term.Num(51121), "cat")`。

设想我们能「截胡」处理出来的值 `51121`，然后换成 `Term.Num(51121)`，不就简单了吗？

#figure(
  image("res/map.png", width: 50%),
  caption: [
    截胡的过程
  ],
)

假设这个「截胡」函数是 `map`，读入 `Term.Num` 只需要：

#sect[
#grid(columns: (auto, auto), gutter: 10pt, [
=== Scala3 写法
```scala
def pos = number.map(
  x => Term.Num(x)
)
```
], [
=== 意义
- 定义 `pos` 为对 `number` 截胡得到的新 `Parser`
- 截胡用的函数把数字 `x` 变成 `Term.Num(x)`
])]

是不是很简单？

不妨想想怎么从 `ident` 实现 `atom`，用于读取一个 `Term.Var`。只需要一个 `map` 就行！

#pagebreak()

=== 选读：How it works?

#sect(color: "blue")[
`map` 的实现是这样子的：

```scala
def map[B](cont: A => B) = Parser(str =>
  run(str) match
    case Result.Success(res, rem) => Result.Success(cont(res), rem)
    case Result.Fail              => Result.Fail
)
```]

#sect[```scala
pos
== number.map(x => Term.Num(x))
== Parser(str => number.run(str) match
    case Result.Success(res, rem) => Result.Success((x => Term.Num(x))(res), rem)
    case Result.Fail              => Result.Fail)

pos.run
== str => number.run(str) match
    case Result.Success(res, rem) => Result.Success((x => Term.Num(x))(res), rem)
    case Result.Fail              => Result.Fail

pos.run("51121cat")
== number.run("51121cat") match
    case Result.Success(res, rem) => Result.Success((x => Term.Num(x))(res), rem)
    case Result.Fail              => Result.Fail
== Result.Success(51121, "cat") match
    case Result.Success(res, rem) => Result.Success((x => Term.Num(x))(res), rem)
    case Result.Fail              => Result.Fail
== Result.Success((x => Term.Num(x))(51121), "cat")
== Result.Success(Term.Num(51121), "cat")
```]

#pagebreak()

== 3 / 4 第二条命

截胡有一个致命缺点：只有一条命。

比如 `pos` 虽然对 `number` 进行了截胡，但不能再读入更多东西，已经寄掉了。

若要读一个负数，如果用 `map`，读了 `'-'` 之后也会寄掉，读不了数字了。这很不好！

如果截胡之后还能有「第二条命」，那该多好？

#figure(
  image("res/flatmap.png", width: 50%),
  caption: [
    第二条命
  ],
)

假设这个「给第二条命的截胡」函数是 `flatMap`，读入一个负数只需要：

#sect[
#grid(columns: (auto, auto), gutter: 10pt, [
=== Scala3 写法
```scala
def neg = exact('-').flatMap(
  _ => number.map(
    x => Term.Num(-x)
  )
)
```
], [
=== 意义
- 定义 `neg` 为对 `exact('-')` 截胡得到的新 `Parser`
- 直接忽略结果，用续的命再读一个 `number`，再截胡
- 把数字 `x` 变成 `Term.Num(-x)`
])]

是不是依然很简单？

#pagebreak()

=== 选读：How it works?

#sect(color: "blue")[
`flatMap` 的实现是这样子的：

```scala
def flatMap[B](cont: A => Parser[B]) = Parser(str =>
  run(str) match
    case Result.Success(res, rem) => cont(res).run(rem.trim())
    case Result.Fail              => Result.Fail
)
```

若不用 `trim`，在连读两个数字 `"114 514"` 时，第一次会剩下 `" 514"`，注意前面有空格！

这个空格会导致第二次读入失败。`trim` 就是为了删除这种前导空格。

另一种选择是每次读入东西之后都专门再读入空格。]

#sect[```scala
val cont = _ => number.map(x => Term.Num(-x))

neg
== exact('-').flatMap(cont)
== Parser(str => exact('-').run(str) match
    case Result.Success(res, rem) => cont(res).run(rem.trim())
    case Result.Fail              => Result.Fail)

neg.run
== str => exact('-').run(str) match
    case Result.Success(res, rem) => cont(res).run(rem.trim())
    case Result.Fail              => Result.Fail

neg.run("-114 and 514")
== exact('-').run(str) match
    case Result.Success(res, rem) => cont(res).run(rem.trim())
    case Result.Fail              => Result.Fail
== Result.Success('-', "114 and 514") match
    case Result.Success(res, rem) => cont(res).run(rem.trim())
    case Result.Fail              => Result.Fail
== cont('-').run("114 and 514".trim())
== number.map(x => Term.Num(-x)).run("114 and 514")
== Result.Success(-114, " and 514")
```] 

#pagebreak()

== 4 / 4 神说，要有加

只读入数字和变量怎么行？我们要读入 `add(1, 1)` 这种加法！

你可能会想，这么多元素，要写几个 `flatMap`？

答案是，0 个！

由于 `flatMap` 嵌套的模式在 Scala3 中过于普遍，Scala3 允许我们进行「简写」：

#sect[
#grid(columns: (auto, auto), gutter: 40pt, [
=== 原始写法
```scala
def neg = exact('-').flatMap(
  _ => number.map(
    value => Term.Num(-value)
  )
)
```
], [
=== 简写写法
```scala
def neg = for {
  _ <- exact('-')
  value <- number
} yield Term.Num(-value)
```
])]

#figure(
  image("res/for.png", width: 40%),
  caption: [
    对应关系
  ],
)

你甚至可以把 `<-` 想成某种赋值！

现在再实现 `add`，就清晰了不少：

#sect[
#grid(columns: (auto, auto), gutter: 40pt, [
=== Scala3 写法
```scala
def add = for {
  _ <- exact("add")
  _ <- exact('(')
  lhs <- pos
  _ <- exact(',')
  rhs <- pos
  _ <- exact(')')
} yield Term.Add(lhs, rhs)
```
], [
=== 意思
- 定义 `add` 为这样的 `Parser`：
- 先读一个 `"add"`
- 再读一个 `'('`
- 再读一个正数，记为 `lhs`
- 再读一个 `','`
- 再读一个正数，记为 `rhs`
- 再读一个 `')'`
- 最终处理结果为 `Term.Add(lhs, rhs)`
])]

#sect(title: "按照这种思路，我们还可以读取", color: "blue")[

- `if a == b then c else d`，选择分支，记为 `Term.Alt(Term.Var("a"), ...)`
- `let x = 1 in x`，定义新值，记为 `Term.Let("x", Term.Num(1), Term.Var("x"))`
- `(x) => add(x, 1)`，创建匿名函数，记为 `Term.Lam("x", Term.Add(...))` 
- `app(f, x)`，函数调用，记为 `Term.App(Term.Var("f"), ...)`] 

#pagebreak()

= 第三章 / 搓出编程语言！

我们已经有了足够的知识储备，现在可以来搓一个编程语言了！

我搓的语言是 `defect-lang`，名字来源于游戏 Slay the Spire 中的一个角色：

#figure(
  image("res/defect.jpg", width: 50%),
  caption: [
    The Defect
  ],
)

用 143 行搓出来的语言，虽然有一些缺陷，但也能实现意想不到的事情。

听完本章，你将收获：

- 了解如何搓出一个编程语言

预计时间：40 分钟

#pagebreak()

== 1 / 2 神说，要有或

细心的你可能已经发现了：`add` 不能读取负数相加、变量相加，这很坏。

我们需要有能力「尝试多条路径」，才能读入「正数或负数或变量」。

#figure(
  image("res/alt.png", width: 50%),
  caption: [
    尝试多条路径读入 `-2`
  ],
)

令 `term` 为读入「正数或负数或变量」的 `Parser`：

#sect[
#grid(columns: (auto, auto), gutter: 40pt, [
=== Scala3 写法
```scala
def term: Parser[Term] = pos | neg | var
```
], [
=== 意思
定义 `term` 为 `pos` 或 `neg` 或 `var`。
])]

随着能读入的东西种类越来越多，`term` 的可选路径也会越来越多。

例如，在实现 `add` 后，`term` 也要能读取一个加法式子，变成 `... | add`。

#pagebreak()

=== 选读：How it works?

#sect(color: "blue")[
`|` 的实现是这样子的：

```scala
def |(another: Parser[A]) = Parser(str =>
  run(str) match
    case Result.Success(res, rem) => Result.Success(res, rem)
    case Result.Fail              => another.run(str)
)
```
]

#sect[```scala
term
== (pos | neg) | var
== Parser(str => (pos | neg).run(str) match
    case Result.Success(res, rem) => Result.Success(res, rem)
    case Result.Fail              => var.run(str))

pos | neg
== Parser(str => pos.run(str) match
    case Result.Success(res, rem) => Result.Success(res, rem)
    case Result.Fail              => neg.run(str))

(pos | neg).run("-114 and 514")
== pos.run("-114 and 514") match
    case Result.Success(res, rem) => Result.Success(res, rem)
    case Result.Fail              => neg.run("-114 and 514")
== Result.Fail match
    case Result.Success(res, rem) => Result.Success(res, rem)
    case Result.Fail              => neg.run("-114 and 514")
== neg.run("-114 and 514")
== Result.Success(-114, " and 514")

term.run("-114 and 514")
== (pos | neg).run("-114 and 514") match
    case Result.Success(res, rem) => Result.Success(res, rem)
    case Result.Fail              => var.run("-114 and 514")
== Result.Success(-114, " and 514") match
    case Result.Success(res, rem) => Result.Success(res, rem)
    case Result.Fail              => var.run("-114 and 514")
== Result.Success(-114, " and 514")
```] 

#pagebreak()

== 2 / 2 怎么求值？

就摁求！

#sect[
#grid(columns: (auto, auto), gutter: 40pt, [
=== Scala3 代码
```scala
enum Val:

  case Num(value: Int)
  case Lam(body: Val => Val)
```
], [
=== 含义

值有两种可能：

- 是一个数字
- 是一个从值到值的函数
])] 

要求一个 `Term` 的值，我们就直接定义求值函数，对每种 `Term` 分类讨论：

#sect[```scala
def eval(env: Map[String, Val], term: Term): Val = term match
  case Term.Num(value) => 
  case Term.Var(name) =>
  case Term.Lam(param, body) =>
  case Term.App(func, arg) =>
  case Term.Add(lhs, rhs) =>
  case Term.Let(name, value, next) =>
  case Term.Alt(lhs, rhs, x, y) =>
```] 

#sect(title: "env 是个什么东西？", color: "blue")[如果你 `let x = 1`，`env` 里就会多出 `x -> 1` 这条记录。

换言之，参数 `env` 存储已知的名字到值的对应关系。
] 

`Term.Num(value)` 的值，显然是 `Val.Num(value)`！

`Term.Var(name)` 的值，需要在当前语境 `env` 中查找，所以是 `env(name)`。

`Term.Lam(param, body)` 表示匿名函数，显然值是 `Val.Lam(arg => ?)` 的形式。

接受参数 `arg` 后语境中多出了 `param -> arg`，因此 `?` 是 `eval(env + (param -> arg), body)`。

剩下的求值都相对简单，读者可以尝试构思，答案在 GitHub #footnote[https://github.com/5eqn/osa-fp-talk/blob/ab7c09acf7e7ac38242d675984cb2888edccbcb4/defect-lang/src/main/scala/Main.scala#L140-L166]。

#pagebreak()

=== 选读：How it works?

要处理以下的程序：

#sect[```scala
app((x) => add(x, 1), 4)
```] 

过程是这样子的：

#sect[```scala
val f = Term.Lam("x", Term.Add(Term.Var("x"), Term.Num(1)))

eval(Map(), Term.App(f, Term.Num(4)))
== eval(Map(), f) match
     case Val.Lam(body) => body(eval(Map(), Term.Num(4)))
     case _ => throw new Exception("app")

eval(Map(), Term.Lam("x", Term.Add(Term.Var("x"), Term.Num(1))))
== Val.Lam(arg => eval(env + ("x" -> arg), Term.Add(Term.Var("x"), Term.Num(1))))

eval(Map(), Term.Num(4))
== Val.Num(4)

eval(Map(), Term.App(f, Term.Num(4)))
== (arg => eval(
     Map() + ("x" -> arg), 
     Term.Add(Term.Var("x"), Term.Num(1))
   ))(Val.Num(4))
== eval(Map("x" -> Val.Num(4)), Term.Add(Term.Var("x"), Term.Num(1)))
== (eval(Map("x" -> Val.Num(4)), Term.Var("x")), 
    eval(Map("x" -> Val.Num(4)), Term.Num(1))) match
     case (Val.Num(a), Val.Num(b)) => Val.Num(a + b)
     case _ => throw new Exception("add")

eval(Map("x" -> Val.Num(4)), Term.Var("x"))
== Map("x" -> Val.Num(4))("x")
== Val.Num(4)

eval(Map(), Term.App(f, Term.Num(4)))
== (Val.Num(4), Val.Num(1)) match
     case (Val.Num(a), Val.Num(b)) => Val.Num(a + b)
     case _ => throw new Exception("add")
== Val.Num(4 + 1)
== Val.Num(5)
```] 

#pagebreak()

恭喜你已经实现了一个自己的编程语言！下面是一些扩展阅读内容。

== 函数式编程的工业应用

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

#pagebreak()

== 左递归

如果要处理任意长度、没打括号的加减法串，该怎么做呢？

主要难点在于处理左递归。我们希望把形如 `1-2-3-4` 的东西拆成 `((1-2)-3)-4`。起初我们可能想这样写（这里用了 Haskell 语法）：

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
