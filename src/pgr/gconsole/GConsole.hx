package pgr.gconsole;

import pgr.gconsole.GCCommands.Register;
import flash.ui.Keyboard;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFormat;

/**
 * GConsole is the main class of this lib, it should be instantiated only once
 * and then use its instance to control the console.
 * 
 * Its recomended to use GameConsole class as API for this lib.
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class GConsole extends Sprite {

	inline static public var VERSION = "3.0.0";
	inline static private var GC_TRC_ERR = "gc_error: ";
	
	/** Aligns console to bottom */
	static public var ALIGN_DOWN:String = "DOWN";
	/** Aligns console to top */
	static public var ALIGN_UP:String = "UP";

	private var _historyArray:Array<String>;
	private var _historyIndex:Int;
	public var _interface:GCInterface;

	private var _elapsedFrames:Int;
	private var _monitorRate:Int;

	/** shortcutkey to show/hide console. */ 
	public var key_showHide:Int; 

	private var _isMonitorOn:Bool;
	
	private static var commandNames:Array<String> = { ["clear", "monitor", "help", "commands", "vars", "funcs", "set"];};
	public static var instance:GConsole;
	
	public var enabled(default, null):Bool;
	public var hidden(default, null):Bool;

	
	public function new(height:Float = 0.33, align:String = "DOWN", theme:GCThemes.Theme = null, monitorRate:Int = 10) {
		super();

		if (height > 1) height = 1;
		if (height < 0.1) height = 0.1;
		_interface = new GCInterface(height, align, theme);
		addChild(_interface);

		_monitorRate = monitorRate;
		key_showHide = Keyboard.TAB;

		clearHistory();
		
		enable();
		hideConsole();
		hideMonitor();
		instance = this;

		GameConsole.logInfo("~~~~~~~~~~ GAME CONSOLE ~~~~~~~~~~ (v" + VERSION + ")");
		
	}

	
	public function setConsoleFont(font:String = null, embed:Bool = true, size:Int = 14, bold:Bool = false, italic:Bool = false, underline:Bool = false) {
		_interface.setConsoleFont(font, embed, size, bold, italic, underline);
	}

	
	public function setPromptFont(font:String = null, embed:Bool = true, size:Int = 16, bold:Bool = false, ?italic:Bool = false, underline:Bool = false )
	{
		_interface.setPromptFont(font, embed, size, bold, italic, underline);
	}

	
	public function setMonitorFont(font:String = null, embed:Bool = true, size:Int = 14, bold:Bool = false, ?italic:Bool = false, underline:Bool = false) {
		_interface.setMonitorFont(font, embed, size, bold, italic, underline);
	}

	
	public function showConsole() {
		if (!enabled) {
			return;
		}
		
		hidden = false;
		visible = true;
		
		Lib.current.stage.focus = _interface.txtPrompt;
	}

	
	public function hideConsole() {
		if (!enabled) {
			return;
		}
		
		hidden = true;
		visible = false;
	}

	
	public function showMonitor() {
		_isMonitorOn = true;
		_interface.toggleMonitor(true);
		addEventListener(Event.ENTER_FRAME, updateMonitor);

		_elapsedFrames = _monitorRate + 1;
		updateMonitor(null);	// renders first frame.
	}

	
	public function hideMonitor() {
		_isMonitorOn = false;
		_interface.toggleMonitor(false);
		removeEventListener(Event.ENTER_FRAME, updateMonitor);
	}

	
	public function enable() {
		
		enabled = true;
		
		if (!hidden) {
			this.visible = true;
		}
		
		// prevents duplicating events
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp, false);
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false);
		
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false);
	}

	
	public function disable() {
		
		enabled = false;
		this.visible = false;
		
		//if (_isMonitorOn) hideMonitor(); // TODO monitor
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp, false);
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false);
	}

	
	public function setShortcutKeyCode(key:Int) {
		key_showHide = key;
	}

	
	public function log(data:Dynamic, color:Int = -1) {
		
		if (data == "") {
			return;
		}
		
		// Adds text to console interface
		var tf:TextField = _interface.txtConsole; 
		tf.appendText(Std.string(data) + '\n');
		tf.scrollV = tf.maxScrollV;
		
		// Applies color - is always applied to avoid bug.
		if (color == -1) {
			color = _interface.theme.CON_TXT_C;
		}
		
		// Applies text formatting
		var format:TextFormat = new TextFormat();
		format.color = color;
		var l = Std.string(data).length;
		tf.setTextFormat(format, tf.text.length - l - 1, tf.text.length - 1);
	}
	
	public function registerFunction(Function:Dynamic, alias:String = "") {

		if (!Reflect.isFunction(Function)) {
			throw GC_TRC_ERR + "Function " + Std.string(Function) + " is not valid.";
			return;
		}

		GCCommands.registerFunction(Function, alias);
	}

	
	public function unregisterFunction(alias:String) {
		if (GCCommands.unregisterFunction(alias)) {
			GameConsole.logInfo(alias + " unregistered.");
		} else {
			GameConsole.logError(alias + " not found.");
		}
	}
	
	
	public function registerObject(object:Dynamic, alias:String) 
	{
		if (!Reflect.isObject(object)) {
			trace(GC_TRC_ERR + "dynamic passed is not an object.");
			return;
		}

		GCCommands.registerObject(object, alias);
	}

	/**
	 * Clears input text;
	 */
	public function clearConsoleText() {
		_interface.clearConsoleText();
	}

	
	public function clearRegistry() {
		GCCommands.clearRegistry();
	}
	
	public function clearHistory() {
		_historyArray = new Array<String>();
		_historyIndex = -1;
	}


	//---------------------------------------------------------------------------------
	//  INPUT HANDLING
	//---------------------------------------------------------------------------------
	private function onKeyDown(e:KeyboardEvent):Void {
		#if !(cpp || neko) // BUGFIX
		if (enabled && !hidden)
			e.stopImmediatePropagation();
		#end
	}
	
	private function onKeyUp(e:KeyboardEvent):Void {
		// SHOW/HIDE MONITOR.
		if (e.ctrlKey && cast(e.keyCode, Int) == key_showHide) {
			_isMonitorOn ? hideMonitor() : showMonitor();
			return;
		}
		// SHOW/HIDE CONSOLE.
		if (cast(e.keyCode, Int) == key_showHide) {
			if (!hidden) {
				hideConsole();
			} else {
				showConsole();
			}
			return;
		}
		// IGNORE INPUT IF CONSOLE HIDDEN.
		if (hidden) 
			return;

		// ENTER KEY
		if (e.keyCode == 13) {
			processInputLine();
		}
		else if (e.keyCode == 33) {
			_interface.txtConsole.scrollV -= _interface.txtConsole.bottomScrollV - _interface.txtConsole.scrollV +1;
			if (_interface.txtConsole.scrollV < 0)
				_interface.txtConsole.scrollV = 0;
		}
		if (e.keyCode == 34) { // PAGE UP
			_interface.txtConsole.scrollV += _interface.txtConsole.bottomScrollV - _interface.txtConsole.scrollV +1;
			if (_interface.txtConsole.scrollV > _interface.txtConsole.maxScrollV)
				_interface.txtConsole.scrollV = _interface.txtConsole.maxScrollV;
		}
		else
		if (e.keyCode == 38) { // DOWN KEY
			nextHistory();
		}
		else if (e.keyCode == 40) { // UP KEY
			prevHistory();
		} else if (e.keyCode == 32 && e.ctrlKey)   // CONTROL + SPACE = AUTOCOMPLETE
		{   
			// remove white space added pressing CTRL + SPACE.
			_interface.removeLastChar();
			
			var autoC:Array<String> = GCUtil.autoComplete(_interface.getInputTxt());
			if (autoC != null)
			{
				if (autoC.length == 1) // only one entry in autocomplete - replace user entry.
				{
					_interface.txtPrompt.text = GCUtil.joinResult(_interface.txtPrompt.text, autoC[0]);
					_interface.txtPrompt.setSelection(_interface.txtPrompt.text.length, _interface.txtPrompt.text.length);
				}
				else	// many entries in autocomplete, list them all.
				{
					GameConsole.log(" "); // new line.
					for (entry in autoC)
					{
						GameConsole.logInfo(entry);
					}
				}
			}
		}
		else 
		{
			_historyIndex = -1; 
		}

		#if !(cpp || neko) // BUGFIX
		e.stopImmediatePropagation(); // BUG - cpp issues.
		#end
	}

	private function prevHistory() {
		_historyIndex--;
		if (_historyIndex < 0) _historyIndex = 0;
		if (_historyIndex > _historyArray.length - 1) return;

		_interface.txtPrompt.text = _historyArray[_historyIndex];
		#if !(cpp || neko)
		_interface.txtPrompt.setSelection(_interface.txtPrompt.length, _interface.txtPrompt.length);
		#end
	}

	private function nextHistory() {
		
		if (_historyIndex + 1 > _historyArray.length - 1) {
			return;
		}
		
		_historyIndex++;

		_interface.txtPrompt.text = _historyArray[_historyIndex];
		#if !(cpp || neko)
		_interface.txtPrompt.setSelection(_interface.txtPrompt.length, _interface.txtPrompt.length);
		#end
	}


	private function processInputLine() {
		
		// no input to process
		if (_interface.txtPrompt.text == '') {
			return;
		}
			
		var temp:String = _interface.txtPrompt.text;
		// HISTORY
		_historyArray.insert(0, _interface.txtPrompt.text);
		_historyIndex = -1;
		// LOG AND CLEAN PROMPT
		log("> " + _interface.txtPrompt.text);
		_interface.txtPrompt.text = '';
		
		parseInput(temp);
	}


	private function parseInput(input:String) {
		var args:Array<String> = input.split(' ');
		var commandName = args[0].toLowerCase();
		args.shift();
		
		switch (commandName) {
			case "clear"	: clearConsoleText();
			case "monitor"	: _isMonitorOn ? hideMonitor() : showMonitor();
			case "help"		: GCCommands.showHelp();
			case "commands" : GCCommands.showCommands();
			case "funcs"	: GCCommands.listFunctions();
			case "objs"		: GCCommands.listObjects();
			case "print"	: GCCommands.printProperty(args);
			case "set"		: GCCommands.setVariable(args);
			case "call"		: GCCommands.callFunction(args);
				
			default : 
				GameConsole.logInfo("unknown command");
		}
	}


	//---------------------------------------------------------------------------------
	//  MONITOR
	//---------------------------------------------------------------------------------
	private function updateMonitor(e:Event):Void {
		_elapsedFrames++;
		
		if (_elapsedFrames > _monitorRate) {
			processMonitorOutput(GCCommands.getMonitorOutput());
			_elapsedFrames = 0;
		}
	}

	private function processMonitorOutput(input:String) {
		if (input.length == 0) {
			return;
		}
		
		var str1:String;
		var str2:String;

		var splitPoint:Int = Std.int(input.length / 2) - 1;

		while (splitPoint < input.length) {
			if (input.charAt(splitPoint) == "\n") 
				break;
			splitPoint++;
		}

		_interface.txtMonitorLeft.text = input.substr(0, splitPoint);
		_interface.txtMonitorRight.text = input.substr(splitPoint + 1);
	}
	
}
