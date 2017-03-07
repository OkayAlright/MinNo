 const PROGMEM int outputPin = 13 ;
	 
 void setup () {
	 pinMode(pgm_read_word(&outputPin),OUTPUT) ;
 }
 
 void loop () {
	 digitalWrite(pgm_read_word(&outputPin),HIGH) ;
	 delay(1000 ) ;
	 digitalWrite(pgm_read_word(&outputPin),LOW) ;
	 delay(1000 ) ;
	 digitalWrite(pgm_read_word(&outputPin),LOW) ;
 }
 
