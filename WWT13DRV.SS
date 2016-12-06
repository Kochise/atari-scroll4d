; /// > A4TECH WWT-13 TRACKBALL DRIVER - KOSS 2002 < ///

	OPT	p=68030/68882
	comment	HEAD=7	; FastLoad

; --- EQUATE ASSEMBLY (EA) ---

; --- EQUATE DATA (ED) ---

ST4D_ED_DAY:	EQU	12	; Binary Date Format
ST4D_ED_MONTH:	EQU	05	;  FEDC BA98 7654 3210
ST4D_ED_YEAR:	EQU	2002	; %YYYY YYYM MMMD DDDD
ST4D_ED_DATE:	EQU	((ST4D_ED_YEAR-1980)<<9)|(ST4D_ED_MONTH<<5)|(ST4D_ED_DAY)

; --- EQUATE INDEX (EI) ---

; --- EQUATE SYSTEM (ES) ---

ST4D_ES_DRIVER_TYPE	EQU	0
	; 0 = MINIMAL  ST4D
	; 1 = COMPLETE ST4D

	IFNE ST4D_ES_DRIVER_TYPE ; ---------------------------,
	output	C:\SCROLL4D.ACC
	ELSEIF ; ---------------------------------------------+
	output	C:\MINIST4D.ACC
	ENDC ; -----------------------------------------------'

; /////////////////////////////////////////////////////////////////////////////
	SECTION	TEXT
; /////////////////////////////////////////////////////////////////////////////

	IFNE ST4D_ES_DRIVER_TYPE ; ---------------------------,
	BRA	ST4D_TUI_START
	dc.b	"ProgHEAD"	; ProgHEADER
	dc.w	$0100	; ProgVERSION
	dc.w	ST4D_ED_DATE	; ProgDATE
	dc.b	"ST4D",0	; ProgNAME
	dc.b	"KOSS",0	; ProgAUTHOR
	ENDC ; -----------------------------------------------'

; --- TEXT USER INIT (TUI) ---

	; WARNING WHEN STARTING AN ACCESSORY !!!
	;
	;   DataREGISTERS  AddressREGISTERS
	;     D0.l = 0          A0.l -> BasePage
	;     D1.l = 0          A1.l = 0
	;     D2.l = 0          A2.l = 0
	;     D3.l = 0          A3.l = 0
	;     D4.l = 0          A4.l = 0
	;     D5.l = 0          A5.l = 0
	;     D6.l = 0          A6.l = 0
	;     D7.l = 0       SP/A7.l = 0 <- * WARNING *
	;

ST4D_TUI_START:	move.l	SP,D0	; IF SP==0, ACC
	BNE	ST4D_TUE_NO_ERROR

	; WARNING : ACCESSORY !!!

	lea	ST4D_BSB_ACC_STACK,SP
	move.l	A0,(4,SP)	; Magie PURE !!!

	movea.l	A0,A6	; ADDR PROG BLOCK START (BASEPAGE)
	move.l	(12,A6),D0	; SIZE SECTION TEXT
	add.l	(20,A6),D0	; SIZE SECTION DATA +
	add.l	(28,A6),D0	; SIZE SECTION BSS  + (INCLUDES THE ACC STACK)
	addi.l	#256,D0	; SIZE BASEPAGE     +
	move.l	D0,-(SP)	; SIZE PROG BLOCK   =          RESERVE
	move.l	A6,-(SP)	; ADDR PROG BLOCK START        RESERVE
	clr.w	-(SP)	; RESERVED
	move.w	#$4A,-(SP)	; - M_SHRINK -
	TRAP	#1	; *** GEMDOS ***
	lea	(12,SP),SP

	; VARS

	move.w	#24,ST4D_BDB_AES_MESSAGE	; WM_ARROWED
	move.w	#-1,ST4D_BDB_4D_WHEELS

	; APPL_INIT

	lea	ST4D_BDB_AES_CONTROL,A0
	move.l	#$0A000100,D0	; - APPL_INIT -
	movep.l	D0,(1,A0)
	BSR	ST4D_TUS_AES_CALL	; *** AES ***

	move.w	ST4D_BDB_AES_INT_OUT,D0
	BMI	ST4D_TUE_PTERM	; If failed

	move.w	D0,ST4D_BDB_AES_HANDLE	; AP_ID

	; MENU REGISTER

	move.w	D0,ST4D_BDB_AES_INT_IN
	move.l	#ST4D_DDA_ACC_TITLE,ST4D_BDB_AES_ADDR_IN

	lea	ST4D_BDB_AES_CONTROL,A0
	move.l	#$23010101,D0	; - MENU_REGISTER -
	movep.l	D0,(1,A0)
	BSR	ST4D_TUS_AES_CALL	; *** AES ***

	move.w	ST4D_BDB_AES_INT_OUT,D0
	BMI	ST4D_TUE_AES_EXIT	; If failed (-1.w)

	; HARDWARE INIT

	pea	ST4D_TSS_INIT_HARD
	move.w	#$26,-(SP)	; - SUPEXEC -
	TRAP	#14	; *** XBIOS ***
	addq.l	#6,SP

	tst.w	D0	; Si Erreur (-1.w)
	BMI	ST4D_TUE_AES_EXIT

; --- TEXT USER MAIN (TUM) ---

ST4D_TUM_LOOP:	;movem.l	D0-D1/A0,ST4D_BDB_LOOP_REGS

	; TIMER 100ms ($64)
	move.l	#$00640000,ST4D_BDB_AES_INT_IN
	lea	ST4D_BDB_AES_CONTROL,A0
	move.l	#$18020100,D0	; - EVNT_TIMER -
	movep.l	D0,(1,A0)
	BSR	ST4D_TUS_AES_CALL	; *** AES ***

	;movem.l	ST4D_BDB_LOOP_REGS,D0-D1/A0

	tst.w	ST4D_BDB_4D_WHEELS
	BMI	ST4D_TUM_LOOP

	move.l	ST4D_BDB_LA_VECTOR,A5
	move.l	(-602,A5),ST4D_BDB_AES_INT_IN	; LineA GCurXY
	lea	ST4D_BDB_AES_CONTROL,A0
	move.l	#$6A020100,D0	; - WIND_FIND -
	movep.l	D0,(1,A0)
	BSR	ST4D_TUS_AES_CALL	; *** AES ***

	tst.w	ST4D_BDB_AES_INT_OUT
	BEQ	ST4D_TUM_LOOP

	move.w	ST4D_BDB_AES_INT_OUT,ST4D_BDB_AES_WIN_ID

	move.l	#ST4D_BDB_AES_MESSAGE,ST4D_BDB_AES_ADDR_IN
	move.w	#0,ST4D_BDB_AES_INT_IN	; Current Working Application
	move.w	#16,ST4D_BDB_AES_INT_IN+2	; Nb Bytes
	lea	ST4D_BDB_AES_CONTROL,A0
	move.l	#$0C020101,D0	; - APPL_WRITE -
	movep.l	D0,(1,A0)
	BSR	ST4D_TUS_AES_CALL	; *** AES ***

	move.w	#-1,ST4D_BDB_4D_WHEELS

	BRA	ST4D_TUM_LOOP

; --- TEXT USER EXIT (TUE) ---

ST4D_TUE_AES_EXIT:	lea	ST4D_BDB_AES_CONTROL,A0
	move.l	#$13000100,D0	; - APPL_EXIT -
	movep.l	D0,(1,A0)
	BSR	ST4D_TUS_AES_CALL	; *** AES ***

ST4D_TUE_NO_ERROR:	clr.w	D0	; 0 = NO ERROR
ST4D_TUE_PTERM:	move.w	D0,-(SP)
	move.w	#$4C,-(SP)	; - P_TERM -
	TRAP	#1	; *** GEMDOS ***
	; - PROGRAM TERMINATED HERE / RETURN TO DESKTOP -

; --- TEXT USER SUB (TUS) ---

ST4D_TUS_AES_CALL:	move.l	#200,D0	; AES (200)
	move.l	#ST4D_DAT_AES_PARAMS_TAB,D1
	TRAP	#2	; *** AES/VDI ***

	RTS

; -----------------------------------------------------------------------------

; --- TEXT SUPER MAIN (TSM) ---

; --- TEXT SUPER SUB (TSS) ---

ST4D_TSS_INIT_HARD:	move.l	$5A0.w,D0	; COOKIE VECTOR
	BEQ	ST4D_TSS_INIT_ERROR

	movea.l	D0,A0
	move.l	(A0),D0
	cmpi.l	#'NULL',D0
	BEQ	ST4D_TSS_INIT_ERROR

	clr.l	D1

ST4D_TSS_INIT_LOOK:	move.l	(A0),D0
	BEQ	ST4D_TSS_INIT_COOK

	addq.l	#1,D1
	addq.l	#8,A0

	BRA	ST4D_TSS_INIT_LOOK

ST4D_TSS_INIT_COOK:	move.l	#'NULL',D2
	move.l	(4,A0),D3
	move.l	D3,D6
	move.l	D1,D5
	addq.l	#2,D5
	cmp.l	D6,D5
	BGT	ST4D_TSS_INIT_ERROR

	movea.l	$5A0.w,A0

ST4D_TSS_INIT_LOOP:	move.l	(A0),D4
	move.l	(4,A0),D5
	move.l	D2,(A0)+
	move.l	D3,(A0)+
	move.l	D4,D2
	move.l	D5,D3

	DBF	D1,ST4D_TSS_INIT_LOOP

	move.l	#'ST4D',(A0)+
	move.l	#ST4D_BDB_RS_BUFFER,(A0)+
	clr.l	(A0)+
	move.l	D6,(A0)

	IFNE ST4D_ES_DRIVER_TYPE ; ---------------------------,
	move.l	$FFFF9800.w,ST4D_BDB_VIDEL_FCOL0
	move.w	$FFFF8240.w,ST4D_BDB_VIDEL_COL0
	move.w	$FFFF82AA.w,ST4D_BDB_VIDEL_VDE
	move.w	$FFFF828A.w,ST4D_BDB_VIDEL_HDE
	move.w	$FFFF82C2.w,ST4D_BDB_VIDEL_VCO
	ENDC ; -----------------------------------------------'

	; VECTORS

	move.w	SR,D7
	move.w	#$2700,SR	; STOP IRQ

	movea.l	$456.w,A0	; VBL VECTOR
	move.l	(A0),ST4D_TSS_VBL_OLD_VECTOR
	move.l	#ST4D_TSS_VBL_INTERRUPT,(A0)

	move.l	#ST4D_TSS_SCC_INTERRUPT,$180.w	; SCC VECTOR

	move.w	D7,SR

	; SCC
	
	lea	$FFFF8C85.w,A0	; SCC B CR
	move.b	#3,(A0)
	move.b	#$41,(A0)
	move.b	#4,(A0)
	move.b	#$47,(A0)
	move.b	#5,(A0)
	move.b	#$AA,(A0)
	move.b	#12,(A0)
	move.b	#$D0,(A0)
	move.b	#13,(A0)
	move.b	#0,(A0)

	; LINE A

	dc.w	$A000	; - LINEA_INIT -
	move.l	D0,ST4D_BDB_LA_VECTOR

	clr.w	D0

	RTS

ST4D_TSS_INIT_ERROR:	move.w	#-1,D0

	RTS

ST4D_TSS_VBL_OLD_VECTOR:	ds.l	1
ST4D_TSS_VBL_INTERRUPT:	JMP	([ST4D_TSS_VBL_OLD_VECTOR])

ST4D_TSS_SCC_INTERRUPT:	movem.l	D0-D2/A4-A6,ST4D_BDB_SCC_REGS

	lea	$FFFF8C85.w,A4	; SCC B CR
	movea.l	A4,A5
	addq.l	#2,A5	; SCC B DR
	lea	ST4D_BDB_RS_BUFFER,A6
	move.w	ST4D_BDB_RS_OFFSET,D2

	move.b	(A5),D0
	tst.w	D2
	BNE	ST4D_TSS_SCC_LOAD

	btst.l	#6,D0
	BEQ	ST4D_TSS_SCC_INTERRUPT_END

ST4D_TSS_SCC_LOAD:	move.b	D0,(A6,D2.w)

	addq.w	#1,D2
	cmpi.w	#4,D2
	BNE	ST4D_TSS_SCC_INTERRUPT_END

	clr.w	D2

	; X

	move.b	(A6),D0	; 01GD YYXX
	andi.b	#%11,D0	; .... ..XX
	ror.b	#2,D0	; XX.. ....
	or.b	D0,(1,A6)	; XXXX xxxx

	; Y

	move.b	(A6),D0	; 01GD YYXX
	andi.b	#%00001100,D0	; .... YY..
	lsl.b	#4,D0	; YY.. ....
	or.b	D0,(2,A6)	; YYYY xxxx

	; LR BUTTONS

	move.b	(A6),D0	; 01GD YYXX
	rol.b	#4,D0	; YYXX 01GD
	andi.b	#%11,D0	; .... ..GD
	move.b	D0,(A6)

	move.b	(3,A6),D0	; 000M wwww
	move.b	D0,D1	; 000M wwww
	andi.w	#%00000111,D0	; .... .www
	andi.w	#%00010000,D1	; ...M ....
	lsr.w	#1,D1	; 0... M...
	or.w	D1,D0	; .... Mwww

	clr.w	D1
	
	lea	ST4D_DDA_4D_WHEEL_TAB,A5
	move.b	(A5,D0.w*2),D1
	move.w	D1,ST4D_BDB_4D_WHEELS
	move.b	(1,A5,D0.w*2),D1
	move.w	D1,ST4D_BDB_AES_WIN_ELEM

ST4D_TSS_SCC_INTERRUPT_END:	move.w	D2,ST4D_BDB_RS_OFFSET

	move.b	#0,(A4)
	move.b	#$28,(A4)
	move.b	#0,(A4)
	move.b	#$38,(A4)

	movem.l	ST4D_BDB_SCC_REGS,D0-D1/A4-A6

	RTE

; /////////////////////////////////////////////////////////////////////////////
	SECTION	DATA
; /////////////////////////////////////////////////////////////////////////////

; --- DATA ADDRESS TABLE (DAT) ---

; *** AES TABLE ***************************************************************

ST4D_DAT_AES_PARAMS_TAB:	dc.l	ST4D_BDB_AES_CONTROL
	dc.l	ST4D_BDB_AES_GLOBAL
	dc.l	ST4D_BDB_AES_INT_IN
	dc.l	ST4D_BDB_AES_INT_OUT
	dc.l	ST4D_BDB_AES_ADDR_IN
	dc.l	ST4D_BDB_AES_ADDR_OUT
	
; --- DATA DEFINED ARRAY (DDA) ---
	
; *** ScrollTrack4D ConversionTABLE *******************************************

ST4D_DDA_4D_WHEEL_TAB:	; Middle Button NOT SELECTED : Per LINE
	; {Wheel Movement Code}.w - {AES Window Element Code}.w
	; -1.b = None               -1.b = None
	;  0.b = Left Wheel UP       0.b = Page UP
	;  1.b = Left Wheel DOWN     1.b = Page DOWN
	;  2.b = Right Wheel UP      2.b = Line UP
	;  3.b = Right Wheel DOWN    3.b = Line DOWN
	;                            4.b = Page LEFT
	;                            5.b = Page RIGHT
	;                            6.b = Column LEFT
	;                            7.b = Column RIGHT

	dc.b	-1,-1	; No Wheels Movement
	dc.b	1,3	; Left  Wheel Down
	dc.b	3,7	; Right Wheel Down
	dc.b	-1,-1
	dc.b	-1,-1
	dc.b	-1,-1
	dc.b	2,6	; Right Wheel Up
	dc.b	0,2	; Left  Wheel Up

	; Middle Button SELECTED : Per PAGE

	dc.b	-1,-1	; No Wheels Movement
	dc.b	1,1	; Left  Wheel Down
	dc.b	3,5	; Right Wheel Down
	dc.b	-1,-1
	dc.b	-1,-1
	dc.b	-1,-1
	dc.b	2,4	; Right Wheel Up
	dc.b	0,0	; Left  Wheel Up

; *** ACCESSORY NAME **********************************************************

	IFNE ST4D_ES_DRIVER_TYPE ; ---------------------------,
ST4D_DDA_ACC_TITLE:	dc.b	"  ScrollTrack4D¿    ",0
	ELSEIF ; ---------------------------------------------+
ST4D_DDA_ACC_TITLE:	dc.b	"  Minimal ST4D¿     ",0
	ENDC ; -----------------------------------------------'

; /////////////////////////////////////////////////////////////////////////////
	SECTION	BSS
; /////////////////////////////////////////////////////////////////////////////

; --- BSS DATA BUFFER (BDB) ---

; *** REGISTERS BUFFERS *******************************************************

ST4D_BDB_LOOP_REGS:	ds.l	3
ST4D_BDB_LA_VECTOR:	ds.l	1
ST4D_BDB_4D_WHEELS:	ds.w	1

; *** REGISTERS BUFFERS *******************************************************

ST4D_BDB_SCC_REGS:	ds.l	5
ST4D_BDB_RS_BUFFER:	ds.b	4
ST4D_BDB_RS_OFFSET:	ds.w	1

; *** VIDEL BUFFERS ***********************************************************

	IFNE ST4D_ES_DRIVER_TYPE ; ---------------------------,
ST4D_BDB_VIDEL_FCOL0:	ds.l	1   
ST4D_BDB_VIDEL_COL0:	ds.w	1
ST4D_BDB_VIDEL_HDE:	ds.w	1
ST4D_BDB_VIDEL_VDE:	ds.w	1
ST4D_BDB_VIDEL_VCO:	ds.w	1
	ENDC ; -----------------------------------------------'

; *** AES BUFFER **************************************************************

ST4D_BDB_AES_CONTROL:	ds.w	5
ST4D_BDB_AES_GLOBAL:	ds.w	14
ST4D_BDB_AES_INT_IN:	ds.w	16
ST4D_BDB_AES_INT_OUT:	ds.w	7
ST4D_BDB_AES_ADDR_IN:	ds.l	3
ST4D_BDB_AES_ADDR_OUT:	ds.l	1

; *** WM_ARROWED MESSAGE (READY TO SEND ONCE 'Message' INITIALIZED TO 24) *****

ST4D_BDB_AES_MESSAGE:	ds.w	1	; WM_ARROWED (24)
ST4D_BDB_AES_HANDLE:	ds.w	1	; AP_ID of the ACC
	ds.w	1	; Normal GEM Message
ST4D_BDB_AES_WIN_ID:	ds.w	1	; Window Handle
ST4D_BDB_AES_WIN_ELEM:	ds.w	1	; Selected Element
	ds.w	3	; Additive Bytes

; --- BSS FLAG BUFFER (BFB) ---


; --- BSS STACK BUFFER (BSB) ---

; *** ACCESSORY STACK *********************************************************

	ds.l	256-2	; 256 LONGs
ST4D_BSB_ACC_STACK:	ds.l	2	; TPA
