; Rutina de RFSH de 4 display 7 seg anodo comun
;usa timer 0, int cada 5ms por compare con OCR0
;RAM de display a partir de 60h, X: puntero a RAM de display
;R24 contador de lamparas, R25 c?igo de barrido

.include "m16def.inc"
.def BIN_LSB=R22
.def BIN_MSB=R23

  .org 0
  JMP main
  .org 0x06
  JMP ms10
  .org 0x26
  JMP RFSH

ms10:;entramos aqui cada 10ms
IN R20, SREG
push R20
push R16

LDS R16, 0x101
dec R16
STS 0x101, R16
brne exit
;entramos aqui cada 100ms
LDI R16, 10
STS 0x101, R16; restaura el contador


call convierte; regresa los valores en R17:16
MOV R17, BIN_MSB
MOV R16, BIN_LSB
call BIN_BCD

exit:
pop r16
pop r20
OUT SREG, R20
reti


main: ldi r16,low(RAMEND)
      out SPL,r16
      ldi r16,high(RAMEND)
      out SPH,r16	     ;init Stack Pointer

	  LDI R16,0xff
	  OUT DDRC,R16        ;pto c como salida
	  
	  LDI R16,2
	  OUT TIMSK,R16       ;Hab. int timer 0
	  
	  LDI R16,38          ;cte de tiempo con prescaler=1024
	  OUT OCR0,R16

	  LDI R16,0xD         ;modo CTC, presacaler 1024
	  OUT TCCR0,R16

	  LDI XL,0x60         ; puntero a ram de display
	  LDI XH,0
	  LDI R24,4           ; contador de l?paras
	  LDI R25,0b11101111  ; c?igo de barrido

	  LDI R16,0
	  STS 0x60,R16
	  STS 0x61,R16
	  STS 0x62,R16
	  STS 0x63,R16
	  SEI

//ADC
	ldi r16, 0b00000000//5V en AREF, justificado a la derecha, canal0
	out ADMUX, R16
	ldi r16, 0b10000111//enable al adc, clk/128
	out ADCSRA, R16
	call convierte //primera conversion

//Timer2 10ms

	ldi r16, 78
	out OCR2, R16
	ldi r16, (1<<WGM21)|(1<<CS22)|(1<<CS21)|(1<<CS20);1024, CTC
	OUT TCCR2, R16
	in R16, TIMSK
	SBR R16, (1<<OCIE2)
	OUT TIMSK, R16

	LDI R16, 10; veces a entrar en a interrupcion de 10ms
	STS 0x101, r16

//Leds 
LDI R16, 0xF0; PB0_3 switches, PB4_7 leds
OUT DDRB, R16
ldi R16, 0x0F
OUT PORTB, R16; pull up de los switches

inicio:
IN R16, PINB
ANDI R16, 0x0F
CPI R16, 0
BREQ canal0
CPI R16, 1
BREQ canal1
CPI R16, 2
BREQ canal2
canal3:
;STS 0x100, R16; direccion del canal a leer


LDI R16, 0b00000011
OUT ADMUX, R16

SBI PORTB,7
CBI PORTB,6
CBI PORTB,5
CBI PORTB,4
rjmp inicio
canal2:
;STS 0x100, R16; direccion del canal a leer

LDI R16, 0b00000010
OUT ADMUX, R16
CBI PORTB,7
SBI PORTB,6
CBI PORTB,5
CBI PORTB,4
rjmp inicio
canal1:
;STS 0x100, R16; direccion del canal a leer
LDI R16, 0b00000001
OUT ADMUX, R16
CBI PORTB,7
CBI PORTB,6
SBI PORTB,5
CBI PORTB,4
rjmp inicio
canal0:
;STS 0x100, R16; direccion del canal a leer
LDI R16, 0b00000000
OUT ADMUX, R16
CBI PORTB,7
CBI PORTB,6
CBI PORTB,5
SBI PORTB,4
rjmp inicio

convierte:
SBIS ADCSRA, ADIF
rjmp convierte
SBI ADCSRA, ADIF; limpia bandera
IN R17, ADCH
IN R16, ADCL
RET




RFSH: IN R20,SREG
      PUSH R20

	  LD R0,x+
	  MOV R20,R25
	  ANDI R20,0xF0
	  ADD R0,R20
	  OUT PORTC,R0
	  ROL R25
	  DEC R24
	  BRNE salir
      LDI XL,0x60         ; puntero a ram de display
	  LDI XH,0
	  LDI R24,4           ; contador de l?paras
	  LDI R25,0b11101111  ; c?igo de barrido

salir:POP R20
      OUT SREG,R20
	  RETI


BIN_BCD: CLR R16
         STS 0x60,R16
	     STS 0x61,R16
	     STS 0x62,R16
	     STS 0x63,R16

    otro:CPI BIN_LSB,0
		 BRNE INC_BCD
		 CPI BIN_MSB,0
		 BRNE INC_BCD
		 RET

  INC_BCD:LDI R17,0
	      LDI YL,0x63
	      LDI YH,0

   ciclo: LD R20,Y
       inc R20
	   ST Y,R20
	   CPI R20,10
	   BRNE DEC_BIN
	   ST Y,R17
	   DEC YL
	   CPI YL,0x5F
	   BRNE ciclo

DEC_BIN:DEC BIN_LSB
        CPI BIN_LSB,0xFF
		BRNE otro
		DEC BIN_MSB
		RJMP otro
