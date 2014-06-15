package pgr.gconsole;

import hscript.Expr.Error;
import hscript.Interp;
import hscript.Parser;


typedef Command = {
	callback:Array<String>->Void, 	// the command callback receiving the list of arguments as a parameter
	alias:String, 					// the command name (must be unique)
	shortcut:String, 				// (optional) another key input to call this command (must also be unique)
	description:String, 			// short description of what the command does
	help:String, 					// extended description on how to use the command
}

/**
 * GCCommands contains the logic used by GC to execute the commands
 * given by the user.
 *
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
@:access(hscript.Interp)
class GCCommands
{
	public static var functionsMap:Map<String, Dynamic> = new Map<String, Dynamic>();
	public static var objectsMap:Map<String, Dynamic> = new Map<String, Dynamic>();
	public static var commandsMap:Map < String, Command > = new Map < String, Command > ();
	
	private static var hScriptParser:Parser;
	private static var hScriptInterp:GCInterp;
	

	static public function init() {
		hScriptParser = new Parser();
		hScriptInterp = new GCInterp();
		hScriptInterp.variables.set("objectsMap", objectsMap);
		hScriptInterp.variables.set("Math", Math);
	}
	
	
	static public function evaluate(input:String) {
		
		/** 
		 * If the first word is a registered command, 
		 * send the input (as tokens) to the command and let it 
		 * process the input
		 */
		var args:Array<String> = input.split(' ');
		var commandName = args[0].toLowerCase();
		
		if (commandName == null || commandName == '') {
			return; 
		}
		
		for (command in commandsMap.iterator()) {
			if (commandName == command.alias || commandName == command.shortcut) {
				args.shift();
				command.callback(args);
				return;
			}
		}
		
		/** Else the input is processed by hscript interpreter */
		try {
			var program = hScriptParser.parseString(input + ";");
			
			// using exprReturn instead of execute to skip interp internal state reset.
			var result = hScriptInterp.exprReturn(program); 
			if (Std.is(result, Float) || result != null) {
				GC.logConfirmation(result);
			}
			
		} catch (e:Dynamic) {
			GC.logError(Std.string(e));
		} 
		
	}
	
	static public function registerCommand(Function:Array<String>->Void,
										   alias:String, 
										   shortcut:String = "",
										   description:String = "",
										   help:String = "") 
	{
		// TODO - sanitize shortcut and alias
		var command:Command = { 
			callback:Function,
			alias:alias,
			shortcut:shortcut,
			description:description,
			help:help
		}
		
		commandsMap.set(alias, command);
	}
										   
										   
	
	static public function registerFunction(Function:Dynamic, alias:String) {
		
		
		if (!Reflect.isFunction(Function)) {
			GC.logError("Function " + Std.string(Function) + " is not valid.");
			return;
		}
		
		// override existing function
		if (functionsMap.exists(alias)) {
			GC.logWarning("function " + alias + " overriden");
		}
		
		functionsMap.set(alias, Function);
		hScriptInterp.variables.set(alias, Function); // registers var in hscript
	}
	
	
	static public function registerObject(object:Dynamic, alias:String) {
		
		if (!Reflect.isObject(object)) {
			GC.logError("dynamic passed is not an object.");
			return;
		}
		
		if (alias == "") {
			alias = GCUtil.generateObjectAlias(object);
		}

		if (objectsMap.exists(alias)) {
			GC.logWarning("object " + alias + " overriden.");
		}
		
		objectsMap.set(alias, object);
		hScriptInterp.variables.set(alias, object); // registers var in hscript
		
	}

	
	public static function unregisterFunction(alias:String) {
		
		if (functionsMap.exists(alias)) {
			functionsMap.remove(alias);
			hScriptInterp.variables.remove(alias);
			GC.logInfo(alias + " unregistered.");
		}
		GC.logError(alias + " not found.");
	}
	
	
	public static function unregisterObject(alias:String) {
		
		if (objectsMap.exists(alias)) {
			objectsMap.remove(alias);
			hScriptInterp.variables.remove(alias); // registers var in hscript
			GC.logInfo(alias + " unregistered.");
		}
		GC.logError(alias + " not found.");
	}
	
	
	public static function clearRegistry() {
		functionsMap  = new Map<String, Dynamic>();
		objectsMap	= new Map<String, Dynamic>();
	}

	
	//-------------------------------------------------------------------------------
	//  CONSOLE RUNTIME COMMANDS
	//-------------------------------------------------------------------------------
	public static function showHelp(args:Array<String>) {
		var output :String = "\n";
		
		if (args.length > 0) {
			
			// print command help
			var commandName = args[0].toLowerCase();
			if (commandName != null && commandName != '') {
				for (command in commandsMap.iterator()) {
					if (commandName == command.alias || commandName == command.shortcut) {
						args.shift();
						command.callback(args);
						
						output += command.alias.toUpperCase();
						if (command.shortcut != "") 
							output += ' ' + '(' + command.shortcut.toUpperCase() + ')\n';
						output += command.description + '\n\n';
						output += command.help		  + '\n';
						GC.logInfo(output);
						return;
					}
				}
			} else {
				GC.logWarning("Command name not found");
				return;
			}
			
		}  else {
			// print normal help
			output += "Type COMMANDS to view availible commands\n"; 
			output += "'PAGEUP' or 'PAGEDOWN' keys to scroll text\n";
			output += "'UP' or 'DOWN' keys to navigate history\n";
			GC.logInfo(output);
		}
	}

	
	public static function showCommands(args:Array<String>) {
		var output:String = "";
		
		for (command in commandsMap.iterator()) {
			var line:String = command.alias.toUpperCase();
			if (command.shortcut != "") 
				line += ' ' + '(' + command.shortcut.toUpperCase() + ')';
			line = StringTools.rpad(line, ' ', 20);
			line += command.description + '\n';
			output += line;
		}
		
		GC.logInfo(output);
	}
	

	public static function listFunctions(args:Array<String>) {
		var list = "";
		for (key in functionsMap.keys()) {
			list += key + '\n'; 
		}

		if (list.toString() == "") {
			GC.logInfo("no functions registered.");
			return;
		} 
		
		GC.logConfirmation(list);
	}

	
	public static function listObjects(args:Array<String>)
	{
		var list = "";
		for (key in objectsMap.keys())  {
			list += key + '\n'; 
		}

		if (list.toString() == '') {
			GC.logInfo("no objects registered.");
			return;
		} 
		
		GC.logConfirmation(list);
	}

	
	//---------------------------------------------------------------------------------
	//  AUX
	//---------------------------------------------------------------------------------
	public static function getFunction(alias:String):Dynamic {
		if (functionsMap.exists(alias))
			return functionsMap.get(alias);
		return null;
	}

	
	public static function getObject(alias:String) {
		if (objectsMap.exists(alias)) {
			return objectsMap.get(alias);
		}
		return null;
	}
	
	
	
}
