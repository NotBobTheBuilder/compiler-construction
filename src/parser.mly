%token <int> NUMBER

%token ADD
%token SUB
%token MUL
%token DIV
%token MOD
%token EOF

%token TRUE
%token FALSE

%token VAR
%token EQ
%token SEMICOLON

%token FUNCTION
%token RETURN
%token BRACKET_OPEN
%token BRACKET_CLOSE
%token COMMA
%token BRACE_OPEN
%token BRACE_CLOSE

%token <string> IDENT

%left ADD
%left SUB
%left MUL
%left DIV
%left MOD

%start <Js.expr Js.statement list> top
%%
top:
    | el = list(statement); EOF { el }
    ;

exp:
    | i = NUMBER              { Js.Number i }
    | FALSE                   { Js.False }
    | TRUE                    { Js.True }
    | f = func                { f }
    | f = funcCall            { f }
    | e = exp; ADD; f = exp   { Js.Add (e, f) }
    | e = exp; SUB; f = exp   { Js.Sub (e, f) }
    | e = exp; MUL; f = exp   { Js.Mul (e, f) }
    | e = exp; DIV; f = exp   { Js.Div (e, f) }
    | e = exp; MOD; f = exp   { Js.Mod (e, f) }
    | i = IDENT               { Js.Ident i }
    ;

funcCall:
    | i = IDENT; BRACKET_OPEN; ps = separated_list(COMMA, exp); BRACKET_CLOSE { Js.Call (i, ps )}
    ;

statement:
    | RETURN; e = exp; SEMICOLON              { Js.Return e }
    | VAR; e = IDENT; EQ; f = exp; SEMICOLON  { Js.Assign (e, f) }
    | e = exp; SEMICOLON                      { Js.Expr e }
    ;

func:
    | FUNCTION; ps = paramList; body = functionBody { Js.Function (None, ps, body )}
    | FUNCTION; i = IDENT; ps = paramList; body = functionBody { Js.Function (Some(i), ps, body )}

paramList:
    | BRACKET_OPEN; ps = separated_list(COMMA, IDENT); BRACKET_CLOSE { ps }

functionBody:
    | BRACE_OPEN; ss = list(statement); BRACE_CLOSE { ss }
