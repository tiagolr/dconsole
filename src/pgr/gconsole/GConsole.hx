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

	inline static public var VERSION = "4.0.0";
	
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
		
		GCCommands.init();

		clearHistory();
		
		enable();
		hideConsole();
		hideMonitor();
		hideProfiler();

		GCCommands.registerCommand(GCCommands.showHelp, "help", "", "Type HELP [command-name] for more info");
		GCCommands.registerCommand(GCCommands.showCommands, "commands", "", "Shows availible commands", "Type HELP [command-name] for more info");
		GCCommands.registerCommand(GCCommands.listFunctions, "functions", "funcs", "Lists registered functions", "To call a function type functionName( args ), make sure the args type and number are correct");
		GCCommands.registerCommand(GCCommands.listObjects, "objects", "objs", "Lists registered objects", "To print an object field type object.field\nTo set and object field type object.field = value");
		GCCommands.registerCommand(clearConsole, "clear", "", "Clears console view");
		GCCommands.registerCommand(toggleMonitor, "monitor", "", "Toggles monitor on and off", "Monitor is used to track variable values in runtime\nCONTROL + CONSOLE_KEY (default TAB) also toggles monitor");
		GCCommands.registerCommand(toggleProfiler, "profiler", "", "Toggles profiler on and off", "Profiler is used to profile app and view statistics like time elapsed and percentage in runtime\nSHIFT + CONSOLE_KEY (default TAB) also toggles profiler");
		
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
		
		if (!Std.is(data,Float) && data == "") {
			return;
		}
		
		interfc.log(data, color);
	}
	
	/**
	 * Clears input text;
	 */
	public function clearConsole(args:Array<String> = null) {
		interfc.clearConsole();
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
	
	
	public function toggleMonitor(args:Array<String> = null) {
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
	
	
	public function toggleProfiler(args:Array<String> = null) {
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
		
		GCCommands.evaluate(currText);
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
	
}
