       COMMENT *

This file is used to generate DSP code for the second generation 
timing boards to operate one 512 x 512 pixel quadrant of 
a HAWAII-1R  array with two coadder boards. 
Modified according to Michael Schubnell's version (SBeland, June 20,2005)
Modified for 16 channels (Adam Ginsburg, August 28 2007)
   *

   PAGE    132     ; Printronix page width - 132 columns

; Include the boot and header files so addressing is easy
    INCLUDE "timhdr.asm"
    INCLUDE    "timboot.asm"

    ORG    P:,P:

CC  EQU    TIMREV5+IRX8VP+CONT_RD+NGST

; Put number of words of application in P: for loading application from EEPROM
    DC    TIMBOOT_X_MEMORY-@LCV(L)-1

;************************************************************************
RD_ARRAY
    BSET    #ST_RDC,X:<STATUS      ; Set status to reading out
    JSR     <PCI_READ_IMAGE        ; Tell the PCI card the number of pixels to expect
    MOVE    #$0C1000,A             ; schubnell 11-11-04 drain fifo
    JSR     <WR_BIAS               ; schubnell 11-11-04 drain fifo
    JSR     <WAIT_TO_FINISH_CLOCKING ; wait for fifo to be empty (brownmg 041123)
    JSET    #TST_IMG,X:STATUS,SYNTHETIC_IMAGE

; Dummy clocks to remedy the dropped FSYNCB during FRAME_INIT
    MOVE    #FIRST_HCLKS,R0        ; with those two lines commented out
    JSR     <CLOCK                 ; we see FSYNCB clock unreliable


; figure out the number of pixels per channel to read (and save it in A)
    MOVE    Y:<NCOLS,A1         ; Get total number of cols
    JSET    #0,Y:<NCHAN,CHN1    ; if bit 0 is set, 1 channel output, goto loop
    JSET    #1,Y:<NCHAN,CHN2    ; if bit 1 is set, 2 channels output
    JSET    #4,Y:<NCHAN,CHN16   ; if bit 4 is set, 16 channels output ;ADDED 8/28/07 GINS
                                ; default to 2 channels
CHN16 LSR     #4,A               ; bit 4 was set (=> 16 channels)
      JMP     <CHN1             ;MOVED 8/28/07 GINS
CHN2  LSR     #1,A               ; bit 1 was set (=> 2 channels) ;COMMENTED 8/28/07 GINS ;un 9/12/07 b/c it's needed
CHN1  NOP

    MOVE    #FRAME_INIT,R0        ; Initialize the frame for readout
    JSR     <CLOCK

; Read the entire frame, clocking each row
    DO      Y:<NROWS,FRAME        ; Clock-and-read all the rows
    MOVE    #CLOCK_ROW,R0         ; Clock to the first row
    JSR     <CLOCK

; Rockwell requires 2 HCLK pulses before the first real pixel in each row
    MOVE    #FIRST_HCLKS,R0
    JSR     <CLOCK

; Finally, clock each row, read each pixel and transmit the A/D data
    DO      A1,L_READ
    MOVE    #CLK_COL_AND_READ,R0
    JSR     <CLOCK
    NOP
L_READ    NOP
;   MOVE    #LAST_HCLKS,R0
;   JSR     <CLOCK
    NOP
FRAME

;   MOVE    #OVERCLOCK_ROW,R0     ; extra one at end of frame used to
;   JSR     <CLOCK                ; generate FRAMECHK pulse (optional)
    
; Restore the controller to non-image data transfer and idling if necessary
; RDA_END    MOVE    #CONT_RST_TEST,R0        ; Continuously read array in idle mode
RDA_END     MOVE    #CONT_RST,R0        ; Continuously read array in idle mode
    MOVE    R0,X:<IDL_ADR
    JSR     <WAIT_TO_FINISH_CLOCKING
    BCLR    #ST_RDC,X:<STATUS    ; Set status to not reading out
    RTS

;******************************************************************************
; Line by line reset (see timing diagram on p40 in H2 manual)
RESET_ARRAY
    ; Dummy clocks to remedy the dropped FSYNCB during FRAME_INIT
    MOVE    #FIRST_HCLKS,R0      ; MS 040812
    JSR     <CLOCK               ; MS 040812
    MOVE    #FRAME_INIT,R0
    JSR     <CLOCK

; figure out the number of pixels per channel to clear (and save it in A)
    MOVE    Y:<NCOLS,A         ; Get total number of cols
    JSET    #0,Y:<NCHAN,RCHN1    ; if bit 0 is set, 1 channel output, goto loop
    JSET    #1,Y:<NCHAN,RCHN2    ; if bit 1 is set, 2 channels output
    JSET    #4,Y:<NCHAN,RCHN16   ; if bit 4 is set, 16 channels output ;ADDED 8/28/07 GINS
                                ; default to 2 channels
RCHN16 LSR     #4,A               ; bit 4 was set (=> 16 channels)
    JMP     <RCHN1             ; MOVED 8/28/07 GINS
RCHN2  LSR     #1,A               ; bit 1 was set (=> 2 channels) ;COMMENTED 8/28/07 GINS
RCHN1    NOP
    ADD     #2,A                 ; add two extra clocks to each row

    ; DO    #1024,L_RESET_ARRAY
    DO      Y:<NROWS,L_RESET_ARRAY
    MOVE    #RESET_ROW,R0
    JSR     <CLOCK

    ; DO    #514,L_OVER_PIXELS      ; change from 514 to 1026 for 1 channel (SB)
    DO      A,L_OVER_PIXELS     ; loop over every pixel
;   MOVE    #SLOW_CLOCK_ONLY,R0
    MOVE    #CLOCK_ONLY,R0
    JSR     <CLOCK
    NOP
L_OVER_PIXELS
    NOP    
L_RESET_ARRAY
    MOVE    #RESETEN_LOW,R0    ; set reset enable low (MS 6-3-04 added)
    JSR     <CLOCK
    NOP
    RTS

;******************************************************************************
; Line by line reset fast mode (for "Clear button on Voodo and CLR serial command)
RESET_FAST_ARRAY
    ; Dummy clocks to remedy the dropped FSYNCB during FRAME_INIT
    MOVE    #FIRST_HCLKS,R0      ; MS 040812
    JSR     <CLOCK               ; MS 040812
    MOVE    #FRAME_INIT,R0
    JSR     <CLOCK

; figure out the number of pixels per channel to clear (and save it in A)
    MOVE    Y:<NCOLS,A         ; Get total number of cols
    JSET    #0,Y:<NCHAN,FRCHN1    ; if bit 0 is set, 1 channel output, goto loop
    JSET    #1,Y:<NCHAN,FRCHN2    ; if bit 1 is set, 2 channels output
    JSET    #4,Y:<NCHAN,FRCHN16   ; if bit 4 is set, 16 channels output ;ADDED 8/28/07 GINS
                                 ; default to 2 channels
FRCHN16 LSR     #4,A               ; bit 4 was set (=> 16 channels)
    JMP     <FRCHN1             ;MOVED 8/28/07 GINS
FRCHN2  LSR     #1,A               ; bit 1 was set (=> 2 channels) ;COMMENTED 8/28/07 GINS
FRCHN1    NOP
    ADD     #2,A                 ; add two extra clocks to each row

    ; DO    #1024,L_RESET_ARRAY_FAST
    DO      Y:<NROWS,L_RESET_ARRAY_FAST
    MOVE    #RESET_ROW,R0
    JSR     <CLOCK

    ; DO    #514,L_OVER_PIXELS_FAST         ; changed from 514 to 1026 for 1 channel (SB)
    DO      A,L_OVER_PIXELS_FAST  ; loop over every pixel
    MOVE    #FAST_CLOCK_ONLY,R0
    JSR     <CLOCK
    NOP
L_OVER_PIXELS_FAST
    NOP    
L_RESET_ARRAY_FAST
    MOVE    #RESETEN_LOW,R0    ; set reset enable low (MS 6-3-04 added)
    JSR     <CLOCK
    NOP
    RTS

;******************************************************************************
; Continuously reset and read array, checking for commands each row
; Testing a new implementation with RESET_FAST_ARRAY implemented
; instead of the very fast row reset.
; This will hopefully add time with RESETEN high for each row 
; by looping on every pixel, and reduce the amount of persistence 
; with bright stars.
; S.Beland 2005-03-22
CONT_RST_TEST
    MOVE    #FRAME_INIT,R0      ; comment to prevent continuous reset (MD June3)
    JSR     <CLOCK              ; comment to prevent continuous reset (MD June3)
    DO      #1024,LL_RESET_ARRAY_FAST        ; Clock entire FPA
    MOVE    #RESET_ROW,R0        ; Reset one row  (comment out to prevent continuous reset )
    JSR     <CLOCK              ;                (comment out to prevent continuous reset )
    DO      #66,LL_OVER_PIXELS_FAST         ; change from 514 to 1026 for 1 channel 
    MOVE    #FAST_CLOCK_ONLY,R0
    JSR     <CLOCK
    NOP
LL_OVER_PIXELS_FAST
    NOP    
    MOVE    #<COM_BUF,R3
    JSR     <GET_RCV        ; Look for a new command every full fast reset (about 1 second)
    JCC     <LL_NO_COM        ; If none, then stay here
    ENDDO
    JMP     <PRC_RCV
LL_NO_COM   NOP
LL_RESET_ARRAY_FAST
    JMP     <CONT_RST_TEST

;******************************************************************************
; Continuously reset and read array, checking for commands each row
CONT_RST
    MOVE    #FIRST_HCLKS,R0     ; MS 040812
    JSR     <CLOCK              ; MS 040812
    MOVE    #FRAME_INIT,R0      ; comment to prevent continuous reset (MD June3)
    JSR     <CLOCK              ; comment to prevent continuous reset (MD June3)
    DO      #1024,L_RESET       ; Clock entire FPA
    MOVE    #RESET_ROW,R0       ; Reset one row  (comment out to prevent continuous reset )
    JSR     <CLOCK              ;                (comment out to prevent continuous reset )

    MOVE    #<COM_BUF,R3
    JSR     <GET_RCV                ; Look for a new command every 4 rows
    JCC     <NO_COM                 ; If none, then stay here
    MOVE    #RESETEN_LOW,R0
    JSR     <CLOCK
    ENDDO
    JMP     <PRC_RCV
NO_COM      NOP
L_RESET
    JMP     <CONT_RST

;******************************************************************************
; Coaddition code, not really implemented, but left here just in case
COADD    DO    Y:<NCOADDS,L_COADD

; Sample the reset level NFS times if in CDS mode
    JCLR    #CDS_MODE,X:STATUS,RD_END
    DO      Y:<NFS,RD_END            ; Fowler sampling
    JSR     <RD_ARRAY                 ; Read the array
    NOP
RD_END

; Implement up-the-ramp readout
    DO      Y:<IUTR,L_UP_THE_RAMP

; Expose the array
    MOVE    #ST_COAD,R7        ; Jump to ST_COAD after exposure
    JMP     <EXPOSE            ; Start exposure countdown

; Sample the signal level NFS times
ST_COAD     DO    Y:<NFS,RD_EXP        ; Fowler sampling
    JSR     <RD_ARRAY             ; Read the array
    NOP
RD_EXP
    NOP
L_UP_THE_RAMP                ; Up the ramp loop

    NOP
L_COADD                    ; Main coadd loop

; Finish up and return to START
    JSR     <PAL_DLY        ; Wait for the last serial data
    JMP     <START            ; Wait for a new host computer command

; Not yet implemented commands for aborting and continuing readouts
ABR_RDC     JMP    <FINISH
CONTINUE_READ

; Include all the miscellaneous, generic support routines
    INCLUDE    "timIRmisc.asm"


TIMBOOT_X_MEMORY    EQU    @LCV(L)

;  ****************  Setup memory tables in X: space ********************

; Define the address in P: space where the table of constants begins

    IF      @SCP("DOWNLOAD","HOST")
    ORG     X:END_COMMAND_TABLE,X:END_COMMAND_TABLE
    ENDIF

    IF      @SCP("DOWNLOAD","ROM")
    ORG     X:END_COMMAND_TABLE,P:
    ENDIF

    DC 'SEX',START_EXPOSURE        ; Voodoo and CCDTool start exposure
    DC 'STX',STOP_EXPOSURE        ; stop (and read) exposure
    DC 'STP',STP                  ; Exit continuous RUN mode
    DC 'PON',POWER_ON               ; Turn on all camera biases and clocks
    DC 'POF',POWER_OFF            ; Turn +/- 15V power supplies off
    DC 'SBN',SET_BIAS_NUMBER
    DC 'SMX',SET_MUX               ; Set MUX number on clock driver board    
    DC 'DON',START                  ; Nothing special
    DC 'SET',SET_EXPOSURE_TIME     ; Set exposure time
    DC 'RET',READ_EXPOSURE_TIME ; Read elapsed time
    DC 'AEX',ABORT_EXPOSURE
;    DC 'ABR',ABR_RDC
    DC 'RCC',READ_CONTROLLER_CONFIGURATION 

 ; Special SNAP commands
    DC 'SRM',SELECT_RESET_MODE
    DC 'CDS',SELECT_SAMPLING_MODE
    DC 'SFS',SET_NUMBER_OF_FOWLER_SAMPLES
    DC 'SNC',SET_NUMBER_OF_COADDS
    DC 'SUR',SET_UP_THE_RAMP
    DC 'SPT',SELECT_PASS_THROUGH_READOUT
    DC 'SER',SERIAL_COMMAND
    DC 'CLS',CLEAR_SERIAL_SETTINGS
    DC 'CLR',CLR_ARRAY
    DC 'RD0',READ_NCOLS
    DC 'RD1',READ_NROWS
    DC 'RD2',READ_NCHAN
    DC 'RD3',READ_SXMIT
    DC 'SCH',SET_NCHAN

END_APPLICATON_COMMAND_TABLE    EQU    @LCV(L)

    IF    @SCP("DOWNLOAD","HOST")
NUM_COM   EQU   (@LCV(R)-COM_TBL_R)/2    ; Number of boot + 
                                                      ;  application commands
EXPOSING  EQU   CHK_TIM                 ; Address if exposing
CONTINUE_READING    EQU   CONT_RD                 ; Address if reading out
    ENDIF

    IF    @SCP("DOWNLOAD","ROM")
        ORG     Y:0,P:
    ENDIF

; Now let's go for the timing waveform tables
    IF    @SCP("DOWNLOAD","HOST")
       ORG     Y:0,Y:0
    ENDIF

GAIN     DC    END_APPLICATON_Y_MEMORY-@LCV(L)-1
NCOLS    DC    1024    ; Number of columns 
NROWS    DC    1024    ; Number of rows 
NCOADDS  DC    1       ; Number of frames to coadd, set in SNC 
NUTR     DC    1       ; Number of up-the-ramp frames
IUTR     DC    1       ; Number of up-the-ramp frames, minus 1
NFS      DC    1       ; Number of Fowler samples
CONFIG   DC    CC      ; Controller configuration
ICOADD   DC    0
IBUFFER  DC    0
RD_MODE  DC    0
NCHAN    DC    16       ; Number of output channels (2 default, 1 in window mode) ;MODIFIED 8/28/07 GINS
NFS1     DC    0       ; Number of first Fowler samples

; Include the waveform table for the designated IR array
    INCLUDE "WAVEFORM_FILE" ; Readout and clocking waveform file

END_APPLICATON_Y_MEMORY    EQU    @LCV(L)

;  End of program
    END
