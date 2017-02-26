#lang racket

; Handles a 'let-statement branch of an AST
(define let-tag-handler
  ;;; add section for mutable lets
  (lambda (datum)
    (let ([mutable? (mutable-tag? datum)])
         (if mutable?
             (append (list 'declaration)
                     (list (list 'type (letType-handler (sixth datum)))) ;;type
                     (list (third datum))  ;; id
                     (list (seventh datum))  ;; equal symbol
                     (list (fix-bracketing-if-array (eighth datum))) ;;value
                     (list (ninth datum)))
             (append (list 'declaration)
                     (list (list 'type (string-append "const PROGMEM " (letType-handler (fifth datum))))) ;;type
                     (list (third datum))  ;; id
                     (list (sixth datum))  ;; equal symbol
                     (list (fix-bracketing-if-array (seventh datum))) ;;value
                     (list (eighth datum))))))) ;; delimiter

; Translates types from original-AST to target AST.
(define letType-handler
  ;;; TODO: add multi-dimensional array type handling.
  (lambda (datum)
    (cond [(equal? (second datum) "array")
           (string-append (fourth datum) "[]")]
          [else (second datum)])))

; checks to see if the given 'lit is an 'array
; if so, fix return the array ast with a c-style
; curly bracket. else return passed arguement unaltered.
(define fix-bracketing-if-array
  (lambda (value-ast)
    (cond [(equal? (first (second value-ast)) 'array)
           (append (list 'lit) (list (fix-array-bracketing (second value-ast))))]
          [else value-ast])))


#| ~~~~~ NO LONGER USED ~~~~~ |#
; Replaces all sqrBracs with curlyBracs in an array's AST
(define fix-array-bracketing
  (lambda (array-ast)
    (append (list 'array) (map bracketing-helper (rest array-ast)))))

; takes an array-ast elements and returns a curly bracket
; if a square bracket is given or the original arg otherwise.
(define bracketing-helper
  (lambda (datum)
    (define tag (first datum))
    (cond [(equal? tag 'lSqBrac) '(lBrac "{")]
          [(equal? tag 'rSqBrac) '(rBrac "}")]
          [(equal? tag 'lit)
           (cond [(equal? (first (second datum)) 'array)
                  (append (list 'lit)
                          (list (append (list 'array)
                                        (fix-array-bracketing (second datum)))))]
                 [else datum])]
          [else datum])))

; Verifies that a mutable tag is present in a let-statement
(define mutable-tag?
  (lambda (let-statement)
    (define result (filter (lambda (x) (equal? (first x) 'mutable-tag))
                           (rest let-statement)))
    (if (equal? (length result) 1) #t #f)))

(provide (all-defined-out))