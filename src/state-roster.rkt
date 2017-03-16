#lang racket

(define prog-mem-variables '())
(define variables-defined '())
(define arrays-defined '())
(define in-def-unpacking #f) ;; a flag for if the unpacker is in a file definition
(define in-func-call #f) ;; a flag to properly wrap prog-mem variables
(define in-scope-statement #f)

(define add-prog-mem-variable
  (lambda (item)
    (set! prog-mem-variables (append prog-mem-variables (list item)))))

(define add-variables-defined
  (lambda (item)
    (set! variables-defined (append variables-defined (list item)))))

(define add-arrays-defined
  (lambda (item)
    (set! arrays-defined (append arrays-defined (list item)))))

(define set-in-def-flag
  (lambda (state)
    (set! in-def-unpacking state)))

(define set-in-func-call-flag
  (lambda (state)
    (set! in-func-call state)))

(define set-in-scope-statement-flag
  (lambda (state)
    (set! in-scope-statement state)))

(provide (all-defined-out))