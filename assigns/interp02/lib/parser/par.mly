%{
open Utils
%}

%token <int> NUM
%token <string> VAR
%token UNIT TRUE FALSE BOOL INT
%token LPAREN RPAREN
%token ADD SUB MUL DIV MOD
%token LT LTE GT GTE EQ NEQ
%token AND OR
%token IF THEN ELSE
%token LET REC IN FUN
%token COLON ARROW ASSERT
%token EOF

%start <sfexpr> prog  (* Output type is sfexpr *)

%%

prog:
  | toplets EOF { SToplets $1 }  (* Wrap in SToplets constructor *)

toplets:
  | /* empty */ { [] }
  | toplet toplets { $1 :: $2 }

toplet:
  | LET VAR args COLON ty EQ expr { SToplet { is_rec = false; name = $2; args = $3; ty = $5; value = $7 } }
  | LET REC VAR args COLON ty EQ expr { SToplet { is_rec = true; name = $3; args = $4; ty = $6; value = $8 } }

args:
  | /* empty */ { [] }
  | arg args { $1 :: $2 }

arg:
  | LPAREN VAR COLON ty RPAREN { ($2, $4) }

ty:
  | INT { IntTy }           (* Core language type *)
  | BOOL { BoolTy }
  | UNIT { UnitTy }
  | ty ARROW ty { FunTy ($1, $3) }
  | LPAREN ty RPAREN { $2 }

expr:
  | LET VAR args COLON ty EQ expr IN expr { SLet { is_rec = false; name = $2; ty = $5; value = $7; body = $9 } }
  | LET REC VAR args COLON ty EQ expr IN expr { SLet { is_rec = true; name = $3; ty = $6; value = $8; body = $10 } }
  | IF expr THEN expr ELSE expr { SIf ($2, $4, $6) }
  | FUN args ARROW expr { List.fold_right (fun (x, ty) acc -> SFun (x, ty, acc)) $2 $4 }
  | expr2 { $1 }

expr2:
  | expr2 bop expr2 { SBop ($2, $1, $3) }
  | ASSERT expr3 { SAssert $2 }
  | expr3 { $1 }

expr3:
  | NUM { SNum $1 }
  | VAR { SVar $1 }
  | UNIT { SUnit }
  | TRUE { STrue }
  | FALSE { SFalse }
  | LPAREN expr RPAREN { $2 }

bop:
  | ADD { Add }
  | SUB { Sub }
  | MUL { Mul }
  | DIV { Div }
  | MOD { Mod }
  | LT { Lt }
  | LTE { Lte }
  | GT { Gt }
  | GTE { Gte }
  | EQ { Eq }
  | NEQ { Neq }
  | AND { And }
  | OR { Or }
