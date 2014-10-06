.include "m16def.inc"
LDI R16, high(RAMEND)
OUT SPH, R16
LDI R16, low(RAMEND)
OUT SPL, R16

SBI PORTB,0

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


LDI XH, high(0x100)
LDI XL, low(0x100)
LDI R20,5
LDI R21,2

otro50:
ldi r21,10
otro10:
IN R16, PINA
ST X+, R16
//call retardo2s
dec r21
brne otro10
dec r20
brne otro50

SBI DDRB,2
SBI DDRD,3 //tren de pulsos
SBI PORTB,2 //led de aviso

espera:
SBIC PINB,1
call pulso
SBIC PINB,1
rjmp espera
CBI PORTB,2

fin1: rjmp fin1


//ejercicio 2
inicio2:
SBI DDRB, 3
SBI DDRB, 4
SBI PORTB, 3 //SENAL ACTIVA EN 0




polling3:; Espera a que se presione la tecla de inicio PB0
    SBIC PINB, 0
    rjmp polling3
    call retardo10ms
    SBIC PINB, 0
    rjmp polling31
polling31:
    SBIS PINB,0
    rjmp polling31
    call retardo10ms
    rjmp continua3

continua3:

LDI XH, HIGH(0X100)
LDI XL, LOW(0X100)
LDI R19, 250


otro250:
call retardo2s
IN R16, PINA
ST X+, R16
dec r19 
brne otro250

SBI DDRB,2
SBI PORTB,2//LED DE AVISO


polling2:; Espera a que se presione la tecla de VALIDACION PB1
    SBIC PINB, 1
    rjmp polling2
    call retardo10ms
    SBIC PINB, 1
    rjmp polling21
polling21:
    SBIS PINB,1
    rjmp polling21
    call retardo10ms
    rjmp continua2

continua2:


LDI XH, HIGH(0X100)
LDI XL, LOW(0X100)
LDI R19, 250
LDI R17, 0
ldi ZH, high(0x200<<1)
LDI ZL, low(0x200<<1)
LPM R18, Z

compara:
LD R16, X+
CP R16, R18
BRSH mayor
dec r19//no es mayor
brne compara
rjmp finC
mayor:
inc r17
dec r19
brne compara
finC://fin de la comparacion

CP R17,R19
BRSH signal50ms
SBI PORTB,4
call retardo2s//buzzer
CBI PORTB,4
rjmp inicio2
signal50ms:
CBI PORTB,3
call retardo10ms
SBI PORTB,3
RJMP inicio2











pulso:
cbi PORTB,3
call retardo200ms
sbi PORTB,3
call retardo300ms
ret


retardo200ms:
push r20
ldi r20, 20
otro200:
call retardo10ms
dec r20
brne otro200
pop r20
ret


retardo300ms:
push r20
ldi r20, 30
otro300:
call retardo10ms
dec r20
brne otro300
pop r20
ret

retardo2s:
call retardo1s
call retardo1s
ret

retardo1s:
push r20
ldi r20,5
otro1s:
call retardo200ms
dec r20
brne otro1s
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


.ORG 0x200
.db 0x80, 0x00
