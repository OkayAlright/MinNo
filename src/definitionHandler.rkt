#lang racket
#|
definitionHandler.rkt
By Logan Davis

Responible for translating function defition
ASTs.

3/24/17 | Racket 6.8 | MacOS
|#
(require "state-roster.rkt")

; The parent handler function to be called on a definition AST
(define definition-tag-handler
  (lambda (datum)
    (define id (third datum))
    (define return-type (get-return-type  (fourth datum)))
    (define args (get-args (fourth datum)))
    (list 'definition return-type id args)))

; Gets the return type of the def AST
(define get-return-type
  (lambda (signature)
    (define return-type (last signature))
    (cond [(equal? (first return-type) 'nonetype) '(void-type "void")]
          [else (list 'type (last return-type))])))

; Gets arguements from the definition AST
(define get-args
  (lambda (signature)
    (define args (get-args-helper signature))
    (define properly-formed-args '(args))
    (for ([item args])
      (set! properly-formed-args (append properly-formed-args (list (last item) (first item)))))
    properly-formed-args))
      
; Assists get-args in parsing sub-AST elements
(define get-args-helper
  (lambda (signature)
    (define full-arg-list '())
    (define arg-accumulator '())
    (for ([item (rest signature)]
          #:final (equal? (first item) 'arrow))
      (cond [(or (equal? (first item) 'comma)
                 (equal? (first item) 'arrow))
             (and (set! full-arg-list (append full-arg-list (list arg-accumulator)))
                  (set! arg-accumulator '()))]
            [else
             (and (set! arg-accumulator (append arg-accumulator (list item)))
                  (if (equal? (first item) 'id) (add-variables-defined (second item)) '()))]))
    full-arg-list))

(provide (all-defined-out))