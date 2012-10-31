#INCLUDE <P16F877a.inc>
;#INCLUDE <P16F877A.INC> //linux

#DEFINE BANK0 BCF STATUS,RP0
#DEFINE BANK1 BSF STATUS,RP0

#DEFINE INFRARED_PORT PORTB

;3/5 of full velocity
#DEFINE PWM_HIGH .102
#DEFINE PWM_LOW .153

#DEFINE MOTOR_PORT PORTD
#DEFINE TURN_LEFT_VALUE  B'10000000'
#DEFINE TURN_RIGHT_VALUE B'00010000'
#DEFINE STRAIGHT_VALUE   B'10010000'

;bits of flag
#DEFINE VELOCITY_FLAG_BIT 1
#DEFINE TIME_UP_DOWN_BIT 0

#DEFINE INTCON_SETUP B'10101000'

;IN�CIO
ORG 0x00
GOTO INICIO

;�REA PARA INTERRUP��ES
ORG 0x04
   BTFSS INTCON,2 ;is a timer interruption?
   GOTO INFRARED_INT
   GOTO TIMER_INT

;timer int
TIMER_INT:
    BTFSS FLAG,VELOCITY_FLAG_BIT
    GOTO NOT_FULL_VELOCITY
    MOVLW PWM_HIGH
    MOVWF TMR0
    GOTO RECONF_INT

NOT_FULL_VELOCITY:
    XORWF MOTOR_OUTPUT 
    MOVWF MOTOR_PORT ;TOGGLE
    BTFSS FLAG,TIME_UP_DOWN_BIT
    GOTO TIME_UP
    GOTO TIME_DOWN

TIME_UP:
    BSF FLAG,TIME_UP_DOWN_BIT
    MOVLW PWM_HIGH
    MOVWF TMR0
    GOTO RECONF_INT

TIME_DOWN:
    BCF FLAG,TIME_UP_DOWN_BIT
    MOVLW PWM_LOW
    MOVWF TMR0
    GOTO RECONF_INT

;gpio int
INFRARED_INT:
   BSF FLAG,TIME_UP_DOWN_BIT ;next timer interruption TMR0 = PWM_LOW
   MOVLW PWM_HIGH
   MOVWF TMR0

   MOVFW INFRARED_PORT
   MOVWF AUX
   RRF AUX               ;roll 1 time because the first port of infrared is 1
   MOVFW AUX
   ADDWF PCL,F
   GOTO OUT_OF_TAPE      ;000
   GOTO TURN_RIGHT       ;001
   GOTO STRAIGHT         ;010
   GOTO TURN_RIGHT_FULL  ;011
   GOTO TURN_LEFT        ;100
   GOTO UNDEF            ;101
   GOTO TURN_LEFT_FULL   ;110
   GOTO UNDEF            ;111

UNDEF:
OUT_OF_TAPE:
STRAIGHT:
   MOVLW STRAIGHT_VALUE
   MOVWF MOTOR_PORT
   MOVWF MOTOR_OUTPUT
   BSF FLAG,VELOCITY_FLAG_BIT ;full velocity
   GOTO RECONF_INT

TURN_LEFT_FULL:
   MOVLW TURN_LEFT_VALUE
   MOVWF MOTOR_PORT
   MOVWF MOTOR_OUTPUT
   BSF FLAG,VELOCITY_FLAG_BIT ;full velocity
   GOTO RECONF_INT

TURN_RIGHT_FULL:
   MOVLW TURN_RIGHT_VALUE
   MOVWF MOTOR_PORT
   MOVWF MOTOR_OUTPUT
   BSF FLAG,VELOCITY_FLAG_BIT ;full velocity
   GOTO RECONF_INT

TURN_LEFT:
   MOVLW TURN_LEFT_VALUE
   MOVWF MOTOR_PORT
   MOVWF MOTOR_OUTPUT
   BCF FLAG,VELOCITY_FLAG_BIT ;not full velocity
   GOTO RECONF_INT

TURN_RIGHT:
   MOVLW TURN_RIGHT_VALUE
   MOVWF MOTOR_PORT
   MOVWF MOTOR_OUTPUT
   BCF FLAG,VELOCITY_FLAG_BIT ;not full velocity
   GOTO RECONF_INT

;reconf all ints
RECONF_INT:
    BANK1
    MOVLW INTCON_SETUP
    MOVWF INTCON
    BANK0
RETFIE

;DECLARAR VARI�VEIS 
CBLOCK 0x20
   AUX
   MOTOR_OUTPUT
   ; BIT0 = {0 = time up, 1 = time down}
   ; BIT1 = 1 full velocity
   FLAG
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
   MOVLW INTCON_SETUP
   MOVWF INTCON
   BANK0

   MOVLW STRAIGHT_VALUE
   MOVWF MOTOR_PORT
   MOVWF MOTOR_OUTPUT
   MOVLW PWM_HIGH
   MOVWF TMR0
   MOVLW .0
   MOVWF FLAG
   BSF FLAG,TIME_UP_DOWN_BIT

; PROGRAMA PRINCIPAL
MAIN:
   NOP
   GOTO MAIN
END
