.include "m16def.inc"

  .org 0
  JMP main
.org 0x02
  JMP INTERRUPCION_0
   .org 0x0C
  JMP TIMER1_COMPA
  .org 0x26
  JMP RFSH

INTERRUPCION_0:
SER R19
RETI

TIMER1_COMPA:
IN R16, PINA
ST Y+, R16
call muestraValor
DEC R18
BRNE salirTimer1
LDI YH, high(0x100)
LDI YL, low(0x100)
LDI R18, 50
salirTimer1:
reti



main: ldi r16,low(RAMEND)
      out SPL,r16
      ldi r16,high(RAMEND)
      out SPH,r16	     ;init Stack Pointer

	  LDI R16,0xff
	  OUT DDRC,R16        ;pto c como salida
	  OUT DDRB,R16        ;pto b como salida
	  
	  LDI R16,2
	  OUT TIMSK,R16       ;Hab. int timer 0
	  
	  LDI R16,38          ;cte de tiempo con prescaler=1024
	  OUT OCR0,R16

	  LDI R16,0xD         ;modo CTC, presacaler 1024
	  OUT TCCR0,R16

	  LDI XL,0x60         ; puntero a ram de display
	  LDI XH,0
	  LDI R24,4           ; contador de l?paras
	  LDI R25,0b11111110  ; c?igo de barrido

	  LDI R16,0x40        ;codigo 7s del 0
	  STS 0x60,R16
	  STS 0x61,R16
	  STS 0x62,R16
	  STS 0x63,R16

//Interrupcion 0
LDI R16, 0b00000010
OUT MCUCR, R16
LDI R16, 0b01000000
OUT GICR, R16
// Timer1 1 seg
LDI R16, HIGH(7812)
OUT OCR1AH, R16
LDI R17, LOW(7812)
OUT OCR1AL, R16

SEI


inicio:
CPI R19, 0xFF
BRNE inicio
CLR R19


ldi r16,(1<<WGM12)|(1<<CS12)|(1<<CS10);1024 CTC
OUT TCCR1B, R16
IN R16, TIMSK
SBR R16,(1<<OCIE1A)
out TIMSK, R16

LDI YH, high(0x100)
LDI YL, low(0x100)
LDI R18, 50

rjmp inicio


muestraValor:
push r18
LDI ZH, high(0x400<<1)
LDI ZL, low(0x400<<1)
SUBI ZL, -10
LPM R16, Z+
STS 0X60, R16 ;P
LPM R16, Z+
STS 0X61, R16; R
LDI ZH, high(0x400<<1)
LDI ZL, low(0x400<<1)
IN R16, PINA; VALOR DE PRESION
ADD ZL, R16;#
LPM R16, Z
STS 0X63, R16
call comparaValor
pop r18
ret










comparaValor:
LDI ZH, high(0x300<<1)
LDI ZL, low(0x300<<1)
LPM R16, Z+
LPM R17, Z+
LPM R18, Z+
in r21, PINB
ANDI R21, 0b00000111
CPI R21, 0
BREQ valor1
CPI R21, 1
BREQ valor2
valor3:
STS 0x100, r18
rjmp cc
valor1:
STS 0x100, r16
rjmp cc
valor2:
STS 0x100, r17
rjmp cc
cc:
LDS r16, 0x100; valor de referencia
LDS r17, 0x63; valor medido
CP R17, R16
BREQ display2
salirComp:
ret
display2:
LDI ZH, high(0x400<<1)
LDI ZL, low(0x400<<1)
SUBI ZL,-12; L
LPM R16, Z+
STS 0X60, R16
LPM R16, Z+; P
STS 0X61, R16
SBI PORTB, 7
rjmp salirComp 






RFSH: IN R20,SREG
      PUSH R20

  LD R0,x+
  OUT PORTC,R0        ;saca caracter 7s
  IN R20,PORTB
  ORI R20,0x0f        ;enmacarar 4MSB
  AND R20,R25       
  OUT PORTB,R20       ;sacar codigo de barrido(PB0-PB3)
  SEC                 ;C=1 para rotaci?
  ROL R25
  DEC R24
  BRNE salir
      LDI XL,0x60         ; puntero a ram de display
  LDI XH,0
  LDI R24,4           ; contador de l?paras
  LDI R25,0b11111110  ; c?igo de barrido

salir:POP R20
      OUT SREG,R20
	  RETI
