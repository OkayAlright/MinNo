#lang racket
(define expected-tree-raw
  '(program
  (let-statement
   (let "let")
   (id "ledpin")
   (colon ":")
   (type "int")
   (eq "=")
   (statement (expr (term (factor (lit (int "13"))))))
   (delimit ";"))
  (let-statement
   (let "let")
   (id "stringtest")
   (colon ":")
   (type "array" (lSqBrac "[") "char" (rSqBrac "]"))
   (eq "=")
   (statement
    (expr
     (term
      (factor
       (lit (string "\"this is a test string.\\n\""))))))
   (delimit ";"))
  (let-statement
   (let "let")
   (id "testfloat")
   (colon ":")
   (type "float")
   (eq "=")
   (statement (expr (term (factor (lit (float "5.0"))))))
   (delimit ";"))
  (let-statement
   (let "let")
   (id "mutable_inttest")
   (colon ":")
   (mutable-tag "mutable")
   (type "int")
   (eq "=")
   (statement (expr (term (factor (lit (int "5"))))))
   (delimit ";"))
  (let-statement
   (let "let")
   (id "mutable_stringtest")
   (colon ":")
   (mutable-tag "mutable")
   (type "array" (lSqBrac "[") "char" (rSqBrac "]"))
   (eq "=")
   (statement
    (expr
     (term
      (factor
       (lit (string "\"this is a test string.\\n\""))))))
   (delimit ";"))
  (let-statement
   (let "let")
   (id "mutable_testfloat")
   (colon ":")
   (mutable-tag "mutable")
   (type "float")
   (eq "=")
   (statement (expr (term (factor (lit (float "56.0"))))))
   (delimit ";"))
  (let-statement
   (let "let")
   (id "expr_inttest")
   (colon ":")
   (type "int")
   (eq "=")
   (statement
    (expr
     (term (factor (lit (int "5"))))
     (add "+")
     (term
      (factor
       (lparen "(")
       (expr
        (term (factor (lit (int "7"))))
        (add "+")
        (term (factor (lit (int "9")))))
       (rparen ")"))
      (mult "*")
      (factor (lit (int "8"))))))
   (delimit ";"))
  (let-statement
   (let "let")
   (id "expr_floattest")
   (colon ":")
   (type "float")
   (eq "=")
   (statement
    (expr
     (term (factor (lit (float "5.0"))))
     (add "+")
     (term
      (factor
       (lparen "(")
       (expr
        (term (factor (lit (float "7.0"))))
        (add "+")
        (term (factor (lit (float "9.0")))))
       (rparen ")"))
      (mult "*")
      (factor (lit (float "8.0"))))))
   (delimit ";"))
  (define-statement
   (def "def")
   (id "setup")
   (signature
    (nonetype "none")
    (arrow "->")
    (nonetype "none"))
   (scope-statement
    (lbrac "{")
    (delimited-statement
     (statement
      (expr
       (func-call
        (id "pinMode")
        (id "ledpin")
        (id "OUTPUT"))))
     (delimit ";"))
    (delimited-statement
     (statement
      (expr
       (func-call
        (id "pinMode")
        (lit (int "3"))
        (id "INPUT"))))
     (delimit ";"))
    (relet-statement
     (id "mutable_testfloat")
     (eq "=")
     (statement (expr (term (factor (lit (float "8.0"))))))
     (delimit ";"))
    (relet-statement
     (id "mutable_inttest")
     (eq "=")
     (statement
      (expr
       (term (factor (lit (int "5"))))
       (add "+")
       (term (factor (lit (int "7"))))))
     (delimit ";"))
    (rbrac "}")))
  (define-statement
   (def "def")
   (id "loop")
   (signature
    (nonetype "none")
    (arrow "->")
    (nonetype "none"))
   (scope-statement
    (lbrac "{")
    (let-statement
     (let "let")
     (id "five")
     (colon ":")
     (type "int")
     (eq "=")
     (statement
      (expr
       (term
        (factor (lit (int "2")))
        (mult "*")
        (factor (lit (int "2"))))
       (add "+")
       (term (factor (lit (int "1"))))))
     (delimit ";"))
    (let-statement
     (let "let")
     (id "i")
     (colon ":")
     (mutable-tag "mutable")
     (type "int")
     (eq "=")
     (statement (expr (term (factor (lit (int "0"))))))
     (delimit ";"))
    (while-loop
     (while "while")
     (comparison
      (statement (expr (func-call (id "i"))))
      (bool-comp "<")
      (statement (expr (term (factor (lit (int "10")))))))
     (scope-statement
      (lbrac "{")
      (conditional
       (if "if")
       (comparison
        (lparen "(")
        (comparison
         (statement (expr (func-call (id "i"))))
         (bool-comp "<=")
         (statement
          (expr (term (factor (lit (int "10")))))))
        (rparen ")")
        (bool-comp "&&")
        (lparen "(")
        (comparison
         (statement (expr (func-call (id "five"))))
         (bool-comp "==")
         (statement
          (expr (term (factor (lit (int "5")))))))
        (rparen ")"))
       (scope-statement
        (lbrac "{")
        (relet-statement
         (id "i")
         (eq "=")
         (statement
          (expr (term (factor (lit (int "10"))))))
         (delimit ";"))
        (rbrac "}"))
       (else "else")
       (scope-statement
        (lbrac "{")
        (relet-statement
         (id "i")
         (eq "=")
         (statement (expr (term (factor (lit (int "1"))))))
         (delimit ";"))
        (rbrac "}")))
      (rbrac "}")))
    (for-loop
     (for "for")
     (let-statement
      (let "let")
      (id "a")
      (colon ":")
      (mutable-tag "mutable")
      (type "int")
      (eq "=")
      (statement (expr (term (factor (lit (int "0"))))))
      (delimit ";"))
     (comparison
      (statement (expr (func-call (id "a"))))
      (bool-comp "<=")
      (statement (expr (term (factor (lit (int "10")))))))
     (delimit ";")
     (relet-statement
      (id "a")
      (eq "=")
      (statement
       (expr
        (func-call (id "a"))
        (add "+")
        (term (factor (lit (int "1"))))))
      (delimit ";"))
     (scope-statement
      (lbrac "{")
      (relet-statement
       (id "i")
       (eq "=")
       (statement
        (expr
         (func-call (id "i"))
         (sub "-")
         (term (factor (lit (int "1"))))))
       (delimit ";"))
      (rbrac "}")))
    (rbrac "}")))
  (define-statement
   (def "def")
   (id "test_fun")
   (signature
    (id "x")
    (colon ":")
    (type "int")
    (comma ",")
    (id "i")
    (colon ":")
    (type "int")
    (arrow "->")
    (type "int"))
   (scope-statement
    (lbrac "{")
    (return-statement
     (return "return")
     (delimited-statement
      (statement
       (expr
        (func-call (id "x"))
        (add "+")
        (term (factor (id "i")))))
      (delimit ";")))
    (rbrac "}")))))

(provide (all-defined-out))