;===========================================================
;Karl Jr
;===========================================================
;
; Simple object life-time management.
;
; (c) Daniel England 2022, All Rights Reserved.
;
; I intend to release this under LGPL 3?
;
;-----------------------------------------------------------
;
; Karl Jr allows modules and units to be used and the 
; objects there-in managed.
;
; Unfortunately, Karl Jr has no memory management...  The 
; actual name-space is yet to be defined.
;
; Karl Jr is standing-in for a HAL module at this time, 
; also (probably to be called Downe, the memory manager
; likely Revere)
;
; Objects are stored in a heirarchy.  Modules contain units
; which contain objects.  Modules can be attached and 
; (eventually) detached from the system.  A name-space and
; browsing capabilities are future enhancements.
;
;===========================================================

	.ifdef  INCLUDE_KARL_TYPES_INC

	.else

	.define	INCLUDE_KARL_TYPES_INC $01

;	Debugging:  Show raster time usage on border
	.define	DEBUG_RASTERTIME	0

;	Debugging:  Don't yeild to IRQ again after suspend
	.define	DEBUG_NOYIELDIRQ	0

;	Debugging:  Ensure bounds limits on stacks
	.define	DEBUG_RANGECHECK	1

;	Feature:  Depth of recursion supported by list processing
	.define	FEATURE_CALLDEPTH	8


	.setcpu		"4510"

	.importzp	__zkarljr


	zptrself=	__zkarljr + $04;
	zptrowner=	__zkarljr + $08;
	zptrscreen=	__zkarljr + $0C
	zptrcolour=	__zkarljr + $10
	zptrtemp0=	__zkarljr + $14
	zptrtemp1=	__zkarljr + $18
	zptrtemp2=	__zkarljr + $1C

	zreg0	=	__zkarljr + $20
	zreg0wl	=	__zkarljr + $20
	zreg0wh	=	__zkarljr + $22
	zreg0b0	=	__zkarljr + $20
	zreg0b1	=	__zkarljr + $21
	zreg0b2	=	__zkarljr + $22
	zreg0b3	=	__zkarljr + $23
	zreg1	=	__zkarljr + $24
	zreg1wl	=	__zkarljr + $24
	zreg1wh	=	__zkarljr + $26
	zreg1b0	=	__zkarljr + $24
	zreg1b1	=	__zkarljr + $25
	zreg1b2	=	__zkarljr + $26
	zreg1b3	=	__zkarljr + $27
	zreg2	=	__zkarljr + $28
	zreg2wl	=	__zkarljr + $28
	zreg2wh	=	__zkarljr + $2A
	zreg2b0	=	__zkarljr + $28
	zreg2b1	=	__zkarljr + $29
	zreg2b2	=	__zkarljr + $2A
	zreg2b3	=	__zkarljr + $2B
	zreg3	=	__zkarljr + $2C
	zreg3wl	=	__zkarljr + $2C
	zreg3wh	=	__zkarljr + $2E
	zreg3b0	=	__zkarljr + $2C
	zreg3b1	=	__zkarljr + $2D
	zreg3b2	=	__zkarljr + $2E
	zreg3b3	=	__zkarljr + $2F

	zreg4	=	__zkarljr + $30
	zreg4wl	=	__zkarljr + $30
	zreg4wh	=	__zkarljr + $32
	zreg4b0	=	__zkarljr + $30
	zreg4b1	=	__zkarljr + $31
	zreg4b2	=	__zkarljr + $32
	zreg4b3	=	__zkarljr + $33
	zreg5	=	__zkarljr + $34
	zreg5wl	=	__zkarljr + $34
	zreg5wh	=	__zkarljr + $36
	zreg5b0	=	__zkarljr + $34
	zreg5b1	=	__zkarljr + $35
	zreg5b2	=	__zkarljr + $36
	zreg5b3	=	__zkarljr + $37
	zreg6	=	__zkarljr + $38
	zreg6wl	=	__zkarljr + $38
	zreg6wh	=	__zkarljr + $3A
	zreg6b0	=	__zkarljr + $38
	zreg6b1	=	__zkarljr + $39
	zreg6b2	=	__zkarljr + $3A
	zreg6b3	=	__zkarljr + $3B
	zreg7	=	__zkarljr + $3C
	zreg7wl	=	__zkarljr + $3C
	zreg7wh	=	__zkarljr + $3E
	zreg7b0	=	__zkarljr + $3C
	zreg7b1	=	__zkarljr + $3D
	zreg7b2	=	__zkarljr + $3E
	zreg7b3	=	__zkarljr + $3F

	zreg8	=	__zkarljr + $40
	zreg8wl	=	__zkarljr + $40
	zreg8wh	=	__zkarljr + $42
	zreg8b0	=	__zkarljr + $40
	zreg8b1	=	__zkarljr + $41
	zreg8b2	=	__zkarljr + $42
	zreg8b3	=	__zkarljr + $43
	zreg9	=	__zkarljr + $44
	zreg9wl	=	__zkarljr + $44
	zreg9wh	=	__zkarljr + $46
	zreg9b0	=	__zkarljr + $44
	zreg9b1	=	__zkarljr + $45
	zreg9b2	=	__zkarljr + $46
	zreg9b3	=	__zkarljr + $47
	zregA	=	__zkarljr + $48
	zregAwl	=	__zkarljr + $48
	zregAwh	=	__zkarljr + $4A
	zregAb0	=	__zkarljr + $48
	zregAb1	=	__zkarljr + $49
	zregAb2	=	__zkarljr + $4A
	zregAb3	=	__zkarljr + $4B
	zregB	=	__zkarljr + $4C
	zregBwl	=	__zkarljr + $4C
	zregBwh	=	__zkarljr + $4E
	zregBb0	=	__zkarljr + $4C
	zregBb1	=	__zkarljr + $4D
	zregBb2	=	__zkarljr + $4E
	zregBb3	=	__zkarljr + $4F

	zregC	=	__zkarljr + $50
	zregCwl	=	__zkarljr + $50
	zregCwh	=	__zkarljr + $52
	zregCb0	=	__zkarljr + $50
	zregCb1	=	__zkarljr + $51
	zregCb2	=	__zkarljr + $52
	zregCb3	=	__zkarljr + $53
	zregD	=	__zkarljr + $54
	zregDwl	=	__zkarljr + $54
	zregDwh	=	__zkarljr + $56
	zregDb0	=	__zkarljr + $54
	zregDb1	=	__zkarljr + $55
	zregDb2	=	__zkarljr + $56
	zregDb3	=	__zkarljr + $57
	zregE	=	__zkarljr + $58
	zregEwl	=	__zkarljr + $58
	zregEwh	=	__zkarljr + $5A
	zregEb0	=	__zkarljr + $58
	zregEb1	=	__zkarljr + $59
	zregEb2	=	__zkarljr + $5A
	zregEb3	=	__zkarljr + $5B
	zregF	=	__zkarljr + $5C
	zregFwl	=	__zkarljr + $5C
	zregFwh	=	__zkarljr + $5E
	zregFb0	=	__zkarljr + $5C
	zregFb1	=	__zkarljr + $5D
	zregFb2	=	__zkarljr + $5E
	zregFb3	=	__zkarljr + $5F

	zvaltemp0=	__zkarljr + $60
	zvalkey	=	__zkarljr + $64


	CPU_IRQ		=	$FFFE
	CPU_RESET	=	$FFFC
	CPU_NMI		=	$FFFA

	CIA1_IRQCTL	=	$DC0D
	CIA1_DDRA	=	$DC02
	CIA1_DDRB	=	$DC03
	CIA1_PRB	=	$DC01

	VIC_XPOS	=	$D000
	VIC_YPOS	=	$D001
	VIC_XPOSMSB	=	$D010
	VIC_CTRLREG	=	$D011
	VIC_RSTRVAL	=	$D012
	VIC_IRQFLGS	=	$D019
	VIC_IRQMASK	=	$D01A
	VIC_BRDRCLR	=	$D020
	VIC_BKGDCLR	=	$D021

	VIC_CLRRAMH	=	$0FF80000

	SID_ADCONV1	=	$D419
	SID_ADCONV2	=	$D41A

	SPRITE_OFFX	=	24
	SPRITE_OFFY	=	50

	MOUSE_LBTN	=	$10
	MOUSE_RBTN	=	$01


;	.define	KEY_ASC_BKSPC	$08
	.define KEY_ASC_CR	$0D

	.define KEY_ASC_SPACE	$20
	.define KEY_ASC_EXMRK	$21
	.define KEY_ASC_DQUOTE	$22
	.define KEY_ASC_POUND	$23
	.define KEY_ASC_HASH	$23		;Alternate
	.define KEY_ASC_DOLLAR	$24
	.define KEY_ASC_PERCENT	$25
	.define KEY_ASC_AMP 	$26
	.define KEY_ASC_QUOTE	$27
	.define KEY_ASC_OBRCKT 	$28
	.define KEY_ASC_LBRCKT 	$28		;Alternate
	.define	KEY_ASC_CBRCKT	$29
	.define	KEY_ASC_RBRCKT	$29		;Alternate
	.define KEY_ASC_MULT	$2A
	.define KEY_ASC_PLUS	$2B
	.define KEY_ASC_COMMA	$2C
	.define KEY_ASC_MINUS	$2D
	.define KEY_ASC_STOP	$2E
	.define KEY_ASC_DIV	$2F
	.define KEY_ASC_FSLASH	$2F		;Alternate
	.define KEY_ASC_0	$30
	.define KEY_ASC_1	$31
	.define KEY_ASC_2	$32
	.define KEY_ASC_3	$33
	.define KEY_ASC_4	$34
	.define KEY_ASC_5	$35
	.define KEY_ASC_6	$36
	.define KEY_ASC_7	$37
	.define KEY_ASC_8	$38
	.define KEY_ASC_9	$39
	.define KEY_ASC_COLON	$3A
	.define KEY_ASC_SCOLON	$3B
	.define KEY_ASC_LESSTH	$3C
	.define KEY_ASC_EQUALS	$3D
	.define	KEY_ASC_GRTRTH	$3E
	.define KEY_ASC_QMARK	$3F
	.define KEY_ASC_AT	$40
	.define KEY_ASC_A	$41
	.define KEY_ASC_B	$42
	.define KEY_ASC_C	$43
	.define KEY_ASC_D	$44
	.define KEY_ASC_E	$45
	.define KEY_ASC_F	$46
	.define KEY_ASC_G	$47
	.define KEY_ASC_H	$48
	.define KEY_ASC_I	$49
	.define KEY_ASC_J	$4A
	.define KEY_ASC_K	$4B
	.define KEY_ASC_L	$4C
	.define KEY_ASC_M	$4D
	.define KEY_ASC_N	$4E
	.define KEY_ASC_O	$4F
	.define KEY_ASC_P	$50
	.define KEY_ASC_Q	$51
	.define KEY_ASC_R	$52
	.define KEY_ASC_S	$53
	.define KEY_ASC_T	$54
	.define KEY_ASC_U	$55
	.define KEY_ASC_V	$56
	.define KEY_ASC_W	$57
	.define	KEY_ASC_X	$58
	.define KEY_ASC_Y	$59
	.define	KEY_ASC_Z	$5A
	.define	KEY_ASC_OSQRBR	$5B
	.define	KEY_ASC_LSQRBR	$5B		;Alternate
;
	.define KEY_ASC_CSQRBR	$5D
	.define KEY_ASC_RSQRBR	$5D		;Alternate
;
	.define KEY_ASC_L_A	$61
	.define KEY_ASC_L_B	$62
	.define KEY_ASC_L_C	$63
	.define KEY_ASC_L_D	$64
	.define KEY_ASC_L_E	$65
	.define KEY_ASC_L_F	$66
	.define KEY_ASC_L_G	$67
	.define KEY_ASC_L_H	$68
	.define KEY_ASC_L_I	$69
	.define KEY_ASC_L_J	$6A
	.define KEY_ASC_L_K	$6B
	.define KEY_ASC_L_L	$6C
	.define KEY_ASC_L_M	$6D
	.define KEY_ASC_L_N	$6E
	.define KEY_ASC_L_O	$6F
	.define KEY_ASC_L_P	$70
	.define KEY_ASC_L_Q	$71
	.define KEY_ASC_L_R	$72
	.define KEY_ASC_L_S	$73
	.define KEY_ASC_L_T	$74
	.define KEY_ASC_L_U	$75
	.define KEY_ASC_L_V	$76
	.define KEY_ASC_L_W	$77
	.define	KEY_ASC_L_X	$78
	.define KEY_ASC_L_Y	$79
	.define	KEY_ASC_L_Z	$7A


	.define KEY_ASC_BSLASH	$5C		;!!Needs screen code xlat
	.define KEY_ASC_CARET	$5E		;!!Needs screen code xlat
	.define KEY_ASC_USCORE	$5F		;!!Needs screen code xlat
	.define KEY_ASC_BQUOTE	$60		;!!Needs screen code xlat. !!Not C64
	.define KEY_ASC_OCRLYB	$7B		;!!Needs screen code xlat. !!Not C64
	.define KEY_ASC_LCRLYB	$7B		;Alternate
	.define KEY_ASC_PIPE	$7C		;!!Needs screen code xlat
	.define KEY_ASC_CCRLYB	$7D		;!!Needs screen code xlat. !!Not C64
	.define KEY_ASC_RCRLYB	$7D		;Alternate
	.define KEY_ASC_TILDE	$7E		;!!Needs screen code xlat


	.define KEY_C64_STOP	$03
	.define KEY_C64_HOME	$13
	.define KEY_C64_POUND	$A3		
	.define KEY_C64_ARRUP	$AF		
	.define KEY_C64_ARRLEFT	$5F

	.define	KEY_C64_CRIGHT	$1D
	.define	KEY_C64_CDOWN	$11

	.define	KEY_C64_DEL		$14

	.define KEY_M65_ESC		$1B
	.define KEY_M65_TAB		$09

	.define KEY_M65_NONE	$00


	.define	KEY_M65_F1		$F1
	.define	KEY_M65_F2		$F2
	.define	KEY_M65_F3		$F3
	.define	KEY_M65_F4		$F4
	.define	KEY_M65_F5		$F5
	.define	KEY_M65_F6		$F6
	.define	KEY_M65_F7		$F7
	.define	KEY_M65_F8		$F8
	.define	KEY_M65_F9		$F9
	.define	KEY_M65_F10		$FA
	.define	KEY_M65_F11		$FB
	.define	KEY_M65_F12		$FC
	.define	KEY_M65_F13		$FD
	.define	KEY_M65_F14		$FE

	.define	KEY_M65_HELP	$1F


	.define	KEY_MOD_SHFTR	$01
	.define	KEY_MOD_SHFTL	$02
	
	.define	KEY_MOD_SHIFT	$03

	.define	KEY_MOD_CTRL	$04
	.define	KEY_MOD_SYS		$08
	.define	KEY_MOD_ALT		$10
	.define	KEY_MOD_NSCRL	$20
	.define	KEY_MOD_CAPLK	$40


	.define STATE_CHANGED	$80
	.define STATE_DIRTY		$40
	.define STATE_PREPARED	$20
	.define STATE_VISIBLE	$01
	.define STATE_ENABLED	$02
	.define STATE_PICKED	$04
	.define STATE_ACTIVE	$08
	.define STATE_DOWN		$10
	.define STATE_EXPRESENT	$0100

	.define	STATE_DEFAULT	STATE_ENABLED
	.define	STATE_DEFCTRL	STATE_VISIBLE | STATE_ENABLED

	.define	OPT_NOAUTOINVL	$01
	.define	OPT_NONAVIGATE	$02
	.define OPT_NODOWNACTV	$04
	.define OPT_DOWNCAPTURE $10
	.define	OPT_AUTOCHECK	$20
	.define OPT_TEXTACCEL2X	$40
	.define OPT_TEXTCONTMRK $80
	.define	OPT_NOAUTOCHKOF $0100
	.define	OPT_AUTOTRACK	$0200

	.define	ERROR_ABORT		$FF
	.define	ERROR_NONE		$00
	.define	ERROR_MODULE	$10
	.define	ERROR_UNIT		$20
	.define	ERROR_OBJECT	$40
	.define	ERROR_SYSTEM	$80


	.struct	FARPTR
		_0	.dword
	.endstruct

	.struct	EVENTPTR
		_0	.word
	.endstruct


;	MODULE
;	  |
;	  +UNIT


	.struct OBJECT
;	Type details
		size		.byte
		parent		.tag	FARPTR

;	Function calls
		prepare		.tag	EVENTPTR
		initialise	.tag	EVENTPTR
		change		.tag	EVENTPTR
		release		.tag	EVENTPTR

;	State information
		state		.word
		oldstate	.word
		options		.word

;	Data items
		tag			.word
	.endstruct


	.struct	NAME
		_data		.res	17
	.endstruct


	.struct	NAMEDOBJECT
		_object		.tag	OBJECT
		name		.tag	NAME
	.endstruct


	.struct	MODULE
		_named		.tag	NAMEDOBJECT

		units_p		.tag	FARPTR
		unitscnt	.byte
	.endstruct


	.struct	UNIT
		_named		.tag	NAMEDOBJECT
	.endstruct


	.struct	CALLCONTEXT
		methidx		.byte
		proxy		.word
	.endstruct

	.struct	PROCCONTEXT
		return		.word

		self		.tag	FARPTR		;0
		listcnt		.byte				;4
		listidx		.byte				;5
		object		.tag	FARPTR		;6
		routine		.word				;10
		target		.tag	FARPTR		;12
		direction	.byte				;16
		proxy		.word				;17
	.endstruct


	.macro	MvDWZ	dst
		LDA	#$00
		STA	dst
		STA	dst + 1
		STA	dst + 2
		STA	dst + 3
	.endmacro

	.macro	MvDWImm	dst, dwsrc
		LDA	#<.loword(dwsrc)
		STA	dst
		LDA	#>.loword(dwsrc)
		STA	dst + 1
		LDA	#<.hiword(dwsrc)
		STA	dst + 2
		LDA	#>.hiword(dwsrc)
		STA	dst + 3
	.endmacro

	.macro	MvDWMem	dst, src
		PHX
		PHY

		NEG
		NEG
		LDA	src

		NEG
		NEG
		STA	dst

		PLY
		PLX
;		LDA	src
;		STA	dst
;		LDA	src + 1
;		STA	dst + 1
;		LDA	src + 2
;		STA	dst + 2
;		LDA	src + 3
;		STA	dst + 3
	.endmacro

	.macro	MvDWObjMem	dst, src, offset
		PHX
		PHY

		LDZ	offset
		NEG
		NEG
		NOP
		LDA	(src), Z

		NEG
		NEG
		STA	dst

		PLY
		PLX

;		LDZ	offset
;		NOP
;		LDA	(src), Z
;		STA	dst
;		INZ
;		NOP
;		LDA	(src), Z
;		STA	dst + 1
;		INZ
;		NOP
;		LDA	(src), Z
;		STA	dst + 2
;		INZ
;		NOP
;		LDA	(src), Z
;		STA	dst + 3
	.endmacro

	.macro	MvDWObjImm	dst, src, offset
		PHX
		PHY

		LDZ	#offset
		NEG
		NEG
		NOP
		LDA	(src), Z

		NEG
		NEG
		STA	dst

		PLY
		PLX

;		NOP
;		LDA	(src), Z
;		STA	dst
;		INZ
;		NOP
;		LDA	(src), Z
;		STA	dst + 1
;		INZ
;		NOP
;		LDA	(src), Z
;		STA	dst + 2
;		INZ
;		NOP
;		LDA	(src), Z
;		STA	dst + 3
	.endmacro

	.macro	ASLWMem	src
		CLC
		LDA	src
		ASL
		STA	src
		LDA	src + 1
		ROL
		STA	src + 1
	.endmacro

	.macro	LSRWMem	src
		CLC
		LDA	src + 1
		LSR
		STA	src + 1
		LDA	src
		ROR
		STA	src
	.endmacro

	.macro	LDQMem src
		NEG
		NEG
		LDA	src
	.endmacro

	.macro	LDQIndWZ src
		NEG
		NEG
		LDA	(src), Z
	.endmacro

	.macro	LDQIndDWZ	dst
		NEG
		NEG
		NOP
		LDA	(dst), Z
	.endmacro

	.macro	STQIndW	dst
		NEG
		NEG
		STA	(dst), Z
;		PHZ
;		LDZ	#$00
;		STA	(dst), Z
;		INZ
;		TXA
;		STA	(dst), Z
;		INZ
;		TYA
;		STA	(dst), Z
;		INZ
;		PLA
;		STA	(dst), Z
	.endmacro

	.macro	STQMem	dst
		NEG
		NEG
		STA	dst
	.endmacro

	.macro	ADQMem	src
		NEG
		NEG
		ADC	src
	.endmacro

	.macro	SBQMem	src
		NEG
		NEG
		SBC	src
	.endmacro

	.macro	LSQMem src
		NEG
		NEG
		LSR	src
	.endmacro

	.macro	CPQMem	src
		NEG
		NEG
		CMP	src
	.endmacro

.endif