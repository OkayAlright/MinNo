# MinNo 

MiNo is a MINimal NOise language for arduinos and AVR processors.
The languages is currently under developement as part of a 
Marlboro College Plan of Concentration. 

The goals of the language are:

* To emphasise some of the features of Harvard Architecture processors (most AVR processors) at a syntactic level.
* Simplify some boilerplate arduino idioms.
* Generate readable C to allow further tweaking once the simpler MinNo file is compiled.


## The State of The Code:

Currently this project is under V0.1 developement and can be considered,
for all intents and purposes, non-functional at this time. This status will
change in the very near future. :)

## What's What:

* "src/": The source code for the actual compiler is contained within this directory. The lexer, parser-spec, and tranlator can all be found there.
* "example/": Some example programs in MinNo.
* "resource/": Would be better titled "lib" because it just hold some files that the compiler needs. Expect that name to change.

This compiler was started on Racket 6.6 but is currently being developed
using Racket 6.8 and the only dependancy to run it will be Racket itself and 
the BRAG library (http://docs.racket-lang.org/brag/).

## Contact:

Any feed back or questions can be directed to ldavis@marlboro.edu

This readme will be expanded as the project progresses.
