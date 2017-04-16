# Making MinNo: Lexers, Parsers, and A Whole Mess of Parenthesis
By Logan Davis

## Abstract:
[MinNo](http://git.logan-h-g-davis.io/logan/minno) is a compiled language targeting the Arduino platform. 
This paper, as part of my [Plan of Concentration](https://www.marlboro.edu/academics/undergraduate/plan-of-concentration),
is an overview of the technologies and techniques used in making 
MinNo's compiler as well as a collection of opinions of the Racket
language and ecosystem (MinNo's implementation language).

### Contents:
<!-- TOC -->

- [Making MinNo: Lexers, Parsers, and A Whole Mess of Parenthesis](#making-minno-lexers-parsers-and-a-whole-mess-of-parenthesis)
    - [Abstract:](#abstract)
        - [Contents:](#contents)
    - [Introduction & Overview:](#introduction--overview)
    - [Racket: A LISP for Language Design](#racket-a-lisp-for-language-design)
    - [The Lexer Itself: The Matt Might Method](#the-lexer-itself-the-matt-might-method)
        - [Regular Expressions and Their Use](#regular-expressions-and-their-use)
        - [Token Construction and MetaData](#token-construction-and-metadata)
        - [The State of MinNo's Lexer:](#the-state-of-minnos-lexer)
    - [BRAG: How I Avoided Losing My Life to Making a Parser](#brag-how-i-avoided-losing-my-life-to-making-a-parser)
        - [Examples of Use and an explanation of BNF:](#examples-of-use-and-an-explanation-of-bnf)
        - [The State of MinNo's Grammar:](#the-state-of-minnos-grammar)
    - [The Translator: A Handler Model](#the-translator-a-handler-model)
        - [Avoiding BNF Hell](#avoiding-bnf-hell)
        - [Handlers:](#handlers)
        - [Unpacking the Handler](#unpacking-the-handler)
    - [Targeting AVR Processors:](#targeting-avr-processors)
        - [Making Sure Things Stayed Fast](#making-sure-things-stayed-fast)
        - [Letting People Under The Hood: Why Translator Result Readability Matters](#letting-people-under-the-hood-why-translator-result-readability-matters)
    - [Disadvantages of My Approach:](#disadvantages-of-my-approach)
        - [A Very Insular Crowd:](#a-very-insular-crowd)
        - [Handler are Both Great and Terrible:](#handler-are-both-great-and-terrible)
    - [What is Left to Be Done:](#what-is-left-to-be-done)
        - [Targeting Closer to the Chip](#targeting-closer-to-the-chip)
        - [Creating an Ecosystem & Library](#creating-an-ecosystem--library)
    - [Opinions On The Ecosystem: Racket, raco, and General House Keeping](#opinions-on-the-ecosystem-racket-raco-and-general-house-keeping)
            - [Package Management & Tooling](#package-management--tooling)
        - [Feelings about Where the Language is Going](#feelings-about-where-the-language-is-going)
    - [Bibliography:](#bibliography)
        - [Directly cited:](#directly-cited)
        - [Background resources:](#background-resources)

<!-- /TOC -->

## Introduction & Overview:
In my junior year at Marlboro College, I wanted to make a synthesizer
in one of my classes using Arduino development boards. The Arduino 
is a small, resource limited computer that allows written programs to directly control
voltages put out by pins. They are cheap, readily available, and run on a 5 volt power
supply. They seemed to fit the bill for making a custom signal generator for a larger synth.

Sadly, 16mhz, the frequency clock of the Arduino's processor, was slower than I could have 
anticipated. If I remember, the first version could only produce up to ~200 hertz (AKA 
lower than the 5th lowest string of a standard guitar on in other words
"no where near acceptable"). So I began hacking away at the Arduino platform trying to learn
every trick to get the signal generator to run faster. Look-up tables, magic hex values, and
hidden registers. Ever shortcut I could think of was hacked into this thing. By the end, 
I had a signal generator that could put out ~20,000 hertz, but the code was painful to maintain
by hand. One of the core problems, in my mind, was that most of the hacks I have to make 
were because the Arduinio's homebrew language was based off of C, an x_86/ARM centric language,
and the Arduino doesn't just use a different implementation architecture (x_86 vs ARM), it belongs to
a different architecture family (Harvard vs. Von Neumann). Most of the code I added was accessing 
some special register or some secret memory pool to x_86 programmers, but these were all
simple and readily available parts of the Arduino (more accurately AVR) CPU (central processing unit).
After the synth project, I realized that I didn't want to build on it for my Plan of Concentration.
I wanted to make a better language to avoid so much hoop-jumping in the future. This is how MinNo began.

MinNo is a language and compiler targeting Arduino-C that is meant to handle some of the 
more common idiosyncrasies of AVR programming. For more on how MinNo attempts this, please see
*Why MinNo*.

After toying with a few different language ideas, I had to actually get down to programming the compiler. 
This starts with making a *lexer*. A lexer classifies words and symbols in a source file and returns *tokens* for them. (it's the part of the compiler that says the symbol *1* is a number unless it's wrapped in string quotes). This classifying of words is in preparation for the *parser* which recognizes series of tokens based on a language grammar.
At this step to compiler recognizes *for(int i = 0; i < 10 ; i++)...* as a loop but not that it will stop at *i == 9*.
What the parser produces is an Abstract Syntax Tree (AST), which is a structured representation of some source code
file as manipulatable data. From an AST, I needed some *translator* to turn my languages AST into one that better
matches an Arduino-C equivalent AST. These are alterations such as cataloging and what can and cannot be put into 
the different memory modules on an Arduino board. To actually output it as text file while making a few formatting
alterations, the translated AST is given to an *unpacker*. This paper will go over the creation of each of these
parts, the tools that helped to create them, and a thoughts that I know have after getting this far with the
project.

## Racket: A LISP for Language Design
For the lexer, parser, translator, and various tools of MinNo, 
I chose to use Racket. Formerly known as PLT scheme, Racket is
one of the many opinionated  and highly idiosyncratic members of the 
LISP family of languages.[1] Where CLISP emphasizes out-of-the-box productivity, Clojure 
focuses on functional constructions, and Scheme strives towards 
simplicity, Racket has built itself around specificity.[2][3]

Originally, Racket was an education
centric platform. It's homegrown IDE, ***DR.Racket*** allows for you
to turn parts of the language on and off to slowly introduce new coders
to extended functionality in small steps. Ultimately,
prior to my time using the language, they still wanted to keep it as an educational platform but
they wanted also wanted to extend to a wider community. Racket made a concerted effort 
to shift it's strengths.

Now Racket markets itself as a "language platform." The entire ecosystem
is built around the idea of embedding Domain Specific Languages (DSLs)
into programs to simplify and better manage sub tasks of larger
programs. To achieve this focus, the developers of the language have
included lexers, parsers, and an extensive macro system.

With Racket's ability to handling syntax parsing and my previous
experience with it in general programming, it came as a natural choice to use when implementing
the MinNo compiler.


## The Lexer Itself: The Matt Might Method
In creating this compiler, by far the most helpful resource was
Matt Might's blog posts about his course on the subject.[4] The lessons
are brief, but give an excellent overview of what one needs to do 
to make a compiler. I most heavily leaned on his course syllabus and
class notes for MinNo's lexer.

A lexer is the section of a language compiler (or interpreter) that
takes a source file and breaks it down into the languages smallest pieces
(tokens). For example: if we were making a compiler for a basic calculator,
the lexer would need to recognize "=", "+", "*", "-", "/", and any integer
or float. The lexer would need to return these tokens in some form that
allows the parser (a later step) to easily recognize them and construct
larger grammar objects in the language.

### Regular Expressions and Their Use
The most typical way to construct a lexer for non-trivial syntax structures 
is to strap together a collection of [regular expressions](https://en.wikipedia.org/wiki/Regular_expression) into some class
or function that consumes a source file and returns a collection of tokens.

Racket, being a language platform, has an included [lexer & regex library](https://docs.racket-lang.org/parser-tools/Lexers.html).
Matt Might thinks highly of it and uses it in his own compiler course.[5]
An example of how to construct a lexer in Racket, using our basic calculator 
language, may look something like the following:

    (define calc-lex
      (lexer
        [#\+   '('ADD-OP lexeme)]
        [#\-   '('SUB-OP lexeme)]
        [#\*   '('MULT-OP lexeme)]
        [#\/   '('DIV-OP lexeme)]
        [(+ (char-range #\0 #\9)) ('INT lexeme)]
        [(: (+ (char-range #\0 #\9)) 
            "." 
            (+ (char-range #\0 #\9))) (‘FLOAT lexeme)]))

Racket prefaces any character with a "#\" to mean a *character literal*, so "#\+"
matches "+" in a source file.  **lexeme** is a reserved word by the Racket lexer to 
reference the currently matched token. The last two entries in the lexer construct
are examples of *s-expression regexes*. **+** recognizes 1 or more of the following 
regex. **char-range** is to match a range of character either in letters or in numbers 
(#\a to #\z or #\0 to #\9 for example). **:** concatenates all following expressions 
into one single pattern. Longer regular expressions are typically defined as lexer 
abbreviations to look a little more clean. With those abbreviations defined the lexer 
would look like this:

    (define-lex-abbrev int? (+ (char-range #\0 #\9)))
    (define-lex-abbrev float? (: (+ (char-range #\0 #\9))
                                 "."
                                 (+ (char-range #\0 #\9))))
    (define calc-lex
      (lexer
        [#\+   '('ADD-OP lexeme)]
        [#\-   '('SUB-OP lexeme)]
        [#\*   '('MULT-OP lexeme)]
        [#\/   '('DIV-OP lexeme)]
        [int? ('INT lexeme)]
        [float? (‘FLOAT lexeme)]))

Given a source file containing "5 + 7.0 / 3" would produce a token stream of:

    '('INT "5") '('ADD-OP "+") '('FLOAT "7.0") '('DIV-OP "/") '('INT "3")

The resulting lexer would be used to listen to an input-port and produce a token stream
for the parser to consume as needed. 

### Token Construction and MetaData
The lexer can do more than just recognize tokens. It can help provide invaluable 
debugging information about the source file it is lexing. For parsing libraries like 
the one I used (which I will get to next), it expects the lexer to append the location 
of tokens in the source file being compiled to use when reporting a parsing error.
The lexer can also be a place to catch stylistic warnings (such as rustc's warning about anything other than
*snake_case*).[6]

### The State of MinNo's Lexer:
[MinNo's lexer](http://git.logan-h-g-davis.io/logan/minno/blob/master/src/lexer.rkt) works on an architecture similar to that used by Matt Might
to take advantage of [Racket's input ports](https://docs.racket-lang.org/reference/stringport.html).[7]
The lexer consumes a file-port's output and gathers it in a buffer. This is recursively done
until the source file-port is empty. The resulting collection of tokens are passed
to MinNo's parser.

The lexer works as intended, though some more utility could easily find it's way into 
that section of the compiler. constructing global tables of meta data about tokens (to help warnings
in the translation step), or stylistic warnings (like I previously mentioned) will all
be looked at when revising the lexer.

## BRAG: How I Avoided Losing My Life to Making a Parser
Parsing is a topic of exploration large enough to the spend an entire dissertation on.[8]
For MinNo, instead of spending the time making one from scratch, or 
learning the [incredibly idiom-centric syntax recognizer in Racket](https://docs.racket-lang.org/reference/stx-patterns.html)
I opted to use a popular Racket tool for grammar specification 
and parsing: *[brag](http://docs.racket-lang.org/brag/)*.

*brag* is a *[Backus Naur form](https://en.wikipedia.org/wiki/Backus%E2%80%93Naur_form)* (BNF)
grammar parser implemented as a *Domain Specific Language* within Racket. Before I get into using 
*brag*, some time should be taken to overview BNF.

### Examples of Use and an explanation of BNF:
BNF grammars work using *symbols* and *expressions*. They are organized as such:

   SYMBOL ::= EXPRESSION 

an expression can be any collection of other symbols or terminals (tokens). If a symbol 
is in an expression, it is considered a non-terminal expression and must be parsed further.
It is worth noting that, in use, some artistic merit is used with BNF notation. For instance,
*brag* does not use "::=" for it's equal-sign, it just uses ":" so rules look like:

    SYMBOL: EXPRESSION

Which can be confusing when first looking at it. *brag* allows for a common shim in BNF 
structures that allows expressions to be regular expression-like statements to 
allow concise grammar rules. So, to continue with the calc grammar,
a *brag* rule to recognize numbers may look like:

    num: (INT | FLOAT)

This rule states a "num" is a integer or a float (as tokenized by our lexer).

When a grammar file is given to the *brag* compiler, it produces a *parse*
function. This function will consume a list of tokens and then, using the generated LALR
parser, it will construct an abstract syntax tree (AST) abiding by the defined
grammar. For instance, here is a snippet of grammar from the MinNo grammar spec for 
type signatures of variables and functions:

     ; Typing statements
     type: TYPE | ARRAY-TYPE lSqBrac TYPE rSqBrac ;;; "int" | "array[int]"
     signature: (((id colon type comma)* id colon type) | nonetype) arrow (type | nonetype)

(Keep in mind that anything is all upper case (like **TYPE**) is caught directly from the lexer while 
things in lower case are other rules in the grammar. )

The rule **type** is applied id a 'TYPE token is passed from the lexer or if an **`ARRAY-TYPE** token is followed
by a "[" some other 'TYPE and than a "]". This means things like **int**, **float**, and **array[char]** are
caught by this rule. The choice between these two different forms is denoted by the "|" in the rule, which just 
means "either the thing to my left or the thing to my right."

The **signature** rules building off of the previous. It is saying that there can be any amount of **id**s followed 
by a **colon**, a **type**, and then a **comma** (including zero of them), but there must be a single id, followed 
by a colon and then a type to end the signature. Alternatively all of this can be replaced by a **nonetype**, but one of the two must by there. After this section of the signature (the arguments sections), an **arrow** ("->") has to 
be next. This arrow can be followed by another **type** or **nonetype**.
     


The grammar produces a syntax-object which is handled by the translator.

### The State of MinNo's Grammar:
A few different versions of [MinNo's grammar](http://git.logan-h-g-davis.io/logan/minno/blob/master/src/grammar.rkt) were toyed around with. Originally, 
MinNo was going to be of a LISP grammar, but between the limitations a LISP interpreter
would have and the shoe-horned-ness of compiling it, I decided against 
the project.[9] Later iterations took notes from F#,
Scala, Java, Python, and, Pyret. The result of those revisions is what you see currently.
The largest of the influences are from Scala and F#'s type notations:

*F#:*

    let some_int = 5 //variable declaration
    let foo x y = x * y //function definition
    foo some_int 5 //function invocation

*Scala:*

    val some_int : Int = 5 //variable declaration
    def foo(x: Int, y: Int):Int = { // function definition 
        x * y 
    }
    foo(some_int, 6) //function invocation

*MinNo:*

    let some_int: int = 5; //variable declaration
    def foo x:int, y:int -> int { //function definition 
        return x * y;
    }
    foo some_int 6; //function invocation

By no means does it reach in any of those
directions as far as the language MinNo takes from (the type system is not even a fraction
as complicated as Scala's). MinNo just takes some loose form from languages I have used 
and enjoyed in the past.

## The Translator: A Handler Model
To further ease language creation using Racket, the language has a *syntax-object* data type.
This is very similar to a quoted expression, but can hold some extra info like lexical bindings and 
source file location. Here is an example of how to create a quotes expression and a syntax-object:

     ; A quoted expression, note that "`" is shorthand for "quote"
     > `( + 1 2)
     '(+ 1 2) 

     ; A syntax-object is also the same notation, but a "#" prepends the "`"
     > #`(+ 1 2)
     #<syntax:3:4 (+ 1 2)>

The two are very similar and their difference might not be immediately obvious, but in DrRacket,
the syntax-object, under inspection, has this meta data attached to it:

     General Info
     Source
     '|interactions from an unsaved editor|
     
     Source module
     #f
     
     Position
     100
     
     Line
     3
     
     Column
     4
     
     Span
     7
     
     Original?
     #t
     
     Known properties
     'errortrace:annotate
     #t

Some of this data is a little funky because it is directly extracted from the Racket interpreter panel. But some things do make sense. The first line you type on is the third line of the interpreter because of the welcome message
Racket prints out:

     Welcome to DrRacket, version 6.8 [3m].
     Language: racket, with debugging; memory limit: 256 MB.

And the syntax-object starts on the 4th column preceded by "> " of the prompt and the "#`" the denote typing a
syntax-object. This meta data what stands out about syntax-object when compared to quotes and quasiquotes in Racket.

Like syntax rules, Racket's syntax-objects are highly specific to 
the crowd that is doing cutting edge language research using the platform. 
They have largely been constructed to make use of Racket's *reader* system to
make interpreted language. I had to make a choice of whether to figure out how to 
half-use this data type or do something a little more straight forward for my use case.
To maintain my sanity, I decided to roll my own template-based method instead. Given
MinNo's rather strict syntax, predicting the grammar that can be used at any 
point is a programs AST is fairly straight forward. 

The only thing that I lose from the not using syntax-objects is the source file location
that would allow me to embed translation errors in the translation step. But given that 
I still have source location in from the lexer, I consider this a non-issue.

### Avoiding BNF Hell
A word of warning, this is that area where you start to understand terrible 
mistakes you made in constructing your grammar or defining your lexer. Those 
steps can be made to consume and parse some pretty kludgy grammar structures. If they consume
kludge they will also produce it. A complicated AST makes for a complicated project. 
It is worth the hours of revising your BNF grammar and lexer to save days of 
debugging further down the road.

### Handlers:
The way I have decided to tackle MinNo's AST is to define a collection of handlers 
for different syntax structures. There are handlers for let statements, block statements,
function definitions, conditionals, returns, and so on. Each handler knows how to pass off
any sub-syntax structure it contains (such as the statements in a block statement) by using 
a handler directory. The directory used to dispatch sections of the program to their respective
handlers until the program is fully translated. When is left is a new AST closer to that of an 
Arduino Language program.

As an example of a handler in action, lets step through the translation of a variable declaration.
Here is the relevant handler code to understand what is going to happen. Here is an example AST of 
a variable declaration:

      (let-statement
        (let "let")
        (id "ledpin")
        (colon ":")
        (type "int")
        (eq "=")
        (statement (expr (term (factor (lit (int "-13"))))))
        (delimit ";"))

So this ast is a *let statement* for an immutable variable referred to by the ID *ledpin* which is an 
integer of "-13". The first piece of code this AST will be handed to is the 
handler directory function *tree-transform* which sends off each expression to the correct 
handler to be translated:

*tree-transform* from *handerDirector.rkt*:

     (define tree-transform
       (lambda (datum)
         (define tag (first datum))
         (cond
           ;;;----------------TOP LEVEL PROGRAM-----------------------;;;
           [(equal? tag 'program) (program-tag-handler datum)]
           ;;;----------------LET STATEMENT---------------------------;;;
           [(equal? tag 'let-statement) (let-tag-handler datum)]
           [(equal? tag 'relet-statement) datum]
           ;;;----------------DEFINE STATEMENT------------------------;;;
           [(equal? tag 'define-statement)
            (append (definition-tag-handler datum) (scope-statement-handler (fifth datum)))]
           ;;;----------------STATEMENT HANDLER-----------------------;;;
           [(equal? tag 'statment) (statement-handler datum)]
           [(equal? tag 'delimited-statement) (delimited-statement-handler datum)]
           [(equal? tag 'scope-statement) (scope-statement-handler datum)]
           ;;;----------------CONDITIONAL-HANDLER---------------------;;;
           [(equal? tag 'conditional) (conditional-handler datum)]
           ;;;----------------RETURN-HANDLER--------------------------;;;
           [(equal? tag 'return-statement) datum]
           ;;;----------------LOOP-HANDLER----------------------------;;;
           [(equal? tag 'while-loop) datum]
           [(equal? tag 'for-loop) (for-loop-handler datum)])))

So given than that first element of the example AST is **`let-statement**, the AST is passed of to **let-tag-hander** 
given the second conditional branch of the **cond** structure from **tree-transform**. So as an overview, before diving
into the code, this is what needs to happen to the example AST to be ready for the unpacker: the variable need to be cataloged 
to distinguish it from a function ID when unpacking; if a mutable tag is not present, than "const PROGMEM" needs to be appended in the type-string; and if a variable is an array, the notation need to be translated (from something like "array[int]" to
"int[]"). Here is the code:
         
*lettypeHandler.rkt*:

     #lang racket
     (require "state-roster.rkt")
     
    ; Handles a 'let-statement branch of an AST
     (define let-tag-handler
       ;;; add section for mutable lets
       (lambda (datum)
         (let ([mutable? (mutable-tag? datum)]
               [ast-result '()])
              (add-variables-defined (second (third datum))) ;;catalog it as variable
              (define is-array #f)
              (if mutable?                          ;; if immutable, catalog it
                  (and (set! is-array (equal? (second (sixth datum)) "array"))
                       (set! ast-result (list  'declaration
                                               (list 'type (letType-handler-get-type (sixth datum))) ;;type
                                               (correct-id-if-array (third datum) is-array)  ;; id
                                               (seventh datum)  ;; equal symbol
                                               (eighth datum);;value
                                               (ninth datum))))
                  (and (set! is-array (equal? (second (fifth datum)) "array"))
                       (set! ast-result (list  'declaration
                                               (list 'type (string-append
                                                            "const PROGMEM "
                                                            (letType-handler-get-type (fifth datum)))) ;;type
                                                (correct-id-if-array (third datum) is-array)  ;; id
                                                (sixth datum) ;; equal symbol
                                                (seventh datum) ;;value
                                                (eighth datum))) ;; delimiter
                       (if in-scope-statement '() (add-prog-mem-variable (third datum)))))
           ast-result)))
                  
     ; Appends "[]" to the id tag for C's notation            
     (define correct-id-if-array
       (lambda (id-string is-array) 
         (if is-array
             (list 'id (string-append (second id-string) "[]"))
             id-string)))
     
     
     ; Translates types from original-AST to target AST.
     (define letType-handler-get-type
       ;;; TODO: add multi-dimensional array type handling.
       (lambda (datum)
         (cond [(equal? (second datum) "array") (fourth datum)]
               [else (second datum)])))
     
     
     ; Verifies that a mutable tag is present in a let-statement
     (define mutable-tag?
       (lambda (let-statement)
         (define result (filter (lambda (x) (equal? (first x) 'mutable-tag))
                                (rest let-statement)))
         (if (equal? (length result) 1) #t #f)))

So the code looks a little verbose, but it is rather straight forward once broken down:

 - *mutable-tag?* is just a predicate to see if some let-statement is marked as mutable in the 
course code. 

 - *letType-handeler-get-type* simply extracts the type from an AST for easier processing.

 - *correct-id-if-array* covers the correction of array brackets in type declarations ("array[int]" -> "int[]").

 The only complicated function is *let-tag-handler* which glues all this stuff together. First, it catalogs the 
 variable for the unpacker to correctly handle it later in a list from **state-roster.rkt**. Then, if the mutable tag
 is present, one of two different formatting procedures is used. This has to happen because the present of the mutable
 tag shifts the index of each element for the AST, restricting options in making a general purpose formatter.
 While formatting, each element of the array is either directly returns or passes through some minor correction
 (such as **correct-id-if-array**). After all of this, the translated AST is passed to the **unpacker**.


### Unpacking the Handler

What the handler leaves us with is a list of lists that represent the program's AST; this is far 
from executable. This is where the ***Unpacker*** comes in. The Unpacker spelunks through the 
AST and does one of three things:
* Returns contained inner string,
* Hands off special cases to a correcter function,
* or calls the Unpacker on sub lists for further unpacking.

The case of something that can just be returns is an atomic object of the AST such as:

     '(lit "1")
     
There is no more information within this item and nothing needs to be formatted
differently. However, in the case of certain AST objects require special unpacking
to deal with some of the specific formatting of the Arduino language. Function calls, 
for instance, require special handling of arguments to make sure they are properly wrapped in
parenthesis and separated by commas. Another would be variables declared in **PROGMEM**; the Unpacker
will wrap each reference of them (as a pointer) in a Arduino built-in function to read from program
memory. The compiler knows how to do these corrections using a directory similar to that of
the handler's directory function.

After the unpacking phase, the resulting Arduino sketch will be returned as a full string
that is written out to a file for uploading.

## Targeting AVR Processors:
### Making Sure Things Stayed Fast
One of the goals of MinNo was to more easily handle the boiler plate code I use
when writing Arduino scripts. Given the Arduino's slow speed and limited
resources, I needed to make sure that the generated code was not so slow
as to entirely undermine this reason for using MinNo. Therefore I made the conscious
decision to make MinNo more of a subtle semantic departure from C rather than
something entirely different. It allowed me to emphasize certain points about 
Arduino programming that I find useful (like making immutability the default
to make easy use of the architecture difference). Making it a shift in default 
behavior, rather than an entire paradigm shift allows MinNo to be closely and 
concisely mapped to a C program with only minor runtime overhead. 

### Letting People Under The Hood: Why Translator Result Readability Matters
One day I want MinNo to be a mature enough platform to write the
majority of my Arduino sketches in. But the likelihood of
achieving that level of maturity while also wanting the graduate
within 4 months of writing this seems minuscule (to put it lightly).

To make up for this, the MinNo compiler focuses on making (subjectively)
readable C code. Often compilers will leverage language constructs
(such as lambdas) to make code generation easier however this 
can generate code that is hard to read. MinNo's template
approach lets the generated code be written so it can follow
consistent styling and formatting for readability.

The code being readable allows the current restrictions of MinNo to be
bypassed by editing the resulting C script. If you really want some
kind of manual memory allocation, MinNo generated C will be totally
accepting of that even if MinNo itself isn't.

## Disadvantages of My Approach:
### A Very Insular Crowd:
Though I can say much to praise Racket, there are definitely some detractors.
For instance, in trying to get into their syntax object I was assaulted with 
numerous conversation-specific words, phrases, and frameworks. Though the 
documentation gave a great deal of links on where to read further, it was just
layers upon layers of conversations that I had no sane introduction to. 

Most of these topics were manageable, but not without staring at docs and opening a 
an interactive Racket interpreter again and again. Racket is a small community with hyper-specific language
to talk about what they do. Consequently there aren't very many resources available
from people other than the ones responsible for the documentation itself. 


Other languages have lexer and parser tools like BRAG. Java has ANTLR to construct compilers,
and C/C++ has Lex/Flex to construct lexers and Yacc/Bison to compiler parsers. Both of these 
could have done what Racket's **lex** and BRAG accomplish in a similar manner. The lexer specification
would be some series of regular expressions that produce tokens that would be consumed by a parser
that follows form BNF-like grammar structure. The major benefit that I see in these over Racket is that
they are far more used and subsequently have a much larger collection of tutorials and educational material
surrounding them. 

### Handler are Both Great and Terrible:

Handlers are a wildly simple and easy framework to use in AST processing. It allows
for very iterative design. Unfortunately, due to the way Racket does
lexical parsing, it is very hard to make handlers that are separated at the file level. 
There are plenty of pieces in MinNo's handler system that can totally be separated out 
into another file for better organization, but this is not true for all of it. If a 
particular handler needs to call the directory function on some sub-section of the AST is handling, 
it needs to be in the same file as the directory. If you tried to separate it, there would 
need to be a cyclical dependency of the two files. Racket does not (and absolutely should not)
allow cyclical imports and therefore makes it impossible to separate trampolining functions
such as certain handlers and the handler directory.

## What is Left to Be Done:
### Targeting Closer to the Chip
Currently MinNo targets the Arduino programming language. A next step
would be to target GCC (or LLVM) compatible C and AVR assembly directly.

This would be more verbose code for sure, but the speed increases and
system controllability would be greatly increased. A major benefit
would also be the ability to expand support for more embedded
platforms. Targeting Arduino restricts me to boards within Arduino or
it's community's interest to support. Boards like the Beagle Bone and
the Raspberry Pi are outside of this list. Targeting GCC or LLVM (when
the support for AVR is mainlined) will allow faster resulting code and
wider target platform support. 

### Creating an Ecosystem & Library

MinNo can do plenty of common tasks on the Arduino, but it's current
library of keywords and functions is sparse. In the interest of creating 
a useful language, a standard library needs to
be properly fleshed out. String operations, mass pin manipulation,
bit-shifting abilities, data-serializing functions, and more. All
of this needs to be included to make MinNo a robust platform for
embedded development.

It also needs to take advantage of the thousands of programming hours
that have already been poured into the platform. Interoperability with
C code directly in MinNo files is on the short list of features to tackle
next. There are far too many libraries for Arduino add-ons, such as shields,
to reimplement from scratch.

In managing the library, C code, and all of the chips to be targeted,
better tooling needs to be developed. The rise of languages like Rust
and Scala can be attributed solely to their innovation as languages,
but that would be missing a key point that other languages (like D and
Julia) neglected: tooling. SBT (Scala's build tool) and Cargo (Rust's version 
of SBT) helped root programmers in a central conversations of the respective
languages. They allowed for immediately productive and understandable
project structures (or at least allowed the authors of the language to direct 
where the communities style went). These common architectures allowed code to easily
connect and communicate. MinNo needs to make a similar move into
creating an entry point to allow coders to share what they make.

## Opinions On The Ecosystem: Racket, raco, and General House Keeping
#### Package Management & Tooling
With Racket's niche being a platform to build more languages, they
needed to have some way to share the tools that programmers produce
so no one has to spend time reinventing the wheel.
Therefore, Dr.Racket has a very intuitive graphical package
manager built on top of their command line tool **raco**.

[pkgs.racket-lang.org](http://pkgs.racket-lang.org) lists, (*start sarcasm*) with all the aesthetic mindfulness of
Dr.Racket (*end sarcasm*), the packages available though **raco**. It contains
tags, links to package documentation, and checksums (if you are
into that).

There is a common moment of anxiety in development when a language or 
library releases an upgrade while you are using the now-out-of-date version.
Some projects are stuck in a version lock (or rewrite) due to their reliance on libraries built in a
previous version. While writing the MinNo Compiler, Racket came out with not 1, but 2 language releases.[10][11]

These were minor version changes (6.7 & 6.8), so I thought about not
upgrading, but after reading their change-logs, I knew I had
to. 6.7 greatly increased performance of strings in the language.[12] 6.8
improves optimization of equality statements.[13] Those two areas make up the vast
majority of operations and data handled by a compiler; it would be a
crime to not utilize these upgrades.

Of course I had that moment of panic when I downloaded the newest
version of Racket. The raw terror of some feature of the Lex library
not working and requiring me to 1. revert to the previous version
or 2. rewrite some not trivial part of the program. After installation
was finish, migrating my dependencies was next on the list.

In the graphical version of the Racket Package Manager, there is a
very handy migration tool from previous language installations. It just checks
your previous installation of racket for downloaded libraries and will
automatically grab them from raco for the new installation. Once
BRAG was migrated and updated, I decided to test how much a had
broken my code base.

    module: identifier already imported from a different source
    whitespace
    parser-tools/lex
    brag/support

It seemed that one of the two libraries decided to now include the
term "whitespace" which was already part of the other library,
creating a naming conflict. After some very brief searching, some
*import prefixing* did the trick.[14] 
After that, the upgrade was successful & the compiler
felt much snappier then before (though I have no way of saying this
objectively, since I never ran a numeric test).

One very surprising thing was that when I upgraded Racket, all of my
preferences and settings carried over despite doing a "fresh"
install. Binds, color schemes, and everything else. As someone who is
color blind, not being bogged down for hours figuring out a color
scheme that actually helps me was a really nice surprise.

Though I don't have a great deal of praise of Dr.Racket (I don't have
deep criticism either, just a mild understanding that it is around and
has a particular use), I have grown very accustomed to using it for
Racket development.

All in all, it is not as comprehensive of a tooling
infrastructure as **Cargo** or dynamically connected as something like
**npm/bower** but there is something to be said for it's
simplicity.

### Feelings about Where the Language is Going

Racket is unfortunately held back by it's view as a tool for education 
and the lack of functional utility that it's only development environment, Dr.Racket,
exudes. When talking to a fellow college student during an internship, I
mentioned that I used Racket. He looked at me with some confusion. "Racket,
we used that in high school for the intro programming course. It was terrible."
Racket was initially created as an education tool. There is a huge amount
of resources poured into it to do as much.  With the state of the default
development environment, you are constantly affronted with what looks like 
software meant to educate you, not to do serious development. Being more 
open and accommodating with other setups for coding in Racket is absolutely 
required to attract & keep new developers. 

It is a surprise that Racket hasn't broken out of their educational roots 
in regards to Dr.Racket like the rest of the language has. Though education
is still a huge part of Racket, the language platform discussion has really
taken off. By far one of the most interesting footholds I have witnessed Racket take is in 
game scripting as the main language for one of the most celebrated Sony developers.[15]
Something about their process just seems to root around using LISP (considering they went
through the trouble of maintaining their own sub language for a number of 
years).[16] For the last new (award winning) titles they have released, Racket
has been their choice in scripting languages.

The movements into fields are far apart as language development and 
gaming scripting have done a great deal to lift Racket out of it's 
PLT reputation. If it could shed away from the last major reminder of
those days, it's deep attachment to Dr.Racket, I think it could really 
be up there with Clojure as the new face of LISP.


## Bibliography:
### Directly cited:
* \[1]: "Racket: From PLT Scheme to Racket." *racket-lang.org*. Published: June, 2010. https://racket-lang.org/new-name.html.

* \[2]: Graham, Paul. "LISP FAQ." *paulgraham.com*. Accessed: February, 2017. http://www.paulgraham.com/lispfaq1.html.

* \[3]: "Rationale." *clojure.org*. Accessed: March, 2017. https://clojure.org/about/rationale.

* \[4]: Might, Matthew. "Compilers :: CS 5470." *matt.might.net*. Accessed: September, 2016. http://matt.might.net/teaching/compilers/spring-2015/. 

* \[5]: Might, Matthew. "Lexical analysis in Racket." *matt.might.net*. Accessed: September, 2016. http://matt.might.net/articles/lexers-in-racket/.

* \[6]: logicchains. "warning: function fooBar should have a snake case name such as foo_bar. #[warn(non_snake_case_functions)] on by default." *reddit.com/r/rust*. Accessed February, 2017. https://www.reddit.com/r/rust/comments/29sumo/warning_function_foobarshould_have_a_snake_case/.

* \[7]: Might, Matt. "derp2." *github.com/mattmight*. Published: Mar 7, 2015. https://github.com/mattmight/derp2.

* \[8]: Hall, David Leo Wright. "Refinements in Syntactic Parsing." *digitalassets.lib.berkeley.edu*. Accessed: February, 2017 http://digitalassets.lib.berkeley.edu/etd/ucb/text/Hall_berkeley_0028E_15470.pdf.

* \[9]: Johnson-Davies, David. "Tiny Lisp Computer." *technoblogy.com*. Published: 8th September, 2016. http://www.technoblogy.com/show?1GX1.

* \[10]: "Racket v6.7." *racket-lang.org*. Published: October 26, 2016. http://blog.racket-lang.org/2016/10/racket-v67.html.

* \[11]: "Racket v6.8." *racket-lang.org*. Published: January 24, 2017. http://blog.racket-lang.org/2017/01/racket-v6-8.html.

* \[12]: "Racket v6.7." *racket-lang.org*. Published: October 26, 2016. http://blog.racket-lang.org/2016/10/racket-v67.html.

* \[13]: "Racket v6.8." *racket-lang.org*. Published: January 24, 2017. http://blog.racket-lang.org/2017/01/racket-v6-8.html.

* \[14]: Hendershott, Greg."Overlapping module imports in Racket." *stackoverflow.com*. Published: July 27, 2013. http://stackoverflow.com/questions/17894875/overlapping-module-imports-in-racket.

* \[15]: Racket Lang. "RacketCon 2013: Dan Liebgold - Racket on the Playstation 3? It's Not What you Think!" Filmed September 29, 2013. YouTube Video, Duration: 59:23. Posted: October 13, 2013. https://www.youtube.com/watch?v=oSmqbnhHp1c.

* \[16]:  Gavin, Andy. "Making Crash Bandicoot – GOOL – part 9." *all-things-andy-gavin.com* Published: March 12, 2011. http://all-things-andy-gavin.com/2011/03/12/making-crash-bandicoot-gool-part-9/.


### Background resources:
These were sources that helped inform me in how to build and program a compiler but had no 
direct quote or idea echoed in this paper.

* Politz, Joe. "Principles of Compiler Design." *cs.swarthmore.edu*. Published: April 29, 2016. https://www.cs.swarthmore.edu/~jpolitz/cs75/s16/s_schedule.html.

* Norvig, Peter. "(How to Write a (Lisp) Interpreter (in Python))." *norvig.com*. Published: August, 2016. http://norvig.com/lispy.html.

* Schrittwieser, Julian."Scalisp - a Lisp interpreter in Scala." *furidamu.org*. Published: March 23, 2012. http://www.furidamu.org/blog/2012/03/23/scalisp-a-lisp-interpreter-in-scala/

* Sarkar, Dipanwita, and  Oscar W., and  R. Kent D.. "A Nanopass Framework for Compiler Education∗." *cs.indiana.edu*. Accessed: August, 2016. http://www.cs.indiana.edu/~dyb/pubs/nano-jfp.pdf.

* NewCircle Training. "The Value of Values with Rich Hickey." Filmed: July, 2012. YouTube Video, Duration: 31:42. Posted: October 8, 2012. https://www.youtube.com/watch?v=-6BsiVyC1kM.

* GDC. "Programming Context-Aware Dialogue in The Last of Us." Filmed: March, 2014. YouTube Video, Duration: 1:00:54. Posted: February 18, 2016. https://www.youtube.com/watch?v=Y7-OoXqNYgY.
