#lang racket


(define in-def #f)

(define unpack
  (lambda (program-datum)
    (let ([program-structure (rest program-datum)]
          [sketch ""])
      (for ([item program-structure])
        (if (equal? (first item) 'definition) (set! in-def #t) '())
        (set! sketch (string-append sketch " " (correcter item) "\n")))
        (if in-def (set! in-def #f) '())
      sketch)))

(define correcter
  (lambda (datum)
    (define needs-correcting '(lSqBrac
                               rSqBrac
                               func-call
                               delimit
                               lbrac
                               rbrac
                               args))
    (let ([output ""])
      (if (member (first datum) needs-correcting)
          (set! output (string-append output (correction-handler datum))) ;;minor formatting changes need to be done
          (if (string? (second datum))
              (set! output (string-append output (second datum) )) ;;ready to go
              (let ([remaining-data (rest datum)]) ;;needs to be unpacked further
                (for ([item remaining-data])
                  (set! output (string-append output (correcter item) " "))))))
      (correct-over-tabbing (correct-over-spacing output)))))
  
(define correction-handler
  (lambda (datum)
    (cond [(equal? (first datum) 'delimit) ";\n\t"]
          [(equal? (first datum) 'lSqBrac) "{"]
          [(equal? (first datum) 'rSqBrac) "}"]
          [(equal? (first datum) 'lbrac) "{\n\t"]
          [(equal? (first datum) 'rbrac) "}\n"]
          [(equal? (first datum) 'args) (arg-corrector datum)]
          [(equal? (first datum) 'func-call) (func-call-corrector datum)]
          [else "PLACEHOLDER"])))

(define func-call-corrector
  (lambda (func-call-datum)
    (let ([func-call-string (string-append (second (second func-call-datum)) "(")]
          [call-ast (rest (rest func-call-datum))])
      (for ([item call-ast])
        (cond [(equal? (first item) 'lparen) ""]
              [(equal? (first item) 'rparen) ""]
              [(set! func-call-string
                     (string-append func-call-string (correcter item) ","))]))
      (string-append func-call-string ")"))))

(define arg-corrector
  (lambda (arg-datum)
    (if (equal? arg-datum '(args (nonetype "none") (nonetype "none")))
        "()"
        (let ([arg-string ""]
              [args (rest arg-datum)])
          (for ([item args])
            (if (equal? (first item) 'type)
                (set! arg-string (string-append arg-string (second item) " "))
                (set! arg-string (string-append arg-string (second item) ", "))))
          (correct-over-commaing (string-append "(" arg-string ")"))))))

(define correct-over-commaing
  (lambda (code-string)
    (string-replace code-string ",)" ")")))

(define correct-over-tabbing
  (lambda (sketch)
    (string-replace sketch "\t }" " }")))

(define correct-over-spacing
  (lambda (sketch)
    (string-replace (string-replace sketch "      " "") "  " " ")))
              
(define test
'(program
  (declaration
   (type "const PROGMEM int[]")
   (id "list_of_pins")
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
  (declaration
   (type "int")
   (id "on")
   (eq "=")
   (statement
    (expr
     (term (factor (lit (int "7"))) (mult "*") (factor (lit (int "8"))))
     (sub "-")
     (term (factor (lit (int "5"))))))
   (delimit ";"))
  (definition
   (void-type "void")
   (id "setup")
   (args (nonetype "none") (nonetype "none"))
   ('scope-statement
    (lbrac "{")
    (statement (expr (func-call (id "pinMode") (id "OUTPUT") (id "list_of_pins"))) (delimit ";"))
    (statement (expr (func-call (id "raw_c") (lit (string "\"Serial.begin(9600)\"")))) (delimit ";"))
    (rbrac "}")))
  (definition
   (void-type "void")
   (id "loop")
   (args (nonetype "none") (nonetype "none"))
   ('scope-statement (lbrac "{")
                     (statement
     (expr
      (func-call
       (id "addTwo")
       (lit (int "5"))
       (lparen "(")
       (expr
        (func-call
         (id "addTwo")
         (lit (int "6"))
         (lparen "(")
         (expr (term (factor (lit (int "8")))) (sub "-") (term (factor (lit (int "9")))))
         (rparen ")")))
       (rparen ")")))
     (delimit ";"))

                     (rbrac "}")))
  (definition
   (void-type "void")
   (id "turn_pattern")
   (args (type "int") (id "pattern") (type "int") (id "mode"))
   ('scope-statement
    (lbrac "{")
    (declaration
     (type "const PROGMEM int[]")
     (id "pattern1")
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
    (declaration
     (type "const PROGMEM int[]")
     (id "pattern2")
     (eq "=")
     (statement
      (expr
       (term
        (factor
         (lit (array (lSqBrac "[") (lit (int "3")) (comma ",") (lit (int "6")) (rSqBrac "]")))))))
     (delimit ";"))
    (statement
     (expr
      (func-call
       (id "addTwo")
       (lit (int "5"))
       (lparen "(")
       (expr
        (func-call
         (id "addTwo")
         (lit (int "6"))
         (lparen "(")
         (expr (term (factor (lit (int "8")))) (sub "-") (term (factor (lit (int "9")))))
         (rparen ")")))
       (rparen ")")))
     (delimit ";"))
    (rbrac "}")))))

(unpack test)