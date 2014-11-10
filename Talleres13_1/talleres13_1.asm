
.include "m16def.inc"
 .org 0
  JMP main
  .org 0x02;int 0
  JMP PROCESO
  .org 0x04; int 1
  JMP MAS

PROCESO:
reti

MAS:
reti



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

//ADC
LDI R16, 0b00000000;canal 0, AREF seleccionado
OUT ADMUX, R16
LDI R16, 0b10000111;enable y 128 de DIVISION
OUT ADCSRA, R16
SBI ADCSRA, ADSC; primera conversion
aq: SBIS ADCSRA, ADIF
rjmp aq
SBI ADCSRA, ADIF; limpia bandera

//USART
;1200 baudrate
LDI R16, high(415)
OUT UBRRH, R16
LDI R16, low(415)
OUT UBRRL, R16
;habilita transmision
LDI R16, (1<<TXEN)
OUT UCSRB, R16
;8 bits, 1 bit de parada , sin paridad
LDI R16, (1<<UCSZ1)|(1<<UCSZ0)|(1<<URSEL)
OUT UCSRC, R16
inicio:
call convierte
MOV R18, R16
call transmite
MOV R18,R17
call transmite
rjmp inicio



transmite:
SBIS UCSRA, UDRE
RJMP transmite
OUT UDR, R18
RET

convierte:
SBI ADCSRA, ADSC; comienza conversion
wait: SBIS ADCSRA, ADIF
rjmp wait
SBI ADCSRA, ADIF; limpia bandera
IN R16, ADCL
IN R17, ADCH
ret










