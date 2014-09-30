.include "m16def.inc"

;pila
//EJERCICIO 1
LDI R16, HIGH(RAMEND)
OUT SPH, R16
LDI R16, LOW(RAMEND)
OUT SPL, R16

call iniciar

IN R16, PINC
LDS r17, 0x60
mul r16, r17//regrsa resultado en R0 y R1
STS 0x300, R0
STS 0x301, R1

//Ejercicio 2
LDI R16, 0xFF
OUT DDRB, R16 //lo pone como salida

LDI ZH, high(0x400<<1)
LDI ZL, low(0x400<<1)//
Lpm R16, Z
lds r17, 0X70
SUB R16, R17//NOS REGRESA EL VALOR EN R16
OUT PORTB, R16


//Ejercicio 3
LDS R16, 0x60
LDS R17, 0x61
LDS R18, 0x62
LDS R19, 0x63//primer operando

lds r20, 0x65
lds r21, 0x66
lds r22, 0x67
lds r23, 0x68//segundo operando


ADd R16, R20//suma con carry
ADC R17, R21
ADC R18, R22
ADC R19, R23

sts 0x80, r16
STS 0x81, r17
sts 0x82, r18
sts 0x83, r19


fin: rjmp fin


iniciar:
 LDI R16, 0x80
 STS 0x60, R16

ldi r17, 0x08
STS 0x70, r16

STS 0x65, r16
ret



.org 0x400
.db 0xF0, 0x0F
.db 0x09, 0x00






















