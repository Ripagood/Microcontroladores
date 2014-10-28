.include "m16def.inc" 
.def pulsos= R21

.org 0 
jmp main 
.org 0x02
jmp Interrupcion0
.org 0x04
jmp Interrupcion1
.org 0x0C
jmp CompareATimer1
.org 0x0E
jmp CompareBTimer1
.org 0x24
jmp Interrupcion2



Interrupcion0: //señal de inicio
LDI R19, 0xFF
reti

Interrupcion1:

ldi r16, (1<<WGM11)|(0<<COM1A1)|(0<<COM1A0)|(0<<COM1B1)|(0<<COM1B0)
OUT TCCR1A, R16

ldi r16, (1<<WGM13)|(1<<WGM12)|(0<<CS11)|(0<<CS10);apagado
out TCCR1B, r16
SBI PORTD,4
SBI PORTD,5

reti

Interrupcion2:
cBI PORTB,0
reti



CompareATimer1:
in r20, SREG

dec pulsos
BRNE salir

ldi r16, (1<<WGM11)|(0<<COM1A1)|(0<<COM1A0)|(0<<COM1B1)|(0<<COM1B0)
OUT TCCR1A, R16

ldi r16, (1<<WGM13)|(1<<WGM12)|(0<<CS11)|(0<<CS10);apagado
out TCCR1B, r16

salir:
OUT SREG, R20
reti

CompareBTimer1:
in r20, SREG

dec pulsos
BRNE salir1

ldi r16, (1<<WGM11)|(0<<COM1A1)|(0<<COM1A0)|(0<<COM1B1)|(0<<COM1B0)
OUT TCCR1A, R16

ldi r16, (1<<WGM13)|(1<<WGM12)|(0<<CS11)|(0<<CS10);apagado
out TCCR1B, r16

salir1:
OUT SREG, R20
reti









main:
 ldi r16,HIGH(RAMEND) 
 out SPH,r16 
 ldi r16,LOW(RAMEND) 
 out SPL,r16 

//Interrupcion Externa

LDI R16 ,0b11100000; INT0 ,INT 1 e INT2
OUT GICR, R16

LDI R16, 0b00001010; falling edge de INT0 e INT1
OUT MCUCR, R16

;INT 2 con ISC2=0 es falling edge


;periodo 250 ms
LDI R16,high(31249)
LDI R17,low(31249)
OUT ICR1H, R16
OUT ICR1L, R17

LDI R16, HIGH(24999);200ms
LDI R17, LOW(24999)
OUT OCR1AH, R16
OUT OCR1AL, R17



LDI R16, HIGH(24999);200ms
LDI R17, LOW(24999)
OUT OCR1BH, R16
OUT OCR1BL, R17


ldi r16, (1<<WGM13)|(1<<WGM12)|(0<<CS11)|(0<<CS10);apagado
out TCCR1B, r16

ldi r16, (1<<WGM11)|(1<<COM1A1)|(1<<COM1A0)|(0<<COM1B1)|(0<<COM1B0)
OUT TCCR1A, R16



SBI DDRD, 4
SBI DDRD, 5; salidas PWM

SBI PORTD,2;INTO
CBI DDRD, 2
SBI PORTD,3;INT1
CBI DDRD, 3
sbi portb,2;INT2
CBI DDRD,2

SBI DDRB, 0;señal reinicio
SBI PORTB,0

;modo 14, tope ICR1, salida  invertida en OC1A y OC1B
;prescaler de 64




sei

espera:

CPI R19, 0XFF
BRNE espera
CLR R19


inicio:
in R16, PINA
SBRS R16, 7
rjmp DesplazamientoDerecha
DesplazamientoIzquierda:
ANDI R16, 0b01111111
MOV pulsos, R16; guarda los pulsos
call Izquierda
rjmp espera
DesplazamientoDerecha:
ANDI R16, 0b01111111
MOV pulsos, R16
call derecha
rjmp espera





izquierda:

CBI PORTD,5
sbi portd,4

ldi r16, (1<<WGM11)|(1<<COM1A1)|(1<<COM1A0)|(0<<COM1B1)|(0<<COM1B0)
OUT TCCR1A, R16

ldi r16, (1<<WGM13)|(1<<WGM12)|(1<<CS11)|(1<<CS10);prendido
out TCCR1B, r16



ldi r16,(1<<OCIE1A)|(0<<OCIE1B)
OUT TIMSK, R16

ret


derecha:
SBI PORTD,5
CBI PORTD,4


ldi r16, (1<<WGM11)|(0<<COM1A1)|(0<<COM1A0)|(1<<COM1B1)|(1<<COM1B0)
OUT TCCR1A, R16

ldi r16, (1<<WGM13)|(1<<WGM12)|(1<<CS11)|(1<<CS10);prendido
out TCCR1B, r16


clr r16
ldi r16,(0<<OCIE1A)|(1<<OCIE1B)
OUT TIMSK, R16

ret
