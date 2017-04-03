#lang racket
#|
formatter.rkt

A set of utils for string correction in the MinNo compiler

3/24/17 | Racket 6.8 | MacOS
|#

(define correct-over-commaing
  (lambda (code-string)
    (string-replace (string-replace code-string ",)" ")") ", )" ")")))

(define correct-over-tabbing
  (lambda (sketch)
    (string-replace sketch "\t }" " }")))

(define remove-tabs
  (lambda (sketch)
    (string-replace sketch "\t" ""))) 

(define remove-newline
  (lambda (sketch)
    (string-replace sketch "\n" "")))

(define remove-tabs-and-newlines
  (lambda (sketch)
    (remove-tabs (remove-newline sketch))))

(define correct-over-spacing
  (lambda (sketch)
    (string-replace (string-replace sketch "      " "") "  " " ")))

(define remove-delimit
  (lambda (delimited-string)
    (string-replace delimited-string ";\n\t" "")))

(define make-one-line
  (lambda (multi-line-string)
    (string-replace multi-line-string ";\n\t" ";")))

(provide (all-defined-out))