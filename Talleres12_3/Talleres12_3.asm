.include "m16def.inc"
.def	drem16uL=r14
.def	drem16uH=r15
.def	dres16uL=r16
.def	dres16uH=r17
.def	dd16uL	=r16
.def	dd16uH	=r17
.def	dv16uL	=r18
.def	dv16uH	=r19
.def	dcnt16u	=r20


  .org 0
  JMP main
  .org 0x02;int 0
  JMP PROCESO
  .org 0x04; int 1
  JMP MAS
  .org 0x24; int 2
  JMP MENOS
  .org 0x26
  JMP RFSH

PROCESO:
SBIS PIND, 2
rjmp proceso2
proceso1:
LDI R16, 0xFF
STS 0x100, R16
LDI R16, 1
STS 0x60, R16; muestra el proceso en el disp
reti
proceso2:
LDI R16, 0x00
STS 0x100, R16
LDI R16, 2
STS 0x60, r16
RETI

MAS:
LDS R16, 0x100
CPI R16, 0XFF
BREQ masProceso1
masProceso2:
LDS R16, 0x102; direccion del duty en ms de proceso2
INC R16
CPI R16, 50
brsh mantiene
STS 0x102, r16
rjmp salirMAS
mantiene:
LDI R16, 50
STS 0X102, R16
salirMAS:
call  calcDuty
call muestraDuty
RETI
masProceso1:
LDS R16, 0x101; direccion del duty en ms de proceso2
INC R16
CPI R16, 50
brsh mantiene2
STS 0x101, r16
rjmp salirMAS
mantiene2:
LDI R16, 50
STS 0X101, R16
rjmp salirMAS

MENOS:
LDS R16, 0x100
CPI R16, 0xFF
BREQ menosProceso1
menosProceso2:
LDS r16, 0x102
CPI R16, 1
BRLO hold
DEC R16
STS 0x102, R16
rjmp salirMenos
hold:
LDI R16, 0
STS 0x102, r16
rjmp salirMenos
salirMenos:
call calcDuty
call muestraDuty
reti
menosProceso1:
LDS r16, 0x101
CPI R16, 1
BRLO hold1
DEC R16
STS 0x101, R16
rjmp salirMenos
hold1:
LDI R16, 0
STS 0x101, r16
rjmp salirMenos




main: ldi r16,low(RAMEND)
      out SPL,r16
      ldi r16,high(RAMEND)
      out SPH,r16	     ;init Stack Pointer

	  LDI R16,0xff
	  OUT DDRC,R16        ;pto c como salida
	  
	  LDI R16,2
	  OUT TIMSK,R16       ;Hab. int timer 0
	  
	  LDI R16,52          ;cte de tiempo con prescaler=1024
	  OUT OCR0,R16

	  LDI R16,0xD         ;modo CTC, presacaler 1024
	  OUT TCCR0,R16

	  LDI XL,0x60         ; puntero a ram de display
	  LDI XH,0
	  LDI R24,3           ; contador de l?paras
	  LDI R25,0b11101111  ; c?igo de barrido

	  LDI R16,0
	  STS 0x60,R16
	  STS 0x61,R16
	  STS 0x62,R16
	  STS 0x63,R16

//Interrupciones

LDI R16, 0b00001001
OUT MCUCR, R16 ; INT 0 por toggle, INT1 por 
;falling edge
LDI R16, 0b11100000
OUT GICR, R16

SBI PORTD, 2
SBI PORTD, 3
SBI PORTB, 2 ;int 2

//Timer 1

LDI R16, high(390);periodo 50ms prescaler 1024
OUT ICR1H, R16
LDI R16, low(390)
OUT ICR1L, R16

LDI R16, (1<<WGM11)|(1<<COM1A1)|(1<<COM1B1)
OUT TCCR1A, R16

ldi r16, (1<<WGM13)|(1<<WGM12)|(1<<CS12)|(1<<CS10)
OUT TCCR1B, R16
; modo 14, salida A YB en modo no invertido
;prescaler 1024
SBI DDRD, 5; OC1A
SBI DDRD, 4; OC1B

SEI

CLR R16
STS 0x100, R16
STS 0x101, R16
STS 0x102, R16


fin :  rjmp fin

muestraDuty:
LDS R16, 0x100
CPI R16, 0xFF
BREQ proceso1M
proceso2M:
LDS R16, 0x102
call BIN_BCD_1
STS 0x61, R18
STS 0x62, R17
ret
proceso1M:
LDS R16, 0x101
call BIN_BCD_1
STS 0x61, R18
STS 0x62, R17
ret


BIN_BCD_1:
//Binario en R16, BCD R18:R17 ;BCD menor o igual a 99
CLR R18
CLR R17
CPI R16, 0
BREQ exit
push r16
inc r17
otro:
DEC R16 
BRNE incrementaR17
rjmp exit
incrementaR17:
INC R17
CPI R17, 10
BREQ incrementaR18
rjmp otro
incrementaR18:
CLR R17
INC R18
rjmp otro
exit:
pop r16
ret








calcDuty:
LDS R16, 0x100
CPI R16, 0xFF
breq DutyP1
DutyP2:
LDS R22, 0x102; duty proceso 2
CLR R23
LDI R21, high(390)
LDI R20, low(390)
call mul16x16_16; regresa en R17:16
MOV dd16uH, R17
MOV dd16uL, R16
LDI dv16uH, high(50)
LDI dv16uL, low(50)
call div16u
OUT OCR1BH, dres16uH
OUT OCR1BL, dres16uL
ret
DutyP1:
LDS R22, 0x101; duty proceso 1
CLR R23
LDI R21, high(390)
LDI R20, low(390)
call mul16x16_16; regresa en R17:16
MOV dd16uH, R17
MOV dd16uL, R16
LDI dv16uH, high(50)
LDI dv16uL, low(50)
call div16u
OUT OCR1AH, dres16uH
OUT OCR1AL, dres16uL
ret

div16u:
;* This subroutine divides the two 16-bit numbers 
;* "dd16uH:dd16uL" (dividend) and "dv16uH:dv16uL" (divisor). 
;* The result is placed in "dres16uH:dres16uL" and the remainder in
;* "drem16uH:drem16uL".

	clr	drem16uL	;clear remainder Low byte
	sub	drem16uH,drem16uH;clear remainder High byte and carry
	ldi	dcnt16u,17	;init loop counter
d16u_1:	rol	dd16uL		;shift left dividend
	rol	dd16uH
	dec	dcnt16u		;decrement counter
	brne	d16u_2		;if done
	ret			;    return
d16u_2:	rol	drem16uL	;shift dividend into remainder
	rol	drem16uH
	sub	drem16uL,dv16uL	;remainder = remainder - divisor
	sbc	drem16uH,dv16uH	;
	brcc	d16u_3		;if result negative
	add	drem16uL,dv16uL	;    restore remainder
	adc	drem16uH,dv16uH
	clc			;    clear carry to be shifted into result
	rjmp	d16u_1		;else
d16u_3:	sec			;    set carry to be shifted into result
	rjmp	d16u_1


mul16x16_16:
;* DECRIPTION
;*	Multiply of two 16bits numbers with 16bits result.
;* USAGE
;*	r17:r16 = r23:r22 * r21:r20
	mul	r22, r20		; al * bl
	movw	r17:r16, r1:r0
	mul	r23, r20		; ah * bl
	add	r17, r0
	mul	r21, r22		; bh * al
	add	r17, r0
	ret



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
