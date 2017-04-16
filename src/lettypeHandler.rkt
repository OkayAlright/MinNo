#lang racket
#|
lettypeHandler.rkt
By Logan Davis

Responsible for prepping and translating let declarations
given by a handlerDirector.

3/24/17 | Racket 6.8 | MacOS
|#
(require "state-roster.rkt")

; Handles a 'let-statement branch of an AST
(define let-tag-handler
  ;;; add section for mutable lets
  (lambda (datum)
    (let ([mutable? (mutable-tag? datum)]
          [ast-result '()])
         (add-variables-defined (second (third datum))) ;;catalog it as variable
         (define is-array #f)
         (if mutable?                          ;; if immutable, catalog it
             
             (and (set! is-array (equal? (second (sixth datum)) "array"))
                  (set! ast-result (list  'declaration
                                          (list 'type (letType-handler-get-type (sixth datum))) ;;type
                                          (correct-id-if-array (third datum) is-array)  ;; id
                                          (seventh datum)  ;; equal symbol
                                          (eighth datum);;value
                                          (ninth datum))))
             (and (set! is-array (equal? (second (fifth datum)) "array"))
                  (set! ast-result (list  'declaration
                                          (list 'type (string-append
                                                       "const PROGMEM "
                                                       (letType-handler-get-type (fifth datum)))) ;;type
                                           (correct-id-if-array (third datum) is-array)  ;; id
                                           (sixth datum) ;; equal symbol
                                           (seventh datum) ;;value
                                           (eighth datum))) ;; delimiter
                  (if in-scope-statement '() (add-prog-mem-variable (third datum)))))
      ast-result)))
             
; Appends "[]" to the id tag for C's notation            
(define correct-id-if-array
  (lambda (id-string is-array) 
    (if is-array
        (list 'id (string-append (second id-string) "[]"))
        id-string)))


; Translates types from original-AST to target AST.
(define letType-handler-get-type
  ;;; TODO: add multi-dimensional array type handling.
  (lambda (datum)
    (cond [(equal? (second datum) "array") (fourth datum)]
          [else (second datum)])))


; Verifies that a mutable tag is present in a let-statement
(define mutable-tag?
  (lambda (let-statement)
    (define result (filter (lambda (x) (equal? (first x) 'mutable-tag))
                           (rest let-statement)))
    (if (equal? (length result) 1) #t #f)))

(provide (all-defined-out))