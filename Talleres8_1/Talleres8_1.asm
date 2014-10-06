.include "m16def.inc"


LDI R16, high(RAMEND)
OUT SPH, R16
LDI R16, low(RAMEND)
OUT SPL, R16


//Ejercicio 3

SBI DDRB, 2// Valvula entrada
SBI DDRB, 3// Valvula de salida

SBI PORTB, 0//pull up del switch


wait: //espera por el switch
SBIC PINB,0
rjmp wait

LDI XH, high(0x60)//puntero   RAM
LDI XL, low(0x60)

SBIC PINB, 1
rjmp load100
load101:
LDI ZH, high(0x101<<1)//seleccion referencia
LDI ZL, low(0x101<<1)
LPM R19, Z
rjmp cc
load100:
LDI ZH, high(0x100<<1)
LDI ZL, low(0x100<<1)
LPM R19, Z
cc:


LDI R20, 100
LDI R21, 10 //1000 veces

otro10:
LDI R20, 100
otro100:
IN R16, PINA
ST X+, R16

call chequeo //ve las valvulas
//call retardo5s

SBIC PINB,0
rjmp wait

dec r20
BRNE otro100
DEC R21
brne otro10


RJMP WAIT



//Ejercicio 4
Ejercicio4:
LDI R16, 0xFF 
OUT DDRA , R16 //salida 8 bits

SBI DDRB, 2 //led
SBI DDRB, 3 // valvula
SBI PORTB, 3 //apaga la valvula


polling:; Espera a que se presione la tecla de inicio
    SBIC PINB, 0
    rjmp polling
    call retardo10ms
    SBIC PINB, 0
    rjmp polling
polling1:
    SBIS PINB,0
    rjmp polling1
    call retardo10ms
    rjmp continua
continua:


CBI PORTB, 2 //apaga el led

LDI R19, 3 // maximas repeticiones



call manda //manda 2000 muestras

validacion:
SBIC PINB, 1
rjmp mandaOtro
cbi portb, 3
RJMP ejercicio4


mandaOtro:
LDI R16, 0b01111110
OUT PORTA, R16
call manda
LDI R16, 0b10000001
OUT PORTA, R16
DEC R19
brne led
rjmp validacion



LED:
SBI PORTB, 2
rjmp ejercicio4





manda: //2000 veces desde 
LDI ZH, high(0x1000<<1)
LDI ZL, low(0x1000<<1)
ldi r20, 200
ldi r21, 10
otro100_2:
ldi r20, 200
otro200:
LPM r16, Z+
OUT PORTA, R16
call retardo500ms
DEC r20
BRNE otro200
DEC R21
brne otro100_2
ret


retardo500ms:
push r20
ldi r20, 5
otro500ms:
call retardo100ms
dec r20
brne otro500ms
pop r20
ret



chequeo:
CP R16, R19
BRSH abreSalida
abreEntrada:
CBI PORTB, 2//abre entrada
SBI PORTB, 3//cierra Salida
ret
abreSalida:
CBI PORTB, 3//abre salida
SBI PORTB, 2//cierra entrada
ret




retardo100ms:
push r20
LDI R20, 10
otro100ms:
call retardo10ms
DEC R20
BRNE otro100ms
pop r20
ret

retardo1s:
push r20
LDI R20, 10
otro1s:
call retardo100ms
DEC R20
BRNE otro1s
pop r20
ret

retardo5s:
push r20
LDI R20,5
otro5s:
call retardo1s
dec r20
brne otro5s
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


.org 0x100
.db 0x80, 0x00, 0x01,0x00



