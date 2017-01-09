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
       (definition-tag-handler datum)])))

(provide (all-defined-out))