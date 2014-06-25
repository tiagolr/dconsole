package pgr.dconsole ;

 /**
  * DC class provides user API to The Console.
  * 
  * @author TiagoLr ( ~~~ProG4mr~~~ )
  */
class DC 
{
	
	/** Aligns console to bottom */
	static public var ALIGN_DOWN:String = "DOWN";
	/** Aligns console to top */
	static public var ALIGN_UP:String = "UP";
	
	/**
	 * Inits TheConsole.
	 * @param	height	The height of the console (percent of app window height).
	 * @param	align	Aligns console using "UP" or "DOWN".
	 * @param	theme	Select the console theme from GCThemes.
	 * @param	monitorRate The number of frames elapsed for each monitor refresh.
	 */
	public static function init(height:Float = 0.33, align:String = "DOWN", theme:DCThemes.Theme = null, monitorRate:Int = 10) {
		if (DConsole.instance != null) {
			return; // DConsole has been initialized already.
		}
		
		new DConsole(height, align, theme, monitorRate);
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
	public static function setConsoleFont(font:String = null, embed:Bool = true, size:Int = 14, bold:Bool = false, italic:Bool = false, underline:Bool = false ){
		checkInstance();
		DConsole.instance.interfc.setConsoleFont(font, embed, size, bold, italic, underline);
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
	public static function setPromptFont(font:String = null, embed:Bool = true, size:Int = 16, bold:Bool = false, ?italic:Bool = false, underline:Bool = false ){
		checkInstance();
		DConsole.instance.interfc.setPromptFont(font, embed, size, bold, italic, underline);
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
	public static function setMonitorFont(font:String = null, embed:Bool = true, size:Int = 14, bold:Bool = false, ?italic:Bool = false, underline:Bool = false ){
		checkInstance();
		DConsole.instance.interfc.setConsoleFont(font, embed, size, bold, italic, underline);
	}
	
	/**
	 * Sets the monitor, console, and prompt fonts in one go.
	 * Sizes and offsets use the default values.
	 *
	 * To change the font color, see <code>GCThemes</code>
	 * @param font The path of the desired font file
	 * @param embed ?
	 * @param bold True if the font should be bold
	 * @param italic True if the font should be italicized
	 * @param underline True if the font should be underlined
	 */
	public static function setFont(font:String = null, embed:Bool = true, size:Int = 16, bold:Bool = false, ?italic:Bool = false, underline:Bool = false){
		checkInstance();
		DConsole.instance.interfc.setConsoleFont(font, embed, size, bold, italic, underline);
		DConsole.instance.interfc.setPromptFont(font, embed, size, bold, italic, underline);
		DConsole.instance.interfc.setConsoleFont(font, embed, size, bold, italic, underline);
		DConsole.instance.interfc.setProfilerFont(font, embed, size, bold, italic, underline);
	}
	
	/**
	 * Shows console.
	 */
	public static function showConsole() {
		checkInstance();
		DConsole.instance.showConsole();
	}
	/**
	 * Hides console.
	 */
	public static function hideConsole() {
		checkInstance();
		DConsole.instance.hideConsole();
	}
	/**
	 * Shows monitor and refreshes displayed info according to refreshRate.
	 */
	public static function showMonitor() {
		checkInstance();
		DConsole.instance.showMonitor();
	}
	/**
	 * Stops monitoring.
	 */
	public static function hideMonitor()
	{
		checkInstance();
		DConsole.instance.hideMonitor();
	}
	/**
	 * Shows profiler and refreshes statistics according to refreshRate.
	 */
	public static function showProfiler() {
		checkInstance();
		DConsole.instance.showProfiler();
	}
	/**
	 * Stops showing and refreshing profiler.
	 */
	public static function hideProfiler()
	{
		checkInstance();
		DConsole.instance.hideProfiler();
	}
	/**
	 * Enables console and its listeners.
	 */
	public static function enable() {
		checkInstance();
		DConsole.instance.enable();
	}
	/**
	 * Disable console and its listeners.
	 */
	public static function disable() {
		checkInstance();
		DConsole.instance.disable();
	}
	/**
	 * Sets the keycode to open the console.
	 * @param	key		The keycode for the new console shortcut key.
	 */
	public static function setShortcutKeyCode(key:Int) {
		checkInstance();
		DConsole.instance.setToggleKey(key);
	}
	/**
	 * Logs a message to the console.
	 * @param	data	The message to log. 
	 * @param	color	The color of text. (-1 uses default color)
	 */
	public static function log(data:Dynamic, color:Int = -1) {
		checkInstance();
		DConsole.instance.log(data, color);
	}
	/**
	 * Logs a warning message to the console.
	 * @param	data	The message to log. 
	 */
	static public function logWarning(data:Dynamic) {
		checkInstance();
		DConsole.instance.log(data, DCThemes.current.LOG_WAR);
	}
	/**
	 * Logs a error message to the console.
	 * @param	data	The message to log. 
	 */
	static public function logError(data:Dynamic) {
		checkInstance();
		DConsole.instance.log(data, DCThemes.current.LOG_ERR);
	}
	/**
	 * Logs a confirmation message to the console.
	 * @param	data	The message to log. 
	 */
	static public function logConfirmation(data:Dynamic) {
		checkInstance();
		DConsole.instance.log(data, DCThemes.current.LOG_CON);
	}
	/**
	 * Logs a info message to the console.
	 * @param	data	The message to log. 
	 */
	static public function logInfo(data:Dynamic) {
		checkInstance();
		DConsole.instance.log(data, DCThemes.current.LOG_INF);
	}
	
	/**
	 * Adds this field to be monitored. 
	 * When monitor is visibile, the value will be visible and updated in realtime.
	 * Private fields or fields with getter/setter are also supported.
	 * 
	 * @param	object			object containing the field
	 * @param	fieldName		field name, eg: "x" or "rotation"
	 * @param	alias			name to be displayed
	 */
	static public function monitorField(object:Dynamic, fieldName:String, alias:String) {
		checkInstance();
		DConsole.instance.monitorField(object, fieldName, alias);
	}
	
	/**
	 * Sets the refresh rate of the monitor.
	 * @param	refreshRate		Time (in milliseconds) between monitor values update.
	 */
	static public function setMonitorRefreshRate(refreshRate:Int = 100) {
		checkInstance();
		DConsole.instance.monitor.setRefreshRate(refreshRate);
	}
	
	/**
	 * Registers a command to be invoked from the console.
	 * For examples check GCCommands, all runtime commands are registered during console init().
	 * 
	 * @param	Function		The method called when the command is invoked.
	 * @param	alias			The command name used to invoke it from the console.
	 * @param	shortcut		Alternative name used to invoke it.
	 * @param	description		Short description shown in commands list.
	 * @param	help			Long description shown in help.
	 */
	static public function registerCommand(Function:Array<String>->Void,
										   alias:String, 
										   shortcut:String = "",
										   description:String = "",
										   help:String = "") 
	{
		checkInstance();
		DCCommands.registerCommand(Function, alias, shortcut, description, help);
	}
	
	/**
	 * Registers an object to be used in the console.
	 * @param	object		The object to register.
	 * @param	alias		The alias displayed in the console. (optional) - if no alias is given, an automatic alias will be created.
	 */
	public static function registerObject(object:Dynamic, alias:String = "") {
		checkInstance();
		DCCommands.registerObject(object, alias);
	}
	/**
	 * Registers a function to be called from the console.
	 * If monitor argument is set, this function will be displayed on monitor window.
	 * 
	 * @param	Function	The function to be registered.
	 * @param	alias		The alias displayed in the console.
	 */
	public static function registerFunction(Function:Dynamic, alias:String) {
		checkInstance();
		DCCommands.registerFunction(Function, alias);
	}
	/**
	 * Deletes field from registry.
	 * @param	alias
	 */
	public static function unregisterFunction(alias:String) {
		checkInstance();
		DCCommands.unregisterFunction(alias);
	}
	
	public static function unregisterObject(alias:String) {
		checkInstance();
		DCCommands.unregisterObject(alias);
	}
	/**
	 * Clears console logs.
	 */
	public static function clearConsole() {
		checkInstance();
		DConsole.instance.clearConsole();
	}
	/**
	 * Removes all entrys from registry.
	 */
	public static function clearRegistry() {
		checkInstance();
		DCCommands.clearRegistry();
	}
	
	/**
	 *  Resets profiler history and samples.
	 *  If any samples are running, clearProfiler will fail.
	 */
	static public function clearProfiler() {
		checkInstance();
		DConsole.instance.profiler.clear();
	}
	
	/**
	 * Removes all registered fields from monitor
	 */
	public static function clearMonitor() {
		checkInstance();
		DConsole.instance.monitor.clear();
	}
	
	/**
	 * Brings console to front in stage. 
	 * Useful when other ojects are added directly to stage, hiding the console.
	 */
	public static function toFront() {
		checkInstance();
		DConsole.instance.interfc.toFront();
	}
	
	/**
	 * Begins profiling sample, use endProfile(sampleName) to display
	 * time elapsed statistics between the two calls inside console profiler.
	 */
	public static function beginProfile(sampleName:String) {
		checkInstance();
		DConsole.instance.profiler.begin(sampleName);
	}
	/**
	 * Ends the sample and dumps output to the profiler if this sample has no
	 * other parent samples.
	 */
	public static function endProfile(sampleName:String) {
		checkInstance();
		DConsole.instance.profiler.end(sampleName);
	}
	
	/**
	 * Set weather to print stack information when errors occur
	 * @param	b
	 */
	public static function setVerboseErrors(b:Bool) {
		DCCommands.printErrorStack = b;
	}
	
	//---------------------------------------------------------------------------------
	//  PRIVATE / AUX
	//---------------------------------------------------------------------------------
	private static function checkInstance() {
		if (DConsole.instance == null) {
			init();
		}
	}
}
