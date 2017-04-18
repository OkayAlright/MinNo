# Why MinNo?

I didn't have an easy time learning how to code when I first started. One of the largest reasons I had trouble was 
because of my first language: [Python](https://www.python.org/).[1]

Though Python has many strengths, I would not say consistency is not among them. This is a pervasive problem from 
the language's core mechanics (string methods being in place or returning new strings for example) to how any two 
given people try to teach the same idea (take these two answers to similar questions for example: [1](http://stackoverflow.com/questions/402504/how-to-determine-the-variable-type-in-python) & [2](http://stackoverflow.com/questions/152580/whats-the-canonical-way-to-check-for-type-in-python).[2][3]
One of Python's strengths is that it allows you to do one specific thing in ten different ways, but I am someone 
who likes to hear a single thing explained multiple ways. Though I was able to overcome my problems with Python, 
when I began toying around with the [Arduino platform](https://www.arduino.cc/), I found the same 
problem with their [home-grown language](https://www.arduino.cc/en/Reference/HomePage).[4][5]

The [Arduino language](https://github.com/arduino/Arduino/) (AKA [Processing](http://playground.arduino.cc/Interfacing/Processing), [Wiring](https://blogs.windows.com/buildingapps/2016/09/07/introducing-arduino-wiring-on-windows-10-iot-core/#vYEu3yjHXGsS9ZXE.97), [C/C++](http://forum.arduino.cc/index.php?topic=45492.0)) is a language built on top of C++ but only implements a 
subset of the C standard library (but none of C++'s library, just using it's syntax and constructs).[6][7][8][9] There are also 
a fair amount of Arduino/AVR specific functions and global variables sprinkled about. Because of this mash up that is 
supposed to be a beginner platform and a collection of C functions resembling a K&R era implementation of the language, you 
get coders running the gamut in style and techniques. [On one end you have some hobbyists making really high level 
sketches with sophisticated libraries to run wifi-shields for their Arduino Uno project in just a few lines of 
code](https://www.arduino.cc/en/Guide/ArduinoWiFiShield101).[10] [On the other side you have some old school hackers writing some of the most PreProcessor-Macro'ed, bit 
twiddling, interrupt throwing files you could imagine](http://rcarduino.blogspot.com/2012/11/quick-and-dirty-synth-for-arduino-due.html).[11] If you aren't brought up to speed on C and Arduino by 
some guide that was provided by education companies like [Sparkfun](https://cdn.sparkfun.com/datasheets/Kits/SFE03-0012-SIK.Guide-300dpi-01.pdf), you can find yourself in a 
hexadecimal-encoded hell within a matter of clicks.[12] MinNo is an attempt to create a more humane (for people like 
myself) entry point to the Arduino platform.

## CPU Architecture: Harvard vs. Von Neumann
Most interest in processor architecture lies in standardized implementations (x86 and ARM). The conversation 
at this level typically is a discussion of instruction sets and bus implementation. AVR processors take it a step further 
back and discuss the basic organization of a computer. X86 and ARM architectures are organized in a manner originally 
specified by [John Von Neumann](http://www.c-jump.com/CIS77/CPU/VonNeumann/lecture.html): a central processing unit, memory, some form of input, some form of output, and long term 
storage across a set of shared buses.[13] AVR processors (generally) are organized in a manner consistent with [Harvard specification](http://embeddedknowledge.blogspot.com/2010/02/processor-architectures-harvard-von.html) (more accurately, 
the modified-Harvard spec).[14] The main difference between Von Neumann and Harvard is that Harvard separates memory into 
two different pools: instruction memory and data memory, which attach to the CPU via entirely separate buses. 
Harvard processors can simultaneously read and write to both memory pools because they do not share a bus. The two pools 
don't even need to be indexed and architectured the same. Often (as is the case with AVR processors), instruction memory is read/write 
accessible at runtime, data memory isn't. Data memory is often used for long-term, initialization data: tables, addresses, 
arrays, keys, and so on. Both the data and instruction memory pools are implemented as EPROM/Flash storage . 
AVR processors have general SRAM for data that needs to be accessed more quickly (in place of caches).

One of the problems with using C to program Harvard processors is that most C compiler implementations (and subsequently Arduino's 
language) have grown under the ideas of Von Neumann architecture. All memory accessors and management systems, property 
files, and object oriented idioms assume the computer they are running on has one shared pool of read/write memory. To 
allow the benefits of Harvard's memory architecture, we have to pollute the global name space with keywords to specifically 
access the data memory pool (such as declaration containing "const PROGMEM" is Arduino sketches).

MinNo is an attempt to embedded Harvard's  distinction in architecture at the syntactic level. By default, all 
declarations of variables are immutable unless they contain the "mutable" tag. If the compiler sees an immutable 
declaration, it will be put in "program memory" (Arduino's name for data memory). This allows for a more concise 
memory placement syntax to counteract MinNo's slightly more verbose declaration structure. This thought of embedding 
Harvards design choices in the syntax is a consideration throughout the languages idioms and structures.

## Static Memory Allocation
[Culturally, among novice programers, pointers and manual memory management stand as the mysterious and often frightening 
figure when writing software](http://stackoverflow.com/questions/4025768/what-do-people-find-difficult-about-c-pointers).[15] It is easy to misuse them and hard to figure out why they aren't working (if you aren't 
practiced in debugging them). Their inclusion in the Arduino language stands as an oddity to me for that reason, other than 
performance restrictions that prohibit a garbage collection system. Why would a platform bragging about beginner friendliness 
use one of the most notoriously confusing memory management systems? Given that garbage collection is out of the question 
due to the lower power CPUs found on Arduinos and that MinNo is supposed to be an alternative beginner language, I have decided (at least 
for now) to have no dynamically growing memory in MinNo: everything is statically allocated.

This may initially seem like a huge drawback, and in general programming I would agree. But in embedded systems, dynamic 
memory bugs can be subtle, incredibly hard to reproduce, and absolutely system crashing . Early in my 
time programming sketches, I swore off the use of malloc and free in favor of static memory declarations. From 
synthesizers, to controllers, to IR navigating robots, I have gotten away without using dynamic heap allocations. 
To anyone reading this, for your sanity, I would suggest a similar shift in coding style. [Others also suggest minimizing dynamic 
allocation where you can](http://web-engineering.info/node/30).[16]

With purely static allocation, it also allows for far better utilization of the program memory pool. An added bonus in such a 
memory restricted system. 

## Template Operations vs. Stateful Procedures
MinNo is meant to emphasize a more template based form of thinking about code; the code represents templates operating on 
data. A hard separation of data and code should be taken where it can. Intermediary values and indexing values are, of 
course, held in read/write instruction memory, but these values can be thought of as markers and states in templates. 
Indexes are markers as to what templates are being applied to. Intermediate values are states in between templates 
operations. This mind set keep the separation of memory pools more consistently present and should lead one to 
minimize stateful code as to avoid unnecessary complexity.

## Getting Under The Hood
Now there are absolutely times when this distinction of memory can be far more of a hinderance than a benefit. Sometimes we 
really need manual heap allocation. MinNo's compiler attempts to generate (subjectively) readable, tabbed 
C code. This will allow boiler plate functions and code to be generated, but the resulting code can be opened and 
optimized/altered to allow for malloc's, free's and a things C-like. It also allows for a bridge from those who have 
been using MinNo to transition into C in a low-stakes, take-it-at-your-pace manner.

For example, leveraging integer sizes to cut down of code to handle looping over collections is fairly common
in Arduino programming, but something MinNo doesn't handle very well (yet). An example of this could be  indexing
through a waveform to be send out via an analog port on an Arduino board:

     int squareWave[256] = {0};
     byte i = 0; //8-bit integer type in Arduino

     //some code to correctly assign the last 128 indexes of squareWave to 255

     while(0){
         analogWrite(squareWave[i++]);
     }

The reason this works is because whenever **i** equals 255 (the last index of **squareWave**), on the next
increment it overflows back to 0 because it is an 8-bit value. This kind of trick is currently not directly
possible in MinNo. To get a similar effect, your code would look like this:


     let squareWave: array[int] = [0,0,0,0,0 ....Then the other 250 integer values];
     let i : mutable int = 0;
     while 0 {
         analogWrite squareWave[i] ;
         i = i + 1;
         if i >= 255 {
             i = 0;
         }
     }

Though this is possibly more readable (less bit-length trickery), it is quite a few more instructions and 
would take quite a few more cycles to complete. Instead I can compile the above function which would produce
the C code:

     const PROGMEM int squareWave[] = { 0 , 0 , 0 , 0 , 0... the other 250 values} ;
	 int i = 0 ;
	 while(0 ){
		 analogWrite(pgm_read_word(&squareWave[i])) ;
		 i = i + 1 ;
		 if(i >= 255 ){
			 i = 0 ;
        }
     }

Then I can get rid of the wrapping logic and change the type of **i** from **int** to **byte**:

     const PROGMEM int squareWave[] = { 0 , 0 , 0 , 0 , 0... the other 250 values} ;
	 byte i = 0 ;
	 while(0 ){
		 analogWrite(pgm_read_word(&squareWave[i++])) ;
     }

Restrictions like this are something I know is a shortcoming of the language can I plan to address them in short order.
But tricks like these, I would venture to say, are only in ~10% of the code I write. If MinNo allows me to more easily
complete the other 90% and more mindfully consider when I really need to leverage tricks for performance over writing
more understandable code, than it has done it's job.


## State of The Language:

Currently MinNo is in an *Alpha* state and, though I find it useful for personal work, I would not call it
production ready by any means. Some more consideration on both the ideas of the language and the construction 
of the compiler are subject to change. Wider support different bit-length integers; structs; optional
safer-pointers; and Foreign Function Interfaces (for direct C code) are all being considered on the language side. 
The compiler needs a semantic verifier in the very near future. This would check arity, make sure no attempted 
re-assignments to constants occur and so. When you actually upload the compiled MinNo script, GCC does all of this
for you, but all the messages reference the translated C and not the actual MinNo source file. This is workable for 
now but by no means is it ideal, and it will become a bigger problem with another goal for the compiler. 

The LLVM community has been doing a lot of work on mainlining AVR support into their codebase. For those who don't know,
LLVM is a compiler framework that allows for a single target language (the LLVM Intermediate Representation) to be
optimized and compiled down to machine code for numerous platforms. If LLVM gets AVR support, MinNo will be able to 
benefit from the vast amount of tool for LLVM compiler and possibly pivot to supporting other platforms with minimal 
rewriting of core compiler components. This would be a pivot away from GCC which is why a proper semantic verifier is so
important. 

I don't plan to try to make MinNo more functional-oriented or construct some system to ensure type safety. I want 
a language to cut down on the code I have to write because the language I have been using makes the incorrect
assumptions (like C's assumption of a single memory bus). Given that fact, expect the progression of the language
to reflect as such.

## Getting Involved:

Though I am not taking direct outside contributions to the project right now, I would love feed back on the language.
MinNo, it's compiler, and the documentation are all under the MIT License, so if you like the idea but want to run
a different direction with it, please feel free to fork the source code. If you have any questions or just want 
to talk about the language or anything I have mentioned here, please feel free to contact me:

 - email: ldavis@marlboro.edu 
 - twitter: @Death\_by_kelp


## Bibliography:

 - \[1]: "Welcome to Python.org." *python.org*. Accessed: April 16th, 2017. https://www.python.org/.

 - \[2]: gregjor. "How to determine a variable's type?." *stackoverflow.com*. Published: December 31st, 2008. http://stackoverflow.com/questions/402504/how-to-determine-the-variable-type-in-python.

 - \[3]: Fredrik Johansson. "What's the canonical way to check for type in python?." *stackoverflow.com*. Published: September 30th, 2008. http://stackoverflow.com/questions/152580/whats-the-canonical-way-to-check-for-type-in-python.

 - \[4]: "Arduino - Home." *arduino.cc*. Accessed: April 16th, 2017. https://www.arduino.cc/.

 - \[5]: "Arduino - Reference." *arduino.cc*. Accessed: April 16th, 2017. https://www.arduino.cc/en/Reference/HomePage.

 - \[6]: "GitHub - arduino/Arduino: open-source electronics prototyping platform." *arduino.cc*. Accessed: April 16th, 2017. https://github.com/arduino/Arduino/.

 - \[7]: "Arduino Playground - Processing." *arduino.cc*. Accessed: April 16th, 2017. http://playground.arduino.cc/Interfacing/Processing.

 - \[8]: Mahmoud Saleh. "Introducing Arduino Wiring on Windows 10 IoT Core." *windows.com*. Published: September 7th, 2016. https://blogs.windows.com/buildingapps/2016/09/07/introducing-arduino-wiring-on-windows-10-iot-core/#vYEu3yjHXGsS9ZXE.97.

 - \[9]: lloyddean. "What is the language you type in the Arduino IDE?." *arduino.cc*. Published: December 8th, 2010. http://forum.arduino.cc/index.php?topic=45492.0.

 - \[10]: "Arduino - ArduinoWiFiShield101 ."  *arduino.cc*. Accessed: April 16th, 2017.  https://www.arduino.cc/en/Guide/ArduinoWiFiShield101.

 - \[11]: Can\_I_Trade?. "Quick And Dirty Synth For Arduino Due." *rcarduino.blogspot.com*. Published: November 30, 2012. http://rcarduino.blogspot.com/2012/11/quick-and-dirty-synth-for-arduino-due.html.

 - \[12]: "Sparkfun Inventor's Kit Guide." *Sparkfun*. Accessed: April 16th, 2017. https://cdn.sparkfun.com/datasheets/Kits/SFE03-0012-SIK.Guide-300dpi-01.pdf.

 - \[13]: Igor Kholodov. "The von Neumann Computer Model." *Bristol Community College*. Accessed: April 16th, 2017. http://www.c-jump.com/CIS77/CPU/VonNeumann/lecture.html.

 - \[14]: Student Fredrick. "Processor architectures: Harvard, von Neumann and Modified Harvard architectures." *embeddedknowledge.blogspot.com*. Published: February 05, 2010. http://embeddedknowledge.blogspot.com/2010/02/processor-architectures-harvard-von.html.

 - \[15]: jkerian. "What do people find difficult about C pointers." *stackoverflow.com*. Published: October 26th, 2010. http://stackoverflow.com/questions/4025768/what-do-people-find-difficult-about-c-pointers.

 - \[16]: mdiaconescu. "Optimize Arduino Memory Usage." *web-engineering.info*. Published: July 27th, 2015. http://web-engineering.info/node/30.











