 const PROGMEM int sensorPin = 0 ;
	 
 const PROGMEM int ledPin = 13 ;
	 
 void setup () {
	 pinMode(pgm_read_word(&ledPin),OUTPUT) ;
 }
 
 void loop () {
	 int sensorVal = analogRead(pgm_read_word(&sensorPin)) ;
	 digitalWrite(pgm_read_word(&ledPin),HIGH) ;
	 delay(sensorVal) ;
	 digitalWrite(pgm_read_word(&ledPin),LOW) ;
	 delay(sensorVal) ;
 }
 
