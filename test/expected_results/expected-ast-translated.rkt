#lang racket
(define expected-ast-translated
  '(program
  (declaration
   (type "const PROGMEM int")
   (id "ledpin")
   (eq "=")
   (statement (expr (term (factor (lit (int "13"))))))
   (delimit ";"))
  (declaration
   (type "const PROGMEM char")
   (id "stringtest[]")
   (eq "=")
   (statement
    (expr
     (term
      (factor
       (lit (string "\"this is a test string.\\n\""))))))
   (delimit ";"))
  (declaration
   (type "const PROGMEM float")
   (id "testfloat")
   (eq "=")
   (statement (expr (term (factor (lit (float "5.0"))))))
   (delimit ";"))
  (declaration
   (type "int")
   (id "mutable_inttest")
   (eq "=")
   (statement (expr (term (factor (lit (int "5"))))))
   (delimit ";"))
  (declaration
   (type "char")
   (id "mutable_stringtest[]")
   (eq "=")
   (statement
    (expr
     (term
      (factor
       (lit (string "\"this is a test string.\\n\""))))))
   (delimit ";"))
  (declaration
   (type "float")
   (id "mutable_testfloat")
   (eq "=")
   (statement (expr (term (factor (lit (float "56.0"))))))
   (delimit ";"))
  (declaration
   (type "const PROGMEM int")
   (id "expr_inttest")
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
  (declaration
   (type "const PROGMEM float")
   (id "expr_floattest")
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
  (definition
   (void-type "void")
   (id "setup")
   (args (nonetype "none") (nonetype "none"))
   ('scope-statement
    (lbrac "{")
    (statement
     (expr
      (func-call
       (id "pinMode")
       (id "ledpin")
       (id "OUTPUT")))
     (delimit ";"))
    (statement
     (expr
      (func-call
       (id "pinMode")
       (lit (int "3"))
       (id "INPUT")))
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
  (definition
   (void-type "void")
   (id "loop")
   (args (nonetype "none") (nonetype "none"))
   ('scope-statement
    (lbrac "{")
    (declaration
     (type "const PROGMEM int")
     (id "five")
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
    (declaration
     (type "int")
     (id "i")
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
     (declaration
      (type "int")
      (id "a")
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
     ('scope-statement
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
  (definition
   (type "int")
   (id "test_fun")
   (args (type "int") (id "x") (type "int") (id "i"))
   ('scope-statement
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