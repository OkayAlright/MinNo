#lang brag

; main structure
program: (let-statement | define-statement )+

let-statement: let id colon [mutable-tag] type eq statement delimit
relet-statement: id eq statement delimit

define-statement: def id signature scope-statement


func-call: id (lit | id | lparen expr rparen)*
statement: expr
delimited-statement: statement delimit

return-statement: return delimited-statement

;code blocks
scope-statement: lbrac (delimited-statement| let-statement | relet-statement |
                        while-loop| for-loop | conditional|return-statement)*
                 rbrac

; Typing statements
type: TYPE | ARRAY-TYPE lSqBrac TYPE rSqBrac ;;; "int" | "array[int]"
signature: (((id colon type comma)* id colon type) | nonetype) arrow (type | nonetype)

; control-flow
while-loop: while (comparison | statement) scope-statement
for-loop: for (let-statement | relet-statement)
              comparison delimit
              relet-statement scope-statement
conditional: if comparison scope-statement
             [else scope-statement]
comparison: (statement | lparen comparison rparen)
            bool-comp
            (statement | lparen comparison rparen);;; "x == y"


; Seperating characters
lbrac: LBRAC   ;;; {
rbrac: RBRAC   ;;; }
lparen: LPAREN   ;;; ( 
rparen: RPAREN   ;;; )
lSqBrac: LSQBRAC   ;;; [
rSqBrac: RSQBRAC   ;;; ]
comma: COMMA    ;;; ,
colon: COLON    ;;; :
delimit: SEMI-COLON ;;; ;
eq: EQUAL ;;; =
return: RETURN

; Ops taken from http://math.purduecal.edu/~rlkraft/cs31600-2012/chapter03/syntax-examples.html

expr: (func-call | term) [(add | sub) term]*
term: factor [(mult | div) factor]*
factor: (lparen expr rparen | id | lit)

add: ADD-OP
sub: SUB-OP
mult: MULT-OP
div: DIV-OP

; data structure
lit: (int | float | string | array)
array: lSqBrac (((lit| id) comma)* (lit | id)) rSqBrac ;;; [lit,lit,...]
int: INT
float: FLOAT
nonetype: NONE-TYPE
mutable-tag: MUT-TAG
string: STRING
while: WHILE           ;;; "while"
for: FOR
if: IF                 ;;; "if"
else: ELSE             ;;; "else"
bool-comp: BOOL-COMP   ;;; "==" | ">" ... ect

;;; Type info
arrow: ARROW   ;;; "->"

; other keywords
id: ID[lSqBrac (int | id) rSqBrac]
def: DEF
let: LET



