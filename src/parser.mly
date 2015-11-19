%token <int> NUMBER

%token ADD
%token SUB
%token MUL
%token DIV
%token MOD
%token LT
%token LTEQ
%token GT
%token GTEQ
%token EQEQ
%token EOF

%token TRUE
%token FALSE
%token UNDEFINED

%token VAR
%token EQ
%token SEMICOLON

%token FUNCTION
%token RETURN
%token IF
%token ELSE
%token WHILE
%token BRACKET_OPEN
%token BRACKET_CLOSE
%token COMMA
%token BRACE_OPEN
%token BRACE_CLOSE

%token <string> IDENT

%left EQEQ
%left LTEQ
%left GTEQ
%left LT
%left GT
%left ADD
%left SUB
%left MUL
%left DIV
%left MOD

%start <Js.statement list> top
%%
top:
    | el = list(statement); EOF { el }
    ;

exp:
    | i = NUMBER              { Js.Number i }
    | FALSE                   { Js.False }
    | TRUE                    { Js.True }
    | UNDEFINED               { Js.Undefined }
    | f = func                { f }
    | f = funcCall            { f }
    | e = exp; ADD; f = exp   { Js.Add (e, f) }
    | e = exp; SUB; f = exp   { Js.Sub (e, f) }
    | e = exp; MUL; f = exp   { Js.Mul (e, f) }
    | e = exp; DIV; f = exp   { Js.Div (e, f) }
    | e = exp; MOD; f = exp   { Js.Mod (e, f) }
    | e = exp; LT; f = exp    { Js.Lt (e, f) }
    | e = exp; LTEQ; f = exp  { Js.LtEq (e, f) }
    | e = exp; GT; f = exp    { Js.Gt (e, f) }
    | e = exp; GTEQ; f = exp  { Js.GtEq (e, f) }
    | e = exp; EQEQ; f = exp  { Js.Eq (e, f) }
    | i = IDENT               { Js.Ident i }
    ;

statement:
    | RETURN; e = exp; SEMICOLON              { Js.Return e }
    | VAR; e = IDENT; EQ; f = exp; SEMICOLON  { Js.Declare (e, f) }
    | e = IDENT; EQ; f = exp; SEMICOLON       { Js.Assign (e, f) }
    | w = whileBlock                          { w }
    | i = ifElseBlock                         { i }
    | i = ifBlock                             { i }
    | e = exp; SEMICOLON                      { Js.Expr e }
    ;

block:
    | BRACE_OPEN; b = list(statement); BRACE_CLOSE
      { b }
    ;

bracketed(X):
    | BRACKET_OPEN; x = X; BRACKET_CLOSE
      { x }
    ;

condStart(X):
  | X; condition = bracketed(exp); block = block
    { (condition, block) }
  ;

whileBlock:
  | b = condStart(WHILE)
    { Js.While b }
  ;

ifBlock:
    | b = condStart(IF)
      { Js.If b }
    ;

ifElseBlock:
    | i = condStart(IF); ELSE; f = block
      { let (e, t) = i in Js.IfElse (e, t, f) }
    ;

func:
    | FUNCTION; i = option(IDENT); ps = paramList; body = block
      { Js.Function (i, ps, Js.function_scope ps body, body@[Js.Return Js.Undefined] )}
    ;

funcCall:
    | i = IDENT; ps = bracketed(separated_list(COMMA, exp))
      { Js.Call (i, ps)}
    ;

paramList:
    | ps = bracketed(separated_list(COMMA, IDENT))
      { ps }
    ;
