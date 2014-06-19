package pgr.dconsole ;

import pgr.dconsole.DCThemes.Theme;

/**
 * DConsole is the main class of this lib, it should be instantiated only once
 * and then use its instance to control the console.
 * 
 * Its recomended to use DC class as API for this lib.
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class DConsole {

	inline static public var VERSION = "4.0.0";
	
	/** Aligns console to bottom */
	static public var ALIGN_DOWN:String = "DOWN";
	/** Aligns console to top */
	static public var ALIGN_UP:String = "UP";

	private var _historyArray:Array<String>;
	private var _historyIndex:Int;
	public var interfc:DCInterface;
	public var monitor:DCMonitor;
	public var profiler:DCProfiler;

	/** shortcutkey to show/hide console. */ 
	public var toggleKey:Int = 9; 
	public static var instance:DConsole;
	
	public var enabled(default, null):Bool;
	public var visible(default, null):Bool;
	
	public var input:DCInput;
	
	
	public function new(height:Float = 0.33, align:String = "DOWN", theme:DCThemes.Theme = null, monitorRate:Int = 10) {
		
		if (instance != null) {
			return;
		}
		instance = this;
		
		if (theme == null) {
			DCThemes.current = DCThemes.DARK;
		} else {
			DCThemes.current = theme;
		}

		if (height > 1) height = 1;
		if (height < 0.1) height = 0.1;
		
		// create input
		input = new DCInput();
		
		// create monitor
		monitor = new DCMonitor();
		
		// create profiler
		profiler = new DCProfiler();
		
		// create console interface
		interfc = new DCInterface(height, align);
		
		DCCommands.init();

		clearHistory();
		
		enable();
		hideConsole();
		hideMonitor();
		hideProfiler();

		DCCommands.registerCommand(DCCommands.showHelp, "help", "", "Type HELP [command-name] for more info");
		DCCommands.registerCommand(DCCommands.showCommands, "commands", "", "Shows availible commands", "Type HELP [command-name] for more info");
		DCCommands.registerCommand(DCCommands.listFunctions, "functions", "funcs", "Lists registered functions", "To call a function type functionName( args ), make sure the args type and number are correct");
		DCCommands.registerCommand(DCCommands.listObjects, "objects", "objs", "Lists registered objects", "To print an object field type object.field\nTo set and object field type object.field = value");
		DCCommands.registerCommand(clearConsole, "clear", "", "Clears console view");
		DCCommands.registerCommand(toggleMonitor, "monitor", "", "Toggles monitor on and off", "Monitor is used to track variable values in runtime\nCONTROL + CONSOLE_KEY (default TAB) also toggles monitor");
		DCCommands.registerCommand(toggleProfiler, "profiler", "", "Toggles profiler on and off", "Profiler is used to profile app and view statistics like time elapsed and percentage in runtime\nSHIFT + CONSOLE_KEY (default TAB) also toggles profiler");
		
		DC.logInfo("~~~~~~~~~~ DCONSOLE ~~~~~~~~~~ (v" + VERSION + ")");
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
		
		if (!Std.is(data,Float) && !Std.is(data,Bool) && data == "") {
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
			DC.logError("invalid fieldName");
			return;
		}
		
		if (alias == null || alias == "") {
			DC.logError("invalid alias");
			return;
		}
		
		if (object == null || !Reflect.isObject(object)) {
			DC.logError("invalid object.");
			return;
		}
		
		try {
			Reflect.getProperty(object, fieldName);
		} catch (e:Dynamic) {
			DC.logError("could not find field: " + fieldName);
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
		
		DCCommands.evaluate(currText);
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
		
		var autoC:Array<String> = DCUtil.autoComplete(interfc.getInputTxt());
		if (autoC != null)
		{
			if (autoC.length == 1) // only one entry in autocomplete - replace user entry.
			{
				interfc.setInputTxt(DCUtil.joinResult(interfc.getInputTxt(), autoC[0]));
				interfc.moveCarretToEnd();
			}
			else	// many entries in autocomplete, list them all.
			{
				DC.log(" "); // new line.
				for (entry in autoC)
				{
					DC.logInfo(entry);
				}
			}
		}
	}
	
}
