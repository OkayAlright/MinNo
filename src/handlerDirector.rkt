#lang racket

(require "definitionHandler.rkt")
(require "lettypeHandler.rkt")

; Handles a 'program branch of an AST
(define program-tag-handler
  (lambda (datum)
    (let ([content (rest datum)]
          [new_program '(program)])
         (for ([item content])
           (set! new_program (append new_program (list (tree-transform item)))))
         new_program)))

(define scope-statement-handler
  (lambda (datum)
    (let ([block '('scope-statement)])
      (for ([item (rest datum)])
        (printf "working on ~a \n\n" item)
        (if (or (equal? (first item) 'lbrac) (equal? (first item) 'rbrac))
            (set! block (append block (list item)))
            (set! block (append block (list (tree-transform item))))))
     (list block))))

(define statement-handler
  (lambda (datum)
    datum))

(define conditional-handler
  (lambda (datum)
    datum))

(define delimited-statement-handler
  (lambda (datum)
    (append (second datum) (list (last datum)))))
    

; Takes some syntax->datum list of original AST and returns translated AST
(define tree-transform
  (lambda (datum)
    (define tag (first datum))
    (cond
      ;;;----------------TOP LEVEL PROGRAM-----------------------;;;
      [(equal? tag 'program)
       (program-tag-handler datum)]
      ;;;----------------LET STATEMENT---------------------------;;;
      [(equal? tag 'let-statement)
       (let-tag-handler datum)]
      ;;;----------------DEFINE STATEMENT------------------------;;;
      [(equal? tag 'define-statement)
       (append (definition-tag-handler datum)
               (scope-statement-handler (fifth datum)))]
      ;;;----------------STATEMENT HANDLER-----------------------;;;
      [(equal? tag 'statment) (statement-handler datum)]
      [(equal? tag 'delimited-statement) (delimited-statement-handler datum)]
      ;;;----------------CONDITIONAL-HANDLER---------------------;;;
      [(equal? tag 'conditional) (conditional-handler datum)])))

(provide (all-defined-out))