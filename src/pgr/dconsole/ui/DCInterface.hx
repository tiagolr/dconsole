package pgr.dconsole.ui;

/**
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */

interface DCInterface
{
	var console:DConsole;
	
	public function init() : Void;
	
	public function showConsole() : Void;
	
	public function hideConsole() : Void;

	public function writeMonitorOutput(output:Array<String>) : Void;
	
	public function showMonitor() : Void;
	
	public function hideMonitor() : Void;
	
	public function writeProfilerOutput(output:String) : Void;
	
	public function showProfiler() : Void;
	
	public function hideProfiler() : Void;
	
	//---------------------------------------------------------------------------------
	//  PUBLIC METHODS
	//---------------------------------------------------------------------------------
	public function log(data:Dynamic, color:Int) : Void;
	
	public function moveCarretToEnd() : Void;
	
	public function scrollConsoleUp() : Void;
	
	public function scrollConsoleDown() : Void;
	
	/**
	 * Brings this display object to the front of display list.
	 */
	public function toFront() : Void;
	
	public function setConsoleFont(font:String = null, embed:Bool = false, size:Int = 14, bold:Bool = false, italic:Bool = false, underline:Bool = false ) : Void;
	
	public function setPromptFont(font:String = null, embed:Bool = false, size:Int = 16, bold:Bool = false, ?italic:Bool = false, underline:Bool = false ) : Void;
	
	public function setProfilerFont(font:String = null, embed:Bool = false, size:Int = 14, bold:Bool = false, ?italic:Bool = false, underline:Bool = false ) : Void;
	
	public function setMonitorFont(font:String = null, embed:Bool = false, size:Int = 14, bold:Bool = false, ?italic:Bool = false, underline:Bool = false ) : Void;
	
	/**
	 * Removes last input char
	 */
	public function inputRemoveLastChar() : Void;
	
	public function getInputTxt():String;
	
	public function setInputTxt(string:String) : Void;
	
	public function getConsoleText() : String;
	
	public function getMonitorText() : { col1:String, col2:String };
	
	public function clearInput() : Void;
	
	public function clearConsole() : Void;

	
}