#lang racket
#|
compiler.rkt
Logan Davis

DESCRIPTION:
    The centeral file to wrap file opening and compiling
    for MinNo.

TO USE:
    Currently, change the input and output
    file paths and press command-R (macOS)

2/27/17 | Racket 6.8 | OS: MacOS
|#

(require (prefix-in brag: brag/support))
(require "lexer.rkt")
(require "grammar.rkt")
(require "handlerDirector.rkt")
(require "unpacker.rkt")


(define token-stream '()) ; accumulator



;recursively lexs a file-port accumulating tokens in token-stream.
(define reader
    (lambda (file)
      (if end-of-file
                  '()
                  (and (set! token-stream (append token-stream(list (tokenize file))))
                       (reader file)))))

(define source-code (open-input-file "../examples/potReader.minno")) ;;example file

(port-count-lines! source-code)  ;;enable line counting on port
(printf "File Found.\nTokenizing...\n")

(if (equal? (reader source-code) '())   ;If no mal-formed return was produced, print success
    (printf "File has been tokenized.\nParsing...\n")
    (printf "Error tokenizing file!\n"))

(define output-string (unpack
                (tree-transform
                 (syntax->datum (parse token-stream))))) ;; parse and return a datum



(printf "\nResult:\n-------\n~a" output-string)

(with-output-to-file "../examples/potReader.c" #:exists 'replace
  (lambda ()
    (printf "~a" output-string)))

(printf "Done!")
(exit)

