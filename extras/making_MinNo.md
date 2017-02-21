# Making MinNo: Lexers, Parsers, and A Whole Mess of Parenthesis
#### By Logan davis

##### Abstract:
[MinNo](http://git.logan-h-g-davis.io/logan/minno) is an Arduino-targeting compiled language. This paper, as
part of my [Plan of Concentration](https://www.marlboro.edu/academics/undergraduate/plan-of-concentration),
is an overview of the technologies and techniques used in making 
MinNo's compiler as well as a collection of opinions of the Racket
language and ecosystem (MinNo's implementation language).

## Racket: A LISP for Language Design
For the lexer, parser, translator, and various tools of MinNo, 
I chose to use Racket. Formerly known as PLT scheme, Racket is
one of the many opinionated  and highly idiosyncratic members of the 
LISP family of languages. Where CLISP emphasizes maturity, Clojure 
focuses on functional constructions, and Scheme strives towards 
simplicity, Racket has built itself around specificity.

Originally, Racket (know at the time as PLT Scheme) was an education
centric platform. It's homegrown IDE, ***DR.Racket*** allows for you
to turn parts of the language on and off to slowly introduce new coders
to new functionality. It even allows for you to import images into
programs by simply dragging them into you editor (it will embed the 
image wholesale into the source code, rendering it inline). Ultimately,
prior to my time using the language, the PLT Scheme group changed 
gears. Though they still wanted to make an educational language,
they wanted it to also be useful to the wider community. This is 
when they rebranded the language as ***Racket***.

Now Racket markets itself as a "language platform." The entire ecosystem
is built around the idea of embedding Domain Specific Languages (DSLs)
into programs to simplify and better manage sub tasks of larger
programs. To achieve this focus, the developers of the language have
included builtin lexers, parsers, and data structures for manipulating
what they produce.

With Racket's ability to handling syntax parsing and my previous
experience with it, it came as a natural choice. 


## The Lexer Itself: The Matt Might Method
In creating this compiler, by far the most helpful resource was
[Matt Might's blog posts on his compiler course](http://matt.might.net/teaching/compilers/spring-2015/). The lessons
are brief, but give an excellent overview of what one needs to do 
to make a compiler. I most heavily leaned on his course syllabus and
class notes for MinNo's lexer.

A lexer is the section of a language compiler (or interpreter) that
takes a source file and breaks it down into the languages smallest pieces
(tokens). For example: if we were making a compiler for a basic calculator,
the lexer would need to recognize "=", "+", "*", "-", "/", and any integer
or float. The lexer would need to return these tokens into some form that
allows the parser (a later step) to easily recognize each atomic part of the
source code.

#### Regular Expressions
The most typical way to construct a lexer for non-trivial syntax structures 
is to strap together a collection of [regular expressions](https://en.wikipedia.org/wiki/Regular_expression) into some class
or function that consumes a source file and returns a collection of tokens.

Racket, being a language platform, has a builtin [lexer & regex library](https://docs.racket-lang.org/parser-tools/Lexers.html).
Matt Might thinks highly of it and [uses it in his own compiler course](http://matt.might.net/articles/lexers-in-racket/).
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
(#\a to #\z or #\0 to #\9, but not both). **:** concatenates all following expressions 
into one single pattern. Though the regular expressions are typically defined as lexer 
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

The resulting lexer would be used to listen to a port and produce a token stream
for the parser to consume as needed. 

#### Token Construction and MetaData
The lexer can do more than just recognize tokens. It can help provide invaluable 
debugging information about the source file it is lexing. This is a step where one
append the location (row and column) of tokens in a source file (in case there is 
as error in parsing). Stylistic warnings can be thrown (such as [rustc's enforcing
of *snake_case*](https://www.reddit.com/r/rust/comments/29sumo/warning_function_foobarshould_have_a_snake_case/)).
 
#### The State of MinNo's Lexer:
[MinNo's lexer](http://git.logan-h-g-davis.io/logan/minno/blob/master/src/lexer.rkt) works on an 
architecture similar to [that used by Matt Might](https://github.com/mattmight/derp2)
to take advantage of [Racket's input ports](https://docs.racket-lang.org/reference/stringport.html). 
The lexer consumes a file-port's output and gathers it in a buffer. This is recursively done
until the source file-port is empty. The resulting collection of tokens are passed
to MinNo's parser.

## BRAG: How I Avoided Losing My Life to Making a Parser
Parsing is a topic of exploration large enough to the spend [an entire dissertation on](http://digitalassets.lib.berkeley.edu/etd/ucb/text/Hall_berkeley_0028E_15470.pdf)
For MinNo, instead of spending the time making on from scratch, or 
learning the [incredibly idiom-centric syntax recognizer in Racket](https://docs.racket-lang.org/reference/stx-patterns.html)
I opted to use a popular Racket tools for grammar specification 
and parsing: *[brag](http://docs.racket-lang.org/brag/)*

*brag* is a *[Backus Naur form](https://en.wikipedia.org/wiki/Backus%E2%80%93Naur_form)* (BNF)
grammar parser implemented as a *Domain Specific Language* within. 

#### Examples of Use and an explanation of BNF:
BNF grammars work using *symbols* and *expressions*. They are organized as such:

   SYMBOL ::= EXPRESSION 

an expression can be any collection of other symbols or terminals (tokens). If a symbol 
is in an expression, it is considered a nonterminal expression and must be parsed further.
It is worth noting that, in use, some artistic merit is used with BNF notation. For instance,
*brag* does not use "::=" for it's equal-sign, it just uses ":" so rules look like:

    SYMBOL: EXPRESSION

Which can be confusing when first looking at it. *brag* also allows expression to only 
use symbols and terminals in regexs is expressions. So, to continue with the calc grammar,
a *brag* rule to recognize numbers may look like:

    num: (INT | FLOAT)

This rule states a "num" is a integer or a float (as tokenized by our lexer).

When a grammar file is given to the *brag* compiler, it produces a *parse*
function. This function will consume a list and than, using the generated LALR
parser, it will construct an abstract syntax tree (AST) abiding by the defined
grammar

### The State of MinNo's Grammar:
A few different versions of [MinNo's grammar](http://git.logan-h-g-davis.io/logan/minno/blob/master/src/grammar.rkt) were toyed around with. Originally, 
MinNo was going to be of a LISP grammar, but between the [limitations a LISP interpreter
would have](http://www.technoblogy.com/show?1GX1) and the shoe-horned-ness of
compiling it, I decided against it. Later iterations took notes from F#,
Scala, Java, Python, and, Pyret. The result of revising is what you seem currently.
I feel it is a nice balance between Scala and F#'s (subjectively) clear type system,
and Python's clear syntax. By no means does it reach in any of those
directions as far as the language take MinNo takes it from (the type system is no even a fraction
as complicated as Scala's and the keywords are not as clean as Pythons). It is a 
small language that is a collection of what I like in other languages. 

The grammar produces a syntax object which is than handled by the translator.

## The Translator: A Handler Model
Like syntax pattern matching, the Racket's syntax objects are highly specific to 
the crowd that is doing cutting edge language research using the platform. To
maintain my sanity, I decided to roll my own template method instead. Given
MinNo's rather strict syntax, predicting the grammar that can be used at any 
point is a programs AST is fairly straight forward. 

#### Avoiding BNF Hell
A a word of warning, this is that area where you start to understand terrible 
mistakes you made in constructing your grammar or defining your lexer. Those 
steps can be made to consume and use some pretty kludgy stuff. But if they consume
kludge they will also produce it. A complicated AST makes for a complicated life. 
It is worth the hours of revising your BNF grammar and lexer to save days of 
debugging here.

#### Handlers:
The way I have decided to tackle MinNo's AST is to define a collection of handlers 
for different syntax structures. There are handlers for let statements, block statements,
function definitions, conditionals, returns, and so on. Each handler knows how to pass off
any sub-syntax structure it contains (such as the statements in a block statement) by using 
a handler directory. The directory used to dispatch sections of the program to their respective
handlers until the program is fully translated. When is left is a new AST closer to that of an 
Arduino Language program.

#### Unpacking the parser

## Targeting AVR Processors:
#### Making Sure Things Stayed Fast
A goal of MinNo was to more easily handle the boiler plate code I use
when writing Arduino scripts. Most of them came out of my experience
making an Arduino based synthesizer. Most of this boiler plate has to
do with the speed of the code, such as embedding a non-terminating
while-loop in ***loop*** function the sketch. The Arduino methods are
well studied in their timing and this effectively cuts the time it
takes to call the loop functions stack frame every iteration. These
kind of trivial (hacky) optimizations are one of the things MinNo helps
generate for you.

**Others include (FILL THIS IN).**


#### Letting People Under The Hood: Why Translator Result Readability Matters
One day I want MinNo to be a mature enough platform to write the
majority of my Arduino sketches in pure MinNo. But the likelihood of
achieving that level of maturity while also wanting the graduate
within 4 months of writing this seems minuscule (to put it lightly).

To make up for this, the MinNo compiler focuses on making (relatively)
readable C code. Often compilers will leverage language constructs
(such as lambdas) to make code generation easier. MinNo's template
approach lets the generated code be written so it can follow
consistent styling and formatting for readabilities sake.

The code being readable allows the current restrictions of MinNo to be
bypassed by editing the resulting C script. If you really want some
kind of manual memory allocation, MinNo generated C will be totally
accepting of that even if MinNo itself isn't.

# What is Left to Be Done:
#### Targeting Closer to the Chip
Currently MinNo targets the Arduino programming language. A next step
would be to target GCC compilable C and AVR assembly directly.

This would be more verbose code for sure, but the speed increases and
system controllability would be greatly increased. A major benefit
would also be the ability to expand support for more embedded
platforms. Targeting Arduino restricts me to boards within Arduino or
it's community's interest to support. Boards like the Beagle Bone and
the Raspberry Pi are outside of this list. Targeting GCC or LLVM (when
the support for AVR is mainlined) will allow faster resulting code and
wider target platform support. 

#### Creating an Ecosystem & Library

MinNo can do plenty of common tasks on the Arduino, but it's current
library of keywords and functions is sparse. In interest of not only
creating a language, but producing a tool, a standard library needs to
be properly fleshed out. String operations, mass pin manipulation,
bit-shifting abilities, encoding and decoding function, and more. All
of this needs to included to make MinNo a robust platform for
embedded development.

It also need to take advantage of the thousands of programming hours
that have already been poured into the platform. Interoperability with
C code directly in the file is on the short list of features to tackle
next. The use the many well coded shield libraries for the Arduino,
the ability to directly call C is needed.

In managing the library, C code, and all of the chips to be targeted,
better tooling needs to be developed. The rise of languages like Rust
and Scala can be attributed solely to their innovation as languages,
but that would be missing a key point that other languages (like D and
Julia) neglected and have not taken take off as a result: tooling. SBT
(Scala's build tool) and Cargo (Rust's version of SBT) helped embedded
programmers in a central conversation of the respective
languages. They allowed for immediately productive and understandable
project structures. These common architectures allowed code to easily
connect and communicate. MinNo needs to make a similar move into
creating an entry point to allow coder to communicate. 

## Opinions On The Ecosystem: Racket, Raco, and General House Keeping
##### Package Management & Tooling
Given that Racket is meant to be built upon DSLs, it also has to have
an easy way to share them so everyone doesn't need to reinvent the
wheel. Therefore, Dr.Racket has a very intuitive graphical package
manager built on top of their command line tool **raco**.

Both the command line version and GUI version of the package installer
and manager as very easy to use. The package site has all the normal
bells and whistles you would expect as well.

**pkgs.racket-lang.org** lists, with all the aesthetic intention of
Dr.Racket, the packages available though **raco**. It contains
tags, links to package documentation, and checksums (if you are
into that).

A moment of panic we all have during development is when you update
language versions or dependancies. Some projects are stuck in
a language feature lock due to their reliance on libraries built in a
previous version (looking at you, Python 2). While writing the MinNo
Compiler, Racket came out with not 1, but 2 language releases.

These were minor version changes (6.7 & 6.8), so I thought about not
jumping versions, but after reading their change-logs, I knew I had
to. 6.7 greatly increased performance of strings in the language. 6.8
improves optimization of equality statements. There make up the vast
majority of operations and data handled by a compiler; it would be a
crime to not utilize the upgrades.

Of course I had that moment of panic when I downloaded the newest
version of Racket. The raw terror of some feature of the Lex library
not working and requiring me to 1. revert to the previous version
or 2. rewrite some not trivial part of the program. After installation
was finish, migrating my dependancies was next on the list.

In the graphical version of the Racket Package Manager, there is a
very handy migration tool from previous language installations. Once
BRAG was migrated and updated, I decided to test how much a had
broken my code base.

    module: identifier already imported from a different source
    whitespace
    parser-tools/lex
    brag/support

It seemed that one of the two libraries decided to now include the
term "whitespace" which was already part of the other library,
creating a naming conflict. After some very brief searching, some
*import prefixing* (answer:
http://stackoverflow.com/questions/17894875/overlapping-module-imports-in-racket)
did the trick. After that, the upgrade was successful & the compiler
felt much snappier then before (though I have no way of saying this
objectively, since i never ran a numeric test).

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
infrastructure as **Cargo** or dynamic as something like
**npm/bower** but there is something to be said for it's
simplicity.

##### Feelings about Where the Language is Going

Racket is unfortunately held back by it's view as a tool for education 
and the lack of attraction that it's only development environment, Dr.Racket,
exudes. When talking to a fellow college student during an internship, I
mentioned that I used Racket. He looked at me with some confusion. "Racket,
we used that in high school for the intro programming course. It was terrible."
Racket was initially created as an education tool. There is a huge amount
of resources poured into it to do as much. But with the state of the default
development environment, you are constantly affronted with what looks like 
software meant to educate you, not to do serious development. Being more 
open and accommodating with other setups for coding in Racket is absolutely 
required to attract & keep new developers. 

It is a surprise that Racket hasn't broken out of their educational roots 
in regards to Dr.Racket like the rest of the language has. Though education
is still a huge part of Racket, the language platform discussion has really
taken off. It's reputation for a systems scripting language is also getting 
some recognition as well. The language from an inner mechanics level has
evolved greatly even since I started using it (Spring, 2013). But by far
one of the most interesting footholds I have witnessed Racket take is in 
game scripting. You can find talks about 3d rendering systems and game 
engines at quite a few different Racket conventions, this is not surprising.
But at GDC, one of the largest graphics and game conventions currently
the company Naughty Dog has given multiple lectures about their use of 
LISP languages and most recently their use of Racket. Something about 
process just seems to root around using LISP (considering they went
through the trouble of maintaining their own sub language for a number of 
years). For the last new (award winning) titles they have released, Racket
has been their choice in scripting languages. 

The movements into fields are far apart as language development and 
gaming scripting have done a great deal to lift Racket out of it's 
PLT reputation. If it could shed away from the last major reminder of
those days, it's deep attachment to Dr.Racket, I think it could really 
be up there with Clojure as the new face of LISP.


## Bibliography:
