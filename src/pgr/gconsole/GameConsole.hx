package pgr.gconsole;


import flash.Lib;
/**
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */

 /**
  * GameConsole class provides user friendly interface to Game Console.
  */
class GameConsole 
{
	/** Aligns console to bottom */
	static public var ALIGN_DOWN:String = "DOWN";
	/** Aligns console to top */
	static public var ALIGN_UP:String = "UP";
	
	
	@:noCompletion public static var COLOR_WARN	: Int = 0x808000; // warning messages color.
	
	@:noCompletion public static var COLOR_ERROR: Int = 0x800000; // error messages color.
	
	@:noCompletion public static var COLOR_INFO	: Int = 0x000080; // info messages color.
	
	@:noCompletion public static var COLOR_CONF	: Int = 0x00FF00; // confirmation messages color.
	
	/**
	 * Inits GameConsole.
	 * @param	height	The height of the console (percent of app window height).
	 * @param	align	Aligns console using "UP" or "DOWN".
	 * @param	theme	Select the console theme from GCThemes.
	 * @param	monitorRate The number of frames elapsed for each monitor refresh.
	 */
	public static function init(height:Float = 0.33, align:String = "DOWN", theme:GCThemes.Theme = null, monitorRate:Int = 10) 
	{
		if (GConsole.instance != null)
			return; // GConsole has been initialized already.
		Lib.current.stage.addChild(new GConsole(height, align, theme, monitorRate));
	}
	/**
	 * Sets the console font.
	 * To change font color see <code>GCThemes</code>.
	 * @param	font
	 * @param	embed
	 * @param	size
	 * @param	bold
	 * @param	italic
	 * @param	underline
	 */
	public static function setConsoleFont(font:String = null, embed:Bool = true, size:Int = 14, bold:Bool = false, italic:Bool = false, underline:Bool = false )
	{
		checkInstance();
		GConsole.instance.setConsoleFont(font, embed, size, bold, italic, underline);
	}
	/**
	 * Sets the prompt font.
	 * To change font color see <code>GCThemes</code>.
	 * @param	font
	 * @param	size
	 * @param	bold
	 * @param	italic
	 * @param	underline
	 */
	public static function setPromptFont(font:String = null, embed:Bool = true, size:Int = 16, bold:Bool = false, ?italic:Bool = false, underline:Bool = false )
	{
		checkInstance();
		GConsole.instance.setPromptFont(font, embed, size, bold, italic, underline);
	}
	/**
	 * Sets the monitor font.
	 * To change font color see <code>GCThemes</code>.
	 * @param	font
	 * @param	size
	 * @param	yOffset	Use this to align the font with the prompt graphic field.
	 * @param	bold
	 * @param	italic
	 * @param	underline
	 */
	public static function setMonitorFont(font:String = null, embed:Bool = true, size:Int = 14, bold:Bool = false, ?italic:Bool = false, underline:Bool = false )
	{
		checkInstance();
		GConsole.instance.setMonitorFont(font, embed, size, bold, italic, underline);
	}
	/**
	 * Shows console.
	 */
	public static function showConsole() 
	{
		checkInstance();
		GConsole.instance.showConsole();
	}
	/**
	 * Hides console.
	 */
	public static function hideConsole()
	{
		checkInstance();
		GConsole.instance.showConsole();
	}
	/**
	 * Shows monitor and starts to follow registered fiedls in real time.
	 * Only fields with 'monitor' flag set to true will be followed. 
	 */
	public static function showMonitor() 
	{
		checkInstance();
		GConsole.instance.showMonitor();
	}
	/**
	 * Stops monitoring.
	 */
	public static function hideMonitor()
	{
		checkInstance();
		GConsole.instance.hideMonitor();
	}
	/**
	 * Enables console and its listeners.
	 */
	public static function enable() 
	{
		checkInstance();
		GConsole.instance.enable();
	}
	/**
	 * Disable console and its listeners.
	 */
	public static function disable() 
	{
		checkInstance();
		GConsole.instance.disable();
	}
	/**
	 * Sets the keycode to open the console.
	 * @param	key		The keycode for the new console shortcut key.
	 */
	public static function setShortcutKeyCode(key:Int)
	{
		checkInstance();
		GConsole.instance.setShortcutKeyCode(key);
	}
	/**
	 * Logs a message to the console.
	 * @param	data	The message to log. 
	 * @param	color	The color of text. (-1 uses default color)
	 */
	public static function log(data:Dynamic, color:Int = -1) 
	{
		checkInstance();
		GConsole.instance.log(data, color);
	}
	/**
	 * Logs a warning message to the console.
	 * @param	data	The message to log. 
	 */
	static public function logWarning(data:Dynamic)
	{
		checkInstance();
		GConsole.instance.log(data, COLOR_WARN);
	}
	/**
	 * Logs a error message to the console.
	 * @param	data	The message to log. 
	 */
	static public function logError(data:Dynamic)
	{
		checkInstance();
		GConsole.instance.log(data, COLOR_ERROR);
	}
	/**
	 * Logs a confirmation message to the console.
	 * @param	data	The message to log. 
	 */
	static public function logConfirmation(data:Dynamic)
	{
		checkInstance();
		GConsole.instance.log(data, COLOR_CONF);
	}
	/**
	 * Logs a info message to the console.
	 * @param	data	The message to log. 
	 */
	static public function logInfo(data:Dynamic)
	{
		checkInstance();
		GConsole.instance.log(data, COLOR_INFO);
	}
	/**
	 * Registers a variable to used in the console.
	 * @param	object		Reference to object containing the variable.
	 * @param	field		The name of the variable inside the object.
	 * @param	alias		The display name that shows on screen console. (optional) - if no alias is given, an automatic alias will be created.
	 * @param	monitor 	Whether to monitor/display this variable in realtime using monitor.
	 */
	public static function registerVariable(object:Dynamic, field:String, alias:String="", monitor:Bool=false) 
	{
		checkInstance();
		GConsole.instance.registerVariable(object, field, alias, monitor);
	}
	/**
	 * Deletes field from registry.
	 * @param	alias
	 */
	public static function unregisterVariable(alias:String)
	{
		checkInstance();
		GConsole.instance.unregisterVariable(alias);
	}
	/**
	 * Registers an object to be used in the console.
	 * @param	object		The object to register.
	 * @param	alias		The alias displayed in the console. (optional) - if no alias is given, an automatic alias will be created.
	 */
	public static function registerObject(object:Dynamic, alias:String = "")
	{
		checkInstance();
		GConsole.instance.registerObject(object, alias);
	}
	/**
	 * Registers a function to be called from the console.
	 * If monitor argument is set, this function will be displayed on monitor window.
	 * 
	 * @param	object		A Reference to object containing the function.
	 * @param	Function	The name of the function inside the object.
	 * @param	alias		The display name that shows on screen console. (optional) - if no alias is given, an automatic alias will be created.
	 * @param	monitor 	If true, the function will be called every n frames and output printed. Be careful with this one.
	 */
	public static function registerFunction(object:Dynamic, Function:String, alias:String="", ?monitor:Bool = false) 
	{
		checkInstance();
		GConsole.instance.registerFunction(object, Function, alias, monitor);
	}
	/**
	 * Deletes field from registry.
	 * @param	alias
	 */
	public static function unregisterFunction(alias:String)
	{
		checkInstance();
		GConsole.instance.unregisterFunction(alias);
	}
	/**
	 * Clears console logs.
	 */
	public static function clearConsole() 
	{
		checkInstance();
		GConsole.instance.clearConsole();
	}
	/**
	 * Removes all entrys from registry.
	 */
	public static function clearRegistry()
	{
		checkInstance();
		GCCommands.clearRegistry();
	}
	/**
	 * Brings console to front in stage. 
	 * Useful when other ojects are added directly to stage, hiding the console.
	 */
	public static function toFront()
	{
		Lib.current.stage.swapChildren(GConsole.instance, Lib.current.stage.getChildAt(Lib.current.stage.numChildren - 1));
	}
	
	private static function checkInstance() 
	{
		if (GConsole.instance == null) init();
	}
}