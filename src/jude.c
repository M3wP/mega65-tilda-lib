#include	"jude.h"

void	JudeViewInit(karlFarPtr_t *view) {
	zreg0wl = view->loword;
	zreg0wh = view->hiword;

	_JudeViewInit();
}

void	JudeEraseLine(byte w, byte x, byte y, word colour) {
//	IN	.A,.X		colour
//	IN	zregAb3		Max width
//	IN	zregBb1		x pos
//	IN	zregBb2		y pos

	zregAwl = colour;
	zregBb1 = x;
	zregBb2 = y;
	zregAb3 = w;

	_JudeEraseLine();
}


void 	JudeDrawText(word colour, byte indent, byte mwidth, byte docont) {
//	IN	zregAwl		Colour
//	IN	zregAb2		Indent
//	IN	zregAb3		Max width
//	IN	zregBb0		Do cont char if opt

	zregAwl = colour;
	zregAb2 = indent;
	zregAb3 = mwidth;
	zregBb0 = docont;

	_JudeDrawText();
}

void	JudeDrawTextDirect(word colour, byte indent, byte mwidth, byte docont,
			byte x, byte y, byte offs, unsigned long text) {
	zregAwl = colour;
	zregAb2 = indent;
	zregAb3 = mwidth;
	zregBb0 = docont;
	zregBb1 = x;
	zregBb2 = y;
	zregCb0 = offs;

	zregD = text;

	_JudeDrawTextDirect();
}



byte	JudeLogClrIsReverse(word colour) {
	_JudeLogClrIsReverse(colour);
	__asm__	("BCS %g", isreverse);

	return 0;

isreverse:

	return 1;
}