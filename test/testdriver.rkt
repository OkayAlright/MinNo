#lang racket
#|

|#

(require (prefix-in brag: brag/support))
(require "../src/lexer.rkt")
(require "../src/grammar.rkt")
(require "../src/handlerDirector.rkt")
(require "../src/unpacker.rkt")
(require "expected_results/expected-tree-raw.rkt")
(require "expected_results/expected-ast-translated.rkt")
(require "expected_results/expected-output-string.rkt")


(define token-stream '()) ; accumulator



;recursively lexs a file-port accumulating tokens in token-stream.
(define reader
    (lambda (file)
      (if end-of-file
                  '()
                  (and (set! token-stream (append token-stream(list (tokenize file))))
                       (reader file)))))

(define source-code (open-input-file "test_source/test1.minno")) ;;example file

(port-count-lines! source-code)  ;;enable line counting on port
(printf "File Found.\nTokenizing...\n")

(if (equal? (reader source-code) '())   ;If no mal-formed return was produced, print success
    (printf "File has been tokenized.\nParsing...\n")
    (and (printf "Error tokenizing file!\n")
         (exit)))
;;TEST 1
(define tree-raw (syntax->datum (parse token-stream)))
(printf "Result of raw tree generation is ~a\n" (if (equal? tree-raw expected-tree-raw) "passing" "failing"))

;;TEST 2
(define ast-translated (tree-transform tree-raw))
(printf "Result of ast transform generation is ~a\n" (if (equal? ast-translated expected-ast-translated) "passing" "failing"))

;;TEST 3
(define output-string (unpack ast-translated))
(printf "Result of C-output generation is ~a\n" (if (equal? output-string expected-output-string) "passing" "failing"))