#lang racket
(define expected-output-string
  " const PROGMEM int ledpin = 13 ;\n\t \n const PROGMEM char stringtest[] = \"this is a test string.\\n\" ;\n\t \n const PROGMEM float testfloat = 5.0 ;\n\t \n int mutable_inttest = 5 ;\n\t \n char mutable_stringtest[] = \"this is a test string.\\n\" ;\n\t \n float mutable_testfloat = 56.0 ;\n\t \n const PROGMEM int expr_inttest = 5 + ( 7 + 9 ) * 8 ;\n\t \n const PROGMEM float expr_floattest = 5.0 + ( 7.0 + 9.0 ) * 8.0 ;\n\t \n void setup () {\n\t pinMode(pgm_read_word(&ledpin),OUTPUT) ;\n\t pinMode(3 ,INPUT) ;\n\t mutable_testfloat = 8.0 ;\n\t mutable_inttest = 5 + 7 ;\n }\n \n void loop () {\n\t const PROGMEM int five = 2 * 2 + 1 ;\n\t int i = 0 ;\n\t while(i < 10 ){\n\t if(( i <= 10 ) && ( five == 5 ) ){\n\t i = 10 ;\n }\n else{\n\t i = 1 ;\n }\n }\n for(int a = 0 ; a <= 10 ;a = a + 1 ){\n\t i = i - 1 ;\n }\n }\n \n int test_fun (int x, int i) {\n\t return x + i ;\n }\n \n")
(provide (all-defined-out))