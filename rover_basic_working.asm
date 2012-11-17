#INCLUDE <P16F877a.inc>

#DEFINE BANK0 BCF STATUS,RP0
#DEFINE BANK1 BSF STATUS,RP0

#DEFINE MOTOR_L_DOWN BCF PORTD,7
#DEFINE MOTOR_L_UP BSF PORTD,7
#DEFINE MOTOR_R_DOWN BCF PORTD,4
#DEFINE MOTOR_R_UP BSF PORTD,4

#DEFINE INFRARED_PORT PORTB

;IN�CIO
ORG 0x00
GOTO INICIO

;�REA PARA INTERRUP��ES
ORG 0x04
 AUX
RETFIE


  ;DECLARAR VARI�VEIS 
  CBLOCK 0x20

  ENDC

INICIO
   ;CONFIGURAR PORTAS
   BANK1
   MOVLW B'00000000'
   MOVWF TRISA
   MOVLW B'00001110' ;B1, B2 and B3 connected to infrared sensors
   MOVWF TRISB
   MOVLW B'00000000'
   MOVWF TRISC
   MOVLW B'00000000' ;D4 and D7 connected to motors
   MOVWF TRISD
   MOVLW B'00000000'
   MOVWF TRISE

   MOVLW B'00000000'
   MOVWF OPTION_REG
   MOVLW B'00000000'
   MOVWF INTCON
   BANK0


  ; PROGRAMA PRINCIPAL
MAIN:
    MOVFW INFRARED_PORT
    MOVWF AUX
    RRF AUX               ;roll 1 time because the first port of infrared is 1
    MOVFW AUX
    ADDWF PCL,F
    GOTO OUT_OF_TAPE      ;000
    GOTO TURN_RIGHT       ;001
    GOTO STRAIGHT         ;010
    GOTO TURN_RIGHT       ;011
    GOTO TURN_LEFT        ;100
    GOTO UNDEF            ;101
    GOTO TURN_LEFT        ;110
    GOTO UNDEF            ;111

UNDEF:
OUT_OF_TAPE:
STRAIGHT:
    MOTOR_L_UP
    MOTOR_R_UP
    GOTO MAIN

TURN_LEFT:
    MOTOR_L_DOWN
    MOTOR_R_UP
    GOTO MAIN

TURN_RIGHT:
    MOTOR_L_UP
    MOTOR_R_DOWN
    GOTO MAIN

END
