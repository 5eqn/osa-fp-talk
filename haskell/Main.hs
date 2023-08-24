-- 该实现不支持自己调用自己的函数

import Data.Char
import GHC.Base

-- 辅助函数

trim (' ' : tl) = trim tl
trim ('\n' : tl) = trim tl
trim str = str

-- 数据结构

data ParseResult a
  = Success a String
  | Fail
  deriving (Show)

newtype Parser a = Parser {run :: String -> ParseResult a}

-- 一些处理函数

failure = Parser $ \_ -> Fail

char x = Parser $ \str ->
  case str of
    (hd : tl) | hd == x -> Success () tl
    otherwise -> Fail

exact x = Parser (f x)
  where
    f (hd : tl) (hd' : tl') | hd == hd' = f tl tl'
    f [] str = Success () str
    f _ _ = Fail

number = Parser (f False 0)
  where
    f _ res (hd : tl) | Just d <- toDigit hd = f True (res * 10 + d) tl
    f True res str = Success res str
    f False _ _ = Fail
    toDigit ch =
      if isDigit ch then Just (digitToInt ch) else Nothing

string = Parser (f False)
  where
    f _ (hd : tl) | isLetter hd = case f True tl of
      Success res str -> Success (hd : res) str
      Fail -> Fail
    f True str = Success "" str
    f False _ = Fail

keywords = ["lam", "let", "in", "app", "add", "if", "then", "else"]

ident = Parser $ \str ->
  case run string str of
    Success res str' | not (elem res keywords) -> Success res str'
    otherwise -> Fail

-- 证明 Parser 有一些数学性质

instance Functor Parser where
  fmap f parser = Parser $ \str ->
    case run parser str of
      Fail -> Fail
      Success res str' -> Success (f res) str'

instance Applicative Parser where
  pure x = Parser (Success x)
  f <*> x = Parser $ \str ->
    case run f str of
      Fail -> Fail
      Success res str' -> run (fmap res x) (trim str')

instance Monad Parser where
  prev >>= next = Parser $ \str ->
    case run prev str of
      Fail -> Fail
      Success res str' -> run (next res) (trim str')

instance Alternative Parser where
  empty = failure
  p <|> q = Parser $ \str ->
    case run p str of
      Success res str' -> Success res str'
      Fail -> run q str

-- 编程语言本身的数据结构

data Term
  = Num Int -- 5
  | Var String -- x
  | Lam String Term -- lam x -> y
  | App Term Term -- app(f, x)
  | Add Term Term -- add(x, y)
  | Def String Term Term -- let x = y in z
  | Alt Term Term Term Term -- if x = y then z else w
  deriving (Show)

-- 让机器理解语言

pos = do
  value <- number
  pure (Num value)

neg = do
  char '-'
  value <- number
  pure (Num (- value))

var = do
  name <- ident
  pure (Var name)

lam = do
  char '('
  param <- ident
  char ')'
  exact "=>"
  body <- term
  pure (Lam param body)

app = do
  exact "app"
  char '('
  func <- term
  char ','
  arg <- term
  char ')'
  pure (App func arg)

add = do
  exact "add"
  char '('
  lhs <- term
  char ','
  rhs <- term
  char ')'
  pure (Add lhs rhs)

def = do
  exact "let"
  name <- ident
  char '='
  value <- term
  exact "in"
  next <- term
  pure (Def name value next)

alt = do
  exact "if"
  lhs <- term
  exact "=="
  rhs <- term
  exact "then"
  z <- term
  exact "else"
  w <- term
  pure (Alt lhs rhs z w)

term = pos <|> neg <|> var <|> lam <|> app <|> add <|> def <|> alt

-- 求值

data Val
  = VNum Int -- 5
  | VLam String (Val -> Val) -- lam x -> y

eval env (Num x) = VNum x
eval env (Var x) = f env
  where
    f ((name, value) : tl) | name == x = value
    f (hd : tl) = f tl
    f [] = error "Variable out of scope"
eval env (Lam param body) =
  VLam param (\arg -> eval ((param, arg) : env) body)
eval env (App func arg) =
  case eval env func of
    VLam _ f -> f (eval env arg)
    otherwise -> error "Apply to non-function"
eval env (Add lhs rhs) =
  case (eval env lhs, eval env rhs) of
    (VNum x, VNum y) -> VNum (x + y)
    otherwise -> error "Add non-numbers"
eval env (Def name value next) =
  eval ((name, eval env value) : env) next
eval env (Alt lhs rhs z w) =
  case (eval env lhs, eval env rhs) of
    (VNum x, VNum y) -> if x == y then eval env z else eval env w
    otherwise -> error "Compare non-numbers"

-- 从这里开始执行

main = do
  program <- readFile "../defect-lang/sample/fib.defect"
  case run term program of
    Success tm _ -> do
      case eval [] tm of
        VNum x -> print x
        val -> error "Result is not a number"
    Fail -> error "Parse failed"
