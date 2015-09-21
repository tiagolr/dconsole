package pgr.dconsole;
import pgr.dconsole.DCThemes.Theme;


// alpha values are shared by console and prompt
 typedef Theme = {
    var CON_C 		: Int; // Console color
	var CON_TXT_C 	: Int; // Console text color
	var CON_A		: Float; // Console alpha
	var CON_TXT_A	: Float; // Console text alpha
	
	var PRM_TXT_C	: Int; // Prompt text color
	var PRM_C 		: Int; // Prompt background color
	
	var MON_C		: Int; // Monitor background color
	var MON_TXT_C	: Int;	// Monitor text color
	var MON_A		: Float; // Monitor background alpha
	var MON_TXT_A	: Float; // Monitor text alpha
	
	var LOG_WAR		: Int; // Log warning color;
	var LOG_ERR		: Int; // Log error color;
	var LOG_INF		: Int; // Log info color;
	var LOG_CON		: Int; // log confirmation color;
} 


 /**
  * @author TiagoLr ( ~~~ProG4mr~~~ )
  * 
  * Static class that provides the themes for the console.
  * Create your own themes here.
  */
class DCThemes 
{
	static public var current:Theme;
	
	static public var LIGHT:Theme = {
		CON_C 		: 0xc5c5c5, 
		CON_TXT_C 	: 0x0,
		CON_A		: .7,		
		CON_TXT_A	: 1,
		
		PRM_C		: 0xc5c5c5,
		PRM_TXT_C	: 0x0,
		
		MON_C		: 0x000000,	
		MON_TXT_C	: 0xFFFFFF,
		MON_A		: .7,			
		MON_TXT_A	: .7,
		
		LOG_WAR	: 0x666600, // Warning messages color;
		LOG_ERR	: 0x770000, // Error message color;
		LOG_INF	: 0x006666, // Info messages color;
		LOG_CON	: 0x007700, // Confirmation messages color;
	}
	
	static public var DARK:Theme = {
		CON_C 		: 0x353535, 
		CON_TXT_C 	: 0xFFFFFF,
		CON_A		: .7,
		CON_TXT_A	: 1,
		
		PRM_C		: 0x454545,
		PRM_TXT_C	: 0xFFFFFF,
		
		MON_C		: 0x000000,
		MON_TXT_C	: 0xFFFFFF,
		MON_A		: .7,			
		MON_TXT_A	: .7,
		
		LOG_WAR	: 0xFFFF00, // Warning messages color;
		LOG_ERR	: 0xFF0000, // Error message color;
		LOG_INF	: 0x00FFFF, // Info messages color;
		LOG_CON	: 0x00FF00, // Confirmation messages color;
	}
	
	public function new() {}
}