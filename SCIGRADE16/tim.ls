Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  tim.asm  Page 1



1                                 COMMENT *
2      
3                          This file is used to generate DSP code for the second generation
4                          timing boards to operate one 512 x 512 pixel quadrant of
5                          a HAWAII-1R  array with two coadder boards.
6                          Modified according to Michael Schubnell's version (SBeland, June 20,2005)
7                             *
8      
9                                    PAGE    132                               ; Printronix page width - 132 columns
10     
11                         ; Include the boot and header files so addressing is easy
12                                   INCLUDE "timhdr.asm"
13                                COMMENT *
14     
15                         This is a header file that is shared between the fiber optic timing board
16                         boot and application code files for Rev. 5 = 250 MHz timing boards
17                                 *
18     
19                                   PAGE    132                               ; Printronix page width - 132 columns
20     
21                         ; Various addressing control registers
22        FFFFFB           BCR       EQU     $FFFFFB                           ; Bus Control Register
23        FFFFF9           AAR0      EQU     $FFFFF9                           ; Address Attribute Register, channel 0
24        FFFFF8           AAR1      EQU     $FFFFF8                           ; Address Attribute Register, channel 1
25        FFFFF7           AAR2      EQU     $FFFFF7                           ; Address Attribute Register, channel 2
26        FFFFF6           AAR3      EQU     $FFFFF6                           ; Address Attribute Register, channel 3
27        FFFFFD           PCTL      EQU     $FFFFFD                           ; PLL control register
28        FFFFFE           IPRP      EQU     $FFFFFE                           ; Interrupt Priority register - Peripheral
29        FFFFFF           IPRC      EQU     $FFFFFF                           ; Interrupt Priority register - Core
30     
31                         ; Port E is the Synchronous Communications Interface (SCI) port
32        FFFF9F           PCRE      EQU     $FFFF9F                           ; Port Control Register
33        FFFF9E           PRRE      EQU     $FFFF9E                           ; Port Direction Register
34        FFFF9D           PDRE      EQU     $FFFF9D                           ; Port Data Register
35        FFFF9C           SCR       EQU     $FFFF9C                           ; SCI Control Register
36        FFFF9B           SCCR      EQU     $FFFF9B                           ; SCI Clock Control Register
37     
38        FFFF9A           SRXH      EQU     $FFFF9A                           ; SCI Receive Data Register, High byte
39        FFFF99           SRXM      EQU     $FFFF99                           ; SCI Receive Data Register, Middle byte
40        FFFF98           SRXL      EQU     $FFFF98                           ; SCI Receive Data Register, Low byte
41     
42        FFFF97           STXH      EQU     $FFFF97                           ; SCI Transmit Data register, High byte
43        FFFF96           STXM      EQU     $FFFF96                           ; SCI Transmit Data register, Middle byte
44        FFFF95           STXL      EQU     $FFFF95                           ; SCI Transmit Data register, Low byte
45     
46        FFFF94           STXA      EQU     $FFFF94                           ; SCI Transmit Address Register
47        FFFF93           SSR       EQU     $FFFF93                           ; SCI Status Register
48     
49        000009           SCITE     EQU     9                                 ; X:SCR bit set to enable the SCI transmitter
50        000008           SCIRE     EQU     8                                 ; X:SCR bit set to enable the SCI receiver
51        000000           TRNE      EQU     0                                 ; This is set in X:SSR when the transmitter
52                                                                             ;  shift and data registers are both empty
53        000001           TDRE      EQU     1                                 ; This is set in X:SSR when the transmitter
54                                                                             ;  data register is empty
55        000002           RDRF      EQU     2                                 ; X:SSR bit set when receiver register is full
56        00000F           SELSCI    EQU     15                                ; 1 for SCI to backplane, 0 to front connector
57     
58     
59                         ; ESSI Flags
60        000006           TDE       EQU     6                                 ; Set when transmitter data register is empty
61        000007           RDF       EQU     7                                 ; Set when receiver is full of data
62        000010           TE        EQU     16                                ; Transmitter enable
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timhdr.asm  Page 2



63     
64                         ; Phase Locked Loop initialization
65        050003           PLL_INIT  EQU     $050003                           ; PLL = 25 MHz x 2 = 100 MHz
66     
67                         ; Port B general purpose I/O
68        FFFFC4           HPCR      EQU     $FFFFC4                           ; Control register (bits 1-6 cleared for GPIO)
69        FFFFC9           HDR       EQU     $FFFFC9                           ; Data register
70        FFFFC8           HDDR      EQU     $FFFFC8                           ; Data Direction Register bits (=1 for output)
71     
72                         ; Port C is Enhanced Synchronous Serial Port 0 = ESSI0
73        FFFFBF           PCRC      EQU     $FFFFBF                           ; Port C Control Register
74        FFFFBE           PRRC      EQU     $FFFFBE                           ; Port C Data direction Register
75        FFFFBD           PDRC      EQU     $FFFFBD                           ; Port C GPIO Data Register
76        FFFFBC           TX00      EQU     $FFFFBC                           ; Transmit Data Register #0
77        FFFFB8           RX0       EQU     $FFFFB8                           ; Receive data register
78        FFFFB7           SSISR0    EQU     $FFFFB7                           ; Status Register
79        FFFFB6           CRB0      EQU     $FFFFB6                           ; Control Register B
80        FFFFB5           CRA0      EQU     $FFFFB5                           ; Control Register A
81     
82                         ; Port D is Enhanced Synchronous Serial Port 1 = ESSI1
83        FFFFAF           PCRD      EQU     $FFFFAF                           ; Port D Control Register
84        FFFFAE           PRRD      EQU     $FFFFAE                           ; Port D Data direction Register
85        FFFFAD           PDRD      EQU     $FFFFAD                           ; Port D GPIO Data Register
86        FFFFAC           TX10      EQU     $FFFFAC                           ; Transmit Data Register 0
87        FFFFA7           SSISR1    EQU     $FFFFA7                           ; Status Register
88        FFFFA6           CRB1      EQU     $FFFFA6                           ; Control Register B
89        FFFFA5           CRA1      EQU     $FFFFA5                           ; Control Register A
90     
91                         ; Timer module addresses
92        FFFF8F           TCSR0     EQU     $FFFF8F                           ; Timer control and status register
93        FFFF8E           TLR0      EQU     $FFFF8E                           ; Timer load register = 0
94        FFFF8D           TCPR0     EQU     $FFFF8D                           ; Timer compare register = exposure time
95        FFFF8C           TCR0      EQU     $FFFF8C                           ; Timer count register = elapsed time
96        FFFF83           TPLR      EQU     $FFFF83                           ; Timer prescaler load register => milliseconds
97        FFFF82           TPCR      EQU     $FFFF82                           ; Timer prescaler count register
98        000000           TIM_BIT   EQU     0                                 ; Set to enable the timer
99        000009           TRM       EQU     9                                 ; Set to enable the timer preloading
100       000015           TCF       EQU     21                                ; Set when timer counter = compare register
101    
102                        ; Board specific addresses and constants
103       FFFFF1           RDFO      EQU     $FFFFF1                           ; Read incoming fiber optic data byte
104       FFFFF2           WRFO      EQU     $FFFFF2                           ; Write fiber optic data replies
105       FFFFF3           WRSS      EQU     $FFFFF3                           ; Write switch state
106       FFFFF5           WRLATCH   EQU     $FFFFF5                           ; Write to a latch
107       010000           RDAD      EQU     $010000                           ; Read A/D values into the DSP
108       000009           EF        EQU     9                                 ; Serial receiver empty flag
109    
110                        ; DSP port A bit equates
111       000000           PWROK     EQU     0                                 ; Power control board says power is OK
112       000001           LED1      EQU     1                                 ; Control one of two LEDs
113       000002           LVEN      EQU     2                                 ; Low voltage power enable
114       000003           HVEN      EQU     3                                 ; High voltage power enable
115       00000E           SSFHF     EQU     14                                ; Switch state FIFO half full flag
116       00000A           EXT_IN0   EQU     10                                ; External digital I/O to the timing board
117       00000B           EXT_IN1   EQU     11
118       00000C           EXT_OUT0  EQU     12
119       00000D           EXT_OUT1  EQU     13
120    
121                        ; Port D equate
122       000001           SSFEF     EQU     1                                 ; Switch state FIFO empty flag
123    
124                        ; Other equates
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timhdr.asm  Page 3



125       000002           WRENA     EQU     2                                 ; Enable writing to the EEPROM
126    
127                        ; Latch U25 bit equates
128       000000           CDAC      EQU     0                                 ; Clear the analog board DACs
129       000002           ENCK      EQU     2                                 ; Enable the clock outputs
130       000004           SHUTTER   EQU     4                                 ; Control the shutter
131       000005           TIM_U_RST EQU     5                                 ; Reset the utility board
132    
133                        ; Software status bits, defined at X:<STATUS = X:0
134       000000           ST_RCV    EQU     0                                 ; Set to indicate word is from SCI = utility board
135       000002           IDLMODE   EQU     2                                 ; Set if need to idle after readout
136       000003           ST_SHUT   EQU     3                                 ; Set to indicate shutter is closed, clear for open
137       000004           ST_RDC    EQU     4                                 ; Set if executing 'RDC' command - reading out
138       000005           SPLIT_S   EQU     5                                 ; Set if split serial
139       000006           SPLIT_P   EQU     6                                 ; Set if split parallel
140       000007           MPP       EQU     7                                 ; Set if parallels are in MPP mode
141       000008           NOT_CLR   EQU     8                                 ; Set if not to clear CCD before exposure
142       00000A           TST_IMG   EQU     10                                ; Set if controller is to generate a test image
143       00000B           SHUT      EQU     11                                ; Set if opening shutter at beginning of exposure
144       00000C           ST_DITH   EQU     12                                ; Set if to dither during exposure
145       00000D           ST_SYNC   EQU     13                                ; Set if starting exposure on SYNC = high signal
146       00000E           ST_CNRD   EQU     14                                ; Set if in continous readout mode
147       00000F           ST_RDM    EQU     15
148    
149                        ; Michigan definitions
150       000010           RST_MODE  EQU     16                                ; 0 for global reset, 1 for row-by-row reset
151       000011           CDS_MODE  EQU     17                                ; 0 for single sampling, 1 for CDS
152       000013           UTR_MODE  EQU     19                                ; 0 for normal, 1 up-the-ramp readout
153       000014           BO_MODE   EQU     20                                ; 0 for normal, 1 Bright Object
154    
155    
156                        ; Address for the table containing the incoming SCI words
157       000400           SCI_TABLE EQU     $400
158    
159    
160                        ; Specify controller configuration bits of the X:STATUS word
161                        ;   to describe the software capabilities of this application file
162                        ; The bit is set (=1) if the capability is supported by the controller
163    
164    
165                                COMMENT *
166    
167                        BIT #'s         FUNCTION
168                        2,1,0           Video Processor
169                                                000     CCD Rev. 3
170                                                001     CCD Gen I
171                                                010     IR Rev. 4
172                                                011     IR Coadder
173                                                100     CCD Rev. 5, Differential input
174                                                101     8x IR
175    
176                        4,3             Timing Board
177                                                00      Rev. 4, Gen II
178                                                01      Gen I
179                                                10      Rev. 5, Gen III, 250 MHz
180    
181                        6,5             Utility Board
182                                                00      No utility board
183                                                01      Utility Rev. 3
184    
185                        7               Shutter
186                                                0       No shutter support
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timhdr.asm  Page 4



187                                                1       Yes shutter support
188    
189                        9,8             Temperature readout
190                                                00      No temperature readout
191                                                01      Polynomial Diode calibration
192                                                10      Linear temperature sensor calibration
193    
194                        10              Subarray readout
195                                                0       Not supported
196                                                1       Yes supported
197    
198                        11              Binning
199                                                0       Not supported
200                                                1       Yes supported
201    
202                        12              Split-Serial readout
203                                                0       Not supported
204                                                1       Yes supported
205    
206                        13              Split-Parallel readout
207                                                0       Not supported
208                                                1       Yes supported
209    
210                        14              MPP = Inverted parallel clocks
211                                                0       Not supported
212                                                1       Yes supported
213    
214                        16,15           Clock Driver Board
215                                                00      Rev. 3
216                                                11      No clock driver board (Gen I)
217    
218                        19,18,17                Special implementations
219                                                000     Somewhere else
220                                                001     Mount Laguna Observatory
221                                                010     NGST Aladdin
222                                                xxx     Other
223                                *
224    
225                        CCDVIDREV3B
226       000000                     EQU     $000000                           ; CCD Video Processor Rev. 3
227       000001           VIDGENI   EQU     $000001                           ; CCD Video Processor Gen I
228       000002           IRREV4    EQU     $000002                           ; IR Video Processor Rev. 4
229       000003           COADDER   EQU     $000003                           ; IR Coadder
230       000004           CCDVIDREV5 EQU    $000004                           ; Differential input CCD video Rev. 5
231       000005           IRX8VP    EQU     $000005                           ; 8 X IR Video Processor
232       000000           TIMREV4   EQU     $000000                           ; Timing Revision 4 = 50 MHz
233       000008           TIMGENI   EQU     $000008                           ; Timing Gen I = 40 MHz
234       000010           TIMREV5   EQU     $000010                           ; Timing Revision 5 = 250 MHz
235       000020           UTILREV3  EQU     $000020                           ; Utility Rev. 3 supported
236       000080           SHUTTER_CC EQU    $000080                           ; Shutter supported
237       000100           TEMP_POLY EQU     $000100                           ; Polynomial calibration
238                        TEMP_LINEAR
239       000200                     EQU     $000200                           ; Linear calibration
240       000400           SUBARRAY  EQU     $000400                           ; Subarray readout supported
241       000800           BINNING   EQU     $000800                           ; Binning supported
242                        SPLIT_SERIAL
243       001000                     EQU     $001000                           ; Split serial supported
244                        SPLIT_PARALLEL
245       002000                     EQU     $002000                           ; Split parallel supported
246       004000           MPP_CC    EQU     $004000                           ; Inverted clocks supported
247       018000           CLKDRVGENI EQU    $018000                           ; No clock driver board - Gen I
248       020000           MLO       EQU     $020000                           ; Set if Mount Laguna Observatory
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timhdr.asm  Page 5



249       040000           NGST      EQU     $040000                           ; NGST Aladdin implementation
250       100000           CONT_RD   EQU     $100000                           ; Continuous readout implemented
251    
252                                  INCLUDE "timboot.asm"
253                               COMMENT *
254    
255                        This file is used to generate boot DSP code for the 250 MHz fiber optic
256                                timing board using a DSP56303 as its main processor.
257                        Added utility board support Dec. 2002
258                                *
259                                  PAGE    132                               ; Printronix page width - 132 columns
260    
261                        ; Special address for two words for the DSP to bootstrap code from the EEPROM
262                                  IF      @SCP("HOST","ROM")
269                                  ENDIF
270    
271                                  IF      @SCP("HOST","HOST")
272       P:000000 P:000000                   ORG     P:0,P:0
273       P:000000 P:000000 0C0190            JMP     <INIT
274       P:000001 P:000001 000000            NOP
275                                           ENDIF
276    
277                                 ;  This ISR receives serial words a byte at a time over the asynchronous
278                                 ;    serial link (SCI) and squashes them into a single 24-bit word
279       P:000002 P:000002 602400  SCI_RCV   MOVE              R0,X:<SAVE_R0           ; Save R0
280       P:000003 P:000003 052139            MOVEC             SR,X:<SAVE_SR           ; Save Status Register
281       P:000004 P:000004 60A700            MOVE              X:<SCI_R0,R0            ; Restore R0 = pointer to SCI receive regist
er
282       P:000005 P:000005 542300            MOVE              A1,X:<SAVE_A1           ; Save A1
283       P:000006 P:000006 452200            MOVE              X1,X:<SAVE_X1           ; Save X1
284       P:000007 P:000007 54A600            MOVE              X:<SCI_A1,A1            ; Get SRX value of accumulator contents
285       P:000008 P:000008 45E000            MOVE              X:(R0),X1               ; Get the SCI byte
286       P:000009 P:000009 0AD041            BCLR    #1,R0                             ; Test for the address being $FFF6 = last by
te
287       P:00000A P:00000A 000000            NOP
288       P:00000B P:00000B 000000            NOP
289       P:00000C P:00000C 000000            NOP
290       P:00000D P:00000D 205862            OR      X1,A      (R0)+                   ; Add the byte into the 24-bit word
291       P:00000E P:00000E 0E0013            JCC     <MID_BYT                          ; Not the last byte => only restore register
s
292       P:00000F P:00000F 545C00  END_BYT   MOVE              A1,X:(R4)+              ; Put the 24-bit word into the SCI buffer
293       P:000010 P:000010 60F400            MOVE              #SRXL,R0                ; Re-establish first address of SCI interfac
e
                            FFFF98
294       P:000012 P:000012 2C0000            MOVE              #0,A1                   ; For zeroing out SCI_A1
295       P:000013 P:000013 602700  MID_BYT   MOVE              R0,X:<SCI_R0            ; Save the SCI receiver address
296       P:000014 P:000014 542600            MOVE              A1,X:<SCI_A1            ; Save A1 for next interrupt
297       P:000015 P:000015 05A139            MOVEC             X:<SAVE_SR,SR           ; Restore Status Register
298       P:000016 P:000016 54A300            MOVE              X:<SAVE_A1,A1           ; Restore A1
299       P:000017 P:000017 45A200            MOVE              X:<SAVE_X1,X1           ; Restore X1
300       P:000018 P:000018 60A400            MOVE              X:<SAVE_R0,R0           ; Restore R0
301       P:000019 P:000019 000004            RTI                                       ; Return from interrupt service
302    
303                                 ; Clear error condition and interrupt on SCI receiver
304       P:00001A P:00001A 077013  CLR_ERR   MOVEP             X:SSR,X:RCV_ERR         ; Read SCI status register
                            000025
305       P:00001C P:00001C 077018            MOVEP             X:SRXL,X:RCV_ERR        ; This clears any error
                            000025
306       P:00001E P:00001E 000004            RTI
307    
308       P:00001F P:00001F                   DC      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
309       P:000030 P:000030                   DC      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timboot.asm  Page 6



310       P:000040 P:000040                   DC      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
311    
312                                 ; Tune the table so the following instruction is at P:$50 exactly.
313       P:000050 P:000050 0D0002            JSR     SCI_RCV                           ; SCI receive data interrupt
314       P:000051 P:000051 000000            NOP
315       P:000052 P:000052 0D001A            JSR     CLR_ERR                           ; SCI receive error interrupt
316       P:000053 P:000053 000000            NOP
317    
318                                 ; *******************  Command Processing  ******************
319    
320                                 ; Read the header and check it for self-consistency
321       P:000054 P:000054 609F00  START     MOVE              X:<IDL_ADR,R0
322       P:000055 P:000055 018FA0            JSET    #TIM_BIT,X:TCSR0,EXPOSING         ; If exposing go check the timer
                            00034D
323       P:000057 P:000057 0A00A4            JSET    #ST_RDC,X:<STATUS,CONTINUE_READING
                            100000
324       P:000059 P:000059 0AE080            JMP     (R0)
325    
326       P:00005A P:00005A 330700  TST_RCV   MOVE              #<COM_BUF,R3
327       P:00005B P:00005B 0D00A5            JSR     <GET_RCV
328       P:00005C P:00005C 0E005B            JCC     *-1
329    
330                                 ; Check the header and read all the remaining words in the command
331       P:00005D P:00005D 0C00FF  PRC_RCV   JMP     <CHK_HDR                          ; Update HEADER and NWORDS
332       P:00005E P:00005E 578600  PR_RCV    MOVE              X:<NWORDS,B             ; Read this many words total in the command
333       P:00005F P:00005F 000000            NOP
334       P:000060 P:000060 01418C            SUB     #1,B                              ; We've already read the header
335       P:000061 P:000061 000000            NOP
336       P:000062 P:000062 06CF00            DO      B,RD_COM
                            00006A
337       P:000064 P:000064 205B00            MOVE              (R3)+                   ; Increment past what's been read already
338       P:000065 P:000065 0B0080  GET_WRD   JSCLR   #ST_RCV,X:STATUS,CHK_FO
                            0000A9
339       P:000067 P:000067 0B00A0            JSSET   #ST_RCV,X:STATUS,CHK_SCI
                            0000D5
340       P:000069 P:000069 0E0065            JCC     <GET_WRD
341       P:00006A P:00006A 000000            NOP
342       P:00006B P:00006B 330700  RD_COM    MOVE              #<COM_BUF,R3            ; Restore R3 = beginning of the command
343    
344                                 ; Is this command for the timing board?
345       P:00006C P:00006C 448500            MOVE              X:<HEADER,X0
346       P:00006D P:00006D 579B00            MOVE              X:<DMASK,B
347       P:00006E P:00006E 459A4E            AND     X0,B      X:<TIM_DRB,X1           ; Extract destination byte
348       P:00006F P:00006F 20006D            CMP     X1,B                              ; Does header = timing board number?
349       P:000070 P:000070 0EA080            JEQ     <COMMAND                          ; Yes, process it here
350       P:000071 P:000071 0E909D            JLT     <FO_XMT                           ; Send it to fiber optic transmitter
351    
352                                 ; Transmit the command to the utility board over the SCI port
353       P:000072 P:000072 060600            DO      X:<NWORDS,DON_XMT                 ; Transmit NWORDS
                            00007E
354       P:000074 P:000074 60F400            MOVE              #STXL,R0                ; SCI first byte address
                            FFFF95
355       P:000076 P:000076 44DB00            MOVE              X:(R3)+,X0              ; Get the 24-bit word to transmit
356       P:000077 P:000077 060380            DO      #3,SCI_SPT
                            00007D
357       P:000079 P:000079 019381            JCLR    #TDRE,X:SSR,*                     ; Continue ONLY if SCI XMT is empty
                            000079
358       P:00007B P:00007B 445800            MOVE              X0,X:(R0)+              ; Write to SCI, byte pointer + 1
359       P:00007C P:00007C 000000            NOP                                       ; Delay for the status flag to be set
360       P:00007D P:00007D 000000            NOP
361                                 SCI_SPT
362       P:00007E P:00007E 000000            NOP
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timboot.asm  Page 7



363                                 DON_XMT
364       P:00007F P:00007F 0C0054            JMP     <START
365    
366                                 ; Process the receiver entry - is it in the command table ?
367       P:000080 P:000080 0203DF  COMMAND   MOVE              X:(R3+1),B              ; Get the command
368       P:000081 P:000081 205B00            MOVE              (R3)+
369       P:000082 P:000082 205B00            MOVE              (R3)+                   ; Point R3 to the first argument
370       P:000083 P:000083 302800            MOVE              #<COM_TBL,R0            ; Get the command table starting address
371       P:000084 P:000084 062180            DO      #NUM_COM,END_COM                  ; Loop over the command table
                            00008B
372       P:000086 P:000086 47D800            MOVE              X:(R0)+,Y1              ; Get the command table entry
373       P:000087 P:000087 62E07D            CMP     Y1,B      X:(R0),R2               ; Does receiver = table entries address?
374       P:000088 P:000088 0E208B            JNE     <NOT_COM                          ; No, keep looping
375       P:000089 P:000089 00008C            ENDDO                                     ; Restore the DO loop system registers
376       P:00008A P:00008A 0AE280            JMP     (R2)                              ; Jump execution to the command
377       P:00008B P:00008B 205800  NOT_COM   MOVE              (R0)+                   ; Increment the register past the table addr
ess
378                                 END_COM
379       P:00008C P:00008C 0C008D            JMP     <ERROR                            ; The command is not in the table
380    
381                                 ; It's not in the command table - send an error message
382       P:00008D P:00008D 479D00  ERROR     MOVE              X:<ERR,Y1               ; Send the message - there was an error
383       P:00008E P:00008E 0C0090            JMP     <FINISH1                          ; This protects against unknown commands
384    
385                                 ; Send a reply packet - header and reply
386       P:00008F P:00008F 479800  FINISH    MOVE              X:<DONE,Y1              ; Send 'DON' as the reply
387       P:000090 P:000090 578500  FINISH1   MOVE              X:<HEADER,B             ; Get header of incoming command
388       P:000091 P:000091 469C00            MOVE              X:<SMASK,Y0             ; This was the source byte, and is to
389       P:000092 P:000092 330700            MOVE              #<COM_BUF,R3            ;     become the destination byte
390       P:000093 P:000093 46935E            AND     Y0,B      X:<TWO,Y0
391       P:000094 P:000094 0C1ED1            LSR     #8,B                              ; Shift right eight bytes, add it to the
392       P:000095 P:000095 460600            MOVE              Y0,X:<NWORDS            ;     header, and put 2 as the number
393       P:000096 P:000096 469958            ADD     Y0,B      X:<SBRD,Y0              ;     of words in the string
394       P:000097 P:000097 200058            ADD     Y0,B                              ; Add source board's header, set Y1 for abov
e
395       P:000098 P:000098 000000            NOP
396       P:000099 P:000099 575B00            MOVE              B,X:(R3)+               ; Put the new header on the transmitter stac
k
397       P:00009A P:00009A 475B00            MOVE              Y1,X:(R3)+              ; Put the argument on the transmitter stack
398       P:00009B P:00009B 570500            MOVE              B,X:<HEADER
399       P:00009C P:00009C 0C006B            JMP     <RD_COM                           ; Decide where to send the reply, and do it
400    
401                                 ; Transmit words to the host computer over the fiber optics link
402       P:00009D P:00009D 63F400  FO_XMT    MOVE              #COM_BUF,R3
                            000007
403       P:00009F P:00009F 060600            DO      X:<NWORDS,DON_FFO                 ; Transmit all the words in the command
                            0000A3
404       P:0000A1 P:0000A1 57DB00            MOVE              X:(R3)+,B
405       P:0000A2 P:0000A2 0D00EB            JSR     <XMT_WRD
406       P:0000A3 P:0000A3 000000            NOP
407       P:0000A4 P:0000A4 0C0054  DON_FFO   JMP     <START
408    
409                                 ; Check for commands from the fiber optic FIFO and the utility board (SCI)
410       P:0000A5 P:0000A5 0D00A9  GET_RCV   JSR     <CHK_FO                           ; Check for fiber optic command from FIFO
411       P:0000A6 P:0000A6 0E80A8            JCS     <RCV_RTS                          ; If there's a command, check the header
412       P:0000A7 P:0000A7 0D00D5            JSR     <CHK_SCI                          ; Check for an SCI command
413       P:0000A8 P:0000A8 00000C  RCV_RTS   RTS
414    
415                                 ; Because of FIFO metastability require that EF be stable for two tests
416       P:0000A9 P:0000A9 0A8989  CHK_FO    JCLR    #EF,X:HDR,TST2                    ; EF = Low,  Low  => CLR SR, return
                            0000AC
417       P:0000AB P:0000AB 0C00AF            JMP     <TST3                             ;      High, Low  => try again
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timboot.asm  Page 8



418       P:0000AC P:0000AC 0A8989  TST2      JCLR    #EF,X:HDR,CLR_CC                  ;      Low,  High => try again
                            0000D1
419       P:0000AE P:0000AE 0C00A9            JMP     <CHK_FO                           ;      High, High => read FIFO
420       P:0000AF P:0000AF 0A8989  TST3      JCLR    #EF,X:HDR,CHK_FO
                            0000A9
421    
422       P:0000B1 P:0000B1 08F4BB            MOVEP             #$028FE2,X:BCR          ; Slow down RDFO access
                            028FE2
423       P:0000B3 P:0000B3 000000            NOP
424       P:0000B4 P:0000B4 000000            NOP
425       P:0000B5 P:0000B5 5FF000            MOVE                          Y:RDFO,B
                            FFFFF1
426       P:0000B7 P:0000B7 2B0000            MOVE              #0,B2
427       P:0000B8 P:0000B8 0140CE            AND     #$FF,B
                            0000FF
428       P:0000BA P:0000BA 0140CD            CMP     #>$AC,B                           ; It must be $AC to be a valid word
                            0000AC
429       P:0000BC P:0000BC 0E20D1            JNE     <CLR_CC
430       P:0000BD P:0000BD 4EF000            MOVE                          Y:RDFO,Y0   ; Read the MS byte
                            FFFFF1
431       P:0000BF P:0000BF 0C1951            INSERT  #$008010,Y0,B
                            008010
432       P:0000C1 P:0000C1 4EF000            MOVE                          Y:RDFO,Y0   ; Read the middle byte
                            FFFFF1
433       P:0000C3 P:0000C3 0C1951            INSERT  #$008008,Y0,B
                            008008
434       P:0000C5 P:0000C5 4EF000            MOVE                          Y:RDFO,Y0   ; Read the LS byte
                            FFFFF1
435       P:0000C7 P:0000C7 0C1951            INSERT  #$008000,Y0,B
                            008000
436       P:0000C9 P:0000C9 000000            NOP
437       P:0000CA P:0000CA 516300            MOVE              B0,X:(R3)               ; Put the word into COM_BUF
438       P:0000CB P:0000CB 0A0000            BCLR    #ST_RCV,X:<STATUS                 ; Its a command from the host computer
439       P:0000CC P:0000CC 000000  SET_CC    NOP
440       P:0000CD P:0000CD 0AF960            BSET    #0,SR                             ; Valid word => SR carry bit = 1
441       P:0000CE P:0000CE 08F4BB            MOVEP             #$028FE1,X:BCR          ; Restore RDFO access
                            028FE1
442       P:0000D0 P:0000D0 00000C            RTS
443       P:0000D1 P:0000D1 0AF940  CLR_CC    BCLR    #0,SR                             ; Not valid word => SR carry bit = 0
444       P:0000D2 P:0000D2 08F4BB            MOVEP             #$028FE1,X:BCR          ; Restore RDFO access
                            028FE1
445       P:0000D4 P:0000D4 00000C            RTS
446    
447                                 ; Test the SCI (= synchronous communications interface) for new words
448       P:0000D5 P:0000D5 44F000  CHK_SCI   MOVE              X:(SCI_TABLE+33),X0
                            000421
449       P:0000D7 P:0000D7 228E00            MOVE              R4,A
450       P:0000D8 P:0000D8 209000            MOVE              X0,R0
451       P:0000D9 P:0000D9 200045            CMP     X0,A
452       P:0000DA P:0000DA 0EA0D1            JEQ     <CLR_CC                           ; There is no new SCI word
453       P:0000DB P:0000DB 44D800            MOVE              X:(R0)+,X0
454       P:0000DC P:0000DC 446300            MOVE              X0,X:(R3)
455       P:0000DD P:0000DD 220E00            MOVE              R0,A
456       P:0000DE P:0000DE 0140C5            CMP     #(SCI_TABLE+32),A                 ; Wrap it around the circular
                            000420
457       P:0000E0 P:0000E0 0EA0E4            JEQ     <INIT_PROCESSED_SCI               ;   buffer boundary
458       P:0000E1 P:0000E1 547000            MOVE              A1,X:(SCI_TABLE+33)
                            000421
459       P:0000E3 P:0000E3 0C00E9            JMP     <SCI_END
460                                 INIT_PROCESSED_SCI
461       P:0000E4 P:0000E4 56F400            MOVE              #SCI_TABLE,A
                            000400
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timboot.asm  Page 9



462       P:0000E6 P:0000E6 000000            NOP
463       P:0000E7 P:0000E7 567000            MOVE              A,X:(SCI_TABLE+33)
                            000421
464       P:0000E9 P:0000E9 0A0020  SCI_END   BSET    #ST_RCV,X:<STATUS                 ; Its a utility board (SCI) word
465       P:0000EA P:0000EA 0C00CC            JMP     <SET_CC
466    
467                                 ; Transmit the word in B1 to the host computer over the fiber optic data link
468                                 XMT_WRD
469       P:0000EB P:0000EB 08F4BB            MOVEP             #$028FE2,X:BCR          ; Slow down RDFO access
                            028FE2
470       P:0000ED P:0000ED 60F400            MOVE              #FO_HDR+1,R0
                            000002
471       P:0000EF P:0000EF 060380            DO      #3,XMT_WRD1
                            0000F3
472       P:0000F1 P:0000F1 0C1D91            ASL     #8,B,B
473       P:0000F2 P:0000F2 000000            NOP
474       P:0000F3 P:0000F3 535800            MOVE              B2,X:(R0)+
475                                 XMT_WRD1
476       P:0000F4 P:0000F4 60F400            MOVE              #FO_HDR,R0
                            000001
477       P:0000F6 P:0000F6 61F400            MOVE              #WRFO,R1
                            FFFFF2
478       P:0000F8 P:0000F8 060480            DO      #4,XMT_WRD2
                            0000FB
479       P:0000FA P:0000FA 46D800            MOVE              X:(R0)+,Y0              ; Should be MOVEP  X:(R0)+,Y:WRFO
480       P:0000FB P:0000FB 4E6100            MOVE                          Y0,Y:(R1)
481                                 XMT_WRD2
482       P:0000FC P:0000FC 08F4BB            MOVEP             #$028FE1,X:BCR          ; Restore RDFO access
                            028FE1
483       P:0000FE P:0000FE 00000C            RTS
484    
485                                 ; Check the command or reply header in X:(R3) for self-consistency
486       P:0000FF P:0000FF 46E300  CHK_HDR   MOVE              X:(R3),Y0
487       P:000100 P:000100 579600            MOVE              X:<MASK1,B              ; Test for S.LE.3 and D.LE.3 and N.LE.7
488       P:000101 P:000101 20005E            AND     Y0,B
489       P:000102 P:000102 0E208D            JNE     <ERROR                            ; Test failed
490       P:000103 P:000103 579700            MOVE              X:<MASK2,B              ; Test for either S.NE.0 or D.NE.0
491       P:000104 P:000104 20005E            AND     Y0,B
492       P:000105 P:000105 0EA08D            JEQ     <ERROR                            ; Test failed
493       P:000106 P:000106 579500            MOVE              X:<SEVEN,B
494       P:000107 P:000107 20005E            AND     Y0,B                              ; Extract NWORDS, must be > 0
495       P:000108 P:000108 0EA08D            JEQ     <ERROR
496       P:000109 P:000109 44E300            MOVE              X:(R3),X0
497       P:00010A P:00010A 440500            MOVE              X0,X:<HEADER            ; Its a correct header
498       P:00010B P:00010B 550600            MOVE              B1,X:<NWORDS            ; Number of words in the command
499       P:00010C P:00010C 0C005E            JMP     <PR_RCV
500    
501                                 ;  *****************  Boot Commands  *******************
502    
503                                 ; Test Data Link - simply return value received after 'TDL'
504       P:00010D P:00010D 47DB00  TDL       MOVE              X:(R3)+,Y1              ; Get the data value
505       P:00010E P:00010E 0C0090            JMP     <FINISH1                          ; Return from executing TDL command
506    
507                                 ; Read DSP or EEPROM memory ('RDM' address): read memory, reply with value
508       P:00010F P:00010F 47DB00  RDMEM     MOVE              X:(R3)+,Y1
509       P:000110 P:000110 20EF00            MOVE              Y1,B
510       P:000111 P:000111 0140CE            AND     #$0FFFFF,B                        ; Bits 23-20 need to be zeroed
                            0FFFFF
511       P:000113 P:000113 21B000            MOVE              B1,R0                   ; Need the address in an address register
512       P:000114 P:000114 20EF00            MOVE              Y1,B
513       P:000115 P:000115 000000            NOP
514       P:000116 P:000116 0ACF14            JCLR    #20,B,RDX                         ; Test address bit for Program memory
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timboot.asm  Page 10



                            00011A
515       P:000118 P:000118 07E087            MOVE              P:(R0),Y1               ; Read from Program Memory
516       P:000119 P:000119 0C0090            JMP     <FINISH1                          ; Send out a header with the value
517       P:00011A P:00011A 0ACF15  RDX       JCLR    #21,B,RDY                         ; Test address bit for X: memory
                            00011E
518       P:00011C P:00011C 47E000            MOVE              X:(R0),Y1               ; Write to X data memory
519       P:00011D P:00011D 0C0090            JMP     <FINISH1                          ; Send out a header with the value
520       P:00011E P:00011E 0ACF16  RDY       JCLR    #22,B,RDR                         ; Test address bit for Y: memory
                            000122
521       P:000120 P:000120 4FE000            MOVE                          Y:(R0),Y1   ; Read from Y data memory
522       P:000121 P:000121 0C0090            JMP     <FINISH1                          ; Send out a header with the value
523       P:000122 P:000122 0ACF17  RDR       JCLR    #23,B,ERROR                       ; Test address bit for read from EEPROM memo
ry
                            00008D
524       P:000124 P:000124 479400            MOVE              X:<THREE,Y1             ; Convert to word address to a byte address
525       P:000125 P:000125 220600            MOVE              R0,Y0                   ; Get 16-bit address in a data register
526       P:000126 P:000126 2000B8            MPY     Y0,Y1,B                           ; Multiply
527       P:000127 P:000127 20002A            ASR     B                                 ; Eliminate zero fill of fractional multiply
528       P:000128 P:000128 213000            MOVE              B0,R0                   ; Need to address memory
529       P:000129 P:000129 0AD06F            BSET    #15,R0                            ; Set bit so its in EEPROM space
530       P:00012A P:00012A 0D0178            JSR     <RD_WORD                          ; Read word from EEPROM
531       P:00012B P:00012B 21A700            MOVE              B1,Y1                   ; FINISH1 transmits Y1 as its reply
532       P:00012C P:00012C 0C0090            JMP     <FINISH1
533    
534                                 ; Program WRMEM ('WRM' address datum): write to memory, reply 'DON'.
535       P:00012D P:00012D 47DB00  WRMEM     MOVE              X:(R3)+,Y1              ; Get the address to be written to
536       P:00012E P:00012E 20EF00            MOVE              Y1,B
537       P:00012F P:00012F 0140CE            AND     #$0FFFFF,B                        ; Bits 23-20 need to be zeroed
                            0FFFFF
538       P:000131 P:000131 21B000            MOVE              B1,R0                   ; Need the address in an address register
539       P:000132 P:000132 20EF00            MOVE              Y1,B
540       P:000133 P:000133 46DB00            MOVE              X:(R3)+,Y0              ; Get datum into Y0 so MOVE works easily
541       P:000134 P:000134 0ACF14            JCLR    #20,B,WRX                         ; Test address bit for Program memory
                            000138
542       P:000136 P:000136 076086            MOVE              Y0,P:(R0)               ; Write to Program memory
543       P:000137 P:000137 0C008F            JMP     <FINISH
544       P:000138 P:000138 0ACF15  WRX       JCLR    #21,B,WRY                         ; Test address bit for X: memory
                            00013C
545       P:00013A P:00013A 466000            MOVE              Y0,X:(R0)               ; Write to X: memory
546       P:00013B P:00013B 0C008F            JMP     <FINISH
547       P:00013C P:00013C 0ACF16  WRY       JCLR    #22,B,WRR                         ; Test address bit for Y: memory
                            000140
548       P:00013E P:00013E 4E6000            MOVE                          Y0,Y:(R0)   ; Write to Y: memory
549       P:00013F P:00013F 0C008F            JMP     <FINISH
550       P:000140 P:000140 0ACF17  WRR       JCLR    #23,B,ERROR                       ; Test address bit for write to EEPROM
                            00008D
551       P:000142 P:000142 013D02            BCLR    #WRENA,X:PDRC                     ; WR_ENA* = 0 to enable EEPROM writing
552       P:000143 P:000143 460E00            MOVE              Y0,X:<SV_A1             ; Save the datum to be written
553       P:000144 P:000144 479400            MOVE              X:<THREE,Y1             ; Convert word address to a byte address
554       P:000145 P:000145 220600            MOVE              R0,Y0                   ; Get 16-bit address in a data register
555       P:000146 P:000146 2000B8            MPY     Y1,Y0,B                           ; Multiply
556       P:000147 P:000147 20002A            ASR     B                                 ; Eliminate zero fill of fractional multiply
557       P:000148 P:000148 213000            MOVE              B0,R0                   ; Need to address memory
558       P:000149 P:000149 0AD06F            BSET    #15,R0                            ; Set bit so its in EEPROM space
559       P:00014A P:00014A 558E00            MOVE              X:<SV_A1,B1             ; Get the datum to be written
560       P:00014B P:00014B 060380            DO      #3,L1WRR                          ; Loop over three bytes of the word
                            000154
561       P:00014D P:00014D 07588D            MOVE              B1,P:(R0)+              ; Write each EEPROM byte
562       P:00014E P:00014E 0C1C91            ASR     #8,B,B
563       P:00014F P:00014F 469E00            MOVE              X:<C100K,Y0             ; Move right one byte, enter delay = 1 msec
564       P:000150 P:000150 06C600            DO      Y0,L2WRR                          ; Delay by 12 milliseconds for EEPROM write
                            000153
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timboot.asm  Page 11



565       P:000152 P:000152 060CA0            REP     #12                               ; Assume 100 MHz DSP56303
566       P:000153 P:000153 000000            NOP
567                                 L2WRR
568       P:000154 P:000154 000000            NOP                                       ; DO loop nesting restriction
569                                 L1WRR
570       P:000155 P:000155 013D22            BSET    #WRENA,X:PDRC                     ; WR_ENA* = 1 to disable EEPROM writing
571       P:000156 P:000156 0C008F            JMP     <FINISH
572    
573                                 ; Load application code from P: memory into its proper locations
574       P:000157 P:000157 47DB00  LDAPPL    MOVE              X:(R3)+,Y1              ; Application number, not used yet
575       P:000158 P:000158 0D015A            JSR     <LOAD_APPLICATION
576       P:000159 P:000159 0C008F            JMP     <FINISH
577    
578                                 LOAD_APPLICATION
579       P:00015A P:00015A 60F400            MOVE              #$8000,R0               ; Starting EEPROM address
                            008000
580       P:00015C P:00015C 0D0178            JSR     <RD_WORD                          ; Number of words in boot code
581       P:00015D P:00015D 21A600            MOVE              B1,Y0
582       P:00015E P:00015E 479400            MOVE              X:<THREE,Y1
583       P:00015F P:00015F 2000B8            MPY     Y0,Y1,B
584       P:000160 P:000160 20002A            ASR     B
585       P:000161 P:000161 213000            MOVE              B0,R0                   ; EEPROM address of start of P: application
586       P:000162 P:000162 0AD06F            BSET    #15,R0                            ; To access EEPROM
587       P:000163 P:000163 0D0178            JSR     <RD_WORD                          ; Read number of words in application P:
588       P:000164 P:000164 61F400            MOVE              #(X_BOOT_START+1),R1    ; End of boot P: code that needs keeping
                            00022A
589       P:000166 P:000166 06CD00            DO      B1,RD_APPL_P
                            000169
590       P:000168 P:000168 0D0178            JSR     <RD_WORD
591       P:000169 P:000169 07598D            MOVE              B1,P:(R1)+
592                                 RD_APPL_P
593       P:00016A P:00016A 0D0178            JSR     <RD_WORD                          ; Read number of words in application X:
594       P:00016B P:00016B 61F400            MOVE              #END_COMMAND_TABLE,R1
                            000036
595       P:00016D P:00016D 06CD00            DO      B1,RD_APPL_X
                            000170
596       P:00016F P:00016F 0D0178            JSR     <RD_WORD
597       P:000170 P:000170 555900            MOVE              B1,X:(R1)+
598                                 RD_APPL_X
599       P:000171 P:000171 0D0178            JSR     <RD_WORD                          ; Read number of words in application Y:
600       P:000172 P:000172 310100            MOVE              #1,R1                   ; There is no Y: memory in the boot code
601       P:000173 P:000173 06CD00            DO      B1,RD_APPL_Y
                            000176
602       P:000175 P:000175 0D0178            JSR     <RD_WORD
603       P:000176 P:000176 5D5900            MOVE                          B1,Y:(R1)+
604                                 RD_APPL_Y
605       P:000177 P:000177 00000C            RTS
606    
607                                 ; Read one word from EEPROM location R0 into accumulator B1
608       P:000178 P:000178 060380  RD_WORD   DO      #3,L_RDBYTE
                            00017B
609       P:00017A P:00017A 07D88B            MOVE              P:(R0)+,B2
610       P:00017B P:00017B 0C1C91            ASR     #8,B,B
611                                 L_RDBYTE
612       P:00017C P:00017C 00000C            RTS
613    
614                                 ; Come to here on a 'STP' command so 'DON' can be sent
615                                 STOP_IDLE_CLOCKING
616       P:00017D P:00017D 305A00            MOVE              #<TST_RCV,R0            ; Execution address when idle => when not
617       P:00017E P:00017E 601F00            MOVE              R0,X:<IDL_ADR           ;   processing commands or reading out
618       P:00017F P:00017F 0A0002            BCLR    #IDLMODE,X:<STATUS                ; Don't idle after readout
619       P:000180 P:000180 0C008F            JMP     <FINISH
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timboot.asm  Page 12



620    
621                                 ; Routines executed after the DSP boots and initializes
622       P:000181 P:000181 305A00  STARTUP   MOVE              #<TST_RCV,R0            ; Execution address when idle => when not
623       P:000182 P:000182 601F00            MOVE              R0,X:<IDL_ADR           ;   processing commands or reading out
624       P:000183 P:000183 44F400            MOVE              #50000,X0               ; Delay by 500 milliseconds
                            00C350
625       P:000185 P:000185 06C400            DO      X0,L_DELAY
                            000188
626       P:000187 P:000187 06E8A3            REP     #1000
627       P:000188 P:000188 000000            NOP
628                                 L_DELAY
629       P:000189 P:000189 57F400            MOVE              #$020002,B              ; Normal reply after booting is 'SYR'
                            020002
630       P:00018B P:00018B 0D00EB            JSR     <XMT_WRD
631       P:00018C P:00018C 57F400            MOVE              #'SYR',B
                            535952
632       P:00018E P:00018E 0D00EB            JSR     <XMT_WRD
633    
634       P:00018F P:00018F 0C0054            JMP     <START                            ; Start normal command processing
635    
636                                 ; *******************  DSP  INITIALIZATION  CODE  **********************
637                                 ; This code initializes the DSP right after booting, and is overwritten
638                                 ;   by application code
639       P:000190 P:000190 08F4BD  INIT      MOVEP             #PLL_INIT,X:PCTL        ; Initialize PLL to 100 MHz
                            050003
640       P:000192 P:000192 000000            NOP
641    
642                                 ; Set operation mode register OMR to normal expanded
643       P:000193 P:000193 0500BA            MOVEC             #$0000,OMR              ; Operating Mode Register = Normal Expanded
644       P:000194 P:000194 0500BB            MOVEC             #0,SP                   ; Reset the Stack Pointer SP
645    
646                                 ; Program the AA = address attribute pins
647       P:000195 P:000195 08F4B9            MOVEP             #$FFFC21,X:AAR0         ; Y = $FFF000 to $FFFFFF asserts commands
                            FFFC21
648       P:000197 P:000197 08F4B8            MOVEP             #$008909,X:AAR1         ; P = $008000 to $00FFFF accesses the EEPROM
                            008909
649       P:000199 P:000199 08F4B7            MOVEP             #$010C11,X:AAR2         ; X = $010000 to $010FFF reads A/D values
                            010C11
650       P:00019B P:00019B 08F4B6            MOVEP             #$080621,X:AAR3         ; Y = $080000 to $0BFFFF R/W from SRAM
                            080621
651    
652                                 ; Program the DRAM memory access and addressing
653       P:00019D P:00019D 08F4BB            MOVEP             #$028FE1,X:BCR          ; Bus Control Register
                            028FE1
654    
655                                 ; Program the Host port B for parallel I/O
656       P:00019F P:00019F 08F484            MOVEP             #>1,X:HPCR              ; All pins enabled as GPIO
                            000001
657       P:0001A1 P:0001A1 08F489            MOVEP             #$810C,X:HDR
                            00810C
658       P:0001A3 P:0001A3 08F488            MOVEP             #$B10E,X:HDDR           ; Data Direction Register
                            00B10E
659                                                                                     ;  (1 for Output, 0 for Input)
660    
661                                 ; Port B conversion from software bits to schematic labels
662                                 ;       PB0 = PWROK             PB08 = PRSFIFO*
663                                 ;       PB1 = LED1              PB09 = EF*
664                                 ;       PB2 = LVEN              PB10 = EXT-IN0
665                                 ;       PB3 = HVEN              PB11 = EXT-IN1
666                                 ;       PB4 = STATUS0           PB12 = EXT-OUT0
667                                 ;       PB5 = STATUS1           PB13 = EXT-OUT1
668                                 ;       PB6 = STATUS2           PB14 = SSFHF*
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timboot.asm  Page 13



669                                 ;       PB7 = STATUS3           PB15 = SELSCI
670    
671                                 ; Program the serial port ESSI0 = Port C for serial communication with
672                                 ;   the utility board
673       P:0001A5 P:0001A5 07F43F            MOVEP             #>0,X:PCRC              ; Software reset of ESSI0
                            000000
674       P:0001A7 P:0001A7 07F435            MOVEP             #$180809,X:CRA0         ; Divide 100 MHz by 20 to get 5.0 MHz
                            180809
675                                                                                     ; DC[4:0] = 0 for non-network operation
676                                                                                     ; WL0-WL2 = 3 for 24-bit data words
677                                                                                     ; SSC1 = 0 for SC1 not used
678       P:0001A9 P:0001A9 07F436            MOVEP             #$020020,X:CRB0         ; SCKD = 1 for internally generated clock
                            020020
679                                                                                     ; SCD2 = 0 so frame sync SC2 is an output
680                                                                                     ; SHFD = 0 for MSB shifted first
681                                                                                     ; FSL = 0, frame sync length not used
682                                                                                     ; CKP = 0 for rising clock edge transitions
683                                                                                     ; SYN = 0 for asynchronous
684                                                                                     ; TE0 = 1 to enable transmitter #0
685                                                                                     ; MOD = 0 for normal, non-networked mode
686                                                                                     ; TE0 = 0 to NOT enable transmitter #0 yet
687                                                                                     ; RE = 1 to enable receiver
688       P:0001AB P:0001AB 07F43F            MOVEP             #%111001,X:PCRC         ; Control Register (0 for GPIO, 1 for ESSI)
                            000039
689       P:0001AD P:0001AD 07F43E            MOVEP             #%000110,X:PRRC         ; Data Direction Register (0 for In, 1 for O
ut)
                            000006
690       P:0001AF P:0001AF 07F43D            MOVEP             #%000100,X:PDRC         ; Data Register - WR_ENA* = 1
                            000004
691    
692                                 ; Port C version = Analog boards
693                                 ;       MOVEP   #$000809,X:CRA0 ; Divide 100 MHz by 20 to get 5.0 MHz
694                                 ;       MOVEP   #$000030,X:CRB0 ; SCKD = 1 for internally generated clock
695                                 ;       MOVEP   #%100000,X:PCRC ; Control Register (0 for GPIO, 1 for ESSI)
696                                 ;       MOVEP   #%000100,X:PRRC ; Data Direction Register (0 for In, 1 for Out)
697                                 ;       MOVEP   #%000000,X:PDRC ; Data Register: 'not used' = 0 outputs
698    
699       P:0001B1 P:0001B1 07F43C            MOVEP             #0,X:TX00               ; Initialize the transmitter to zero
                            000000
700       P:0001B3 P:0001B3 000000            NOP
701       P:0001B4 P:0001B4 000000            NOP
702       P:0001B5 P:0001B5 013630            BSET    #TE,X:CRB0                        ; Enable the SSI transmitter
703    
704                                 ; Conversion from software bits to schematic labels for Port C
705                                 ;       PC0 = SC00 = UTL-T-SCK
706                                 ;       PC1 = SC01 = 2_XMT = SYNC on prototype
707                                 ;       PC2 = SC02 = WR_ENA*
708                                 ;       PC3 = SCK0 = TIM-U-SCK
709                                 ;       PC4 = SRD0 = UTL-T-STD
710                                 ;       PC5 = STD0 = TIM-U-STD
711    
712                                 ; Program the serial port ESSI1 = Port D for serial transmission to
713                                 ;   the analog boards and two parallel I/O input pins
714       P:0001B6 P:0001B6 07F42F            MOVEP             #>0,X:PCRD              ; Software reset of ESSI0
                            000000
715       P:0001B8 P:0001B8 07F425            MOVEP             #$000809,X:CRA1         ; Divide 100 MHz by 20 to get 5.0 MHz
                            000809
716                                                                                     ; DC[4:0] = 0
717                                                                                     ; WL[2:0] = ALC = 0 for 8-bit data words
718                                                                                     ; SSC1 = 0 for SC1 not used
719       P:0001BA P:0001BA 07F426            MOVEP             #$000030,X:CRB1         ; SCKD = 1 for internally generated clock
                            000030
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timboot.asm  Page 14



720                                                                                     ; SCD2 = 1 so frame sync SC2 is an output
721                                                                                     ; SHFD = 0 for MSB shifted first
722                                                                                     ; CKP = 0 for rising clock edge transitions
723                                                                                     ; TE0 = 0 to NOT enable transmitter #0 yet
724                                                                                     ; MOD = 0 so its not networked mode
725       P:0001BC P:0001BC 07F42F            MOVEP             #%100000,X:PCRD         ; Control Register (0 for GPIO, 1 for ESSI)
                            000020
726                                                                                     ; PD3 = SCK1, PD5 = STD1 for ESSI
727       P:0001BE P:0001BE 07F42E            MOVEP             #%000100,X:PRRD         ; Data Direction Register (0 for In, 1 for O
ut)
                            000004
728       P:0001C0 P:0001C0 07F42D            MOVEP             #%000100,X:PDRD         ; Data Register: 'not used' = 0 outputs
                            000004
729       P:0001C2 P:0001C2 07F42C            MOVEP             #0,X:TX10               ; Initialize the transmitter to zero
                            000000
730       P:0001C4 P:0001C4 000000            NOP
731       P:0001C5 P:0001C5 000000            NOP
732       P:0001C6 P:0001C6 012630            BSET    #TE,X:CRB1                        ; Enable the SSI transmitter
733    
734                                 ; Conversion from software bits to schematic labels for Port D
735                                 ; PD0 = SC10 = 2_XMT_? input
736                                 ; PD1 = SC11 = SSFEF* input
737                                 ; PD2 = SC12 = PWR_EN
738                                 ; PD3 = SCK1 = TIM-A-SCK
739                                 ; PD4 = SRD1 = PWRRST
740                                 ; PD5 = STD1 = TIM-A-STD
741    
742                                 ; Program the SCI port to communicate with the utility board
743       P:0001C7 P:0001C7 07F41C            MOVEP             #$0B04,X:SCR            ; SCI programming: 11-bit asynchronous
                            000B04
744                                                                                     ;   protocol (1 start, 8 data, 1 even parity
,
745                                                                                     ;   1 stop); LSB before MSB; enable receiver
746                                                                                     ;   and its interrupts; transmitter interrup
ts
747                                                                                     ;   disabled.
748       P:0001C9 P:0001C9 07F41B            MOVEP             #$0003,X:SCCR           ; SCI clock: utility board data rate =
                            000003
749                                                                                     ;   (390,625 kbits/sec); internal clock.
750       P:0001CB P:0001CB 07F41F            MOVEP             #%011,X:PCRE            ; Port Control Register = RXD, TXD enabled
                            000003
751       P:0001CD P:0001CD 07F41E            MOVEP             #%000,X:PRRE            ; Port Direction Register (0 = Input)
                            000000
752    
753                                 ;       PE0 = RXD
754                                 ;       PE1 = TXD
755                                 ;       PE2 = SCLK
756    
757                                 ; Program one of the three timers as an exposure timer
758       P:0001CF P:0001CF 07F403            MOVEP             #$C34F,X:TPLR           ; Prescaler to generate millisecond timer,
                            00C34F
759                                                                                     ;  counting from the system clock / 2 = 50 M
Hz
760       P:0001D1 P:0001D1 07F40F            MOVEP             #$208200,X:TCSR0        ; Clear timer complete bit and enable presca
ler
                            208200
761       P:0001D3 P:0001D3 07F40E            MOVEP             #0,X:TLR0               ; Timer load register
                            000000
762    
763                                 ; Enable interrupts for the SCI port only
764       P:0001D5 P:0001D5 08F4BF            MOVEP             #$000000,X:IPRC         ; No interrupts allowed
                            000000
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timboot.asm  Page 15



765       P:0001D7 P:0001D7 08F4BE            MOVEP             #>$80,X:IPRP            ; Enable SCI interrupt only, IPR = 1
                            000080
766       P:0001D9 P:0001D9 00FCB8            ANDI    #$FC,MR                           ; Unmask all interrupt levels
767    
768                                 ; Initialize the fiber optic serial receiver circuitry
769       P:0001DA P:0001DA 061480            DO      #20,L_FO_INIT
                            0001DF
770       P:0001DC P:0001DC 5FF000            MOVE                          Y:RDFO,B
                            FFFFF1
771       P:0001DE P:0001DE 0605A0            REP     #5
772       P:0001DF P:0001DF 000000            NOP
773                                 L_FO_INIT
774    
775                                 ; Pulse PRSFIFO* low to revive the CMDRST* instruction and reset the FIFO
776       P:0001E0 P:0001E0 44F400            MOVE              #1000000,X0             ; Delay by 10 milliseconds
                            0F4240
777       P:0001E2 P:0001E2 06C400            DO      X0,*+3
                            0001E4
778       P:0001E4 P:0001E4 000000            NOP
779       P:0001E5 P:0001E5 0A8908            BCLR    #8,X:HDR
780       P:0001E6 P:0001E6 0614A0            REP     #20
781       P:0001E7 P:0001E7 000000            NOP
782       P:0001E8 P:0001E8 0A8928            BSET    #8,X:HDR
783    
784                                 ; Reset the utility board
785       P:0001E9 P:0001E9 0A0F05            BCLR    #5,X:<LATCH
786       P:0001EA P:0001EA 09F0B5            MOVEP             X:LATCH,Y:WRLATCH       ; Clear reset utility board bit
                            00000F
787       P:0001EC P:0001EC 06C8A0            REP     #200                              ; Delay by RESET* low time
788       P:0001ED P:0001ED 000000            NOP
789       P:0001EE P:0001EE 0A0F25            BSET    #5,X:<LATCH
790       P:0001EF P:0001EF 09F0B5            MOVEP             X:LATCH,Y:WRLATCH       ; Clear reset utility board bit
                            00000F
791       P:0001F1 P:0001F1 56F400            MOVE              #200000,A               ; Delay 2 msec for utility boot
                            030D40
792       P:0001F3 P:0001F3 06CE00            DO      A,*+3
                            0001F5
793       P:0001F5 P:0001F5 000000            NOP
794    
795                                 ; Put all the analog switch inputs to low so they draw minimum current
796       P:0001F6 P:0001F6 012F23            BSET    #3,X:PCRD                         ; Turn the serial clock on
797       P:0001F7 P:0001F7 56F400            MOVE              #$0C3000,A              ; Value of integrate speed and gain switches
                            0C3000
798       P:0001F9 P:0001F9 20001B            CLR     B
799       P:0001FA P:0001FA 241000            MOVE              #$100000,X0             ; Increment over board numbers for DAC write
s
800       P:0001FB P:0001FB 45F400            MOVE              #$001000,X1             ; Increment over board numbers for WRSS writ
es
                            001000
801       P:0001FD P:0001FD 060F80            DO      #15,L_ANALOG                      ; Fifteen video processor boards maximum
                            000205
802       P:0001FF P:0001FF 0D020C            JSR     <XMIT_A_WORD                      ; Transmit A to TIM-A-STD
803       P:000200 P:000200 200040            ADD     X0,A
804       P:000201 P:000201 5F7000            MOVE                          B,Y:WRSS    ; This is for the fast analog switches
                            FFFFF3
805       P:000203 P:000203 0620A3            REP     #800                              ; Delay for the serial data transmission
806       P:000204 P:000204 000000            NOP
807       P:000205 P:000205 200068            ADD     X1,B                              ; Increment the video and clock driver numbe
rs
808                                 L_ANALOG
809       P:000206 P:000206 0A0F00            BCLR    #CDAC,X:<LATCH                    ; Enable clearing of DACs
810       P:000207 P:000207 0A0F02            BCLR    #ENCK,X:<LATCH                    ; Disable clock and DAC output switches
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timboot.asm  Page 16



811       P:000208 P:000208 09F0B5            MOVEP             X:LATCH,Y:WRLATCH       ; Execute these two operations
                            00000F
812       P:00020A P:00020A 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
813       P:00020B P:00020B 0C0222            JMP     <SKIP
814    
815                                 ; Transmit contents of accumulator A1 over the synchronous serial transmitter
816                                 XMIT_A_WORD
817       P:00020C P:00020C 07F42C            MOVEP             #0,X:TX10               ;This helps, don't know why
                            000000
818       P:00020E P:00020E 547000            MOVE              A1,X:SV_A1
                            00000E
819       P:000210 P:000210 01A786            JCLR    #TDE,X:SSISR1,*                   ; Start bit
                            000210
820       P:000212 P:000212 07F42C            MOVEP             #$010000,X:TX10
                            010000
821       P:000214 P:000214 060380            DO      #3,L_X
                            00021A
822       P:000216 P:000216 01A786            JCLR    #TDE,X:SSISR1,*                   ; Three data bytes
                            000216
823       P:000218 P:000218 04CCCC            MOVEP             A1,X:TX10
824       P:000219 P:000219 0C1E90            LSL     #8,A
825       P:00021A P:00021A 000000            NOP
826                                 L_X
827       P:00021B P:00021B 01A786            JCLR    #TDE,X:SSISR1,*                   ; Zeroes to bring transmitter low
                            00021B
828       P:00021D P:00021D 07F42C            MOVEP             #0,X:TX10
                            000000
829       P:00021F P:00021F 54F000            MOVE              X:SV_A1,A1
                            00000E
830       P:000221 P:000221 00000C            RTS
831    
832                                 SKIP
833    
834                                 ; Set up the circular SCI buffer, 32 words in size
835       P:000222 P:000222 64F400            MOVE              #SCI_TABLE,R4
                            000400
836       P:000224 P:000224 051FA4            MOVE              #31,M4
837       P:000225 P:000225 647000            MOVE              R4,X:(SCI_TABLE+33)
                            000421
838    
839                                           IF      @SCP("HOST","ROM")
847                                           ENDIF
848    
849       P:000227 P:000227 44F400            MOVE              #>$AC,X0
                            0000AC
850       P:000229 P:000229 440100            MOVE              X0,X:<FO_HDR
851    
852       P:00022A P:00022A 0C0181            JMP     <STARTUP
853    
854                                 ;  ****************  X: Memory tables  ********************
855    
856                                 ; Define the address in P: space where the table of constants begins
857    
858                                  X_BOOT_START
859       000229                              EQU     @LCV(L)-2
860    
861                                           IF      @SCP("HOST","ROM")
863                                           ENDIF
864                                           IF      @SCP("HOST","HOST")
865       X:000000 X:000000                   ORG     X:0,X:0
866                                           ENDIF
867    
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timboot.asm  Page 17



868                                 ; Special storage area - initialization constants and scratch space
869       X:000000 X:000000         STATUS    DC      $1064                             ; Controller status bits
870    
871       000001                    FO_HDR    EQU     STATUS+1                          ; Fiber optic write bytes
872       000005                    HEADER    EQU     FO_HDR+4                          ; Command header
873       000006                    NWORDS    EQU     HEADER+1                          ; Number of words in the command
874       000007                    COM_BUF   EQU     NWORDS+1                          ; Command buffer
875       00000E                    SV_A1     EQU     COM_BUF+7                         ; Save accumulator A1
876    
877                                           IF      @SCP("HOST","ROM")
882                                           ENDIF
883    
884                                           IF      @SCP("HOST","HOST")
885       X:00000F X:00000F                   ORG     X:$F,X:$F
886                                           ENDIF
887    
888                                 ; Parameter table in P: space to be copied into X: space during
889                                 ;   initialization, and is copied from ROM by the DSP boot
890       X:00000F X:00000F         LATCH     DC      $7A                               ; Starting value in latch chip U25
891                                  EXPOSURE_TIME
892       X:000010 X:000010                   DC      0                                 ; Exposure time in milliseconds
893                                  ELAPSED_TIME
894       X:000011 X:000011                   DC      0                                 ; Time elapsed so far in the exposure
895       X:000012 X:000012         ONE       DC      1                                 ; One
896       X:000013 X:000013         TWO       DC      2                                 ; Two
897       X:000014 X:000014         THREE     DC      3                                 ; Three
898       X:000015 X:000015         SEVEN     DC      7                                 ; Seven
899       X:000016 X:000016         MASK1     DC      $FCFCF8                           ; Mask for checking header
900       X:000017 X:000017         MASK2     DC      $030300                           ; Mask for checking header
901       X:000018 X:000018         DONE      DC      'DON'                             ; Standard reply
902       X:000019 X:000019         SBRD      DC      $020000                           ; Source Identification number
903       X:00001A X:00001A         TIM_DRB   DC      $000200                           ; Destination = timing board number
904       X:00001B X:00001B         DMASK     DC      $00FF00                           ; Mask to get destination board number
905       X:00001C X:00001C         SMASK     DC      $FF0000                           ; Mask to get source board number
906       X:00001D X:00001D         ERR       DC      'ERR'                             ; An error occurred
907       X:00001E X:00001E         C100K     DC      100000                            ; Delay for WRROM = 1 millisec
908       X:00001F X:00001F         IDL_ADR   DC      TST_RCV                           ; Address of idling routine
909       X:000020 X:000020         EXP_ADR   DC      0                                 ; Jump to this address during exposures
910    
911                                 ; Places for saving register values
912       X:000021 X:000021         SAVE_SR   DC      0                                 ; Status Register
913       X:000022 X:000022         SAVE_X1   DC      0
914       X:000023 X:000023         SAVE_A1   DC      0
915       X:000024 X:000024         SAVE_R0   DC      0
916       X:000025 X:000025         RCV_ERR   DC      0
917       X:000026 X:000026         SCI_A1    DC      0                                 ; Contents of accumulator A1 in RCV ISR
918       X:000027 X:000027         SCI_R0    DC      SRXL
919    
920                                 ; Command table
921       000028                    COM_TBL_R EQU     @LCV(R)
922       X:000028 X:000028         COM_TBL   DC      'TDL',TDL                         ; Test Data Link
923       X:00002A X:00002A                   DC      'RDM',RDMEM                       ; Read from DSP or EEPROM memory
924       X:00002C X:00002C                   DC      'WRM',WRMEM                       ; Write to DSP memory
925       X:00002E X:00002E                   DC      'LDA',LDAPPL                      ; Load application from EEPROM to DSP
926       X:000030 X:000030                   DC      'STP',STOP_IDLE_CLOCKING
927       X:000032 X:000032                   DC      'DON',START                       ; Nothing special
928       X:000034 X:000034                   DC      'ERR',START                       ; Nothing special
929    
930                                  END_COMMAND_TABLE
931       000036                              EQU     @LCV(R)
932    
933                                 ; The table at SCI_TABLE is for words received from the utility board, written by
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timboot.asm  Page 18



934                                 ;   the interrupt service routine SCI_RCV. Note that it is 32 words long,
935                                 ;   hard coded, and the 33rd location contains the pointer to words that have
936                                 ;   been processed by moving them from the SCI_TABLE to the COM_BUF.
937    
938                                           IF      @SCP("HOST","ROM")
940                                           ENDIF
941    
942       000036                    END_ADR   EQU     @LCV(L)                           ; End address of P: code written to ROM
943    
944       P:00022B P:00022B                   ORG     P:,P:
945    
946       140015                    CC        EQU     TIMREV5+IRX8VP+CONT_RD+NGST
947    
948                                 ; Put number of words of application in P: for loading application from EEPROM
949       P:00022B P:00022B                   DC      TIMBOOT_X_MEMORY-@LCV(L)-1
950    
951                                 ;************************************************************************
952                                 RD_ARRAY
953       P:00022C P:00022C 0A0024            BSET    #ST_RDC,X:<STATUS                 ; Set status to reading out
954       P:00022D P:00022D 0D03EA            JSR     <PCI_READ_IMAGE                   ; Tell the PCI card the number of pixels to 
expect
955       P:00022E P:00022E 56F400            MOVE              #$0C1000,A              ; schubnell 11-11-04 drain fifo
                            0C1000
956       P:000230 P:000230 0D02ED            JSR     <WR_BIAS                          ; schubnell 11-11-04 drain fifo
957       P:000231 P:000231 0D03F7            JSR     <WAIT_TO_FINISH_CLOCKING          ; wait for fifo to be empty (brownmg 041123)
958       P:000232 P:000232 0A00AA            JSET    #TST_IMG,X:STATUS,SYNTHETIC_IMAGE
                            0003B5
959    
960                                 ; Dummy clocks to remedy the dropped FSYNCB during FRAME_INIT
961       P:000234 P:000234 60F400            MOVE              #FIRST_HCLKS,R0         ; with those two lines commented out
                            00002D
962       P:000236 P:000236 0D03FA            JSR     <CLOCK                            ; we see FSYNCB clock unreliable
963    
964    
965                                 ; figure out the number of pixels per channel to read (and save it in A)
966       P:000237 P:000237 5C8100            MOVE                          Y:<NCOLS,A1 ; Get total number of cols
967       P:000238 P:000238 0A0BE0            JSET    #0,Y:<NCHAN,CHN1                  ; if bit 0 is set, 1 channel output, goto lo
op
                            000241
968       P:00023A P:00023A 0A0BE1            JSET    #1,Y:<NCHAN,CHN2                  ; if bit 1 is set, 2 channels output
                            00023E
969       P:00023C P:00023C 0A0BE4            JSET    #4,Y:<NCHAN,CHN16                 ; if bit 4 is set, 16 channels output
                            000240
970                                                                                     ; default to 2 channels
971       P:00023E P:00023E 0C1EC2  CHN2      LSR     #1,A                              ; bit 1 was set (=> 2 channels)
972       P:00023F P:00023F 0C0241            JMP     <CHN1
973       P:000240 P:000240 0C1EC8  CHN16     LSR     #4,A                              ; bit 4 was set (=> 16 channels)
974       P:000241 P:000241 000000  CHN1      NOP
975    
976       P:000242 P:000242 60F400            MOVE              #FRAME_INIT,R0          ; Initialize the frame for readout
                            00000D
977       P:000244 P:000244 0D03FA            JSR     <CLOCK
978    
979                                 ; Read the entire frame, clocking each row
980       P:000245 P:000245 060240            DO      Y:<NROWS,FRAME                    ; Clock-and-read all the rows
                            000254
981       P:000247 P:000247 60F400            MOVE              #CLOCK_ROW,R0           ; Clock to the first row
                            000012
982       P:000249 P:000249 0D03FA            JSR     <CLOCK
983    
984                                 ; Rockwell requires 2 HCLK pulses before the first real pixel in each row
985       P:00024A P:00024A 60F400            MOVE              #FIRST_HCLKS,R0
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  tim.asm  Page 19



                            00002D
986       P:00024C P:00024C 0D03FA            JSR     <CLOCK
987    
988                                 ; Finally, clock each row, read each pixel and transmit the A/D data
989       P:00024D P:00024D 06CC00            DO      A1,L_READ
                            000252
990       P:00024F P:00024F 60F400            MOVE              #CLK_COL_AND_READ,R0
                            00001F
991       P:000251 P:000251 0D03FA            JSR     <CLOCK
992       P:000252 P:000252 000000            NOP
993       P:000253 P:000253 000000  L_READ    NOP
994                                 ;   MOVE    #LAST_HCLKS,R0
995                                 ;   JSR     <CLOCK
996       P:000254 P:000254 000000            NOP
997                                 FRAME
998    
999                                 ;   MOVE    #OVERCLOCK_ROW,R0     ; extra one at end of frame used to
1000                                ;   JSR     <CLOCK                ; generate FRAMECHK pulse (optional)
1001   
1002                                ; Restore the controller to non-image data transfer and idling if necessary
1003                                ; RDA_END    MOVE    #CONT_RST_TEST,R0        ; Continuously read array in idle mode
1004      P:000255 P:000255 60F400  RDA_END   MOVE              #CONT_RST,R0            ; Continuously read array in idle mode
                            0002B7
1005      P:000257 P:000257 601F00            MOVE              R0,X:<IDL_ADR
1006      P:000258 P:000258 0D03F7            JSR     <WAIT_TO_FINISH_CLOCKING
1007      P:000259 P:000259 0A0004            BCLR    #ST_RDC,X:<STATUS                 ; Set status to not reading out
1008      P:00025A P:00025A 00000C            RTS
1009   
1010                                ;******************************************************************************
1011                                ; Line by line reset (see timing diagram on p40 in H2 manual)
1012                                RESET_ARRAY
1013                                                                                    ; Dummy clocks to remedy the dropped FSYNCB 
during FRAME_INIT
1014      P:00025B P:00025B 60F400            MOVE              #FIRST_HCLKS,R0         ; MS 040812
                            00002D
1015      P:00025D P:00025D 0D03FA            JSR     <CLOCK                            ; MS 040812
1016      P:00025E P:00025E 60F400            MOVE              #FRAME_INIT,R0
                            00000D
1017      P:000260 P:000260 0D03FA            JSR     <CLOCK
1018   
1019                                ; figure out the number of pixels per channel to clear (and save it in A)
1020      P:000261 P:000261 5E8100            MOVE                          Y:<NCOLS,A  ; Get total number of cols
1021      P:000262 P:000262 0A0BE0            JSET    #0,Y:<NCHAN,RCHN1                 ; if bit 0 is set, 1 channel output, goto lo
op
                            00026B
1022      P:000264 P:000264 0A0BE1            JSET    #1,Y:<NCHAN,RCHN2                 ; if bit 1 is set, 2 channels output
                            000268
1023      P:000266 P:000266 0A0BE4            JSET    #4,Y:<NCHAN,RCHN16                ; if bit 4 is set, 16 channels output
                            00026A
1024                                                                                    ; default to 2 channels
1025      P:000268 P:000268 0C1EC2  RCHN2     LSR     #1,A                              ; bit 1 was set (=> 2 channels)
1026      P:000269 P:000269 0C026B            JMP     <RCHN1
1027      P:00026A P:00026A 0C1EC8  RCHN16    LSR     #4,A                              ; bit 4 was set (=> 16 channels)
1028      P:00026B P:00026B 000000  RCHN1     NOP
1029      P:00026C P:00026C 014280            ADD     #2,A                              ; add two extra clocks to each row
1030   
1031                                                                                    ; DO    #1024,L_RESET_ARRAY
1032      P:00026D P:00026D 060240            DO      Y:<NROWS,L_RESET_ARRAY
                            000278
1033      P:00026F P:00026F 60F400            MOVE              #RESET_ROW,R0
                            00001B
1034      P:000271 P:000271 0D03FA            JSR     <CLOCK
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  tim.asm  Page 20



1035   
1036                                                                                    ; DO    #514,L_OVER_PIXELS      ; change fro
m 514 to 1026 for 1 channel (SB)
1037      P:000272 P:000272 06CE00            DO      A,L_OVER_PIXELS                   ; loop over every pixel
                            000277
1038                                ;   MOVE    #SLOW_CLOCK_ONLY,R0
1039      P:000274 P:000274 60F400            MOVE              #CLOCK_ONLY,R0
                            000034
1040      P:000276 P:000276 0D03FA            JSR     <CLOCK
1041      P:000277 P:000277 000000            NOP
1042                                L_OVER_PIXELS
1043      P:000278 P:000278 000000            NOP
1044                                L_RESET_ARRAY
1045      P:000279 P:000279 60F400            MOVE              #RESETEN_LOW,R0         ; set reset enable low (MS 6-3-04 added)
                            00003D
1046      P:00027B P:00027B 0D03FA            JSR     <CLOCK
1047      P:00027C P:00027C 000000            NOP
1048      P:00027D P:00027D 00000C            RTS
1049   
1050                                ;******************************************************************************
1051                                ; Line by line reset fast mode (for "Clear button on Voodo and CLR serial command)
1052                                RESET_FAST_ARRAY
1053                                                                                    ; Dummy clocks to remedy the dropped FSYNCB 
during FRAME_INIT
1054      P:00027E P:00027E 60F400            MOVE              #FIRST_HCLKS,R0         ; MS 040812
                            00002D
1055      P:000280 P:000280 0D03FA            JSR     <CLOCK                            ; MS 040812
1056      P:000281 P:000281 60F400            MOVE              #FRAME_INIT,R0
                            00000D
1057      P:000283 P:000283 0D03FA            JSR     <CLOCK
1058   
1059                                ; figure out the number of pixels per channel to clear (and save it in A)
1060      P:000284 P:000284 5E8100            MOVE                          Y:<NCOLS,A  ; Get total number of cols
1061      P:000285 P:000285 0A0BE0            JSET    #0,Y:<NCHAN,FRCHN1                ; if bit 0 is set, 1 channel output, goto lo
op
                            00028E
1062      P:000287 P:000287 0A0BE1            JSET    #1,Y:<NCHAN,FRCHN2                ; if bit 1 is set, 2 channels output
                            00028B
1063      P:000289 P:000289 0A0BE4            JSET    #4,Y:<NCHAN,FRCHN16               ; if bit 4 is set, 16 channels output
                            00028D
1064                                                                                    ; default to 2 channels
1065      P:00028B P:00028B 0C1EC2  FRCHN2    LSR     #1,A                              ; bit 1 was set (=> 2 channels)
1066      P:00028C P:00028C 0C028E            JMP     <FRCHN1
1067      P:00028D P:00028D 0C1EC8  FRCHN16   LSR     #4,A                              ; bit 4 was set (=> 16 channels)
1068      P:00028E P:00028E 000000  FRCHN1    NOP
1069      P:00028F P:00028F 014280            ADD     #2,A                              ; add two extra clocks to each row
1070   
1071                                                                                    ; DO    #1024,L_RESET_ARRAY_FAST
1072      P:000290 P:000290 060240            DO      Y:<NROWS,L_RESET_ARRAY_FAST
                            00029B
1073      P:000292 P:000292 60F400            MOVE              #RESET_ROW,R0
                            00001B
1074      P:000294 P:000294 0D03FA            JSR     <CLOCK
1075   
1076                                                                                    ; DO    #514,L_OVER_PIXELS_FAST         ; ch
anged from 514 to 1026 for 1 channel (SB)
1077      P:000295 P:000295 06CE00            DO      A,L_OVER_PIXELS_FAST              ; loop over every pixel
                            00029A
1078      P:000297 P:000297 60F400            MOVE              #FAST_CLOCK_ONLY,R0
                            000037
1079      P:000299 P:000299 0D03FA            JSR     <CLOCK
1080      P:00029A P:00029A 000000            NOP
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  tim.asm  Page 21



1081                                L_OVER_PIXELS_FAST
1082      P:00029B P:00029B 000000            NOP
1083                                L_RESET_ARRAY_FAST
1084      P:00029C P:00029C 60F400            MOVE              #RESETEN_LOW,R0         ; set reset enable low (MS 6-3-04 added)
                            00003D
1085      P:00029E P:00029E 0D03FA            JSR     <CLOCK
1086      P:00029F P:00029F 000000            NOP
1087      P:0002A0 P:0002A0 00000C            RTS
1088   
1089                                ;******************************************************************************
1090                                ; Continuously reset and read array, checking for commands each row
1091                                ; Testing a new implementation with RESET_FAST_ARRAY implemented
1092                                ; instead of the very fast row reset.
1093                                ; This will hopefully add time with RESETEN high for each row
1094                                ; by looping on every pixel, and reduce the amount of persistence
1095                                ; with bright stars.
1096                                ; S.Beland 2005-03-22
1097                                CONT_RST_TEST
1098      P:0002A1 P:0002A1 60F400            MOVE              #FRAME_INIT,R0          ; comment to prevent continuous reset (MD Ju
ne3)
                            00000D
1099      P:0002A3 P:0002A3 0D03FA            JSR     <CLOCK                            ; comment to prevent continuous reset (MD Ju
ne3)
1100      P:0002A4 P:0002A4 060084            DO      #1024,LL_RESET_ARRAY_FAST         ; Clock entire FPA
                            0002B5
1101      P:0002A6 P:0002A6 60F400            MOVE              #RESET_ROW,R0           ; Reset one row  (comment out to prevent con
tinuous reset )
                            00001B
1102      P:0002A8 P:0002A8 0D03FA            JSR     <CLOCK                            ;                (comment out to prevent con
tinuous reset )
1103      P:0002A9 P:0002A9 060282            DO      #514,LL_OVER_PIXELS_FAST          ; change from 514 to 1026 for 1 channel
                            0002AE
1104      P:0002AB P:0002AB 60F400            MOVE              #FAST_CLOCK_ONLY,R0
                            000037
1105      P:0002AD P:0002AD 0D03FA            JSR     <CLOCK
1106      P:0002AE P:0002AE 000000            NOP
1107                                LL_OVER_PIXELS_FAST
1108      P:0002AF P:0002AF 000000            NOP
1109      P:0002B0 P:0002B0 330700            MOVE              #<COM_BUF,R3
1110      P:0002B1 P:0002B1 0D00A5            JSR     <GET_RCV                          ; Look for a new command every full fast res
et (about 1 second)
1111      P:0002B2 P:0002B2 0E02B5            JCC     <LL_NO_COM                        ; If none, then stay here
1112      P:0002B3 P:0002B3 00008C            ENDDO
1113      P:0002B4 P:0002B4 0C005D            JMP     <PRC_RCV
1114      P:0002B5 P:0002B5 000000  LL_NO_COM NOP
1115                                LL_RESET_ARRAY_FAST
1116      P:0002B6 P:0002B6 0C02A1            JMP     <CONT_RST_TEST
1117   
1118                                ;******************************************************************************
1119                                ; Continuously reset and read array, checking for commands each row
1120                                CONT_RST
1121      P:0002B7 P:0002B7 60F400            MOVE              #FIRST_HCLKS,R0         ; MS 040812
                            00002D
1122      P:0002B9 P:0002B9 0D03FA            JSR     <CLOCK                            ; MS 040812
1123      P:0002BA P:0002BA 60F400            MOVE              #FRAME_INIT,R0          ; comment to prevent continuous reset (MD Ju
ne3)
                            00000D
1124      P:0002BC P:0002BC 0D03FA            JSR     <CLOCK                            ; comment to prevent continuous reset (MD Ju
ne3)
1125      P:0002BD P:0002BD 060084            DO      #1024,L_RESET                     ; Clock entire FPA
                            0002CA
1126      P:0002BF P:0002BF 60F400            MOVE              #RESET_ROW,R0           ; Reset one row  (comment out to prevent con
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  tim.asm  Page 22



tinuous reset )
                            00001B
1127      P:0002C1 P:0002C1 0D03FA            JSR     <CLOCK                            ;                (comment out to prevent con
tinuous reset )
1128   
1129      P:0002C2 P:0002C2 330700            MOVE              #<COM_BUF,R3
1130      P:0002C3 P:0002C3 0D00A5            JSR     <GET_RCV                          ; Look for a new command every 4 rows
1131      P:0002C4 P:0002C4 0E02CA            JCC     <NO_COM                           ; If none, then stay here
1132      P:0002C5 P:0002C5 60F400            MOVE              #RESETEN_LOW,R0
                            00003D
1133      P:0002C7 P:0002C7 0D03FA            JSR     <CLOCK
1134      P:0002C8 P:0002C8 00008C            ENDDO
1135      P:0002C9 P:0002C9 0C005D            JMP     <PRC_RCV
1136      P:0002CA P:0002CA 000000  NO_COM    NOP
1137                                L_RESET
1138      P:0002CB P:0002CB 0C02B7            JMP     <CONT_RST
1139   
1140                                ;******************************************************************************
1141                                ; Coaddition code, not really implemented, but left here just in case
1142      P:0002CC P:0002CC 060340  COADD     DO      Y:<NCOADDS,L_COADD
                            0002DE
1143   
1144                                ; Sample the reset level NFS times if in CDS mode
1145      P:0002CE P:0002CE 0A0091            JCLR    #CDS_MODE,X:STATUS,RD_END
                            0002D4
1146      P:0002D0 P:0002D0 060640            DO      Y:<NFS,RD_END                     ; Fowler sampling
                            0002D3
1147      P:0002D2 P:0002D2 0D022C            JSR     <RD_ARRAY                         ; Read the array
1148      P:0002D3 P:0002D3 000000            NOP
1149                                RD_END
1150   
1151                                ; Implement up-the-ramp readout
1152      P:0002D4 P:0002D4 060540            DO      Y:<IUTR,L_UP_THE_RAMP
                            0002DD
1153   
1154                                ; Expose the array
1155      P:0002D6 P:0002D6 67F400            MOVE              #ST_COAD,R7             ; Jump to ST_COAD after exposure
                            0002D9
1156      P:0002D8 P:0002D8 0C033F            JMP     <EXPOSE                           ; Start exposure countdown
1157   
1158                                ; Sample the signal level NFS times
1159      P:0002D9 P:0002D9 060640  ST_COAD   DO      Y:<NFS,RD_EXP                     ; Fowler sampling
                            0002DC
1160      P:0002DB P:0002DB 0D022C            JSR     <RD_ARRAY                         ; Read the array
1161      P:0002DC P:0002DC 000000            NOP
1162                                RD_EXP
1163      P:0002DD P:0002DD 000000            NOP
1164                                L_UP_THE_RAMP                                       ; Up the ramp loop
1165   
1166      P:0002DE P:0002DE 000000            NOP
1167                                L_COADD                                             ; Main coadd loop
1168   
1169                                ; Finish up and return to START
1170      P:0002DF P:0002DF 0D0405            JSR     <PAL_DLY                          ; Wait for the last serial data
1171      P:0002E0 P:0002E0 0C0054            JMP     <START                            ; Wait for a new host computer command
1172   
1173                                ; Not yet implemented commands for aborting and continuing readouts
1174      P:0002E1 P:0002E1 0C008F  ABR_RDC   JMP     <FINISH
1175                                CONTINUE_READ
1176   
1177                                ; Include all the miscellaneous, generic support routines
1178                                          INCLUDE "timIRmisc.asm"
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timIRmisc.asm  Page 23



1179                                ; wait some
1180                                WAIT_SOME
1181      P:0002E2 P:0002E2 06C880            DO      #200,END_WAIT_SOME                ; wait some for the read_array to finish
                            0002E4
1182      P:0002E4 P:0002E4 000000            NOP
1183                                END_WAIT_SOME
1184      P:0002E5 P:0002E5 000000            NOP
1185      P:0002E6 P:0002E6 00000C            RTS
1186                                DELAY1
1187      P:0002E7 P:0002E7 44F400            MOVE              #10000,X0               ; 100 microsec delay
                            002710
1188      P:0002E9 P:0002E9 06C400            DO      X0,END_DEL1
                            0002EB
1189      P:0002EB P:0002EB 000000            NOP
1190                                END_DEL1
1191      P:0002EC P:0002EC 00000C            RTS
1192                                ; Write a number to an analog board over the serial link
1193                                WR_BIAS
1194      P:0002ED P:0002ED 012F23            BSET    #3,X:PCRD                         ; turn on the serial clock
1195      P:0002EE P:0002EE 0D0405            JSR     <PAL_DLY
1196      P:0002EF P:0002EF 0D020C            JSR     <XMIT_A_WORD
1197      P:0002F0 P:0002F0 0D0405            JSR     <PAL_DLY
1198      P:0002F1 P:0002F1 012F03            BCLR    #3,X:PCRD
1199      P:0002F2 P:0002F2 0D0405            JSR     <PAL_DLY
1200      P:0002F3 P:0002F3 00000C            RTS
1201                                ; Clear all video processor analog switches to lower their power dissipation
1202   
1203                                POWER_OFF
1204      P:0002F4 P:0002F4 0D0327            JSR     <CLEAR_SWITCHES_AND_DACS          ; Clear switches and DACs
1205      P:0002F5 P:0002F5 0A8922            BSET    #LVEN,X:HDR
1206      P:0002F6 P:0002F6 0A8923            BSET    #HVEN,X:HDR
1207      P:0002F7 P:0002F7 0C008F            JMP     <FINISH
1208   
1209                                ; Execute the power-on cycle, as a command
1210                                POWER_ON
1211      P:0002F8 P:0002F8 0D0327            JSR     <CLEAR_SWITCHES_AND_DACS          ; Clear switches and DACs
1212   
1213                                ; Turn on the low voltages (+/- 6.5V, +/- 16.5V) and then delay awhile
1214      P:0002F9 P:0002F9 0A8902            BCLR    #LVEN,X:HDR                       ; Set these signals to DSP outputs
1215      P:0002FA P:0002FA 44F400            MOVE              #10000000,X0
                            989680
1216      P:0002FC P:0002FC 06C400            DO      X0,*+3                            ; Wait 100 millisec for settling
                            0002FE
1217      P:0002FE P:0002FE 000000            NOP
1218   
1219      P:0002FF P:0002FF 0A8980            JCLR    #PWROK,X:HDR,PWR_ERR              ; Test if the power turned on properly
                            000309
1220      P:000301 P:000301 0D030C            JSR     <SET_BIASES                       ; Turn on the DC bias supplies
1221      P:000302 P:000302 60F400            MOVE              #CONT_RST,R0            ; --> continuous readout state
                            0002B7
1222      P:000304 P:000304 601F00            MOVE              R0,X:<IDL_ADR
1223      P:000305 P:000305 60F400            MOVE              #RESET_SERIAL,R0        ; Clear the Rockwell internal registers
                            000052
1224      P:000307 P:000307 0D03FA            JSR     <CLOCK
1225      P:000308 P:000308 0C008F            JMP     <FINISH
1226   
1227                                ; The power failed to turn on because of an error on the power control board
1228      P:000309 P:000309 0A8922  PWR_ERR   BSET    #LVEN,X:HDR                       ; Turn off the low voltage emable line
1229      P:00030A P:00030A 0A8923            BSET    #HVEN,X:HDR                       ; Turn off the high voltage emable line
1230      P:00030B P:00030B 0C008D            JMP     <ERROR
1231   
1232                                ; Set all the DC bias voltages and video processor offset values, reading
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timIRmisc.asm  Page 24



1233                                ;   them from the 'DACS' table
1234                                SET_BIASES
1235      P:00030C P:00030C 012F23            BSET    #3,X:PCRD                         ; Turn on the serial clock
1236      P:00030D P:00030D 0A0F01            BCLR    #1,X:<LATCH                       ; Separate updates of clock driver
1237      P:00030E P:00030E 0A0F20            BSET    #CDAC,X:<LATCH                    ; Disable clearing of DACs
1238      P:00030F P:00030F 0A0F22            BSET    #ENCK,X:<LATCH                    ; Enable clock and DAC output switches
1239      P:000310 P:000310 09F0B5            MOVEP             X:LATCH,Y:WRLATCH       ; Write it to the hardware
                            00000F
1240      P:000312 P:000312 0D0405            JSR     <PAL_DLY                          ; Delay for all this to happen
1241   
1242                                ; Read DAC values from a table, and write them to the DACs
1243      P:000313 P:000313 60F400            MOVE              #DACS,R0                ; Get starting address of DAC values
                            000057
1244      P:000315 P:000315 000000            NOP
1245      P:000316 P:000316 000000            NOP
1246      P:000317 P:000317 065840            DO      Y:(R0)+,L_DAC                     ; Repeat Y:(R0)+ times
                            00031B
1247      P:000319 P:000319 5ED800            MOVE                          Y:(R0)+,A   ; Read the table entry
1248      P:00031A P:00031A 0D020C            JSR     <XMIT_A_WORD                      ; Transmit it to TIM-A-STD
1249      P:00031B P:00031B 000000            NOP
1250                                L_DAC
1251   
1252                                ; Let the DAC voltages all ramp up before exiting
1253      P:00031C P:00031C 44F400            MOVE              #400000,X0
                            061A80
1254      P:00031E P:00031E 06C400            DO      X0,*+3                            ; 4 millisec delay
                            000320
1255      P:000320 P:000320 000000            NOP
1256      P:000321 P:000321 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1257      P:000322 P:000322 00000C            RTS
1258   
1259                                SET_BIAS_VOLTAGES
1260      P:000323 P:000323 0D030C            JSR     <SET_BIASES
1261      P:000324 P:000324 0C008F            JMP     <FINISH
1262   
1263      P:000325 P:000325 0D0327  CLR_SWS   JSR     <CLEAR_SWITCHES_AND_DACS          ; Clear switches and DACs
1264      P:000326 P:000326 0C008F            JMP     <FINISH
1265   
1266                                CLEAR_SWITCHES_AND_DACS
1267      P:000327 P:000327 0A0F00            BCLR    #CDAC,X:<LATCH                    ; Clear all the DACs
1268      P:000328 P:000328 0A0F02            BCLR    #ENCK,X:<LATCH                    ; Disable all the output switches
1269      P:000329 P:000329 09F0B5            MOVEP             X:LATCH,Y:WRLATCH       ; Write it to the hardware
                            00000F
1270      P:00032B P:00032B 012F23            BSET    #3,X:PCRD                         ; Turn the serial clock on
1271      P:00032C P:00032C 56F400            MOVE              #$0C3000,A              ; Value of integrate speed and gain switches
                            0C3000
1272      P:00032E P:00032E 20001B            CLR     B
1273      P:00032F P:00032F 241000            MOVE              #$100000,X0             ; Increment over board numbers for DAC write
s
1274      P:000330 P:000330 45F400            MOVE              #$001000,X1             ; Increment over board numbers for WRSS writ
es
                            001000
1275      P:000332 P:000332 060F80            DO      #15,L_VIDEO                       ; Fifteen video processor boards maximum
                            000339
1276      P:000334 P:000334 0D020C            JSR     <XMIT_A_WORD                      ; Transmit A to TIM-A-STD
1277      P:000335 P:000335 200040            ADD     X0,A
1278      P:000336 P:000336 5F7000            MOVE                          B,Y:WRSS
                            FFFFF3
1279      P:000338 P:000338 0D0405            JSR     <PAL_DLY                          ; Delay for the serial data transmission
1280      P:000339 P:000339 200068            ADD     X1,B
1281                                L_VIDEO
1282      P:00033A P:00033A 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timIRmisc.asm  Page 25



1283      P:00033B P:00033B 00000C            RTS
1284   
1285                                ; Fast clear of FPA, executed as a command
1286                                CLEAR
1287      P:00033C P:00033C 0D025B            JSR     <RESET_ARRAY
1288      P:00033D P:00033D 000000            NOP
1289      P:00033E P:00033E 0C008F            JMP     <FINISH
1290   
1291                                ; Start the exposure timer and monitor its progress
1292                                EXPOSE
1293      P:00033F P:00033F 07F40E            MOVEP             #0,X:TLR0               ; Load 0 into counter timer
                            000000
1294      P:000341 P:000341 579000            MOVE              X:<EXPOSURE_TIME,B
1295      P:000342 P:000342 20000B            TST     B                                 ; Special test for zero exposure time
1296      P:000343 P:000343 0EA34F            JEQ     <END_EXP                          ; Don't even start an exposure
1297      P:000344 P:000344 01418C            SUB     #1,B                              ; Timer counts from X:TCPR0+1 to zero
1298      P:000345 P:000345 010F20            BSET    #TIM_BIT,X:TCSR0                  ; Enable the timer #0
1299      P:000346 P:000346 577000            MOVE              B,X:TCPR0
                            FFFF8D
1300      P:000348 P:000348 330700  CHK_RCV   MOVE              #<COM_BUF,R3            ; The beginning of the command buffer
1301      P:000349 P:000349 0A8989            JCLR    #EF,X:HDR,CHK_TIM                 ; Simple test for fast execution
                            00034D
1302      P:00034B P:00034B 0D00A5            JSR     <GET_RCV                          ; Check for an incoming command
1303      P:00034C P:00034C 0E805D            JCS     <PRC_RCV                          ; If command is received, go check it
1304      P:00034D P:00034D 018F95  CHK_TIM   JCLR    #TCF,X:TCSR0,CHK_RCV              ; Wait for timer to equal compare value
                            000348
1305      P:00034F P:00034F 010F00  END_EXP   BCLR    #TIM_BIT,X:TCSR0                  ; Disable the timer
1306      P:000350 P:000350 0AE780            JMP     (R7)                              ; This contains the return address
1307   
1308   
1309                                ; Stop the exposure (set the timer status bit)
1310                                STOP_EXPOSURE
1311      P:000351 P:000351 010F00            BCLR    #TIM_BIT,X:TCSR0                  ; Disable the DSP exposure timer
1312      P:000352 P:000352 010F29            BSET    #TRM,X:TCSR0                      ; To be sure it will load TLR0
1313      P:000353 P:000353 579000            MOVE              X:<EXPOSURE_TIME,B
1314      P:000354 P:000354 0140CC            SUB     #100,B                            ; set elapsed time to exp_time - 100 msec
                            000064
1315      P:000356 P:000356 000000            NOP
1316      P:000357 P:000357 577000            MOVE              B,X:TCR0
                            FFFF8C
1317      P:000359 P:000359 07700C            MOVEP             X:TCR0,X:TLR0           ; Restore elapsed exposure time
                            FFFF8E
1318      P:00035B P:00035B 010F20            BSET    #TIM_BIT,X:TCSR0                  ; Re-enable the DSP exposure timer
1319      P:00035C P:00035C 0C008F            JMP     <FINISH
1320   
1321                                ; Start the exposure and initiate FPA readout
1322                                START_EXPOSURE
1323      P:00035D P:00035D 57F400            MOVE              #$020102,B              ; Initialize the PCI image address
                            020102
1324      P:00035F P:00035F 0D00EB            JSR     <XMT_WRD
1325      P:000360 P:000360 57F400            MOVE              #'IIA',B
                            494941
1326      P:000362 P:000362 0D00EB            JSR     <XMT_WRD
1327   
1328      P:000363 P:000363 305A00            MOVE              #TST_RCV,R0             ; Process commands, don't idle,
1329      P:000364 P:000364 601F00            MOVE              R0,X:<IDL_ADR           ;    during the exposure
1330      P:000365 P:000365 67F400            MOVE              #L_SEX1,R7              ; Return address at end of exposure
                            000374
1331   
1332                                ; Clear the FPA and process commands from the host
1333      P:000367 P:000367 0D025B            JSR     <RESET_ARRAY                      ; Clear out the FPA
1334                                                                                    ; (comment out to have non-destructive reads
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timIRmisc.asm  Page 26



)
1335   
1336   
1337                                ; test if CDS bit is set (MS 040609)
1338      P:000368 P:000368 0B00B1            JSSET   #CDS_MODE,X:STATUS,RD_ARRAY
                            00022C
1339   
1340                                FOWLER
1341      P:00036A P:00036A 060C40            DO      Y:<NFS1,F1_END
                            00036E
1342      P:00036C P:00036C 0D022C            JSR     <RD_ARRAY
1343      P:00036D P:00036D 0D02E7            JSR     <DELAY1
1344      P:00036E P:00036E 000000            NOP
1345                                F1_END
1346      P:00036F P:00036F 67F400            MOVE              #L_SEX1,R7              ; Return address at end of exposure
                            000374
1347      P:000371 P:000371 060440            DO      Y:<NUTR,S_UTR
                            000379
1348      P:000373 P:000373 0C033F            JMP     <EXPOSE
1349                                L_SEX1
1350      P:000374 P:000374 060640            DO      Y:<NFS,F2_END
                            000378
1351      P:000376 P:000376 0D022C            JSR     <RD_ARRAY
1352      P:000377 P:000377 0D02E7            JSR     <DELAY1
1353      P:000378 P:000378 000000            NOP
1354                                F2_END
1355      P:000379 P:000379 000000            NOP
1356                                S_UTR
1357      P:00037A P:00037A 000000            NOP
1358      P:00037B P:00037B 0C0054            JMP     <START
1359   
1360                                ; Set the desired exposure time
1361                                SET_EXPOSURE_TIME
1362      P:00037C P:00037C 46DB00            MOVE              X:(R3)+,Y0
1363      P:00037D P:00037D 461000            MOVE              Y0,X:EXPOSURE_TIME
1364      P:00037E P:00037E 07F00D            MOVEP             X:EXPOSURE_TIME,X:TCPR0
                            000010
1365      P:000380 P:000380 0C008F            JMP     <FINISH
1366   
1367                                ; Read the time remaining until the exposure ends
1368                                READ_EXPOSURE_TIME
1369      P:000381 P:000381 47F000            MOVE              X:TCR0,Y1               ; Read elapsed exposure time
                            FFFF8C
1370      P:000383 P:000383 0C0090            JMP     <FINISH1
1371   
1372                                ; Pause the exposure - just stop the timer
1373                                PAUSE_EXPOSURE
1374      P:000384 P:000384 07700C            MOVEP             X:TCR0,X:ELAPSED_TIME   ; Save the elapsed exposure time
                            000011
1375      P:000386 P:000386 010F00            BCLR    #TIM_BIT,X:TCSR0                  ; Disable the DSP exposure timer
1376      P:000387 P:000387 0C008F            JMP     <FINISH
1377   
1378                                ; Resume the exposure - just restart the timer
1379                                RESUME_EXPOSURE
1380      P:000388 P:000388 010F29            BSET    #TRM,X:TCSR0                      ; To be sure it will load TLR0
1381      P:000389 P:000389 07700C            MOVEP             X:TCR0,X:TLR0           ; Restore elapsed exposure time
                            FFFF8E
1382      P:00038B P:00038B 010F20            BSET    #TIM_BIT,X:TCSR0                  ; Re-enable the DSP exposure timer
1383      P:00038C P:00038C 0C008F            JMP     <FINISH
1384   
1385                                ; See if the command issued during readout is a 'ABR'. If not continue readout
1386                                CHK_ABORT_COMMAND
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timIRmisc.asm  Page 27



1387      P:00038D P:00038D 44DB00            MOVE              X:(R3)+,X0              ; Get candidate header
1388      P:00038E P:00038E 56F400            MOVE              #$000202,A
                            000202
1389      P:000390 P:000390 200045            CMP     X0,A
1390      P:000391 P:000391 0E2399            JNE     <RD_CONT
1391      P:000392 P:000392 0D00A5  WT_COM    JSR     <GET_RCV                          ; Get the command
1392      P:000393 P:000393 0E0392            JCC     <WT_COM
1393      P:000394 P:000394 44DB00            MOVE              X:(R3)+,X0              ; Get candidate header
1394      P:000395 P:000395 56F400            MOVE              #'ABR',A
                            414252
1395      P:000397 P:000397 200045            CMP     X0,A
1396      P:000398 P:000398 0EA2E1            JEQ     <ABR_RDC
1397      P:000399 P:000399 330700  RD_CONT   MOVE              #<COM_BUF,R3            ; Continue reading out the FPA
1398      P:00039A P:00039A 227400            MOVE              R3,R4
1399      P:00039B P:00039B 0C02E2            JMP     <CONTINUE_READ
1400   
1401                                ; Special ending after abort command to send a 'DON' to the host computer
1402                                RDFPA_END_ABORT
1403      P:00039C P:00039C 44F400            MOVE              #100000,X0
                            0186A0
1404      P:00039E P:00039E 06C400            DO      X0,*+3                            ; Wait one millisec
                            0003A0
1405      P:0003A0 P:0003A0 000000            NOP
1406      P:0003A1 P:0003A1 0A0082            JCLR    #IDLMODE,X:<STATUS,NO_IDL2        ; Don't idle after readout
                            0003A7
1407      P:0003A3 P:0003A3 60F400            MOVE              #CONT_RST,R0
                            0002B7
1408      P:0003A5 P:0003A5 601F00            MOVE              R0,X:<IDL_ADR
1409      P:0003A6 P:0003A6 0C03A9            JMP     <RDC_E2
1410      P:0003A7 P:0003A7 305A00  NO_IDL2   MOVE              #TST_RCV,R0
1411      P:0003A8 P:0003A8 601F00            MOVE              R0,X:<IDL_ADR
1412      P:0003A9 P:0003A9 0D03F7  RDC_E2    JSR     <WAIT_TO_FINISH_CLOCKING
1413      P:0003AA P:0003AA 0A0004            BCLR    #ST_RDC,X:<STATUS                 ; Set status to not reading out
1414   
1415      P:0003AB P:0003AB 44F400            MOVE              #$000202,X0             ; Send 'DON' to the host computer
                            000202
1416      P:0003AD P:0003AD 440500            MOVE              X0,X:<HEADER
1417      P:0003AE P:0003AE 0C008F            JMP     <FINISH
1418   
1419                                ; Exit continuous readout mode
1420      P:0003AF P:0003AF 305A00  STP       MOVE              #TST_RCV,R0
1421      P:0003B0 P:0003B0 601F00            MOVE              R0,X:<IDL_ADR
1422      P:0003B1 P:0003B1 0C008F            JMP     <FINISH
1423   
1424                                ; Abort exposure - stop the timer and resume continuous readout mode
1425                                ABORT_EXPOSURE
1426      P:0003B2 P:0003B2 010F00            BCLR    #TIM_BIT,X:TCSR0                  ; Disable the DSP exposure timer
1427      P:0003B3 P:0003B3 0D0255            JSR     <RDA_END
1428      P:0003B4 P:0003B4 0C0054            JMP     <START
1429   
1430                                ; Generate a synthetic image by simply incrementing the pixel counts
1431                                SYNTHETIC_IMAGE
1432      P:0003B5 P:0003B5 200013            CLR     A
1433      P:0003B6 P:0003B6 060240            DO      Y:<NROWS,LPR_TST                  ; Loop over each line readout
                            0003C2
1434      P:0003B8 P:0003B8 060140            DO      Y:<NCOLS,LSR_TST                  ; Loop over number of pixels per line
                            0003C1
1435      P:0003BA P:0003BA 0614A0            REP     #20                               ; #20 => 1.0 microsec per pixel
1436      P:0003BB P:0003BB 000000            NOP
1437      P:0003BC P:0003BC 014180            ADD     #1,A                              ; Pixel data = Pixel data + 1
1438      P:0003BD P:0003BD 000000            NOP
1439      P:0003BE P:0003BE 21CF00            MOVE              A,B
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timIRmisc.asm  Page 28



1440      P:0003BF P:0003BF 000000            NOP
1441      P:0003C0 P:0003C0 0D03C5            JSR     <XMT_PIX                          ;  transmit them
1442      P:0003C1 P:0003C1 000000            NOP
1443                                LSR_TST
1444      P:0003C2 P:0003C2 000000            NOP
1445                                LPR_TST
1446      P:0003C3 P:0003C3 0D0255            JSR     <RDA_END                          ; Normal exit
1447      P:0003C4 P:0003C4 0C0054            JMP     <START
1448   
1449                                ; Transmit the 16-bit pixel datum in B1 to the host computer
1450      P:0003C5 P:0003C5 0C1DA1  XMT_PIX   ASL     #16,B,B
1451      P:0003C6 P:0003C6 000000            NOP
1452      P:0003C7 P:0003C7 216500            MOVE              B2,X1
1453      P:0003C8 P:0003C8 0C1D91            ASL     #8,B,B
1454      P:0003C9 P:0003C9 000000            NOP
1455      P:0003CA P:0003CA 216400            MOVE              B2,X0
1456      P:0003CB P:0003CB 000000            NOP
1457      P:0003CC P:0003CC 09C532            MOVEP             X1,Y:WRFO
1458      P:0003CD P:0003CD 09C432            MOVEP             X0,Y:WRFO
1459      P:0003CE P:0003CE 00000C            RTS
1460   
1461                                ; Test the hardware to read A/D values directly into the DSP instead
1462                                ;   of using the SXMIT option, A/Ds #2 and 3.
1463      P:0003CF P:0003CF 57F000  READ_AD   MOVE              X:(RDAD+2),B
                            010002
1464      P:0003D1 P:0003D1 0C1DA1            ASL     #16,B,B
1465      P:0003D2 P:0003D2 000000            NOP
1466      P:0003D3 P:0003D3 216500            MOVE              B2,X1
1467      P:0003D4 P:0003D4 0C1D91            ASL     #8,B,B
1468      P:0003D5 P:0003D5 000000            NOP
1469      P:0003D6 P:0003D6 216400            MOVE              B2,X0
1470      P:0003D7 P:0003D7 000000            NOP
1471      P:0003D8 P:0003D8 09C532            MOVEP             X1,Y:WRFO
1472      P:0003D9 P:0003D9 09C432            MOVEP             X0,Y:WRFO
1473      P:0003DA P:0003DA 060AA0            REP     #10
1474      P:0003DB P:0003DB 000000            NOP
1475      P:0003DC P:0003DC 57F000            MOVE              X:(RDAD+3),B
                            010003
1476      P:0003DE P:0003DE 0C1DA1            ASL     #16,B,B
1477      P:0003DF P:0003DF 000000            NOP
1478      P:0003E0 P:0003E0 216500            MOVE              B2,X1
1479      P:0003E1 P:0003E1 0C1D91            ASL     #8,B,B
1480      P:0003E2 P:0003E2 000000            NOP
1481      P:0003E3 P:0003E3 216400            MOVE              B2,X0
1482      P:0003E4 P:0003E4 000000            NOP
1483      P:0003E5 P:0003E5 09C532            MOVEP             X1,Y:WRFO
1484      P:0003E6 P:0003E6 09C432            MOVEP             X0,Y:WRFO
1485      P:0003E7 P:0003E7 060AA0            REP     #10
1486      P:0003E8 P:0003E8 000000            NOP
1487      P:0003E9 P:0003E9 00000C            RTS
1488   
1489                                ; Alert the PCI interface board that images are coming soon
1490                                PCI_READ_IMAGE
1491      P:0003EA P:0003EA 57F400            MOVE              #$020104,B              ; Send header word to the FO transmitter
                            020104
1492      P:0003EC P:0003EC 0D00EB            JSR     <XMT_WRD
1493      P:0003ED P:0003ED 57F400            MOVE              #'RDA',B
                            524441
1494      P:0003EF P:0003EF 0D00EB            JSR     <XMT_WRD
1495      P:0003F0 P:0003F0 5FF000            MOVE                          Y:NCOLS,B   ; Number of columns to read
                            000001
1496      P:0003F2 P:0003F2 0D00EB            JSR     <XMT_WRD
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timIRmisc.asm  Page 29



1497      P:0003F3 P:0003F3 5FF000            MOVE                          Y:NROWS,B   ; Number of rows to read
                            000002
1498      P:0003F5 P:0003F5 0D00EB            JSR     <XMT_WRD
1499      P:0003F6 P:0003F6 00000C            RTS
1500   
1501                                ; Wait for the clocking to be complete before proceeding
1502                                WAIT_TO_FINISH_CLOCKING
1503      P:0003F7 P:0003F7 01ADA1            JSET    #SSFEF,X:PDRD,*                   ; Wait for the SS FIFO to be empty
                            0003F7
1504      P:0003F9 P:0003F9 00000C            RTS
1505   
1506                                ; This MOVEP instruction executes in 30 nanosec, 20 nanosec for the MOVEP,
1507                                ;   and 10 nanosec for the wait state that is required for SRAM writes and
1508                                ;   FIFO setup times. It looks reliable, so will be used for now.
1509   
1510                                ; Core subroutine for clocking out FPA charge
1511                                CLOCK
1512      P:0003FA P:0003FA 0A898E            JCLR    #SSFHF,X:HDR,*                    ; Only write to FIFO if < half full
                            0003FA
1513      P:0003FC P:0003FC 000000            NOP
1514      P:0003FD P:0003FD 0A898E            JCLR    #SSFHF,X:HDR,CLOCK                ; Guard against metastability
                            0003FA
1515      P:0003FF P:0003FF 4CD800            MOVE                          Y:(R0)+,X0  ; # of waveform entries
1516      P:000400 P:000400 06C400            DO      X0,CLK1                           ; Repeat X0 times
                            000402
1517      P:000402 P:000402 09D8F3            MOVEP             Y:(R0)+,Y:WRSS          ; 30 nsec Write the waveform to the SS
1518                                CLK1
1519      P:000403 P:000403 000000            NOP
1520      P:000404 P:000404 00000C            RTS                                       ; Return from subroutine
1521   
1522                                ; Work on later !!!
1523                                ; This will execute in 20 nanosec, 10 nanosec for the MOVE and 10 nanosec
1524                                ;   the one wait state that is required for SRAM writes and FIFO setup times.
1525                                ;   However, the assembler gives a WARNING about pipeline problems if its
1526                                ;   put in a DO loop. This problem needs to be resolved later, and in the
1527                                ;   meantime I'll be using the MOVEP instruction.
1528   
1529                                ;  MOVE  #$FFFF03,R6    ; Write switch states, X:(R6)
1530                                ;  MOVE  Y:(R0)+,A  A,X:(R6)
1531   
1532   
1533                                ; Delay for serial writes to the PALs and DACs by 8 microsec
1534      P:000405 P:000405 062083  PAL_DLY   DO      #800,DLY                          ; Wait 8 usec for serial data transmission
                            000407
1535      P:000407 P:000407 000000            NOP
1536      P:000408 P:000408 000000  DLY       NOP
1537      P:000409 P:000409 00000C            RTS
1538   
1539                                ; Let the host computer read the controller configuration
1540                                READ_CONTROLLER_CONFIGURATION
1541      P:00040A P:00040A 4F8700            MOVE                          Y:<CONFIG,Y1 ; Just transmit the configuration
1542      P:00040B P:00040B 0C0090            JMP     <FINISH1
1543   
1544                                ; Read and return Y:NCOLS
1545                                READ_NCOLS
1546      P:00040C P:00040C 4FF000            MOVE                          Y:NCOLS,Y1
                            000001
1547      P:00040E P:00040E 0C0090            JMP     <FINISH1
1548   
1549                                ; Read and return Y:NROWS
1550                                READ_NROWS
1551      P:00040F P:00040F 4FF000            MOVE                          Y:NROWS,Y1
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timIRmisc.asm  Page 30



                            000002
1552      P:000411 P:000411 0C0090            JMP     <FINISH1
1553   
1554                                ; Read and return Y:NCHAN
1555                                READ_NCHAN
1556      P:000412 P:000412 4FF000            MOVE                          Y:NCHAN,Y1
                            00000B
1557      P:000414 P:000414 0C0090            JMP     <FINISH1
1558   
1559                                ; Read and return Y:SXMIT
1560                                READ_SXMIT
1561                                                                                    ;MOVE    Y:SXMIT,Y1
1562                                                                                    ;MOVE    Y:CXMIT,Y1
1563      P:000415 P:000415 4FF000            MOVE                          Y:OFFS0,Y1
                            000095
1564      P:000417 P:000417 0C0090            JMP     <FINISH1
1565   
1566                                ; Set the desired number of readout channels
1567                                SET_NCHAN
1568      P:000418 P:000418 46DB00            MOVE              X:(R3)+,Y0              ; get the requested number of channels
1569      P:000419 P:000419 4E0B00            MOVE                          Y0,Y:<NCHAN ; update the value of the variable
1570                                                                                    ; change the OFFSET value according to the n
umber of channels
1571                                                                                    ; 1 channel -> OFFS0=OFFD0 + OFFV1
1572                                                                                    ; 2 channels-> OFFS0=OFFD0 + OFFV2
1573      P:00041A P:00041A 5EF000            MOVE                          Y:OFFD0,A
                            0000A9
1574      P:00041C P:00041C 0A0BE0            JSET    #0,Y:<NCHAN,NCHN1                 ; if bit 0 is set, 1 channel output, goto lo
op
                            000425
1575                                                                                    ; default to 2 channels
1576      P:00041E P:00041E 4CF000            MOVE                          Y:SXMITV2,X0 ; 2 pixels for 2 video boards
                            0000A6
1577      P:000420 P:000420 4C7000            MOVE                          X0,Y:CXMIT  ;
                            00002A
1578      P:000422 P:000422 4CF000            MOVE                          Y:OFFV2,X0  ; OFFSET2CH
                            0000A8
1579      P:000424 P:000424 0C042B            JMP     <C_NCHN
1580      P:000425 P:000425 4CF000  NCHN1     MOVE                          Y:SXMITV1,X0 ; 2 pixels for 2 1ideo board
                            0000A5
1581      P:000427 P:000427 4C7000            MOVE                          X0,Y:CXMIT  ;
                            00002A
1582      P:000429 P:000429 4CF000            MOVE                          Y:OFFV1,X0  ; OFFSET1CH
                            0000A7
1583      P:00042B P:00042B 000000  C_NCHN    NOP
1584      P:00042C P:00042C 200040            ADD     X0,A                              ; $0e0000+OFFSET2CH
1585      P:00042D P:00042D 000000            NOP
1586      P:00042E P:00042E 012F23            BSET    #3,X:PCRD                         ; Turn the serial clock on
1587      P:00042F P:00042F 000000            NOP
1588      P:000430 P:000430 000000            NOP
1589      P:000431 P:000431 5E7000            MOVE                          A,Y:OFFS0   ; update the value
                            000095
1590      P:000433 P:000433 0D020C            JSR     <XMIT_A_WORD                      ; Transmit it to TIM-A-STD
1591      P:000434 P:000434 0D0405            JSR     <PAL_DLY                          ; Delay for the serial data transmission
1592      P:000435 P:000435 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1593      P:000436 P:000436 0C008F            JMP     <FINISH
1594   
1595   
1596                                ; Set the video processor gain and integrator speed for all video boards
1597                                ;  Command syntax is  SGN  #GAIN  #SPEED, #GAIN = 1, 2, 5 or 10
1598                                ;                #SPEED = 0 for slow, 1 for fast
1599      P:000437 P:000437 012F23  ST_GAIN   BSET    #3,X:PCRD                         ; Turn the serial clock on
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timIRmisc.asm  Page 31



1600      P:000438 P:000438 56DB00            MOVE              X:(R3)+,A               ; Gain value (1,2,5 or 10)
1601      P:000439 P:000439 44F400            MOVE              #>1,X0
                            000001
1602      P:00043B P:00043B 200045            CMP     X0,A                              ; Check for gain = x1
1603      P:00043C P:00043C 0E2440            JNE     <STG2
1604      P:00043D P:00043D 57F400            MOVE              #>$77,B
                            000077
1605      P:00043F P:00043F 0C0454            JMP     <STG_A
1606      P:000440 P:000440 44F400  STG2      MOVE              #>2,X0                  ; Check for gain = x2
                            000002
1607      P:000442 P:000442 200045            CMP     X0,A
1608      P:000443 P:000443 0E2447            JNE     <STG5
1609      P:000444 P:000444 57F400            MOVE              #>$BB,B
                            0000BB
1610      P:000446 P:000446 0C0454            JMP     <STG_A
1611      P:000447 P:000447 44F400  STG5      MOVE              #>5,X0                  ; Check for gain = x5
                            000005
1612      P:000449 P:000449 200045            CMP     X0,A
1613      P:00044A P:00044A 0E244E            JNE     <STG10
1614      P:00044B P:00044B 57F400            MOVE              #>$DD,B
                            0000DD
1615      P:00044D P:00044D 0C0454            JMP     <STG_A
1616      P:00044E P:00044E 44F400  STG10     MOVE              #>10,X0                 ; Check for gain = x10
                            00000A
1617      P:000450 P:000450 200045            CMP     X0,A
1618      P:000451 P:000451 0E208D            JNE     <ERROR
1619      P:000452 P:000452 57F400            MOVE              #>$EE,B
                            0000EE
1620   
1621      P:000454 P:000454 56DB00  STG_A     MOVE              X:(R3)+,A               ; Integrator Speed (0 for slow, 1 for fast)
1622      P:000455 P:000455 000000            NOP
1623      P:000456 P:000456 0ACC00            JCLR    #0,A1,STG_B
                            00045B
1624      P:000458 P:000458 0ACD68            BSET    #8,B1
1625      P:000459 P:000459 000000            NOP
1626      P:00045A P:00045A 0ACD69            BSET    #9,B1
1627      P:00045B P:00045B 44F400  STG_B     MOVE              #$0C3C00,X0
                            0C3C00
1628      P:00045D P:00045D 20004A            OR      X0,B
1629      P:00045E P:00045E 000000            NOP
1630      P:00045F P:00045F 5F0000            MOVE                          B,Y:<GAIN   ; Store the GAIN value for later use
1631   
1632                                ; Send this same value to 15 video processor boards whether they exist or not
1633      P:000460 P:000460 241000            MOVE              #$100000,X0             ; Increment value
1634      P:000461 P:000461 21EE00            MOVE              B,A
1635      P:000462 P:000462 060F80            DO      #15,STG_LOOP
                            000466
1636      P:000464 P:000464 0D020C            JSR     <XMIT_A_WORD                      ; Transmit A to TIM-A-STD
1637      P:000465 P:000465 0D0405            JSR     <PAL_DLY                          ; Wait for SSI and PAL to be empty
1638      P:000466 P:000466 200048            ADD     X0,B                              ; Increment the video processor board number
1639                                STG_LOOP
1640      P:000467 P:000467 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1641      P:000468 P:000468 0C008F            JMP     <FINISH
1642      P:000469 P:000469 56DB00  ERR_SGN   MOVE              X:(R3)+,A
1643      P:00046A P:00046A 0C008D            JMP     <ERROR
1644   
1645                                ; Set the video processor boards in DC-coupled diagnostic mode or not
1646                                ; Command syntax is  SDC # # = 0 for normal operation
1647                                ;           # = 1 for DC coupled diagnostic mode
1648      P:00046B P:00046B 012F23  SET_DC    BSET    #3,X:PCRD                         ; Turn the serial clock on
1649      P:00046C P:00046C 44DB00            MOVE              X:(R3)+,X0
1650      P:00046D P:00046D 0AC420            JSET    #0,X0,SDC_1
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timIRmisc.asm  Page 32



                            000472
1651      P:00046F P:00046F 0A004A            BCLR    #10,Y:<GAIN
1652      P:000470 P:000470 0A004B            BCLR    #11,Y:<GAIN
1653      P:000471 P:000471 0C0474            JMP     <SDC_A
1654      P:000472 P:000472 0A006A  SDC_1     BSET    #10,Y:<GAIN
1655      P:000473 P:000473 0A006B            BSET    #11,Y:<GAIN
1656      P:000474 P:000474 241000  SDC_A     MOVE              #$100000,X0             ; Increment value
1657      P:000475 P:000475 060F80            DO      #15,SDC_LOOP
                            00047A
1658      P:000477 P:000477 5E8000            MOVE                          Y:<GAIN,A
1659      P:000478 P:000478 0D020C            JSR     <XMIT_A_WORD                      ; Transmit A to TIM-A-STD
1660      P:000479 P:000479 0D0405            JSR     <PAL_DLY                          ; Wait for SSI and PAL to be empty
1661      P:00047A P:00047A 200048            ADD     X0,B                              ; Increment the video processor board number
1662                                SDC_LOOP
1663      P:00047B P:00047B 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1664      P:00047C P:00047C 0C008F            JMP     <FINISH
1665   
1666                                ; Set a particular DAC numbers, for setting DC bias voltages, clock driver
1667                                ;   voltages and video processor offset
1668                                ;
1669                                ; SBN  #BOARD  #DAC  ['CLK' or 'VID']  voltage
1670                                ;
1671                                ;           #BOARD is from 0 to 15
1672                                ;           #DAC number
1673                                ;           #voltage is from 0 to 4095
1674   
1675                                SET_BIAS_NUMBER                                     ; Set bias number
1676      P:00047D P:00047D 012F23            BSET    #3,X:PCRD                         ; Turn on the serial clock
1677      P:00047E P:00047E 56DB00            MOVE              X:(R3)+,A               ; First argument is board number, 0 to 15
1678      P:00047F P:00047F 0614A0            REP     #20
1679      P:000480 P:000480 200033            LSL     A
1680      P:000481 P:000481 000000            NOP
1681      P:000482 P:000482 21C400            MOVE              A,X0
1682      P:000483 P:000483 56DB00            MOVE              X:(R3)+,A               ; Second argument is DAC number
1683      P:000484 P:000484 060EA0            REP     #14
1684      P:000485 P:000485 200033            LSL     A
1685      P:000486 P:000486 200042            OR      X0,A
1686      P:000487 P:000487 57DB00            MOVE              X:(R3)+,B               ; Third argument is 'VID' or 'CLK' string
1687      P:000488 P:000488 44F400            MOVE              #'VID',X0
                            564944
1688      P:00048A P:00048A 20004D            CMP     X0,B
1689      P:00048B P:00048B 0E2490            JNE     <CLK_DRV
1690      P:00048C P:00048C 0ACC73            BSET    #19,A1                            ; Set bits to mean video processor DAC
1691      P:00048D P:00048D 000000            NOP
1692      P:00048E P:00048E 0ACC72            BSET    #18,A1
1693      P:00048F P:00048F 0C0494            JMP     <VID_BRD
1694      P:000490 P:000490 44F400  CLK_DRV   MOVE              #'CLK',X0
                            434C4B
1695      P:000492 P:000492 20004D            CMP     X0,B
1696      P:000493 P:000493 0E249E            JNE     <ERR_SBN
1697      P:000494 P:000494 21C400  VID_BRD   MOVE              A,X0
1698      P:000495 P:000495 56DB00            MOVE              X:(R3)+,A               ; Fourth argument is voltage value, 0 to $ff
f
1699      P:000496 P:000496 46F400            MOVE              #$000FFF,Y0             ; Mask off just 12 bits to be sure
                            000FFF
1700      P:000498 P:000498 200056            AND     Y0,A
1701      P:000499 P:000499 200042            OR      X0,A
1702      P:00049A P:00049A 0D020C            JSR     <XMIT_A_WORD                      ; Transmit A to TIM-A-STD
1703      P:00049B P:00049B 0D0405            JSR     <PAL_DLY                          ; Wait for the number to be sent
1704      P:00049C P:00049C 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1705      P:00049D P:00049D 0C008F            JMP     <FINISH
1706      P:00049E P:00049E 56DB00  ERR_SBN   MOVE              X:(R3)+,A               ; Read and discard the fourth argument
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timIRmisc.asm  Page 33



1707      P:00049F P:00049F 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1708      P:0004A0 P:0004A0 0C008D            JMP     <ERROR
1709   
1710                                ; Specify the MUX value to be output on the clock driver board
1711                                ; Command syntax is  SMX  #clock_driver_board #MUX1 #MUX2
1712                                ;           #clock_driver_board from 0 to 15
1713                                ;           #MUX1, #MUX2 from 0 to 23
1714   
1715      P:0004A1 P:0004A1 012F23  SET_MUX   BSET    #3,X:PCRD                         ; Turn on the serial clock
1716      P:0004A2 P:0004A2 56DB00            MOVE              X:(R3)+,A               ; Clock driver board number
1717      P:0004A3 P:0004A3 0614A0            REP     #20
1718      P:0004A4 P:0004A4 200033            LSL     A
1719      P:0004A5 P:0004A5 44F400            MOVE              #$003000,X0
                            003000
1720      P:0004A7 P:0004A7 200042            OR      X0,A
1721      P:0004A8 P:0004A8 000000            NOP
1722      P:0004A9 P:0004A9 21C500            MOVE              A,X1                    ; Move here for storage
1723   
1724                                ; Get the first MUX number
1725      P:0004AA P:0004AA 56DB00            MOVE              X:(R3)+,A               ; Get the first MUX number
1726      P:0004AB P:0004AB 0AF0A9            JLT     ERR_SM1
                            0004EF
1727      P:0004AD P:0004AD 44F400            MOVE              #>24,X0                 ; Check for argument less than 32
                            000018
1728      P:0004AF P:0004AF 200045            CMP     X0,A
1729      P:0004B0 P:0004B0 0AF0A1            JGE     ERR_SM1
                            0004EF
1730      P:0004B2 P:0004B2 21CF00            MOVE              A,B
1731      P:0004B3 P:0004B3 44F400            MOVE              #>7,X0
                            000007
1732      P:0004B5 P:0004B5 20004E            AND     X0,B
1733      P:0004B6 P:0004B6 44F400            MOVE              #>$18,X0
                            000018
1734      P:0004B8 P:0004B8 200046            AND     X0,A
1735      P:0004B9 P:0004B9 0E24BC            JNE     <SMX_1                            ; Test for 0 <= MUX number <= 7
1736      P:0004BA P:0004BA 0ACD63            BSET    #3,B1
1737      P:0004BB P:0004BB 0C04C7            JMP     <SMX_A
1738      P:0004BC P:0004BC 44F400  SMX_1     MOVE              #>$08,X0
                            000008
1739      P:0004BE P:0004BE 200045            CMP     X0,A                              ; Test for 8 <= MUX number <= 15
1740      P:0004BF P:0004BF 0E24C2            JNE     <SMX_2
1741      P:0004C0 P:0004C0 0ACD64            BSET    #4,B1
1742      P:0004C1 P:0004C1 0C04C7            JMP     <SMX_A
1743      P:0004C2 P:0004C2 44F400  SMX_2     MOVE              #>$10,X0
                            000010
1744      P:0004C4 P:0004C4 200045            CMP     X0,A                              ; Test for 16 <= MUX number <= 23
1745      P:0004C5 P:0004C5 0E24EF            JNE     <ERR_SM1
1746      P:0004C6 P:0004C6 0ACD65            BSET    #5,B1
1747      P:0004C7 P:0004C7 20006A  SMX_A     OR      X1,B1                             ; Add prefix to MUX numbers
1748      P:0004C8 P:0004C8 000000            NOP
1749      P:0004C9 P:0004C9 21A700            MOVE              B1,Y1
1750   
1751                                ; Add on the second MUX number
1752      P:0004CA P:0004CA 56DB00            MOVE              X:(R3)+,A               ; Get the next MUX number
1753      P:0004CB P:0004CB 0E908D            JLT     <ERROR
1754      P:0004CC P:0004CC 44F400            MOVE              #>24,X0                 ; Check for argument less than 32
                            000018
1755      P:0004CE P:0004CE 200045            CMP     X0,A
1756      P:0004CF P:0004CF 0E108D            JGE     <ERROR
1757      P:0004D0 P:0004D0 0606A0            REP     #6
1758      P:0004D1 P:0004D1 200033            LSL     A
1759      P:0004D2 P:0004D2 000000            NOP
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timIRmisc.asm  Page 34



1760      P:0004D3 P:0004D3 21CF00            MOVE              A,B
1761      P:0004D4 P:0004D4 44F400            MOVE              #$1C0,X0
                            0001C0
1762      P:0004D6 P:0004D6 20004E            AND     X0,B
1763      P:0004D7 P:0004D7 44F400            MOVE              #>$600,X0
                            000600
1764      P:0004D9 P:0004D9 200046            AND     X0,A
1765      P:0004DA P:0004DA 0E24DD            JNE     <SMX_3                            ; Test for 0 <= MUX number <= 7
1766      P:0004DB P:0004DB 0ACD69            BSET    #9,B1
1767      P:0004DC P:0004DC 0C04E8            JMP     <SMX_B
1768      P:0004DD P:0004DD 44F400  SMX_3     MOVE              #>$200,X0
                            000200
1769      P:0004DF P:0004DF 200045            CMP     X0,A                              ; Test for 8 <= MUX number <= 15
1770      P:0004E0 P:0004E0 0E24E3            JNE     <SMX_4
1771      P:0004E1 P:0004E1 0ACD6A            BSET    #10,B1
1772      P:0004E2 P:0004E2 0C04E8            JMP     <SMX_B
1773      P:0004E3 P:0004E3 44F400  SMX_4     MOVE              #>$400,X0
                            000400
1774      P:0004E5 P:0004E5 200045            CMP     X0,A                              ; Test for 16 <= MUX number <= 23
1775      P:0004E6 P:0004E6 0E208D            JNE     <ERROR
1776      P:0004E7 P:0004E7 0ACD6B            BSET    #11,B1
1777      P:0004E8 P:0004E8 200078  SMX_B     ADD     Y1,B                              ; Add prefix to MUX numbers
1778      P:0004E9 P:0004E9 000000            NOP
1779      P:0004EA P:0004EA 21AE00            MOVE              B1,A
1780      P:0004EB P:0004EB 0D020C            JSR     <XMIT_A_WORD                      ; Transmit A to TIM-A-STD
1781      P:0004EC P:0004EC 0D0405            JSR     <PAL_DLY                          ; Delay for all this to happen
1782      P:0004ED P:0004ED 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1783      P:0004EE P:0004EE 0C008F            JMP     <FINISH
1784      P:0004EF P:0004EF 56DB00  ERR_SM1   MOVE              X:(R3)+,A
1785      P:0004F0 P:0004F0 012F03            BCLR    #3,X:PCRD                         ; Turn the serial clock off
1786      P:0004F1 P:0004F1 0C008D            JMP     <ERROR
1787   
1788                                ;******************************************************************************
1789                                ; Specify either global or row-by-row reset
1790                                SELECT_RESET_MODE
1791      P:0004F2 P:0004F2 44DB00            MOVE              X:(R3)+,X0              ; Get the command argument
1792      P:0004F3 P:0004F3 0AC420            JSET    #0,X0,SRM_SET
                            0004F7
1793      P:0004F5 P:0004F5 0A0010            BCLR    #RST_MODE,X:STATUS                ; Global reset is in effect
1794      P:0004F6 P:0004F6 0C008F            JMP     <FINISH
1795      P:0004F7 P:0004F7 0A0030  SRM_SET   BSET    #RST_MODE,X:STATUS                ; Row-by-row reset is in effect
1796      P:0004F8 P:0004F8 0C008F            JMP     <FINISH
1797   
1798                                ;******************************************************************************
1799                                ; Set number of Fowler samples per frame
1800                                SET_NUMBER_OF_FOWLER_SAMPLES
1801      P:0004F9 P:0004F9 44DB00            MOVE              X:(R3)+,X0
1802      P:0004FA P:0004FA 4C0600            MOVE                          X0,Y:<NFS   ; Number of Fowler samples
1803      P:0004FB P:0004FB 208E00            MOVE              X0,A
1804      P:0004FC P:0004FC 014184            SUB     #1,A
1805      P:0004FD P:0004FD 000000            NOP
1806      P:0004FE P:0004FE 5E0C00            MOVE                          A,Y:<NFS1
1807      P:0004FF P:0004FF 0C008F            JMP     <FINISH
1808   
1809                                ;******************************************************************************
1810                                ; OLD CDS MODE IS BELOW, THIS IS WHAT LEACH DELIVERS
1811                                ; Specify readout either before and after exposure (CDS) or only after
1812                                SELECT_SAMPLING_MODE
1813      P:000500 P:000500 44DB00            MOVE              X:(R3)+,X0              ; Get the command argument
1814      P:000501 P:000501 0AC420            JSET    #0,X0,CDS_SET
                            000505
1815      P:000503 P:000503 0A0011            BCLR    #CDS_MODE,X:STATUS                ; Single sampling is in effect
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timIRmisc.asm  Page 35



1816      P:000504 P:000504 0C008F            JMP     <FINISH
1817      P:000505 P:000505 0A0031  CDS_SET   BSET    #CDS_MODE,X:STATUS                ; Double correlated sampling is
1818      P:000506 P:000506 0C008F            JMP     <FINISH                           ;  in effect
1819   
1820                                ;******************************************************************************
1821                                ; Specify whether the coadder board does arithmetic (PTR = 0) or whether
1822                                ;   it just passes the data right through = do nothing here
1823                                SELECT_PASS_THROUGH_READOUT
1824      P:000507 P:000507 44DB00            MOVE              X:(R3)+,X0
1825      P:000508 P:000508 0C008F            JMP     <FINISH
1826   
1827   
1828                                ;******************************************************************************
1829                                ; Clear Array (M. Schubnell October 2003)
1830                                ; This should clear the array when the 'Clear Array' button in the main Voodoo
1831                                ; window is pressed.
1832                                CLR_ARRAY
1833      P:000509 P:000509 0D027E            JSR     <RESET_FAST_ARRAY
1834                                ;  JSR   <RESET_ARRAY
1835      P:00050A P:00050A 0C008F            JMP     <FINISH
1836                                ;******************************************************************************
1837                                ; Set number of exposures for up-the-ramp readout mode; also, pass-through
1838                                ;   mode is always implemented in up-the-ramp.
1839                                SET_UP_THE_RAMP
1840      P:00050B P:00050B 44DB00            MOVE              X:(R3)+,X0
1841      P:00050C P:00050C 4C0400            MOVE                          X0,Y:<NUTR
1842      P:00050D P:00050D 449200            MOVE              X:<ONE,X0               ; load one into X0
1843      P:00050E P:00050E 4C0500            MOVE                          X0,Y:<IUTR  ; reset this so that Fowler and CDS work aft
er UTR
1844      P:00050F P:00050F 0C008F            JMP     <FINISH
1845   
1846                                ;******************************************************************************
1847                                ; Specify the number of coadds.
1848                                SET_NUMBER_OF_COADDS
1849      P:000510 P:000510 44DB00            MOVE              X:(R3)+,X0
1850      P:000511 P:000511 4C0300            MOVE                          X0,Y:<NCOADDS
1851      P:000512 P:000512 0C008F            JMP     <FINISH
1852   
1853                                ;******************************************************************************
1854                                ; Transmit a serial command to the Rockwell array
1855                                SERIAL_COMMAND
1856      P:000513 P:000513 56DB00            MOVE              X:(R3)+,A               ; Get the command
1857      P:000514 P:000514 60F400            MOVE              #CSB_LOW,R0             ; Enable the serial command link
                            000040
1858      P:000516 P:000516 0D03FA            JSR     <CLOCK
1859      P:000517 P:000517 061080            DO      #16,L_SERCOM                      ; The commands are 16 bits long
                            000523
1860      P:000519 P:000519 0ACC2F            JSET    #15,A1,B_SET                      ; Check if the bit is set or cleared
                            00051F
1861      P:00051B P:00051B 60F400            MOVE              #CLOCK_SERIAL_ZERO,R0   ; Transmit a zero bit
                            00004E
1862      P:00051D P:00051D 0D03FA            JSR     <CLOCK
1863      P:00051E P:00051E 0C0522            JMP     <NEXTBIT
1864      P:00051F P:00051F 60F400  B_SET     MOVE              #CLOCK_SERIAL_ONE,R0    ; Transmit a one bit
                            00004A
1865      P:000521 P:000521 0D03FA            JSR     <CLOCK
1866      P:000522 P:000522 200033  NEXTBIT   LSL     A                                 ; Get the next most significant bit
1867      P:000523 P:000523 000000            NOP
1868                                L_SERCOM
1869      P:000524 P:000524 60F400            MOVE              #CSB_HIGH,R0            ; Disable the serial command link
                            000043
1870      P:000526 P:000526 0D03FA            JSR     <CLOCK
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  timIRmisc.asm  Page 36



1871      P:000527 P:000527 0C008F            JMP     <FINISH
1872   
1873                                ;******************************************************************************
1874                                ; Assert MAINRESETB to clear all serial commands to default settings
1875                                CLEAR_SERIAL_SETTINGS
1876      P:000528 P:000528 60F400            MOVE              #RESET_SERIAL,R0
                            000052
1877      P:00052A P:00052A 0D03FA            JSR     <CLOCK
1878      P:00052B P:00052B 0C008F            JMP     <FINISH
1879   
1880   
1881   
1882                                 TIMBOOT_X_MEMORY
1883      00052C                              EQU     @LCV(L)
1884   
1885                                ;  ****************  Setup memory tables in X: space ********************
1886   
1887                                ; Define the address in P: space where the table of constants begins
1888   
1889                                          IF      @SCP("HOST","HOST")
1890      X:000036 X:000036                   ORG     X:END_COMMAND_TABLE,X:END_COMMAND_TABLE
1891                                          ENDIF
1892   
1893                                          IF      @SCP("HOST","ROM")
1895                                          ENDIF
1896   
1897      X:000036 X:000036                   DC      'SEX',START_EXPOSURE              ; Voodoo and CCDTool start exposure
1898      X:000038 X:000038                   DC      'STX',STOP_EXPOSURE               ; stop (and read) exposure
1899      X:00003A X:00003A                   DC      'STP',STP                         ; Exit continuous RUN mode
1900      X:00003C X:00003C                   DC      'PON',POWER_ON                    ; Turn on all camera biases and clocks
1901      X:00003E X:00003E                   DC      'POF',POWER_OFF                   ; Turn +/- 15V power supplies off
1902      X:000040 X:000040                   DC      'SBN',SET_BIAS_NUMBER
1903      X:000042 X:000042                   DC      'SMX',SET_MUX                     ; Set MUX number on clock driver board
1904      X:000044 X:000044                   DC      'DON',START                       ; Nothing special
1905      X:000046 X:000046                   DC      'SET',SET_EXPOSURE_TIME           ; Set exposure time
1906      X:000048 X:000048                   DC      'RET',READ_EXPOSURE_TIME          ; Read elapsed time
1907      X:00004A X:00004A                   DC      'AEX',ABORT_EXPOSURE
1908                                ;    DC 'ABR',ABR_RDC
1909      X:00004C X:00004C                   DC      'RCC',READ_CONTROLLER_CONFIGURATION
1910   
1911                                                                                    ; Special SNAP commands
1912      X:00004E X:00004E                   DC      'SRM',SELECT_RESET_MODE
1913      X:000050 X:000050                   DC      'CDS',SELECT_SAMPLING_MODE
1914      X:000052 X:000052                   DC      'SFS',SET_NUMBER_OF_FOWLER_SAMPLES
1915      X:000054 X:000054                   DC      'SNC',SET_NUMBER_OF_COADDS
1916      X:000056 X:000056                   DC      'SUR',SET_UP_THE_RAMP
1917      X:000058 X:000058                   DC      'SPT',SELECT_PASS_THROUGH_READOUT
1918      X:00005A X:00005A                   DC      'SER',SERIAL_COMMAND
1919      X:00005C X:00005C                   DC      'CLS',CLEAR_SERIAL_SETTINGS
1920      X:00005E X:00005E                   DC      'CLR',CLR_ARRAY
1921      X:000060 X:000060                   DC      'RD0',READ_NCOLS
1922      X:000062 X:000062                   DC      'RD1',READ_NROWS
1923      X:000064 X:000064                   DC      'RD2',READ_NCHAN
1924      X:000066 X:000066                   DC      'RD3',READ_SXMIT
1925      X:000068 X:000068                   DC      'SCH',SET_NCHAN
1926   
1927                                 END_APPLICATON_COMMAND_TABLE
1928      00006A                              EQU     @LCV(L)
1929   
1930                                          IF      @SCP("HOST","HOST")
1931      000021                    NUM_COM   EQU     (@LCV(R)-COM_TBL_R)/2             ; Number of boot +
1932                                                                                    ;  application commands
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  tim.asm  Page 37



1933      00034D                    EXPOSING  EQU     CHK_TIM                           ; Address if exposing
1934                                 CONTINUE_READING
1935      100000                              EQU     CONT_RD                           ; Address if reading out
1936                                          ENDIF
1937   
1938                                          IF      @SCP("HOST","ROM")
1940                                          ENDIF
1941   
1942                                ; Now let's go for the timing waveform tables
1943                                          IF      @SCP("HOST","HOST")
1944      Y:000000 Y:000000                   ORG     Y:0,Y:0
1945                                          ENDIF
1946   
1947      Y:000000 Y:000000         GAIN      DC      END_APPLICATON_Y_MEMORY-@LCV(L)-1
1948      Y:000001 Y:000001         NCOLS     DC      1024                              ; Number of columns
1949      Y:000002 Y:000002         NROWS     DC      1024                              ; Number of rows
1950      Y:000003 Y:000003         NCOADDS   DC      1                                 ; Number of frames to coadd, set in SNC
1951      Y:000004 Y:000004         NUTR      DC      1                                 ; Number of up-the-ramp frames
1952      Y:000005 Y:000005         IUTR      DC      1                                 ; Number of up-the-ramp frames, minus 1
1953      Y:000006 Y:000006         NFS       DC      1                                 ; Number of Fowler samples
1954      Y:000007 Y:000007         CONFIG    DC      CC                                ; Controller configuration
1955      Y:000008 Y:000008         ICOADD    DC      0
1956      Y:000009 Y:000009         IBUFFER   DC      0
1957      Y:00000A Y:00000A         RD_MODE   DC      0
1958      Y:00000B Y:00000B         NCHAN     DC      2                                 ; Number of output channels (2 default, 1 in
 window mode)
1959      Y:00000C Y:00000C         NFS1      DC      0                                 ; Number of first Fowler samples
1960   
1961                                ; Include the waveform table for the designated IR array
1962                                          INCLUDE "H1RG.waveforms"                  ; Readout and clocking waveform file
1963                                ;----------------------------------------------------------------------------
1964                                ;
1965                                ; Revision History
1966                                ;
1967                                ;  1.0  SBeland 03/02/04 VRESET and VBIASGATE are on the clock driver DB37
1968                                ;       connector on pins 18 and 19 (instead of the second video processor
1969                                ;       board which we don't have)
1970                                ;  1.1  MDrosback 04-21-04 Changed Offset on video processor to account for
1971                                ;       grounded differential outputs (used value of 1.65 V taken from H1RG
1972                                ;       manual)
1973                                ;  1.2  See H1RGApril27.waveforms for previous version; changing OFFSET back to
1974                                ;       672, changing voltages to match what RSC controller reads
1975                                ;  1.3  Modified to match Schubnell's H2IR8.waveforms file (SBeland 06/05)
1976                                ;
1977                                ;----------------------------------------------------------------------------
1978                                ;
1979                                ; Miscellaneous definitions
1980      000000                    VID0      EQU     $000000                           ; Video board select = 0
1981      002000                    CLK2      EQU     $002000                           ; Select bottom of clock driver board
1982      003000                    CLK3      EQU     $003000                           ; Select top of clock driver board
1983   
1984                                ;SXMIT      EQU     $00F040    ; Transmit 2 pixels from two video boards
1985                                ; on the sci_grade chip, changing from 2 to 1 channel changes the bias
1986      00F040                    SXMIT2    EQU     $00F040                           ; Transmit 2 pixels from two video boards
1987      00F000                    SXMIT1    EQU     $00F000                           ; Transmit 1 pixel from one video board
1988   
1989      000000                    DLY0      EQU     $000000                           ; no delay
1990      8F0000                    DLY1      EQU     $8F0000                           ; = 5 microsec
1991      050000                    DLYS      EQU     $050000                           ; Serial command delay time = 200 nanosec
1992   
1993                                ; Define switch state bits for CLK2 = "bottom" of clock board = channels 0 to 11
1994      000001                    FSYNCB    EQU     1                                 ; Frame Sync
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  H1RG.waveforms  Page 38



1995      000002                    LSYNCB    EQU     2                                 ; Line Sync
1996      000004                    VCLK      EQU     4                                 ; Vertical Clock
1997      000008                    HCLK      EQU     8                                 ; Horizontal (fast pixel) Clock
1998      000010                    RESETEN   EQU     $10                               ; Reset enable
1999      000020                    READEN    EQU     $20                               ; Read enable
2000      000040                    TSTCLK    EQU     $40                               ; Test signal for integrator latch
2001   
2002                                ; Define switch state bits for CLK3 = "top" of clock board = channels 12 to 23
2003      000001                    MAINRESETB EQU    1                                 ; Reset the serial register to default value
s
2004      000002                    CSB       EQU     2                                 ; Serial Chip Select Bar
2005      000004                    DATACLK   EQU     4                                 ; Serial Data Clock
2006      000008                    DATAIN    EQU     8                                 ; Serial Data In (serial)
2007   
2008                                ; Voltage tables
2009      3.331700E+000             VIDEOmax  EQU     3.3317                            ; Maximum clock voltage, should be 3.3 volts
 for H1RG.
2010      3.331700E+000             CLKmax    EQU     3.3317                            ; Maximum video board DC bias voltage, shoul
d be 3.3 volts.
2011      2.050000E+000             VSOURCE   EQU     2.05                              ; Source load voltage on the ARC46 video boa
rd
2012      3.100000E+000             CLK_HI    EQU     3.10                              ; High clock voltage
2013      1.000000E-001             CLK_LO    EQU     0.10                              ; Low clock voltage
2014      0.000000E+000             CLK_ZERO  EQU     0.00                              ; Zero volts for power-on sequence
2015                                ; A/D converter voltage reference
2016                                ;ADREF      EQU     1.75   ; Between 0 and 2.5 volts. 2.5 = min. gain (buffered mode)
2017      1.700000E+000             ADREF     EQU     1.70                              ; Between 0 and 2.5 volts. 2.5 = min. gain t
esting buffered mode 01/29/2007
2018   
2019                                ; The ARC46 video board is strapped for unipolar DC bias outputs.
2020                                ;   The rail voltage is VIDEOmax set by a reference resistor.
2021      3.300000E+000             VDD       EQU     3.30                              ; Digital positive power supply, was 3.28
2022      3.280000E+000             VDDA      EQU     3.28                              ; Analog positive power supply, was 3.28
2023      0.000000E+000             CELLDRAIN EQU     0.0                               ; pixel source-follower drain node, was 0.2 
(RSC said 0.0)
2024      0.000000E+000             DRAIN     EQU     0.0                               ; output source-follower drain node, was 0.0
2025      3.280000E+000             VBIASPOWER EQU    3.28                              ; was 3.28 pixel source-follower source node
, was 3.28
2026      3.500000E-001             DSUB      EQU     0.35                              ; was 2.20 Detector substrate voltage, was 0
.4
2027      1.000000E-001             VRESET    EQU     0.10                              ; was 0.40 Detector reset voltage. was 0.15
2028      2.200000E+000             VBIASGATE EQU     2.20                              ; was 2.4 pixel source-follower bias voltage
--was 2.3
2029                                                                                    ; was 3.0, was 2.2 (Apr 27)
2030      0.000000E+000             VBIAS7    EQU     0.00                              ; voltage used for the complement inputs (SB
eland Aug05)
2031   
2032   
2033                                ; Video processor offset values
2034                                ;OFFSET         EQU     $2b0    ; unbuffered value
2035                                ;OFFSET         EQU     $30f    ; buffered value ENG chip  (SB 04-07-23)
2036                                ;OFFSET         EQU     $2E1    ; unbuffered with ADREF=1.75 (ENG chip)
2037                                ;OFFSET         EQU     $362    ; buffered value SCI chip
2038                                ;OFFSET1CH      EQU     $348    ; unbuffered value SCI chip  (1 channel TEST)
2039                                ;OFFSET2CH      EQU     $331    ; unbuffered value SCI chip  (2 channels DEFAULT)
2040                                ;OFFSET1CH      EQU     $36C    ; unbuffered value SCI chip  (March 15/06 SBeland)
2041                                ;OFFSET2CH      EQU     $342    ; unbuffered value SCI chip  (March 15/06 SBeland)
2042      00032D                    OFFSET1CH EQU     $32D                              ; buffered value SCI chip  (March 05/07 SBel
and)
2043      000331                    OFFSET2CH EQU     $331                              ; buffered value SCI chip (TEST 01/28/2007)
2044      000458                    OFFSET2CHA EQU    $458                              ; unbuffered value SCI chip  (2 channels DEF
AULT)
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  H1RG.waveforms  Page 39



2045      0002B0                    OFFSET2CHB EQU    $2B0                              ; unbuffered value SCI chip  (2 channels DEF
AULT)
2046      000331                    OFFSET    EQU     OFFSET2CH
2047      000331                    OFFSET0   EQU     OFFSET2CH
2048      000331                    OFFSET1   EQU     OFFSET2CH
2049      000331                    OFFSET2   EQU     OFFSET
2050      000331                    OFFSET3   EQU     OFFSET
2051      000331                    OFFSET4   EQU     OFFSET
2052      000331                    OFFSET5   EQU     OFFSET
2053      000331                    OFFSET6   EQU     OFFSET
2054      000331                    OFFSET7   EQU     OFFSET
2055      000331                    OFFSET8   EQU     OFFSET
2056      000331                    OFFSET9   EQU     OFFSET
2057      000331                    OFFSET10  EQU     OFFSET
2058      000331                    OFFSET11  EQU     OFFSET
2059      000331                    OFFSET12  EQU     OFFSET
2060      000331                    OFFSET13  EQU     OFFSET
2061      000331                    OFFSET14  EQU     OFFSET
2062      000331                    OFFSET15  EQU     OFFSET
2063   
2064                                ; Copy of the clocking bit definition for easy reference
2065                                ;    DC    CLK2+DELAY+FSYNCB+LSYNCB+VCLK+HCLK+RESETEN+READEN
2066                                ;    DC    CLK3+DELAY+MAINRESETB+CSB+DATACLK+DATAIN
2067   
2068                                FRAME_INIT
2069      Y:00000D Y:00000D                   DC      END_FRAME_INIT-FRAME_INIT-1
2070      Y:00000E Y:00000E                   DC      CLK2+$880000+FSYNCB+LSYNCB+0000+0000+0000000+000000 ; HCLK low (MS added 6-3-0
4)
2071      Y:00000F Y:00000F                   DC      CLK2+DLY0+FSYNCB+LSYNCB+0000+0000+0000000+000000 ; Pulse FSYNCB low (5us)
2072      Y:000010 Y:000010                   DC      CLK2+DLY1+000000+LSYNCB+0000+0000+0000000+000000
2073      Y:000011 Y:000011                   DC      CLK2+DLY0+FSYNCB+LSYNCB+0000+0000+0000000+000000
2074                                END_FRAME_INIT
2075   
2076                                CLOCK_ROW
2077      Y:000012 Y:000012                   DC      END_CLOCK_ROW-CLOCK_ROW-1
2078      Y:000013 Y:000013                   DC      CLK2+DLY1+FSYNCB+LSYNCB+0000+0000+0000000+READEN ;
2079      Y:000014 Y:000014                   DC      CLK2+DLY1+FSYNCB+000000+VCLK+0000+0000000+READEN ; Pulse LSYNC low
2080      Y:000015 Y:000015                   DC      CLK2+DLY1+FSYNCB+LSYNCB+0000+0000+0000000+READEN ;   and VCLK high
2081                                END_CLOCK_ROW
2082   
2083                                ; pulse VCLK high to generater FRAMECHK pulse at end of read
2084                                OVERCLOCK_ROW
2085      Y:000016 Y:000016                   DC      END_OVERCLOCK_ROW-OVERCLOCK_ROW-1
2086      Y:000017 Y:000017                   DC      CLK2+DLY1+FSYNCB+LSYNCB+0000+0000+0000000+READEN ; Bring READEN low
2087      Y:000018 Y:000018                   DC      CLK2+DLY1+FSYNCB+LSYNCB+VCLK+0000+0000000+000000 ; Pulse VCLK high
2088      Y:000019 Y:000019                   DC      CLK2+DLY1+FSYNCB+LSYNCB+0000+0000+0000000+000000
2089      Y:00001A Y:00001A                   DC      CLK2+DLY0+FSYNCB+LSYNCB+0000+0000+0000000+000000
2090                                END_OVERCLOCK_ROW
2091   
2092                                RESET_ROW
2093      Y:00001B Y:00001B                   DC      END_RESET_ROW-RESET_ROW-1
2094      Y:00001C Y:00001C                   DC      CLK2+DLY1+FSYNCB+LSYNCB+0000+0000+RESETEN+000000 ; Pulse LSYNCB low,
2095      Y:00001D Y:00001D                   DC      CLK2+DLY1+FSYNCB+000000+VCLK+0000+RESETEN+000000 ;   VCLK high, keeping
2096      Y:00001E Y:00001E                   DC      CLK2+DLY1+FSYNCB+LSYNCB+0000+0000+RESETEN+000000 ;   RESETEN high
2097                                END_RESET_ROW
2098   
2099                                ; Video processor bit definitions
2100                                ;    Bit #3 = Move A/D data to FIFO  (high going edge)
2101                                ;    Bit #2 = A/D Convert            (low going edge to start conversion)
2102                                ;    Bit #1 = Reset Integrator       (=0 to reset)
2103                                ;    Bit #0 = Integrate              (=0 to integrate)
2104   
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  H1RG.waveforms  Page 40



2105                                CLK_COL_AND_READ
2106      Y:00001F Y:00001F                   DC      END_CLK_COL_AND_READ-CLK_COL_AND_READ-1
2107      Y:000020 Y:000020                   DC      CLK2+$2D0000+FSYNCB+LSYNCB+0000+0000+0000000+READEN ; keep HCLK low (1800ns)
2108      Y:000021 Y:000021                   DC      CLK2+$040000+FSYNCB+LSYNCB+0000+HCLK+0000000+READEN ; HCLK high (160ns) doesn'
t change pixels
2109      Y:000022 Y:000022                   DC      VID0+$050000+%0101                ; Reset integrator (200ns)
2110      Y:000023 Y:000023                   DC      VID0+$2D0000+%0111                ; Settling time (1800ns)
2111      Y:000024 Y:000024                   DC      VID0+$4B0000+%0110                ; Integrate (3000ns)
2112      Y:000025 Y:000025                   DC      VID0+$0A0000+%0111                ; Settling time (400ns)
2113      Y:000026 Y:000026                   DC      VID0+$020000+%0011                ; Start A/D conversion
2114      Y:000027 Y:000027                   DC      VID0+$2E0000+%0111                ; A/D conversion time (1840ns)
2115      Y:000028 Y:000028                   DC      VID0+$000000+%1111                ; A/D data--> FIFO
2116      Y:000029 Y:000029                   DC      CLK2+$050000+FSYNCB+LSYNCB+0000+HCLK+0000000+READEN ; HCLK High (200ns delay f
or A/D)
2117      Y:00002A Y:00002A         CXMIT     DC      SXMIT2                            ; Transmit 2 pixels
2118      Y:00002B Y:00002B                   DC      VID0+$050000+%0111                ; Settling time (200ns was 400)
2119      Y:00002C Y:00002C                   DC      CLK2+$040000+FSYNCB+LSYNCB+0000+0000+0000000+READEN ; clock to next pixel (160
ns)
2120                                END_CLK_COL_AND_READ
2121   
2122   
2123                                ; Advance the pixel clock without A/D conversions at the beginning of each line
2124                                FIRST_HCLKS
2125      Y:00002D Y:00002D                   DC      END_FIRST_HCLKS-FIRST_HCLKS-1
2126      Y:00002E Y:00002E                   DC      CLK2+$8F0000+FSYNCB+LSYNCB+0000+HCLK+0000000+READEN ; Cycle HCLK
2127      Y:00002F Y:00002F                   DC      CLK2+$8F0000+FSYNCB+LSYNCB+0000+0000+0000000+READEN
2128      Y:000030 Y:000030                   DC      CLK2+$8F0000+FSYNCB+LSYNCB+0000+HCLK+0000000+READEN
2129      Y:000031 Y:000031                   DC      CLK2+$000000+FSYNCB+LSYNCB+0000+0000+0000000+READEN ; clocks 1st real pixel
2130                                END_FIRST_HCLKS
2131   
2132                                ; Bring HCLK low at the end of each line
2133                                LAST_HCLKS
2134      Y:000032 Y:000032                   DC      END_LAST_HCLKS-LAST_HCLKS-1
2135      Y:000033 Y:000033                   DC      CLK2+DLY0+FSYNCB+LSYNCB+0000+0000+0000000+READEN
2136                                END_LAST_HCLKS
2137   
2138                                ; Match the nominal pixel clocking (5 us)
2139                                CLOCK_ONLY
2140      Y:000034 Y:000034                   DC      END_CLOCK_ONLY-CLOCK_ONLY-1
2141      Y:000035 Y:000035                   DC      CLK2+DLY1+FSYNCB+LSYNCB+0000+HCLK+RESETEN+000000 ; Cycle HCLK
2142      Y:000036 Y:000036                   DC      CLK2+DLY1+FSYNCB+LSYNCB+0000+0000+RESETEN+000000
2143                                END_CLOCK_ONLY
2144   
2145                                ; HCLK for clearing, faster than usual
2146                                FAST_CLOCK_ONLY
2147      Y:000037 Y:000037                   DC      END_FAST_CLOCK_ONLY-FAST_CLOCK_ONLY-1
2148      Y:000038 Y:000038                   DC      CLK2+$180000+FSYNCB+LSYNCB+0000+HCLK+RESETEN+000000 ; Cycle HCLK
2149      Y:000039 Y:000039                   DC      CLK2+$180000+FSYNCB+LSYNCB+0000+0000+RESETEN+000000 ;
2150                                END_FAST_CLOCK_ONLY
2151   
2152                                ; the SLOW_CLOCK_ONLY is used by the RESET_ARRAY routine in tim.asm ONLY
2153                                SLOW_CLOCK_ONLY
2154      Y:00003A Y:00003A                   DC      END_SLOW_CLOCK_ONLY-SLOW_CLOCK_ONLY-1
2155      Y:00003B Y:00003B                   DC      CLK2+$3F0000+FSYNCB+LSYNCB+0000+HCLK+RESETEN+000000 ; Cycle HCLK
2156      Y:00003C Y:00003C                   DC      CLK2+$580000+FSYNCB+LSYNCB+0000+0000+RESETEN+000000 ;
2157                                END_SLOW_CLOCK_ONLY
2158   
2159                                ; Take RESETEN low at end of reset  (MS 6-3-04 added)
2160                                RESETEN_LOW
2161      Y:00003D Y:00003D                   DC      END_RESETEN_LOW-RESETEN_LOW-1
2162      Y:00003E Y:00003E                   DC      CLK2+$000000+FSYNCB+LSYNCB+0000+0000+0000000+000000
2163      Y:00003F Y:00003F                   DC      CLK2+$000000+FSYNCB+LSYNCB+0000+0000+0000000+000000
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  H1RG.waveforms  Page 41



2164                                END_RESETEN_LOW
2165   
2166   
2167                                ; The remaining commands are for the serial interface
2168      Y:000040 Y:000040         CSB_LOW   DC      END_CSB_LOW-CSB_LOW-1
2169      Y:000041 Y:000041                   DC      CLK3+DLYS+MAINRESETB+CSB+0000000+000000 ; hold CSB high for a little while
2170      Y:000042 Y:000042                   DC      CLK3+DLYS+MAINRESETB+000+0000000+000000 ; CSB low = serial
2171                                ;   DC    CLK3+DLYS+MAINRESETB+000+0000000+000000    ; CSB low = serial
2172                                END_CSB_LOW
2173   
2174                                CSB_HIGH
2175      Y:000043 Y:000043                   DC      END_CSB_HIGH-CSB_HIGH-1
2176      Y:000044 Y:000044                   DC      CLK3+DLYS+MAINRESETB+000+0000000+000000 ; hold CSB low for a little while
2177      Y:000045 Y:000045                   DC      CLK3+DLYS+MAINRESETB+CSB+0000000+000000 ; then set CSB high
2178      Y:000046 Y:000046                   DC      CLK3+DLYS+MAINRESETB+CSB+0000000+000000 ; Added extra high - SBeland June2304
2179                                ;   DC    CLK3+DLYS+MAINRESETB+CSB+0000000+000000    ;
2180                                END_CSB_HIGH
2181   
2182                                DATACLK_HIGH
2183      Y:000047 Y:000047                   DC      END_DATACLK_HIGH-DATACLK_HIGH-1
2184      Y:000048 Y:000048                   DC      CLK3+DLYS+MAINRESETB+000+DATACLK+000000 ; DATACLK high
2185      Y:000049 Y:000049                   DC      CLK3+DLY0+MAINRESETB+000+DATACLK+000000 ; DATACLK high
2186                                END_DATACLK_HIGH
2187   
2188                                CLOCK_SERIAL_ONE
2189      Y:00004A Y:00004A                   DC      END_CLOCK_SERIAL_ONE-CLOCK_SERIAL_ONE-1
2190      Y:00004B Y:00004B                   DC      CLK3+DLYS+MAINRESETB+000+0000000+DATAIN ; CSB low, DATAIN high, DATACLK low
2191      Y:00004C Y:00004C                   DC      CLK3+DLYS+MAINRESETB+000+DATACLK+DATAIN ; CSB low, DATAIN high, DATACLK high
2192      Y:00004D Y:00004D                   DC      CLK3+DLYS+MAINRESETB+000+0000000+DATAIN ; CSB low, DATAIN high, DATACLK low
2193                                END_CLOCK_SERIAL_ONE
2194   
2195                                CLOCK_SERIAL_ZERO
2196      Y:00004E Y:00004E                   DC      END_CLOCK_SERIAL_ZERO-CLOCK_SERIAL_ZERO-1
2197      Y:00004F Y:00004F                   DC      CLK3+DLYS+MAINRESETB+000+0000000+000000 ; CSB low, DATAIN low, DATACLK low
2198      Y:000050 Y:000050                   DC      CLK3+DLYS+MAINRESETB+000+DATACLK+000000 ; CSB low, DATAIN low, DATACLK high
2199      Y:000051 Y:000051                   DC      CLK3+DLYS+MAINRESETB+000+0000000+000000 ; CSB low, DATAIN low, DATACLK low
2200                                END_CLOCK_SERIAL_ZERO
2201   
2202                                ; Reset all the serial command bits to default values
2203                                RESET_SERIAL
2204      Y:000052 Y:000052                   DC      END_RESET_SERIAL-RESET_SERIAL-1
2205      Y:000053 Y:000053                   DC      CLK3+DLYS+0000000000+CSB          ; MAINRESETB low for >200 nanosec
2206      Y:000054 Y:000054                   DC      CLK3+DLYS+0000000000+CSB
2207      Y:000055 Y:000055                   DC      CLK3+DLYS+MAINRESETB+CSB
2208      Y:000056 Y:000056                   DC      CLK3+DLYS+MAINRESETB+CSB          ; added this line for MAINRESETB low for ~20
0 nanosec
2209                                                                                    ; SBeland 6-22-04 (verified on oscilloscope)
2210                                END_RESET_SERIAL
2211   
2212                                ; This is the initialization of the Bias/clock voltages completed during the
2213                                ; "Power Up" sequence in Voodoo, odds are default positions
2214                                ; Clocking voltage settings
2215      Y:000057 Y:000057         DACS      DC      END_DACS-DACS-1
2216      Y:000058 Y:000058                   DC      $2A0080                           ; DAC = unbuffered mode
2217      Y:000059 Y:000059                   DC      $200100+@CVI(CLK_HI/CLKmax*255)   ; Pin #1, FSYNCB
2218      Y:00005A Y:00005A                   DC      $200200+@CVI(CLK_LO/CLKmax*255)
2219      Y:00005B Y:00005B                   DC      $200400+@CVI(CLK_HI/CLKmax*255)   ; Pin #2, LSYNCB
2220      Y:00005C Y:00005C                   DC      $200800+@CVI(CLK_LO/CLKmax*255)
2221      Y:00005D Y:00005D                   DC      $202000+@CVI(CLK_HI/CLKmax*255)   ; Pin #3, VCLK
2222      Y:00005E Y:00005E                   DC      $204000+@CVI(CLK_LO/CLKmax*255)
2223      Y:00005F Y:00005F                   DC      $208000+@CVI(CLK_HI/CLKmax*255)   ; Pin #4, HCLK
2224      Y:000060 Y:000060                   DC      $210000+@CVI(CLK_LO/CLKmax*255)
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  H1RG.waveforms  Page 42



2225      Y:000061 Y:000061                   DC      $220100+@CVI(CLK_HI/CLKmax*255)   ; Pin #5, RESETEN
2226      Y:000062 Y:000062                   DC      $220200+@CVI(CLK_LO/CLKmax*255)
2227      Y:000063 Y:000063                   DC      $220400+@CVI(CLK_HI/CLKmax*255)   ; Pin #6, READEN
2228      Y:000064 Y:000064                   DC      $220800+@CVI(CLK_LO/CLKmax*255)
2229   
2230      Y:000065 Y:000065                   DC      $222000+@CVI(CLK_ZERO/CLKmax*255) ; Pin #7
2231      Y:000066 Y:000066                   DC      $224000+@CVI(CLK_ZERO/CLKmax*255)
2232      Y:000067 Y:000067                   DC      $228000+@CVI(CLK_ZERO/CLKmax*255) ; Pin #8
2233      Y:000068 Y:000068                   DC      $230000+@CVI(CLK_ZERO/CLKmax*255)
2234      Y:000069 Y:000069                   DC      $240100+@CVI(CLK_ZERO/CLKmax*255) ; Pin #9
2235      Y:00006A Y:00006A                   DC      $240200+@CVI(CLK_ZERO/CLKmax*255)
2236      Y:00006B Y:00006B                   DC      $240400+@CVI(CLK_ZERO/CLKmax*255) ; Pin #10
2237      Y:00006C Y:00006C                   DC      $240800+@CVI(CLK_ZERO/CLKmax*255)
2238      Y:00006D Y:00006D                   DC      $242000+@CVI(CLK_ZERO/CLKmax*255) ; Pin #11
2239      Y:00006E Y:00006E                   DC      $244000+@CVI(CLK_ZERO/CLKmax*255)
2240      Y:00006F Y:00006F                   DC      $248000+@CVI(CLK_ZERO/CLKmax*255) ; Pin #12
2241      Y:000070 Y:000070                   DC      $250000+@CVI(CLK_ZERO/CLKmax*255)
2242   
2243      Y:000071 Y:000071                   DC      $260100+@CVI(CLK_HI/CLKmax*255)   ; Pin #13, MAINRESETB
2244      Y:000072 Y:000072                   DC      $260200+@CVI(CLK_LO/CLKmax*255)
2245      Y:000073 Y:000073                   DC      $260400+@CVI(CLK_HI/CLKmax*255)   ; Pin #14, CSB
2246      Y:000074 Y:000074                   DC      $260800+@CVI(CLK_LO/CLKmax*255)
2247      Y:000075 Y:000075                   DC      $262000+@CVI(CLK_HI/CLKmax*255)   ; Pin #15, DATACLK
2248      Y:000076 Y:000076                   DC      $264000+@CVI(CLK_LO/CLKmax*255)
2249      Y:000077 Y:000077                   DC      $268000+@CVI(CLK_HI/CLKmax*255)   ; Pin #16, DATAIN
2250      Y:000078 Y:000078                   DC      $270000+@CVI(CLK_LO/CLKmax*255)
2251   
2252      Y:000079 Y:000079                   DC      $280100+@CVI(CLK_ZERO/CLKmax*255) ; Pin #17
2253      Y:00007A Y:00007A                   DC      $280200+@CVI(CLK_ZERO/CLKmax*255)
2254   
2255                                ; Added voltages on the Clock Driver pins 18 and 19 (Rev 1.0)
2256      Y:00007B Y:00007B                   DC      $280400+@CVI(VRESET/CLKmax*255)   ; Pin #18, VRESET
2257      Y:00007C Y:00007C                   DC      $280800+@CVI(VRESET/CLKmax*255)   ;
2258      Y:00007D Y:00007D                   DC      $282000+@CVI(VBIASGATE/CLKmax*255) ; Pin #19, VBIASGATE
2259      Y:00007E Y:00007E                   DC      $284000+@CVI(VBIASGATE/CLKmax*255) ;
2260   
2261      Y:00007F Y:00007F                   DC      $288000+@CVI(CLK_ZERO/CLKmax*255) ; Pin #33
2262      Y:000080 Y:000080                   DC      $290000+@CVI(CLK_ZERO/CLKmax*255)
2263      Y:000081 Y:000081                   DC      $2A0100+@CVI(CLK_ZERO/CLKmax*255) ; Pin #34
2264      Y:000082 Y:000082                   DC      $2A0200+@CVI(CLK_ZERO/CLKmax*255)
2265      Y:000083 Y:000083                   DC      $2A0400+@CVI(CLK_ZERO/CLKmax*255) ; Pin #35
2266      Y:000084 Y:000084                   DC      $2A0800+@CVI(CLK_ZERO/CLKmax*255)
2267      Y:000085 Y:000085                   DC      $2A2000+@CVI(CLK_ZERO/CLKmax*255) ; Pin #36
2268      Y:000086 Y:000086                   DC      $2A4000+@CVI(CLK_ZERO/CLKmax*255)
2269      Y:000087 Y:000087                   DC      $2A8000+@CVI(CLK_ZERO/CLKmax*255) ; Pin #37
2270      Y:000088 Y:000088                   DC      $2B0000+@CVI(CLK_ZERO/CLKmax*255)
2271   
2272                                ; A/D gain (reference voltage)
2273      Y:000089 Y:000089                   DC      $0c0000+@CVI((ADREF+VIDEOmax)/(2.0*VIDEOmax)*4095)
2274      Y:00008A Y:00008A                   DC      $1C0000+@CVI((ADREF+VIDEOmax)/(2.0*VIDEOmax)*4095)
2275      Y:00008B Y:00008B                   DC      $2C0000+@CVI((ADREF+VIDEOmax)/(2.0*VIDEOmax)*4095)
2276      Y:00008C Y:00008C                   DC      $3C0000+@CVI((ADREF+VIDEOmax)/(2.0*VIDEOmax)*4095)
2277      Y:00008D Y:00008D                   DC      $0C3003                           ; added to test the slow and fast integrator
 resistance SBeland 01/29/2007
2278   
2279                                ; Bipolar +/-5 volts output voltages, on the 15 pin DB output connector
2280      Y:00008E Y:00008E                   DC      $0C4000+@CVI((VDD+VIDEOmax)/(2.0*VIDEOmax)*4095) ; P2, Pin #1
2281      Y:00008F Y:00008F                   DC      $0C8000+@CVI((VDDA+VIDEOmax)/(2.0*VIDEOmax)*4095) ; P2, Pin #2
2282      Y:000090 Y:000090                   DC      $0CC000+@CVI((CELLDRAIN+VIDEOmax)/(2.0*VIDEOmax)*4095) ; P2, Pin #3
2283   
2284                                ; Unipolar 0 to 5 volts output voltages, video board #0
2285      Y:000091 Y:000091                   DC      $0d0000+@CVI(DRAIN/VIDEOmax*4095) ; P2, Pin #4
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  H1RG.waveforms  Page 43



2286      Y:000092 Y:000092                   DC      $0d4000+@CVI(VBIASPOWER/VIDEOmax*4095) ; P2, Pin #5
2287      Y:000093 Y:000093                   DC      $0d8000+@CVI(DSUB/VIDEOmax*4095)  ; P2, Pin #6
2288   
2289                                ; We assume that the 8-channel IR video board ARC46 is being used, that it
2290                                ;  provides the source voltage for H1RG, that JP11 has a jumper installed
2291                                ;  from pins #1 to 2, and that the source load resistors R10 and R21 are
2292                                ;  installed in all eight channels.
2293      Y:000094 Y:000094                   DC      $0dc000+@CVI(VSOURCE/VIDEOmax*4095) ; P2, Pin #7
2294   
2295                                ; For the new version of the fanout board (8/23/2005), the BIAS7 is used
2296                                ; as the complement voltages (COMP7 and COMP15).
2297                                ;    DC    $0dc000+@CVI(VBIAS7/VIDEOmax*4095)        ; P2, Pin #7
2298   
2299                                ; Unipolar 0 to 5 volts output voltages, video board #1
2300                                ;   Commented out for Revision 1.0
2301                                ;    DC    $1d0000+@CVI(VRESET/VIDEOmax*4095)        ; P2, Pin #4
2302                                ;    DC    $1d4000+@CVI(VBIASGATE/VIDEOmax*4095)        ; P2, Pin #5
2303   
2304                                ; Video processor offset voltages
2305      Y:000095 Y:000095         OFFS0     DC      $0e0000+OFFSET0                   ; Output #0 - Board #0
2306      Y:000096 Y:000096         OFFS1     DC      $0e4000+OFFSET1                   ; Output #1
2307      Y:000097 Y:000097         OFFS2     DC      $0e8000+OFFSET2                   ; Output #2
2308      Y:000098 Y:000098         OFFS3     DC      $0ec000+OFFSET3                   ; Output #3
2309      Y:000099 Y:000099         OFFS4     DC      $0f0000+OFFSET4                   ; Output #4
2310      Y:00009A Y:00009A         OFFS5     DC      $0f4000+OFFSET5                   ; Output #5
2311      Y:00009B Y:00009B         OFFS6     DC      $0f8000+OFFSET6                   ; Output #6
2312      Y:00009C Y:00009C         OFFS7     DC      $0fc000+OFFSET7                   ; Output #7
2313   
2314      Y:00009D Y:00009D         OFFS8     DC      $1e0000+OFFSET8                   ; Output #0 - Board #1
2315      Y:00009E Y:00009E         OFFS9     DC      $1e4000+OFFSET9                   ; Output #1
2316      Y:00009F Y:00009F         OFFSA     DC      $1e8000+OFFSET10                  ; Output #2
2317      Y:0000A0 Y:0000A0         OFFSB     DC      $1ec000+OFFSET11                  ; Output #3
2318      Y:0000A1 Y:0000A1         OFFSC     DC      $1f0000+OFFSET12                  ; Output #4
2319      Y:0000A2 Y:0000A2         OFFSD     DC      $1f4000+OFFSET13                  ; Output #5
2320      Y:0000A3 Y:0000A3         OFFSE     DC      $1f8000+OFFSET14                  ; Output #6
2321      Y:0000A4 Y:0000A4         OFFSF     DC      $1fc000+OFFSET15                  ; Output #7
2322   
2323                                END_DACS
2324   
2325   
2326      Y:0000A5 Y:0000A5         SXMITV1   DC      SXMIT1                            ; keep it in memory (Sbeland)
2327      Y:0000A6 Y:0000A6         SXMITV2   DC      SXMIT2                            ; keep it in memory (Sbeland)
2328      Y:0000A7 Y:0000A7         OFFV1     DC      OFFSET1CH                         ; keep it in memory (Sbeland)
2329      Y:0000A8 Y:0000A8         OFFV2     DC      OFFSET2CH                         ; keep it in memory (Sbeland)
2330      Y:0000A9 Y:0000A9         OFFD0     DC      $0e0000
2331      Y:0000AA Y:0000AA         OFFD1     DC      $0e4000
2332      Y:0000AB Y:0000AB         OFFD2     DC      $0e8000
2333      Y:0000AC Y:0000AC         OFFD3     DC      $0ec000
2334      Y:0000AD Y:0000AD         OFFD4     DC      $0f0000
2335      Y:0000AE Y:0000AE         OFFD5     DC      $0f4000
2336      Y:0000AF Y:0000AF         OFFD6     DC      $0f8000
2337      Y:0000B0 Y:0000B0         OFFD7     DC      $0fc000
2338      Y:0000B1 Y:0000B1         OFFD8     DC      $1e0000
2339      Y:0000B2 Y:0000B2         OFFD9     DC      $1e4000
2340      Y:0000B3 Y:0000B3         OFFDA     DC      $1e8000
2341      Y:0000B4 Y:0000B4         OFFDB     DC      $1ec000
2342      Y:0000B5 Y:0000B5         OFFDC     DC      $1f0000
2343      Y:0000B6 Y:0000B6         OFFDD     DC      $1f4000
2344      Y:0000B7 Y:0000B7         OFFDE     DC      $1f8000
2345      Y:0000B8 Y:0000B8         OFFDF     DC      $1fc000
2346   
2347   
Motorola DSP56300 Assembler  Version 6.3.4   07-08-14  15:31:01  tim.asm  Page 44



2348                                 END_APPLICATON_Y_MEMORY
2349      0000B9                              EQU     @LCV(L)
2350   
2351                                ;  End of program
2352                                          END

0    Errors
0    Warnings


