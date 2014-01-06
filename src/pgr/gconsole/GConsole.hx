package pgr.gconsole;

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
class GConsole extends Sprite
{	

	inline static public var VERSION = "2.00";
	inline static private var GC_TRC_ERR = "gc_error: ";
	/** Aligns console to bottom */
	static public var ALIGN_DOWN:String = "DOWN";
	/** Aligns console to top */
	static public var ALIGN_UP:String = "UP";
	
	private var _historyArray:Array<String>;
	private var _historyIndex:Int;
	private var _historyMaxSz:Int;
	public var _interface:GCInterface;
	
	private var _elapsedFrames:Int;
	private var _monitorRate:Int;
	
	/** Show console key. */ 
	private var _consoleScKey:Int; 
	
	private var _isMonitorOn:Bool;
	private var _isConsoleOn:Bool;
	
	public static var instance:GConsole;

	public function new(height:Float = 0.33, align:String = "DOWN", theme:GCThemes.Theme = null, monitorRate:Int = 10) 
	{
		super();
		
		if (height > 1) height = 1;
		if (height < 0.1) height = 0.1;
		_interface = new GCInterface(height,align,theme);
		addChild(_interface);
		
		_monitorRate = monitorRate;
		_consoleScKey = 9;
		
		_historyArray = new Array();
		_historyIndex = -1;
		_historyMaxSz = 100;	
		_firstLine = true;
		
		enable();
		hideConsole();
		hideMonitor();
		instance = this;
		
		GameConsole.logInfo("~~~~~~~~~~ GAME CONSOLE ~~~~~~~~~~ (v" + VERSION + ")");
	} 

	public function setConsoleFont(font:String = null, embed:Bool = true, size:Int = 14, bold:Bool = false, italic:Bool = false, underline:Bool = false )
	{
		_interface.setConsoleFont(font, embed, size, bold, italic, underline);
	}

	public function setPromptFont(font:String = null, embed:Bool = true, size:Int = 16, bold:Bool = false, ?italic:Bool = false, underline:Bool = false )
	{
		_interface.setPromptFont(font, embed, size, bold, italic, underline);
	}

	public function setMonitorFont(font:String = null, embed:Bool = true, size:Int = 14, bold:Bool = false, ?italic:Bool = false, underline:Bool = false )
	{		
		_interface.setMonitorFont(font, embed, size, bold, italic, underline);
	}

	public function showConsole() 
	{
		if (!this.visible) return;
		Lib.current.stage.focus = _interface.txtPrompt;
		_isConsoleOn = true;
		_interface.toggleConsoleOn(true);
	}

	public function hideConsole()
	{
		if (!this.visible) return;
		_isConsoleOn = false;
		_interface.toggleConsoleOn(false);
	}

	public function showMonitor() 
	{
		_isMonitorOn = true;
		_interface.toggleMonitor(true);
		addEventListener(Event.ENTER_FRAME, updateMonitor);
		
		_elapsedFrames = _monitorRate + 1;
		updateMonitor(null);	// renders first frame.
	}

	public function hideMonitor()
	{
		_isMonitorOn = false;
		_interface.toggleMonitor(false);
		removeEventListener(Event.ENTER_FRAME, updateMonitor);
	}

	public function enable() 
	{
		visible = true;
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false);
	}

	public function disable() 
	{
		if (_isMonitorOn) hideMonitor();
		if (_isConsoleOn) hideConsole();
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp, false);
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false);
		visible = false;
	}

	public function setShortcutKeyCode(key:Int)
	{
		_consoleScKey = key;
	}
	
	// ========================
	// =====   LOG        =====
	// ========================
	public function log(data:Dynamic, color:Int = -1) 
	{
		if (data == "") return;
			
		
		var tf:TextField = _interface.txtConsole; 
		tf.appendText(data.toString() + '\n');
		
		//if (tf.length > data.toString().length) // if its not the first line add new line at the end.
			//tf.appendText('\n');
		tf.scrollV = tf.maxScrollV;
		
		
		// Applies color - is always applied to avoid bug.
		if (color == -1)
			color = _interface.theme.consTxtColor;
		var format:TextFormat = new TextFormat();
		format.color = color;
		var l = data.toString().length;
		tf.setTextFormat(format, tf.length - l - 1, tf.length - 1);
	}
	

	public function registerVariable(object:Dynamic, name:String, alias:String, monitor:Bool=false) 
	{
		if (!Reflect.isObject(object)) {
		trace(GC_TRC_ERR + "dynamic passed with the field: " + name + " is not an object.");
			return;
		}
		#if !(cpp || neko)
		if (!Reflect.hasField(object, name)) 
		#else
		if (Reflect.getProperty(object, name) == null) 
		#end
		{
			trace (GC_TRC_ERR + name + " field was not found in object passed.");
			return;
		}
		
		GCCommands.registerVariable(object, name, alias, monitor);
	}

	public function unregisterVariable(alias:String)
	{
		if (GCCommands.unregisterVariable(alias)) {
			GameConsole.logInfo(alias + " unregistered.");
		} else {
			GameConsole.logError(alias + " not found.");
		}
	}
	
	public function registerFunction(object:Dynamic, name:String, alias:String="", ?monitor:Bool = false) 
	{
		#if !(cpp || neko)
		if (!Reflect.hasField(object, name)) 
		#else
		if (Reflect.getProperty(object, name) == null) 
		#end
		{
			trace(GC_TRC_ERR + name + " field was not found in object passed.");
			return;
		}
		
		if (!Reflect.isFunction(Reflect.field(object, name))) {
			trace(GC_TRC_ERR + "could not find function: " + name + " in object passed.");
			return;
		}
		
		GCCommands.registerFunction(object, name, alias, monitor);
	}

	public function unregisterFunction(alias:String)
	{
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
	
	public function clearConsole() 
	{
		_interface.txtConsole.text = '';
	}

	public function clearRegistry()
	{
		GCCommands.clearRegistry();
	}
	
	// INPUT HANDLING ------------------------------------------------------
	
	private function onKeyDown(e:KeyboardEvent):Void 
	{
		#if !(cpp || neko) // BUGFIX
		if (_isConsoleOn) 
			e.stopImmediatePropagation(); 
		#end
	}
	
	private function onKeyUp(e:KeyboardEvent):Void 
	{
		// SHOW/HIDE MONITOR.
		if (e.ctrlKey && cast(e.keyCode,Int) == _consoleScKey ) {
			_isMonitorOn ? hideMonitor() : showMonitor();
			return;
		}
		// SHOW/HIDE CONSOLE.
		if (cast(e.keyCode,Int) == _consoleScKey) { 
			_isConsoleOn ? hideConsole() : showConsole();
			return; 
		}
		// IGNORE INPUT IF CONSOLE HIDDEN.
		if (!_isConsoleOn) 
			return;	
		
		if (e.keyCode == 13) // ENTER KEY.
		{
			processInputLine();
		}
		else 
		if (e.keyCode == 33) // PAGE DOWN
		{
			_interface.txtConsole.scrollV -= _interface.txtConsole.bottomScrollV - _interface.txtConsole.scrollV +1;
			if (_interface.txtConsole.scrollV < 0)
				_interface.txtConsole.scrollV = 0;
		}
		else 
		if (e.keyCode == 34) // PAGE UP
		{
			_interface.txtConsole.scrollV += _interface.txtConsole.bottomScrollV - _interface.txtConsole.scrollV +1;
			if (_interface.txtConsole.scrollV > _interface.txtConsole.maxScrollV)
				_interface.txtConsole.scrollV = _interface.txtConsole.maxScrollV;
		}
		else
		if (e.keyCode == 38) // DOWN KEY
		{
			nextHistory();
		}
		else 
		if (e.keyCode == 40) // UP KEY
		{
			prevHistory();
		}
		else 
		if (e.keyCode == 32 && e.ctrlKey)   // CONTROL + SPACE = Autocomplete
		{   
			// remove white space added pressing CTRL + SPACE.
			_interface.txtPrompt.text = _interface.txtPrompt.text.substr(0, _interface.txtPrompt.text.length - 1); 
			
			var autoC:Array<String> = GCUtil.autoComplete(_interface.txtPrompt.text);
			if (autoC != null)
			{
				if (autoC.length == 1) // only one entry in autocomplete.
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

		
		/*
		}
		switch (e.keyCode) {
			// ENTER
			case 13	: 	processInputLine();
			// PAGEUP
			case 33 : 	_interface.txtConsole.scrollV -= _interface.txtConsole.bottomScrollV - _interface.txtConsole.scrollV +1;
						if (_interface.txtConsole.scrollV < 0)
							_interface.txtConsole.scrollV = 0;
			// PAGEDOWN
			case 34	:	_interface.txtConsole.scrollV += _interface.txtConsole.bottomScrollV - _interface.txtConsole.scrollV +1;
						if (_interface.txtConsole.scrollV > _interface.txtConsole.maxScrollV)
							_interface.txtConsole.scrollV = _interface.txtConsole.maxScrollV;
			// UP
			case 38	:	nextHistory();
			// DOWN
			case 40	: 	prevHistory();
			default	:	_historyIndex = -1;
		}
		*/
			
		#if !(cpp || neko) // BUGFIX
		e.stopImmediatePropagation(); // BUG - cpp issues.
		#end
	}
	
	private function prevHistory() 
	{
		_historyIndex--;
		if (_historyIndex < 0 ) _historyIndex = 0;
		if (_historyIndex > _historyArray.length - 1) return; 
		
		_interface.txtPrompt.text = _historyArray[_historyIndex];
		#if !(cpp || neko)
		_interface.txtPrompt.setSelection(_interface.txtPrompt.length, _interface.txtPrompt.length); 
		#end
	}
	
	private function nextHistory() 
	{
		if (_historyIndex + 1 > _historyArray.length - 1) return;
		_historyIndex++;
		
		_interface.txtPrompt.text = _historyArray[_historyIndex];
		#if !(cpp || neko)
		_interface.txtPrompt.setSelection(_interface.txtPrompt.length, _interface.txtPrompt.length); 
		#end
	}
	
	// INPUT PARSE ----------------------------------------------------
	
	private function processInputLine() 
	{
		if (_interface.txtPrompt.text == '') 
			return;
			
		var temp:String = _interface.txtPrompt.text;
		// HISTORY
		_historyArray.insert(0, _interface.txtPrompt.text);
		_historyIndex = -1;
		if (_historyArray.length > _historyMaxSz)
			_historyArray.splice(_historyArray.length - 1, 1);
		// LOG AND CLEAN PROMPT
		log(_interface.txtPrompt.text);
		_interface.txtPrompt.text = '';
		
		parseInput(temp);
	}
	
	private function parseInput(input:String) 
	{
		var args:Array<String> = input.split(' ');
		
		switch (args[0].toLowerCase()) {
			case "clear"	: clearConsole();
			case "monitor"	: _isMonitorOn ? hideMonitor() : showMonitor();
			case "help"		: GCCommands.showHelp();
			case "commands" : GCCommands.showCommands();
			case "vars"		: GCCommands.listVars();
			case "funcs"	: GCCommands.listFunctions();
			case "objs"		: GCCommands.listObjects();
			case "set"		: GCCommands.setVar(args);
			case "call"		: GCCommands.callFunction(args);
			default 		: GameConsole.logInfo("unknown command");
		}
	}
	
	// MONITOR --------------------------------------------------------

	private function updateMonitor(e:Event):Void 
	{
		_elapsedFrames++;
		if (_elapsedFrames > _monitorRate) {
			processMonitorOutput(GCCommands.getMonitorOutput());
			_elapsedFrames = 0;
		}
	}
	
	private function processMonitorOutput(input:String) 
	{
		if (input.length == 0) return;
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
	
	// GETTERS AND SETTERS ------------------------------------------------
	
	private function set_historyMaxSz(value:Int):Int 
	{
		return _historyMaxSz = value;
	}
	public var historyMaxSz(null, set_historyMaxSz):Int;
}
