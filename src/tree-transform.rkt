#lang racket
#|
tree-transform.rkt
Logan Davis

Description:
    An in-progress transcompiler to turn a <new languages name>
    AST into an Arduino-C AST to be unpacked.

To Use:
    Import into another racket file and call (tree-transform)
    on a syntax->datum list of the <new language>s AST.


11/28/16 | Racket 6.6 | MIT License
|#

(require "handlerDirector.rkt")
(provide (all-defined-out))

#|
(tree-transform '(program
  (let-statement
   (let "let")
   (id "list_of_pins")
   (colon ":")
   (type "array" (lSqBrac "[") "int" (rSqBrac "]"))
   (eq "=")
   (statement
    (expr
     (term
      (factor
       (lit
        (array
         (lSqBrac "[")
         (lit (int "1"))
         (comma ",")
         (lit (int "2"))
         (comma ",")
         (lit (int "3"))
         (comma ",")
         (lit (int "4"))
         (comma ",")
         (lit (int "5"))
         (rSqBrac "]")))))))
   (delimit ";"))
  (let-statement
   (let "let")
   (id "on")
   (colon ":")
   (mutable-tag "mutable")
   (type "int")
   (eq "=")
   (statement
    (expr
     (term (factor (lit (int "7"))) (mult "*") (factor (lit (int "8"))))
     (sub "-")
     (term (factor (lit (int "5"))))))
   (delimit ";"))
  (let-statement
   (let "let")
   (id "a")
   (colon ":")
   (type "int")
   (eq "=")
   (statement
    (expr
     (func-call
      (id "addTwoNums")
      (lit (int "5"))
      (lparen "(")
      (expr
       (func-call
        (id "addTwoNums")
        (lit (int "6"))
        (lparen "(")
        (expr (term (factor (lit (int "7")))) (add "+") (term (factor (lit (int "7")))))
        (rparen ")")))
      (rparen ")"))))
   (delimit ";"))
  (define-statement
   (def "def")
   (id "turn_pattern")
   (signature
    (id "pattern")
    (colon ":")
    (type "int")
    (comma ",")
    (id "mode")
    (colon ":")
    (type "int")
    (arrow "->")
    (nonetype "none"))
   (scope-statement
    (lbrac "{")
    (let-statement
     (let "let")
     (id "pattern1")
     (colon ":")
     (type "array" (lSqBrac "[") "int" (rSqBrac "]"))
     (eq "=")
     (statement
      (expr
       (term
        (factor
         (lit
          (array
           (lSqBrac "[")
           (lit (int "1"))
           (comma ",")
           (lit (int "2"))
           (comma ",")
           (lit (int "3"))
           (comma ",")
           (lit (int "5"))
           (rSqBrac "]")))))))
     (delimit ";"))
    (let-statement
     (let "let")
     (id "pattern2")
     (colon ":")
     (type "array" (lSqBrac "[") "int" (rSqBrac "]"))
     (eq "=")
     (statement
      (expr
       (term
        (factor
         (lit
          (array (lSqBrac "[") (lit (int "3")) (comma ",") (lit (int "6")) (rSqBrac "]")))))))
     (delimit ";"))
    (conditional
     (if "if")
     (comparison (id "pattern") (bool-comp "==") (lit (int "1")))
     (scope-statement
      (lbrac "{")
      (statement (expr (func-call (id "setPins") (id "mode") (id "pattern1"))))
      (delimit ";")
      (rbrac "}")))
    (conditional
     (if "if")
     (comparison (id "pattern") (bool-comp "==") (lit (int "2")))
     (scope-statement
      (lbrac "{")
      (statement (expr (func-call (id "setPins") (id "mode") (id "pattern2"))))
      (delimit ";")
      (rbrac "}")))
    (rbrac "}"))))) |#