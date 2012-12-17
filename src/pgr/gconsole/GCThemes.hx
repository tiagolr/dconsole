package pgr.gconsole;


// alpha values are shared by console and prompt
 typedef Theme = {
	var promptBgColor 	: Int; // prompt background color
	var promptTxtColor	: Int; // prompt text color
    var consBgColor 	: Int; // console background color
	var consTxtColor 	: Int; // console text alpha
	var consBgAlpha		: Float; // console background alpha
	var	consTxtAlpha	: Float; // console text alpha
	
	var monBgColor		: Int; // Monitor background color
	var monTxtColor		: Int;	// Monitor text color
	var	monBgAlpha		: Float; // monitor background alpha
	var monTxtAlpha		: Float; // monitor text alpha
} 


 /**
  * @author TiagoLr ( ~~~ProG4mr~~~ )
  * 
  * Static class that provides the themes for the console.
  * Create your own themes here.
  */
class GCThemes 
{
	static public var YELLOW_THEME:Theme = {
		consBgColor 	: 0x00008b, 	
		promptBgColor 	: 0x000000,		
		consTxtColor 	: 0xffd700,		
		promptTxtColor	: 0xffd700,		
		monTxtColor		: 0xffFF00,
		monBgColor		: 0x000024,
		consBgAlpha		: .7,			
		consTxtAlpha	: .7,
		monBgAlpha		: .7,			
		monTxtAlpha		: .7,			
	}
	
	static public var GREEN_THEME:Theme = {
		consBgColor 	: 0x000000, 	
		promptBgColor 	: 0x000000,		
		consTxtColor 	: 0x00FF00,		
		promptTxtColor	: 0x00FF00,		
		monTxtColor		: 0x55FF55,
		monBgColor		: 0x000000,
		consBgAlpha		: .7,			
		consTxtAlpha	: .7,
		monBgAlpha		: .7,			
		monTxtAlpha		: .7,			
	}
	
	static public var BLUE_THEME:Theme = {
		consBgColor 	: 0x000000, 
		promptBgColor 	: 0x000000,
		consTxtColor 	: 0x00FFFF,
		promptTxtColor	: 0x00FFFF,
		monTxtColor		: 0x5555FF,
		monBgColor		: 0x000000,
		consBgAlpha		: .7,	
		consTxtAlpha	: .7,			
		monBgAlpha		: .7,			
		monTxtAlpha		: .7,			
	}
	
	static public var DEFAULT_THEME:Theme = {
		consBgColor 	: 0x999999, 
		promptBgColor 	: 0x999999,
		consTxtColor 	: 0x000000,
		promptTxtColor	: 0x000000,
		monTxtColor		: 0xFFFFFF,
		monBgColor		: 0x000000,
		consBgAlpha		: .7,	
		consTxtAlpha	: .7,			
		monBgAlpha		: .7,			
		monTxtAlpha		: .7,
	}
	
	public function new() {}
}