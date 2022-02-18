#include <karljr.h>
#include <jude.h>


//------------------------------------------------------------------------------
//MODULE
//------------------------------------------------------------------------------

//Predeclare interface elements
karlFarPtr_t uns_test_app[];
karlFarPtr_t vws_test_ui[];

judeView_t	vew_test_view;
judePage_t	pge_test_page0;


//Object "instances"
karlModule_t mod_test_app = {
//	Object
		sizeof(karlModule_t),						//size
		FARPTRNULLREC,								//parent
		NEARTOEVENTPTR(KarlDefModPrepare),			//prepare
		NEARTOEVENTPTR(KarlDefModInit),				//initialise
		NEARTOEVENTPTR(KarlDefModChange),			//change
		NEARTOEVENTPTR(KarlDefModRelease),			//release
		STATE_DEFAULT,								//state
		0x0000,										//oldstate
		0x0000,										//options
		0x0000,										//tag
//	Named
		"TEST APP        ",							//name
//	Module
		NEARTOFARPTRREC(uns_test_app),				//units_p
		0x01};										//unitscnt
	
//------------------------------------------------------------------------------
//UNIT
//------------------------------------------------------------------------------

judeUInterface_t uni_test_ui = {
//	Object
		sizeof(judeUInterface_t),					//size
		NEARTOFARPTRREC(mod_test_app),				//parent
		NEARTOEVENTPTR(JudeDefUIPrepare),			//prepare
		NEARTOEVENTPTR(JudeDefUIInit),				//initialise
		NEARTOEVENTPTR(JudeDefUIChange),			//change
		NEARTOEVENTPTR(JudeDefUIRelease),			//release
		STATE_DEFAULT,								//state
		0x0000,										//oldstate
		0x0000,										//options
		0x0000,										//tag
//	Named
		"TEST UI         ",							//name
//	UI
		DWRDTOFARPTRREC(0x3000, 0x0001),			//mouseloc
		DWRDTOFARPTRREC(0x3200, 0x0001),			//mptrloc
		0x01,										//mousepal
		NEARTOFARPTRREC(vws_test_ui),				//views_p
		0x01};										//viewscnt

karlFarPtr_t uns_test_app[] = {
		NEARTOFARPTRREC(uni_test_ui)};
karlFarPtr_t vws_test_ui[] = {
		NEARTOFARPTRREC(vew_test_view)};

//------------------------------------------------------------------------------
//VIEW
//------------------------------------------------------------------------------

karlFarPtr_t lys_test_view[];
karlFarPtr_t brs_test_view[];
karlFarPtr_t pgs_test_view[];


judeView_t vew_test_view = {
//Object
		sizeof(judeView_t),							//size
		NEARTOFARPTRREC(uni_test_ui),				//parent
		NEARTOEVENTPTR(JudeDefViewPrepare),			//prepare
		NEARTOEVENTPTR(JudeDefViewInit),
		NEARTOEVENTPTR(JudeDefViewChange),			//change
		NEARTOEVENTPTR(JudeDefViewRelease),			//release
		STATE_DEFAULT,								//state
		0x0000,										//oldstate
		0x0000,										//options
		0x0000,										//tag
//View
		0x50,										//width
		0x19,										//height
		DWRDTOFARPTRREC(0x2000, 0x0001),			//location
		0x02,										//cellsize
		NEARTOFARPTRREC(lys_test_view),				//layers_p
		0x01,										//layerscnt
		NEARTOFARPTRREC(brs_test_view),				//bars_p
		0x00,										//barscnt
		NEARTOFARPTRREC(pge_test_page0),			//actvpage_p
		NEARTOFARPTRREC(pgs_test_view),				//pages_p
		0x01,										//pagescnt
		0x0000};									//linelen


judeLayer_t	lyr_test_layer = {
//Object
		sizeof(judeLayer_t),						//size
		NEARTOFARPTRREC(vew_test_view),				//parent
		NEARTOEVENTPTR(JudeDefLyrPrepare),			//prepare
		NEARTOEVENTPTR(JudeDefLyrInit),				//initialise
		NEARTOEVENTPTR(JudeDefLyrChange),			//change
		NEARTOEVENTPTR(JudeDefLyrRelease),			//release
		STATE_DEFAULT,								//state
		0x0000,										//oldstate
		0x0000,										//options
		0x0000,										//tag
//Layer
		0x50,										//width
		0x0000,										//offset
		0x00,										//transparent
		0x01};										//background

karlFarPtr_t lys_test_view[] = {
		NEARTOFARPTRREC(lyr_test_layer)};

karlFarPtr_t brs_test_view[] = {
		FARPTRNULLREC};

karlFarPtr_t pgs_test_view[] = {
		NEARTOFARPTRREC(pge_test_page0)};


//------------------------------------------------------------------------------
//PAGE 0
//------------------------------------------------------------------------------

karlFarPtr_t pns_test_page0[];
char str_test_page0[] = "TEST";

judePanel_t	pnl_test_panel0;


judePage_t	pge_test_page0 = {
//Object
		sizeof(judePage_t),							//size
		NEARTOFARPTRREC(lyr_test_layer),			//parent
		NEARTOEVENTPTR(JudeDefPgePrepare),			//prepare
		NEARTOEVENTPTR(JudeDefPgeInit),				//initialise
		NEARTOEVENTPTR(JudeDefPgeChange),			//change
		NEARTOEVENTPTR(JudeDefPgeRelease),			//release
		STATE_DEFCTRL,								//state
		0x0000,										//oldstate
		0x0000,										//options
		0x0000,										//tag
//Element
		NEARTOEVENTPTR(JudeDefPgePresent),			//present
		EVENTPTRNULLREC,							//keypress
		FARPTRNULLREC,								//owner
		CLR_EMPTY,									//colour
		0x00,										//posx
		0x00,										//posy
		0x50,										//width
		0x19,										//height
//Page
		FARPTRNULLREC,								//pagenxt
		FARPTRNULLREC,								//pagebak
		NEARTOFARPTRREC(str_test_page0),			//text_p
		0x00,										//textoffx
		NEARTOFARPTRREC(pns_test_page0),			//panels_p
		0x01};										//panelscnt


karlFarPtr_t pns_test_page0[] = {
		NEARTOFARPTRREC(pnl_test_panel0)};


//------------------------------------------------------------------------------
//PANEL 0 CPU
//------------------------------------------------------------------------------

karlFarPtr_t cts_test_panel0[];

judePanel_t	pnl_test_panel0 = {
//Object
		sizeof(judePanel_t),						//size
		NEARTOFARPTRREC(pge_test_page0),			//parent
		NEARTOEVENTPTR(JudeDefPnlPrepare),			//prepare
		NEARTOEVENTPTR(JudeDefPnlInit),				//initialise
		NEARTOEVENTPTR(JudeDefPnlChange),			//change
		NEARTOEVENTPTR(JudeDefPnlRelease),			//release
		STATE_DEFCTRL,								//state
		0x0000,										//oldstate
		0x0000,										//options
		0x0000,										//tag
//Element
		NEARTOEVENTPTR(JudeDefPnlPresent),			//present
		EVENTPTRNULLREC,							//keypress
		NEARTOFARPTRREC(pge_test_page0),			//owner
		CLR_TEXT,									//colour
		0,											//posx
		0,											//posy
		20,											//width
		10,											//height
//Panel
		NEARTOFARPTRREC(lyr_test_layer),			//layer_p
		NEARTOFARPTRREC(cts_test_panel0),			//controls_p
		0x00};										//controlscnt

karlFarPtr_t cts_test_panel0[] = {
		FARPTRNULLREC};




void main(void) {
	karlFarPtr_t	modulep = {
		NEARTOFARPTRREC(mod_test_app)};
	karlFarPtr_t	viewp = {
		NEARTOFARPTRREC(vew_test_view)};

	KarlInit();
	JudeInit();

	KarlModAttach(&modulep);
	JudeViewInit(&viewp);

	JudeMain();	
}
