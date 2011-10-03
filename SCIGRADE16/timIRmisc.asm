; (not) Modified for 16 channels (Adam Ginsburg, August 28 2007)
; wait some
WAIT_SOME
   DO #200,END_WAIT_SOME      ; wait some for the read_array to finish
   NOP
END_WAIT_SOME  
   NOP
   RTS
DELAY1
   MOVE  #10000,X0   ; 100 microsec delay
   DO X0,END_DEL1
   NOP
END_DEL1
   RTS
; Write a number to an analog board over the serial link
WR_BIAS
   BSET  #3,X:PCRD   ; turn on the serial clock
   JSR   <PAL_DLY
   JSR   <XMIT_A_WORD
   JSR   <PAL_DLY
   BCLR  #3,X:PCRD
   JSR   <PAL_DLY
   RTS
; Clear all video processor analog switches to lower their power dissipation

POWER_OFF
   JSR   <CLEAR_SWITCHES_AND_DACS   ; Clear switches and DACs
   BSET  #LVEN,X:HDR 
   BSET  #HVEN,X:HDR 
   JMP   <FINISH

; Execute the power-on cycle, as a command
POWER_ON
   JSR   <CLEAR_SWITCHES_AND_DACS   ; Clear switches and DACs

; Turn on the low voltages (+/- 6.5V, +/- 16.5V) and then delay awhile
   BCLR  #LVEN,X:HDR          ; Set these signals to DSP outputs 
   MOVE  #10000000,X0
   DO      X0,*+3             ; Wait 100 millisec for settling
   NOP   

   JCLR  #PWROK,X:HDR,PWR_ERR ; Test if the power turned on properly
   JSR   <SET_BIASES          ; Turn on the DC bias supplies
   MOVE  #CONT_RST,R0         ; --> continuous readout state
   MOVE  R0,X:<IDL_ADR
   MOVE  #RESET_SERIAL,R0     ; Clear the Rockwell internal registers
   JSR   <CLOCK
   JMP   <FINISH

; The power failed to turn on because of an error on the power control board
PWR_ERR  BSET  #LVEN,X:HDR    ; Turn off the low voltage emable line
   BSET  #HVEN,X:HDR          ; Turn off the high voltage emable line
   JMP   <ERROR

; Set all the DC bias voltages and video processor offset values, reading
;   them from the 'DACS' table
SET_BIASES
   BSET  #3,X:PCRD            ; Turn on the serial clock
   BCLR  #1,X:<LATCH          ; Separate updates of clock driver
   BSET  #CDAC,X:<LATCH       ; Disable clearing of DACs
   BSET  #ENCK,X:<LATCH       ; Enable clock and DAC output switches
   MOVEP X:LATCH,Y:WRLATCH    ; Write it to the hardware
   JSR   <PAL_DLY             ; Delay for all this to happen

; Read DAC values from a table, and write them to the DACs
   MOVE  #DACS,R0             ; Get starting address of DAC values
   NOP
   NOP
   DO    Y:(R0)+,L_DAC        ; Repeat Y:(R0)+ times
   MOVE  Y:(R0)+,A            ; Read the table entry
   JSR   <XMIT_A_WORD         ; Transmit it to TIM-A-STD
   NOP
L_DAC

; Let the DAC voltages all ramp up before exiting
   MOVE  #400000,X0
   DO    X0,*+3               ; 4 millisec delay
   NOP
   BCLR  #3,X:PCRD            ; Turn the serial clock off
   RTS

SET_BIAS_VOLTAGES
   JSR   <SET_BIASES
   JMP   <FINISH

CLR_SWS  JSR   <CLEAR_SWITCHES_AND_DACS   ; Clear switches and DACs
   JMP   <FINISH

CLEAR_SWITCHES_AND_DACS
   BCLR  #CDAC,X:<LATCH       ; Clear all the DACs
   BCLR  #ENCK,X:<LATCH       ; Disable all the output switches
   MOVEP X:LATCH,Y:WRLATCH    ; Write it to the hardware
   BSET  #3,X:PCRD            ; Turn the serial clock on
   MOVE  #$0C3000,A           ; Value of integrate speed and gain switches
   CLR   B
   MOVE  #$100000,X0          ; Increment over board numbers for DAC writes
   MOVE  #$001000,X1          ; Increment over board numbers for WRSS writes
   DO    #15,L_VIDEO          ; Fifteen video processor boards maximum
   JSR   <XMIT_A_WORD         ; Transmit A to TIM-A-STD
   ADD   X0,A
   MOVE  B,Y:WRSS
   JSR   <PAL_DLY ; Delay for the serial data transmission
   ADD   X1,B
L_VIDEO  
   BCLR  #3,X:PCRD            ; Turn the serial clock off
   RTS

; Fast clear of FPA, executed as a command
CLEAR 
   JSR   <RESET_ARRAY
   NOP
   JMP   <FINISH

; Start the exposure timer and monitor its progress
EXPOSE   
   MOVEP #0,X:TLR0            ; Load 0 into counter timer
   MOVE  X:<EXPOSURE_TIME,B
   TST   B                    ; Special test for zero exposure time
   JEQ   <END_EXP             ; Don't even start an exposure
   SUB   #1,B                 ; Timer counts from X:TCPR0+1 to zero
   BSET  #TIM_BIT,X:TCSR0     ; Enable the timer #0
   MOVE  B,X:TCPR0
CHK_RCV  MOVE  #<COM_BUF,R3   ; The beginning of the command buffer
   JCLR  #EF,X:HDR,CHK_TIM    ; Simple test for fast execution
   JSR   <GET_RCV             ; Check for an incoming command
   JCS   <PRC_RCV             ; If command is received, go check it
CHK_TIM  JCLR  #TCF,X:TCSR0,CHK_RCV ; Wait for timer to equal compare value
END_EXP  BCLR  #TIM_BIT,X:TCSR0     ; Disable the timer
   JMP   (R7)                 ; This contains the return address


; Stop the exposure (set the timer status bit)
STOP_EXPOSURE
   BCLR  #TIM_BIT,X:TCSR0     ; Disable the DSP exposure timer
   BSET  #TRM,X:TCSR0         ; To be sure it will load TLR0
   MOVE  X:<EXPOSURE_TIME,B
   SUB   #100,B               ; set elapsed time to exp_time - 100 msec
   NOP
   MOVE  B,X:TCR0
   MOVEP X:TCR0,X:TLR0        ; Restore elapsed exposure time
   BSET  #TIM_BIT,X:TCSR0     ; Re-enable the DSP exposure timer
   JMP   <FINISH

; Start the exposure and initiate FPA readout
START_EXPOSURE
   MOVE  #$020102,B           ; Initialize the PCI image address
   JSR   <XMT_WRD
   MOVE  #'IIA',B
   JSR   <XMT_WRD
   
   MOVE  #TST_RCV,R0          ; Process commands, don't idle, 
   MOVE  R0,X:<IDL_ADR        ;    during the exposure
   MOVE  #L_SEX1,R7           ; Return address at end of exposure
   
; Clear the FPA and process commands from the host
   JSR    <RESET_ARRAY        ; Clear out the FPA 
                              ; (comment out to have non-destructive reads)

         
; test if CDS bit is set (MS 040609)
   JSSET #CDS_MODE,X:STATUS,RD_ARRAY

FOWLER
   DO Y:<NFS1,F1_END
   JSR   <RD_ARRAY
   JSR   <DELAY1
   NOP
F1_END   
   MOVE  #L_SEX1,R7           ; Return address at end of exposure
   DO Y:<NUTR,S_UTR
   JMP   <EXPOSE
L_SEX1   
   DO Y:<NFS,F2_END
   JSR   <RD_ARRAY
   JSR   <DELAY1
   NOP 
F2_END
   NOP
S_UTR
   NOP
   JMP   <START

; Set the desired exposure time
SET_EXPOSURE_TIME
   MOVE  X:(R3)+,Y0
   MOVE  Y0,X:EXPOSURE_TIME
   MOVEP X:EXPOSURE_TIME,X:TCPR0
   JMP   <FINISH

; Read the time remaining until the exposure ends
READ_EXPOSURE_TIME
   MOVE  X:TCR0,Y1            ; Read elapsed exposure time
   JMP   <FINISH1

; Pause the exposure - just stop the timer
PAUSE_EXPOSURE
   MOVEP X:TCR0,X:ELAPSED_TIME   ; Save the elapsed exposure time
   BCLR  #TIM_BIT,X:TCSR0        ; Disable the DSP exposure timer
   JMP   <FINISH

; Resume the exposure - just restart the timer
RESUME_EXPOSURE
   BSET  #TRM,X:TCSR0         ; To be sure it will load TLR0
   MOVEP X:TCR0,X:TLR0        ; Restore elapsed exposure time
   BSET  #TIM_BIT,X:TCSR0     ; Re-enable the DSP exposure timer
   JMP   <FINISH

; See if the command issued during readout is a 'ABR'. If not continue readout
CHK_ABORT_COMMAND
   MOVE  X:(R3)+,X0     ; Get candidate header
   MOVE  #$000202,A 
   CMP   X0,A
   JNE   <RD_CONT
WT_COM   JSR   <GET_RCV    ; Get the command
   JCC   <WT_COM
   MOVE  X:(R3)+,X0     ; Get candidate header
   MOVE  #'ABR',A 
   CMP   X0,A
   JEQ   <ABR_RDC
RD_CONT  MOVE  #<COM_BUF,R3      ; Continue reading out the FPA
   MOVE  R3,R4
   JMP   <CONTINUE_READ

; Special ending after abort command to send a 'DON' to the host computer
RDFPA_END_ABORT
   MOVE  #100000,X0
   DO      X0,*+3       ; Wait one millisec
   NOP
   JCLR  #IDLMODE,X:<STATUS,NO_IDL2 ; Don't idle after readout
   MOVE  #CONT_RST,R0
   MOVE  R0,X:<IDL_ADR
   JMP   <RDC_E2
NO_IDL2  MOVE  #TST_RCV,R0
   MOVE  R0,X:<IDL_ADR
RDC_E2   JSR   <WAIT_TO_FINISH_CLOCKING
   BCLR  #ST_RDC,X:<STATUS ; Set status to not reading out

   MOVE  #$000202,X0    ; Send 'DON' to the host computer
   MOVE  X0,X:<HEADER
   JMP   <FINISH

; Exit continuous readout mode
STP   MOVE  #TST_RCV,R0
   MOVE  R0,X:<IDL_ADR
   JMP   <FINISH

; Abort exposure - stop the timer and resume continuous readout mode
ABORT_EXPOSURE
   BCLR    #TIM_BIT,X:TCSR0   ; Disable the DSP exposure timer
   JSR   <RDA_END
   JMP   <START

; Generate a synthetic image by simply incrementing the pixel counts
SYNTHETIC_IMAGE
   CLR   A
   DO      Y:<NROWS,LPR_TST         ; Loop over each line readout
   DO      Y:<NCOLS,LSR_TST   ; Loop over number of pixels per line
   REP   #20         ; #20 => 1.0 microsec per pixel
   NOP
   ADD   #1,A        ; Pixel data = Pixel data + 1
   NOP
   MOVE  A,B
   NOP
   JSR   <XMT_PIX    ;  transmit them
   NOP
LSR_TST  
   NOP
LPR_TST  
   JSR   <RDA_END      ; Normal exit
   JMP   <START

; Transmit the 16-bit pixel datum in B1 to the host computer
XMT_PIX  ASL   #16,B,B
   NOP
   MOVE  B2,X1
   ASL   #8,B,B
   NOP
   MOVE  B2,X0
   NOP
   MOVEP X1,Y:WRFO
   MOVEP X0,Y:WRFO
   RTS

; Test the hardware to read A/D values directly into the DSP instead
;   of using the SXMIT option, A/Ds #2 and 3.
READ_AD  MOVE  X:(RDAD+2),B
   ASL   #16,B,B
   NOP
   MOVE  B2,X1
   ASL   #8,B,B
   NOP
   MOVE  B2,X0
   NOP
   MOVEP X1,Y:WRFO
   MOVEP X0,Y:WRFO
   REP   #10
   NOP
   MOVE  X:(RDAD+3),B
   ASL   #16,B,B
   NOP
   MOVE  B2,X1
   ASL   #8,B,B
   NOP
   MOVE  B2,X0
   NOP
   MOVEP X1,Y:WRFO
   MOVEP X0,Y:WRFO
   REP   #10
   NOP
   RTS

; Alert the PCI interface board that images are coming soon
PCI_READ_IMAGE
   MOVE  #$020104,B     ; Send header word to the FO transmitter
   JSR   <XMT_WRD
   MOVE  #'RDA',B
   JSR   <XMT_WRD
   MOVE  Y:NCOLS,B         ; Number of columns to read
   JSR   <XMT_WRD
   MOVE  Y:NROWS,B         ; Number of rows to read
   JSR   <XMT_WRD
   RTS

; Wait for the clocking to be complete before proceeding
WAIT_TO_FINISH_CLOCKING
   JSET  #SSFEF,X:PDRD,*      ; Wait for the SS FIFO to be empty  
   RTS

; This MOVEP instruction executes in 30 nanosec, 20 nanosec for the MOVEP,
;   and 10 nanosec for the wait state that is required for SRAM writes and 
;   FIFO setup times. It looks reliable, so will be used for now.

; Core subroutine for clocking out FPA charge
CLOCK
   JCLR  #SSFHF,X:HDR,*       ; Only write to FIFO if < half full
   NOP
   JCLR  #SSFHF,X:HDR,CLOCK   ; Guard against metastability
   MOVE  Y:(R0)+,X0           ; # of waveform entries 
   DO    X0,CLK1              ; Repeat X0 times
   MOVEP Y:(R0)+,Y:WRSS       ; 30 nsec Write the waveform to the SS    
CLK1
   NOP
   RTS                        ; Return from subroutine

; Work on later !!!
; This will execute in 20 nanosec, 10 nanosec for the MOVE and 10 nanosec 
;   the one wait state that is required for SRAM writes and FIFO setup times. 
;   However, the assembler gives a WARNING about pipeline problems if its
;   put in a DO loop. This problem needs to be resolved later, and in the
;   meantime I'll be using the MOVEP instruction. 

;  MOVE  #$FFFF03,R6    ; Write switch states, X:(R6)
;  MOVE  Y:(R0)+,A  A,X:(R6)


; Delay for serial writes to the PALs and DACs by 8 microsec
PAL_DLY  DO #800,DLY  ; Wait 8 usec for serial data transmission
   NOP
DLY   NOP
   RTS

; Let the host computer read the controller configuration
READ_CONTROLLER_CONFIGURATION
   MOVE  Y:<CONFIG,Y1      ; Just transmit the configuration
   JMP   <FINISH1

; Read and return Y:NCOLS
READ_NCOLS
    MOVE    Y:NCOLS,Y1
    JMP    <FINISH1

; Read and return Y:NROWS
READ_NROWS
    MOVE    Y:NROWS,Y1
    JMP    <FINISH1

; Read and return Y:NCHAN
READ_NCHAN
    MOVE    Y:NCHAN,Y1
    JMP    <FINISH1

; Read and return Y:SXMIT
READ_SXMIT
    ;MOVE    Y:SXMIT,Y1
    ;MOVE    Y:CXMIT,Y1
    MOVE    Y:OFFS0,Y1
    JMP    <FINISH1

; Set the desired number of readout channels
SET_NCHAN
        MOVE    X:(R3)+,Y0   ; get the requested number of channels
        MOVE    Y0,Y:<NCHAN  ; update the value of the variable
        ; change the OFFSET value according to the number of channels
        ; 1 channel -> OFFS0=OFFD0 + OFFV1  
        ; 2 channels-> OFFS0=OFFD0 + OFFV2  
        MOVE    Y:OFFD0,A
        JSET    #0,Y:<NCHAN,NCHN1    ; if bit 0 is set, 1 channel output, goto loop
                                     ; default to 2 channels
        MOVE    Y:SXMITV2,X0         ; 2 pixels for 2 video boards
        MOVE    X0,Y:CXMIT           ; 
        MOVE    Y:OFFV2,X0           ; OFFSET2CH
        JMP     <C_NCHN             
NCHN1   MOVE    Y:SXMITV1,X0         ; 2 pixels for 2 1ideo board
        MOVE    X0,Y:CXMIT           ; 
        MOVE    Y:OFFV1,X0           ; OFFSET1CH
C_NCHN  NOP
        ADD     X0,A                    ; $0e0000+OFFSET2CH
        NOP
        BSET    #3,X:PCRD    ; Turn the serial clock on
        NOP
        NOP
        MOVE    A,Y:OFFS0               ; update the value
        JSR    <XMIT_A_WORD        ; Transmit it to TIM-A-STD
        JSR    <PAL_DLY    ; Delay for the serial data transmission
        BCLR    #3,X:PCRD    ; Turn the serial clock off
        JMP    <FINISH


; Set the video processor gain and integrator speed for all video boards
;  Command syntax is  SGN  #GAIN  #SPEED, #GAIN = 1, 2, 5 or 10   
;                #SPEED = 0 for slow, 1 for fast
ST_GAIN  BSET  #3,X:PCRD   ; Turn the serial clock on
   MOVE  X:(R3)+,A   ; Gain value (1,2,5 or 10)
   MOVE  #>1,X0
   CMP   X0,A     ; Check for gain = x1
   JNE   <STG2
   MOVE  #>$77,B
   JMP   <STG_A
STG2  MOVE  #>2,X0      ; Check for gain = x2
   CMP   X0,A
   JNE   <STG5
   MOVE  #>$BB,B
   JMP   <STG_A
STG5  MOVE  #>5,X0      ; Check for gain = x5
   CMP   X0,A
   JNE   <STG10
   MOVE  #>$DD,B
   JMP   <STG_A
STG10 MOVE  #>10,X0     ; Check for gain = x10
   CMP   X0,A
   JNE   <ERROR
   MOVE  #>$EE,B

STG_A MOVE  X:(R3)+,A   ; Integrator Speed (0 for slow, 1 for fast)
   NOP
   JCLR  #0,A1,STG_B
   BSET  #8,B1
   NOP
   BSET  #9,B1
STG_B MOVE  #$0C3C00,X0
   OR X0,B
   NOP
   MOVE  B,Y:<GAIN   ; Store the GAIN value for later use

; Send this same value to 15 video processor boards whether they exist or not
   MOVE  #$100000,X0 ; Increment value
   MOVE  B,A
   DO #15,STG_LOOP
   JSR   <XMIT_A_WORD   ; Transmit A to TIM-A-STD
   JSR   <PAL_DLY ; Wait for SSI and PAL to be empty
   ADD   X0,B     ; Increment the video processor board number
STG_LOOP
   BCLR  #3,X:PCRD   ; Turn the serial clock off
   JMP   <FINISH
ERR_SGN  MOVE  X:(R3)+,A
   JMP   <ERROR

; Set the video processor boards in DC-coupled diagnostic mode or not
; Command syntax is  SDC # # = 0 for normal operation
;           # = 1 for DC coupled diagnostic mode
SET_DC   BSET  #3,X:PCRD   ; Turn the serial clock on
   MOVE  X:(R3)+,X0
   JSET  #0,X0,SDC_1
   BCLR  #10,Y:<GAIN
   BCLR  #11,Y:<GAIN
   JMP   <SDC_A
SDC_1 BSET  #10,Y:<GAIN
   BSET  #11,Y:<GAIN
SDC_A MOVE  #$100000,X0 ; Increment value
   DO #15,SDC_LOOP
   MOVE  Y:<GAIN,A
   JSR   <XMIT_A_WORD   ; Transmit A to TIM-A-STD
   JSR   <PAL_DLY ; Wait for SSI and PAL to be empty
   ADD   X0,B     ; Increment the video processor board number
SDC_LOOP
   BCLR  #3,X:PCRD   ; Turn the serial clock off
   JMP   <FINISH

; Set a particular DAC numbers, for setting DC bias voltages, clock driver  
;   voltages and video processor offset
;
; SBN  #BOARD  #DAC  ['CLK' or 'VID']  voltage
;
;           #BOARD is from 0 to 15
;           #DAC number
;           #voltage is from 0 to 4095

SET_BIAS_NUMBER         ; Set bias number
   BSET  #3,X:PCRD   ; Turn on the serial clock
   MOVE  X:(R3)+,A   ; First argument is board number, 0 to 15
   REP   #20
   LSL   A
   NOP
   MOVE  A,X0
   MOVE  X:(R3)+,A   ; Second argument is DAC number
   REP   #14
   LSL   A
   OR X0,A
   MOVE  X:(R3)+,B   ; Third argument is 'VID' or 'CLK' string
   MOVE  #'VID',X0
   CMP   X0,B
   JNE   <CLK_DRV
   BSET  #19,A1      ; Set bits to mean video processor DAC
   NOP
   BSET  #18,A1
   JMP   <VID_BRD
CLK_DRV  MOVE  #'CLK',X0
   CMP   X0,B
   JNE   <ERR_SBN
VID_BRD  MOVE  A,X0
   MOVE  X:(R3)+,A   ; Fourth argument is voltage value, 0 to $fff
   MOVE  #$000FFF,Y0 ; Mask off just 12 bits to be sure
   AND   Y0,A
   OR X0,A
   JSR   <XMIT_A_WORD   ; Transmit A to TIM-A-STD
   JSR   <PAL_DLY ; Wait for the number to be sent
   BCLR  #3,X:PCRD   ; Turn the serial clock off
   JMP   <FINISH
ERR_SBN  MOVE  X:(R3)+,A   ; Read and discard the fourth argument
   BCLR  #3,X:PCRD   ; Turn the serial clock off
   JMP   <ERROR

; Specify the MUX value to be output on the clock driver board
; Command syntax is  SMX  #clock_driver_board #MUX1 #MUX2
;           #clock_driver_board from 0 to 15
;           #MUX1, #MUX2 from 0 to 23

SET_MUX  BSET  #3,X:PCRD   ; Turn on the serial clock
   MOVE  X:(R3)+,A   ; Clock driver board number
   REP   #20
   LSL   A
   MOVE  #$003000,X0
   OR X0,A
   NOP
   MOVE  A,X1     ; Move here for storage

; Get the first MUX number
   MOVE  X:(R3)+,A   ; Get the first MUX number
   JLT   ERR_SM1
   MOVE  #>24,X0     ; Check for argument less than 32
   CMP   X0,A
   JGE   ERR_SM1
   MOVE  A,B
   MOVE  #>7,X0
   AND   X0,B
   MOVE  #>$18,X0
   AND   X0,A
   JNE   <SMX_1      ; Test for 0 <= MUX number <= 7
   BSET  #3,B1
   JMP   <SMX_A
SMX_1 MOVE  #>$08,X0
   CMP   X0,A     ; Test for 8 <= MUX number <= 15
   JNE   <SMX_2
   BSET  #4,B1
   JMP   <SMX_A
SMX_2 MOVE  #>$10,X0
   CMP   X0,A     ; Test for 16 <= MUX number <= 23
   JNE   <ERR_SM1
   BSET  #5,B1
SMX_A OR X1,B1    ; Add prefix to MUX numbers
   NOP
   MOVE  B1,Y1

; Add on the second MUX number
   MOVE  X:(R3)+,A   ; Get the next MUX number
   JLT   <ERROR
   MOVE  #>24,X0     ; Check for argument less than 32
   CMP   X0,A
   JGE   <ERROR
   REP   #6
   LSL   A
   NOP
   MOVE  A,B
   MOVE  #$1C0,X0
   AND   X0,B
   MOVE  #>$600,X0
   AND   X0,A
   JNE   <SMX_3      ; Test for 0 <= MUX number <= 7
   BSET  #9,B1
   JMP   <SMX_B
SMX_3 MOVE  #>$200,X0
   CMP   X0,A     ; Test for 8 <= MUX number <= 15
   JNE   <SMX_4
   BSET  #10,B1
   JMP   <SMX_B
SMX_4 MOVE  #>$400,X0
   CMP   X0,A     ; Test for 16 <= MUX number <= 23
   JNE   <ERROR
   BSET  #11,B1
SMX_B ADD   Y1,B     ; Add prefix to MUX numbers
   NOP
   MOVE  B1,A
   JSR   <XMIT_A_WORD   ; Transmit A to TIM-A-STD
   JSR   <PAL_DLY ; Delay for all this to happen
   BCLR  #3,X:PCRD   ; Turn the serial clock off
   JMP   <FINISH
ERR_SM1  MOVE  X:(R3)+,A
   BCLR  #3,X:PCRD   ; Turn the serial clock off
   JMP   <ERROR

;******************************************************************************
; Specify either global or row-by-row reset
SELECT_RESET_MODE
   MOVE  X:(R3)+,X0     ; Get the command argument
   JSET  #0,X0,SRM_SET
   BCLR  #RST_MODE,X:STATUS   ; Global reset is in effect
   JMP   <FINISH
SRM_SET  BSET  #RST_MODE,X:STATUS   ; Row-by-row reset is in effect
   JMP   <FINISH

;******************************************************************************
; Set number of Fowler samples per frame
SET_NUMBER_OF_FOWLER_SAMPLES
   MOVE  X:(R3)+,X0
   MOVE  X0,Y:<NFS      ; Number of Fowler samples
   MOVE  X0,A
   SUB   #1,A
   NOP
   MOVE  A,Y:<NFS1
   JMP   <FINISH

;******************************************************************************
; OLD CDS MODE IS BELOW, THIS IS WHAT LEACH DELIVERS
; Specify readout either before and after exposure (CDS) or only after
SELECT_SAMPLING_MODE
   MOVE  X:(R3)+,X0     ; Get the command argument
   JSET  #0,X0,CDS_SET
   BCLR  #CDS_MODE,X:STATUS   ; Single sampling is in effect 
   JMP   <FINISH  
CDS_SET  BSET  #CDS_MODE,X:STATUS   ; Double correlated sampling is
   JMP   <FINISH        ;  in effect

;******************************************************************************
; Specify whether the coadder board does arithmetic (PTR = 0) or whether
;   it just passes the data right through = do nothing here
SELECT_PASS_THROUGH_READOUT
   MOVE  X:(R3)+,X0
   JMP   <FINISH


;******************************************************************************
; Clear Array (M. Schubnell October 2003)
; This should clear the array when the 'Clear Array' button in the main Voodoo
; window is pressed.
CLR_ARRAY
   JSR   <RESET_FAST_ARRAY
;  JSR   <RESET_ARRAY
   JMP   <FINISH
;******************************************************************************
; Set number of exposures for up-the-ramp readout mode; also, pass-through
;   mode is always implemented in up-the-ramp. 
SET_UP_THE_RAMP
   MOVE  X:(R3)+,X0
   MOVE  X0,Y:<NUTR
   MOVE  X:<ONE,X0   ; load one into X0
   MOVE    X0,Y:<IUTR   ; reset this so that Fowler and CDS work after UTR
   JMP   <FINISH

;******************************************************************************
; Specify the number of coadds. 
SET_NUMBER_OF_COADDS
   MOVE  X:(R3)+,X0
   MOVE  X0,Y:<NCOADDS
   JMP   <FINISH

;******************************************************************************
; Transmit a serial command to the Rockwell array
SERIAL_COMMAND
   MOVE  X:(R3)+,A      ; Get the command
   MOVE  #CSB_LOW,R0    ; Enable the serial command link
   JSR   <CLOCK
   DO #16,L_SERCOM      ; The commands are 16 bits long
   JSET  #15,A1,B_SET      ; Check if the bit is set or cleared
   MOVE  #CLOCK_SERIAL_ZERO,R0   ; Transmit a zero bit
   JSR   <CLOCK
   JMP   <NEXTBIT
B_SET MOVE  #CLOCK_SERIAL_ONE,R0 ; Transmit a one bit
   JSR   <CLOCK
NEXTBIT  LSL   A        ; Get the next most significant bit
   NOP   
L_SERCOM
   MOVE  #CSB_HIGH,R0      ; Disable the serial command link
   JSR   <CLOCK
   JMP   <FINISH

;******************************************************************************
; Assert MAINRESETB to clear all serial commands to default settings
CLEAR_SERIAL_SETTINGS
   MOVE  #RESET_SERIAL,R0
   JSR   <CLOCK
   JMP   <FINISH

