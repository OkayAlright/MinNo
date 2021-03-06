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

3/24/17 | Racket 6.8 | MacOS 10.11
|#
(require "state-roster.rkt")
(require "formatter.rkt")

; unpacks an Arduino-C AST into a string
(define unpack
  (lambda (program-datum)
    (let ([program-structure (rest program-datum)]
          [sketch ""])
      (for ([item program-structure])
        (if (equal? (first item) 'definition) (set-in-def-flag #t) '())
        (set! sketch (string-append sketch " " (correcter item) "\n")))
        (if in-def-unpacking (set-in-def-flag #f) '())
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
                               args
                               id
                               while-loop
                               conditional
                               for-loop))
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
    (cond [(equal? (first datum) 'delimit) (string-append ";\n" (make-string tab-level #\tab))]
          [(equal? (first datum) 'lSqBrac) "{"]
          [(equal? (first datum) 'rSqBrac) "}"]
          [(equal? (first datum) 'lbrac) (increase-tab-level-and-start-block)]
          [(equal? (first datum) 'rbrac) (lower-tab-level-and-delimit-block)]
          [(equal? (first datum) 'args) (arg-corrector datum)]
          [(equal? (first datum) 'func-call) (func-call-or-id datum)]
          [(equal? (first datum) 'id) (correct-if-immutable-or-array datum)]
          [(equal? (first datum) 'while-loop) (while-loop-corrector datum)]
          [(equal? (first datum) 'for-loop) (for-loop-corrector datum)]
          [(equal? (first datum) 'conditional) (conditional-corrector datum)]
          [else "PLACEHOLDER"])))

(define lower-tab-level-and-delimit-block
  (lambda ()
    (set-tab-level (- tab-level 1))
    (string-append "}\n" (make-string tab-level #\tab))))

(define increase-tab-level-and-start-block
  (lambda ()
    (set-tab-level (+ tab-level 1))
    (string-append "{\n" (make-string tab-level #\tab))))



(define while-loop-corrector
  (lambda (datum)
    (string-append "while(" (correcter (third datum)) ")" (correcter (fourth datum)))))

(define for-loop-corrector
  (lambda (datum)
    
    (string-append (make-one-line (string-append "for("
                                                 (remove-tabs-and-newlines
                                                  (string-append (correcter (third datum))
                                                                 (correcter (fourth datum))
                                                                 (correcter (fifth datum))
                                                                 (remove-delimit (correcter (sixth datum)))))
                                                 ")"))
                                                 (correcter (seventh datum)))))
;; corrects conditional if statements
(define conditional-corrector
  (lambda (datum)
    (string-append "if(" (correcter (third datum)) ")"
                   (correcter (fourth datum))
                   (if (member '(else "else") datum)
                       (string-append "else" (correcter (sixth datum)))
                       ""))))


;; deals with wrapping of values and progmem variables.
(define correct-if-immutable-or-array
  (lambda (datum)
    (let ([result (second datum)])
      (if (member (second datum) arrays-defined)
          (set! result (string-append result "[]"))
                '())
      (if (member '(lSqBrac "[") datum)
          (set! result (string-append result "[" (second (fourth datum)) "]"))
          '())
      (if (and (member datum prog-mem-variables) in-func-call)
          (set! result (string-append "pgm_read_word(&" result ")"))
          '())
      result)))

; check if it is not just a variable
(define func-call-or-id
  (lambda (datum)
    (if (member (second (second datum)) variables-defined)
        (correct-if-immutable-or-array (second datum))
        (func-call-corrector datum))))

; adds parens and commas to a func-call datum and unpacks
(define func-call-corrector
  (lambda (func-call-datum)
    (set-in-func-call-flag #t) ;; start in context
    (let ([func-call-string (string-append (second (second func-call-datum)) "(")]
          [call-ast (rest (rest func-call-datum))])
      (for ([item call-ast]) 
        (set-in-func-call-flag #t) ;; correct context for nested func calls
        (cond [(equal? (first item) 'lparen) ""]
              [(equal? (first item) 'rparen) ""]
              [(set! func-call-string
                     (string-append func-call-string (correcter item) ","))]))
      (set-in-func-call-flag #f)
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
          (correct-over-commaing (string-append "(" arg-string ")"))))))
          
(provide (all-defined-out))