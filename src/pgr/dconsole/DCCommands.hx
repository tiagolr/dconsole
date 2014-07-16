package pgr.dconsole;

import haxe.CallStack;
import hscript.Expr.Error;
import hscript.Interp;
import hscript.Parser;
import pgr.dconsole.DCUtil.ALIAS_TYPE;


typedef Command = {
	callback:Array<String>->Void, 	// the command callback receiving the list of arguments as a parameter
	alias:String, 					// the command name (must be unique)
	shortcut:String, 				// (optional) another key input to call this command (must also be unique)
	description:String, 			// short description of what the command does
	help:String, 					// extended description on how to use the command
}

/**
 * DCCommands contains the logic used by GC to execute the commands
 * given by the user.
 *
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
@:access(hscript.Interp)
class DCCommands
{
	public var functionsMap:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var objectsMap:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var commandsMap:Map < String, Command > = new Map < String, Command > ();
	
	public var hScriptParser:Parser;
	public var hScriptInterp:DCInterp;
	
	public var printErrorStack:Bool = false;

	public function new() {
		hScriptParser = new Parser();
		hScriptParser.allowJSON = true;
		hScriptInterp = new DCInterp();
		hScriptInterp.variables.set("objectsMap", objectsMap);
		hScriptInterp.variables.set("Math", Math);
	}
	
	/**
	 * Evaluates input: 
	 * If the first word is a registered command,
	 * call that command and send rest of input as arguments (tokens)
	 * Otherwise let the interpreter handle the input.
	 */
	public function evaluate(input:String) {
		
		var args:Array<String> = input.split(' ');
		var commandName = args[0].toLowerCase();
		if (commandName != null && commandName != '') {
			for (command in commandsMap.iterator()) {
				if (commandName == command.alias || commandName == command.shortcut) {
					
					// Command found, execute command instead of using hscrit interp
					args.shift();
					command.callback(args);
					return;
				}
			}
		}
		
		// hscript interp handle input
		try {
			if (StringTools.endsWith(StringTools.trim(input), ";") == false) {
				input = StringTools.trim(input) + ";";
			}
			var program = hScriptParser.parseString(input);
			
			// using exprReturn instead of execute to skip interp internal state reset.
			var result = hScriptInterp.exprReturn(program); 
			if (Std.is(result, Float) || Std.is(result, Bool) || result != null) { 
				DC.logConfirmation(result);
			}
			
		} 
		catch (e:Dynamic) {
			if (printErrorStack) {
				var stack = CallStack.exceptionStack();
				for (entry in stack) {
					DC.log(entry);
				}
			}
			DC.logError(Std.string(e));
		} 
		
	}
	
	public function registerCommand(Function:Array<String>->Void,
										   alias:String, 
										   shortcut:String = "",
										   description:String = "",
										   help:String = "") 
	{
		if (!Reflect.isFunction(Function)) {
			DC.logError("Command function " + Std.string(Function) + " is not valid.");
			return;
		}
		
		alias = DCUtil.formatAlias(this, alias, ALIAS_TYPE.COMMAND);
		if (alias == null) {
			DC.log("Failed to register command, make sure alias or shortcut is correct");
			return;
		}
		
		if (shortcut != "") {
			shortcut = DCUtil.formatAlias(this, shortcut, ALIAS_TYPE.COMMAND);
			// failed to validade this
			if (shortcut == null) {
				shortcut = ""; // no shortcut
			}
		}
		
		var command:Command = { 
			callback:Function,
			alias:alias,
			shortcut:shortcut,
			description:description,
			help:help
		}
		
		commandsMap.set(alias, command);
	}
										   
										   
	
	public function registerFunction(Function:Dynamic, alias:String) {
		
		if (!Reflect.isFunction(Function)) {
			DC.logError("Function " + Std.string(Function) + " is not valid.");
			return;
		}
		
		alias = DCUtil.formatAlias(this, alias, ALIAS_TYPE.FUNCTION);
		if (alias == null) {
			DC.logError("Function " + Std.string(Function) + " alias not valid");
			return;
		}
		
		functionsMap.set(alias, Function);
		hScriptInterp.variables.set(alias, Function); // registers var in hscript
	}
	
	
	public function registerObject(object:Dynamic, alias:String) {
		
		if (!Reflect.isObject(object)) {
			DC.logError("dynamic passed is not an object.");
			return;
		}
		
		if (alias == "") {
			alias = DCUtil.formatAlias(this, Type.getClassName(Type.getClass(object)).toLowerCase(), ALIAS_TYPE.OBJECT);
		} else {
			alias = DCUtil.formatAlias(this, alias, ALIAS_TYPE.OBJECT);
		}
		
		if (alias == null) {
			DC.logError("failed to register object " + Type.getClassName(Type.getClass(object)) + " make sure object alias is correct");
			return;
		}
		
		objectsMap.set(alias, object);
		hScriptInterp.variables.set(alias, object); // registers var in hscript
		
	}

	
	public function unregisterFunction(alias:String) {
		
		if (functionsMap.exists(alias)) {
			functionsMap.remove(alias);
			hScriptInterp.variables.remove(alias);
			DC.logInfo(alias + " unregistered.");
		}
		DC.logError(alias + " not found.");
	}
	
	
	public function unregisterObject(alias:String) {
		
		if (objectsMap.exists(alias)) {
			objectsMap.remove(alias);
			hScriptInterp.variables.remove(alias); // registers var in hscript
			DC.logInfo(alias + " unregistered.");
		}
		DC.logError(alias + " not found.");
	}
	
	
	public function clearRegistry() {
		functionsMap  = new Map<String, Dynamic>();
		objectsMap	= new Map<String, Dynamic>();
	}

	
	//-------------------------------------------------------------------------------
	//  CONSOLE RUNTIME COMMANDS
	//-------------------------------------------------------------------------------
	public function showHelp(args:Array<String>) {
		var output :String = "\n";
		
		if (args.length > 0) {
			
			// print command help
			var commandName = args[0].toLowerCase();
			if (commandName != null && commandName != '') {
				for (command in commandsMap.iterator()) {
					if (commandName == command.alias || commandName == command.shortcut) {	
						output += "command: " + command.alias.toUpperCase() + '\n';
						if (command.shortcut != "") 
							output += "shortcut: " + '' + command.shortcut.toUpperCase() + '\n';
						output += command.description + '\n\n';
						output += command.help		  + '\n';
						DC.logInfo(output);
						return;
					}
				}
			} else {
				DC.logWarning("Command name not found");
				return;
			}
			
		}  else {
			// print normal help
			output += "Type COMMANDS to view availible commands\n"; 
			output += "'PAGEUP' or 'PAGEDOWN' keys to scroll text\n";
			output += "'UP' or 'DOWN' keys to navigate history\n";
			DC.logInfo(output);
		}
	}

	
	public function showCommands(args:Array<String>) {
		var output:String = "";
		
		for (command in commandsMap.iterator()) {
			var line:String = command.alias.toUpperCase();
			if (command.shortcut != "") 
				line += ' ' + '(' + command.shortcut.toUpperCase() + ')';
			line = StringTools.rpad(line, ' ', 20);
			line += command.description + '\n';
			output += line;
		}
		
		DC.logInfo(output);
	}
	

	public function listFunctions(args:Array<String>) {
		var list = "";
		for (key in functionsMap.keys()) {
			list += key + '\n'; 
		}

		if (list.toString() == "") {
			DC.logInfo("no functions registered.");
			return;
		} 
		
		DC.logConfirmation(list);
	}

	
	public function listObjects(args:Array<String>)
	{
		var list = "";
		for (key in objectsMap.keys())  {
			list += key + '\n'; 
		}

		if (list.toString() == '') {
			DC.logInfo("no objects registered.");
			return;
		} 
		
		DC.logConfirmation(list);
	}

	
	//---------------------------------------------------------------------------------
	//  AUX
	//---------------------------------------------------------------------------------
	public function getFunction(alias:String):Dynamic {
		return functionsMap[alias];
	}

	
	public function getObject(alias:String) {
		return objectsMap[alias];
	}
	
	public function getCommand(alias:String):Command {
		alias = alias.toLowerCase();
		for (command in commandsMap.iterator()) {
			if (command.alias == alias || command.shortcut == alias) {
				return command;
			}
		}
		return null;
	}
	
}
