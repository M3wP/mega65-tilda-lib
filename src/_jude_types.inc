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
; Jude implements a simple, text-based GUI system and some
; widget primitives.  A type of inheritance and simple
; polymorphism is used to implement behaviours.
;
; Jude expands on the object system of Karl Jr to define the
; UI elements.  The heirarchy is as so:
;
;				UINTERFACE
;				|
;				+VIEW
;				  |
;				  +LAYER
;				  |
;				  +BAR
;				  | |
;				  | >LAYER
;				  | |
;				  | +CONTROL
;				  |
;				  +PAGE
;				    |
;				    +PANEL
;				      |
;				      >LAYER
;				      |
;				      +CONTROL
;
; A HAL has yet to be implemented.  Some features of this
; module should be moved into another (or that) module as
; functional units.  Namely these features are IRQ, Mouse
; and Keyboard/Text and possibly the Cursor/Pointer.  Some
; abstraction for the Screen is desireable but I'm uncertain
; how it could be easily achieved.
;
; I have purposefully not used messages or a mechanism of
; creating run-time indexes of changes/updates and controls
; because doing so would introduce hard limits on many
; things and given there is no memory manager, would make C
; integration more difficult.
;
; See Karl Jr for further information.
;
;===========================================================

	.ifdef INCLUDE_JUDE_TYPES_INC

	.else

	.define	INCLUDE_JUDE_TYPES_INC $01


	.define	CLR_BACK		$00FD		;Background on C64
	.define	CLR_EMPTY		$00FE		;Border on C64
	.define	CLR_CURSOR		$00FF		
	.define	CLR_TEXT		$0000
	.define	CLR_FOCUS		$0001
	.define	CLR_INSET		$0002
	.define	CLR_FACE		$0003
	.define CLR_SHADOW		$0004
	.define CLR_PAPER		$0005
	.define CLR_MONEY		$0006
	.define	CLR_ITEM		$0007
	.define CLR_INFORM		$0008
	.define CLR_ACCEPT		$0009
	.define CLR_APPLY		$000A
	.define CLR_ABORT		$000B

	.define CLR_INTN_THME	$0000		;Theme colour
	.define CLR_SYSS_TEXT	$1000		;Specific system text colour
	.define CLR_SYSS_CTRL	$2000		;Specific system control colour 

	.define MPTR_NONE		$FF
	.define	MPTR_NORMAL		$00
	.define	MPTR_WAIT		$01


	.struct	THEME
		_name		.tag	NAME
		_data		.res	15
	.endstruct


	.struct	UINTERFACE
		_unit		.tag	UNIT

		mouseloc	.tag	FARPTR
		mptrloc		.tag	FARPTR
		mousepal	.byte

		views_p		.tag	FARPTR
		viewscnt	.byte
	.endstruct


	.struct	VIEW
		_object		.tag	OBJECT

		width		.byte
		height		.byte

		location	.tag	FARPTR
		cellsize	.byte

		layers_p	.tag	FARPTR
		layerscnt	.byte

		bars_p		.tag	FARPTR
		barscnt		.byte

		actvpage_p	.tag	FARPTR
		pages_p		.tag	FARPTR
		pagescnt	.byte

		linelen		.word
	.endstruct

	.struct	LAYER
		_object		.tag	OBJECT

		width		.byte
		offset		.word
		transparent	.byte
		background	.byte
	.endstruct


	.struct	ELEMENT
		_object		.tag	OBJECT

;	Function calls
		present		.tag	EVENTPTR
		keypress	.tag	EVENTPTR

;	Data items
		owner		.tag	FARPTR
		colour		.word
		posx		.byte
		posy		.byte
		width		.byte
		height		.byte
	.endstruct

	.struct	CONTROL
		_element	.tag 	ELEMENT
		text_p		.tag	FARPTR
		textoffx	.byte
		textaccel	.byte
		accelchar	.byte
	.endstruct

	
	.struct	PANEL
		_element	.tag	ELEMENT

		layer_p		.tag	FARPTR

		controls_p	.tag	FARPTR
		controlscnt	.byte
	.endstruct


	.struct	BAR
		_panel		.tag	PANEL
		position	.byte
	.endstruct

	.struct	TABBAR
		_bar		.tag	BAR
	.endstruct

	.struct	BUTTONBAR
		_bar		.tag	BAR
	.endstruct

	.struct	BROWSEBAR
		_bar		.tag	BAR
	.endstruct


	.struct PAGE
		_element	.tag	ELEMENT

		pagenxt_p		.tag	FARPTR
		pagebak_p		.tag	FARPTR

		text_p		.tag	FARPTR
		textoffx	.byte

		panels_p	.tag	FARPTR
		panelscnt	.byte
	.endstruct


	.struct	BUTTONCTRL
		_control	.tag	CONTROL
	.endstruct

	.struct LABELCTRL
		_control	.tag 	CONTROL
		actvctrl_p	.tag	FARPTR
	.endstruct

	.struct	PAGEBTNCTRL
		_control	.tag	CONTROL
		actvpage_p	.tag	FARPTR
	.endstruct

	.struct	EDITCTRL
		_control	.tag	CONTROL
		textsz		.byte
		textmaxsz	.byte
	.endstruct

	.struct	RADIOGRPCTRL
		_control	.tag	CONTROL

		controls_p	.tag	FARPTR
		controlscnt	.byte

		labelctrl	.tag	FARPTR
	.endstruct

	.struct	RADIOBTNCTRL
		_control	.tag	CONTROL

		groupctrl_p	.tag	FARPTR
	.endstruct

	.endif