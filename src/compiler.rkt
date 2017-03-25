#lang racket
#|
compiler.rkt
Logan Davis

DESCRIPTION:
    The centeral file to wrap file opening and compiling
    for MinNo.

TO USE:
    Run from the command like and provide two arguements:
     - source_file: the MinNo file that you want to compile.
     - output_file: the path and name you want to give the 
                    resulting C program.

3/24/17 | Racket 6.8 | OS: MacOS
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

(define source-code (open-input-file (vector-ref (current-command-line-arguments) 0))) ;;example file

(port-count-lines! source-code)  ;;enable line counting on port
(printf "File Found.\nTokenizing...\n")

(if (equal? (reader source-code) '())   ;If no mal-formed return was produced, print success
    (printf "File has been tokenized.\nParsing...\n")
    (and (printf "Error tokenizing file!\n")
         (exit)))

(define tree-raw (syntax->datum (parse token-stream)))

;;(printf "\nResult:\n-------\n~a" tree-raw)

(define ast-translated (tree-transform tree-raw))
;; (printf "\nResult:\n-------\n~a" ast-translated)

(define output-string (unpack ast-translated)) ;; parse and return a datum



(printf "\nResult:\n-------\n~a" output-string)

(with-output-to-file (vector-ref (current-command-line-arguments) 1) #:exists 'replace
  (lambda ()
    (printf "~a" output-string)))

(printf "Done!\n")
(exit)



