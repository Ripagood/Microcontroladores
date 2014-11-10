.include "m16def.inc"
;***** Subroutine Register Variables

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
SBIC PIND,2
rjmp proceso1
proceso2:
CLR R16
STS 0x100, R16
LDI R16, 2; proceso en el primer display
STS 0X60, R16
rjmp salirProceso
proceso1:
SER R16
STS 0X100, R16
LDI R16, 1
STS 0X60, R16
salirProceso:
reti

MAS:
LDS R16, 0X100
CPI R16, 0XFF
BREQ cambiaProceso1
cambiaProceso2:
LDS R16, 0X102; direccion de RAM del duty cycle de proceso2
INC R16
CPI R16, 30
BRSH mantiene
STS 0x102, R16
rjmp salirMAS
mantiene:
LDI R16, 30
STS 0X102, R16
rjmp salirMAS
salirMAS:
call muestraVol
reti
cambiaProceso1:
LDS R16, 0x101; direccion de RAM del duty cycle de proceso1
INC R16
CPI R16, 30
BRSH mantiene1
STS 0x101, r16
rjmp salirMAS
mantiene1:
LDI R16, 30
STS 0x101, R16
rjmp salirMAS

MENOS:
LDS R16, 0X100;checamos que proceso esta activo
CPI R16, 0xFF
BREQ menosProceso1
menosProceso2:
LDS R16, 0X102
CPI R16, 0
BREQ salirMENOS
DEC R16
STS 0X102, R16
salirMENOS:
call muestraVol
salida:
reti
menosProceso1:
LDS R16, 0X101
CPI R16, 0
BREQ salida; si ya es 0, no hacer nada
DEC R16; sino , decrementa y guarda el valor
STS 0X101, R16
RJMP salirMenos



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
	  

//Int 0,1,2
//INT0 cualquier cambio, INT1 y 2 por falling edge
LDI R16, 0b00001001
OUT MCUCR, R16
//INT2 por falling edge
LDI R16, 0b11100000
OUT GICR, R16
SBI PORTD, 2;int0
SBI PORTD, 3;int1
SBI PORTB, 2;int2
//USART
;habilita transmision
LDI R16, (1<<TXEN)
OUT UCSRB, R16
;8 bits, 1 bit de parada , sin paridad
LDI R16, (1<<UCSZ1)|(1<<UCSZ0)|(1<<URSEL)
OUT UCSRC, R16
LDI R16, 0x33
OUT UBRRL, R16; 9600 baudios


 //Iniciamos todos en cero
LDI R16, 0
STS 0X100, R16//proceso a seleccionar
STS 0X101, R16//proceso1
STS 0X102, R16//proceso2


LDI R16, 0x03
OUT DDRA, R16
;SALIDAS seleccion vol

sei
FIN:
nop
nop
nop
 jmp FIN


muestraVol:
LDS R16, 0x100
CPI R16, 0XFF
BREQ process1
process2:
LDS R16, 0X102
call BIN_BCD_1; bcd en R18:17
STS 0x61, R18
STS 0x62, R17
SBI PORTA,1
call transmite
CBI PORTA,1
ret
process1:
LDS R16, 0x101
call BIN_BCD_1
STS 0x61, R18
STS 0x62, R17
SBI PORTA,0
call transmite
CBI PORTA,0
ret


transmite:
SWAP R18
ADD R17, R18
call transmit
ret

transmit:
SBIS UCSRA, UDRE
RJMP transmit
OUT UDR, R17
RET


BIN_BCD_1:
//Binario en R16, BCD R18:R17 ;BCD menor o igual a 99
CLR R18;mantiene el valor binario en r16
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
