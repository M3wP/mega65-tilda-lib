;===========================================================
;Jude
;===========================================================
;
; Simple text-based GUI system and widget library.
;
; (c) Daniel England 2022, All Rights Reserved.
;
; I intend to release this under LGPL 3?
;
;-----------------------------------------------------------
;
;-----------------------------------------------------------

	.include	"_karljr_types.inc"
	.include	"_jude_types.inc"

	.code

	.export		_JudeInit
	.export		__JudeViewInit
	.export		_JudeMain

	.export		_JudeDeActivatePage
	.export		_JudeActivatePage
	.export		_JudeUnDownCtrl
	.export		_JudeDownCtrl
	.export		_JudeDeActivateCtrl
	.export		_JudeActivateCtrl
	.export		_JudeSetPointer

	.export		__JudeEraseLine
	.export		_JudeEraseBkg
	.export		__JudeDrawText
	.export		__JudeDrawTextDirect
	.export		_JudeDrawAccel
	.export		_JudeLogClrToSys
	.export		__JudeLogClrIsReverse
	.export		_JudeEnqueueKey
	.export		_JudeDequeueKey
	.export		__JudeMoveActiveControl

	.export		_JudeDefUIPrepare
	.export		_JudeDefUIInit
	.export		_JudeDefUIChange
	.export		_JudeDefUIRelease
	.export		_JudeDefViewPrepare
	.export		_JudeDefViewInit
	.export		_JudeDefViewChange
	.export		_JudeDefViewRelease
	.export		_JudeDefLyrPrepare
	.export		_JudeDefLyrInit
	.export		_JudeDefLyrChange
	.export		_JudeDefLyrRelease
	.export		_JudeDefPgePrepare
	.export		_JudeDefPgeInit
	.export		_JudeDefPgeChange
	.export		_JudeDefPgeRelease
	.export		_JudeDefPgePresent
	.export		_JudeDefPnlPrepare
	.export		_JudeDefPnlInit
	.export		_JudeDefPnlChange
	.export		_JudeDefPnlRelease
	.export		_JudeDefPnlPresent

	.export		__JudeProcessAccelerators

	.export		jude_cellsize
	.export		jude_coloury0
	.export		jude_screeny0
	.export		jude_actvpg
	.export		judeDownElem

	.export		_mouseXCol = mouseXCol
	.export		_mouseYRow = mouseYRow


	.import		_KarlASCIIToScreen
	.import		_KarlGetLastError
	.import		_KarlPanic
	.import		_KarlIOFast
	.import		__KarlModAttach
	.import		_KarlObjExcludeState
	.import		_KarlObjIncludeState

	.import		__KarlProcObjLst
	.import		karl_dirty
	.import		karl_changed
	.import		karl_lock
	.import		__KarlCallObjLstMethod
	.import		_karl_errorno

	.import		_KarlDefModPrepare
	.import		_KarlDefModInit
	.import		_KarlDefModChange
	.import		_KarlDefModRelease

;		SEI
;@halt:
;		INC	$D020
;		JMP	@halt

;-----------------------------------------------------------
_JudeInit:
;-----------------------------------------------------------
		MvDWImm zreg0, mod_jude_core
		JSR	__KarlModAttach

		LDX	#.sizeof(NAME)
@loop0:
		LDA	theme0, X
		STA	jude_theme - .sizeof(NAME), X

		INX
		CPX	#(.sizeof(NAME) + $0F)
		BNE	@loop0


;***FIXME Check return
		RTS


;-----------------------------------------------------------
__JudeViewInit:
;	reg0		IN		VIEW
;-----------------------------------------------------------
		MvDWMem	zptrself, zreg0
		MvDWMem	zreg8, zptrself

		LDA	#ERROR_NONE
		STA	_karl_errorno

;	Check prepared
		LDZ	#OBJECT::state
		NOP
		LDA	(zptrself), Z

		AND	#STATE_PREPARED
		LBEQ	@exit

	.if	DEBUG_RASTERTIME
		LDA	#$05
		STA	VIC_BRDRCLR
	.endif

;	Prepare owned objects (bars, pages only here)
		LDA	#VIEW::barscnt
		STA	zreg5b0

		LDA	#VIEW::bars_p
		STA	zreg5b2

		LDA	#OBJECT::prepare
		STA	zreg5b1

		LDA	#$00
		STA	zreg5b3

		MvDWMem	zreg4, zptrself
;		MvDWMem	zreg4, zreg8

		JSR	__KarlCallObjLstMethod

		LDA	_karl_errorno
		LBNE	@exit

		LDA	#VIEW::pagescnt
		STA	zreg5b0

		LDA	#VIEW::pages_p
		STA	zreg5b2

		LDA	#OBJECT::prepare
		STA	zreg5b1

		LDA	#$00
		STA	zreg5b3

		MvDWMem	zreg4, zptrself
;		MvDWMem	zreg4, zreg8

		JSR	__KarlCallObjLstMethod

		LDA	_karl_errorno
		LBNE	@exit

;	Init
		LDA	#ERROR_NONE
		STA	_karl_errorno

		LDZ	#OBJECT::initialise
		NOP
		LDA	(zptrself), Z
;		LDA	(zreg8), Z
		STA	jude_proxyptr
		INZ
		NOP
		LDA	(zptrself), Z
;		LDA	(zreg8), Z
		STA	jude_proxyptr + 1

		BEQ	@exit

		LDZ	#$00
		JSR	__JudeProxy

		LDA	#$00
		STA	jude_avhrsx

		LDZ	#VIEW::width
		NOP
		LDA	(zptrself), Z
		CMP	#$29
		BCC @cont0

		LDA	#$01
		STA	jude_avhrsx

@cont0:
		LDA	#$00
		STA	jude_avhrsy

		LDZ	#VIEW::height
		NOP
		LDA	(zptrself), Z
		CMP	#$1A
		BCC @cont1

		LDA	#$01
		STA	jude_avhrsy

@cont1:
		MvDWMem	jude_actvvw, zptrself
		MvDWObjImm	zreg4, zptrself, VIEW::actvpage_p
		MvDWMem	zptrself, zreg4

		JSR	_JudeActivatePage

		LDA	#ERROR_NONE
		STA	_karl_errorno

@exit:
		RTS


;-----------------------------------------------------------
_JudeMain:
;-----------------------------------------------------------
;		SEI
;@halt:
;		INC	$D020
;		JMP	@halt

@main:
		CLI

;	Check not locked
;	Suspend IRQ
		SEI
		LDA	karl_lock
		BNE	@main

;	Set processed this frame
		LDA	#$01
		STA	jude_proc

		CLI

;	Check if have already processed this frame
;		LDA	jude_proc
;		BNE	@done

		LDA	jude_actvpg
		ORA	jude_actvpg + 1
		ORA	jude_actvpg + 2
		ORA	jude_actvpg + 3
		BEQ	@done

;	Check Changed
		LDA	karl_changed
		BEQ	@keys

		JSR	__JudeUpdateChanged

		LDA	#$00
		STA	karl_changed
		JMP	@finish

;	Check Keys
@keys:
		JSR	__JudeSendKeys

;	Check Dirty
@dirty:
		LDA	karl_dirty
		BEQ	@finish

		JSR	__JudePresentDirty

		LDA	#$00
		STA	karl_dirty

@finish:

@done:
;	Release IRQ
;		CLI
		SEI
		LDA	#$00
		STA	jude_proc

		JMP	@main


;-----------------------------------------------------------
_JudeDeActivatePage:
;-----------------------------------------------------------
		LDA	#STATE_ACTIVE
		JSR	_KarlObjExcludeState
		
		LDA	#STATE_DIRTY
		JSR	_KarlObjExcludeState

		MvDWZ	jude_actvpg

;**FIXME	Update view?

		JSR	__MouseUnPickElement
		JSR	_JudeDeActivateCtrl

		RTS


;-----------------------------------------------------------
_JudeActivatePage:
;-----------------------------------------------------------
		LDA	jude_actvpg
		ORA	jude_actvpg + 1
		ORA	jude_actvpg + 2
		ORA	jude_actvpg + 3
		BEQ	@activate

		LDQMem	zptrself
		STQMem	zreg4

		LDQMem	jude_actvpg
		STQMem	zptrself

		JSR	_JudeDeActivatePage

		LDQMem	zreg4
		STQMem	zptrself

@activate:
		MvDWMem	jude_actvpg, zptrself

		LDA	#STATE_DIRTY | STATE_ACTIVE
		JSR	_KarlObjIncludeState

		LDA	#KEY_C64_CDOWN
		STA	zvalkey
		LDA	#$00
		STA	zvalkey + 1

		JSR	__JudeMoveActiveControl

;**FIXME	Update view?

		RTS


;-----------------------------------------------------------
_JudeUnDownCtrl:
;-----------------------------------------------------------
		LDA	judeDownElem
		ORA	judeDownElem + 1
		ORA	judeDownElem + 2
		ORA	judeDownElem + 3
		BEQ	@exit

		MvDWMem	zptrself, judeDownElem

		LDA	#STATE_DOWN
		JSR	_KarlObjExcludeState

		MvDWZ	judeDownElem

@exit:
		RTS


;-----------------------------------------------------------
_JudeDownCtrl:
;-----------------------------------------------------------
		MvDWMem	zreg4, zptrself

		JSR	_JudeUnDownCtrl

		LDZ	#OBJECT::options
		NOP
		LDA	(zreg4), Z
		AND	#OPT_NONAVIGATE
		BNE	@nodeact

		JSR	_JudeDeActivateCtrl

@nodeact:
		MvDWMem	zptrself, zreg4

;		LDA	#$00
;		STA	zreg2b3
		LDA	#STATE_DOWN
		JSR	_KarlObjIncludeState

		MvDWMem	judeDownElem, zptrself

		LDZ	#OBJECT::options
		NOP
		LDA	(zptrself), Z
		AND	#OPT_NONAVIGATE
		BNE	@noact

		JSR	_JudeActivateCtrl

@noact:
		RTS


;-----------------------------------------------------------
_JudeDeActivateCtrl:
;-----------------------------------------------------------
		LDA	judeActvElem
		ORA	judeActvElem + 1
		ORA	judeActvElem + 2
		ORA	judeActvElem + 3
		BEQ	@exit

		MvDWMem	zptrself, judeActvElem

		LDA	#STATE_ACTIVE
		JSR	_KarlObjExcludeState

		MvDWZ	judeActvElem

@exit:
		RTS


;-----------------------------------------------------------
_JudeActivateCtrl:
;-----------------------------------------------------------
		MvDWMem	zreg4, zptrself

		JSR	_JudeDeActivateCtrl
		
		MvDWMem	zptrself, zreg4

;		LDA	#$00
;		STA	zreg2b3
		LDA	#STATE_ACTIVE
		JSR	_KarlObjIncludeState

		MvDWMem	judeActvElem, zptrself

		RTS


;-----------------------------------------------------------
_JudeSetPointer:
;-----------------------------------------------------------
		PHA

		LDQMem	jude_mouseptr
		STQMem	zregA

		LDA	jude_mousevic
		STA	zregBwl
		LDA	jude_mousevic + 1
		STA	zregBwl + 1

		PLA

		CMP	#MPTR_NORMAL
		BEQ	@move

		CMP	#MPTR_WAIT
		BNE	@exit

		LDX	$D020
		STX	jude_brdbak

		INW	zregBwl
		INW	zregBwl
		INW	zregBwl

		PHA

		JSR	__MouseUnPickElement

		PLA

@move:
		STA	jude_mptrstate

		LDA	jude_brdbak
		STA $D020

;	Sprite pointer
		LDZ	#$00
		LDA	zregBwl
		NOP
		STA	(zregA), Z

		INZ
		LDA	zregBwl + 1
		NOP
		STA	(zregA), Z
		
@exit:
		RTS



;-----------------------------------------------------------
__JudeEraseLine:
;	IN	zregAwl		colour
;	IN	zregAb3		Max width
;	IN	zregBb1		x pos
;	IN	zregBb2		y pos
;-----------------------------------------------------------
;		SEI
; @halt:
;		INC	$D020
;		JMP	@halt

		LDA	zregAwl
		STA	zreg9b0			;colour
		LDX	zregAwl + 1
		STX	zreg9b1

		LDA	zregAb3
		STA	zregBb3

		LDA	jude_cellsize
		CMP	#$02
		BNE	@single

		LDA	zregBb1
		ASL
		STA	zregBb1

@single:
		LDA	zreg9b0
		LDX	zreg9b1
		
		JSR	__JudeLogClrIsReverse
		BCC	@text
		
		LDA	#KEY_ASC_SPACE
		JSR	_KarlASCIIToScreen
		ORA	#$80

		JMP	@cont

@text:
		LDA	#KEY_ASC_SPACE
		JSR	_KarlASCIIToScreen
		
@cont:
		STA	zreg9b2		;background char

		LDA	zreg9b0
		LDX	zreg9b1
		JSR	_JudeLogClrToSys

		STA	zreg9b0		;system colour

		LDA	zregBb2
		ASL
		ASL
		TAX

		LDA	jude_screeny0, X
		STA	zptrscreen		;screen ptr
		LDA	jude_screeny0 + 1, X
		STA	zptrscreen + 1
		LDA	jude_screeny0 + 2, X
		STA	zptrscreen + 2
		LDA	jude_screeny0 + 3, X
		STA	zptrscreen + 3

		LDA	jude_coloury0, X
		STA	zptrcolour		;colour ptr
		LDA	jude_coloury0 + 1, X
		STA	zptrcolour + 1
		LDA	jude_coloury0 + 2, X
		STA	zptrcolour + 2
		LDA	jude_coloury0 + 3, X
		STA	zptrcolour + 3

		LDZ	zregBb1
		LDX	zregBb3
		DEX


;***FIXME!!!
;	Replace this loopw with a dma job.

@loopw:
		LDA	zreg9b2				;char to screen ram
		NOP
		STA	(zptrscreen), Z
		
		LDA	jude_cellsize
		CMP	#$02
		BNE	@clrsingle

		INZ

		LDA	#00				;hi char to screen ram
		NOP
		STA	(zptrscreen), Z

@clrsingle:
		LDA	zreg9b0				;colour to colour ram
		NOP
		STA	(zptrcolour), Z

		INZ

@cellcont:
		DEX
		BPL	@loopw

		RTS



;-----------------------------------------------------------
_JudeEraseBkg:
;-----------------------------------------------------------
		STA	zreg9b0			;colour
		STX	zreg9b1

		LDZ	#ELEMENT::posx

		LDQIndDWZ	zptrself
		STQMem	zreg8

		LDA	jude_cellsize
		CMP	#$02
		BNE	@single

		LDA	zreg8
		ASL
		STA	zreg8

@single:
		LDA	zreg9b0
		LDX	zreg9b1
		
		JSR	__JudeLogClrIsReverse
		BCC	@text
		
		LDA	#KEY_ASC_SPACE
		JSR	_KarlASCIIToScreen
		ORA	#$80

		JMP	@cont

@text:
		LDA	#KEY_ASC_SPACE
		JSR	_KarlASCIIToScreen
		
@cont:
		STA	zreg9b2		;background char

		LDA	zreg9b0
		LDX	zreg9b1
		JSR	_JudeLogClrToSys

		STA	zreg9b0		;system colour

@looph:
		LDA	zreg8b1
		ASL
		ASL
		TAX

;	Undocumented LDQ $addr, X
;		PHX
;
;		NEG
;		NEG
;		LDA	jude_screeny0, X
;
;		NEG
;		NEG
;		STA	zptrscreen
;
;		PLX

		LDA	jude_screeny0, X
		STA	zptrscreen		;screen ptr
		LDA	jude_screeny0 + 1, X
		STA	zptrscreen + 1
		LDA	jude_screeny0 + 2, X
		STA	zptrscreen + 2
		LDA	jude_screeny0 + 3, X
		STA	zptrscreen + 3

;		NEG
;		NEG
;		LDA	jude_coloury0, X
;
;		NEG
;		NEG
;		STA	zptrcolour

		LDA	jude_coloury0, X
		STA	zptrcolour		;colour ptr
		LDA	jude_coloury0 + 1, X
		STA	zptrcolour + 1
		LDA	jude_coloury0 + 2, X
		STA	zptrcolour + 2
		LDA	jude_coloury0 + 3, X
		STA	zptrcolour + 3

		LDZ	zreg8b0
		LDX	zreg8b2
		DEX

;***FIXME!!!
;
;	This routine is now being called to clear the whole page!
;	Replace this loopw with a dma job.


@loopw:
		LDA	zreg9b2				;char to screen ram
		NOP
		STA	(zptrscreen), Z
		
		LDA	jude_cellsize
		CMP	#$02
		BNE	@clrsingle

		INZ

		LDA	#00				;hi char to screen ram
		NOP
		STA	(zptrscreen), Z

@clrsingle:
		LDA	zreg9b0				;colour to colour ram
		NOP
		STA	(zptrcolour), Z

		INZ

@cellcont:
		DEX
		BPL	@loopw
		
		INC	zreg8b1
		DEC	zreg8b3
		LDA	zreg8b3
		BNE	@looph
		
		RTS


;-----------------------------------------------------------
__JudeDrawText:
;	IN	zregAwl		Colour
;	IN	zregAb2		Indent
;	IN	zregAb3		Max width
;	IN	zregBb0		Do cont char if opt
;-----------------------------------------------------------
		LDZ	#ELEMENT::posx
		NOP
		LDA	(zptrself), Z
		STA	zregBb1		;x
		INZ
		NOP
		LDA	(zptrself), Z
		STA	zregBb2		;y
;		INY
		
		MvDWObjImm	zregD, zptrself, CONTROL::text_p
		LDA	zregDb0
		ORA	zregDb1
		ORA	zregDb2
		ORA	zregDb3
		
		BNE	@cont0
		
		RTS
		
@cont0:
		LDZ	#CONTROL::textoffx
		NOP
		LDA	(zptrself), Z		;
		STA	zregCb0		;text off x

;-----------------------------------------------------------
__JudeDrawTextDirect:
;	IN	zregAwl		Colour
;	IN	zregAb2		Indent
;	IN	zregAb3		Max width
;	IN	zregBb0		Do cont char if opt
;	IN	zregBb1		x pos
;	IN	zregBb2		y pos
;	IN	zregCb0		text off x
;	IN	zregD		text pointer
;-----------------------------------------------------------

		CLC
		LDA	zregCb0
		ADC	zregBb1

		LDX	jude_cellsize
		CPX	#$02
		BNE	@xcont

		ASL

@xcont:
		STA	zregBb1		;x

		LDA	zregAb0
		LDX	zregAb1
		JSR	__JudeLogClrIsReverse
		BCC	@text
		
		LDA	#$80
		JMP	@cont1
		
@text:
		LDA	#$00
		
@cont1:
		STA	zregCb2		;char or for norm/rev

		LDA	zregBb2
		ASL
		ASL
		TAX

		LDA	jude_screeny0, X
		STA	zptrscreen		;screen ptr
		LDA	jude_screeny0 + 1, X
		STA	zptrscreen + 1
		LDA	jude_screeny0 + 2, X
		STA	zptrscreen + 2
		LDA	jude_screeny0 + 3, X
		STA	zptrscreen + 3

		LDA	zregBb0
		BEQ	@cont2
	
		LDZ	#OBJECT::options
		NOP
		LDA	(zptrself), Z
		AND	#OPT_TEXTCONTMRK
		BEQ	@cont2

		DEC	zregAb3

@cont2:
		LDA	zregAb2		;text indent
		STA	zregCb1

		LDX	#$00
	
@loopw:
		LDZ	zregCb1
		NOP
		LDA	(zregD), Z		;char 
		
		BEQ	@exit
		
		JSR	_KarlASCIIToScreen
		ORA	zregCb2
		
		LDZ	zregBb1
		NOP
		STA	(zptrscreen), Z
		
		INC	zregBb1

		LDA	jude_cellsize
		CMP	#$02
		BNE	@cellcont

		INC	zregBb1

@cellcont:
		INC	zregCb1

		INX
		CPX	zregAb3
		BCS	@contchk

		JMP	@loopw

@contchk:
		LDA	zregBb0
		BEQ	@exit

		LDZ	#OBJECT::options
		NOP
		LDA	(zptrself), Z
		AND	#OPT_TEXTCONTMRK
		BEQ	@exit

		LDA	#$68
;		JSR	KarlASCIIToScreen
		ORA	zregCb2
		
		LDZ	zregBb1
		NOP
		STA	(zptrscreen), Z

@exit:
		RTS


;-----------------------------------------------------------
_JudeDrawAccel:
;-----------------------------------------------------------
		LDZ	#CONTROL::textaccel
		NOP
		LDA	(zptrself), Z
		CMP	#$FF
		BEQ	@exit

		STA	zregBb3

		LDZ	#OBJECT::state
		NOP
		LDA	(zptrself), Z
		AND	#STATE_ENABLED
		BEQ	@exit

		LDZ	#ELEMENT::posx
		NOP
		LDA	(zptrself), Z
		
		CLC
		ADC	zregBb3

		LDX	jude_cellsize
		CPX	#$02
		BNE	@storex

		ASL
		TAX
		INX
		TXA

@storex:
		STA	zregBb1		;x + textaccel
		
		INZ
		NOP
		LDA	(zptrself), Z
		STA	zregBb2		;y
		
		LDA	#<CLR_FOCUS
		LDX	#>CLR_FOCUS
		JSR	_JudeLogClrToSys
		STA	zregCb1		;system colour

		LDA	zregBb2
		ASL
		ASL
		TAX

		LDA	jude_coloury0, X
		STA	zptrcolour		;screen ptr
		LDA	jude_coloury0 + 1, X
		STA	zptrcolour + 1
		LDA	jude_coloury0 + 2, X
		STA	zptrcolour + 2
		LDA	jude_coloury0 + 3, X
		STA	zptrcolour + 3

		LDZ	#OBJECT::options
		NOP
		LDA	(zptrself), Z
		AND	#OPT_TEXTACCEL2X
		STA	zregCb0

		LDZ	zregBb1
		LDA	zregCb1
		NOP
		STA	(zptrcolour), Z
		
		LDX	zregCb0
		BEQ	@exit
		
		LDX	jude_cellsize
		CPX	#$02
		BNE	@dblx

		INZ

@dblx:
		INZ
		NOP
		STA	(zptrcolour), Z

@exit:
		RTS


;-----------------------------------------------------------
_JudeLogClrToSys:
;-----------------------------------------------------------
		PHA
		TXA

		AND	#$30
		BEQ	@ctrl

		PLA
		RTS

@ctrl:
		PLY
		INY
		INY
		INY
		LDA	jude_theme, Y
		RTS


;-----------------------------------------------------------
__JudeLogClrIsReverse:
;-----------------------------------------------------------
		PHA
		TXA

		AND	#$20
		BEQ	@int

		PLA
@ctrl:
		SEC
		RTS

@int:
		PLA
		CMP	#CLR_EMPTY
		BEQ	@ctrl

		CMP	#CLR_FOCUS
		BPL	@ctrl

@text:
		CLC
		RTS


;-----------------------------------------------------------
_JudeEnqueueKey:
;-----------------------------------------------------------
		SEI

		LDY	keysIdx
		CPY	#$10
		BCC	@enqueue

@finish:
		LDA	karl_lock
		BNE	@exit

	.if DEBUG_NOYIELDIRQ
	.else
		CLI
	.endif
@exit:
		RTS

@enqueue:
		STA	keysBuffer0, Y
		INY
		TXA
		STA	keysBuffer0, Y

		INC	keysIdx
		INC	keysIdx

		JMP	@finish


;-----------------------------------------------------------
_JudeDequeueKey:
;-----------------------------------------------------------
		SEI

		LDA	#$00
		STA	zvalkey
		STA	zvalkey + 1

		LDA	keysIdx
		BNE	@dequeue

@finish:
		LDA	karl_lock
		BNE	@exit

	.if DEBUG_NOYIELDIRQ
	.else
		CLI
	.endif
@exit:
		RTS

@dequeue:
		LDA	keysBuffer0
		STA	zvalkey
		LDA	keysBuffer0 + 1
		STA	zvalkey + 1

		LDX	#$00
@loop:
		LDA	keysBuffer0 + 2, X
		STA	keysBuffer0, X

		INX
		CPX	#$0E
		BNE	@loop

		DEC	keysIdx
		DEC	keysIdx

		JMP	@finish


;-----------------------------------------------------------
_JudeDefUIPrepare:
;-----------------------------------------------------------
		LDA	#UINTERFACE::viewscnt
		STA	zreg5b0

		LDA	#UINTERFACE::views_p
		STA	zreg5b2

		LDA	#OBJECT::prepare
		STA	zreg5b1

		LDA	#$00
		STA	zreg5b3

		MvDWMem	zreg4, zptrself

		JSR	__KarlCallObjLstMethod

		LDA	_karl_errorno
		BNE	@exit

;		LDA	#$01
;		STA	zreg2b3
		LDA	#STATE_PREPARED
		JSR	_KarlObjIncludeState

@exit:
		RTS


;-----------------------------------------------------------
_JudeDefUIInit:
;-----------------------------------------------------------
		MvDWObjImm	jude_mouseram, zptrself, UINTERFACE::mouseloc
		MvDWObjImm	zreg4, zptrself, UINTERFACE::mouseloc
		MvDWObjImm	jude_mouseptr, zptrself, UINTERFACE::mptrloc

		LDZ	#UINTERFACE::mousepal
		NOP
		LDA	(zptrself), Z
		STA	jude_mousepal

		LDA	zreg4
		ORA	zreg4 + 1
		ORA	zreg4 + 2
		ORA	zreg4 + 3

		BEQ	@cont6

		LDZ	#$00
		LDY	#$00
@loop1:
		LDA	pointer0, Y
		NOP
		STA	(zreg4), Z

		INY
		INZ

		CPY	#$A8
		BNE	@loop1

		LDA	#$C0
		STA	zregAb0
		LDA	#$00
		STA	zregAb1
		STA	zregAb2
		STA	zregAb3

		LDQMem	zreg4
		CLC
		ADQMem	zregA
		STQMem	zreg4

		LDZ	#$00
		LDY	#$00
@loop2:
		LDA	pointer1, Y
		NOP
		STA	(zreg4), Z

		INY
		INZ

		CPY	#$A8
		BNE	@loop2


@cont6:
		LDA	#$00
		STA	_karl_errorno

		RTS


;-----------------------------------------------------------
_JudeDefUIChange:
;-----------------------------------------------------------
		LDA	#$00
		STA	_karl_errorno

		RTS


;-----------------------------------------------------------
_JudeDefUIRelease:
;-----------------------------------------------------------
		LDA	#$00
		STA	_karl_errorno

		RTS


;-----------------------------------------------------------
__JudeViewPrepProcLayers:
;-----------------------------------------------------------
		LDA	zreg1wh
		BEQ	@done

		INW	zreg1wl
		INW	zreg1wl

;***FIXME  This is not using 16bit math

		LDZ	#LAYER::width
		NOP
		LDA	(zreg0), Z

		PHA

		LDA	zreg1wh + 1
		CMP	#$02
		BNE	@cont0

		PLA
		ASL
		JMP	@cont1

@cont0:
		PLA

@cont1:
		CLC
		ADC	zreg1wl
		STA	zreg1wl
		LDA	#$00
		ADC	zreg1wl + 1
		STA	zreg1wl + 1

@done:
		INC	zreg1wh

		RTS

;-----------------------------------------------------------
_JudeDefViewPrepare:
;-----------------------------------------------------------
	.if	DEBUG_RASTERTIME
		LDA	#$03
		STA	VIC_BRDRCLR
	.endif 

		LDA	#VIEW::layerscnt
		STA	zreg5b0

		LDA	#VIEW::layers_p
		STA	zreg5b2

		LDA	#OBJECT::prepare
		STA	zreg5b1

		LDA	#$00
		STA	zreg5b3

		MvDWMem	zreg4, zptrself

		JSR	__KarlCallObjLstMethod

		LDA	_karl_errorno
		BEQ	@prep

		RTS

@prep:
		LDZ	#VIEW::width
		NOP
		LDA	(zptrself), Z

		STA	zreg1wl

		LDA	#$00
		STA	zreg1wl + 1
		STA	zreg1wh

		LDZ	#VIEW::cellsize
		NOP
		LDA	(zptrself), Z

		STA	zreg1wh + 1

		CMP	#$02
		BNE	@cont0

		ASLWMem	zreg1wl

@cont0:
		LDA	#VIEW::layerscnt
		STA	zreg5b0

		LDA	#VIEW::layers_p
		STA	zreg5b2

		LDA	#$00
		STA	zreg5b3

		LDA	#<__JudeViewPrepProcLayers
		STA	zreg6wl
		LDA	#>__JudeViewPrepProcLayers
		STA	zreg6wl + 1

		MvDWMem	zreg4, zptrself

		JSR	__KarlProcObjLst

		LDZ	#VIEW::layerscnt
		NOP
		LDA	(zptrself), Z

		BEQ	@done

		CMP	#$01
		BEQ	@done

		INW	zreg1wl
		INW	zreg1wl

@done:
		LDZ	#VIEW::linelen
		LDA	zreg1wl
		NOP
		STA	(zptrself), Z
		INZ
		LDA	zreg1wl + 1
		NOP
		STA	(zptrself), Z

		LDA	#$00
		STA	_karl_errorno

;		LDA	#$01
;		STA	zreg2b3
		LDA	#STATE_PREPARED
		JSR	_KarlObjIncludeState

	.if	DEBUG_RASTERTIME
		LDA	#$04
		STA	VIC_BRDRCLR
	.endif

@exit:
		RTS


;-----------------------------------------------------------
_JudeDefViewInit:
;-----------------------------------------------------------
		MvDWObjImm	jude_screenram, zptrself, VIEW::location

		LDZ	#VIEW::width
		NOP
		LDA	(zptrself), Z

		CMP	#$29
		BCS	@dblw

		LDA	#$28
		STA	jude_screenw
		JMP	@cont0

@dblw:
		LDA	#$50
		STA	jude_screenw

@cont0:
		LDZ	#VIEW::height
		NOP
		LDA	(zptrself), Z

		CMP	#$1A
		BCS	@dblh

		LDA	#$19
		STA	jude_screenh
		JMP	@cont1

@dblh:
		LDA	#$32
		STA	jude_screenh

@cont1:
		LDZ	#VIEW::cellsize
		NOP
		LDA	(zptrself), Z

		BEQ	@cell1

		CMP	#$01
		BEQ	@cell1

		LDA	#$02
		STA	jude_cellsize
		JMP	@cont2

@cell1:
		LDA	#$01
		STA	jude_cellsize

@cont2:
		LDZ	#VIEW::linelen
		NOP
		LDA	(zptrself), Z
		STA	jude_linesize
		INZ
		NOP
		LDA	(zptrself), Z
		STA	jude_linesize + 1

		MvDWMem	zreg0, jude_screenram
		MvDWImm	zreg2, VIC_CLRRAMH
;		LDA	#$00
;		STA	jude_screensize
;		STA	jude_screensize + 1
		MvDWZ jude_screensize

		LDA	#<jude_screeny0
		STA	zreg1wl
		LDA	#>jude_screeny0
		STA	zreg1wl + 1

		LDA	#<jude_coloury0
		STA	zreg1wh
		LDA	#>jude_coloury0
		STA	zreg1wh + 1

		LDZ	#$00
		LDX	#$00
@loop0:
		PHX
;		PHZ

		LDQMem	zreg0
		STQIndW	zreg1wl

		LDQMem	zreg2
		STQIndW	zreg1wh

		INW	zreg1wl
		INW	zreg1wl
		INW	zreg1wl
		INW	zreg1wl

		INW	zreg1wh
		INW	zreg1wh
		INW	zreg1wh
		INW	zreg1wh

		LDQMem	zreg0
		CLC
		ADQMem	jude_linesize
		STQMem	zreg0

		LDQMem	zreg2
		CLC
		ADQMem	jude_linesize
		STQMem	zreg2

		PLX

		CPX	jude_screenh
		BCS	@next0

		PHX

		LDQMem	jude_screensize
		CLC
		ADQMem	jude_linesize
		STQMem	jude_screensize

		PLX

@next0:
		INX
		CPX	#$32
		BNE	@loop0

;	Prevent VIC-II compatibility changes
		LDA	#$80
		TRB	$D05D

;	Uppercase
		LDA	$D018
		AND	#$FD
		STA	$D018

;	Set input to "raw" mode - $02 is required to 
;	fix bug.
;***FIXME
		LDA	#$82
		TSB	$D611

;	Theme
		LDA	#<CLR_EMPTY
		LDX	#>CLR_EMPTY
		JSR	_JudeLogClrToSys
		STA	$D020
		STA	jude_brdbak

		LDA	#<CLR_BACK
		LDX	#>CLR_BACK
		JSR	_JudeLogClrToSys
		STA	$D021

;	Set the location of screen RAM
		LDA	jude_screenram
		STA	$D060
		LDA	jude_screenram + 1
		STA	$D061
		LDA	jude_screenram + 2
		STA	$D062

;	Set VIC to use 80/40 columns
		LDA	jude_screenw
		CMP	#$28
		BNE	@col80

		LDA	#$80
		TRB	$D031

		JMP	@cont3

@col80:
		LDA	#$80
		TSB	$D031

;***FIXME
;	Also, 80 columns is FCM/16 bit chars
		LDA	#$05
		TSB	$D054


@cont3:
;	Set VIC to use 25/50 rows
		LDA	jude_screenh
		CMP	#$19
		BNE	@row50

		LDA	#$08
		TRB	$D031
		JMP	@cont4

@row50:
		LDA	#$08
		TSB	$D031

@cont4:
;	Set VIC line size
		LDA jude_linesize
		STA $D058
		LDA jude_linesize + 1
		STA $D059

;	Set VIC window w
		LDA	jude_screenw
		STA	$D05E

;	CHRYSCL
		LDA	#$01
		STA	$D05B

;	Set VIC window h
		LDA	jude_screenh
		STA	$D07B

;	Set VIC alpha compositing
		LDA	#$80
		TSB	$D054

;	Use PALETTE RAM entries for colours 0 - 15
		LDA	#$04
		TSB	$D030

		LDA	jude_cellsize
		CMP	#$02
		BEQ	@cell16

		LDA	#$01
		TRB	$D054
		JMP	@cont5

@cell16:
		LDA	#$01
		TSB	$D054

@cont5:
		LDA	jude_screensize
		STA	zreg4wl
		LDA	jude_screensize + 1
		STA	zreg4wl + 1

		DEW	zreg4wl
		DEW	zreg4wl

;	Size
		LDA	zreg4wl
		STA	dma_vw_siz
		LDA	zreg4wl + 1
		STA	dma_vw_siz + 1

;	Destination addr
		LDA	#<.loword(VIC_CLRRAMH + 2)
		STA	dma_vw_dadr
		LDA	#>.loword(VIC_CLRRAMH + 2)
		STA	dma_vw_dadr + 1

		LDA	#<.hiword(VIC_CLRRAMH + 2)
		AND	#$0F
		STA	dma_vw_dbnk

		LDA	#<.hiword(VIC_CLRRAMH + 2)
		LSR
		LSR
		LSR
		LSR
		STA	zreg0b0

		LDA	#>.hiword(VIC_CLRRAMH + 2)
		ASL
		ASL
		ASL
		ASL

		ORA	zreg0b0
		STA	dma_vw_dmb + 1

;	Source addr
		LDA	#<.loword(VIC_CLRRAMH)
		STA	dma_vw_sadr
		LDA	#>.loword(VIC_CLRRAMH)
		STA	dma_vw_sadr + 1

		LDA	#<.hiword(VIC_CLRRAMH)
		AND	#$0F
		STA	dma_vw_sbnk

		LDA	#<.hiword(VIC_CLRRAMH)
		LSR
		LSR
		LSR
		LSR
		STA	zreg0b0

		LDA	#>.hiword(VIC_CLRRAMH)
		ASL
		ASL
		ASL
		ASL

		ORA	zreg0b0
		STA	dma_vw_smb + 1

;	Source data
		MvDWImm	zreg4, VIC_CLRRAMH

		LDA	#<CLR_EMPTY
		LDX	#>CLR_EMPTY
		JSR	_JudeLogClrToSys

		TAX

		LDZ	#$00
		NOP
		STA	(zreg4), Z

		LDA	jude_cellsize
		CMP	#$02
		BNE	@clrsingle

		LDA	#$00
		NOP
		STA	(zreg4), Z

		TXA
		BRA	@clrplot2

@clrsingle:
		TXA

@clrplot2:
		INZ
		NOP
		STA	(zreg4), Z

		LDA	#$00
		STA	$D702
		LDA	#>dma_view_clear
		STA	$D701
		LDA	#<dma_view_clear
		STA	$D705

;	Screen
;			dma_view_clear:
;				.byte	$0B					; Request format is F018B
;			dma_vw_smb:
;				.byte	$80,$00				; Source MB 
;			dma_vw_dmb:
;				.byte	$81,$00				; Destination MB 
;				.byte	$00					; No more options
;				.byte	$03					;Command LSB
;			dma_vw_siz:
;				.word	$0000				;Count LSB Count MSB
;			dma_vw_sadr:
;				.word	$0000				;Source Address LSB Source Address MSB
;			dma_vw_sbnk:
;				.byte	$00					;Source Address BANK and FLAGS
;			dma_vw_dadr:
;				.word	$0000				;Destination Address LSB Destination Address MSB
;			dma_vw_dbnk:
;				.byte	$00					;Destination Address BANK and FLAGS
;				.byte	$00					;Command MSB
;				.word	$0000				;Modulo LSB / Mode Modulo MSB / Mode
;	Destination addr
		MvDWMem	zreg4, jude_screenram

		INW	zreg4wl
		BNE	@nohi0

		INW	zreg4wh

@nohi0:
		INW	zreg4wl
		BNE	@nohi1

		INW	zreg4wh

@nohi1:
		LDA	zreg4
		STA	dma_vw_dadr
		LDA	zreg4 + 1
		STA	dma_vw_dadr + 1

		LDA	zreg4 + 2
		AND	#$0F
		STA	dma_vw_dbnk

		LDA	zreg4 + 2
		LSR
		LSR
		LSR
		LSR
		STA	zreg0b0

		LDA	zreg4 + 3
		ASL
		ASL
		ASL
		ASL

		ORA	zreg0b0
		STA	dma_vw_dmb + 1

;	Source addr
		MvDWMem	zreg4, jude_screenram

		LDA	zreg4
		STA	dma_vw_sadr
		LDA	zreg4 + 1
		STA	dma_vw_sadr + 1

		LDA	zreg4 + 2
		AND	#$0F
		STA	dma_vw_sbnk

		LDA	zreg4 + 2
		LSR
		LSR
		LSR
		LSR
		STA	zreg0b0

		LDA	zreg4 + 3
		ASL
		ASL
		ASL
		ASL

		ORA	zreg0b0
		STA	dma_vw_smb + 1

;	Source data


		LDA	#KEY_ASC_SPACE
		JSR	_KarlASCIIToScreen

		PHA

		LDA	#<CLR_EMPTY
		LDX	#>CLR_EMPTY
		JSR	__JudeLogClrIsReverse

		BCC	@text

		PLA
		ORA	#$80
		JMP	@clrscr

@text:
		PLA

@clrscr:
		STA	zreg0b0

		LDZ	#$00
		NOP
		STA	(zreg4), Z

		LDA	jude_cellsize
		CMP	#$02
		BNE	@scrsingle

		LDA	#$00
		BRA	@scrplot

@scrsingle:
		LDA	zreg0b0

@scrplot:
		INZ
		NOP
		STA	(zreg4), Z

		LDA	#$00
		STA	$D702
		LDA	#>dma_view_clear
		STA	$D701
		LDA	#<dma_view_clear
		STA	$D705

@mouse:
		LDA	#MPTR_NONE
		STA	jude_mptrstate

;	Sprite disable
		LDA	#$00
		STA	$D015

		MvDWMem	zreg4, jude_mouseram

		LDA	zreg4
		ORA	zreg4 + 1
		ORA	zreg4 + 2
		ORA	zreg4 + 3

		BEQ	@cont6

		LDX	#$05
@loop1:
		LSQMem	zreg4
		DEX
		BPL	@loop1

		JSR	__JudeThemeSetMouse

		LDA	#MPTR_NORMAL
		STA	jude_mptrstate

;	Sprite pointer location & 16bit
		LDA	jude_mouseptr
		STA	$D06C
		STA	zreg3
		LDA	jude_mouseptr + 1
		STA	$D06D
		STA	zreg3 + 1
		LDA	jude_mouseptr + 2
		STA	zreg3 + 2
		ORA	#$80
		STA	$D06E
		LDA	#$00
		STA	zreg3 + 3

;	Sprite pointer
		LDZ	#$00
		LDA	zreg4
		NOP
		STA	(zreg3), Z
		STA	jude_mousevic

		INZ
		LDA	zreg4 + 1
		NOP
		STA	(zreg3), Z
		STA	jude_mousevic + 1

;	Sprite transparency colour
		LDA	#$00
		STA	$D027

;	Sprite 16 colour
		LDA #$01
		TSB $D06B

;	Sprite 8 bytes wide
		TSB	$D057

;***FIXME What was this, is it fixed?
;	Workaround BUG #339
		LDA	#$08
		TRB	$D07A
;---

;	Sprite enable
		LDA	#$01
		STA	$D015

;	Sprite position
		JSR	__MouseMoveSprX
		JSR	__MouseMoveSprY

@cont6:
		LDA	#VIEW::layerscnt
		STA	zreg5b0

		LDA	#VIEW::layers_p
		STA	zreg5b2

		LDA	#OBJECT::initialise
		STA	zreg5b1

		LDA	#$00
		STA	zreg5b3

		MvDWMem	zreg4, zptrself

		JSR	__KarlCallObjLstMethod

		LDA	_karl_errorno
		BNE	@exit

		LDA	#VIEW::barscnt
		STA	zreg5b0

		LDA	#VIEW::bars_p
		STA	zreg5b2

		LDA	#OBJECT::initialise
		STA	zreg5b1

		LDA	#$00
		STA	zreg5b3

		MvDWMem	zreg4, zptrself

		JSR	__KarlCallObjLstMethod

		LDA	_karl_errorno
		BNE	@exit

		LDA	#VIEW::pagescnt
		STA	zreg5b0

		LDA	#VIEW::pages_p
		STA	zreg5b2

		LDA	#OBJECT::initialise
		STA	zreg5b1

		LDA	#$00
		STA	zreg5b3

		MvDWMem	zreg4, zptrself

		JSR	__KarlCallObjLstMethod

;		LDA	#$00
;		STA	_karl_errorno

@exit:
		RTS


;-----------------------------------------------------------
_JudeDefViewChange:
;-----------------------------------------------------------
		LDA	#$00
		STA	_karl_errorno

		RTS


;-----------------------------------------------------------
_JudeDefViewRelease:
;-----------------------------------------------------------
		LDA	#$00
		STA	_karl_errorno

		RTS


;-----------------------------------------------------------
_JudeDefLyrPrepare:
;-----------------------------------------------------------
		LDA	#$00
		STA	_karl_errorno

;		LDA	#$01
;		STA	zreg2b3
		LDA	#STATE_PREPARED
		JSR	_KarlObjIncludeState

		RTS


;-----------------------------------------------------------
_JudeDefLyrInit:
;-----------------------------------------------------------
		LDA	#$00
		STA	_karl_errorno

		RTS


;-----------------------------------------------------------
_JudeDefLyrChange:
;-----------------------------------------------------------
		LDA	#$00
		STA	_karl_errorno

		RTS


;-----------------------------------------------------------
_JudeDefLyrRelease:
;-----------------------------------------------------------
		LDA	#$00
		STA	_karl_errorno

		RTS


;-----------------------------------------------------------
_JudeDefPgePrepare:
;-----------------------------------------------------------
		LDA	#PAGE::panelscnt
		STA	zreg5b0

		LDA	#PAGE::panels_p
		STA	zreg5b2

		LDA	#OBJECT::prepare
		STA	zreg5b1

		LDA	#$00
		STA	zreg5b3

		MvDWMem	zreg4, zptrself

		JSR	__KarlCallObjLstMethod

;		LDA	#$01
;		STA	zreg2b3
		LDA	#STATE_PREPARED
		JSR	_KarlObjIncludeState

		LDA	#$00
		STA	_karl_errorno

		RTS


;-----------------------------------------------------------
_JudeDefPgeInit:
;-----------------------------------------------------------
		LDA	#PAGE::panelscnt
		STA	zreg5b0

		LDA	#PAGE::panels_p
		STA	zreg5b2

		LDA	#OBJECT::initialise
		STA	zreg5b1

		LDA	#$00
		STA	zreg5b3

		MvDWMem	zreg4, zptrself

		JSR	__KarlCallObjLstMethod

;		LDA	#$00
;		STA	_karl_errorno

		RTS


;-----------------------------------------------------------
_JudeDefPgeChange:
;-----------------------------------------------------------
		LDA	#$00
		STA	_karl_errorno

		RTS


;-----------------------------------------------------------
_JudeDefPgeRelease:
;-----------------------------------------------------------
		LDA	#$00
		STA	_karl_errorno

		RTS


;-----------------------------------------------------------
_JudeDefPgePresent:
;-----------------------------------------------------------
		LDZ	#OBJECT::state
		NOP
		LDA	(zptrself), Z
		AND	#STATE_ACTIVE
		BNE	@present

		RTS

@present:
		LDZ	#ELEMENT::colour + 1
		NOP
		LDA	(zptrself), Z
		TAX
		DEZ
		NOP
		LDA	(zptrself), Z

		JSR	_JudeEraseBkg

		LDA	#VIEW::barscnt
		STA	zreg5b0

		LDA	#VIEW::bars_p
		STA	zreg5b2

		LDA	#ELEMENT::present
		STA	zreg5b1

		LDA	#$00
		STA	zreg5b3

		MvDWMem	zreg4, jude_actvvw

		JSR	__KarlCallObjLstMethod


		LDA	#PAGE::panelscnt
		STA	zreg5b0

		LDA	#PAGE::panels_p
		STA	zreg5b2

		LDA	#ELEMENT::present
		STA	zreg5b1

		LDA	#$00
		STA	zreg5b3

		MvDWMem	zreg4, zptrself

		JSR	__KarlCallObjLstMethod

		LDA	#STATE_DIRTY
		JSR	_KarlObjExcludeState

		LDA	#$00
		STA	_karl_errorno

		RTS


;-----------------------------------------------------------
_JudeDefPnlPrepare:
;-----------------------------------------------------------
;		LDA	#$01
;		STA	zreg2b3
		LDA	#STATE_PREPARED
		JSR	_KarlObjIncludeState

		LDA	#$00
		STA	_karl_errorno

		RTS


;-----------------------------------------------------------
_JudeDefPnlInit:
;-----------------------------------------------------------
		LDA	#$00
		STA	_karl_errorno

		RTS


;-----------------------------------------------------------
_JudeDefPnlChange:
;-----------------------------------------------------------
		LDA	#STATE_CHANGED
		JSR	_KarlObjExcludeState

;		LDA	#$01
;		STA	zreg2b3
		LDA	#STATE_DIRTY
		JSR	_KarlObjIncludeState

		LDA	#$00
		STA	_karl_errorno

		RTS


;-----------------------------------------------------------
_JudeDefPnlRelease:
;-----------------------------------------------------------
		LDA	#$00
		STA	_karl_errorno

		RTS


;-----------------------------------------------------------
_JudeDefPnlPresent:
;-----------------------------------------------------------
;		LDZ	#OBJECT::state
;		NOP
;		LDA	(zptrself), Z
;		AND	#STATE_PICKED
;		BEQ	@nopick
;
;		LDA	#<CLR_FOCUS
;		LDX	#>CLR_FOCUS
;
;		JMP	@present
;
;@nopick:
		LDZ	#ELEMENT::colour + 1
		NOP
		LDA	(zptrself), Z
		TAX
		DEZ
		NOP
		LDA	(zptrself), Z

@present:
		JSR	_JudeEraseBkg

		LDA	#PANEL::controlscnt
		STA	zreg5b0

		LDA	#PANEL::controls_p
		STA	zreg5b2

		LDA	#ELEMENT::present
		STA	zreg5b1

		LDA	#$00
		STA	zreg5b3

		MvDWMem	zreg4, zptrself

		JSR	__KarlCallObjLstMethod

		LDA	#STATE_DIRTY
		JSR	_KarlObjExcludeState

		LDA	#$00
		STA	_karl_errorno

		RTS




;-----------------------------------------------------------
__JudeMvActvNextPanel:
;-----------------------------------------------------------
		LDZ	#$00
		LDQIndDWZ	zregF
		STQMem	zptrowner

		LDA	#$00
		STA	zregDb1

		MvDWObjImm	zregC, zptrowner, PANEL::controls_p
		MvDWMem	zregE, zregC

		LDZ	#PANEL::controlscnt
		NOP
		LDA	(zptrowner), Z
		STA	zregDb0

		BEQ	@exit

		LDA	zvalkey + 1
		AND	#KEY_MOD_SHIFT
		BEQ	@exit

		LDX	zregDb0
		DEX
		STX	zreg5b0
		LDA	#$00
		STA	zreg5b1
		STA	zreg5b2
		STA	zreg5b3

		ASLWMem	zreg5wl
		ASLWMem	zreg5wl

		LDQMem	zregC
		CLC
		ADQMem	zreg5
		STQMem	zregE

		LDX	zregDb0
		DEX
		STX	zregDb1

@exit:
		RTS


;-----------------------------------------------------------
__JudeMoveActiveControl:
;-----------------------------------------------------------
		LDA	jude_actvpg
		ORA	jude_actvpg + 1
		ORA	jude_actvpg + 2
		ORA	jude_actvpg + 3
		BNE	@begin

		RTS

@begin:
;***FIXME	Check if control is actually on a bar and if so,
; restart (set active control to zero?)

;	Get page's panels list
		MvDWMem	zreg4, jude_actvpg
		MvDWObjImm	zregA, zreg4, PAGE::panels_p

		LDZ	#PAGE::panelscnt
		NOP
		LDA	(zreg4), Z
		STA	zregBb0

;					zregA	:	pointer to page's panels
;					zregBb0	:	page panel count

		LDA	judeActvElem
		ORA	judeActvElem + 1
		ORA	judeActvElem + 2
		ORA	judeActvElem + 3
		LBEQ	@restart

;	Get active element's panel
		MvDWMem	zreg4, judeActvElem
		MvDWObjImm zptrowner, zreg4, ELEMENT::owner

;					zreg4	:	active elem
;					zptrowner:	active panel

		LDA	zptrowner
		ORA	zptrowner + 1
		ORA	zptrowner + 2
		ORA	zptrowner + 3
		LBEQ	@restart

;	Get active panel's controls
		MvDWObjImm zregC, zptrowner, PANEL::controls_p
		
		LDZ	#PANEL::controlscnt
		NOP
		LDA	(zptrowner), Z
		STA	zregDb0

;					zregC	:	pointer to panel's controls
;					zregDb0	:	panel control count

;	Find active control index
		LDA	#$00
		STA	zregDb1

		MvDWMem	zregE, zregC

@loopfac:
		LDZ	#$00
		LDQIndDWZ	zregE
		CPQMem	zreg4
		BEQ	@foundfac

		LDQMem	zregE
		CLC
		ADQMem	zvaltemp0
		STQMem	zregE

		INC	zregDb1
		LDA	zregDb1
		CMP	zregDb0
		BCC	@loopfac

		BRA	@restart

@foundfac:

;					zregE	:	pointer to control in list
;					zregDb1	:	control list index

;	Find active panel index
		LDA	#$00
		STA	zregDb2

		MvDWMem	zregF, zregA

@loopfap:
		LDZ	#$00
		LDQIndDWZ	zregF
		CPQMem	zptrowner
		BEQ	@foundfap

		LDQMem	zregF
		CLC
		ADQMem	zvaltemp0
		STQMem	zregF

		INC	zregDb2
		LDA	zregDb2
		CMP	zregBb0
		BCC	@loopfap

		BRA	@restart

@foundfap:

;					zregF	:	pointer to panel in list
;					zregDb2	:	panel list index
		LDA	zregDb2
		STA	zregBb1

		LDA	zregDb1
		STA	zregBb2

		JMP	@nextelem

@restart:
;		SEI
; @halt:
;		INC	$D020
;		JMP	@halt
		
		LDA	#$00
		STA	zregBb1
		STA	zregBb2

;					zregBb1:	start panel index
;					zregBb2:	start control index

;					zregA	:	pointer to page's panels
;					zregBb0	:	page panel count
		MvDWMem	zregF, zregA
		LDA	#$00
		STA	zregDb2

		LDA	zvalkey + 1
		AND	#KEY_MOD_SHIFT
		BEQ	@rescont0

		LDX	zregBb0
		DEX
		STX	zreg5b0
		LDA	#$00
		STA	zreg5b1
		STA	zreg5b2
		STA	zreg5b3

		ASLWMem	zreg5wl
		ASLWMem	zreg5wl

		LDQMem	zregF
		CLC
		ADQMem	zreg5
		STQMem	zregF

		LDX	zregBb0
		DEX
		STX	zregDb2

;					zregF	:	pointer to panel in list
;					zregDb2	:	panel list index

@rescont0:
		JSR	__JudeMvActvNextPanel

;					zptrowner:	active panel
;					zregC	:	pointer to panel's controls
;					zregDb0	:	panel control count
;					zregE	:	pointer to control in list
;					zregDb1	:	control list index
		LDA	zregDb0
		BNE	@rescont1

		JMP	@nextpanel

@rescont1:
		LDZ	#$00
		LDQIndDWZ	zregE
		STQMem	zreg4

;					zreg4	:	active elem

@start:
		LDA	zregDb2
		STA	zregBb1

		LDA	zregDb1
		STA	zregBb2

;					zregBb1:	start panel index
;					zregBb2:	start control index

@testelem:
;	Must be state PREPARED | VISIBLE | ENABLED
		LDZ	#OBJECT::state
		NOP
		LDA	(zreg4), Z
		AND	#(STATE_VISIBLE | STATE_ENABLED)
		CMP	#(STATE_VISIBLE | STATE_ENABLED)
		BNE	@nextelem

;	And otherwise navagable
		LDZ	#OBJECT::options
		NOP
		LDA	(zreg4), Z

		AND	#OPT_NONAVIGATE
		BNE	@nextelem

@activelem:
		MvDWMem	zptrself, zreg4
		JSR	_JudeActivateCtrl

		RTS

@nextelem:
		LDA	zvalkey + 1
		AND	#KEY_MOD_SHIFT
		BNE	@nxtelemup

		INC	zregDb1
		LDA	zregDb1
		CMP	zregDb0
		BEQ	@nextpanel

		LDQMem	zregE
		CLC
		ADQMem	zvaltemp0
		STQMem	zregE

		BRA	@nxtelemfetch

@nxtelemup:
		DEC	zregDb1
		LDA	zregDb1
		CMP	#$FF
		BEQ	@nextpanel

		LDQMem	zregE
		SEC
		SBQMem	zvaltemp0
		STQMem	zregE


@nxtelemfetch:
		LDZ	#$00
		LDQIndDWZ	zregE
		STQMem	zreg4

;					zregBb1:	start panel index
;					zregBb2:	start control index
;					zregDb2	:	panel list index
;					zregDb1	:	control list index
		LDA	zregBb1
		CMP	zregDb2
		BNE	@testelem

		LDA	zregBb2
		CMP	zregDb1
		BNE	@testelem

		RTS					;ABORT

@nextpanel:
		LDA	zvalkey + 1
		AND	#KEY_MOD_SHIFT
		BNE	@nxtpnlup

		INC	zregDb2
		LDA	zregDb2
		CMP	zregBb0
		BEQ	@nxtpnldnwrap

		LDQMem	zregF
		CLC
		ADQMem	zvaltemp0
		STQMem	zregF

		BRA	@nxtpnlfetch

@nxtpnldnwrap:
		MvDWMem	zregF, zregA

		LDA	#$00
		STA	zregDb2

		BRA	@nxtpnlfetch

@nxtpnlup:
		DEC	zregDb2
		LDA	zregDb2
		CMP	#$FF
		BEQ	@nxtpnlupwrap

		LDQMem	zregF
		SEC
		SBQMem	zvaltemp0
		STQMem	zregF

		BRA	@nxtpnlfetch

@nxtpnlupwrap:
		LDX	zregBb0
		DEX
		STX	zreg5b0
		LDA	#$00
		STA	zreg5b1
		STA	zreg5b2
		STA	zreg5b3

		ASLWMem	zreg5wl
		ASLWMem	zreg5wl

		LDQMem	zregA
		CLC
		ADQMem	zreg5
		STQMem	zregF

@nxtpnlfetch:
		JSR	__JudeMvActvNextPanel

;					zregBb1:	start panel index
;					zregBb2:	start control index
;					zregDb2	:	panel list index
;					zregDb1	:	control list index

		LDA	zregDb0
		BNE	@nxtpnlcont0

		LDA	zregDb2
		CMP	zregBb1
		LBNE	@nextpanel

		RTS				;Abort

@nxtpnlcont0:
		LDZ	#$00
		LDQIndDWZ	zregE
		STQMem	zreg4

		JMP	@testelem


;					zregA	:	pointer to page's panels
;					zregBb0	:	page panel count
;					zregF	:	pointer to panel in list
;					zregDb2	:	panel list index
;					zptrowner:	active panel
;					zregC	:	pointer to panel's controls
;					zregDb0	:	panel control count
;					zregE	:	pointer to control in list
;					zregDb1	:	control list index


;-----------------------------------------------------------
__JudeSendKeys:
;-----------------------------------------------------------
		JSR	_JudeDequeueKey
		LDA	zvalkey
		BNE	@input

@exit:
		RTS

@input:
		MvDWMem	zreg4, jude_screeny0
		LDA	zvalkey
		LDZ	#$00
		NOP
		STA	(zreg4), Z
		INZ
		INZ
		LDA	zvalkey + 1
		NOP
		STA	(zreg4), Z

		LDA	zvalkey + 1
		AND	#KEY_MOD_SYS
		BEQ	@tstfkeys

		JMP	@findaccel

@tstfkeys:
		LDA	zvalkey
		CMP	#KEY_M65_F1
		BCS	@fkey0
	
		CMP	#KEY_M65_ESC
		LBEQ	@findaccel

		JMP	@isdownctrl

@fkey0:
		CMP	#(KEY_M65_F14 + 1)	
		LBCS	@isdownctrl

		LDA	zvalkey + 1
		AND	#KEY_MOD_SHIFT
		BEQ	@fkeycont

		INC	zvalkey

@fkeycont:
		JMP	@findaccel

@isdownctrl:
		LDA	judeDownElem
		ORA	judeDownElem + 1
		ORA	judeDownElem + 2
		ORA	judeDownElem + 3
		BNE	@downctrl

		LDA	judeActvElem
		ORA	judeActvElem + 1
		ORA	judeActvElem + 2
		ORA	judeActvElem + 3
		BNE	@actvctrl

;***FIXME!!! Shouldn't discard, should send to active page

;		JMP	__JudeSendKeys		;discard key press
		JMP	@page0

@actvctrl:
		MvDWMem	zptrself, judeActvElem

		LDZ	#OBJECT::options + 1
		NOP
		LDA	(zptrself), Z
		AND	#>OPT_AUTOTRACK
		BEQ	@chkmv

		JMP	@send

@chkmv:
		LDA	zvalkey
		CMP	#KEY_C64_CDOWN
		BEQ	@moveactv

		CMP	#KEY_C64_CRIGHT
		BEQ	@moveactv

		CMP	#KEY_M65_TAB
		BEQ	@moveactv

		LDA	zvalkey
		CMP	#KEY_ASC_CR
		BNE	@send

		JSR	_JudeDownCtrl
		JMP	__JudeSendKeys


@moveactv:
		JSR	__JudeMoveActiveControl
		JMP	__JudeSendKeys


@downctrl:
		MvDWMem	zptrself, judeDownElem

@send:
		LDZ	#ELEMENT::keypress
		NOP
		LDA	(zptrself), Z
		STA	jude_proxyptr
		INZ
		LDA	(zptrself), Z
		STA	jude_proxyptr + 1

		BEQ	@page0

		LDZ	#$00
		JSR	__JudeProxy

;***FIXME!!! Check return from keypress and send keys to parent
;loop if not initial control not down and return not abort instead
;of this hack
@page0:
		LDA	_karl_errorno
		CMP	#ERROR_ABORT
		BEQ	@def

		LDA	jude_actvpg
		ORA	jude_actvpg + 1
		ORA	jude_actvpg + 2
		ORA	jude_actvpg + 3
		BEQ	@def

		MvDWMem	zptrself, jude_actvpg

		LDZ	#ELEMENT::keypress
		NOP
		LDA	(zptrself), Z
		STA	jude_proxyptr
		INZ
		LDA	(zptrself), Z
		STA	jude_proxyptr + 1

		BEQ	@def

		LDZ	#$00
		JSR	__JudeProxy

@discard0:
		JMP	__JudeSendKeys

@def:
;		JSR	ctrlsControlDefKeyPress
		JMP	__JudeSendKeys


@findaccel:
		JSR	__JudeProcessAccelerators

		RTS


;-----------------------------------------------------------
__JudeProcVwElemsAccel:
;-----------------------------------------------------------
		LDA	#ERROR_NONE
		STA	_karl_errorno

		LDZ	#OBJECT::state
		NOP
		LDA	(zreg0), Z

		AND	zptrtemp2 + 1
		BEQ	@exit

		LDZ	#CONTROL::accelchar
		NOP
		LDA	(zreg0), Z

		CMP	zvalkey
		BNE	@exit

		MvDWMem	zptrself, zreg0
		JSR	_JudeDownCtrl 

		LDA	#ERROR_ABORT
		STA	_karl_errorno

@exit:
		RTS


;-----------------------------------------------------------
__JudeProcessAccelerators:
;-----------------------------------------------------------
;		MvDWMem	zreg4, jude_actvvw
		LDA	#<__JudeProcVwElemsAccel
		STA	zreg6wl
		LDA	#>__JudeProcVwElemsAccel
		STA	zreg6wl + 1

;		LDA	#OBJECT::change
;		STA	zptrtemp2

		LDA	#STATE_VISIBLE | STATE_ENABLED
		STA	zptrtemp2 + 1

		JSR	__JudeProcViewElements

		RTS


;-----------------------------------------------------------
__JudeUpdateChanged:
;-----------------------------------------------------------
;		MvDWMem	zreg4, jude_actvvw
		LDA	#<__JudeProcVwElemsUpdate
		STA	zreg6wl
		LDA	#>__JudeProcVwElemsUpdate
		STA	zreg6wl + 1

		LDA	#OBJECT::change
		STA	zptrtemp2

		LDA	#STATE_CHANGED
		STA	zptrtemp2 + 1

		JSR	__JudeProcViewElements

		RTS


;-----------------------------------------------------------
__JudeProcVwElemsPanels:
;-----------------------------------------------------------
		LDZ	#OBJECT::state
		NOP
		LDA	(zreg0), Z

		AND	zptrtemp2 + 1
		BEQ	@controls

		LDA	zreg3wh
		STA	jude_proxyptr
		LDA	zreg3wh + 1
		STA	jude_proxyptr + 1

		LDZ	#$00
		JSR	__JudeProxy

@controls:
		MvDWMem	zreg4, zreg0

		LDA	#PANEL::controlscnt
		STA	zreg5b0

		LDA	#PANEL::controls_p
		STA	zreg5b2

		LDA	#$00
		STA	zreg5b3

		LDA	zreg3wh
		STA	zreg6wl
		LDA	zreg3wh + 1
		STA	zreg6wl + 1

		JSR	__KarlProcObjLst

@exit:
		RTS


;-----------------------------------------------------------
__JudeProcVwElemsPages:
;-----------------------------------------------------------
		LDZ	#OBJECT::state
		NOP
		LDA	(zreg0), Z

		AND	zptrtemp2 + 1
		BEQ	@panels

		LDA	zreg3wh
		STA	jude_proxyptr
		LDA	zreg3wh + 1
		STA	jude_proxyptr + 1

		LDZ	#$00
		JSR	__JudeProxy

@panels:
		MvDWMem	zreg4, zreg0

		LDA	#PAGE::panelscnt
		STA	zreg5b0

		LDA	#PAGE::panels_p
		STA	zreg5b2

		LDA	#$00
		STA	zreg5b3

		LDA	#<__JudeProcVwElemsPanels
		STA	zreg6wl
		LDA	#>__JudeProcVwElemsPanels
		STA	zreg6wl + 1

		JSR	__KarlProcObjLst

@exit:
		RTS


;-----------------------------------------------------------
__JudeProcViewElements:
;-----------------------------------------------------------
;	zreg6wl		IN		callback routine
;-----------------------------------------------------------
		LDA	jude_actvvw
		ORA	jude_actvvw + 1
		ORA	jude_actvvw + 2
		ORA	jude_actvvw + 2
		BNE	@begin

		RTS

@begin:
		LDA	zreg6wl
		STA	zreg3wh
		LDA	zreg6wl + 1
		STA	zreg3wh + 1

		MvDWMem	zreg4, jude_actvvw

		LDA	#VIEW::barscnt
		STA	zreg5b0

		LDA	#VIEW::bars_p
		STA	zreg5b2

		LDA	#$00
		STA	zreg5b3

		LDA	#<__JudeProcVwElemsPanels
		STA	zreg6wl
		LDA	#>__JudeProcVwElemsPanels
		STA	zreg6wl + 1

		JSR	__KarlProcObjLst

;		LDA	zptrtemp2 + 1
;		CMP	#STATE_DIRTY
;		BEQ	@present


		BRA	@present

;	This code, which I'm skipping, would process all pages in the 
;	view which I've decided I never want (and esp for DIRTY/Present 
;	calls).

		MvDWMem	zreg4, jude_actvvw

		LDA	#VIEW::pagescnt
		STA	zreg5b0

		LDA	#VIEW::pages_p
		STA	zreg5b2

		LDA	#$00
		STA	zreg5b3

		LDA	#<__JudeProcVwElemsPages
		STA	zreg6wl
		LDA	#>__JudeProcVwElemsPages
		STA	zreg6wl + 1

		JSR	__KarlProcObjLst

		RTS

@present:
;	Process the active page only

		LDA	jude_actvpg
		ORA	jude_actvpg + 1
		ORA	jude_actvpg + 2
		ORA	jude_actvpg + 3
		BNE	@cont0

		RTS

@cont0:
		MvDWMem	zreg0, jude_actvpg

		LDZ	#OBJECT::state
		NOP
		LDA	(zreg0), Z

		AND	zptrtemp2 + 1
		BEQ	@panels

		LDA	zreg3wh
		STA	jude_proxyptr
		LDA	zreg3wh + 1
		STA	jude_proxyptr + 1

		LDZ	#$00
		JSR	__JudeProxy

@panels:
		MvDWMem	zreg4, jude_actvpg

;		SEI
;@halt:
;		INC	$D020
;		JMP	@halt
;		CLI

		LDA	#PAGE::panelscnt
		STA	zreg5b0

		LDA	#PAGE::panels_p
		STA	zreg5b2

		LDA	#$00
		STA	zreg5b3

		LDA	#<__JudeProcVwElemsPanels
		STA	zreg6wl
		LDA	#>__JudeProcVwElemsPanels
		STA	zreg6wl + 1

		JSR	__KarlProcObjLst

		RTS

;-----------------------------------------------------------
__JudeProcVwElemsUpdate:
;-----------------------------------------------------------
		LDZ	#OBJECT::state
		NOP
		LDA	(zreg0), Z

		AND	zptrtemp2 + 1
		BEQ	@exit

		MvDWMem	zptrself, zreg0

		LDZ	zptrtemp2
		NOP
		LDA	(zreg0), Z
		STA	jude_proxyptr
		INZ
		NOP
		LDA	(zreg0), Z
		STA	jude_proxyptr + 1

		BEQ	@exit

		LDZ	#$00
		JSR	__JudeProxy

@exit:
		RTS

;-----------------------------------------------------------
__JudePresentDirty:
;-----------------------------------------------------------
		LDA	#<__JudeProcVwElemsUpdate
		STA	zreg6wl
		LDA	#>__JudeProcVwElemsUpdate
		STA	zreg6wl + 1

		LDA	#ELEMENT::present
		STA	zptrtemp2

		LDA	#STATE_DIRTY
		STA	zptrtemp2 + 1

		JSR	__JudeProcViewElements

		RTS


;-----------------------------------------------------------
__JudeThemeSetMouse:
;-----------------------------------------------------------
		LDA	#$C0
		TSB	$D070

		LDA	#<CLR_CURSOR
		LDX	#>CLR_CURSOR
		JSR	_JudeLogClrToSys

		TAX
		LDA	$D100, X
		STA	zreg3b0
		LDA	$D200, X
		STA	zreg3b1
		LDA	$D300, X
		STA	zreg3b2

		LDA	$D070
		AND	#$3F
		STA	$D070

		LDA	jude_mousepal
		ASL
		ASL
		ASL
		ASL
		ASL
		ASL
		TSB	$D070

		LDA	#$00
		STA	$D100
		STA	$D102
		STA	$D200
		STA	$D202
		STA	$D300
		STA	$D302

		LDA	zreg3b0
		STA	$D101
		LDA	zreg3b1
		STA	$D201
		LDA	zreg3b2
		STA	$D301

		LDA	#$08
		STA	$D103
		STA	$D203
		STA	$D303

		LDA	#$FF
		STA	$D104
		STA	$D204
		STA	$D304

		LDA	$D070
		AND	#$F3
		STA	$D070

		LDA	jude_mousepal
		ASL
		ASL
		TSB	$D070

;	Set the mapped palette to the one used by the chars so
;	that m65 will get the proper screen shot
		LDA	#$C0
		TSB	$D070

		RTS


;-----------------------------------------------------------
__MouseProcessClick:
;-----------------------------------------------------------
		LDA	mouseBtnLClick
		BEQ	@exit

		LDA	#$00
		STA	mouseBtnLClick

		LDA	mouseCapture
		BEQ	@norm

		JMP	(mouseCapClick)

@norm:
		LDA	judePickElem
		ORA	judePickElem + 1
		ORA	judePickElem + 2
		ORA	judePickElem + 3
		BNE	@down

		RTS

@down:
		MvDWMem	zptrself, judePickElem

		JSR	_JudeDownCtrl

@exit:
		RTS


;-----------------------------------------------------------
__MouseUnPickElement:
;-----------------------------------------------------------
		LDA	judePickElem
		ORA	judePickElem + 1
		ORA	judePickElem + 2
		ORA	judePickElem + 3
		BEQ	@exit

		MvDWMem	zptrself, judePickElem

		LDZ	#OBJECT::state
		NOP
		LDA	(zptrself), Z

		AND	#STATE_PICKED
		BEQ	@clear

		LDA	#STATE_PICKED
		JSR	_KarlObjExcludeState

@clear:
		MvDWZ	judePickElem

@exit:
		RTS


;-----------------------------------------------------------
__MousePickElement:
;-----------------------------------------------------------
		LDA	judePickElem
		CMP judeMsePElem
		BNE	@update

		LDA	judePickElem + 1
		CMP judeMsePElem + 1
		BNE	@update

		LDA	judePickElem + 2
		CMP judeMsePElem + 2
		BNE	@update

		LDA	judePickElem + 3 
		CMP judeMsePElem + 3
		BNE	@update

		RTS

@update:
		JSR	__MouseUnPickElement

		MvDWMem	zptrself, judeMsePElem
		MvDWMem	judePickElem, zptrself

;		LDA	#$00
;		STA	zreg2b3
		LDA	#STATE_PICKED
		JSR	_KarlObjIncludeState

;		LDZ	#OBJECT::options + 1
;		NOP
;		LDA	(zptrself), Z
;		AND	#>OPT_AUTOTRACK
;		BEQ	@exit
;
;		JSR	_JudeActivateCtrl

@exit:
		RTS


;-----------------------------------------------------------
__MouseInElement:
;-----------------------------------------------------------
		LDZ	#ELEMENT::posy
		NOP
		LDA	(zptrself), Z
		STA	zptrtemp0

		LDA	mouseYRow
		CMP	zptrtemp0
		BCS	@testh

		JMP	@nomatch

@testh:
		LDZ	#ELEMENT::height
		NOP
		LDA	(zptrself), Z

		CLC
		ADC	zptrtemp0
		STA	zptrtemp0

		LDA	mouseYRow
		CMP	zptrtemp0
		BCS	@nomatch

		LDZ	#ELEMENT::posx
		NOP
		LDA	(zptrself), Z
		STA	zptrtemp0

		LDA	mouseXCol
		CMP	zptrtemp0
		BCS	@testw

@nomatch:
		CLC
		RTS

@testw:
		LDZ	#ELEMENT::width
		NOP
		LDA	(zptrself), Z

		CLC
		ADC	zptrtemp0
		STA	zptrtemp0

		LDA	mouseXCol
		CMP	zptrtemp0
		BCS	@nomatch

		SEC
		RTS


;-----------------------------------------------------------
__MousePickBlink:
;-----------------------------------------------------------
		LDY	judePBlinkDelay
		BEQ	@blink

		DEY
		STY	judePBlinkDelay
		
		RTS

@blink:
;		LDY	#$29
		LDY	#$14
		STY	judePBlinkDelay

		MvDWMem	zptrself, judePickElem

		LDA	judePBlinkState
		EOR	#$01
		STA	judePBlinkState

		BEQ	@exclude

;		LDA	#$00
;		STA	zreg2b3
		LDA	#STATE_PICKED
		JSR	_KarlObjIncludeState
		RTS

@exclude:
		LDA	#STATE_PICKED
		JSR	_KarlObjExcludeState

		RTS


;-----------------------------------------------------------
__MouseProcessPickControls:
;-----------------------------------------------------------
		MvDWMem	zptrself, zreg0

		LDZ	#OBJECT::state
		NOP
		LDA	(zptrself), Z
;		AND	#STATE_VISIBLE
		BIT	#STATE_VISIBLE
		BNE	@cont0

		RTS

@cont0:
;		NOP
;		LDA	(zptrself), Z
;		AND	#STATE_ENABLED
		BIT	#STATE_ENABLED
		BNE	@cont1

		RTS

@cont1:
		LDZ	#OBJECT::options
		NOP
		LDA	(zptrself), Z
		AND	#OPT_NONAVIGATE
		BEQ	@cont2

		RTS

@cont2:
		JSR	__MouseInElement
		BCS	@cont3

		RTS

@cont3:
		MvDWMem	judeMsePElem, zptrself

		LDA	#ERROR_ABORT
		STA	_karl_errorno

		RTS

;-----------------------------------------------------------
__MouseProcessPickPanels:
;-----------------------------------------------------------
		MvDWMem	zptrself, zreg0

		LDZ	#OBJECT::state
		NOP
		LDA	(zptrself), Z
;		AND	#STATE_VISIBLE
		BIT	#STATE_VISIBLE
		BNE	@cont0

		RTS

@cont0:
;		NOP
;		LDA	(zptrself), Z
		BIT	#STATE_ENABLED
		BNE	@cont1

		RTS

@cont1:
		LDZ	#OBJECT::options
		NOP
		LDA	(zptrself), Z
		AND	#OPT_NONAVIGATE
		BEQ	@cont2

		RTS

@cont2:
		JSR	__MouseInElement
		BCS	@cont3

		RTS

@cont3:
;		MvDWMem	judeMsePElem, zptrselfl

		MvDWMem	zreg4, zreg0

		LDA	#PANEL::controlscnt
		STA	zreg5b0

		LDA	#PANEL::controls_p
		STA	zreg5b2

		LDA	#$01
		STA	zreg5b3

		LDA	#<__MouseProcessPickControls
		STA	zreg6wl
		LDA	#>__MouseProcessPickControls
		STA	zreg6wl + 1

		JSR	__KarlProcObjLst

		RTS


;;-----------------------------------------------------------
; __MouseProcessPickPages:
;;-----------------------------------------------------------
;		MvDWMem	zptrself, zreg0
;
;		LDZ	#OBJECT::state
;		NOP
;		LDA	(zptrself), Z
;		AND	#STATE_VISIBLE
;		BNE	@cont0
;
;		RTS
;
; @cont0:
;		NOP
;		LDA	(zptrself), Z
;		AND	#STATE_ENABLED
;		BNE	@cont1
;
;		RTS
;
; @cont1:
;		LDZ	#OBJECT::options
;		NOP
;		LDA	(zptrself), Z
;		AND	#OPT_NONAVIGATE
;		BEQ	@cont2
;
;		RTS
;
; @cont2:
;		JSR	_MouseInElement
;		BCS	@cont3
;
;		RTS
;
; @cont3:
;		MvDWMem	zreg4, zreg0
;
;		LDA	#PAGE::panelscnt
;		STA	zreg5b0
;
;		LDA	#PAGE::panels_p
;		STA	zreg5b2
;
;		LDA	#$01
;		STA	zreg5b3
;
;		LDA	#<_MouseProcessPickPanels
;		STA	zreg6wl
;		LDA	#>_MouseProcessPickPanels
;		STA	zreg6wl + 1
;
;		JSR	_KarlProcObjLst
;
;		RTS


;-----------------------------------------------------------
__MouseProcessMouse:
;-----------------------------------------------------------
		MvDWMem	zreg4, jude_actvvw
		LDA	zreg4
		ORA	zreg4 + 1
		ORA	zreg4 + 2
		ORA	zreg4 + 3
		BNE	@begin

@exit:
		RTS

@begin:
		INC	mouseCheck

		LDA	jude_mptrstate
		CMP	#MPTR_NORMAL
		BNE	@exit

		LDA	mouseBtnLClick
		LBNE	@proc

		LDA	mouseCheck
		CMP	#$10
		BCS	@proc

		LDA	mouseCapture
		BEQ	@tstpick

		RTS

@tstpick:
		LDA	judePickElem
		ORA	judePickElem + 1
		ORA	judePickElem + 2
		ORA	judePickElem + 3

		BNE	@tstblink
		RTS

@tstblink:
		LDA	judePickElem
		CMP judeDownElem
		BNE	@blink

		LDA	judePickElem + 1
		CMP judeDownElem + 1
		BNE	@blink

		LDA	judePickElem + 2
		CMP judeDownElem + 2
		BNE	@blink

		LDA	judePickElem + 3 
		CMP judeDownElem + 3
		BNE	@blink

;		MvDWMem	zreg4, judeDownElem
;
;		LDZ	#OBJECT::options + 1
;		NOP
;		LDA	(zreg4), Z
;		AND	#>OPT_DOWNPICK
;		BNE	@blink

		RTS

@blink:
		JSR	__MousePickBlink
		RTS

@proc:
		LDA	#$00
		STA	mouseCheck

		LDA	mouseXPos
		STA	mouseTemp0
		LDA	mouseXPos + 1
		STA	mouseTemp0 + 1
		
		LSRWMem	mouseTemp0
		LSRWMem	mouseTemp0
		
		LDA	jude_avhrsx
		BNE	@cont0

		LSRWMem	mouseTemp0

@cont0:
		LDA	mouseTemp0
		STA	mouseXCol
		
		LDA	mouseYPos
		STA	mouseTemp0
		LDA	mouseYPos + 1
		STA	mouseTemp0 + 1

		LSRWMem	mouseTemp0
		LSRWMem	mouseTemp0
		
		LDA	jude_avhrsy
		BNE	@cont1

		LSRWMem	mouseTemp0
		
@cont1:
		LDA	mouseTemp0
		STA	mouseYRow

		LDA	mouseCapture
		BEQ	@findctrl
		
		JMP	(mouseCapMove)

;		RTS

@findctrl:
		MvDWZ	judeMsePElem

;		LDA	#VIEW::pagescnt
;		STA	zreg5b0
;
;		LDA	#VIEW::pages_p
;		STA	zreg5b2
;
;		LDA	#$01
;		STA	zreg5b3
;
;		LDA	#<_MouseProcessPickPages
;		STA	zreg6wl
;		LDA	#>_MouseProcessPickPages
;		STA	zreg6wl + 1
;
;		JSR	_KarlProcObjLst

		MvDWMem	zreg4, jude_actvpg

		LDA	#PAGE::panelscnt
		STA	zreg5b0

		LDA	#PAGE::panels_p
		STA	zreg5b2

		LDA	#$01
		STA	zreg5b3

		LDA	#<__MouseProcessPickPanels
		STA	zreg6wl
		LDA	#>__MouseProcessPickPanels
		STA	zreg6wl + 1

		JSR	__KarlProcObjLst

		LDA	judeMsePElem
		ORA	judeMsePElem + 1
		ORA	judeMsePElem + 2
		ORA	judeMsePElem + 3
		BNE	@dopick

		MvDWMem	zreg4, jude_actvvw

		LDA	#VIEW::barscnt
		STA	zreg5b0

		LDA	#VIEW::bars_p
		STA	zreg5b2

		LDA	#$01
		STA	zreg5b3

		LDA	#<__MouseProcessPickPanels
		STA	zreg6wl
		LDA	#>__MouseProcessPickPanels
		STA	zreg6wl + 1

		JSR	__KarlProcObjLst

		LDA	judeMsePElem
		ORA	judeMsePElem + 1
		ORA	judeMsePElem + 2
		ORA	judeMsePElem + 3
		BEQ	@unpick

@dopick:
		LDA	judePickElem
		CMP	judeMsePElem
		BNE	@newpick
		LDA	judePickElem + 1
		CMP	judeMsePElem + 1
		BNE	@newpick
		LDA	judePickElem + 2
		CMP	judeMsePElem + 2
		BNE	@newpick
		LDA	judePickElem + 3
 		CMP	judeMsePElem + 3
		BNE	@newpick

		JSR	__MousePickBlink
		RTS

@newpick:
;		MvDWMem	zptrself, judeMsePElem

;		LDA	#$29
		LDA	#$14
		STA	judePBlinkDelay
		LDA	#$01
		STA	judePBlinkState

		JSR	__MousePickElement
		RTS
		
@unpick:
		JSR	__MouseUnPickElement

		RTS


;-----------------------------------------------------------
__MouseInputMouse:
;-----------------------------------------------------------
;		LDA	mouseCheck
;		BEQ	@begin
;		
;		INC	mouseCheck

@begin:
		LDY	#%00000000		    ;Set ports A and B to input
		STY	CIA1_DDRB
		STY	CIA1_DDRA			;Keyboard won't look like mouse
		LDA	CIA1_PRB			 ;Read Control-Port 1
		DEC	CIA1_DDRA			;Set port A back to output
		EOR	#%11111111		    ;Bit goes up when button goes down
		STA	mouseButtons
		BEQ	@L0				 ;(bze)
		DEC	CIA1_DDRB			;Mouse won't look like keyboard
		STY	CIA1_PRB			 ;Set "all keys pushed"

@L0:    
		JSR	__MouseButtonCheck
		
		LDA	SID_ADCONV1		   ;Get mouse X movement

		LDY	mouseOldPotX
		JSR	_MoveCheck			;Calculate movement vector
		STY	mouseOldPotX

; Skip processing if nothing has changed

		BCC	@SkipX

; Calculate the new X coordinate (--> a/y)
		ASL
		PHA
		TXA
		ROL
		TAX
		PLA

		CLC
		ADC	mouseXPosNew

		TAY					    ;Remember low byte
		TXA
		ADC	mouseXPosNew+1
		TAX

; Limit the X coordinate to the bounding box

		CPY	mouseXMin
		SBC	mouseXMin+1
		BPL	@L1
		LDY	mouseXMin
		LDX	mouseXMin+1
		JMP	@L2
@L1:    	
		TXA

		CPY	mouseXMax
		SBC	mouseXMax+1
		BMI	@L2
		LDY	mouseXMax
		LDX	mouseXMax+1
@L2:    
		STY	mouseXPosNew
	    STX	mouseXPosNew+1
		JSR __MouseHistoresisCheck

; Move the mouse pointer to the new X pos

		TYA
		JSR	__MouseMoveSprX
		
;		LDA	mouseCheck
;		BNE	@SkipX

;		LDA	#$01
;		STA	mouseCheck

; Calculate the Y movement vector

@SkipX: 
		LDA	SID_ADCONV2		   ;Get mouse Y movement
		LDY	mouseOldPotY
		JSR	_MoveCheck			;Calculate movement
		STY	mouseOldPotY

; Skip processing if nothing has changed

		BCC	@SkipY

; Calculate the new Y coordinate (--> a/y)

		ASL
		PHA
		TXA
		ROL
		TAX
		PLA

		STA	mouseOldValue
		LDA	mouseYPosNew
		SEC
		SBC	mouseOldValue

		TAY
		STX	mouseOldValue
		LDA	mouseYPosNew+1
		SBC	mouseOldValue
		TAX

; Limit the Y coordinate to the bounding box

		CPY	mouseYMin
		SBC	mouseYMin+1
		BPL	@L3
		LDY	mouseYMin
		LDX	mouseYMin+1
		JMP	@L4
@L3:    
		TXA

		CPY	mouseYMax
		SBC	mouseYMax+1
		BMI	@L4
		LDY	mouseYMax
		LDX	mouseYMax+1
@L4:    	
		STY	mouseYPosNew
		STX	mouseYPosNew+1

		JSR __MouseHistoresisCheck

; Move the mouse pointer to the new Y pos

		TYA
		JSR	__MouseMoveSprY

;		LDA	mouseCheck
;		BNE	@SkipY
;		
;		LDA	#$01
;		STA	mouseCheck

; Done

@SkipY: 
;		JSR	CDRAW

;dengland	What is this for???
		CLC					    ;Interrupt not "handled"

		RTS

__MouseHistoresisCheck:
	;; Dont actually update mouse unless it has moved more than 1 px in the same direction
	
	lda mouseXPosNew
	cmp mouseXPosPending
	bne @XChanged
	lda mouseXPosNew+1
	cmp mouseXPosPending+1
	beq @updatedmouseXDir
@XChanged:
	;;  Get sign of difference between XPos and mouseXPosNew
	lda mouseXPosNew
	sec
	sbc mouseXPosPending
	lda mouseXPosNew+1
	sbc mouseXPosPending+1

	pha
	lda mouseXPosNew
	sta mouseXPosPending
	lda mouseXPosNew+1
	sta mouseXPosPending+1
	pla	
	
	;; Is the direction different to last time?
	and #$80
	sta mouseDirTemp
	eor mouseXDir
	bne @UpdatemouseXDir
	;; Direction same, so update X position
	lda mouseXPosNew+1
	sta mouseXPos+1
	lda mouseXPosNew
	sta mouseXPos
	jmp @updatedmouseXDir
@UpdatemouseXDir:
	;;  Don't update X, but do update the direction of last movement
	lda mouseDirTemp
	sta mouseXDir
@updatedmouseXDir:

	lda mouseYPosNew
	cmp mouseYPosPending
	bne @YChanged
	lda mouseYPosNew+1
	cmp mouseYPosPending+1
	beq @updatedmouseYDir
@YChanged:

	;;  Get sign of difference between mouseYPos and mouseYPosNew
	lda mouseYPosNew
	sec
	sbc mouseYPosPending
	lda mouseYPosNew+1
	sbc mouseYPosPending+1

	pha
	lda mouseYPosNew
	sta mouseYPosPending
	lda mouseYPosNew+1
	sta mouseYPosPending+1
	pla	
	
	;; Is the direction different to last time?
	and #$80
	sta mouseDirTemp
	eor mouseYDir
	bne @UpdatemouseYDir
	;; Direction same, so update Y position
	lda mouseYPosNew+1
	sta mouseYPos+1
	lda mouseYPosNew
	sta mouseYPos
	jmp @updatedmouseYDir
@UpdatemouseYDir:
	;;  Don't update Y, but do update the direction of last movement
	lda mouseDirTemp
	sta mouseYDir
@updatedmouseYDir:

	rts

;-----------------------------------------------------------
_MoveCheck:
; Move check routine, called for both coordinates.
;
; Entry:        y = old value of pot register
;               a = current value of pot register
; Exit:         y = value to use for old value
;               x/a = delta value for position
;-----------------------------------------------------------
		STY     mouseOldValue
		STA     mouseNewValue
		LDX     #$00

		SEC				; a = mod64 (new - old)
		SBC	mouseOldValue

	cmp #$3f
	bcs @notPositiveMovement
	LDY mouseNewValue
	LDX #0
		SEC
	RTS
@notPositiveMovement:
	cmp #$c0
	bcc @notNegativeMovement
		LDY     mouseNewValue
	ldx #$ff
		SEC
		RTS

@notNegativeMovement:
	ldy mouseNewValue
		TXA                             ; A = $00
		CLC
		RTS


;-----------------------------------------------------------
__MouseButtonCheck:
;-----------------------------------------------------------

		LDA	mouseButtons			;mouseButtons still the same as last
		CMP	mouseButtonsOld		;time?
		BEQ	@done			;Yes - don't do anything here
		
;		PHA
;		LDA	#$01
;		STA	MouseUsed
;		PLA
;		INC	$D020


		AND	#MOUSE_LBTN		;No - Is left button down?
;		BIT	#MOUSE_LBTN		;No - Is left button down?
		BNE	@testRight		;Yes - test right
		
		LDA	mouseButtonsOld		;No, but was it last time?
		AND	#MOUSE_LBTN
;		BIT	#MOUSE_LBTN
		BEQ	@testRight		;No - test right
		
		LDA	#$01			;Yes - flag have left click
		STA	mouseBtnLClick
		
@testRight:
;dengland Before adding BIT, this was probably bugged.

;		AND	#MOUSE_RBTN		;Is right button down?
		BIT	#MOUSE_RBTN		;Is right button down?
		BNE	@done			;Yes - don't do anything here
		
		LDA	mouseButtonsOld		;No, but was it last time?
;		AND	#MOUSE_RBTN
		BIT	#MOUSE_RBTN
		BEQ	@done			;No - don't do anything here
		
		LDA	#$01			;Yes - flag have right click
		STA	mouseBtnRClick

@done:
		LDA	mouseButtons			;Store the current state
		STA	mouseButtonsOld
		RTS


;-----------------------------------------------------------
__MouseMoveSprX:
;-----------------------------------------------------------
		LDA	mouseXPos + 1
		LSR
		STA	mouseTemp0
		LDA	mouseXPos
		ROR
		STA	mouseXCell
		LDA	mouseTemp0
		LSR
		STA	mouseTemp0
		LDA	mouseXCell
		ROR
		STA	mouseXCell

		CLC
		LDA	mouseXPos
		ADC	#SPRITE_OFFX
		STA	mouseTemp1
		LDA	mouseXPos + 1
		ADC	#$00
		STA	mouseTemp1 + 1

		LDA	mouseTemp1
		STA	VIC_XPOS
		LDA	mouseTemp1 + 1
		CMP	#$00
		BEQ	@unset

		LDA	#$01
		TSB	VIC_XPOSMSB
		RTS
	
@unset:
		LDA	#$01
		TRB	VIC_XPOSMSB

		RTS

;-----------------------------------------------------------
__MouseMoveSprY:
;-----------------------------------------------------------
		LDA	mouseYPos + 1
		LSR
		STA	mouseTemp0
		LDA	mouseYPos
		ROR
		STA	mouseYCell
		LDA	mouseTemp0
		LSR
		STA	mouseTemp0
		LDA	mouseYCell
		ROR
		STA	mouseYCell

		CLC
		LDA	mouseYPos
		ADC	#SPRITE_OFFY
		STA	mouseTemp1
		LDA	mouseYPos + 1
		ADC	#$00
		STA	mouseTemp1 + 1

		LDA	mouseTemp1
		STA	VIC_YPOS

		RTS


;-----------------------------------------------------------
__KeysInputKeys:
;-----------------------------------------------------------
@loop:
		LDX	$D611
		LDA	$D610

		STA	$D610

		BNE	@enqueue

		RTS

@enqueue:
;		STA	$0400

		JSR	_JudeEnqueueKey
		JMP	@loop


jude_volstr:
		.res	$20, 0


;-----------------------------------------------------------
__JudeVolatileStore:
;-----------------------------------------------------------
;		LDA	#$40
;		STA	@loop + 1
;
;		LDA	#<jude_volstr
;		STA	@store + 1
;		LDA	#>jude_volstr
;		STA	@store + 2

		LDX	#$1F
@loop:
		LDA	$40, X
@store:
		STA	jude_volstr, X

;		INC	@loop + 1
;		INW	@store + 1

		DEX
		BPL	@loop

		RTS


;-----------------------------------------------------------
__JudeVolatileLoad:
;-----------------------------------------------------------
;		LDA	#$40
;		STA	@store + 1
;
;		LDA	#<jude_volstr
;		STA	@loop + 1
;		LDA	#>jude_volstr
;		STA	@loop + 2

		LDX	#$1F
@loop:
		LDA	jude_volstr, X
@store:
		STA	$40, X

;		INW	@loop + 1
;		INC	@store + 1

		DEX
		BPL	@loop

		RTS


;-----------------------------------------------------------
__JudeUserIRQNOP:
;-----------------------------------------------------------
		RTI


;-----------------------------------------------------------
__JudeUserIRQ:
;-----------------------------------------------------------
		PHP				;save the initial state
		PHA
		PHX
		PHY
		PHZ

		CLD

		LDA	#$01
		STA	karl_lock

	.if	DEBUG_RASTERTIME
		LDA	#$00
		STA	VIC_BRDRCLR
	.endif

		JSR	__JudeVolatileStore

;	Is the VIC-II needing service?
		LDA	VIC_IRQFLGS
		AND	#$01
		BNE	@proc

;	Some other interrupt source
		JSR	_KarlPanic

@proc:
		ASL	VIC_IRQFLGS

		MvDWMem	zptrtemp1, zptrself

		JSR	__JudeUserIRQHandler

		MvDWMem	zptrself, zptrtemp1

@done:
		JSR	__JudeVolatileLoad

	.if	DEBUG_RASTERTIME
		LDA	#<CLR_EMPTY
		LDX	#>CLR_EMPTY
		JSR	_JudeLogClrToSys
		STA	VIC_BRDRCLR
	.endif

		LDA	#$00
		STA	karl_lock

		PLZ
		PLY
		PLX
		PLA
		PLP

		RTI


;-----------------------------------------------------------
__JudeUserIRQHandler:
;-----------------------------------------------------------
@keys:
		JSR	__KeysInputKeys

@mouse:
		JSR	__MouseInputMouse
		JSR	__MouseProcessMouse
		JSR	__MouseProcessClick


@exit:

		RTS


;-----------------------------------------------------------
__JudeDefCorePrepare:
;-----------------------------------------------------------
		SEI

		LDA	#$7F			;disable standard CIA irqs
		STA	CIA1_IRQCTL

;	Bank out BASIC+Kernal, keep IO
;	First, make sure that the IO port line are set to output
		LDA	$00
		ORA	#$07
		STA	$00

;	Now, exclude BASIC+KERNAL from the memory map (keep IO)
		LDA	#$1D
		STA	$01

		LDA	#$00
		STA	_karl_errorno

		RTS

;-----------------------------------------------------------
__JudeDefCoreInit:
;-----------------------------------------------------------
		LDA	#<__JudeUserIRQ		;install our handler
		STA	CPU_IRQ
		LDA	#>__JudeUserIRQ
		STA	CPU_IRQ + 1

		LDA	#<__JudeUserIRQNOP		;install our handler
		STA	CPU_RESET
		LDA	#>__JudeUserIRQNOP
		STA	CPU_RESET + 1

		LDA	#<__JudeUserIRQNOP		;install our handler
		STA	CPU_NMI
		LDA	#>__JudeUserIRQNOP
		STA	CPU_NMI + 1

		LDA	#%01111111		;We'll always want rasters
		AND	VIC_CTRLREG		;    less than $0100
		STA	VIC_CTRLREG
		
		LDA	#$19
		STA	VIC_RSTRVAL
		
		LDA	#$01			;Enable raster irqs
		STA	VIC_IRQMASK

		LDA	#$00
		STA	_karl_errorno

		CLI

		RTS

;-----------------------------------------------------------
__JudeDefCoreChange:
;-----------------------------------------------------------
		LDA	#$00
		STA	_karl_errorno

		RTS

;-----------------------------------------------------------
__JudeDefCoreRelease:
;-----------------------------------------------------------
		LDA	#$00
		STA	_karl_errorno

		RTS


;-----------------------------------------------------------
__JudeProxy:
;-----------------------------------------------------------
		JMP	(jude_proxyptr)


	.data

mod_jude_core:
;	Object
		.byte		.sizeof(MODULE)			;size
		.dword		$00000000				;parent
		.word		_KarlDefModPrepare		;prepare
		.word		_KarlDefModInit			;initialise
		.word		_KarlDefModChange		;change
		.word		_KarlDefModRelease		;release
		.word		STATE_DEFAULT			;state
		.word		$0000					;oldstate
		.word		$0000					;options
		.word		$0000					;tag
;	Named
		.asciiz		"JUDE CORE       "		;name
;	Module
		.dword		uns_jude_core			;units_p
		.byte		$01						;unitscnt

uns_jude_core:
		.dword		uni_jude_core

uni_jude_core:
;	Object
		.byte		.sizeof(UNIT)			;size
		.dword		mod_jude_core			;parent
		.word		__JudeDefCorePrepare	;prepare
		.word		__JudeDefCoreInit		;initialise
		.word		__JudeDefCoreChange		;change
		.word		__JudeDefCoreRelease	;release
		.word		STATE_DEFAULT			;state
		.word		$0000					;oldstate
		.word		$0000					;options
		.word		$0000					;tag
;	Named
		.asciiz		"JUDE CORE       "		;name


dma_view_clear:
	.byte	$0B					; Request format is F018B
dma_vw_smb:
	.byte	$80,$00				; Source MB 
dma_vw_dmb:
	.byte	$81,$00				; Destination MB 
	.byte	$00					; No more options
	.byte	$00					;Command LSB
dma_vw_siz:
	.word	$0000				;Count LSB Count MSB
dma_vw_sadr:
	.word	$0000				;Source Address LSB Source Address MSB
dma_vw_sbnk:
	.byte	$00					;Source Address BANK and FLAGS
dma_vw_dadr:
	.word	$0000				;Destination Address LSB Destination Address MSB
dma_vw_dbnk:
	.byte	$00					;Destination Address BANK and FLAGS
	.byte	$00					;Command MSB
	.word	$0000				;Modulo LSB / Mode Modulo MSB / Mode

themecnt:
		.byte	$03


;	.define	CLR_BACK		$00FD		;Background on C64
;	.define	CLR_EMPTY		$00FE		;Border on C64
;	.define	CLR_CURSOR		$00FF		
;	.define	CLR_TEXT		$0000
;	.define	CLR_FOCUS		$0001
;	.define	CLR_INSET		$0002
;	.define	CLR_FACE		$0003
;	.define CLR_SHADOW		$0004
;	.define CLR_PAPER		$0005
;	.define CLR_MONEY		$0006
;	.define	CLR_ITEM		$0007


theme0:
		.asciiz		"CORPORATE       "
		.byte		$00, $06, $04, $01, $01, $06, $0E, $0B
		.byte		$0F, $03, $0C, $0E, $0D, $07, $0A

		.asciiz		"DARK            "
		.byte		$00, $00, $04, $0F, $01, $00, $0F, $0B
		.byte		$0F, $03, $0C, $0E, $0D, $07, $0A

		.asciiz		"FAMILIAR        "
		.byte		$00, $0E, $06, $01, $01, $0E, $04, $0C
		.byte		$0F, $03, $0F, $06, $0D, $07, $0A

		.asciiz		"ASTRO           "
		.byte		$00, $00, $0A, $02, $01, $00, $0A, $0B
		.byte		$0F, $0A, $0C, $0F, $0D, $07, $0A

		.asciiz		"GREEN           "
		.byte		$00, $05, $0D, $01, $01, $05, $0D, $0B
		.byte		$0F, $03, $0C, $0D, $0D, $07, $0A

		.asciiz		"CORPORATE NUEVO "
		.byte		$00, $06, $04, $01, $01, $06, $04, $0B
		.byte		$0F, $03, $0C, $0E, $0D, $07, $0A


pointer0:
		.byte		$33, $33, $33, $33, $33, $00, $00, $00
		.byte		$32, $22, $22, $22, $23, $00, $00, $00
		.byte		$32, $44, $44, $42, $30, $00, $00, $00
		.byte		$32, $31, $11, $23, $00, $00, $00, $00
		.byte		$32, $31, $11, $42, $30, $00, $00, $00
		.byte		$32, $31, $11, $14, $23, $00, $00, $00
		.byte		$32, $32, $31, $11, $42, $30, $00, $00
		.byte		$32, $23, $23, $11, $14, $23, $00, $00
		.byte		$32, $30, $32, $31, $32, $30, $00, $00
		.byte		$33, $00, $03, $23, $23, $00, $00, $00
		.byte		$00, $00, $00, $32, $30, $00, $00, $00
		.byte		$00, $00, $00, $03, $00, $00, $00, $00
		.byte		$00, $00, $00, $00, $00, $00, $00, $00
		.byte		$00, $00, $00, $00, $00, $00, $00, $00
		.byte		$00, $00, $00, $00, $00, $00, $00, $00
		.byte		$00, $00, $00, $00, $00, $00, $00, $00
		.byte		$00, $00, $00, $00, $00, $00, $00, $00
		.byte		$00, $00, $00, $00, $00, $00, $00, $00
		.byte		$00, $00, $00, $00, $00, $00, $00, $00
		.byte		$00, $00, $00, $00, $00, $00, $00, $00
		.byte		$00, $00, $00, $00, $00, $00, $00, $00

pointer1:
		.byte		$00, $03, $33, $33, $33, $33, $00, $00
		.byte		$00, $32, $22, $22, $22, $23, $30, $00
		.byte		$03, $24, $44, $44, $44, $42, $23, $00
		.byte		$32, $33, $11, $11, $11, $14, $23, $00
		.byte		$32, $31, $11, $11, $11, $14, $23, $00
		.byte		$32, $31, $11, $11, $11, $14, $23, $00
		.byte		$32, $31, $11, $11, $11, $14, $23, $00
		.byte		$32, $33, $11, $11, $11, $42, $33, $00
		.byte		$03, $23, $32, $34, $44, $22, $30, $00
		.byte		$00, $32, $23, $31, $11, $42, $30, $00
		.byte		$03, $24, $43, $11, $14, $23, $00, $00
		.byte		$32, $31, $14, $23, $32, $30, $00, $00
		.byte		$32, $33, $32, $32, $23, $00, $00, $00
		.byte		$03, $22, $23, $33, $30, $00, $00, $00
		.byte		$00, $33, $30, $00, $00, $00, $00, $00
		.byte		$00, $00, $00, $00, $00, $00, $00, $00
		.byte		$00, $00, $00, $00, $00, $00, $00, $00
		.byte		$00, $00, $00, $00, $00, $00, $00, $00
		.byte		$00, $00, $00, $00, $00, $00, $00, $00
		.byte		$00, $00, $00, $00, $00, $00, $00, $00
		.byte		$00, $00, $00, $00, $00, $00, $00, $00


		.data
;***FIXME	Protect from page boundary bug
jude_proxyptr:
		.word	$0000


jude_temp0:
		.byte	$00


jude_actvvw:
		.dword	$00000000
jude_actvpg:
		.dword	$00000000
jude_avhrsx:
		.byte	$00
jude_avhrsy:
		.byte	$00

jude_proc:
		.byte	$00


jude_screenram:
		.dword	$00000000
jude_mousevic:
		.word	$0000
jude_mouseram:
		.dword	$00000000
jude_mouseptr:
		.dword	$00000000
jude_mousepal:
		.byte	$00
jude_mptrstate:
		.byte	$00

jude_screenw:
		.byte	$00
jude_screenh:
		.byte	$00
jude_cellsize:
		.byte	$00
jude_linesize:
		.dword	$00000000
jude_screensize:
		.dword	$00000000

jude_screeny0:
		.repeat	50, I
		.dword	$00000000
		.endrepeat

jude_coloury0:
		.repeat	50, I
		.dword	$00000000
		.endrepeat

jude_theme:
		.res	15, 0

jude_brdbak:
		.byte	$00

;-----------------------------------------------------------
;Mouse driver variables
;-----------------------------------------------------------
mouseOldPotX:        
	.byte    	0               	; Old hw counter values
mouseOldPotY:        
	.byte    	0

mouseDirTemp:	
	.byte 0
mouseXDir:	
	.byte 0
mouseYDir:	
	.byte 0
mouseXPosNew:           
	.word    	0               
mouseYPosNew:           
	.word    	0               
mouseXPosPending:           
	.word    	0               
mouseYPosPending:           
	.word    	0               
mouseXPos:
	.word    	0               	; Current mouse position, X
mouseYPos:
	.word    	0               	; Current mouse position, Y
mouseXMin:           
	.word    	0               	; X1 value of bounding box
mouseYMin:           
	.word    	0               	; Y1 value of bounding box
mouseXMax:           
	.word    	319               	; X2 value of bounding box
mouseYMax:           
	.word    	199           		; Y2 value of bounding box
mouseButtons:        
	.byte    	0               	; button status bits
mouseButtonsOld:
	.byte		0
mouseBtnLClick:
	.byte		0
mouseBtnRClick:
	.byte		0
	
mouseOldValue:       
	.byte    	0               	; Temp for MoveCheck routine
mouseNewValue:       
	.byte    	0               	; Temp for MoveCheck routine

mouseCheck:
		.byte		$00
mouseTemp0:
		.byte		$00
mouseTemp1:
		.word		0

mouseCapture:
		.byte		$00
mouseCapCtrl:
			.word	$0000
mouseCapMove:
			.word	$0000
mouseCapClick:
			.word	$0000

mouseXCol:
	.byte		$00
mouseYRow:
	.byte		$00
mouseXCell:
	.byte		$00
mouseYCell:
	.byte		$00


keysBuffer0:
	.res	16, $00

keysIdx:
	.byte	$00


judePickElem:
		.dword $00000000
judeMsePElem:
		.dword $00000000
judeDownElem:
		.dword $00000000
judeActvElem:
		.dword $00000000

judePBlinkDelay:
		.byte	$00
judePBlinkState:
		.byte	$00