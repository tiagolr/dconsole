package pgr.dconsole.ui;

/**
 * ...
 * @author TiagoLr
 */
class DCEmtpyInterface implements DCInterface {
	public var console:DConsole;
	
	public function new() {}
	
	public function init() {}
	
	public function showConsole() {}
	
	public function hideConsole() {} 

	public function writeMonitorOutput(output:Array<String>) {}
	
	public function showMonitor() {}
	
	public function hideMonitor() {}
	
	public function writeProfilerOutput(output:String) {}
	
	public function showProfiler() {}
	
	public function hideProfiler() {}
	
	//---------------------------------------------------------------------------------
	//  PUBLIC METHODS
	//---------------------------------------------------------------------------------
	public function log(data:Dynamic, color:Int) {}
	
	public function moveCarretToEnd() {}
	
	public function scrollConsoleUp() {}
	
	public function scrollConsoleDown() {}
	
	/**
	 * Brings this display object to the front of display list.
	 */
	public function toFront() {}
	
	public function setConsoleFont(font:String = null, embed:Bool = false, size:Int = 14, bold:Bool = false, italic:Bool = false, underline:Bool = false ) {}
	
	
	public function setPromptFont(font:String = null, embed:Bool = false, size:Int = 16, bold:Bool = false, ?italic:Bool = false, underline:Bool = false ) {}
	
	public function setProfilerFont(font:String = null, embed:Bool = false, size:Int = 14, bold:Bool = false, ?italic:Bool = false, underline:Bool = false ) {}
	
	public function setMonitorFont(font:String = null, embed:Bool = false, size:Int = 14, bold:Bool = false, ?italic:Bool = false, underline:Bool = false ) {}
	
	/**
	 * Removes last input char
	 */
	public function inputRemoveLastChar() {}
	
	public function getInputTxt():String { return "";  }
	
	public function setInputTxt(string:String) { }
	
	public function getConsoleText() { return ""; }
	
	public function getMonitorText() { return { col1:"", col2:"" } }
	
	public function clearInput() {}
	
	
	public function clearConsole() {}
}