#lang racket
#|
unpacker.rkt
By Logan Davis

DESCRIPTION:
    Unpacks an Arduino-C AST from the MinNo
    compiler's (tree-trasform) into a raw
    string.

TO USE:
    call (unpack) on an Arduino-C AST.

2/27/17 | Racket 6.8 | MacOS 10.11
|#

(define in-def #f) ;; a flag for if the unpacker is in a file definition


; unpacks an Arduino-C AST into a string
(define unpack
  (lambda (program-datum)
    (let ([program-structure (rest program-datum)]
          [sketch ""])
      (for ([item program-structure])
        (if (equal? (first item) 'definition) (set! in-def #t) '())
        (set! sketch (string-append sketch " " (correcter item) "\n")))
        (if in-def (set! in-def #f) '())
      sketch)))

; checks if a datum needs to be corrected or is ready to be unpacked.
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

; Either returns a corrected string or passes off the datum to a handler
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

; adds parens and commas to a func-call datum and unpacks
(define func-call-corrector
  (lambda (func-call-datum)
    (let ([func-call-string (string-append (second (second func-call-datum)) "(")]
          [call-ast (rest (rest func-call-datum))])
      (for ([item call-ast])
        (cond [(equal? (first item) 'lparen) ""]
              [(equal? (first item) 'rparen) ""]
              [(set! func-call-string
                     (string-append func-call-string (correcter item) ","))]))
      (correct-over-commaing (string-append func-call-string ")")))))

; adds parens and commas to a definition's sub-datum "args" and unpacks
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
          (string-append "(" arg-string ")")))))

(define correct-over-commaing
  (lambda (code-string)
    (string-replace code-string ",)" ")")))

(define correct-over-tabbing
  (lambda (sketch)
    (string-replace sketch "\t }" " }")))

(define correct-over-spacing
  (lambda (sketch)
    (string-replace (string-replace sketch "      " "") "  " " ")))
              
(provide (all-defined-out))