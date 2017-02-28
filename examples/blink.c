 int outputPin = 13 ;
	 
 void setup () {
	 pinMode(OUTPUT,outputPin) ;
 }
 
 void loop () {
	 digitalWrite(outputPin,HIGH) ;
	 delay(1000 ) ;
	 digitalWrite(outputPin,LOW) ;
	 delay(1000 ) ;
 }
 
