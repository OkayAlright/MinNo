# MinNo 

MiNo is a MINimal NOise language for Arduino and AVR processors.
The languages is currently under development as part of a 
Marlboro College Plan of Concentration. 

# Example Code:

     #/
     blink.minno
     by Logan Davis
     
        An example blink program.
        
     /#
     
     let outputPin : int = 13; //set pin for reference
     
     def setup none -> none {
         //set mode to output
         pinMode outputPin OUTPUT;
     }
     
     def loop none -> none {
         // blink on and off with 1 sec intervals
         digitalWrite outputPin HIGH;
         delay 1000;
         digitalWrite outputPin LOW;
     }

## What's What:

* "src/": The source code for the actual compiler is contained within this directory. The lexer, parser-spec, and translator can all be found there.
* "example/": Some example programs in MinNo.
* "extras/": Documentation about the language and papers/writing about the construction of MinNo.

Documentation of the language can be found in the wiki tab.

This compiler was started on Racket 6.6 but is currently being developed
using Racket 6.8 and the only dependency to run it will be Racket itself and 
the BRAG library (http://docs.racket-lang.org/brag/).

## Contact:

Any feed back or questions can be directed to ldavis@marlboro.edu

This readme will be expanded as the project progresses.
