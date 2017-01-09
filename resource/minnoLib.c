/* Minno.c
 * By Logan Davis
 *
 * DESCRIPTION: a template for the MinNo compiler to use
 *              when translating code.
 *
 * 12/5/16 | Apple LLVM version 7.3.0 (clang-703.0.31) | MIT License
 */

// ----- UTILITY FUNCTIONS ----- //
void setPins(int *pins, int number_of_pins, int mode){
  for(int i = 0; i < number_of_pins, i++){
    digitalWrite(pins[i],mode);
  }
}

// ----- USER GLOBAL CODE (defs and such) ----- //



// ----- SYSTEM CALLED FUNCTIONS ----- //
void setup(){
  //user setup code goes here
}

void loop(){
  while(0){
    //user loop code goes here
  }
}

/*
 ______    __                             __                  __     
/\__  _\  /\ \                           /\ \                /\ \    
\/_/\ \/  \ \ \___       __       ___    \ \ \/'\      ____  \ \ \   
   \ \ \   \ \  _ `\   /'__`\   /' _ `\   \ \ , <     /',__\  \ \ \  
    \ \ \   \ \ \ \ \ /\ \L\.\_ /\ \/\ \   \ \ \\`\  /\__, `\  \ \_\ 
     \ \_\   \ \_\ \_\\ \__/.\_\\ \_\ \_\   \ \_\ \_\\/\____/   \/\_\
      \/_/    \/_/\/_/ \/__/\/_/ \/_/\/_/    \/_/\/_/ \/___/     \/_/
 generated via messletters.com     
 */
