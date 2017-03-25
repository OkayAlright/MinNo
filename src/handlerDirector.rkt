#lang racket
#|
handlerDirector.rkt
Logan Davis

Description:
    The director for specific AST structures and handing them
    to handlers for translating.

To Use:
    Import into another racket file and call (tree-transform)
    on a syntax->datum list of a MinNo AST.


3/24/17 | Racket 6.8 | MacOS
|#
(require "definitionHandler.rkt")
(require "lettypeHandler.rkt")
(require "state-roster.rkt")


; Handles a 'program branch of an AST
(define program-tag-handler
  (lambda (datum)
    (let ([content (rest datum)]
          [new_program '(program)])
         (for ([item content])
           (set! new_program (append new_program (list (tree-transform item)))))
         new_program)))

; handles block statements by breaking them into one line statements and concatting them
(define scope-statement-handler
  (lambda (datum)
    (set-in-scope-statement-flag #t)
    (let ([block '('scope-statement)])
      (for ([item (rest datum)])
        (if (or (equal? (first item) 'lbrac) (equal? (first item) 'rbrac))
            (set! block (append block (list item)))
            (set! block (append block (list (tree-transform item))))))
      (set-in-scope-statement-flag #f)
      (list block))))

; processes oneline statements
(define statement-handler
  (lambda (datum)
    datum))

; handles conditions
(define conditional-handler
  (lambda (datum)
    datum))

; handles one line statements with a ";" delimiting it
(define delimited-statement-handler
  (lambda (datum)
    (append (second datum) (list (last datum)))))
    
; handles for loop structures
(define for-loop-handler
  (lambda (datum)
    (list (first datum)
          (second datum)
          (tree-transform (third datum))
          (fourth datum)
          (fifth datum)
          (tree-transform (sixth datum))
          (first (tree-transform (seventh datum))))))
          



; Takes some syntax->datum list of original AST and returns translated AST
(define tree-transform
  (lambda (datum)
    (define tag (first datum))
    (cond
      ;;;----------------TOP LEVEL PROGRAM-----------------------;;;
      [(equal? tag 'program) (program-tag-handler datum)]
      ;;;----------------LET STATEMENT---------------------------;;;
      [(equal? tag 'let-statement) (let-tag-handler datum)]
      [(equal? tag 'relet-statement) datum]
      ;;;----------------DEFINE STATEMENT------------------------;;;
      [(equal? tag 'define-statement)
       (append (definition-tag-handler datum) (scope-statement-handler (fifth datum)))]
      ;;;----------------STATEMENT HANDLER-----------------------;;;
      [(equal? tag 'statment) (statement-handler datum)]
      [(equal? tag 'delimited-statement) (delimited-statement-handler datum)]
      [(equal? tag 'scope-statement) (scope-statement-handler datum)]
      ;;;----------------CONDITIONAL-HANDLER---------------------;;;
      [(equal? tag 'conditional) (conditional-handler datum)]
      ;;;----------------RETURN-HANDLER--------------------------;;;
      [(equal? tag 'return-statement) datum]
      ;;;----------------LOOP-HANDLER----------------------------;;;
      [(equal? tag 'while-loop) datum]
      [(equal? tag 'for-loop) (for-loop-handler datum)])))


(provide (all-defined-out))