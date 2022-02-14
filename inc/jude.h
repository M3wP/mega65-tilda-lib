//===========================================================
//Jude
//===========================================================
//
// Project: Tilda
//
// Simple text-based GUI system and widget library.
//
// (c) Daniel England 2022, All Rights Reserved.
//
// I intend to release this under LGPL 3?
//
//-----------------------------------------------------------
//
// Jude implements a simple, text-based GUI system and some
// widget primitives.  A type of inheritance and simple
// polymorphism is used to implement behaviours.
//
// Jude expands on the object system of Karl Jr to define the
// UI elements.  The heirarchy is as so:
//
//				UINTERFACE
//				|
//				+VIEW
//				  |
//				  +LAYER
//				  |
//				  +BAR
//				  | |
//				  | >LAYER
//				  | |
//				  | +CONTROL
//				  |
//				  +PAGE
//				    |
//				    +PANEL
//				      |
//				      >LAYER
//				      |
//				      +CONTROL
//
// A HAL has yet to be implemented.  Some features of this
// module should be moved into another (or that) module as
// functional units.  Namely these features are IRQ, Mouse
// and Keyboard/Text and possibly the Cursor/Pointer.  Some
// abstraction for the Screen is desireable but I'm uncertain
// how it could be easily achieved.
//
// I have purposefully not used messages or a mechanism of
// creating run-time indexes of changes/updates and controls
// because doing so would introduce hard limits on many
// things and given there is no memory manager, would make C
// integration more difficult.
//
// See Karl Jr for further information.
//
//===========================================================

#ifdef	INCLUDE_JUDE_H
#else
#define	INCLUDE_JUDE_H

#include	"karljr.h"


#define	CLR_BACK		0x00FD		//Background on C64
#define	CLR_EMPTY		0x00FE		//Border on C64
#define	CLR_CURSOR		0x00FF		
#define	CLR_TEXT		0x0000
#define	CLR_FOCUS		0x0001
#define	CLR_INSET		0x0002
#define	CLR_FACE		0x0003
#define CLR_SHADOW		0x0004
#define CLR_PAPER		0x0005
#define CLR_MONEY		0x0006
#define	CLR_ITEM		0x0007
#define CLR_INFORM		0x0008
#define CLR_ACCEPT		0x0009
#define CLR_APPLY		0x000A
#define CLR_ABORT		0x000B

#define CLR_INTN_THME	0x0000		//Theme colour
#define CLR_SYSS_TEXT	0x1000		//Specific system text colour
#define CLR_SYSS_CTRL	0x2000		//Specific system control colour 


#define MPTR_NONE		0xFF
#define	MPTR_NORMAL		0x00
#define	MPTR_WAIT		0x01



typedef	struct	THEME {
		karlName_t		_name;
		byte			_data[15];
	} judeTheme_t;


typedef	struct	UINTERFACE {
		karlUnit_t		_unit;

		karlFarPtr_t	mouseloc;
		karlFarPtr_t	mptrloc;
		byte			mousepal;

		karlFarPtr_t	views_p;
		byte			viewscnt;
	} judeUInterface_t;


typedef	struct	VIEW {
		karlObject_t		_object;

		byte			width;
		byte			height;

		karlFarPtr_t	location;
		byte			cellsize;

		karlFarPtr_t	layers_p;
		byte			layerscnt;

		karlFarPtr_t	bars_p;
		byte			barscnt;

		karlFarPtr_t	actvpage;
		karlFarPtr_t	pages_p;
		byte			pagescnt;

		word			linelen;
	} judeView_t;

typedef	struct	LAYER {
		karlObject_t	_object;

		byte			width;
		word			offset;
		byte			transparent;
		byte			background;
	} judeLayer_t;


typedef	struct	ELEMENT {
		karlObject_t	_object;

//	Function calls
		EVENTPTR		present;
		EVENTPTR		keypress;

//	Data items
		karlFarPtr_t	owner;
		word			colour;
		byte			posx;
		byte			posy;
		byte			width;
		byte			height;
	} judeElement_t;

typedef	struct	PANEL {
		judeElement_t	_element;

		karlFarPtr_t	layer_p;

		karlFarPtr_t	controls_p;
		byte			controlscnt;
	} judePanel_t;


typedef	struct	BAR {
		judePanel_t		_panel;
		byte			position;
	} judeBar_t;


typedef	struct	PAGE {
		judeElement_t	_element;

		karlFarPtr_t	pagenxt;
		karlFarPtr_t	pagebak;

		karlFarPtr_t	text_p;
		byte			textoffx;

		karlFarPtr_t	panels_p;
		byte			panelscnt;
	} judePage_t;


typedef	struct	CONTROL {
		judeElement_t	_element;
		karlFarPtr_t	text_p;
		byte			textoffx;
		byte			textaccel;
		byte			accelchar;
	} judeControl_t;

	


extern void	__fastcall__	JudeInit(void);
extern void	__fastcall__	JudeMain(void);


extern void	__fastcall__	JudeDeActivatePage(void);
extern void	__fastcall__	JudeActivatePage(void);
extern void	__fastcall__	JudeUnDownCtrl(void);
extern void	__fastcall__	JudeDownCtrl(void);
extern void	__fastcall__	JudeDeActivateCtrl(void);
extern void	__fastcall__	JudeActivateCtrl(void);

extern void __fastcall__	JudeSetPointer(byte pstate);


extern void	__fastcall__	JudeEraseBkg(word colour);
extern void	__fastcall__	JudeDrawAccel(void);

extern void	__fastcall__	JudeEnqueueKey(word key);
extern void	__fastcall__	JudeDequeueKey(void);

extern void	__fastcall__	JudeDefUIPrepare(void);
extern void	__fastcall__	JudeDefUIInit(void);
extern void	__fastcall__	JudeDefUIChange(void);
extern void	__fastcall__	JudeDefUIRelease(void);
extern void	__fastcall__	JudeDefViewPrepare(void);
extern void	__fastcall__	JudeDefViewInit(void);
extern void	__fastcall__	JudeDefViewChange(void);
extern void	__fastcall__	JudeDefViewRelease(void);
extern void	__fastcall__	JudeDefLyrPrepare(void);
extern void	__fastcall__	JudeDefLyrInit(void);
extern void	__fastcall__	JudeDefLyrChange(void);
extern void	__fastcall__	JudeDefLyrRelease(void);
extern void	__fastcall__	JudeDefPgePrepare(void);
extern void	__fastcall__	JudeDefPgeInit(void);
extern void	__fastcall__	JudeDefPgeChange(void);
extern void	__fastcall__	JudeDefPgeRelease(void);
extern void	__fastcall__	JudeDefPgePresent(void);
extern void	__fastcall__	JudeDefPnlPrepare(void);
extern void	__fastcall__	JudeDefPnlInit(void);
extern void	__fastcall__	JudeDefPnlChange(void);
extern void	__fastcall__	JudeDefPnlRelease(void);
extern void	__fastcall__	JudeDefPnlPresent(void);

extern byte	__fastcall__	JudeLogClrToSys(word colour);
extern void	__fastcall__	_JudeLogClrIsReverse(word colour);
extern void	__fastcall__	_JudeViewInit(void);
extern void	__fastcall__	_JudeEraseLine(void);
extern void	__fastcall__	_JudeDrawText(void);
extern void	__fastcall__	_JudeDrawTextDirect(void);

extern void __fastcall__	_JudeProcessAccelerators(void);
extern void __fastcall__	_JudeMoveActiveControl(void);

extern void	JudeViewInit(karlFarPtr_t *view);
extern void	JudeEraseLine(byte w, byte x, byte y, word colour);
extern void JudeDrawText(word colour, byte indent, byte mwidth, byte docont);
extern void JudeDrawTextDirect(word colour, byte indent, byte mwidth, byte docont,
			byte x, byte y, byte offs, unsigned long text);

extern byte	JudeLogClrIsReverse(word colour);

extern byte mouseXCol;
extern byte mouseYRow;

#endif