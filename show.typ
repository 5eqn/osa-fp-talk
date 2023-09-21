#import "template.typ": *

#show: project.with(
  title: "如何用 143 行代码搓出新编程语言？",
  authors: (
    "5eqn",
  ),
)

= 前言

#figure(
  image("res/tenet.png", width: 80%),
  caption: [
    《信条》剧照 / 不要试图理解它，要感受它
  ],
)

#pagebreak()

== 鸣谢

#columns(3)[
- Anqur
- AntibodyGame
- Clouder
- harpsichord
- launchd
#colbreak()
- N3M0
- Origami404
- San_Cai
- SeparateWings
- SoraShu
#colbreak()
- toaster
- yyx
- zc
- zly
- ...
]

#figure(
  image("res/osa.jpg", width: 80%),
  caption: [
    开源技术协会群二维码
  ],
)

#pagebreak()

== 导语

#figure(
  image("res/lang.png", width: 80%),
  caption: [
    ？
  ],
)

#pagebreak()

#figure(
  image("res/code.png", width: 80%),
  caption: [
    ！
  ],
)

#pagebreak()

#figure(
  image("res/pi.png", width: 80%),
  caption: [
    两步
  ],
)

#pagebreak()

#figure(
  image("res/cpp.png", width: 10%),
  caption: [
    这只是部分代码 #footnote[https://github.com/drmenguin/minilang-interpreter/blob/master/src/parser/parser.cpp] 
  ],
)

#pagebreak()

#figure(
  image("res/parser.png", width: 80%),
  caption: [
    我的程序 #footnote[https://github.com/5eqn/osa-fp-talk/blob/main/defect-lang/src/main/scala/Main.scala] 
  ],
)

#pagebreak()

#figure(
  image("res/python.png", width: 50%),
  caption: [
    keleshev/mini #footnote[https://github.com/keleshev/mini/blob/master/mini.py]
  ],
)

#pagebreak()

#figure(
  image("res/carbon.png", width: 80%),
  caption: [
    我的程序
  ],
)

#pagebreak()

= 第一部分 / 横看成岭侧成峰

#figure(
  image("res/swap.png", width: 80%),
  caption: [
    C 语言和函数式编程解决交换问题
  ],
)

#pagebreak()

== 1 / 4 什么是函数式编程？

#sect(title: "一些例题", color: "blue")[
1. 请写一个函数 `isNumeric`，判断一个字符是不是数字。
2. 请写一个函数 `isAlphabetic`，判断一个字符是不是字母。

答案在 GitHub #footnote[https://github.com/5eqn/osa-fp-talk/blob/ab7c09acf7e7ac38242d675984cb2888edccbcb4/defect-lang/src/main/scala/Main.scala#L6-L7]，我在 Talk 里也会讲。] 

#pagebreak()

== 2 / 4 来点更难的问题

#figure(
  image("res/string.png", width: 80%),
  caption: [
    C 和函数式编程对字符串的不同处理方式
  ],
)

#pagebreak()

#figure(
  image("res/option.png", width: 80%),
  caption: [
    str.headOption 有两种可能：存在或不存在
  ],
)

#pagebreak()

#sect(title: "例题", color: "blue")[
实现 `collect`，读取一个字符串，返回这个字符串以什么单词开头。
]

#pagebreak()

== 3 / 4 再难一点

#figure(
  image("res/recycle.png", width: 80%),
  caption: [
    你不想这样做
  ],
)

#pagebreak()

#sect(title: "例题", color: "blue")[
修改 `collect`，使其额外返回剩余的字符串。
]

#pagebreak()

== 4 / 4 现实是有失败的

#sect[```c
#include <studio.h>
int mian() {
  printf("Hell Word!")
  remake 0;
}
```]

#pagebreak()

#figure(
  image("res/cases.png", width: 80%),
  caption: [
    无论成功还是失败，都是结果！
  ],
)

#pagebreak()

#sect(title: "一些例题", color: "blue")[
1. 请写一个函数 `word`，提取字符串的第一个单词，单词为空则失败。
2. 请写一个函数 `exactChar(exp)`，判断字符串是否以字符 `exp` 开头。
3. 请写一个函数 `exactString(exp)`，判断字符串是否以字符串 `exp` 开头。
4. 请写一个函数 `number`，读入字符串开头的非负数字，可能有多位。
] 

#pagebreak()

= 第二部分：只用 143 行的秘密

#figure(
  image("res/reduce.png", width: 80%),
  caption: [
    提取共同逻辑
  ],
)

#pagebreak()

== 1 / 4 提取！

#figure(
  image("res/box.png", width: 80%),
  caption: [
    `Parser[A]` 封装 `String => Result[A]`
  ],
)

#pagebreak()

#sect(title: "一些例题", color: "blue")[
1. 封装 `word`。
2. 封装 `exactChar(exp)`。
3. 封装 `exactString(exp)`。
4. 封装 `number`。
]

#pagebreak()

== 2 / 4 截胡

#figure(
  image("res/term.png", width: 80%),
  caption: [
    要读入的东西有两种可能：是数字或是变量
  ],
)

#pagebreak()

#figure(
  image("res/map.png", width: 80%),
  caption: [
    截胡的过程
  ],
)

#pagebreak()

#sect(title: "例题", color: "blue")[
1. 实现 `pos`，用于读取一个正数并转化为 `Term.Num`。
2. 实现 `atom`，用于读取一个单词并转化为 `Term.Var`。
]

#pagebreak()

== 3 / 4 第二条命

#figure(
  image("res/flatmap.png", width: 80%),
  caption: [
    第二条命
  ],
)

#pagebreak()

#sect(title: "例题", color: "blue")[
实现 `neg`，用于读取一个负数并转化为 `Term.Num`。
]

#pagebreak()

== 4 / 4 神说，要有加

#figure(
  image("res/for.png", width: 80%),
  caption: [
    对应关系
  ],
)

#pagebreak()

#sect(title: "例题：读取以下程序", color: "blue")[
- `if a == b then c else d`，选择分支，记为 `Term.Alt(Term.Var("a"), ...)`
- `let x = 1 in x`，定义新值，记为 `Term.Let("x", Term.Num(1), Term.Var("x"))`
- `(x) => add(x, 1)`，创建匿名函数，记为 `Term.Lam("x", Term.Add(...))` 
- `app(f, x)`，函数调用，记为 `Term.App(Term.Var("f"), ...)`
]

#pagebreak()

= 第三部分 / 搓出编程语言！

#figure(
  image("res/defect.jpg", width: 80%),
  caption: [
    The Defect
  ],
)

#pagebreak()

== 1 / 2 神说，要有或

#figure(
  image("res/alt.png", width: 80%),
  caption: [
    尝试多条路径读入 `-2`
  ],
)

#pagebreak()

== 2 / 2 怎么求值？

#figure(
  image("res/enum.png", width: 80%),
  caption: [
    程序的数据结构
  ],
)
