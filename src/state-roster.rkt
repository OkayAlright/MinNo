#lang racket

(define prog-mem-variables '())
(define variables-defined '())
(define arrays-defined '())
(define in-def-unpacking #f) ;; a flag for if the unpacker is in a file definition
(define in-func-call #f) ;; a flag to properly wrap prog-mem variables

(define add-prog-mem-variable
  (lambda (item)
    (set! prog-mem-variables (append prog-mem-variables (list item)))))

(define add-variables-defined
  (lambda (item)
    (set! variables-defined (append variables-defined (list item)))))

(define add-arrays-defined
  (lambda (item)
    (set! arrays-defined (append arrays-defined (list item)))))

(provide (all-defined-out))