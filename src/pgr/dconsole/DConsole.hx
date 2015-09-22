package pgr.dconsole;

#if js
import js.Lib;
#end
import pgr.dconsole.DCThemes.Theme;
import pgr.dconsole.input.DCInput;
import pgr.dconsole.input.DCEmptyInput;
import pgr.dconsole.ui.DCInterface;
import pgr.dconsole.ui.DCEmtpyInterface;


#if openfl
import pgr.dconsole.ui.DCOpenflInterface;
import pgr.dconsole.input.DCOpenflInput;
#end

typedef SCKey = {
	altKey:Bool,
	ctrlKey:Bool,
	shiftKey:Bool,
	keycode:Int,
}

/**
 * DConsole is the main class of this lib, it should be instantiated only once
 * and then use its instance to control the console.
 * 
 * Its recomended to use DC class as API for this lib.
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class DConsole {

	/** Aligns console to bottom */
	static public var ALIGN_DOWN:String = "DOWN";
	/** Aligns console to top */
	static public var ALIGN_UP:String = "UP";

	private var _historyArray:Array<String>;
	private var _historyIndex:Int;
	public var input:DCInput;
	public var interfc:DCInterface;
	public var monitor:DCMonitor;
	public var profiler:DCProfiler;
	public var commands:DCCommands;

	/** console toggle key */ 
	public var consoleKey:SCKey;
	/** monitor toggle key */
	public var monitorKey:SCKey;
	/** profiler toggle key */
	public var profilerKey:SCKey;
	
	public var enabled(default, null):Bool;
	public var visible(default, null):Bool;
	
	
	
	public function new(input:DCInput = null, interfc:DCInterface = null, theme:DCThemes.Theme = null) {
		
		if (input == null) {
			#if (openfl && !js)
			input = new DCOpenflInput();
			#else
			input = new DCEmptyInput();
			#end
		}
		
		if (interfc == null) {
			#if (openfl && !js)
			interfc = new DCOpenflInterface(33, "DOWN");
			#else
			interfc = new DCEmtpyInterface();
			#end
		}
		
		if (theme == null) {
			DCThemes.current = DCThemes.DARK;
		} else {
			DCThemes.current = theme;
		}
		
		// default key is tab
		setConsoleKey(9);
		// default key is ctrl + tab
		setMonitorKey(9, true);
		// default key is shift + tab
		setProfilerKey(9, false, true);
		
		// create monitor
		monitor = new DCMonitor(this);
		
		// create profiler
		profiler = new DCProfiler(this);
		
		// create input
		this.input = input;
		input.console = this;
		input.init();
		
		// create console interface
		this.interfc = interfc;
		interfc.console = this;
		interfc.init();
		
		commands = new DCCommands(this);

		clearHistory();
		
		enable();
		hideConsole();
		hideMonitor();
		hideProfiler();

		commands.registerCommand(commands.showHelp, "help", "", "Type HELP [command-name] for more info");
		commands.registerCommand(commands.showCommands, "commands", "", "Shows available commands", "Type HELP [command-name] for more info");
		commands.registerCommand(commands.listFunctions, "functions", "funcs", "Lists registered functions", "To call a function type functionName( args ), make sure the args type and number are correct");
		commands.registerCommand(commands.listObjects, "objects", "objs", "Lists registered objects", "To print an object field type object.field\nTo set and object field type object.field = value");
		commands.registerCommand(commands.listClasses, "classes", "", "Lists registered classes", "Registered classes can access their static fields and methods, eg: Math.abs(value), or Math.PI");
		commands.registerCommand(clearConsole, "clear", "", "Clears console view");
		commands.registerCommand(toggleMonitor, "monitor", "", "Toggles monitor on and off", "Monitor is used to track variable values in runtime\nCONTROL + CONSOLE_KEY (default TAB) also toggles monitor");
		commands.registerCommand(toggleProfiler, "profiler", "", "Toggles profiler on and off", "Profiler is used to profile app and view statistics like time elapsed and percentage in runtime\nSHIFT + CONSOLE_KEY (default TAB) also toggles profiler");
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

	public function setConsoleKey(keyCode:Int, ctrlKey:Bool = false, shiftKey:Bool = false, altKey:Bool = false) {
		consoleKey = makeShorcutKey(keyCode, ctrlKey, shiftKey, altKey); 
	}
	
	public function setMonitorKey(keyCode:Int, ctrlKey:Bool = false, shiftKey:Bool = false, altKey:Bool = false) {
		monitorKey = makeShorcutKey(keyCode, ctrlKey, shiftKey, altKey); 
	}
	
	public function setProfilerKey(keyCode:Int, ctrlKey:Bool = false, shiftKey:Bool = false, altKey:Bool = false) {
		profilerKey = makeShorcutKey(keyCode, ctrlKey, shiftKey, altKey); 
	}
	
	function makeShorcutKey(keyCode:Int, ctrlKey:Bool = false, shiftKey:Bool = false, altKey:Bool = false):SCKey {
		return {
			altKey:altKey,
			ctrlKey:ctrlKey,
			shiftKey:shiftKey,
			keycode:keyCode,
		}
	}

	
	public function log(data:Dynamic, color:Int = -1) {
		
		if (!Std.is(data, Float) && !Std.is(data, Bool) && data == "") {
			return;
		}
		
		interfc.log(data, color);
		
		#if js
		// dispatches log inside a js event
		var scolor = StringTools.hex(color, 6);
		var s = Std.string(data);

		// js Lib.eval does not support \n in strings, so split the string and log each line.
		s = StringTools.replace(s, "\n", "\\n");
		Lib.eval (
				'var event = new CustomEvent("console_log", { detail: { data:"' + s + '", color:"' + scolor + '" }}); ' +
				'document.dispatchEvent(event);'
			);
		#end
	}
	
	public function logConfirmation(data:Dynamic) {
		log(data, DCThemes.current.LOG_CON);
	}
	
	public function logInfo(data:Dynamic) {
		log(data, DCThemes.current.LOG_INF);
	}
	
	public function logError(data:Dynamic) {
		log(data, DCThemes.current.LOG_ERR);
	}
	
	public function logWarning(data:Dynamic) {
		log(data, DCThemes.current.LOG_WAR);
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
			logError("invalid fieldName");
			return;
		}
		
		if (alias == null || alias == "") {
			logError("invalid alias");
			return;
		}
		
		if (object == null || !Reflect.isObject(object)) {
			logError("invalid object.");
			return;
		}
		
		try {
			Reflect.getProperty(object, fieldName);
		} catch (e:Dynamic) {
			logError("could not find field: " + fieldName);
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
		
		commands.evaluate(currText);
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
	
}
