%{
open Utils

let rec mk_app e = function
  | [] -> e
  | x :: es -> mk_app (SApp (e, x)) es
%}

%token <int> NUM
%token <string> VAR
%token UNIT
%token TRUE
%token FALSE
%token LPAREN
%token RPAREN
%token ADD
%token SUB
%token MUL
%token DIV
%token MOD
%token LT
%token LTE
%token GT
%token GTE
%token EQ
%token NEQ
%token AND
%token OR
%token IF
%token THEN
%token ELSE
%token LET
%token REC
%token IN
%token FUN
%token ARROW
%token COLON
%token EOF
%token INT
%token BOOL

%right OR
%right AND
%left LT LTE GT GTE EQ NEQ
%left ADD SUB
%left MUL DIV MOD

%start <Utils.prog> prog

%%

prog:
  | toplet_list EOF { $1 }

toplet_list:
  | toplet { [$1] }
  | toplet_list toplet { $1 @ [$2] }

toplet:
  | LET VAR args COLON ty EQ expr IN {
      { is_rec = false; name = $2; args = $3; ty = $5; value = $6 }
    }
  | LET REC VAR args COLON ty EQ expr IN {
      { is_rec = true; name = $3; args = $4; ty = $6; value = $7 }
    }

args:
  | /* empty */ { [] }
  | arg args { $1 :: $2 }

arg:
  | LPAREN VAR COLON ty RPAREN { ($2, $4) }

ty:
  | INT { IntTy }
  | BOOL { BoolTy }
  | UNIT { UnitTy }
  | ty ARROW ty { FunTy ($1, $3) }

expr:
  | IF expr THEN expr ELSE expr { SIf ($2, $4, $6) }
  | LET VAR EQ expr IN expr { SLet { is_rec = false; name = $2; args = []; ty = UnitTy; value = $4; body = $6 } }
  | FUN VAR ARROW expr { SFun { arg = ($2, UnitTy); args = []; body = $4 } }
  | expr2 { $1 }

expr2:
  | expr2 bop expr2 { SBop ($2, $1, $3) }
  | expr3 expr3* { mk_app $1 $2 }

expr3:
  | UNIT { SUnit }
  | TRUE { STrue }
  | FALSE { SFalse }
  | NUM { SNum $1 }
  | VAR { SVar $1 }
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