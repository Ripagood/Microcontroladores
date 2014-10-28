.include "m16def.inc" 
 
ldi r16,HIGH(RAMEND) 
out SPH,r16 
ldi r16,LOW(RAMEND) 
out SPL,r16 

rjmp Ejercicio3

SBI DDRB, 3 ; salida OC0
Ejercicio1:
LDI R16, 77
OUT OCR0 , R16; tope a 50hz
clr r16
ldi R16, (1<<WGM01)|(1<<COM00)|(1<<CS02)|(1<<CS00)//toggle
out TCCR0,R16

fin: rjmp fin

Ejercicio2:
ldi r16, 205;80% de 255
OUT OCR0, R16
clr r16
ldi r16, (1<<WGM01)|(1<<WGM00)|(1<<COM01)|(1<<CS01)
;modo fast pwm, compare , duty cycle al 80% , prescaler de 8
out TCCR0, R16
fin2: rjmp fin2

Ejercicio3:


SBI DDRD, 5 ; salida PWM OC1A

LDI R16, high(19999); tope
LDI R17, low(19999)
OUT ICR1H, R16
OUT ICR1L, R17

LDI R16, high(15999); 80%
LDI R17, low(15999)
OUT OCR1AH, R16
OUT OCR1AL, R17

ldi r16, (1<<WGM11)|(1<<COM1A1)
OUT TCCR1A, R16
ldi r16, (1<<WGM13)|(1<<WGM12)|(1<<CS11)
out TCCR1B, r16

;modo no invertido, prescaler de 8 y salida en OC1A


LDI ZH, high(0x400<<1)
LDI ZL, low(0x400<<1)
LPM R17, Z
inicio:
call delay20ms
IN R16, PINA
CP R16, R17
BRSH mayor
menor:
LDI R16, high(5999)
OUT OCR1AH, R16
LDI R16, low(5999)
OUT OCR1AL, R16
rjmp inicio


mayor:
BREQ igual
LDI R16, high(15999)
OUT OCR1AH, R16
LDI R16, low(15999)
OUT OCR1AL, R16
rjmp inicio


igual:
LDI R16, high(9999)
OUT OCR1AH, R16
LDI R16, low(9999)
OUT OCR1AL, R16
rjmp inicio


delay20ms:
ldi r16, 156
out OCR2, R16
clr r16
ldi r16, (1<<WGM21)|(1<<CS02)|(1<<CS01)|(1<<CS00)
;CTC prescaler 1024
out TCCR2, r16
wait:
in r16, TIFR
SBRS R16, OCIE2
rjmp wait
clr r16
out TCCR2, R16
ldi R16, (1<<OCIE2)
out TIFR, r16
ret







.org 0x400
.db 0x80, 0x81






