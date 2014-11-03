.include "m16def.inc"

  .org 0
  JMP main
  .org 0x02
  JMP INTERRUPCION_0
  .org 0x04
  JMP INTERRUPCION_1
  .org 0x06
  JMP TIMER2_COMP
  .org 0x26
  JMP RFSH

INTERRUPCION_0:
;detiene el conteo
IN R16, TIMSK
CBR R16, (1<<OCIE2)
OUT TIMSK, R16
IN R16, TCCR2
CBR R16, (1<<CS22)|(1<<CS21)|(1<<CS20)
out TCCR2, R16
reti

INTERRUPCION_1:
LDI R16, 0
STS 0X60, R16
STS 0X61, R16
STS 0X62, R16
STS 0X63, R16
reti

TIMER2_COMP:
LDS r16, 0x60
LDS r17, 0x61
LDS r18, 0x62
LDS r19, 0x63

inc r16
cpi r16, 10
breq resetr16
rjmp salirTimer
resetr16:
ldi r16,0
inc r17
cpi r17, 10
breq resetr17
rjmp salirTimer
resetr17:
ldi r17,0
inc r18
cpi r18, 10
breq resetr18
rjmp salirTimer
resetr18:
ldi r18,0
INC R19
cpi r19,10
breq resetr19
rjmp salirTimer
resetr19:
ldi r19,0
salirTimer:
STS 0X60, R16
STS 0x61, r17
STS 0x62, r18
STS 0x63, r19
reti


main: ldi r16,low(RAMEND)
      out SPL,r16
      ldi r16,high(RAMEND)
      out SPH,r16	     ;init Stack Pointer
//7 segmentos
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
//Timer 2 a 10ms
	LDI R16, 76
	OUT OCR2, R16


//Interrupcion 0 y 1
LDI R16, 0b00001000
OUT MCUCR, R16
LDI R16, 0b11000000
OUT GICR, R16
SBI PORTD, 3; pull up

SBI PORTB, 0; pull up tecla start

sei


inicio:

polling:; Espera a que se presione la tecla de inicio
	SBIC PINB, 0
	rjmp polling
	call retardo10ms
	SBIC PINB, 0
	rjmp polling1
polling1:
	SBIS PINB,0
	rjmp polling1
	call retardo10ms
	rjmp continua
continua:

;habilita interrupcion 10ms Timer2
LDI R16, (1<<WGM21)|(1<<CS22)|(1<<CS21)|(1<<CS20)
out TCCR2, R16
IN r16, TIMSK
SBR R16, (1<<OCIE2)
OUT TIMSK , R16
rjmp inicio












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
