#lang racket
#|  possible_grammar_lex.rkt

    Description:
        A lexer for some non-trivial grammar.
    To Use:
        Open in Dr. Racket and press "run".

    TODO:
        Come up with actual names for these files.
        Break up the lexer file.
        Debug the grammar.

Racket 6.6 | 10/2/16 | License MIT
|#
(require parser-tools/lex)
(require parser-tools/lex-sre)
(require brag/support)
(require "grammar.rkt")

(define-lex-abbrev int? (+ (char-range #\0 #\9)))

(define-lex-abbrev float? (: (+ (char-range #\0 #\9))
                             "."
                             (+ (char-range #\0 #\9))))

(define-lex-abbrev string? (: #\" (* (char-complement #\")) #\"))

(define-lex-abbrev identifier? (: (+ alphabetic)
                                  (* (or alphabetic #\_ #\! #\? (char-range #\0 #\9)))))

(define-lex-abbrev bool-comp? (or "==" "&&" "||" "<" ">" ">=" "<=" "!="))
(define-lex-abbrev type? (or "int" "string" "float"))

(define-lex-abbrev comment? (or (: "//" (* (char-complement #\newline)))
                                (: "#/" (complement (: any-string "/#" any-string)) "/#")))

(define end-of-file #f)

(define line 0)
(define column 0)
(define offset 0)


;Takes a file port and returns a single token-struct per call.
(define tokenize
  (lambda (file)
    (set!-values (line column offset) (port-next-location file))
    (define find-token
      (lexer
       [comment?    '(COMMENT lexeme #:skip? #t)]
       [int?        (list 'INT lexeme)]
       [float?      (list 'FLOAT lexeme)]
       [string?     (list 'STRING lexeme)]
       [type?       (list 'TYPE lexeme)]
       ["none"      (list 'NONE-TYPE lexeme)]
       ["mutable"   (list 'MUT-TAG lexeme)]
       ["array"     (list 'ARRAY-TYPE lexeme)]
       [#\*         (list 'MULT-OP lexeme)]
       [#\/         (list 'DIV-OP lexeme)]
       [#\-         (list 'SUB-OP lexeme)]
       [#\+         (list 'ADD-OP lexeme)]
       ;;;[#\!         (token 'NEGATE lexeme)] <- soon to be considered
       [#\{         (list 'LBRAC lexeme)]
       [#\}         (list 'RBRAC lexeme)]
       [#\(         (list 'LPAREN lexeme)]
       [#\)         (list 'RPAREN lexeme)]
       [#\[         (list 'LSQBRAC lexeme)]
       [#\]         (list 'RSQBRAC lexeme)]
       [#\,         (list 'COMMA lexeme)]
       [#\:         (list 'COLON lexeme)]
       [#\;         (list 'SEMI-COLON lexeme)]
       [bool-comp?  (list 'BOOL-COMP lexeme)]
       [#\=         (list 'EQUAL lexeme)]
       ["while"     (list 'WHILE lexeme)]
       ["if"        (list 'IF lexeme)]
       ["else"      (list 'ELSE lexeme)]
       ["->"        (list 'ARROW lexeme)]
       ["def"       (list 'DEF lexeme)]
       ["let"       (list 'LET lexeme)]
       [identifier? (list 'ID lexeme)]
       [(or #\newline #\space #\tab nothing) '(WHITESPACE lexeme #:skip? #t)]
       [(eof) (set! end-of-file #t)]))
    (define result (find-token file))
  (cond [(equal? result (void)) (void)]  ;;;EOF
        [(equal? (length result) 2) (token (first result) (second result) #:line line #:column column)]  ;;; TOKEN
        [else (token (first result) #:skip? #t)]))) ;;; WHITESPACE or COMMENT

(define token-stream '()) ; accumulator


;recursively lexs a file-port accumulating tokens in token-stream.
(define reader
    (lambda (file)
      (if end-of-file
                  '()
                  (and (set! token-stream (append token-stream(list (tokenize file))))
                       (reader file)))))

(define test (open-input-file "../test/template_syntax_test.txt")) ;;example file

(port-count-lines! test)  ;;enable line counting on port
(printf "File Found.\nTokenizing...\n")

(if (equal? (reader test) '())   ;If no mal-formed return was produced, print success
    (printf "File has been tokenized.\nParsing...\n")
    (printf "Error tokenizing file!\n"))

(syntax->datum (parse token-stream)) ;; parse and return a datum