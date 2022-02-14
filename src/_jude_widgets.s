;===========================================================
	.include	"_karljr_types.inc"
	.include	"_jude_types.inc"
;===========================================================


;===========================================================
	.export		_JudeDefCtlPrepare
	.export		_JudeDefCtlInit
	.export		_JudeDefCtlChange
	.export		_JudeDefCtlRelease
	.export		_JudeDefCtlPresent
	.export		_JudeDefCtlKeypress
	.export		_JudeDefEdtPresent
	.export		_JudeDefEdtKeypress

	.export		_JudeDefLblChange

	.export		_JudeDefPBtChange
	.export		_JudeDefPBtPresent

	.export		_JudeDefRGpChange
	.export		_JudeDefRBtChange

	.export		_JudeRGroupReset
;===========================================================


;===========================================================
	.import		_JudeActivatePage

	.import		_JudeUnDownCtrl
	.import		_JudeDownCtrl
	.import		_JudeDeActivateCtrl
	.import		_JudeActivateCtrl
	.import		_JudeEraseBkg
	.import		__JudeDrawText
	.import		__JudeDrawTextDirect
	.import		_JudeDrawAccel
	.import		_JudeLogClrToSys
	.import		__JudeLogClrIsReverse
	.import		_JudeEnqueueKey
	.import		_JudeDequeueKey

	.import		jude_actvpg
	.import		jude_cellsize
	.import		jude_coloury0
	.import		jude_screeny0
	.import		judeDownElem

	.import		_karl_errorno
	.import		_KarlObjExcludeState
	.import		_KarlObjIncludeState
	.import		__KarlObjIncStateEx
;===========================================================


;===========================================================
	.code
;===========================================================

;-----------------------------------------------------------
_JudeDefCtlPrepare:
;-----------------------------------------------------------
;		LDA	#$01
;		STA	zreg2b3
		LDA	#STATE_PREPARED
		JSR	_KarlObjIncludeState

		LDA	#<STATE_EXPRESENT
		LDX	#>STATE_EXPRESENT
		LDY	#$00
		JSR	__KarlObjIncStateEx

		LDA	#$00
		STA	_karl_errorno

		RTS


;-----------------------------------------------------------
_JudeDefCtlInit:
;-----------------------------------------------------------
		LDA	#$00
		STA	_karl_errorno

		RTS


;-----------------------------------------------------------
_JudeDefCtlChange:
;-----------------------------------------------------------
		LDZ	#OBJECT::state
		NOP
		LDA	(zptrself), Z
		AND	#STATE_CHANGED
		BEQ	@exit

		LDA	#$00
		STA	zregAb0

		NOP
		LDA	(zptrself), Z
;		LDZ	#OBJECT::oldstate + 1
;		NOP
;		STA	(zptrself), Z
;		LDZ	#OBJECT::state
		AND	#STATE_DOWN
		BEQ	@dirty

		LDA	#$01
		STA	zregAb0
		
		LDZ	#OBJECT::options
		NOP
		LDA	(zptrself), Z
		AND	#OPT_DOWNCAPTURE
		BNE	@dirty

		LDZ	#OBJECT::state
		NOP
		LDA	(zptrself), Z
		AND	#($FF ^ STATE_DOWN)
		STA	(zptrself), Z

		MvDWZ	judeDownElem

@dirty:
		LDA	#STATE_CHANGED
		JSR	_KarlObjExcludeState

		LDZ	#OBJECT::options
		
		LDA	zregAb0
		BEQ	@cont1

@auto:
		NOP
		LDA	(zptrself), Z
		AND	#OPT_AUTOCHECK
		BEQ	@cont1
		
		LDZ	#OBJECT::tag
		NOP
		LDA	(zptrself), Z
		BEQ	@check

		LDZ	#OBJECT::options + 1
		NOP
		LDA	(zptrself), Z

		DEZ

		AND	#>OPT_NOAUTOCHKOF
		BNE	@cont1

		LDZ	#OBJECT::tag
		LDA	#$00
		JMP	@cont0

@check:
		LDA	#$01
		
@cont0:
		NOP
		STA	(zptrself), Z
		
		LDZ	#OBJECT::options
@cont1:
		NOP
		LDA	(zptrself), Z
		AND	#OPT_NOAUTOINVL
		BNE	@exit

;		LDA	#$01
;		STA	zreg2b3
		LDA	#STATE_DIRTY
		JSR	_KarlObjIncludeState

@exit:
		LDA	#$00
		STA	_karl_errorno

		RTS


;-----------------------------------------------------------
_JudeDefCtlRelease:
;-----------------------------------------------------------
		LDA	#$00
		STA	_karl_errorno

		RTS


;-----------------------------------------------------------
_JudeDefCtlPresent:
;-----------------------------------------------------------
		LDZ	#OBJECT::state
		NOP
		LDA	(zptrself), Z

		STA	zregAb0

		AND	#STATE_VISIBLE
		BNE	@present
		
		JMP	@exit

@present:
		LDA	zregAb0
		AND	#STATE_ENABLED
		BNE	@checkpick
		
		LDA	#<CLR_SHADOW
		LDX	#>CLR_SHADOW
		JMP	@draw
		
@checkpick:
;		LDA	zregAb0				;Check if picked
;		AND	#STATE_PICKED
;		BEQ	@checkactv
;		LDA	zregAb0				;Check if its not active
;		AND	#STATE_ACTIVE
;		BNE	@normal

		LDA	zregAb0				;Check if picked
		BIT	#STATE_PICKED
		BEQ	@checkactv
;		LDA	zregAb0				;Check if its not active
		BIT	#STATE_ACTIVE
		BNE	@normal


@picked:
		LDZ	#ELEMENT::colour + 1;Check its not already FOCUS
		NOP
		LDA	(zptrself), Z

		CMP	#>CLR_FOCUS
		BNE	@pickednrm

		DEZ
		NOP
		LDA	(zptrself), Z

		CMP	#<CLR_FOCUS
		BNE	@pickednrm
		
		LDA	#<CLR_FACE
		LDX	#>CLR_FACE
		JMP	@draw

@pickednrm:
		LDA	#<CLR_FOCUS
		LDX	#>CLR_FOCUS
		JMP	@draw

@checkactv:
		LDA	zregAb0
		AND	#STATE_ACTIVE
		BNE	@picked			;Make it the same as picked
		
@normal:
		LDZ	#ELEMENT::colour + 1
		NOP
		LDA	(zptrself), Z
		TAX
		DEZ
		NOP
		LDA	(zptrself), Z
		
@draw:
		STA	zregAb0
		STX	zregAb1

		JSR	_JudeEraseBkg

		LDA	#$00
		STA	zregAb2

		LDZ	#CONTROL::textoffx
		NOP
		LDA	(zptrself), Z
		STA	zregAb3

		LDZ	#ELEMENT::width
		NOP
		LDA	(zptrself), Z
		
		SEC
		SBC	zregAb3
		STA	zregAb3

		LDA	#$01
		STA	zregBb0

		JSR	__JudeDrawText

		JSR	_JudeDrawAccel
		
		LDZ	#OBJECT::options
		NOP
		LDA	(zptrself), Z
		AND	#OPT_AUTOCHECK
		BEQ	@exit
		
		LDZ	#OBJECT::tag
		NOP
		LDA	(zptrself), Z
		BEQ	@exit
		
		LDZ	#ELEMENT::posx
		NOP
		LDA	(zptrself), Z

		LDX	jude_cellsize
		CPX	#$02
		BNE	@xcont

		ASL

@xcont:
;		STA	zregBb1
		STA	zregBb3
		


		INZ
		NOP
		LDA	(zptrself), Z
		STA	zregBb2
;		INZ
;		NOP
;		LDA	(zptrself), Z
;		TAX
;		DEX
;		DEX
;		TXA
;		STA	zregBb3
;		
;		LDA	zregBb1
;		CLC
;		ADC	zregBb3
;		STA	zregBb3
;		

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
		STA	zptrcolour		;screen ptr
		LDA	jude_coloury0 + 1, X
		STA	zptrcolour + 1
		LDA	jude_coloury0 + 2, X
		STA	zptrcolour + 2
		LDA	jude_coloury0 + 3, X
		STA	zptrcolour + 3
		
		LDA	#<CLR_TEXT
		LDX	#>CLR_TEXT
		JSR	_JudeLogClrToSys

		PHA

		LDZ	zregBb3

		LDA	#$51
		NOP
		STA	(zptrscreen), Z

		LDX	jude_cellsize
		CPX	#$02
		BNE	@clrcont

		INZ

@clrcont:
		PLA

		NOP
		STA	(zptrcolour), Z
		
@exit:
		LDA	#STATE_DIRTY
		JSR	_KarlObjExcludeState

		LDA	#$00
		STA	_karl_errorno

		RTS

;-----------------------------------------------------------
_JudeDefCtlKeypress:
;-----------------------------------------------------------
		LDA	#ERROR_NONE
		STA	_karl_errorno

		RTS


;-----------------------------------------------------------
_JudeDefLblChange:
;-----------------------------------------------------------
		LDZ	#OBJECT::state
		NOP
		LDA	(zptrself), Z

		PHA

		JSR	_JudeDefCtlChange

		PLA
		AND	#STATE_DOWN
		BEQ	@exit

		MvDWObjImm	zreg4, zptrself, LABELCTRL::actvctrl_p
		
		LDA	zreg4b0
		ORA	zreg4b1
		ORA	zreg4b2
		ORA	zreg4b3
		BEQ	@exit

		MvDWMem	zptrself, zreg4
		JSR	_JudeDownCtrl

@exit:
		RTS
		

;-----------------------------------------------------------
_JudeDefPBtChange:
;-----------------------------------------------------------
		LDZ	#OBJECT::state
		NOP
		LDA	(zptrself), Z

		PHA

		JSR	_JudeDefCtlChange

		PLA
		AND	#STATE_DOWN
		BEQ	@exit

		MvDWObjImm	zreg4, zptrself, PAGEBTNCTRL::actvpage_p
		
		LDA	zreg4b0
		ORA	zreg4b1
		ORA	zreg4b2
		ORA	zreg4b3
		BEQ	@exit

		MvDWMem	zptrself, zreg4
		JSR	_JudeActivatePage

@exit:
		RTS


;-----------------------------------------------------------
_JudeDefPBtPresent:
;-----------------------------------------------------------
		MvDWObjImm	zreg4, zptrself, PAGEBTNCTRL::actvpage_p
		
		LDQMem	zreg4
		CPQMem	jude_actvpg

		BNE	@unset

		LDZ	#ELEMENT::colour
		LDA	#<CLR_FOCUS
		NOP
		STA	(zptrself), Z
		INZ
		LDA	#>CLR_FOCUS
		NOP
		STA	(zptrself), Z

		BRA	@default

@unset:
		LDZ	#ELEMENT::colour
		LDA	#<CLR_FACE
		NOP
		STA	(zptrself), Z
		INZ
		LDA	#>CLR_FACE
		NOP
		STA	(zptrself), Z

@default:
		JMP	_JudeDefCtlPresent



;-----------------------------------------------------------
_JudeDefEdtPresent:
;-----------------------------------------------------------
		LDZ	#OBJECT::state
		NOP
		LDA	(zptrself), Z
		AND	#STATE_DOWN
		BEQ	@normal

		LDA	#<CLR_TEXT
		STA	zregAb0
		LDX	#>CLR_TEXT
		STX	zregAb1

		JSR	_JudeEraseBkg

		LDZ	#CONTROL::textoffx
		NOP
		LDA	(zptrself), Z
		STA	zregAb3

		LDZ	#ELEMENT::width
		NOP
		LDA	(zptrself), Z
		
		SEC
		SBC	zregAb3
		STA	zregAb3

		DEC	zregAb3

		LDZ	#EDITCTRL::textsz
		NOP
		LDA	(zptrself), Z
		STA	zregAb2

		LDA	zregAb3
		CMP	zregAb2
		BCS	@noindent

		SEC
		LDA	zregAb2
		SBC	zregAb3
		STA	zregAb2
	
		JMP	@text

@noindent:
		LDA	#$00
		STA	zregAb2

@text:
		LDA	#$00
		STA	zregBb0

;	IN	zregAwl		Colour
;	IN	zregAb2		Indent
;	IN	zregAb3		Max width
;	IN	zregBb0		Do cont char if opt
		JSR	__JudeDrawText
		
		RTS

@normal:
		JMP	_JudeDefCtlPresent


;-----------------------------------------------------------
_JudeDefEdtKeypress:
;-----------------------------------------------------------
		LDZ	#OBJECT::state
		NOP
		LDA	(zptrself), Z
		AND	#STATE_DOWN
		BNE	@downkeys

		RTS

@downkeys:
		LDA	zvalkey
		CMP	#KEY_C64_CDOWN
		BEQ	@navkey

		CMP	#KEY_ASC_CR
		BNE	@input

		JSR	_JudeUnDownCtrl
		RTS

@navkey:
		JSR	_JudeUnDownCtrl
		

@input:
		MvDWObjImm	zregA, zptrself, CONTROL::text_p

		LDZ	#EDITCTRL::textsz
		NOP
		LDA	(zptrself), Z
		STA	zregBb0

		LDA	zvalkey
		CMP	#KEY_C64_DEL
		BEQ	@delete

		LDZ	#EDITCTRL::textmaxsz
		NOP
		LDA	(zptrself), Z
		CMP	zregBb0
		BEQ	@exit

		LDZ	zregBb0

		LDA	zvalkey
		NOP
		STA	(zregA), Z
		
		INZ
		LDA	#$00
		NOP
		STA	(zregA), Z
		TZA

@invalidate:
		LDZ	#EDITCTRL::textsz
		NOP
		STA	(zptrself), Z

;		LDA	#$00
;		STA	zreg2b3
		LDA	#(STATE_DIRTY | STATE_CHANGED)
		JSR	_KarlObjIncludeState

@exit:
		JMP	_JudeDefCtlKeypress

@delete:
		LDZ	zregBb0
		BEQ	@exit

		DEZ

		LDA	#$00
		NOP
		STA	(zregA), Z
		
		TZA
		
		JMP	@invalidate


;-----------------------------------------------------------
_JudeRGroupReset:
;-----------------------------------------------------------
		STA	zregDb1

		LDA	#$00
		STA	zregDb0
		STA	zregDb3

		MvDWMem	zregA, zptrself

		MvDWObjImm	zregC, zregA, RADIOGRPCTRL::controls_p

		LDZ	#RADIOGRPCTRL::controlscnt
		NOP
		LDA	(zregA), Z
		STA	zregDb2

@loop:
		LDZ	#$00
		LDQIndDWZ zregC
		STQMem	zregE

		LDQMem	zregC
		CLC
		ADQMem	zvaltemp0
		STQMem	zregC

		LDA	zregDb0
		CMP	zregDb1
		BEQ	@found

		LDZ	#OBJECT::tag
		LDA	#$00

@update:
		NOP
		STA	(zregE), Z

		MvDWMem zptrself, zregE

		LDA	#STATE_CHANGED | STATE_DIRTY
		JSR	_KarlObjIncludeState

@next:
		INC	zregDb0

		LDA	zregDb0
		CMP	zregDb2
		BNE	@loop

		BRA	@label

@found:
		STA	zregDb3

		LDQMem	zregC
		STQMem	zregF

		LDZ	#OBJECT::tag
		LDA	#$01
		BRA	@update

@label:
		LDA	zregDb3
		CMP	zregDb1
		BNE	@exit

		INC zregDb3

		MvDWObjImm	zregB, zregA, RADIOGRPCTRL::labelctrl

		LDA	zregBb0
		ORA	zregBb1
		ORA	zregBb2
		ORA	zregBb3
		BEQ	@exit

		LDA	zregDb3
		CMP	zregDb2
		BCC	@this

		MvDWObjImm	zregF, zregA, RADIOGRPCTRL::controls_p

@this:
		LDZ	#$00
		LDQIndDWZ zregF
		STQMem	zregE

@set:
		LDZ	#LABELCTRL::actvctrl_p

		LDA	zregEb0
		NOP
		STA	(zregB), Z
		INZ
		LDA	zregEb1
		NOP
		STA	(zregB), Z
		INZ
		LDA	zregEb2
		NOP
		STA	(zregB), Z
		INZ
		LDA	zregEb3
		NOP
		STA	(zregB), Z


@exit:
		RTS

;-----------------------------------------------------------
_JudeDefRGpChange:
;-----------------------------------------------------------
		LDZ	#OBJECT::state
		NOP
		LDA	(zptrself), Z

		LDZ	#OBJECT::oldstate + 1
		NOP
		STA	(zptrself), Z

		JSR	_JudeDefCtlChange

		LDZ	#OBJECT::tag
		NOP
		LDA	(zptrself), Z

		BEQ	@exit

		LDZ	#OBJECT::oldstate + 1
		NOP
		LDA	(zptrself), Z

		AND	#STATE_DOWN
		BEQ	@exit

		MvDWMem	zregA, zptrself
		JSR	__JudeUpdateRadioGroup

@exit:
		LDA	#$00
		STA	_karl_errorno

		RTS


;-----------------------------------------------------------
__JudeUpdateRadioGroup:
;-----------------------------------------------------------
		MvDWMem	zregB, zptrself

;	Unset all other than zregB in group
;		Store index of zregB
		MvDWObjImm	zregC, zregA, RADIOGRPCTRL::controls_p

		LDA	#$00
		STA	zregDb0

		LDA	#$FF
		STA	zregDb1

		LDZ	#RADIOGRPCTRL::controlscnt
		NOP
		LDA	(zregA), Z
		STA	zregDb2

@loop:
		LDZ	#$00
		LDQIndDWZ zregC
		
		CPQMem	zregB
		BEQ	@found

		STQMem	zregE

		LDZ	#OBJECT::tag

		LDA	#$00
		NOP
		STA	(zregE), Z

		MvDWMem zptrself, zregE

		LDA	#STATE_CHANGED | STATE_DIRTY
		JSR	_KarlObjIncludeState

		LDQMem	zregC
		CLC
		ADQMem	zvaltemp0
		STQMem	zregC

@next:
		INC	zregDb0

		LDA	zregDb0
		CMP	zregDb2
		BNE	@loop

		JMP	@cont

@found:
		LDQMem	zregC
		CLC
		ADQMem	zvaltemp0
		STQMem	zregC
		STQMem	zregF

		LDA	zregDb0
		STA	zregDb1

		JMP	@next

@cont:
		INC	zregDb1

		LDA	zregDb1
		CMP	zregDb2
		BCC	@set

		MvDWObjImm	zregF, zregA, RADIOGRPCTRL::controls_p

@set:
		LDZ	#$00
		LDQIndDWZ zregF
		STQMem	zregE

		MvDWObjImm	zregB, zregA, RADIOGRPCTRL::labelctrl

		LDA	zregBb0
		ORA	zregBb1
		ORA	zregBb2
		ORA	zregBb3
		BEQ	@exit

		LDZ	#LABELCTRL::actvctrl_p

		LDA	zregEb0
		NOP
		STA	(zregB), Z
		INZ
		LDA	zregEb1
		NOP
		STA	(zregB), Z
		INZ
		LDA	zregEb2
		NOP
		STA	(zregB), Z
		INZ
		LDA	zregEb3
		NOP
		STA	(zregB), Z

@exit:
		RTS


;-----------------------------------------------------------
_JudeDefRBtChange:
;-----------------------------------------------------------
		LDZ	#OBJECT::state
		NOP
		LDA	(zptrself), Z

		LDZ	#OBJECT::oldstate + 1
		NOP
		STA	(zptrself), Z

		JSR	_JudeDefCtlChange

		LDZ	#OBJECT::tag
		NOP
		LDA	(zptrself), Z

		BEQ	@exit

		LDZ	#OBJECT::oldstate + 1
		NOP
		LDA	(zptrself), Z

		AND	#STATE_DOWN
		BEQ	@exit

		MvDWObjImm	zregA, zptrself, RADIOBTNCTRL::groupctrl_p
		JSR	__JudeUpdateRadioGroup

@exit:
		LDA	#$00
		STA	_karl_errorno

		RTS