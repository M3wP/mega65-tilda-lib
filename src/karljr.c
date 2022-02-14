#include	"karljr.h"


void	KarlModAttach(karlFarPtr_t *module) {
	zreg0wl = module->loword;
	zreg0wh = module->hiword;
	_KarlModAttach();
}


void	KarlObjExcStateEx(byte changed, word state) {
	zreg0wl = state;
	zreg0b2 = changed;

	_KarlObjExcStateEx();
}

void	KarlObjIncStateEx(byte changed, word state) {
	zreg0wl = state;
	zreg0b2 = changed;

	_KarlObjIncStateEx();
}
