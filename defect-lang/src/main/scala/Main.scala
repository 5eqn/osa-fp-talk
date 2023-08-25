import scala.io.Source

// 一些辅助函数

def isNumeric(ch: Char) = ch >= '0' && ch <= '9'
def isAlphabetic(ch: Char) = ch >= 'A' && ch <= 'Z' || ch >= 'a' && ch <= 'z'

def collect(pred: Char => Boolean, str: String, acc: String): (String, String) =
  str.headOption match
    case Some(hd) if pred(hd) => collect(pred, str.tail, acc + hd);
    case _                    => (acc, str)

def keywords = List("lam", "let", "in", "app", "add", "if", "then", "else")

// 处理结果

enum Result[+A]:
  case Success(res: A, rem: String)
  case Fail

// 分析模块

case class Parser[A](run: String => Result[A]):
  def map[B](cont: A => B) = Parser(str =>
    run(str) match
      case Result.Success(res, rem) => Result.Success(cont(res), rem)
      case Result.Fail              => Result.Fail
  )
  def flatMap[B](cont: A => Parser[B]) = Parser(str =>
    run(str) match
      case Result.Success(res, rem) => cont(res).run(rem.trim())
      case Result.Fail              => Result.Fail
  )
  def |(another: Parser[A]) = Parser(str =>
    run(str) match
      case Result.Success(res, rem) => Result.Success(res, rem)
      case Result.Fail              => another.run(str)
  )

// 一些分析函数

def exact(exp: Char) = Parser(str =>
  str.headOption match
    case Some(hd) if hd == exp => Result.Success(hd, str.tail)
    case _                     => Result.Fail
)

def exact(exp: String) = Parser(str =>
  str.stripPrefix(exp) match
    case rem if rem.length() < str.length() => Result.Success(exp, rem)
    case _                                  => Result.Fail
)

def number = Parser(str =>
  val (res, rem) = collect(isNumeric, str, "")
  if res.length() > 0
  then Result.Success(res.toInt, rem)
  else Result.Fail
)

def ident = Parser(str =>
  val (res, rem) = collect(isAlphabetic, str, "")
  if res.length() > 0 && !keywords.contains(res)
  then Result.Success(res, rem)
  else Result.Fail
)

// 编程语言的数据结构

enum Term:
  case Num(value: Int)
  case Var(name: String)
  case Lam(param: String, body: Term)
  case App(func: Term, arg: Term)
  case Add(lhs: Term, rhs: Term)
  case Let(name: String, value: Term, next: Term)
  case Alt(lhs: Term, rhs: Term, x: Term, y: Term)

// 让机器理解编程语言

def pos = number.map(value => Term.Num(value))

def neg = for {
  _ <- exact('-')
  value <- number
} yield Term.Num(-value)

def atom = ident.map(name => Term.Var(name))

def lam = for {
  _ <- exact('(')
  param <- ident
  _ <- exact(')')
  _ <- exact("=>")
  body <- term
} yield Term.Lam(param, body)

def app = for {
  _ <- exact("app")
  _ <- exact('(')
  func <- term
  _ <- exact(',')
  arg <- term
  _ <- exact(')')
} yield Term.App(func, arg)

def add = for {
  _ <- exact("add")
  _ <- exact('(')
  lhs <- term
  _ <- exact(',')
  rhs <- term
  _ <- exact(')')
} yield Term.Add(lhs, rhs)

def let = for {
  _ <- exact("let")
  name <- ident
  _ <- exact('=')
  value <- term
  _ <- exact("in")
  next <- term
} yield Term.Let(name, value, next)

def alt = for {
  _ <- exact("if")
  lhs <- term
  _ <- exact("==")
  rhs <- term
  _ <- exact("then")
  x <- term
  _ <- exact("else")
  y <- term
} yield Term.Alt(lhs, rhs, x, y)

def term: Parser[Term] = pos | neg | atom | lam | app | add | let | alt

// 求值

enum Val:
  case Num(value: Int)
  case Lam(body: Val => Val)
  case Rec(env: Map[String, Val], term: Term)

def eval(env: Map[String, Val], term: Term): Val = term match
  case Term.Num(value) => Val.Num(value)
  case Term.Var(name) =>
    env(name) match
      case Val.Rec(loc, term) =>
        eval(loc + (name -> Val.Rec(loc, term)), term)
      case value => value
  case Term.Lam(param, body) =>
    Val.Lam(arg => eval(env + (param -> arg), body))
  case Term.App(func, arg) =>
    eval(env, func) match
      case Val.Lam(body) => body(eval(env, arg))
      case _             => throw new Exception("app")
  case Term.Add(lhs, rhs) =>
    (eval(env, lhs), eval(env, rhs)) match
      case (Val.Num(a), Val.Num(b)) => Val.Num(a + b)
      case _                        => throw new Exception("add")
  case Term.Let(name, value, next) =>
    eval(env + (name -> Val.Rec(env, value)), next)
  case Term.Alt(lhs, rhs, x, y) =>
    (eval(env, lhs), eval(env, rhs)) match
      case (Val.Num(a), Val.Num(b)) =>
        if a == b then eval(env, x) else eval(env, y)
      case _ => throw new Exception("alt")

// 从这里开始运行

@main def run() =
  val src = Source.fromFile("sample/rec-fib.defect")
  val str = src.mkString
  src.close()
  term.run(str) match
    case Result.Fail => println("Parse failed")
    case Result.Success(res, rem) =>
      eval(Map(), res) match
        case Val.Num(value) => println(value)
        case _              => println("Result is not a number")
