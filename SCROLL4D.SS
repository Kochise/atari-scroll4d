; /// A4TECH's ScroolTrack4D¿ TrackBall Driver - Santorin 06/1993 & Kochise 07/2000 ///
;
; *** Program Informations **************************** Set TAB to 24 ***
; *			*
; * + ACC Version, Rev 1.06 		*
; *   - Assembled using 'HiSoft Devpac 3.10' 		*
; *			*
; * + Main SpeedMS Driver           by Santorin of the CYCLADES	*
; *   + Additive Code & Improvement by Kochise Of STALLION SOFTWARE	*
; *     - TurboVEILLE System        by ROCHE Xavier (Scrubed by KOSS)	*
; *     - VidelCUT System           by Kochise Of STALLION SOFTWARE	*
; *     - AsteroidGLIDER System     by Kochise Of STALLION SOFTWARE     *
; *			*
; * + This Driver is A4TECH-Ware & ARTE-Ware		*
; *   + Please support them for their efforts to make the World better.	*
; *     + A4TECH			*
; *     | - http://www.a4tech.com		*
; *     | - info@a4tech.com		*
; *     + ARTE			*
; *       - http://www.arte-tv.com		*
; *       - communication@arte-tv.com		*
; *			*
; * + Known BUGS			*
; *   + DOESN'T WORK ON MultiTOS !!! 		*
; *     - I DON'T EVEN KNOW WHY... What a STUPID 'ANTI-LAMER' KERNEL !  *
; *			*
; * + HardWare			*
; *   + ATARI Falcon030			*
; *     - 68030			*
; *     - VidelPROCESSOR		*
; *			*
; * + Version 1.06 Features		*
; *   + Builders			*
; *     - Generic   Serial Mouse Support		*
; *     - MicroSoft IntelliMouse Support 		*
; *     - A4TECH    ScrollTrack4D Mouse Support 	*
; *			*
; ***********************************************************************

; I must say that I'm VERY proud of this Revision. It * MIGHT * be the FINAL 
; ONE for the ATARI working under TOS. Next Releases will be done for the
; SSAVCALL Project...

; *** Equates Zone ************************************************************
;
; There are some useful Stuffs for the Assembler !
;

	; *** Equates for Assembly
	;
	; Create the Date of Assembly in SystemFORMAT

ST4D_EQU_ASM_DAY	EQU	15	
ST4D_EQU_ASM_MONTH	EQU	8
ST4D_EQU_ASM_YEAR	EQU	2000
	; Date Format :	%AAAAAAAmmmmJJJJJ
ST4D_EQU_ASM_DATE	EQU	((ST4D_EQU_ASM_YEAR-1980)<<9)|(ST4D_EQU_ASM_MONTH<<5)|(ST4D_EQU_ASM_DAY)

ST4D_EQU_DRIVER_TYPE	EQU	1
	; 0 = MinimalST4D
	; 1 = FullyFeaturedST4D

	; *** Commands for Assembly
	;
	; Define the AssemblySPECIFICATIONS

	OPT	p=68030/68882
	comment	HEAD=7	; FastLoad

	IFNE ST4D_EQU_DRIVER_TYPE ; --------------------------,
	
	output	C:\ACCS\SCROLL4D.ACC
	
	ELSEIF ; ---------------------------------------------+
	
	output	C:\ACCS\MINIST4D.ACC
	
	ENDC ; -----------------------------------------------'

; /////////////////////////////////////////////////////////////////////////////	
	SECTION	TEXT
; /////////////////////////////////////////////////////////////////////////////	
	
; *** 0. General Informations *******************************************
; *			*
; * Here are ALL the WHOLE Sources for the A4TECH ST4DDRIVER¿ by KOSS ! *
; *			*
; * This is NOT a Trick, just Assemble THIS File, and you will get the  *
; * same File you have already...		*
; *			*
; * Before starting to see what is there, let me tell you the Storie of *
; * a guy who ALWAYS believed that the World is WHAT we want it to be.  *
; *			*
; * "Once upon a time..." the Storie would have started like this, but  *
; * NOT, definitively NOT !!!		*
; *			*
; *- 
; *			*
; * Now let's have an Overview of the Program...	*
; *			*
; * /// SECTION TEXT ////////////////////////////////////////////////// *
; * 1. Booter...... : Initialisation of the OperatingSYSTEM (-> 2.)	*
; * 2. Initializer. : Initialisation of the ATARI HardWare (3. <-)	*
; * 3. Main Loop... : The MainLOOP - OperatingSYSTEM Interface	*
; * 4. VBL......... : Each VBL, do some job		*
; * 5. IKBD........ : When something comes from the Keyboard (IKBD)	*
; * 6. MOUSE....... : When something comes from the Mouse (MOUSE)	*
; *			*
; * /// SECTION DATA ////////////////////////////////////////////////// *
; * There are the Program 
; *			*
; * /// SECTION BSS /////////////////////////////////////////////////// *
; * There are the 
; *			*
; ***********************************************************************
	
	IFNE ST4D_EQU_DRIVER_TYPE ; --------------------------,
	
	BRA	ST4D_DRIVER_Booting

	; *** Program Informations
	;
	; These Informations MAY be used by ProgANALYSER
	;
	
	dc.b	"ProgHEAD"	; ProgHEADER
	dc.w	$0106	; ProgVERSION
	dc.w	ST4D_EQU_ASM_DATE	; ProgDATE
	dc.b	"ST4DDRIVER",0	; ProgNAME
	dc.b	"KOSS",0	; ProgAUTHOR
		
	ENDC ; -----------------------------------------------'
				
; *** 1. Booter *********************************************************
; *			*
; * 1.1. - Shrink the Memory Allocated to the Starting Program	*
; * 1.2. - Ask the AES to takes care of us		*
; * 1.3. - Ask to be Displayed in the MenuBAR		*
; * 1.4. - HardWare Installation		*
; * 			*
; ***********************************************************************
	
ST4D_DRIVER_Booting	; *** 1.1. Shrink the Memory ********************
	; *		*
	; * Because the WHOLE Memory is Allocated to	*
	; * starting Program, we must Free the Memory	*
	; * not used by the Program itself for future	*
	; * allocations, and for other task allocation. *
	; *		*
	; * GEMDOS / M_SHRINK ($4A/74)	*
	; * 		*
	; ***********************************************
	
	; WARNING : ACCESSORY !!!
	; When an Accessory Starts, the Registers of the 68030 
	; are Set like this :
	;
	;   DataREGISTERS   AddressREGISTERS
	;     D0.l = 0          A0.l -> BasePage
	;     D1.l = 0          A1.l = 0
	;     D2.l = 0          A2.l = 0
	;     D3.l = 0          A3.l = 0
	;     D4.l = 0          A4.l = 0
	;     D5.l = 0          A5.l = 0
	;     D6.l = 0          A6.l = 0
	;     D7.l = 0       SP/A7.l = 0 <- * WARNING *
	;

	move.l	SP,D0	; If SP==0, ACC
	BNE	ST4D_BOOT_SafeExit

	lea	ST4D_BSS_AccStack,SP

	; WARNING : ACCESSORY !!!

	move.l	A0,(4,SP)	; Magie PURE !!!

	movea.l	(4,SP),A6	; BASEPAGE Address
	move.l	(12,A6),D0	; SEGMENT TEXT Size
	add.l	(20,A6),D0	; SEGMENT DATA Size
	add.l	(28,A6),D0	; SEGMENT BSS Size
	addi.l	#256,D0	; BASEPAGE Size
	move.l	D0,-(SP)	; Size to Allocate
	move.l	A6,-(SP)	; PROGRAM Address
	clr.w	-(SP)	; Reserved
	move.w	#$4A,-(SP)	; - M_SHRINK -
	TRAP	#1	; *** GEMDOS ***
	lea	(12,SP),SP

	; *** 1.2. Ask the AES to takes care of us ******
	; *		*
	; * The AES is the part of the OS which manage	*
	; * alle the Windows, the Forms, the Messages.	*
	; * In order to be able to talk to another	*
	; * Applications, you SHOULD have a Handle	*
	; * provided by the AES.	*
	; *		*
	; * AES / APPL_INIT ($A/10)	*
	; *		*
	; ***********************************************
	
	lea	ST4D_BSS_AES_Control,A0
	move.l	#$0A000100,D0	; - APPL_INIT -
	movep.l	D0,(1,A0)

	BSR	ST4D_BOOT_AES_LibCall	; *** AES ***

	move.w	ST4D_BSS_AES_Int_Out,D0
	BMI	ST4D_BOOT_ErrorExit	; If failed

	move.w	D0,ST4D_DATA_AES_Handle	; AP_ID

	; *** 1.3. Ask to be Displayed in the MenuBAR ***
	; *		*
	; * Once having get an AES Handle, we can ask	*
	; * to be Accessible EVERYWHERE by Installing	*
	; * ourselves as an Accessory.	*
	; *		*
	; * AES / MENU_REGISTER ($23/35)	*
	; *		*
	; ***********************************************

	move.w	D0,ST4D_BSS_AES_Int_In
	move.l	#ST4D_DATA_ACC_Name,ST4D_BSS_AES_Addr_In

	lea	ST4D_BSS_AES_Control,A0
	move.l	#$23010101,D0	; - MENU_REGISTER -
	movep.l	D0,(1,A0)

	BSR	ST4D_BOOT_AES_LibCall	; *** AES ***

	move.w	ST4D_BSS_AES_Int_Out,D0
	BMI	ST4D_BOOT_AES_Exit	; If failed (-1.w)

	move.w	D0,ST4D_BSS_ACC_Handle	; ACC_ID

	; *** 1.4. HardWare Installation ****************
	; *		*
	; * Turn into SUPERVISOR Mode, and Hack some	*
	; * Registers in order to Install some Routines	*
	; *		*
	; * XBIOS / SUPEXEC ($26/38)	*
	; *		*
	; ***********************************************

	pea	ST4D_INIT_Start
	move.w	#$26,-(SP)	; - SUPEXEC -
	TRAP	#14	; *** XBIOS ***
	addq.l	#6,SP

	tst.w	D0	; Si Erreur (-1.w)
	BMI	ST4D_BOOT_AES_Exit

	BRA	ST4D_MAIN_START
	
; ----    ---------------------------------------------------------------------

	; *** If an Error occur AFTER AES Init **********
	; *		*
	; * Once get the Handle given by the AES, you	*
	; * should restore the place safe BEFORE doing	*
	; * something else...		*
	; *		*
	; * AES / APPL_EXIT ($13/19)	*
	; *		*
	; ***********************************************

ST4D_BOOT_AES_Exit	lea	ST4D_BSS_AES_Control,A0
	move.l	#$13000100,D0	; - APPL_EXIT -
	movep.l	D0,(1,A0)

	BSR	ST4D_BOOT_AES_LibCall	; *** AES ***

	; *** Exit WITH or WITHOUT ExitCODE *************
	; *		*
	; * When Exiting, you can specify an ExitCODE	*
	; *		*
	; * GEMDOS / P_TERM ($4C/76)	*
	; *		*
	; ***********************************************

ST4D_BOOT_SafeExit	clr.w	D0	; No Error
ST4D_BOOT_ErrorExit	move.w	D0,-(SP)	; ErrorCODE
	move.w	#$4C,-(SP)	; - P_TERM -
	TRAP	#1	; *** GEMDOS ***
	; - PROGRAM TERMINATED HERE / RETURN TO DESKTOP -

; ----    ---------------------------------------------------------------------

ST4D_BOOT_AES_LibCall	move.l	#200,D0
	move.l	#ST4D_DATA_AES_ParamsTab,D1
	TRAP	#2	; *** AES/VDI ***

	RTS

; *** 2. Initializer ****************************************************
; *			*
; * 2.1. - Get the ACIA Dispatch Handler		*
; * 2.2. - Change the MOUSE Vector		*
; * 2.3. - Check if already Installed		*
; * 2.4. - Init the LineA		*
; * 2.5. - Set the SerialSPEED		*
; * 2.6. - Empty RS Buffer		*
; * 2.7. - Install HardWare & OS Vectors		*
; *			*
; ***********************************************************************

ST4D_INIT_Start	; *** 2.1. Get the ACIA Dispatch Handler ********
	; *		*
	; * There are TWO ACIA in the ATARI :	*
	; *  - MIDI		*
	; *  - IKBD		*
	; *		*
	; * XBIOS / KBDVBASE ($22/34)	*
	; *		*
	; * Offset Size Name	 Purpose	*
	; *      0 LONG midivec  MIDI Input	*
	; *      4 LONG vkbderr  IKBD Error	*
	; *      8 LONG vmiderr  MIDI Error	*
	; *  $C/12 LONG statvec  IKBD Status Packet	*
	; * $10/16 LONG mousevec MOUSE Packet	*
	; * $14/20 LONG clockvec CLOCK Packet	*
	; * $18/24 LONG joyvec   JOYSTICK Packet	*
	; * $1C/28 LONG midisys  MIDI System Vector	*
	; * $20/32 LONG ikbdsys  IKBD System Vector	*
	; * $24/36 BYTE busyflag 0 if IKBD not sending	*
	; *		*
	; ***********************************************

	move.w	#$22,-(SP)	; - KBDVBASE -
	TRAP	#14	; *** XBIOS ***
	addq.l	#2,SP

	; *** 2.2. Change the MOUSE Vector **************
	; *		*
	; * Retrieve the 'mousevec' in the DispatchTAB	*
	; * Then point the Routine...	*
	; *		*
	; ***********************************************

	addi.l	#16,D0	; -> mousevec
	exg	A0,D0
	move.l	A0,ST4D_BSS_MousVectAddr
	movea.l	(A0),A0	; Routine
	
	; *** 2.3. Check if already Installed ***********
	; *		*
	; * Check the XBRA		*
	; *		*
	; ***********************************************
	
	cmpi.l	#"ST4D",(-8,A0)
	BNE	ST4D_INIT_Install	; NOT INSTALLED
	
	move.w	#-1,D0	; INSTALLED
		
	RTS	
		
ST4D_INIT_Install	move.l	A0,ST4D_MOUSE_OldMousVect
	
	; *** 2.4. Init the LineA ***********************
	; *		*
	; * Get the LineA Vectors Table Address	*
	; *		*
	; ***********************************************
	
	dc.w	$A000	; LineA_Init
	move.l	D0,ST4D_BSS_LATabVectAddr
		
	; *** 2.5. Set the SerialSPEED ******************
	; *		*
	; * Set the Speed Rate at a Correct Value	*
	; *		*
	; ***********************************************
		
	BSR	ST4D_MAIN_RS_Conf
		
	; *** 2.6. Empty RS Buffer **********************
	; *		*
	; * Empty the Receive Buffer	*
	; *		*
	; ***********************************************
		
ST4D_INIT_Empty_RS_Buff	move.w	#1,-(SP)	; RS232
	move.w	#1,-(SP)	; - BCONSTAT -
	TRAP	#13	; *** BIOS ***
	addq.l	#4,SP

	tst.w	D0
	BEQ	ST4D_INIT_VectInit	; If no Char

	move.w	#1,-(SP)	; RS232
	move.w	#2,-(SP)	; - BCONIN -
	TRAP	#13	; *** BIOS ***
	addq.l	#4,SP

	BRA	ST4D_INIT_Empty_RS_Buff

	; *** 2.7. Install HardWare and OS Vectors ******
	; *		*
	; * 2.7.1. - Save Status	*
	; * 2.7.2. - Set the New MOUSE Vector	*
	; * 2.7.3. - Set the New VBL Vector	*
	; * 2.7.4. - Get the SpecialKeysBufferAddress	*
	; * 2.7.5. - Set the New IKBD Vector	*
	; * 2.7.6. - Look for the Video Processor Type  *
	; * 2.7.7. - Save some Videl Registers	*
	; * 2.7.8. - Restore Status	*
	; *		*
	; ***********************************************

ST4D_INIT_VectInit	; *** 2.7.1. Save Status ************************

	move.w	SR,ST4D_BSS_Old_SR
	move.w	#$2700,SR	; STOP Interrupts

	; *** 2.7.2. Set the New MOUSE Vector ***********

	movea.l	ST4D_BSS_MousVectAddr,A0
	move.l	#ST4D_MOUSE_NewMousVect,(A0)
	
	; *** 2.7.3. Set the New VBL Vector *************
	
	movea.l	$456.w,A0	; _vblqueue
	move.l	(A0),ST4D_BSS_OldVblVector
	move.l	#ST4D_VBL_START,(A0)

	IFNE ST4D_EQU_DRIVER_TYPE ; --------------------------,

	; *** 2.7.4. Get the SpecialKeysBufferAddress ***
	
	movea.l	$4F2.w,A0	; _SysBase
	adda.l	#36,A0
	move.l	(A0),ST4D_BSS_KbShift
	
	; *** 2.7.5. Set the New IKBD Vector ************
	
	move.l	$118.w,ST4D_IKBD_OldSTMFP6Vect
	move.l	#ST4D_IKBD_START,$118.w

	; *** 2.7.6. Look for the Video Processor Type **
	
	move.l	$5A0.w,D0	; COOKIE_Base
	BEQ	ST4D_INIT_VIDEO_None

	movea.l	D0,A0
	move.w	#31,D0

ST4D_INIT_VIDEO_Loop	cmpi.l	#"_VDO",([A0],D0.w*8)
	BEQ	ST4D_INIT_VIDEO_Test

	DBF	D0,ST4D_INIT_VIDEO_Loop

ST4D_INIT_VIDEO_None	bclr.b	#2,ST4D_BSS_MultiFlag

	BRA	ST4D_INIT_END

ST4D_INIT_VIDEO_Test	cmpi.l	#$00030000,(4,[A0],D0.w*8)
	BNE	ST4D_INIT_VIDEO_None
	
	bset.b	#2,ST4D_BSS_MultiFlag

	; *** 2.7.7. Save some Videl Registers **********

	move.l	$FFFF9800.w,ST4D_BSS_OldFaclC0
	move.w	$FFFF8240.w,ST4D_BSS_OldColor0
	move.w	$FFFF82AA.w,ST4D_BSS_OldVDE
	move.w	$FFFF828A.w,ST4D_BSS_OldHDE
	move.w	$FFFF82C2.w,ST4D_BSS_OldVCO
	
	ENDC ; -----------------------------------------------'

	; *** 2.7.8. Restore Status *********************
		
ST4D_INIT_END	move.w	ST4D_BSS_Old_SR,SR

	RTS	

; *** 3. Main Loop ******************************************************
; *			*
; * 3.1. - Wait a 'little' moment		*
; * 3.2. - Force the Serial Speed		*
; * 3.3. + Check for any Wheel Movement		*
; *			*
; ***********************************************************************	

ST4D_MAIN_START	movem.l	D0-A6,ST4D_BSS_MAIN_REGS

	move.l	#10,D0
	swap	D0
	move.l	D0,ST4D_BSS_AES_Int_In

	lea	ST4D_BSS_AES_Control,A0
	move.l	#$18020100,D0	; - EVNT_TIMER -
	movep.l	D0,(1,A0)

	BSR	ST4D_BOOT_AES_LibCall	; *** AES ***

	movem.l	ST4D_BSS_MAIN_REGS,D0-A6
		
	; ** On va v‚rifier si la Transmission S‚rie s'effectue
	; TOUJOURS … la bonne vitesse

	BSR	ST4D_MAIN_RS_Conf

	; ** On va v‚rifier si le Driver a d‚tect‚ un fr‚missement
	; des Molettes de la Souris PC...
	
	tst.w	ST4D_BSS_4DWheels
	BMI	ST4D_MAIN_START
	
	; Et bien oui, il y a eu quelques chose...
	; ** WIND_FIND, on va tenter de savoir s'il y a une
	; Fenˆtre d'ouverte sous la Souris, et … qui elle
	; appartient...
	
	move.l	ST4D_BSS_LATabVectAddr,A5
	move.l	(-602,A5),ST4D_BSS_AES_Int_In	; LineA GCurXY
	
	lea	ST4D_BSS_AES_Control,A0
	move.l	#$6A020100,D0	; - WIND_FIND -
	movep.l	D0,(1,A0)

	BSR	ST4D_BOOT_AES_LibCall	; *** AES ***
	
	; Y'a rien l… dessous...
	tst.w	ST4D_BSS_AES_Int_Out
	BEQ	ST4D_MAIN_START
	
	; "Mais SI, j'ai bien vu un 'ros Minet..."
	
	move.w	ST4D_BSS_AES_Int_Out,ST4D_DATA_AES_WinHandle
	
	; Maintenant, il sagit d'envoyer un Message GEM …
	; une Application, … qui appartient la dite
	; Fenˆtre...
	; ** APPL_WRITE, on envoie le Message...
	
	move.l	#ST4D_DATA_AES_Message,ST4D_BSS_AES_Addr_In
	move.w	#0,ST4D_BSS_AES_Int_In	; Current Working Application
	move.w	#16,ST4D_BSS_AES_Int_In+2
			; Nb Bytes
	
	lea	ST4D_BSS_AES_Control,A0
	move.l	#$0C020101,D0	; - APPL_WRITE -
	movep.l	D0,(1,A0)

	BSR	ST4D_BOOT_AES_LibCall	; *** AES ***

	; Et on n'oublie SURTOUT PAS de d‚sactiver le pr‚c‚dent
	; Message...
	
	move.w	#-1,ST4D_BSS_4DWheels
	
	; "Plus un zeste !!!" - Joe le Citron
	
	BRA	ST4D_MAIN_START

; ----    ---------------------------------------------------------------------


ST4D_MAIN_RS_Conf	; ** RSCONF, Initialisation du Port S‚rie

	move.w	#-1,-(SP)	; Synchro  Char Reg
	move.w	#-1,-(SP)	; Transmit Stat Reg
	move.w	#-1,-(SP)	; Receive  Stat Reg
	move.w	#-1,-(SP)
	move.w	#-1,-(SP)	; Flow Control Mode -> No Control
	move.w	#-1,-(SP)	; New Speed         -> 1200 bauds
	move.w	#15,-(SP)	; - RSCONF -
	TRAP	#14	; *** XBIOS ***
	lea	(14,SP),SP

	rol.l	#8,D0
	andi.w	#$FF,D0	; UCR

	move.w	ST4D_DATA_RS_Params,D1
	cmp.w	D1,D0
	BEQ	ST4D_MAIN_RS_Good

	move.w	#-1,-(SP)	; Synchro  Char Reg
	move.w	#-1,-(SP)	; Transmit Stat Reg
	move.w	#-1,-(SP)	; Receive  Stat Reg
	move.w	ST4D_DATA_RS_Params,-(SP)
	move.w	#0,-(SP)	; Flow Control Mode -> No Control
	move.w	#7,-(SP)	; New Speed         -> 1200 bauds
	move.w	#15,-(SP)	; - RSCONF -
	TRAP	#14	; *** XBIOS ***
	lea	(14,SP),SP

ST4D_MAIN_RS_Good	RTS

; *** 4. VBL ************************************************************
; *			*
; * + Brutal MOUSE Driver 		*
; *   - Santorin 1993 			*
; *   - KOSS 2000 (A4TECH ScrollTrack4D¿)		*
; *			*
; ***********************************************************************

	; *** 4.1. Save the Current Status **************
	; *		*
	; *		*
	; ***********************************************

ST4D_VBL_START	movem.l	D0-A6,ST4D_BSS_VBL_REGS

	btst.b	#3,ST4D_BSS_MultiFlag
	BNE	ST4D_VBL_MOUSE_Pass

	; Pointeur de Chargement de la Trame

	lea	ST4D_BSS_RSBuffer,A6
	adda.l	ST4D_BSS_RSCounter,A6

	; On v‚rifie s'il y a quelque chose … charger

ST4D_VBL_MOUSE_Seek	JSR	([$51E+4])	; InputStatRout : RS232

	; Si … 0, rien
	tst.w	D0
	BEQ	ST4D_VBL_MOUSE_Pass

	; Sinon on lit la Donn‚e sur le Port S‚rie
	JSR	([$53E+4])	; InputRout : RS232

	; Si le compteur est diff‚rent de 0, c'est que
	; le Chargement … bien d‚but‚, que la Trame est
	; valide (voir juste ce qui suit)
	tst.l	ST4D_BSS_RSCounter
	BNE	ST4D_VBL_MOUSE_Load

	; Si le bit 6 n'est pas … 1, qui est la signature d'une
	; Trame de Souris PC, ce n'est pas bon, on cherche la suite
	btst.l	#6,D0
	BEQ	ST4D_VBL_MOUSE_Seek

; ----    ---------------------------------------------------------------------

	; On sauve l'octet dans le Buffer

ST4D_VBL_MOUSE_Load	move.b	D0,(A6)+
	addq.l	#1,ST4D_BSS_RSCounter

	; Buffer plein ?

	cmpi.l	#4,ST4D_BSS_RSCounter
	BNE	ST4D_VBL_MOUSE_Seek

	; Pour la fois prochaine

	clr.l	ST4D_BSS_RSCounter	; Compteur … 0
	bset.b	#3,ST4D_BSS_MultiFlag
	
	; On traite les infos issues du port s‚rie
	
	lea	ST4D_BSS_RSBuffer,A6
	
	; ** Trame de Dialogue A4TECH ScrollTrack4D¿
	; Trouv‚ par Kochise Of STALLION SOFTWARE
	;
	; OffSet Size  %7654 3210
	;      0 byte - 01LR YYXX
	;      1 byte - 00XX xxxx
	;      2 byte - 00YY yyyy
	;      3 byte - 000M wwww
	;
	;        L : Left   Button
	;        R : Right  Button
	;        M : Middle Button
	; XXXXxxxx : 8bits SIGNED X RELATIVE Displacement
	; YYYYyyyy : 8bits SIGNED Y RELATIVE Displacement
	;     wwww : A4TECH ScrollTrack¿ ScrollWheels Commands
	;            %3210
	;             0000 No Wheels Movement
	;             1111 Left  Wheel Up
	;             0001 Left  Wheel Down
	;             1110 Right Wheel Up
	;             0010 Right Wheel Down
	;
	; You can only move one ScrollBar at a same time, 
	; and that's normal : with your mouse, you can only 
	; click on one ScrollButton at a same time !!!
	
	; On r‚cupŠre le D‚placement en X
	
	move.b	(A6),D0	; 01GD YYXX
	andi.b	#%11,D0	; .... ..XX
	ror.b	#2,D0	; XX.. ....
	or.b	D0,(1,A6)	; XXXX xxxx
	
	; On r‚cupŠre le D‚placement en Y
	
	move.b	(A6),D0	; 01GD YYXX
	andi.b	#%1100,D0	; .... YY..
	lsl.b	#4,D0	; YY.. ....
	or.b	D0,(2,A6)	; YYYY xxxx

	; On r‚cupŠre les deux boutons Gauche et Droite

	move.b	(A6),D0	; 01GD YYXX
	rol.b	#4,D0	; YYXX 01GD
	andi.b	#%11,D0	; .... ..GD
	move.b	D0,(A6)
	
	; ** On calcul le temps de pression du Bouton du Milieu
	
	btst.b	#4,(3,A6)	; 000M wwww
	BEQ	ST4D_VBL_MOUSE_MB_END

	tst.l	ST4D_BSS_TIME_Slice
	BNE	ST4D_VBL_MOUSE_MB_SEC
	
	move.l	$4BA.w,ST4D_BSS_TIME_Slice
	
	BRA	ST4D_VB_MOUSE_WHEELS
	
ST4D_VBL_MOUSE_MB_END	;- A FINIR -

ST4D_VBL_MOUSE_MB_SEC	move.l	$4BA.w,ST4D_BSS_TIME_Slice+4
	movem.l	ST4D_BSS_TIME_Slice,D0-D1
	
	sub.l	D0,D1
	
	cmpi.l	#400,D1
	BGT	ST4D_VBL_MOUSE_WHEELS
	
	clr.l	ST4D_BSS_TIME_Slice
	bclr.b	#1,ST4D_BSS_MultiFlag

	; ** On transforme le mouvement des Roues 4D
	; et l'on pr‚pare le Message GEM … Envoyer …
	; l'Application d‚tentrice de l'Hypoth‚tique
	; Fenˆtre se situant SOUS la Souris dans la
	; Boucle ACC_MainLoop (voir plus haut)...
	; %0000 -> -1 : No Wheels Movement
	; %1111 ->  0 : Left  Wheel Up	
	; %0001 ->  1 : Left  Wheel Down
	; %1110 ->  2 : Right Wheel Up
	; %0010 ->  3 : Right Wheel Down

ST4D_VBL_MOUSE_WHEELS	move.b	(3,A6),D0	; 000M wwww
	andi.w	#%111,D0	; .... .www

	move.b	(3,A6),D1	; 000M wwww
	andi.w	#%10000,D1	; ...M ....
	lsr.w	#1,D1	; 0... M...
	
	or.w	D1,D0	; .... Mwww
	
	lea	ST4D_DATA_WheelTable,A5
	move.w	(A5,D0.w*4),ST4D_BSS_4DWheels
	move.w	(2,A5,D0.w*4),ST4D_DATA_AES_SelElem
		
	;   Au fait, on viens de jouer avec la Souris PC, donc
	; on restaure l'Ecran au cas o—... :) )
	
	IFNE ST4D_EQU_DRIVER_TYPE ; --------------------------,
	
	bclr.b	#0,ST4D_BSS_MultiFlag
	
	ENDC ; -----------------------------------------------'
				
ST4D_VBL_MOUSE_Pass	; Le driver de Souris PC
	JSR	ST4D_VBL_LINEA_START

	IFNE ST4D_EQU_DRIVER_TYPE ; --------------------------,

	; Le protecteur d'Ecran
	JSR	ST4D_VBL_SCRNSAVE_START
		
	ENDC ; -----------------------------------------------'
		
	; Restaure contexte	
	movem.l	ST4D_BSS_VBL_REGS,D0-A6

	; On continue ensuite … l'ancienne VBL
	JMP	([ST4D_BSS_OldVblVector])
	
; ----    ---------------------------------------------------------------------
; A chaque VBL, trifouille la LineA + OK
		
ST4D_VBL_LINEA_START	btst.b	#3,ST4D_BSS_MultiFlag
	BEQ	ST4D_VBL_LINEA_END

	bclr.b	#3,ST4D_BSS_MultiFlag
	lea	ST4D_BSS_RSBuffer,A0	; Buffer
	movea.l	ST4D_BSS_LATabVectAddr,A2	
			; LineA VTable

	move.b	(A0),D0	; .... ..GD
	andi.l	#%11,D0	; Pour ˆtre s–r...

	lsr.b	#1,D0
	BCC	ST4D_VBL_LINEA_ExgButt

	bset.l	#1,D0

	; .... ..DG

ST4D_VBL_LINEA_ExgButt	move.b	(-348,A2),D1	; LineA CurMouseStat
	andi.w	#%11,D1

	; Y'a t'il des buttons de chang‚s

	cmp.b	D1,D0
	BEQ	ST4D_VBL_LINEA_NoButt

	; Y'a ka...

	movem.w	D1,-(SP)	; Save
	JSR	([-58,A2])	; LineA UserBut
	movem.w	(SP)+,D1	; Restore
	
	move.w	D0,(-596,A2)	; LineA MouseBut
	eor.b	D0,D1
	ror.b	#2,D1
	or.b	D1,D0
	move.b	D0,(-348,A2)	; LineA CurMouseStat

	; Pas de mouvement de Souris...
	
ST4D_VBL_LINEA_NoButt	bclr	#5,(-348,A2)	; LineA CurMouseStat
	
	; Y'a t'il un fr‚missement de Souris PC ?
	
	move.b	(1,A0),D0	; Buffer
	or.b	(2,A0),D0	; Buffer
	BEQ	ST4D_VBL_LINEA_END

	; Mouvement de Souris … prendre en compte...

	bset	#5,(-348,A2)	; LineA CurMouseStat
	
	move.l	(-602,A2),D0	; LineA GCurXY
	move.l	D0,D1	; XY
	swap	D0	; YX
	move.b	(1,A0),D3	; sX
	ext.w	D3
	add.w	D3,D0
	move.b	(2,A0),D3	; sY
	ext.w	D3
	add.w	D3,D1

	; Modification des Coordonn‚es de la Souris PC

	BSR	ST4D_VBL_CTEST_X_MIN

	move	SR,ST4D_BSS_Old_SR	; Sauve SR
	ori	#$700,SR	; Stoppe Interruptions

	JSR	([-50,A2])	; LineA UserMouseMovement

	move	ST4D_BSS_Old_SR,SR	; Restaure Interruptions

	; Modification des Coordonn‚es de la Souris ATARI

	BSR	ST4D_VBL_CTEST_X_MIN

	lea	(-602,A2),A1	; LineA GCurX
	move.w	D0,(A1)+	; X
	move.w	D1,(A1)	; Y

	JSR	([-54,A2])	; LineA UserMouseDraw

ST4D_VBL_LINEA_END	RTS	

; ----    ---------------------------------------------------------------------
; A chaque VBL, v‚rifie la validit‚ des Coordonn‚es OK
	
ST4D_VBL_CTEST_X_MIN	tst.w	D0	; X
	BGE	ST4D_VBL_CTEST_X_MAX

	; Si inf‚rieur … 0, on met … 0...

	clr.w	D0

	BRA	ST4D_VBL_CTEST_Y_MIN

	; On v‚rifie si on ne d‚passe pas en X

ST4D_VBL_CTEST_X_MAX	cmp.w	(-12,A2),D0	; LineA VRezH
	BLT	ST4D_VBL_CTEST_Y_MIN

	move.w	(-12,A2),D0	; LineA VRezH
	subq.w	#1,D0

	; La mˆme chose pour Y

ST4D_VBL_CTEST_Y_MIN	tst.w	D1
	BGE	ST4D_VBL_CTEST_Y_MAX

	clr.w	D1

	RTS	

ST4D_VBL_CTEST_Y_MAX	cmp.w	(-4,A2),D1	; LineA VRezV
	BLT	ST4D_VBL_CTEST_END

	move.w	(-4,A2),D1	; LineA VRezV
	subq.w	#1,D1

ST4D_VBL_CTEST_END	RTS	

; ----    ---------------------------------------------------------------------
; A chaque VBL, on va v‚rifier s'il faut Prot‚ger l'Ecran + OK

	IFNE ST4D_EQU_DRIVER_TYPE ; --------------------------,

ST4D_VBL_SCRNSAVE_START	move.w	D0,-(SP)

	; On v‚rifie si on a un Videl

	btst.b	#2,ST4D_BSS_MultiFlag
	BEQ	ST4D_VBL_SCRNSAVE_END

	btst.b	#0,ST4D_BSS_MultiFlag
	BNE	ST4D_VBL_SCRNSAVE_OFF

	; Allume l'Ecran, remet une R‚solution Convenable

	move.w	ST4D_BSS_OldVDE,$FFFF82AA.w
	move.w	ST4D_BSS_OldHDE,$FFFF828A.w
	move.l	ST4D_BSS_OldFaclC0,$FFFF9800.w
	move.w	ST4D_BSS_OldColor0,$FFFF8240.w

	BRA	ST4D_VBL_SCRNSAVE_ON

	; On fout n'Importe QUOI : R‚solution de 0*0 Pixels

ST4D_VBL_SCRNSAVE_OFF	clr.l	$FFFF9800.w	; FalcPal0
	clr.w	$FFFF8240.w	; Color0
	move.w	$FFFF82A8.w,$FFFF82AA.w ; VDE
	addq.w	#1,$FFFF82AA.w	; VDE
	move.w	$FFFF8288.w,$FFFF828A.w ; HDE
	addi.w	#10,$FFFF828A.w	; HDE
	
	; On rallume le Machin lumineux devant soit...
	
ST4D_VBL_SCRNSAVE_ON	btst.b	#1,ST4D_BSS_MultiFlag
	BNE	ST4D_VBL_SCRNSAVE_ESTAR

	move.w	ST4D_BSS_OldVCO,$FFFF82C2.w

	BRA	ST4D_VBL_SCRNSAVE_END

	; On coupe Ze Machin Lumineux

ST4D_VBL_SCRNSAVE_ESTAR	move.w	$FFFF82C2.w,D0
	
	andi.w	#%11,D0
	ori.w	#%1100,D0

	move.w	D0,$FFFF82C2.w
	
ST4D_VBL_SCRNSAVE_END	move.w	(SP)+,D0
	
	RTS
	
	ENDC ; -----------------------------------------------'
	
; *** 5. IKBD ***********************************************************
; *			*
; * + New IKBD Vector 			*
; *   - ROCHE Xavier / Turo Veille		*
; *   - KOSS 2000 / XBRA		*
; *			*
; ***********************************************************************

	IFNE ST4D_EQU_DRIVER_TYPE ; --------------------------,

	dc.l	'XBRA'
	dc.l	'ST4D'
ST4D_IKBD_OldSTMFP6Vect	ds.l	1

ST4D_IKBD_START	movem.l	D0-A6,ST4D_BSS_IKBD_REGS

	; Teste d‚j… si on a un Videl
	
	btst.b	#2,ST4D_BSS_MultiFlag
	BEQ	ST4D_IKBD_NextIKBD

	; On Lit l'Etat des Touches Sp‚ciales
	
	move.l	([ST4D_BSS_KbShift]),D0

	; Y'en a t-il au moins ?

	andi.b	#$F,D0
	BNE	ST4D_IKBD_ShiftKeys

	; Ben non, donc on coupe Turbo Veille

	bclr.b	#0,ST4D_BSS_MultiFlag

ST4D_IKBD_NextIKBD	movem.l	ST4D_BSS_IKBD_REGS,D0-A6
	
	JMP	([ST4D_IKBD_OldSTMFP6Vect])

	; Est-ce [LShift] + [Alternate] + [RShift]

ST4D_IKBD_ShiftKeys	cmp.b	#%00001011,D0
	BNE	ST4D_IKBD_NextShift

	; OK, on met Turbo Veille en route

	bset.b	#0,ST4D_BSS_MultiFlag

	BRA	ST4D_IKBD_NextIKBD
	
	; Est-ce [Control] + [LShift] + [Alternate] + [RShift]
	
ST4D_IKBD_NextShift	cmp.b	#%00001111,D0
	BNE	ST4D_IKBD_NextIKBD

	; OK, on met Videl CUT en route
	
	bset.b	#1,ST4D_BSS_MultiFlag
	
	BRA	ST4D_IKBD_NextIKBD
	
	ENDC ; -----------------------------------------------'
		
; *** 6. MOUSE **********************************************************
; *			*
; * + New MOUSE Vector			*
; *   - Santorin 1993			*
; *   - KOSS 2000 (XBRA)		*
; *			*
; ***********************************************************************		

	dc.b	"XBRA"
	dc.b	"ST4D"
ST4D_MOUSE_OldMousVect	ds.l	1	

ST4D_MOUSE_NewMousVect	JMP	([ST4D_MOUSE_OldMousVect])

; /////////////////////////////////////////////////////////////////////////////	
	SECTION	DATA
; /////////////////////////////////////////////////////////////////////////////	

; *** ScrollTrack4D ConversionTABLE *******************************************

ST4D_DATA_WheelTable	; Middle Button NOT SELECTED : Per LINE
	; {Wheel Movement Code}.w - {AES Window Element Code}.w
	; -1.w = None               -1.w = None
	;  0.w = Left Wheel UP       0.w = Page UP
	;  1.w = Left Wheel DOWN     1.w = Page DOWN
	;  2.w = Right Wheel UP      2.w = Line UP
	;  3.w = Right Wheel DOWN    3.w = Line DOWN
	;                            4.w = Page LEFT
	;                            5.w = Page RIGHT
	;                            6.w = Column LEFT
	;                            7.w = Column RIGHT

	dc.w	-1,-1	; No Wheels Movement
	dc.w	1,3	; Left  Wheel Down
	dc.w	3,7	; Right Wheel Down
	dc.w	-1,-1
	dc.w	-1,-1
	dc.w	-1,-1
	dc.w	2,6	; Right Wheel Up
	dc.w	0,2	; Left  Wheel Up

	; Middle Button SELECTED : Per PAGE

	dc.w	-1,-1	; No Wheels Movement
	dc.w	1,1	; Left  Wheel Down
	dc.w	3,5	; Right Wheel Down
	dc.w	-1,-1
	dc.w	-1,-1
	dc.w	-1,-1
	dc.w	2,4	; Right Wheel Up
	dc.w	0,0	; Left  Wheel Up

; *** ACCESSORY NAME **********************************************************
	
	IFNE ST4D_EQU_DRIVER_TYPE ; --------------------------,

ST4D_DATA_ACC_Name	dc.b	"  ScrollTrack4D¿    ",0

	ELSEIF ; ---------------------------------------------+

ST4D_DATA_ACC_Name	dc.b	"  Minimal ST4D¿     ",0

	ENDC ; -----------------------------------------------'

; *** AES TABLE ***************************************************************

ST4D_DATA_AES_ParamsTab	dc.l	ST4D_BSS_AES_Control
	dc.l	ST4D_BSS_AES_Global
	dc.l	ST4D_BSS_AES_Int_In
	dc.l	ST4D_BSS_AES_Int_Out
	dc.l	ST4D_BSS_AES_Addr_In
	dc.l	ST4D_BSS_AES_Addr_Out
	
; *** SERIAL CONFIGURATION BitFIELD *******************************************

ST4D_DATA_RS_Params	dc.w	%10101110

; *** WM_ARROWED MESSAGE (READY TO SEND) **************************************

ST4D_DATA_AES_Message	dc.w	24	; WM_ARROWED
ST4D_DATA_AES_Handle	ds.w	1	; AP_ID of the ACC
	dc.w	0	; Normal GEM Mesag
ST4D_DATA_AES_WinHandle	ds.w	1	; Window Handle	
ST4D_DATA_AES_SelElem	ds.w	1	; Selected Element
	dc.w	0,0,0	; Additive Bytes	

; /////////////////////////////////////////////////////////////////////////////	
	SECTION	BSS
; /////////////////////////////////////////////////////////////////////////////	

ST4D_BSS_LATabVectAddr	ds.l	1	
ST4D_BSS_MousVectAddr	ds.l	1
ST4D_BSS_OldVblVector	ds.l	1	

ST4D_BSS_4DWheels	ds.w	1	

ST4D_BSS_ACC_Handle	ds.w	1

; *** BitFIELD FLAGS **********************************************************

ST4D_BSS_MultiFlag	ds.w	1
	; Bit 0	0 Turbo Veille UN-Activated
	;	1 Turbo Veille    Activated
	; Bit 1	0 Videl CUT UN-Activated
	;	1 Videl CUT    Activated
	; Bit 2	0 VIDEL Video Processor OK
	;	1 Something else
	; Bit 3	0 NO RS Load Requested
	;	1 OK RS Load Done, need processing

; *** SYSTEM VARIABLES ********************************************************

ST4D_BSS_Old_SR	ds.w	1

	IFNE ST4D_EQU_DRIVER_TYPE ; --------------------------,

ST4D_BSS_KbShift	ds.l	1
ST4D_BSS_TIME_Slice	ds.l	2

	ENDC ; -----------------------------------------------'

; *** REGISTERS BUFFERS *******************************************************

ST4D_BSS_MAIN_REGS	ds.l	16
ST4D_BSS_VBL_REGS	ds.l	16

	IFNE ST4D_EQU_DRIVER_TYPE ; --------------------------,

ST4D_BSS_IKBD_REGS	ds.l	16

	ENDC ; -----------------------------------------------'

; *** SERIAL BUFFERS **********************************************************

ST4D_BSS_RSBuffer	ds.l	1
ST4D_BSS_RSCounter	ds.l	1

; *** TurboVEILLE BUFFER ******************************************************

	IFNE ST4D_EQU_DRIVER_TYPE ; --------------------------,

ST4D_BSS_OldFaclC0	ds.l	1    
ST4D_BSS_OldColor0	ds.w	1
ST4D_BSS_OldHDE	ds.w	1
ST4D_BSS_OldVDE	ds.w	1
ST4D_BSS_OldVCO	ds.w	1

	ENDC ; -----------------------------------------------'

; *** AES BUFFER **************************************************************

ST4D_BSS_AES_Control	ds.w	5
ST4D_BSS_AES_Global	ds.w	14
ST4D_BSS_AES_Int_In	ds.w	16
ST4D_BSS_AES_Int_Out	ds.w	7
ST4D_BSS_AES_Addr_In	ds.l	3
ST4D_BSS_AES_Addr_Out	ds.l	1

; *** ACCESSORY STACK *********************************************************

	ds.l	256-2	; 256 LONGs
ST4D_BSS_AccStack	ds.l	2
