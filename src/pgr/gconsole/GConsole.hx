package pgr.gconsole;

import pgr.gconsole.GCThemes.Theme;

/**
 * GConsole is the main class of this lib, it should be instantiated only once
 * and then use its instance to control the console.
 * 
 * Its recomended to use GC class as API for this lib.
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class GConsole {

	inline static public var VERSION = "3.1.0";
	
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
	public var toggleKey:Int = 9; 
	public static var instance:GConsole;
	
	public var enabled(default, null):Bool;
	public var visible(default, null):Bool;
	
	public var input:GCInput;
	
	
	public function new(height:Float = 0.33, align:String = "DOWN", theme:GCThemes.Theme = null, monitorRate:Int = 10) {
		
		if (instance != null) {
			return;
		}
		instance = this;
		
		if (theme == null) {
			GCThemes.current = GCThemes.DARK;
		} else {
			GCThemes.current = theme;
		}

		if (height > 1) height = 1;
		if (height < 0.1) height = 0.1;
		
		// create input
		input = new GCInput();
		
		// create monitor
		monitor = new GCMonitor();
		
		// create profiler
		profiler = new GCProfiler();
		
		// create console interface
		interfc = new GCInterface(height, align);

		clearHistory();
		
		enable();
		hideConsole();
		hideMonitor();
		hideProfiler();

		GC.logInfo("~~~~~~~~~~ GAME CONSOLE ~~~~~~~~~~ (v" + VERSION + ")");
	}
	
	
	public function showConsole() {
		visible = true;
		if (!enabled) {
			return;
		}
		interfc.showConsole();
	}

	public function hideConsole() {
		visible = false;
		if (!enabled) {
			return;
		}
		interfc.hideConsole();
	}

	
	public function enable() {
		enabled = true;
		if (visible) {
			interfc.showConsole();
		}
		if (monitor.visible) {
			interfc.showMonitor();
		} 
		if (profiler.visible) {
			interfc.showProfiler();
		}
		input.enable();
	}

	
	public function disable() {
		enabled = false;
		interfc.hideConsole();
		interfc.hideMonitor();
		interfc.hideProfiler();
		input.disable();
	}

	
	public function setToggleKey(key:Int) {
		toggleKey = key;
	}

	
	public function log(data:Dynamic, color:Int = -1) {
		
		if (data == "") {
			return;
		}
		
		interfc.log(data, color);
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
		} catch (e:Dynamic) {
			GC.logError("could not find field: " + fieldName);
			return;
		}
		
		monitor.addField(object, fieldName, alias);
	}
	
	
	public function toggleMonitor() {
		if (monitor.visible) {
			hideMonitor();
		} else {
			showMonitor();
		}
	}
	
	public function showMonitor() {
		hideProfiler();
		monitor.show();
		interfc.showMonitor();
	}
	
	public function hideMonitor() {
		monitor.hide();
		interfc.hideMonitor();
	}
	
	
	public function toggleProfiler() {
		if (profiler.visible) {
			hideProfiler();
		} else {
			showProfiler();
		}
	}
	
	public function showProfiler() {
		hideMonitor();
		profiler.show();
		interfc.showProfiler();
	}
	
	public function hideProfiler() {
		profiler.hide();
		interfc.hideProfiler();
	}

	
	public function prevHistory() {
		_historyIndex--;
		
		if (_historyIndex < 0) {
			_historyIndex = 0;
		}
		
		if (_historyIndex > _historyArray.length - 1) {
			return;
		}

		interfc.setInputTxt(_historyArray[_historyIndex]);
		interfc.moveCarretToEnd();
	}

	public function nextHistory() {
		
		if (_historyIndex + 1 > _historyArray.length - 1) {
			return;
		}
		
		_historyIndex++;

		interfc.setInputTxt(_historyArray[_historyIndex]);
		interfc.moveCarretToEnd();
	}


	public function processInputLine() {
		
		var currText = interfc.getInputTxt();
		// no input to process
		if (currText == '' || currText == null) {
			return;
		}
		
		// HISTORY
		_historyArray.insert(0, currText);
		resetHistoryIndex();
		
		// LOG AND CLEAN PROMPT
		log("> " + currText);
		interfc.clearInput();
		
		parseInput(currText);
	}
	
	// returns history index to beggining.
	public function resetHistoryIndex() {
		_historyIndex = -1;
	}
	
	public function scrollDown() {
		interfc.scrollConsoleDown();
	}
	
	public function scrollUp() {
		interfc.scrollConsoleUp();
	}
	
	public function autoComplete() {
		// remove white space added pressing CTRL + SPACE.
		interfc.inputRemoveLastChar();
		
		var autoC:Array<String> = GCUtil.autoComplete(interfc.getInputTxt());
		if (autoC != null)
		{
			if (autoC.length == 1) // only one entry in autocomplete - replace user entry.
			{
				interfc.setInputTxt(GCUtil.joinResult(interfc.getInputTxt(), autoC[0]));
				interfc.moveCarretToEnd();
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
