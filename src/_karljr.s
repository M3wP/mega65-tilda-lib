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
;
;===========================================================

	.setcpu		"4510"

	.include	"_karljr_types.inc"

	.code

	.export		_KarlInit
	.export		_KarlASCIIToScreen
	.export		_KarlGetLastError
	.export		_KarlClearZ
	.export		_KarlPanic
	.export		_KarlIOFast
	.export		__KarlModAttach
	.export		_KarlObjExcludeState
	.export		_KarlObjIncludeState
	.export		__KarlObjIncStateEx
	.export		__KarlObjExcStateEx

	.export		_KarlDefModPrepare
	.export		_KarlDefModInit
	.export		_KarlDefModChange
	.export		_KarlDefModRelease

	.export		__KarlProcObjLst
	.export		karl_dirty
	.export		karl_changed
	.export		karl_lock
	.export		__KarlCallObjLstMethod
	.export		_karl_errorno


;-----------------------------------------------------------
_KarlInit:
;-----------------------------------------------------------
		CLD

		JSR	_KarlIOFast

		LDA	#$04
		STA	zvaltemp0
		LDA	#$00
		STA	zvaltemp0 + 1
		STA	zvaltemp0 + 2
		STA	zvaltemp0 + 3

		LDA	#$00
		STA	_karl_errorno

		RTS


;-----------------------------------------------------------
_KarlASCIIToScreen:
;	.A		IN		ascii char
;	.A		OUT		screen byte
;-----------------------------------------------------------
		STA	karl_temp0
		LDY	#$07
@loop:
		LDA	karl_scrASCIIXlat, Y
		CMP	karl_temp0
		BEQ	@subst
		DEY
		BPL	@loop

		LDA	karl_temp0
		
		CMP	#$20
		BCS	@regular

@irregular:
		LDA	#$66
		RTS

@regular:
		CMP	#$7F
		BCS	@irregular

		CMP	#$40
		BCC	@exit
	
		CMP	#$60
		BCC	@upper
	
		SEC
		SBC	#$60
		
		RTS

@upper:
		SEC
		SBC	#$40
		
@exit:
		RTS

@subst:
		LDA	karl_scrASCIISub, Y
		RTS


;-----------------------------------------------------------
_KarlClearZ:
;-----------------------------------------------------------
		LDZ	#$00
		RTS


;-----------------------------------------------------------
_KarlGetLastError:
;-----------------------------------------------------------
		LDA	_karl_errorno

		RTS


;-----------------------------------------------------------
_KarlPanic:
;-----------------------------------------------------------
		SEI

		LDA	#$02
		STA	VIC_BRDRCLR

@panic:
		JMP	@panic


;-----------------------------------------------------------
_KarlIOFast:
;-----------------------------------------------------------
;	Go fast
		LDA	#65
		STA	$00

;	Enable M65 enhanced registers
		LDA	#$47
		STA	$D02F
		LDA	#$53
		STA	$D02F

;	Switch to fast mode
; 	1. C65 fast-mode enable
		LDA	$D031
		ORA	#$40
		STA	$D031
; 	2. MEGA65 40MHz enable (requires C65 or C128 fast mode 
;	to truly enable, hence the above)
		LDA	#$40
		TSB	$D054

		RTS


;-----------------------------------------------------------
__KarlModAttach:
;reg4		IN		module ptr
;-----------------------------------------------------------
		PHX
		PHY
		PHZ

	.if	DEBUG_RASTERTIME
		LDA	#$00
		STA	VIC_BRDRCLR
	.endif

		MvDWMem	zptrself, zreg0
		MvDWMem zptrowner, zreg0
		MvDWZ	zreg0

		LDA	#ERROR_MODULE
		STA	_karl_errorno

		LDZ	#OBJECT::prepare
		NOP
		LDA	(zptrself), Z
		STA	karl_proxyptr
		INZ
		NOP
		LDA	(zptrself), Z
		STA	karl_proxyptr + 1

		BEQ	@exit

		LDZ	#$00
		JSR	_KarlProxy

		LDA	_karl_errorno
		BNE	@exit

	.if	DEBUG_RASTERTIME
		LDA	#$01
		STA	VIC_BRDRCLR
	.endif

		MvDWMem	zptrself, zptrowner

		LDA	#ERROR_MODULE
		STA	_karl_errorno

		LDZ	#OBJECT::initialise
		NOP
		LDA	(zptrself), Z
		STA	karl_proxyptr
		INZ
		NOP
		LDA	(zptrself), Z
		STA	karl_proxyptr + 1

		BEQ	@exit

		LDZ	#$00
		JSR	_KarlProxy

		LDA	_karl_errorno
		BNE	@exit

		MvDWMem	zreg0, zptrowner

@exit:
		PLZ
		PLY
		PLX

		RTS


;-----------------------------------------------------------
__KarlObjExcStateEx:
;-----------------------------------------------------------
		LDA	zreg0b0
		LDX	zreg0b1
		LDY	zreg0b2

		PHX
		PHY

		JSR	_KarlObjExcludeState

		PLY
		PLA

		SEI

		STA	karl_temp0
		EOR	$FF
		STA	karl_temp1

		LDZ	#OBJECT::state + 1
		NOP
		LDA	(zptrself), Z

		CPY	#$00
		BEQ	@cont0

		AND	karl_temp0
		BEQ	@finish

		LDY	#$01
		STY	karl_changed

		NOP
		LDA	(zptrself), Z

@cont0:
		AND	karl_temp1

		NOP
		STA	(zptrself), Z

@finish:
		LDA	karl_lock
		BNE	@exit

	.if DEBUG_NOYIELDIRQ
	.else
		CLI
	.endif

@exit:
		RTS

;-----------------------------------------------------------
_KarlObjExcludeState:
;-----------------------------------------------------------
		CMP	#$00
		BEQ	@exit

		SEI

		STA	karl_temp0
		EOR	#$FF
		STA	karl_temp1

		LDA	#$00
		STA	karl_temp2

		LDA	karl_temp0
		AND	#(STATE_CHANGED | STATE_DIRTY | STATE_PREPARED)
		CMP	karl_temp0
		BNE	@begin0

		LDA	#$01
		STA	karl_temp2

@begin0:
		LDZ	#OBJECT::state
		NOP
		LDA	(zptrself), Z
		AND	karl_temp0
		BEQ	@finish

		NOP
		LDA	(zptrself), Z
		STA	karl_temp0
		AND	karl_temp1

		PHA

		LDZ	#OBJECT::oldstate
		LDA	karl_temp0
		NOP
		STA	(zptrself), Z

		PLA
		PHA

		AND	#STATE_CHANGED
		BNE	@cont0

		LDA	karl_temp2
		BNE	@cont0

		PLA
		ORA	#STATE_CHANGED

		LDZ	#$01
		STZ	karl_changed

		JMP	@cont1

@cont0:
		PLA

@cont1:
		LDZ	#OBJECT::state
		NOP
		STA	(zptrself), Z

@finish:
		LDA	karl_lock
		BNE	@exit

	.if DEBUG_NOYIELDIRQ
	.else
		CLI
	.endif


@exit:
		RTS


;-----------------------------------------------------------
__KarlObjIncStateEx:
;-----------------------------------------------------------
		LDA	zreg0b0
		LDX	zreg0b1
		LDY	zreg0b2

		PHX
		PHY

		JSR	_KarlObjIncludeState

		PLY
		PLX

		TXA
		BEQ	@exit

		SEI

		STX	karl_temp0

		LDZ	#OBJECT::state + 1
		NOP
		LDA	(zptrself), Z

		CPY	#$00
		BEQ	@cont0

		AND	karl_temp0
		BNE	@finish

		LDY	#$01
		STY	karl_changed

		NOP
		LDA	(zptrself), Z

@cont0:
		ORA	karl_temp0

		NOP
		STA	(zptrself), Z


@finish:
		LDA	karl_lock
		BNE	@exit

	.if DEBUG_NOYIELDIRQ
	.else
		CLI
	.endif

@exit:
		RTS


;-----------------------------------------------------------
_KarlObjIncludeState:
;-----------------------------------------------------------
		CMP	#$00
		BEQ	@exit

		SEI

		STA	karl_temp0

;		AND	#STATE_DIRTY
		BIT	#STATE_DIRTY
		BEQ	@test0

		LDA	#$01
		STA	karl_dirty

		JMP	@cont0

@test0:
;		LDA	karl_temp0
;		AND	#STATE_CHANGED
		BIT	#STATE_CHANGED
		BEQ	@cont0

		LDA	#$01
		STA	karl_changed

@cont0:
		LDZ	#OBJECT::state
		NOP
		LDA	(zptrself), Z

		PHA

		LDA	karl_temp0
;		AND	#(STATE_DIRTY | STATE_PREPARED)
		BIT	#(STATE_DIRTY | STATE_PREPARED)
		BEQ	@cont1

;		LDA	karl_temp0
;		AND	#STATE_CHANGED
		BIT	#STATE_CHANGED
		BEQ	@update

@cont1:
		PLA
		PHA

		AND	#STATE_CHANGED
		BNE	@changed

		NOP
		LDA	(zptrself), Z
		
		LDZ	#OBJECT::oldstate
		NOP
		STA (zptrself), Z

@changed:
		PLA
		ORA	#STATE_CHANGED
		ORA	karl_temp0

		LDZ	#OBJECT::state
		NOP
		STA	(zptrself), Z

		LDA	#$01
		STA	karl_changed

		JMP	@finish

@update:
		PLA
		ORA	karl_temp0

		NOP
		STA	(zptrself), Z

@finish:
		LDA	karl_lock
		BNE	@exit

	.if DEBUG_NOYIELDIRQ
	.else
		CLI
	.endif

@exit:
		RTS


;-----------------------------------------------------------
_KarlDefModPrepare:
;-----------------------------------------------------------
;@halt:
;		INC	$D020
;		JMP	@halt

		LDA	#MODULE::unitscnt
		STA	zreg5b0

		LDA	#MODULE::units_p
		STA	zreg5b2

		LDA	#OBJECT::prepare
		STA	zreg5b1

		MvDWMem	zreg4, zptrself

		JSR	__KarlCallObjLstMethod

		LDA	_karl_errorno
		BEQ	@exit

		LDA	#$01
		STA	zreg2b3
		LDA	#STATE_PREPARED
		JSR	_KarlObjIncludeState

@exit:
		RTS

;-----------------------------------------------------------
_KarlDefModInit:
;-----------------------------------------------------------
		LDA	#MODULE::unitscnt
		STA	zreg5b0

		LDA	#MODULE::units_p
		STA	zreg5b2

		LDA	#OBJECT::initialise
		STA	zreg5b1

		MvDWMem	zreg4, zptrself

		JSR	__KarlCallObjLstMethod
		RTS


;-----------------------------------------------------------
_KarlDefModChange:
;-----------------------------------------------------------
		RTS


;-----------------------------------------------------------
_KarlDefModRelease:
;-----------------------------------------------------------
		RTS


;-----------------------------------------------------------
_KarlProxy:
;-----------------------------------------------------------
		JMP	(karl_proxyptr)

karl_callstackidx:
		.repeat	FEATURE_CALLDEPTH, I
		.word	karl_callstack + (I * .sizeof(CALLCONTEXT))
		.endrepeat

karl_procstackidx:
		.repeat	FEATURE_CALLDEPTH, I
		.word	karl_procstack + (I * .sizeof(PROCCONTEXT))
		.endrepeat

;-----------------------------------------------------------
__KarlCallObjLstMStore:
;-----------------------------------------------------------
		LDA	karl_callcnt
		ASL
		TAX
		LDA	karl_callstackidx, X
		STA	zreg3wl
		LDA	karl_callstackidx + 1, X
		STA	zreg3wl + 1

		LDY	#$00

		LDA	zreg2b1
		STA	(zreg3wl), Y
		INY

		LDA	karl_proxyptr
		STA	(zreg3wl), Y
		INY

		LDA	karl_proxyptr + 1
		STA	(zreg3wl), Y

		RTS


;-----------------------------------------------------------
__KarlCallObjLstMLoad:
;-----------------------------------------------------------
		LDA	karl_callcnt
		ASL
		TAX
		LDA	karl_callstackidx, X
		STA	zreg3wl
		LDA	karl_callstackidx + 1, X
		STA	zreg3wl + 1

		LDY	#$00

		LDA	(zreg3wl), Y
		STA	zreg2b1
		INY

		LDA	(zreg3wl), Y
		STA	karl_proxyptr
		INY

		LDA	(zreg3wl), Y
		STA	karl_proxyptr + 1

		RTS


;-----------------------------------------------------------
__KarlCallObjLstMProc:
;-----------------------------------------------------------
		LDA	#ERROR_NONE
		STA	_karl_errorno

		MvDWMem	zptrself, zreg0

		LDZ	zreg2b1
		NOP
		LDA	(zptrself), Z
		STA	karl_proxyptr
		INZ
		NOP
		LDA	(zptrself), Z
		STA	karl_proxyptr + 1

		BEQ	@exit

		JSR	_KarlProxy

		LDA	_karl_errorno
		CMP	#ERROR_ABORT
		BNE	@exit

		LDA	#ERROR_NONE
		STA	_karl_errorno

@exit:
		RTS


;-----------------------------------------------------------
__KarlCallObjLstMethod:
;-----------------------------------------------------------
;	zreg4		IN		owner object
;	zreg5b1		IN		method index
;	zreg5b0		IN		list count index
;	zreg5b2		IN		owner's list index
;	zreg5b3		IN		direction
;-----------------------------------------------------------
		SEI

		JSR	__KarlCallObjLstMStore
		INC	karl_callcnt

	.if	DEBUG_RANGECHECK
		LDA	karl_callcnt
		CMP	#FEATURE_CALLDEPTH
		BCC	@contrc

		JSR	_KarlPanic
@contrc:
	.endif

		LDA	zreg5b1
		STA	zreg2b1

		LDA	#<__KarlCallObjLstMProc
		STA	zreg6wl
		LDA	#>__KarlCallObjLstMProc
		STA	zreg6wl + 1

		LDA	karl_lock
		BNE	@proc

	.if DEBUG_NOYIELDIRQ
	.else
		CLI
	.endif

@proc:
		JSR	__KarlProcObjLst

@finish:
		SEI

		DEC	karl_callcnt
		JSR	__KarlCallObjLstMLoad

		LDA	karl_lock
		BNE	@exit

	.if DEBUG_NOYIELDIRQ
	.else
		CLI
	.endif

@exit:
		RTS


;-----------------------------------------------------------
__KarlProcObjLstStore:
;-----------------------------------------------------------
;@halt:
;		INC	$D020
;		JMP	@halt

		LDA	karl_proccnt
		ASL
		TAX
		LDA	karl_procstackidx, X
		STA	zreg3wl
		LDA	karl_procstackidx + 1, X
		STA	zreg3wl + 1

		TSX
		INX
		INX
		INX
		INX
		INX
		INX
		INX

		LDY	#$00
		LDA	$0100, X
		STA	(zreg3wl), Y
		INY
		LDA	$0101, X
		STA	(zreg3wl), Y

		INW	zreg3wl
		INW	zreg3wl

		LDQMem	zptrself
		STQIndW zreg3wl

		INW	zreg3wl
		INW	zreg3wl
		INW	zreg3wl
		INW	zreg3wl

		LDY	#$00

		LDA	zreg2b2
		STA	(zreg3wl), Y
		INY

		LDA	zreg5b2
		STA	(zreg3wl), Y
;		INY

		INW	zreg3wl
		INW	zreg3wl

		LDQMem	zreg7
		STQIndW zreg3wl

		INW	zreg3wl
		INW	zreg3wl
		INW	zreg3wl
		INW	zreg3wl

		LDY	#$00

		LDA	zreg6wh
		STA	(zreg3wl), Y
		INY
		LDA	zreg6wh + 1
		STA	(zreg3wl), Y
;		INY

		INW	zreg3wl
		INW	zreg3wl

		LDQMem	zreg0
		STQIndW	zreg3wl

		INW	zreg3wl
		INW	zreg3wl
		INW	zreg3wl
		INW	zreg3wl

		LDY	#$00

		LDA	zreg2b0
		STA	(zreg3wl), Y
		INY

		LDA	karl_proxyptr
		STA	(zreg3wl), Y
		INY

		LDA	karl_proxyptr + 1
		STA	(zreg3wl), Y

		RTS


;-----------------------------------------------------------
__KarlProcObjLstLoad:
;-----------------------------------------------------------
		LDA	karl_proccnt
		ASL
		TAX
		LDA	karl_procstackidx, X
		STA	zreg3wl
		LDA	karl_procstackidx + 1, X
		STA	zreg3wl + 1

		INW	zreg3wl
		INW	zreg3wl

		LDZ	#$00

		LDQIndWZ	zreg3wl
		STQMem	zptrself

		LDZ	#$04

		LDA	(zreg3wl), Z
		STA	zreg2b2
		INZ

		LDA	(zreg3wl), Z
		STA	zreg5b2
		INZ

		LDQIndWZ	zreg3wl
		STQMem	zreg7

		LDZ	#$0A

		LDA	(zreg3wl), Z
		STA	zreg6wh
		INZ
		LDA	(zreg3wl), Z
		STA	zreg6wh + 1
		INZ

		LDQIndWZ	zreg3wl
		STQMem	zreg0

		LDZ	#$10

		LDA	(zreg3wl), Z
		STA	zreg2b0
		INZ

		LDA	(zreg3wl), Z
		STA	karl_proxyptr
		INZ

		LDA	(zreg3wl), Z
		STA	karl_proxyptr + 1

		RTS


;-----------------------------------------------------------
__KarlProcObjLst:
;	zreg4		IN		owner object
;	zreg5b0		IN		list count
;	zreg5b2		IN		owner's list index
;	zreg6wl		IN		callback routine
;	zreg5b3		IN		direction
;-----------------------------------------------------------
		SEI

		LDA	#$FF
		PHA
		PHA
		PHA
		PHA

		JSR	__KarlProcObjLstStore
		INC	karl_proccnt

	.if	DEBUG_RANGECHECK
		LDA	karl_proccnt
		CMP	#FEATURE_CALLDEPTH
		BCC	@contrc

		JSR	_KarlPanic
@contrc:
	.endif

		LDA	zreg5b3
		STA	zreg2b0

		LDZ	zreg5b0
		NOP
		LDA	(zreg4), Z

		LBEQ	@finish

		STA	zreg2b2

		MvDWObjMem	zreg7, zreg4, zreg5b2
		LDA	zreg6wl
		STA	zreg6wh
		LDA	zreg6wl + 1
		STA	zreg6wh + 1

		LDA	karl_lock
		BNE	@check

	.if DEBUG_NOYIELDIRQ
	.else
		CLI
	.endif

@check:
		LDA	zreg2b0
		BEQ	@continue

		LDX	zreg2b2
		DEX
		STX	zreg0b0
		LDA	#$00
		STA	zreg0b1

		STA	zreg0b2
		STA	zreg0b3

		ASLWMem	zreg0wl
		ASLWMem	zreg0wl

		LDQMem	zreg7
		CLC
		ADQMem	zreg0
		STQMem	zreg7

@continue:
		LDZ	#$00

		LDQIndDWZ	zreg7
		STQMem	zreg0

		LDA	zreg2b0
		BEQ	@loop0

@loop2:
		LDQMem	zreg7

		SEC
		SBQMem	zvaltemp0

		JMP	@proc

@loop0:
		LDQMem	zreg7
		CLC
		ADQMem	zvaltemp0

@proc:
		STQMem	zreg7

		DEC	zreg2b2

		LDA	zreg6wh
		STA	karl_proxyptr
		LDA	zreg6wh + 1
		STA	karl_proxyptr + 1

		BEQ	@next2

		LDA	#$00
		STA	_karl_errorno

		JSR	_KarlProxy

		LDA	_karl_errorno
		CMP	#ERROR_ABORT
		BEQ	@finish

@next2:
		LDA	zreg2b2
		BNE	@continue

@finish:
		SEI

		DEC	karl_proccnt
		JSR	__KarlProcObjLstLoad

		PLA
		PLA
		PLA
		PLA

		LDA	karl_lock
		BNE	@exit

	.if DEBUG_NOYIELDIRQ
	.else
		CLI
	.endif

@exit:
		RTS

karl_scrASCIIXlat:
	.byte	KEY_ASC_BSLASH, KEY_ASC_CARET, KEY_ASC_USCORE, KEY_ASC_BQUOTE
	.byte	KEY_ASC_OCRLYB, KEY_ASC_PIPE, KEY_ASC_CCRLYB, KEY_ASC_TILDE, $00
karl_scrASCIISub:
	.byte	$4D, $71, $64, $4A ,$55, $5D, $49, $1F, $00


	.data
karl_temp0:
		.byte	$00
karl_temp1:
		.byte	$00
karl_temp2:
		.byte	$00

;***FIXME	Protect from page boundary bug
karl_proxyptr:
		.word	$0000

_karl_errorno:
		.byte	$00

karl_lock:
		.byte	$00
karl_dirty:
		.byte	$00
karl_changed:
		.byte	$00


karl_callcnt:
		.byte	$00

karl_callstack:
		.res	(.sizeof(CALLCONTEXT) * FEATURE_CALLDEPTH), 0

karl_proccnt:
		.byte	$00

karl_procstack:
		.res	(.sizeof(PROCCONTEXT) * FEATURE_CALLDEPTH), 0
