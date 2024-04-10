PROCESSOR 18F8722

#include <xc.inc>

; CONFIGURATION (DO NOT EDIT)
; CONFIG1H
CONFIG OSC = HSPLL      ; Oscillator Selection bits (HS oscillator, PLL enabled (Clock Frequency = 4 x FOSC1))
CONFIG FCMEN = OFF      ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
CONFIG IESO = OFF       ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)
; CONFIG2L
CONFIG PWRT = OFF       ; Power-up Timer Enable bit (PWRT disabled)
CONFIG BOREN = OFF      ; Brown-out Reset Enable bits (Brown-out Reset disabled in hardware and software)
; CONFIG2H
CONFIG WDT = OFF        ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
; CONFIG3H
CONFIG LPT1OSC = OFF    ; Low-Power Timer1 Oscillator Enable bit (Timer1 configured for higher power operation)
CONFIG MCLRE = ON       ; MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled)
; CONFIG4L
CONFIG LVP = OFF        ; Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)
CONFIG XINST = OFF      ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))
CONFIG DEBUG = OFF      ; Disable In-Circuit Debugger


GLOBAL var1
GLOBAL var2
GLOBAL var3
GLOBAL buttonLastState
GLOBAL barEnabled
GLOBAL actionSpecifier
; Define space for the variables in RAM
PSECT udata_acs
var1:
    DS 1 ; Allocate 1 byte for var1
var2:
    DS 1 
var3:
    DS 1
buttonLastState:
    DS 1
barEnabled:
    DS 1
actionSpecifier:
    DS 1


PSECT resetVec,class=CODE,reloc=2
resetVec:
    goto       main
PSECT CODE
main:
    call initialize
    
    movlw 00011110B
    movwf var1
    movlw 11111111B	
    movwf var2
    
    round_robin:
		
		DECF var2
		TSTFSZ var2
		INCF var1
		DECF var1
	    
		call check_buttons    
		
		SETF actionSpecifier
		TSTFSZ var1
		CLRF actionSpecifier
		TSTFSZ var2
		CLRF actionSpecifier
		
		
		TSTFSZ actionSpecifier
		BTG LATD,0
		
		
		call handleBarB
		call handleBarC
		
		TSTFSZ actionSpecifier
		movlw 00011110B
		TSTFSZ actionSpecifier
		movwf var1
		
		TSTFSZ actionSpecifier
		movlw 11111111B
		TSTFSZ actionSpecifier
		movwf var2
		
    goto round_robin
    
goto main   ; Jump to the label main 


initialize:
    movlw 00000000B
    movwf TRISB
    movwf TRISC
    movwf TRISD
    movlw 11111111B
    movwf LATB
    movwf LATC
    movwf LATD
    
    ;working register is already 11111111, so no need to set
    movwf TRISE   
    
    
    
    call wait_initial
    movlw 00000000B
    movwf LATB
    movwf LATC
    movwf LATD
    movwf barEnabled
    movwf buttonLastState
    return
wait_initial:
    movlw 00000100B
    movwf var1
    wait_loop_1:
    
	movlw 11110101B
	movwf var2
	wait_loop_2:
	    
	    movlw 11111110B
	    movwf var3
	    wait_loop_3:
	
    
	    DECF var3
	    BZ wait_exit_loop_3
	    goto wait_loop_3
	    wait_exit_loop_3:
	
	DECF var2
	BZ wait_exit_loop_2
	goto wait_loop_2
	wait_exit_loop_2:
	
    DECF var1
    BZ wait_exit_loop_1
    goto wait_loop_1
    wait_exit_loop_1:

    return
    

check_buttons:
    movff PORTE , WREG
    xorwf buttonLastState, 0
    
    BTFSC WREG,0
    bra button0changed
    nop
    nop
    nop
    post_b0:
    

    BTFSC WREG,1
    bra button1changed
    nop
    nop
    nop
    post_b1:
    movff PORTE, buttonLastState
    return

    button0changed:
    BTFSC buttonLastState,0
    BTG barEnabled,0
    goto post_b0
    
    button1changed:
    BTFSC buttonLastState,1
    BTG barEnabled,1
    goto post_b1
    


handleBarC:                   
    TSTFSZ actionSpecifier     
    goto actionC             
    
    nop
    nop
    nop
    nop
    nop
    nop
    
    return                    
    
    actionC:                  
    
    BTFSS barEnabled , 0                  
    bra setupBarC_v1
    BTFSC PORTC , 0
    bra setupBarC_v2
    
    
    
    rrncf PORTC, 0
    BSF WREG , 7
    movwf LATC
	return
    
    setupBarC_v1:
    nop
    nop
    nop
    
    nop
    nop
    movlw 00000000B
    TSTFSZ PORTC;experiment
    movff WREG, LATC
	return
    setupBarC_v2:
    nop
    nop
    nop
    
    movlw 00000000B
    TSTFSZ PORTC;experiment
    movff WREG, LATC
	return
    
    

handleBarB:                   
    TSTFSZ actionSpecifier     
    goto actionB             
    
    nop
    nop
    nop
    nop
    nop
    nop
    
    return                    
    
    actionB:                  
    
    BTFSS barEnabled , 1                  
    goto setupBarB_v1
    BTFSC PORTB , 7
    bra setupBarB_v2
    
    
    rlncf PORTB, 0
    BSF WREG , 0
    movwf LATB
	return
    
    setupBarB_v1:
    nop
    nop
    nop
    
    nop
    nop
    movlw 00000000B
    TSTFSZ PORTB;experiment
    movwf LATB
	return
    setupBarB_v2:
    nop
    nop
    nop
    
    movlw 00000000B
    TSTFSZ PORTB;experiment
    movwf LATB
	return
    

    
    


end resetVec
