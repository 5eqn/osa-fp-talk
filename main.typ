#import "template.typ": *

#show: project.with(
  title: "带你用函数式编程手搓自己的编程语言",
  authors: (
    "5eqn（电子鼠会梦见仿生猫猫虫吗）",
  ),
)

= 前言

== 自我介绍

哈深大二 CS 人，有较多工业编程实践 #footnote[在 GitHub 和某实验室。] 的同时爱好编程语言理论，喜欢发猫猫虫表情包以及玩 Eggy Party。如果愿意的话，考虑关注我的 GitHub 账号 #footnote[https://github.com/5eqn] qwq

== 目标受众

不论你出于什么原因，只要想学习怎么搓一个自己的编程语言，都可以来听！

不需要编程前置知识，这是因为函数式编程「大道至简」，只需要掌握「函数」就能开始使用。

只是，本次 Talk「不能」让你：

- 提高某门课程的成绩，因为函数式编程是冷门分支而不是捷径
- 独立搓出像 Rust 这种有竞争力的语言，因为个人力量只能搓小玩具
- 提高团队编程生产力，因为团队编程中最好采用成熟、有活跃社区的技术

不过即使函数式编程在功利意义上如此不堪，依靠它掌握独立搓出编程语言的能力，难道不是一件很酷的事情吗？如果还感兴趣的话，就继续听下去吧！

#sect(title: "补充：如果你真的想跟着做……", color: "blue")[
你需要安装 Haskell，Linux 用户可参考这篇文章 #footnote[https://zhuanlan.zhihu.com/p/455688955，处理了多版本适配]，Windows 用户考虑安装 WSL2 #footnote[https://learn.microsoft.com/zh-cn/windows/wsl/install] 后参考 Linux 用户做法。如果懒得安装 Haskell，可以选择使用在线编辑器 #footnote[例如 https://www.w3cschool.cn/tryrun/runcode?lang=haskell]。  
]

== 一节课真的能搓出来吗？

我不确定，但我会边讲边搓，如果搓出来了，就证明了真的能搓出来（

= 正文 

== 从 $1+1$ 开始

处理 `"1+1"` 和大块的代码看似天差地别，但在本节我将直接讲「最通用」的处理方法，通用到只要稍微改一点就能处理大块代码的程度。现在从 $1+1$ 开始，只是单纯为了降低思维负担。

首先明确一下需求：

- 处理 `"1+1"`，得到 `2`，啥也不剩
- 处理 `"1+1=4"`，得到 `2`，剩下 `"=4"`
- 处理 `"11+45and"`，得到 `56`，剩下 `"and"`
- 处理 `"114-514"`，直接爆炸，因为不是加法

怎么实现？既然是在「函数式编程」，一定是写「函数」啦！

具体地，我们想实现一个从「初始字符串」映射到「分析结果」的函数。

记这个函数为 $"plus"$，我们希望：

#sect[
#grid(columns: (auto, auto), gutter: 10pt, [
=== 函数眼光
- $"plus"(\""1+1"\") = "Success"(2)(\"""\")$
- $"plus"(\""11+45and"\") = "Success"(56)(\""and"\")$
- $"plus"(\""114-514"\") = "Fail"$
], [
=== 原需求
- 处理 `"1+1"`，得到 `2`，啥也不剩
- 处理 `"11+45and"`，得到 `56`，剩下 `"and"`
- 处理 `"114-514"`，直接报错，因为不是加法
])]

#sect(title: "你可能会问：函数不是只能从数到数吗？", color: "red")[考虑字符串 `aabc` 的长度。是不是很显然是 $4$？这里，「的长度」就是从字符串到数的函数。]

由此可见，$"plus"$ 的功能就是判断字符串是否以一个合法的加法式子开头，分析结果有两种可能：

- #tag[分析成功] 返回「值」$r : ZZ$ 和「剩余字符串」$s : "String"$，记为 $"Success"(r)(s)$
- #tag[分析失败] 直接爆炸，记为 $"Fail"$

=== 怎么把这些写成程序？

我们需要一个「函数式编程语言」，这里我选择 Haskell。把上面的东西翻译成 Haskell，记 `"1+1"`、`"1+1=4"` 这种字符串的类型为 `String`，`2`、`56` 这种整数的类型为 `Int`，把分析结果的类型取名为 `ParseResult Int`，则函数可以记为：

#sect[
```haskell
plus : String -> ParseResult Int
```
]

这个类型很长，为方便起见，规定 `Parser Int = String -> ParseResult Int`。

`ParseResult Int` 的定义如下：

#sect[
#grid(columns: (auto, auto), gutter: 10pt, [
=== Haskell 写法
```haskell
data ParseResult Int =
  | Success Int String
  | Fail
```
], [
=== 函数眼光
分析结果有两种可能，
- 分析成功：返回「值」$r : ZZ$ 和「剩余字符串」$s : "String"$
- 分析失败：啥也不返回，记为 $"Fail"$
])]

如果值类型不是整数 `Int`，而是其他的类型，比如 `String` 或者表示不含信息的 `()` 类型，要怎么写成 Haskell？难道分别实现 `ParseResult Int`、`ParseResult String` 和 `ParseResult ()` 吗？并没有这么麻烦，我们可以随便选个不引起歧义的名字来代表这个可变的类型：

#sect[
#grid(columns: (auto, auto), gutter: 10pt, [
=== Haskell 写法
```haskell
data ParseResult a =
  | Success a String
  | Fail
```
], [
=== 函数眼光
分析结果有两种可能，
- 分析成功：返回「值」$r : a$ 和「剩余字符串」$s : "String"$
- 分析失败：啥也不返回，记为 $"Fail"$
])]

#sect(title: "补充", color: "blue")[这就是代数数据类型。] 

有了这些定义，就可以把 `plus` 的几个例子用 Haskell 写出来：

#sect[
#grid(columns: (auto, auto), gutter: 10pt, [
=== Haskell 写法
- `plus "1+1" = Success 2 ""`
- `plus "11+45and" = Success 56 "and"`
- `plus "114-514" = Fail`
], [
=== 函数眼光
- $"plus"(\""1+1"\") = "Success"(2)(\"""\")$
- $"plus"(\""11+45and"\") = "Success"(56)(\""and"\")$
- $"plus"(\""114-514"\") = "Fail"$
])]

是不是相当直观？

如果感觉直观的话，你已经掌握了 Haskell 程序的基本书写方法，克服了约 20% 的困难！

=== 拼接

假设我们已经实现了下面两个小函数：

- $"char"(x)(s)$ 判断字符串 $s$ 是否以 $x$ 开头，是则吞掉字符 $x$，值为空，用 `()` 表示
  - `char 'A' "Anqur" = Success () "nqur"`
- $"num"(s)$ 判断字符串 $s$ 是否以数字开头，是则吞掉开头的数字，值为被吞的数字
  - `num "51121 511121" = Success 51121 " 511121"`

我们要怎么用这两个小函数，拼成读取加法式子的大函数呢？

当然是一步一步来。假设输入的字符串为 $\""1+1"\"$：

- 判断 $"num"(\""1+1"\")$ 是成功还是失败
  - 成功，剩余 $\""+1"\"$，值为 $1$，判断 $"char"(\'"+"\')(\""+1"\")$ 是成功还是失败
    - 成功，剩余 $\""1"\"$，忽略值，判断 $"num"(\""1"\")$ 是成功还是失败
      - 成功，剩余 $\"""\"$，值为 $1$，那整体也剩余 $\"""\"$，值为 $1 + 1 = 2$

假设输入的字符串为未知的 $s$，可以这样处理：

- 判断 $"num"(s)$ 是成功还是失败
  - 如果失败，说明 $s$ 不以数字开头，分析失败
  - 如果成功，剩余 $s_1$，值为 $a$，判断 $"char"(\'"+"\')(s_1)$ 是成功还是失败
    - 如果失败，说明 $s_1$ 不以加号开头，不是加法运算，分析失败
    - 如果成功，剩余 $s_2$，忽略值，判断 $"num"(s_2)$ 是成功还是失败
      - 如果失败，说明 $s_2$ 不以数字开头，加号右边不紧跟数字，分析失败
      - 如果成功，剩余 $s_3$，值为 $b$，那整体也剩余 $s_3$，值为 $a + b$

把这些翻译成 Haskell：

#sect[
#grid(columns: (auto, auto), gutter: 10pt, [
=== Haskell 写法
```haskell
plus : Parser Int
plus str = case num str of
  Fail => Fail
  Success a str1 => case (char '+') str1 of
    Fail => Fail
    Success _ str2 => case num str2 of
      Fail => Fail
      Success b str3 => Success (a + b) str3
```
], [
=== 函数眼光
- 判断 $"num"(s)$ 是成功还是失败
  - 失败，整个寄掉
  - 成功，判断 $"char"(\'"+"\')(s_1)$
    - 失败，整个寄掉
    - 成功，判断 $"num"(s_2)$
      - 失败，整个寄掉
      - 成功，返回 $a + b$
])]

注意到代码中每次用 `num`、`char '+'` 这种「小函数」的时候都会被迫进行一次判断，还要产生一个新的字符串变量，这很坏。

不妨请点场外援助：

#sect[
#grid(columns: (auto, auto), gutter: 10pt, [
=== Haskell 写法
```haskell
plus : Parser Int
plus = 
  bind (num) (
    \a =>
      bind (char '+') (
        \_ =>
          bind (num) (
            \b =>
              Success (a + b)
          )
      )
  )
```
], [
=== 函数眼光
你请了 $"bind"$ 函数来帮助你，于是过程变为：
- 计划用 $"num"$ 判断当前字符串，让 $"bind"$ 帮你判断，你开始摆烂睡觉，有结果了 $"bind"$ 再叫醒你
  - 你被用结果 $a$ 叫醒了，让 $"bind"$ 再帮你用 $"char"(\'"+"\')$ 判断剩余字符串，继续睡觉
    - 你被叫醒了，但不在乎结果是什么，让 $"bind"$ 再帮你用 $"num"$ 判断剩余字符串，继续睡觉
      - 你被用结果 $b$ 叫醒了，得到结果 $a + b$
$"bind"$ 如果爆炸就不能叫醒你了，直接 `Fail`。
])]

由于 $"bind"$ 函数太好用，Haskell 为此建立了一套新的语法：

#sect[
#grid(columns: (auto, auto), gutter: 10pt, [
=== Haskell 写法
```haskell
plus : Parser Int
plus = do
  a <- num
  char '+'
  b <- num
  Success (a + b)
```
], [
=== 函数眼光
你其实还是请了 $"bind"$，但他失去了存在感，因此过程是：
- 用 $"num"$，睡一觉，得到 $a$
- 用 $"char"(\'"+"\')$，睡一觉，忽略结果
- 用 $"num"$，睡一觉，得到 $b$
- 结果就是 $a + b$
])]

#sect(title: "补充", color: "blue")[要用这套语法，需要为 `Parser` 实现 `Monad` Typeclass，具体需要实现的函数在文末给出。] 

是不是比开头短了好多好多？这就是为什么 $"bind"$ 是神。$"bind"$ 的类型是：

#sect[
```haskell
bind : (prev : Parser a) -> (next : a -> Parser b) -> Parser b
```
]

等等，这好像有点长！但别急，这刻画的其实就是上面的「摆烂」：

- #tag[prev] 摆烂前构造出的分析函数
- #tag[next] 摆烂后的行动，接受 `prev` 的结果，给出下一步的分析函数
- 请思考：结果的类型为什么是 `Parser b`？

#sect(title: "解释", color: "blue")[`bind` 的返回类型是 `Parser b`，有两层原因：

- 如果 `prev str` 处理成功，值为 `x`，我们希望最终结果为下一步操作结果 `next x str`
- 如果 `prev str` 处理失败，结果为 `Fail`，类型也可以是 `ParseResult b`

但这个 `str` 只是参数，所以 `bind` 返回类型是 `String -> ParseResult b`。

也可以利用下面 `bind` 的实现来理解为什么返回类型是 `Parser b`。] 

但摆烂是有代价的：你需要实现 `bind` 函数。要不要试着实现一下？如果不熟悉 Haskell 语法的话，用伪码也行😋

3, 2, 1...

#pagebreak()

啊哈哈哈，实现来咯！

#sect[
```haskell
bind : (prev : Parser a) -> (next : a -> Parser b) -> Parser b
bind prev next str =
  case prev str of -- is result of `prev str` success or fail?
    Fail => Fail -- if fail, the whole module fails
    Success res str' => next res str' -- otherwise run `next` with
                                      -- result and consumed string
```
]

恭喜你克服了约 80% 的难关！剩下约 20% 有信心继续攻克吗？

== 加或减

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

如果要使用 `alt`，只需要连续地传递两个参数即可：

#sect[
```haskell
plusOrMinus : Parser Int
plusOrMinus = alt plus minus
```
] 

要不要试试实现 `alt` 呢？比 `bind` 容易哦！

3, 2, 1...

#pagebreak()

啊哈哈哈，实现又来咯！

#sect[
```haskell
alt : Parser a -> Parser a -> Parser a
alt mod mod' str = case mod str of
  Success res str' => Success res str'
  Fail => mod' str
```
]

用这些知识足以实现一个自己的玩具编程语言，我会现场带大家实现。成品将被放在 GitHub #footnote[https://github.com/5eqn/osa-fp-talk]。

=== 扩展阅读：实现 Monad 还需要哪些函数

#sect(color: "blue", title: "pure 函数")[
`pure` 用于把值直接转换成对应的语法分析模块，不修改字符串：

```haskell
pure : a -> Parser a
pure x str = Success x str -- alternatively, pure = Success, proof left as exercise
```

`pure` 有时以 `return` 形态出现。
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

== 设计草稿，最终版会删

- promise
  - explicit: will get language done, can master
  - I mixed a weak promise with uncertainty
- cycle
  - talk about how everything is function more?
- fence
  - separate from normal programming?
  - with cycle
- question (7s)
  - I would just randomly add the questions when actually implementing
- time (11AM)
  - perhaps?
