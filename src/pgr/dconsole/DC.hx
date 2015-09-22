package pgr.dconsole;
import pgr.dconsole.input.DCInput;
import pgr.dconsole.input.DCEmptyInput;
import pgr.dconsole.ui.DCInterface;
import pgr.dconsole.ui.DCEmtpyInterface;
#if openfl
import pgr.dconsole.input.DCOpenflInput;
import pgr.dconsole.ui.DCOpenflInterface;
#end
#if luxe
import pgr.dconsole.input.DCLuxeInput;
import pgr.dconsole.ui.DCLuxeInterface;
#end

 /**
  * DC class provides user API to The Console.
  * It creates a console instance that is added on top of other stage sprites (default).
  * 
  * @author TiagoLr ( ~~~ProG4mr~~~ )
  */
@:expose
class DC 
{
	inline static public var VERSION = "5.0.0";
	/** Aligns console to bottom */
	static public var ALIGN_DOWN:String = "DOWN";
	/** Aligns console to top */
	static public var ALIGN_UP:String = "UP";
	
	static public var instance:DConsole;
	
	/**
	 * Inits TheConsole.
	 * @param	heightPt	Pertentage height of the console
	 * @param	align		Aligns console using "UP" or "DOWN".
	 * @param	theme		Select the console theme from GCThemes.
	 * @param	monitorRate The number of frames elapsed for each monitor refresh.
	 */
	public static function init(?heightPt:Float = 33, ?align:String = "DOWN", ?theme:DCThemes.Theme = null, input:DCInput = null, interfc:DCInterface = null) {
		if (instance != null) {
			return; // DConsole has been initialized already.
		}
		
		if (input == null) {
			#if (openfl && !js)
			input = new DCOpenflInput();
			#elseif luxe
			input = new DCLuxeInput();
			#else
			input = new DCEmptyInput();
			#end
		}
		
		if (interfc == null) {
			#if (openfl && !js)
			interfc = new DCOpenflInterface(heightPt, align);
			#elseif luxe
			interfc = new DCLuxeInterface(heightPt, align);
			Luxe.next(function() {
				DC.registerClass(luxe.Vector, 'Vector');
			});
			#else
			interfc = new DCEmtpyInterface();
			#end
		}
		
		instance = new DConsole(input, interfc, theme);
		DC.logInfo("~~~~~~~~~~ DCONSOLE ~~~~~~~~~~ (v" + VERSION + ")");
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
		instance.interfc.setConsoleFont(font, embed, size, bold, italic, underline);
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
		instance.interfc.setPromptFont(font, embed, size, bold, italic, underline);
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
		instance.interfc.setConsoleFont(font, embed, size, bold, italic, underline);
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
		instance.interfc.setConsoleFont(font, embed, size, bold, italic, underline);
		instance.interfc.setPromptFont(font, embed, size, bold, italic, underline);
		instance.interfc.setConsoleFont(font, embed, size, bold, italic, underline);
		instance.interfc.setProfilerFont(font, embed, size, bold, italic, underline);
	}
	
	/**
	 * Shows console.
	 */
	public static function showConsole() {
		checkInstance();
		instance.showConsole();
	}
	/**
	 * Hides console.
	 */
	public static function hideConsole() {
		checkInstance();
		instance.hideConsole();
	}
	/**
	 * Shows monitor and refreshes displayed info according to refreshRate.
	 */
	public static function showMonitor() {
		checkInstance();
		instance.showMonitor();
	}
	/**
	 * Stops monitoring.
	 */
	public static function hideMonitor()
	{
		checkInstance();
		instance.hideMonitor();
	}
	/**
	 * Shows profiler and refreshes statistics according to refreshRate.
	 */
	public static function showProfiler() {
		checkInstance();
		instance.showProfiler();
	}
	/**
	 * Stops showing and refreshing profiler.
	 */
	public static function hideProfiler()
	{
		checkInstance();
		instance.hideProfiler();
	}
	/**
	 * Enables console and its listeners.
	 */
	public static function enable() {
		checkInstance();
		instance.enable();
	}
	/**
	 * Disable console and its listeners.
	 */
	public static function disable() {
		checkInstance();
		instance.disable();
	}
	/**
	 * Sets console toggle key combination.
	 * @param	keyCode		The key code.
	 * @param	ctrlKey		If control key is pressed.
	 * @param	shiftKey	If shift key is pressed.
	 * @param	altKey		If alt key is pressed.
	 */
	public static function setConsoleKey(keyCode:Int, ctrlKey:Bool = false, shiftKey:Bool = false, altKey:Bool = false) {
		checkInstance();
		instance.setConsoleKey(keyCode, ctrlKey, shiftKey, altKey);
	}
	/**
	 * Sets monitor toggle key combination.
	 * @param	keyCode		The key code.
	 * @param	ctrlKey		If control key is pressed.
	 * @param	shiftKey	If shift key is pressed.
	 * @param	altKey		If alt key is pressed.
	 */
	public static function setMonitorKey(keyCode:Int, ctrlKey:Bool = false, shiftKey:Bool = false, altKey:Bool = false) {
		checkInstance();
		instance.setMonitorKey(keyCode, ctrlKey, shiftKey, altKey);
	}
	/**
	 * Sets console toggle key combination.
	 * @param	keyCode		The key code.
	 * @param	ctrlKey		If control key is pressed.
	 * @param	shiftKey	If shift key is pressed.
	 * @param	altKey		If alt key is pressed.
	 */
	public static function setProfilerKey(keyCode:Int, ctrlKey:Bool = false, shiftKey:Bool = false, altKey:Bool = false) {
		checkInstance();
		instance.setProfilerKey(keyCode, ctrlKey, shiftKey, altKey);
	}
	/**
	 * Logs a message to the console.
	 * @param	data	The message to log. 
	 * @param	color	The color of text. (-1 uses default color)
	 */
	public static function log(data:Dynamic, color:Int = -1) {
		checkInstance();
		instance.log(data, color);
	}
	/**
	 * Logs a warning message to the console.
	 * @param	data	The message to log. 
	 */
	static public function logWarning(data:Dynamic) {
		checkInstance();
		instance.logWarning(data);
	}
	/**
	 * Logs a error message to the console.
	 * @param	data	The message to log. 
	 */
	static public function logError(data:Dynamic) {
		checkInstance();
		instance.log(data, DCThemes.current.LOG_ERR);
	}
	/**
	 * Logs a confirmation message to the console.
	 * @param	data	The message to log. 
	 */
	static public function logConfirmation(data:Dynamic) {
		checkInstance();
		instance.logConfirmation(data);
	}
	/**
	 * Logs a info message to the console.
	 * @param	data	The message to log. 
	 */
	static public function logInfo(data:Dynamic) {
		checkInstance();
		instance.logInfo(data);
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
		instance.monitorField(object, fieldName, alias);
	}
	
	/**
	 * Sets the refresh rate of the monitor.
	 * @param	refreshRate		Time (in milliseconds) between monitor values update.
	 */
	static public function setMonitorRefreshRate(refreshRate:Int = 100) {
		checkInstance();
		instance.monitor.setRefreshRate(refreshRate);
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
		instance.commands.registerCommand(Function, alias, shortcut, description, help);
	}
	
	/**
	 * Registers an object to be used in the console.
	 * @param	object		The object to register.
	 * @param	alias		The alias displayed in the console. (optional) - if no alias is given, an automatic alias will be created.
	 */
	public static function registerObject(object:Dynamic, alias:String = "") {
		checkInstance();
		instance.commands.registerObject(object, alias);
	}
	
	/**
	 * Allows a class static methods and properties to be used from the console.
	 * @param	alias	The variable name that invokes this class.
	 * @param	cls		The class to be exposed to the console.
	 */
	public static function registerClass(cls:Class<Dynamic>, alias:String) {
		checkInstance();
		instance.commands.registerClass(cls, alias);
	}
	/**
	 * Registers a function to be called from the console.
	 * If monitor argument is set, this function will be displayed on monitor window.
	 * 
	 * @param	Function	The function to be registered.
	 * @param	alias		The alias displayed in the console.
	 * @param 	description	Short description shown in commands list.
	 */
	public static function registerFunction(Function:Dynamic, alias:String, description:String = "") {
		checkInstance();
		instance.commands.registerFunction(Function, alias, description);
	}
	/**
	 * Deletes field from registry.
	 * @param	alias
	 */
	public static function unregisterFunction(alias:String) {
		checkInstance();
		instance.commands.unregisterFunction(alias);
	}
	
	public static function unregisterObject(alias:String) {
		checkInstance();
		instance.commands.unregisterObject(alias);
	}
	/**
	 * Clears console logs.
	 */
	public static function clearConsole() {
		checkInstance();
		instance.clearConsole();
	}
	/**
	 * Removes all entrys from registry.
	 */
	public static function clearRegistry() {
		checkInstance();
		instance.commands.clearRegistry();
	}
	
	/**
	 *  Resets profiler history and samples.
	 *  If any samples are running, clearProfiler will fail.
	 */
	static public function clearProfiler() {
		checkInstance();
		instance.profiler.clear();
	}
	
	/**
	 * Removes all registered fields from monitor
	 */
	public static function clearMonitor() {
		checkInstance();
		instance.monitor.clear();
	}
	
	/**
	 * Brings console to front in stage. 
	 * Useful when other ojects are added directly to stage, hiding the console.
	 */
	public static function toFront() {
		checkInstance();
		instance.interfc.toFront();
	}
	
	/**
	 * Begins profiling sample, use endProfile(sampleName) to display
	 * time elapsed statistics between the two calls inside console profiler.
	 */
	public static function beginProfile(sampleName:String) {
		checkInstance();
		instance.profiler.begin(sampleName);
	}
	/**
	 * Ends the sample and dumps output to the profiler if this sample has no
	 * other parent samples.
	 */
	public static function endProfile(sampleName:String) {
		checkInstance();
		instance.profiler.end(sampleName);
	}
	
	/**
	 * Set weather to print stack information when errors occur
	 * @param	b
	 */
	public static function setVerboseErrors(b:Bool) {
		checkInstance();
		instance.commands.printErrorStack = b;
	}
	
	/**
	 * Makes console interp evaluate expression
	 * @param	expr
	 */
	public static function eval(expr:String) {
		checkInstance();
		instance.commands.evaluate(expr);
	}
	
	//---------------------------------------------------------------------------------
	//  PRIVATE / AUX
	//---------------------------------------------------------------------------------
	private static function checkInstance() {
		if (instance == null) {
			init();
		}
	}
}
