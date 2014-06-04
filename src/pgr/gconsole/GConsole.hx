package pgr.gconsole;

import flash.errors.Error;
import pgr.gconsole.GCCommands.Register;
import flash.ui.Keyboard;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFormat;
import pgr.gconsole.GCThemes.Theme;

/**
 * GConsole is the main class of this lib, it should be instantiated only once
 * and then use its instance to control the console.
 * 
 * Its recomended to use GC class as API for this lib.
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class GConsole extends Sprite {

	inline static public var VERSION = "3.0.2";
	
	/** Aligns console to bottom */
	static public var ALIGN_DOWN:String = "DOWN";
	/** Aligns console to top */
	static public var ALIGN_UP:String = "UP";

	private var _historyArray:Array<String>;
	private var _historyIndex:Int;
	public var interfc:GCInterface;
	public var monitor:GCMonitor;
	public var profiler:GCProfiler;

	/** shortcutkey to show/hide console. */ 
	public var toggleKey:Int; 
	public static var instance:GConsole;
	
	public var enabled(default, null):Bool;
	public var hidden(default, null):Bool;
	
	var input:GCInput;
	
	
	public function new(height:Float = 0.33, align:String = "DOWN", theme:GCThemes.Theme = null, monitorRate:Int = 10) {
		
		if (instance != null) {
			return;
		}
		
		if (theme == null) {
			GCThemes.current = GCThemes.DARK;
		} else {
			GCThemes.current = theme;
		}
		
		super();

		if (height > 1) height = 1;
		if (height < 0.1) height = 0.1;
		
		// create input
		input = new GCInput(this);
		
		// create monitor
		monitor = new GCMonitor();
		addChild(monitor);
		
		profiler = new GCProfiler();
		addChild(profiler);
		
		// create console interface
		interfc = new GCInterface(height, align);
		addChild(interfc);
		
		
		toggleKey = Keyboard.TAB;
		clearHistory();
		
		
		enable();
		hide();
		monitor.hide();
		profiler.hide();
		instance = this;

		GC.logInfo("~~~~~~~~~~ GAME CONSOLE ~~~~~~~~~~ (v" + VERSION + ")");
	}
	
	
	public function show() {
		hidden = false;
		if (!enabled) {
			return;
		}
		
		interfc.visible = true;
		
		Lib.current.stage.focus = interfc.txtPrompt;
	}

	public function hide() {
		hidden = true;
		if (!enabled) {
			return;
		}
		
		interfc.visible = false;
	}

	
	public function enable() {
		
		enabled = true;
		
		if (!hidden) {
			show();
		}
		
		input.enable();
	}

	
	public function disable() {
		enabled = false;
		interfc.visible = false;
		
		input.disable();
	}

	
	public function setToggleKey(key:Int) {
		toggleKey = key;
	}

	
	public function log(data:Dynamic, color:Int = -1) {
		
		if (data == "") {
			return;
		}
		
		// Adds text to console interface
		var tf:TextField = interfc.txtConsole; 
		tf.appendText(Std.string(data) + '\n');
		tf.scrollV = tf.maxScrollV;
		
		// Applies color - is always applied to avoid bug.
		if (color == -1) {
			color = GCThemes.current.CON_TXT_C;
		}
		
		// Applies text formatting
		var format:TextFormat = new TextFormat();
		format.color = color;
		var l = Std.string(data).length;
		tf.setTextFormat(format, tf.text.length - l - 1, tf.text.length - 1);
	}
	
	
	public function registerFunction(Function:Dynamic, alias:String = "") {

		if (!Reflect.isFunction(Function)) {
			GC.logError("Function " + Std.string(Function) + " is not valid.");
			return;
		}
		
		GCCommands.registerFunction(Function, alias);
	}

	
	public function unregisterFunction(alias:String) {
		if (GCCommands.unregisterFunction(alias)) {
			GC.logInfo(alias + " unregistered.");
		} else {
			GC.logError(alias + " not found.");
		}
	}
	
	
	public function registerObject(object:Dynamic, alias:String) {
		if (!Reflect.isObject(object)) {
			GC.logError("dynamic passed is not an object.");
			return;
		}

		GCCommands.registerObject(object, alias);
	}
	
	public function unregisterObject(alias:String) {
		if (GCCommands.unregisterObject(alias)) {
			GC.logInfo(alias + " unregistered.");
		} else {
			GC.logError(alias + " not found.");
		}
	}

	/**
	 * Clears input text;
	 */
	public function clearConsole() {
		interfc.clearConsole();
	}

	
	public function clearRegistry() {
		GCCommands.clearRegistry();
	}
	
	public function clearHistory() {
		_historyArray = new Array<String>();
		_historyIndex = -1;
	}
	
	public function monitorField(object:Dynamic, fieldName:String, alias:String) {
		
		
		if (fieldName == null || fieldName == "") {
			GC.logError("invalid fieldName");
			return;
		}
		
		if (alias == null || alias == "") {
			GC.logError("invalid alias");
			return;
		}
		
		if (object == null || !Reflect.isObject(object)) {
			GC.logError("invalid object.");
			return;
		}
		
		try {
			Reflect.getProperty(object, fieldName);
		} catch (e:Error) {
			GC.logError("could not find field: " + fieldName);
			return;
		}
		
		monitor.addField(object, fieldName, alias);
	}
	
	public function toggleMonitor() {
		monitor.toggle(); 
		if (monitor.visible) {
			profiler.hide();
		}
	}
	
	public function toggleProfiler() {
		profiler.toggle();
		if (profiler.visible) {
			monitor.hide();
		}
	}

	public function prevHistory() {
		_historyIndex--;
		if (_historyIndex < 0) _historyIndex = 0;
		if (_historyIndex > _historyArray.length - 1) return;

		interfc.txtPrompt.text = _historyArray[_historyIndex];
		#if !(cpp || neko)
		interfc.txtPrompt.setSelection(interfc.txtPrompt.length, interfc.txtPrompt.length);
		#end
	}

	public function nextHistory() {
		
		if (_historyIndex + 1 > _historyArray.length - 1) {
			return;
		}
		
		_historyIndex++;

		interfc.txtPrompt.text = _historyArray[_historyIndex];
		#if !(cpp || neko)
		interfc.txtPrompt.setSelection(interfc.txtPrompt.length, interfc.txtPrompt.length);
		#end
	}


	public function processInputLine() {
		
		// no input to process
		if (interfc.txtPrompt.text == '') {
			return;
		}
			
		var temp:String = interfc.txtPrompt.text;
		// HISTORY
		_historyArray.insert(0, interfc.txtPrompt.text);
		resetHistoryIndex();
		// LOG AND CLEAN PROMPT
		log("> " + interfc.txtPrompt.text);
		interfc.txtPrompt.text = '';
		
		parseInput(temp);
	}
	
	// returns history index to beggining.
	public function resetHistoryIndex() {
		_historyIndex = -1;
	}
	
	public function scrollDown() {
		interfc.txtConsole.scrollV -= interfc.txtConsole.bottomScrollV - interfc.txtConsole.scrollV +1;
		if (interfc.txtConsole.scrollV < 0)
			interfc.txtConsole.scrollV = 0;
	}
	
	public function scrollUp() {
		interfc.txtConsole.scrollV += interfc.txtConsole.bottomScrollV - interfc.txtConsole.scrollV +1;
		if (interfc.txtConsole.scrollV > interfc.txtConsole.maxScrollV)
			interfc.txtConsole.scrollV = interfc.txtConsole.maxScrollV;
	}
	
	public function autoComplete() {
		// remove white space added pressing CTRL + SPACE.
		interfc.inputRemoveLastChar();
		
		var autoC:Array<String> = GCUtil.autoComplete(interfc.getInputTxt());
		if (autoC != null)
		{
			if (autoC.length == 1) // only one entry in autocomplete - replace user entry.
			{
				interfc.txtPrompt.text = GCUtil.joinResult(interfc.txtPrompt.text, autoC[0]);
				interfc.txtPrompt.setSelection(interfc.txtPrompt.text.length, interfc.txtPrompt.text.length);
			}
			else	// many entries in autocomplete, list them all.
			{
				GC.log(" "); // new line.
				for (entry in autoC)
				{
					GC.logInfo(entry);
				}
			}
		}
	}


	private function parseInput(input:String) {
		var args:Array<String> = input.split(' ');
		var commandName = args[0].toLowerCase();
		args.shift();
		
		switch (commandName) {
			case "clear"	: clearConsole();
			case "monitor"	: toggleMonitor();
			case "profiler" : toggleProfiler();
			case "help"		: GCCommands.showHelp();
			case "commands" : GCCommands.showCommands();
			case "funcs"	: GCCommands.listFunctions();
			case "objs"		: GCCommands.listObjects();
			case "print"	: GCCommands.printProperty(args);
			case "set"		: GCCommands.setVariable(args);
			case "call"		: GCCommands.callFunction(args);
				
			default : 
				GC.logInfo("unknown command");
		}
	}
	
}
