#lang racket
(require "state-roster.rkt")

; Handles a 'let-statement branch of an AST
(define let-tag-handler
  ;;; add section for mutable lets
  (lambda (datum)
    (let ([mutable? (mutable-tag? datum)]
          [ast-result '()])
         (add-variables-defined (second (third datum))) ;;catalog it as variable
         (define is-array #f)
         (if mutable?                          ;; if immutaable, catalog it
             
             (and (set! is-array (equal? (second (sixth datum)) "array"))
                  (set! ast-result (append (list 'declaration)
                                           (list (list 'type (letType-handler (sixth datum)))) ;;type
                                           (list (correct-id-if-array (third datum) is-array))  ;; id
                                           (list (seventh datum))  ;; equal symbol
                                           (list (eighth datum)) ;;value
                                           (list (ninth datum)))))
             (and (set! is-array (equal? (second (fifth datum)) "array"))
                  (set! ast-result (append (list 'declaration)
                                           (list (list 'type (string-append
                                                              "const PROGMEM "
                                                              (letType-handler (fifth datum))))) ;;type
                                           (list (correct-id-if-array (third datum) is-array))  ;; id
                                           (list (sixth datum))  ;; equal symbol
                                           (list (seventh datum)) ;;value
                                           (list (eighth datum)))) ;; delimiter
                  (add-prog-mem-variable (third datum))))
      ast-result)))
             
             
(define correct-id-if-array
  (lambda (id-string is-array) 
    (if is-array
        (list 'id (string-append (second id-string) "[]"))
        id-string)))


; Translates types from original-AST to target AST.
(define letType-handler
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