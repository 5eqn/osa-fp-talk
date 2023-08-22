import Data.Char

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

-- 证明 Parser 有一些特性，从而让 Haskell 提供 do-notation 语法糖

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

-- 一些样例处理函数

failure = Parser $ \_ -> Fail

char x = Parser f
  where
    f (hd : tl) | hd == x = Success () tl
    f _ = Fail

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
      let x = ord ch in if x >= 48 && x < 58 then Just (x - 48) else Nothing

string = Parser (f False)
  where
    f _ (hd : tl) | isLetter hd = case f True tl of
      Success res str -> Success (hd : res) str
      Fail -> Fail
    f True str = Success "" str
    f False _ = Fail

ident = do
  str <- string
  if str == "lam" || str == "let" || str == "in" || str == "app" || str == "add" || str == "if" || str == "then" || str == "else"
    then failure
    else return str

-- 选择

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
  exact "lam"
  param <- ident
  exact "->"
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
  | VApp Val Val -- app(f, x)
  | VAdd Val Val -- add(x, y)
  | VAlt Val Val Val Val -- if x == y then z else w

eval env (Num x) = VNum x
eval env (Var x) = go env
  where
    go ((name, value) : tl) | name == x = value
    go (hd : tl) = go tl
    go [] = VNum 114514
eval env (Lam param body) = VLam param (\arg -> eval ((param, arg) : env) body)
eval env (App func arg) = case eval env func of
  VLam _ f -> f (eval env arg)
  f -> VApp f (eval env arg)
eval env (Add lhs rhs) = case (eval env lhs, eval env rhs) of
  (VNum x, VNum y) -> VNum (x + y)
  (vx, vy) -> VAdd vx vy
eval env (Def name value next) = eval ((name, eval env value) : env) next
eval env (Alt lhs rhs z w) = case (eval env lhs, eval env rhs) of
  (VNum x, VNum y) -> if x == y then eval env z else eval env w
  (vx, vy) -> VAlt vx vy (eval env z) (eval env w)

-- 例子

test =
  unlines
    [ "if add(2, 4) == 6",
      "then app(lam x -> add(x, 2), 8)",
      "else 5"
    ]

fib =
  unlines
    [ "let Y = lam f -> app(",
      "  lam x -> app(f, app(x, x)),",
      "  lam x -> app(f, app(x, x))) in",
      "let fibgen = lam fib -> lam x ->",
      "  if x == 1 then 1 else",
      "  if x == 2 then 1 else",
      "    let y = add(x, -1) in",
      "    let z = add(x, -2) in",
      "    add(app(fib, y), app(fib, z)) in",
      "app(app(Y, fibgen), 8)"
    ]

-- 从这里开始执行

main = case run term fib of
  Success tm _ -> do
    case eval [] tm of
      VNum x -> print x
      val -> print "Result is not a number"
  Fail -> print "Parse failed"
