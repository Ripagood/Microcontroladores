.include "m16def.inc"

LDI R16, HIGH(RAMEND)
OUT SPH, R16
LDI R16, LOW(RAMEND)
OUT SPL, R16



//EJERCICIO 1


SBI DDRB, 0
SBI PORTB, 1 //pull up del switch

inicio:
sbic PINB, 1
rjmp sesenta
rjmp cuarenta


sesenta:
SBI PORTB,0
call retardo20ms
CBI PORTB, 0
call retardo40ms
rjmp inicio


cuarenta:
SBI PORTB, 0
cALL retardo30ms
CBI PORTB, 0
cALL retardo10msCTC
rjmp inicio


retardo10ms:
LDI R16, 255-78
OUT TCNT0, R16
ldi r16, (1<<CS02)|(1<<CS00)//PRESCALER 1024
out tccr0, R16
wait10ms:
IN R16, TIFR
SBRS R16, TOV0
rjmp wait10ms
CLR R16
OUT TCCR0, R16 //detiene el timer
LDI R16, (1<<TOV0)
OUT TIFR, R16
ret

retardo20ms:
LDI R16, 255-156
OUT TCNT0, R16
ldi r16, (1<<CS02)|(1<<CS00)//PRESCALER 1024
out tccr0, R16
wait20ms:
IN R16, TIFR
SBRS R16, TOV0
rjmp wait20ms
CLR R16
OUT TCCR0, R16 //detiene el timer
LDI R16, (1<<TOV0)
OUT TIFR, R16
ret

retardo30ms:
push r20
ldi r20, 3
otro30ms:
call retardo10msCTC
dec r20
brne otro30ms
pop r20
ret

retardo40ms:
push r20
ldi r20,4
otro40ms:
call retardo10msCTC
dec r20
brne otro40ms
pop r20
ret


retardo10msCTC:
ldi R16, 77
OUT OCR0, R16
LDI R16, (1<<CS02)|(1<<CS00)|(1<<WGM01)
out TCCR0, R16
wait10msCTC:
in r16, TIFR
SBRS R16, OCF0
rjmp wait10msCTC
CLR R16
OUT TCCR0, R16
LDI R16, (1<<OCF0)
OUT TIFR, R16
ret


retardo20msCTC:
ldi R16, 154
OUT OCR0, R16
LDI R16, (1<<CS02)|(1<<CS00)|(1<<WGM01)
out TCCR0, R16
wait20msCTC:
in r16, TIFR
SBRS R16, OCF0
rjmp wait20msCTC
CLR R16
OUT TCCR0, R16
LDI R16, (1<<OCF0)
OUT TIFR, R16
ret




























































