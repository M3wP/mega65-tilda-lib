#ifdef	INCLUDE_JUDE_WIDGETS_H
#else
#define	INCLUDE_JUDE_WIDGETS_H

#include	"jude.h"

typedef	struct	TABBAR {
		judeBar_t		_bar;
	} judeTabBar_t;

typedef	struct	BUTTONBAR {
		judeBar_t		_bar;
	} judeButtonBar_t;

typedef	struct	BROWSEBAR {
		judeBar_t		_bar;
	} judeBrowseBar_t;

typedef	struct	BUTTONCTRL {
		judeControl_t	_control;
	} judeButtonCtrl_t;

typedef	struct	LABELCTRL {
		judeControl_t	_control;
		karlFarPtr_t	actvctrl_p;
	} judeLabelCtrl_t;

typedef	struct	PAGEBTNCTRL {
		judeControl_t	_control;
		karlFarPtr_t	actvpage_p;
	} judePageBtnCtrl_t;

typedef	struct	EDITCTRL {
		judeControl_t	_control;
		byte			textsz;
		byte			textmaxsz;
	} judeEditCtrl_t;

typedef	struct	RADIOGRPCTRL {
		judeControl_t	_control;

		karlFarPtr_t	controls_p;
		byte			controlscnt;

		karlFarPtr_t	labelctrl;
	} judeRadioGrpCtrl_t;

typedef	struct	RADIOBTNCTRL {
		judeControl_t	_control;

		karlFarPtr_t	groupctrl_p;
	} judeRadioBtnCtrl_t;


extern	void	__fastcall__	JudeDefCtlPrepare(void);
extern	void	__fastcall__	JudeDefCtlInit(void);
extern	void	__fastcall__	JudeDefCtlChange(void);
extern	void	__fastcall__	JudeDefCtlRelease(void);
extern	void	__fastcall__	JudeDefCtlPresent(void);
extern	void	__fastcall__	JudeDefCtlKeypress(void);
extern	void	__fastcall__	JudeDefEdtPresent(void);
extern	void	__fastcall__	JudeDefEdtKeypress(void);

extern	void	__fastcall__	JudeDefLblChange(void);

extern	void	__fastcall__	JudeDefPBtChange(void);
extern	void	__fastcall__	JudeDefPBtPresent(void);

extern	void	__fastcall__	JudeDefRGpChange(void);
extern	void	__fastcall__	JudeDefRBtChange(void);

extern	void	__fastcall__	JudeRGroupReset(byte index);

#endif