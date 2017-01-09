#lang brag

; main structure
program: (let-statement | define-statement )+
let-statement: let id colon [mutable-tag] type eq (lit | id | func-call| expr) [delimit]
relet-statement: let id eq (lit | id | func-call | expr) [delimit]
define-statement: def id signature scope-statement
func-call: id (lit | id | func-call | expr)*

statement: (let-statement | func-call | expr | relet-statement) delimit

;code blocks
scope-statement: lbrac (statement|while-loop|conditional)*
                 rbrac

; Typing statements
type: TYPE | ARRAY-TYPE lSqBrac TYPE rSqBrac ;;; "int" | "array[int]"
signature: (((id colon type comma)* id colon type) | nonetype) arrow (type | nonetype)

; control-flow
while-loop: while lparen (comparison | id) rparen scope-statement            
conditional: if comparison scope-statement
             [else scope-statement]
comparison: (statement| lit| id) bool-comp (statement|lit|id) ;;; "x == y"


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


; Ops taken from http://math.purduecal.edu/~rlkraft/cs31600-2012/chapter03/syntax-examples.html

expr: term [(add | sub) term]*
term: factor [(mult | div) factor]*
factor: (lparen expr rparen | id | lit)

add: ADD-OP
sub: SUB-OP
mult: MULT-OP
div: DIV-OP

; data structure
lit: (int | float | string | array)
array: lSqBrac ((lit comma)* lit) rSqBrac ;;; [lit,lit,...]
int: INT
float: FLOAT
nonetype: NONE-TYPE
mutable-tag: MUT-TAG
string: STRING
while: WHILE           ;;; "while"
if: IF                 ;;; "if"
else: ELSE             ;;; "else"
bool-comp: BOOL-COMP   ;;; "==" | ">" ... ect

;;; Type info
arrow: ARROW   ;;; "->"

; other keywords
id: ID
def: DEF
let: LET



