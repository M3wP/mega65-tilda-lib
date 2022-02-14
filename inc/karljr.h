//===========================================================
//Karl Jr
//===========================================================
//
// Project: Tilda
//
// Simple object life-time management.
//
// (c) Daniel England 2022, All Rights Reserved.
//
// I intend to release this under LGPL 3?
//
//-----------------------------------------------------------
//
// Karl Jr allows modules and units to be used and the 
// objects there-in managed.
//
// Unfortunately, Karl Jr has no memory management...  The 
// actual name-space is yet to be defined.
//
// Karl Jr is standing-in for a HAL module at this time, 
// also -- probably to be called Downe, the memory manager
// likely Revere.
//
// Objects are stored in a heirarchy.  Modules contain units
// which when "sub-classed" contain objects.  Modules can be 
// attached and (eventually) detached from the system.  A 
// name-space and browsing capabilities are future 
// enhancements.
//
//				MODULE
//				|
//				+UNIT
//
//===========================================================

#ifdef	INCLUDE_KARLJR_H
#else
#define	INCLUDE_KARLJR_H

#define	SIZ_ZP_KARLJR (0x68)

typedef unsigned char byte;
typedef unsigned short word;
typedef unsigned long dword;

extern byte _zkarljr[SIZ_ZP_KARLJR];
#pragma zpsym ("_zkarljr");

#define	zptrself	*((dword *)&(_zkarljr[0x04]))
#define	zptrowner	*((dword *)&(_zkarljr[0x08]))
#define	zptrscreen	*((dword *)&(_zkarljr[0x0C]))	
#define zptrcolour	*((dword *)&(_zkarljr[0x10]))
#define	zptrtemp0	*((dword *)&(_zkarljr[0x14]))
#define	zptrtemp1	*((dword *)&(_zkarljr[0x18]))
#define	zptrtemp2	*((dword *)&(_zkarljr[0x1C]))

#define	zreg0	*((dword *)&(_zkarljr[0x20]))
#define	zreg0wl	*((word *)&(_zkarljr[0x20]))
#define	zreg0wh	*((word *)&(_zkarljr[0x22]))
#define	zreg0b0	*((byte *)&(_zkarljr[0x20]))
#define	zreg0b1	*((byte *)&(_zkarljr[0x21]))
#define	zreg0b2	*((byte *)&(_zkarljr[0x22]))
#define	zreg0b3	*((byte *)&(_zkarljr[0x23]))
#define	zreg1	*((dword *)&(_zkarljr[0x24]))
#define	zreg1wl	*((word *)&(_zkarljr[0x24]))
#define	zreg1wh	*((word *)&(_zkarljr[0x26]))
#define	zreg1b0	*((byte *)&(_zkarljr[0x24]))
#define	zreg1b1	*((byte *)&(_zkarljr[0x25]))
#define	zreg1b2	*((byte *)&(_zkarljr[0x26]))
#define	zreg1b3	*((byte *)&(_zkarljr[0x27]))
#define	zreg2	*((dword *)&(_zkarljr[0x28]))
#define	zreg2wl	*((word *)&(_zkarljr[0x28]))
#define	zreg2wh	*((word *)&(_zkarljr[0x2A]))
#define	zreg2b0	*((byte *)&(_zkarljr[0x28]))
#define	zreg2b1	*((byte *)&(_zkarljr[0x29]))
#define	zreg2b2	*((byte *)&(_zkarljr[0x2A]))
#define	zreg2b3	*((byte *)&(_zkarljr[0x2B]))
#define	zreg3	*((dword *)&(_zkarljr[0x2C]))
#define	zreg3wl	*((word *)&(_zkarljr[0x2C]))
#define	zreg3wh	*((word *)&(_zkarljr[0x2E]))
#define	zreg3b0	*((byte *)&(_zkarljr[0x2C]))
#define	zreg3b1	*((byte *)&(_zkarljr[0x2D]))
#define	zreg3b2	*((byte *)&(_zkarljr[0x2E]))
#define	zreg3b3	*((byte *)&(_zkarljr[0x2F]))

#define	zreg4	*((dword *)&(_zkarljr[0x30]))
#define	zreg4wl	*((word *)&(_zkarljr[0x30]))
#define	zreg4wh	*((word *)&(_zkarljr[0x32]))
#define	zreg4b0	*((byte *)&(_zkarljr[0x30]))
#define	zreg4b1	*((byte *)&(_zkarljr[0x31]))
#define	zreg4b2	*((byte *)&(_zkarljr[0x32]))
#define	zreg4b3	*((byte *)&(_zkarljr[0x33]))
#define	zreg5	*((dword *)&(_zkarljr[0x34]))
#define	zreg5wl	*((word *)&(_zkarljr[0x34]))
#define	zreg5wh	*((word *)&(_zkarljr[0x36]))
#define	zreg5b0	*((byte *)&(_zkarljr[0x34]))
#define	zreg5b1	*((byte *)&(_zkarljr[0x35]))
#define	zreg5b2	*((byte *)&(_zkarljr[0x36]))
#define	zreg5b3	*((byte *)&(_zkarljr[0x37]))
#define	zreg6	*((dword *)&(_zkarljr[0x38]))
#define	zreg6wl	*((word *)&(_zkarljr[0x38]))
#define	zreg6wh	*((word *)&(_zkarljr[0x3A]))
#define	zreg6b0	*((byte *)&(_zkarljr[0x38]))
#define	zreg6b1	*((byte *)&(_zkarljr[0x39]))
#define	zreg6b2	*((byte *)&(_zkarljr[0x3A]))
#define	zreg6b3	*((byte *)&(_zkarljr[0x3B]))
#define	zreg7	*((dword *)&(_zkarljr[0x3C]))
#define	zreg7wl	*((word *)&(_zkarljr[0x3C]))
#define	zreg7wh	*((word *)&(_zkarljr[0x3E]))
#define	zreg7b0	*((byte *)&(_zkarljr[0x3C]))
#define	zreg7b1	*((byte *)&(_zkarljr[0x3D]))
#define	zreg7b2	*((byte *)&(_zkarljr[0x3E]))
#define	zreg7b3	*((byte *)&(_zkarljr[0x3F]))

#define	zreg8	*((dword *)&(_zkarljr[0x40]))
#define	zreg8wl	*((word *)&(_zkarljr[0x40]))
#define	zreg8wh	*((word *)&(_zkarljr[0x42]))
#define	zreg8b0	*((byte *)&(_zkarljr[0x40]))
#define	zreg8b1	*((byte *)&(_zkarljr[0x41]))
#define	zreg8b2	*((byte *)&(_zkarljr[0x42]))
#define	zreg8b3	*((byte *)&(_zkarljr[0x43]))
#define	zreg9	*((dword *)&(_zkarljr[0x44]))
#define	zreg9wl	*((word *)&(_zkarljr[0x44]))
#define	zreg9wh	*((word *)&(_zkarljr[0x46]))
#define	zreg9b0	*((byte *)&(_zkarljr[0x44]))
#define	zreg9b1	*((byte *)&(_zkarljr[0x45]))
#define	zreg9b2	*((byte *)&(_zkarljr[0x46]))
#define	zreg9b3	*((byte *)&(_zkarljr[0x47]))
#define	zregA	*((dword *)&(_zkarljr[0x48]))
#define	zregAwl	*((word *)&(_zkarljr[0x48]))
#define	zregAwh	*((word *)&(_zkarljr[0x4A]))
#define	zregAb0	*((byte *)&(_zkarljr[0x48]))
#define	zregAb1	*((byte *)&(_zkarljr[0x49]))
#define	zregAb2	*((byte *)&(_zkarljr[0x4A]))
#define	zregAb3	*((byte *)&(_zkarljr[0x4B]))
#define	zregB	*((dword *)&(_zkarljr[0x4C]))
#define	zregBwl	*((word *)&(_zkarljr[0x4C]))
#define	zregBwh	*((word *)&(_zkarljr[0x4E]))
#define	zregBb0	*((byte *)&(_zkarljr[0x4C]))
#define	zregBb1	*((byte *)&(_zkarljr[0x4D]))
#define	zregBb2	*((byte *)&(_zkarljr[0x4E]))
#define	zregBb3	*((byte *)&(_zkarljr[0x4F]))

#define	zregC	*((dword *)&(_zkarljr[0x50]))
#define	zregCwl	*((word *)&(_zkarljr[0x50]))
#define	zregCwh	*((word *)&(_zkarljr[0x52]))
#define	zregCb0	*((byte *)&(_zkarljr[0x50]))
#define	zregCb1	*((byte *)&(_zkarljr[0x51]))
#define	zregCb2	*((byte *)&(_zkarljr[0x52]))
#define	zregCb3	*((byte *)&(_zkarljr[0x53]))
#define	zregD	*((dword *)&(_zkarljr[0x54]))
#define	zregDwl	*((word *)&(_zkarljr[0x54]))
#define	zregDwh	*((word *)&(_zkarljr[0x56]))
#define	zregDb0	*((byte *)&(_zkarljr[0x54]))
#define	zregDb1	*((byte *)&(_zkarljr[0x55]))
#define	zregDb2	*((byte *)&(_zkarljr[0x56]))
#define	zregDb3	*((byte *)&(_zkarljr[0x57]))
#define	zregE	*((dword *)&(_zkarljr[0x58]))
#define	zregEwl	*((word *)&(_zkarljr[0x58]))
#define	zregEwh	*((word *)&(_zkarljr[0x5A]))
#define	zregEb0	*((byte *)&(_zkarljr[0x58]))
#define	zregEb1	*((byte *)&(_zkarljr[0x59]))
#define	zregEb2	*((byte *)&(_zkarljr[0x5A]))
#define	zregEb3	*((byte *)&(_zkarljr[0x5B]))
#define	zregF	*((dword *)&(_zkarljr[0x5C]))
#define	zregFwl	*((word *)&(_zkarljr[0x5C]))
#define	zregFwh	*((word *)&(_zkarljr[0x5E]))
#define	zregFb0	*((byte *)&(_zkarljr[0x5C]))
#define	zregFb1	*((byte *)&(_zkarljr[0x5D]))
#define	zregFb2	*((byte *)&(_zkarljr[0x5E]))
#define	zregFb3	*((byte *)&(_zkarljr[0x5F]))

#define	zvaltemp0	*((dword *)&(_zkarljr[0x60]))
#define	zvalkey		*((dword *)&(_zkarljr[0x64]))


//#define	KEY_ASC_BKSPC	0x08
#define KEY_ASC_CR	0x0D

#define KEY_ASC_SPACE	0x20
#define KEY_ASC_EXMRK	0x21
#define KEY_ASC_DQUOTE	0x22
#define KEY_ASC_POUND	0x23

#define KEY_ASC_DOLLAR	0x24
#define KEY_ASC_PERCENT	0x25
#define KEY_ASC_AMP 	0x26
#define KEY_ASC_QUOTE	0x27
#define KEY_ASC_OBRCKT 	0x28
#define	KEY_ASC_CBRCKT	0x29
#define KEY_ASC_MULT	0x2A
#define KEY_ASC_PLUS	0x2B
#define KEY_ASC_COMMA	0x2C
#define KEY_ASC_MINUS	0x2D
#define KEY_ASC_STOP	0x2E
#define KEY_ASC_DIV	0x2F
#define KEY_ASC_0	0x30
#define KEY_ASC_1	0x31
#define KEY_ASC_2	0x32
#define KEY_ASC_3	0x33
#define KEY_ASC_4	0x34
#define KEY_ASC_5	0x35
#define KEY_ASC_6	0x36
#define KEY_ASC_7	0x37
#define KEY_ASC_8	0x38
#define KEY_ASC_9	0x39
#define KEY_ASC_COLON	0x3A
#define KEY_ASC_SCOLON	0x3B
#define KEY_ASC_LESSTH	0x3C
#define KEY_ASC_EQUALS	0x3D
#define	KEY_ASC_GRTRTH	0x3E
#define KEY_ASC_QMARK	0x3F
#define KEY_ASC_AT	0x40
#define KEY_ASC_A	0x41
#define KEY_ASC_B	0x42
#define KEY_ASC_C	0x43
#define KEY_ASC_D	0x44
#define KEY_ASC_E	0x45
#define KEY_ASC_F	0x46
#define KEY_ASC_G	0x47
#define KEY_ASC_H	0x48
#define KEY_ASC_I	0x49
#define KEY_ASC_J	0x4A
#define KEY_ASC_K	0x4B
#define KEY_ASC_L	0x4C
#define KEY_ASC_M	0x4D
#define KEY_ASC_N	0x4E
#define KEY_ASC_O	0x4F
#define KEY_ASC_P	0x50
#define KEY_ASC_Q	0x51
#define KEY_ASC_R	0x52
#define KEY_ASC_S	0x53
#define KEY_ASC_T	0x54
#define KEY_ASC_U	0x55
#define KEY_ASC_V	0x56
#define KEY_ASC_W	0x57
#define	KEY_ASC_X	0x58
#define KEY_ASC_Y	0x59
#define	KEY_ASC_Z	0x5A
#define	KEY_ASC_OSQRBR	0x5B
#define KEY_ASC_CSQRBR	0x5D

#define KEY_ASC_L_A	0x61
#define KEY_ASC_L_B	0x62
#define KEY_ASC_L_C	0x63
#define KEY_ASC_L_D	0x64
#define KEY_ASC_L_E	0x65
#define KEY_ASC_L_F	0x66
#define KEY_ASC_L_G	0x67
#define KEY_ASC_L_H	0x68
#define KEY_ASC_L_I	0x69
#define KEY_ASC_L_J	0x6A
#define KEY_ASC_L_K	0x6B
#define KEY_ASC_L_L	0x6C
#define KEY_ASC_L_M	0x6D
#define KEY_ASC_L_N	0x6E
#define KEY_ASC_L_O	0x6F
#define KEY_ASC_L_P	0x70
#define KEY_ASC_L_Q	0x71
#define KEY_ASC_L_R	0x72
#define KEY_ASC_L_S	0x73
#define KEY_ASC_L_T	0x74
#define KEY_ASC_L_U	0x75
#define KEY_ASC_L_V	0x76
#define KEY_ASC_L_W	0x77
#define	KEY_ASC_L_X	0x78
#define KEY_ASC_L_Y	0x79
#define	KEY_ASC_L_Z	0x7A


//Alternates
#define KEY_ASC_HASH	0x23		
#define KEY_ASC_LBRCKT 	0x28		
#define	KEY_ASC_RBRCKT	0x29		
#define KEY_ASC_FSLASH	0x2F		
#define	KEY_ASC_LSQRBR	0x5B		
#define KEY_ASC_RSQRBR	0x5D		

//Needs screen code xlat (no real char)
#define KEY_ASC_BSLASH	0x5C		
#define KEY_ASC_CARET	0x5E		
#define KEY_ASC_USCORE	0x5F		
#define KEY_ASC_BQUOTE	0x60		
#define KEY_ASC_OCRLYB	0x7B		
#define KEY_ASC_PIPE	0x7C		
#define KEY_ASC_CCRLYB	0x7D		
#define KEY_ASC_TILDE	0x7E		
//Alternate
#define KEY_ASC_LCRLYB	0x7B		
#define KEY_ASC_RCRLYB	0x7D		


#define KEY_C64_STOP	0x03
#define KEY_C64_HOME	0x13
#define KEY_C64_POUND	0xA3		
#define KEY_C64_ARRUP	0xAF		
#define KEY_C64_ARRLEFT	0x5F

#define	KEY_C64_CRIGHT	0x1D
#define	KEY_C64_CDOWN	0x11

#define	KEY_C64_DEL		0x14

#define KEY_M65_ESC		0x1B
#define KEY_M65_TAB		0x09

#define KEY_M65_NONE	0x00

#define	KEY_M65_F1		0xF1
#define	KEY_M65_F2		0xF2
#define	KEY_M65_F3		0xF3
#define	KEY_M65_F4		0xF4
#define	KEY_M65_F5		0xF5
#define	KEY_M65_F6		0xF6
#define	KEY_M65_F7		0xF7
#define	KEY_M65_F8		0xF8
#define	KEY_M65_F9		0xF9
#define	KEY_M65_F10		0xFA
#define	KEY_M65_F11		0xFB
#define	KEY_M65_F12		0xFC
#define	KEY_M65_F13		0xFD
#define	KEY_M65_F14		0xFE

#define	KEY_M65_HELP	0x1F


#define	KEY_MOD_SHFTR	0x01
#define	KEY_MOD_SHFTL	0x02
	
#define	KEY_MOD_SHIFT	0x03

#define	KEY_MOD_CTRL	0x04
#define	KEY_MOD_SYS		0x08
#define	KEY_MOD_ALT		0x10
#define	KEY_MOD_NSCRL	0x20
#define	KEY_MOD_CAPLK	0x40


#define STATE_CHANGED	0x80
#define STATE_DIRTY		0x40
#define STATE_PREPARED	0x20
#define STATE_VISIBLE	0x01
#define STATE_ENABLED	0x02
#define STATE_PICKED	0x04
#define STATE_ACTIVE	0x08
#define STATE_DOWN		0x10
#define STATE_EXPRESENT	0x0100

#define	STATE_DEFAULT	STATE_ENABLED
#define	STATE_DEFCTRL	(STATE_VISIBLE | STATE_ENABLED)

#define	OPT_NOAUTOINVL	0x01
#define	OPT_NONAVIGATE	0x02
#define OPT_NODOWNACTV	0x04
#define OPT_DOWNCAPTURE 0x10
#define	OPT_AUTOCHECK	0x20
#define OPT_TEXTACCEL2X	0x40
#define OPT_TEXTCONTMRK 0x80
#define OPT_NOAUTOCHKOF 0x0100
#define OPT_AUTOTRACK	0x0200

#define	ERROR_ABORT		0xFF
#define	ERROR_NONE		0x00
#define	ERROR_MODULE	0x10
#define	ERROR_UNIT		0x20
#define	ERROR_OBJECT	0x40
#define	ERROR_SYSTEM	0x80

#define	NEARTOEVENTPTR(__near) (word)((void (*)(void))&__near)
#define	EVENTPTRNULLREC 0x0000
#define NEARTOFARPTRREC(__near) (word)((void *)&__near), 0x0000
#define	FARPTRNULLREC	0x0000, 0x0000
#define	DWRDTOFARPTRREC(__loword, __hiword) __loword, __hiword


typedef	struct	FARPTR {
		word	loword;
		word	hiword;
	} karlFarPtr_t;

typedef union	DWFARPTR_U {
		dword	data;
		karlFarPtr_t ptr;
	} karlDWFarPtr_t;

typedef unsigned short	EVENTPTR;

typedef struct OBJECT {
//	Type details
		byte			size;
		karlFarPtr_t	parent;

//	Function calls
		EVENTPTR		prepare;
		EVENTPTR		initialise;
		EVENTPTR		change;
		EVENTPTR		release;

//	State information
		word			state;
		word			oldstate;
		word			options;

//	Data items
		word			tag;
	} karlObject_t;

typedef	char NAME[17];
typedef	NAME karlName_t; 

typedef	struct	NAMEDOBJECT {
		karlObject_t	_object;
		karlName_t		name;
	} karlNamedObject_t;

typedef	struct	MODULE {
		karlNamedObject_t	_named;

		karlFarPtr_t	units_p;
		byte			unitscnt;
	} karlModule_t;


typedef	struct UNIT {
		karlNamedObject_t	_named;
	} karlUnit_t;


extern	unsigned char karl_errorno;

extern void	__fastcall__	KarlInit(void);
extern void	__fastcall__	KarlASCIIToScreen(void);
extern void	__fastcall__	KarlGetLastError(void);
extern void	__fastcall__	KarlPanic(void);
extern void	__fastcall__	KarlClearZ(void);
extern void	__fastcall__	KarlIOFast(void);
extern void	__fastcall__	KarlObjExcludeState(byte state);
extern void	__fastcall__	KarlObjIncludeState(byte state);

extern void	__fastcall__	KarlDefModPrepare(void);
extern void	__fastcall__	KarlDefModInit(void);
extern void	__fastcall__	KarlDefModChange(void);
extern void	__fastcall__	KarlDefModRelease(void);

extern void	KarlModAttach(karlFarPtr_t *module);
extern void	KarlObjExcStateEx(byte changed, word state);
extern void	KarlObjIncStateEx(byte changed, word state);

extern void	__fastcall__	_KarlModAttach(void);
extern void	__fastcall__	_KarlObjExcStateEx(void);
extern void	__fastcall__	_KarlObjIncStateEx(void);


#endif