.include "m16def.inc"
.def positivo= r22
.def negativo= r21


ldi r16,HIGH(RAMEND) 
 out SPH,r16 
 ldi r16,LOW(RAMEND) 
 out SPL,r16 

; Ejercicio 1

JMP Ejercicio5



LDI XH, HIGH(0X300)
LDI XL, LOW(0X300)
ldi R17, 100

otro:
IN R16, PINA
ST X+, R16
call retardo200ms
dec r17
brne otro

; Ejercicio 2
LDI R16 , 0xff
OUT DDRC , R16

ldi r17, 100
ldi ZH, HIGH(0X200<<1)
LDI zl, LOW(0X200<<1)

otro3:
LPM R16, Z+
OUT PORTC, R16
dec r17
call retardo1s
brne otro3



; Ejercicio 3

LDI XH, high(0x100)
LDI XL, low(0x100)
ldi r18, 15
ldi r16, 0xff
OUT DDRB , R16

ciclo15:
ld r16, X+
ANDI r16, 0b10000000; nos deja solo el septimo bit
CPI R16, 0b10000000
BREQ negativos
inc positivo
dec r18
brne cc
rjmp continua
negativos:
inc negativo
dec r18
brne cc
rjmp continua
cc:
rjmp ciclo15

continua:
CP positivo, negativo
BRSH prendePB0
SBI PORTB, 7
rjmp fin3
prendePB0:
SBI PORTB, 0
fin3:
CBI PORTB, 0
CBI PORTB, 7


;Ejercicio 4

LDI ZH, HIGH(0X300<<1)
LDI ZL, LOW(0X300<<1)
LPM R17, Z

in r16, PINC

LDI R20, 0XFF
OUT DDRC, R20

CP R16, R17
BREQ manda0
SBI PORTC, 1
call retardo3s
cbi portc, 1
rjmp fin4
manda0:
CBI PORTC, 0
call retardo50ms
SBI PORTC, 0
fin4:

Ejercicio5:
SBI PORTB, 2; pull up 

LDI R16, 0xFF
OUT DDRC, R16

inicio:
SBIS PINB, 2
rjmp mandaN
mandaY:
LDI r16, 'Y'
OUT PORTC, R16
CBI PORTB, 1
call retardo100ms
SBI PORTB, 1
rjmp inicio
mandaN:
LDI R16, 'N'
OUT PORTC, R16
sbi PORTB, 0
CALL retardo3s
CBI PORTB,0
rjmp inicio


retardo100ms:
push r20
ldi r20,10
otro100ms:
call retardo10ms
dec r20
brne otro100ms
pop r20
ret



retardo3s:
push r20
ldi r20, 3
otro3s:
call retardo1s
dec r20
brne otro3s
pop r20
RET




retardo50ms:
push r20
LDI R20, 5
otroCiclo:
call retardo10ms
dec R20
BRNE otroCiclo
pop r20
RET






retardo1s:
push r20
ldi r20, 100
aqui:
call retardo10ms
dec r20
brne aqui
pop r20
ret



retardo200ms:
push r20
ldi r20,20
otro2:
call retardo10ms
dec r20
brne otro2
pop r20
ret




retardo10ms:
	push r20
	push r21
	LDI R20, 104
	ciclo1: LDI R21, 255
	ciclo:  dec r21
		BRNE ciclo
		DEC R20
		BRNE CICLO1
		pop r21
		pop r20
RET

.org 0x300
.db 0x81, 0x67
