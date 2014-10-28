.include "m16def.inc" 

.org 0 
jmp main 
.org 0x02
jmp Interrupcion0
.org 0x04
jmp Interrupcion1


Interrupcion0:
push r20
in r20, sreg
push r20

INC R18

pop r20
out SREG , R20
pop r20
reti

Interrupcion1:
push r20
in r20, sreg
push r20

dec r18

pop r20
out sreg, r20
pop r20
reti





main:

LDI R16, HIGH(RAMEND)
OUT SPH, R16
LDI R17, LOW(RAMEND)
OUT SPL, R16

LDI R16, (1<<ISC11)|(1<<ISC01)
OUT MCUCR, R16

LDI R16, (1<<INT0)|(1<<INT1)
OUT GICR, R16

SBI PORTD,2;INTO
CBI DDRD, 2


SBI DDRB, 7 //LED
LDI R16, 0xFF
OUT DDRC, R16

inicio:
OUT PORTC, R18
CPI R18, 10
BRSH menor
CBI PORTB,7
rjmp inicio
menor:
CPI R18, 101
BRLO led
CBI PORTB, 7	
rjmp inicio
led:
SBI PORTB, 7
rjmp inicio










	


