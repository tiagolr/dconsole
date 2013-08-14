package pgr.gconsole;

import flash.display.MovieClip;
import flash.Lib;

 typedef RemoteObj = {
	 var name	: String;
	 var alias	: String;
	 var object	: Dynamic;
	 var monitor: Bool;
 }
 /**
 * GCCommands contains the logic used by GameConsole to execute the commands
 * given by the user.
 *
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class GCCommands
{
	inline static private var GC_LOG_ERR = "";
	inline static private var GC_LOG_WAR = "";

	private static var _variables:Array<RemoteObj> = new Array<RemoteObj>();
	private static var _functions:Array<RemoteObj> = new Array<RemoteObj>();

	public function new() { }

	public static function registerVariable(object:Dynamic, name:String, alias:String, monitor:Bool):String
	{
		var aliasAlreadyExists = unregisterVariable(alias); // Used to remove duplicates.

		_variables.push( {
			name 	: name,
			alias	: alias,
			object	: object,
			monitor	: monitor,
		} );

		if (aliasAlreadyExists)
			return (GC_LOG_WAR + "alias " + alias + " for variable " + name + " already exists and will be overriden.");
		else
			return '';
	}

	public static function unregisterVariable(alias:String):Bool
	{
		for (i in 0..._variables.length) {
			if (_variables[i].alias == alias) {
				_variables.splice(i, 1);
				return true;
			}
		}
		return false;
	}

	static public function registerFunction(object:Dynamic, name:String, alias:String, monitor:Bool):String
	{
		var aliasAlreadyExists = unregisterFunction(alias); // Used to remove duplicates

		_functions.push( {
			name 	: name,
			alias	: alias,
			object	: object,
			monitor	: monitor,
		} );

		if (aliasAlreadyExists)
			return (GC_LOG_WAR + "alias " + alias + " for function " + name + " already exists and will be overriden");
		else
			return '';
	}

	public static function unregisterFunction(alias:String):Bool
	{
		for (i in 0..._functions.length) {
			if (_functions[i].alias == alias) {
				_functions.splice(i, 1);
				return false;
			}
		}
		return false;
	}

	public static function clearRegistry()
	{
		_variables = new Array<RemoteObj>();
		_functions = new Array<RemoteObj>();
	}

	// ------------------------------------------------------------------------------
	//	CONSOLE COMMANDS
	// ------------------------------------------------------------------------------
	public static function showHelp():String
	{
		var output : StringBuf = new StringBuf();
		output.add('\n');
		output.add("GAME CONSOLE v1.0\n\n");
		output.add("Type \"commands\" to view availible commands.\n");
		output.add("Use 'PAGEUP' or 'PAGEDOWN' to scroll this console text.\n");
		output.add("Use 'UP' or 'DOWN' keys to view recent commands history.\n");
		output.add("Use 'CTRL' + 'CONSOLE SCKEY' to toggle monitor on/off.\n");
		return Std.string(output);
	}

	public static function showCommands():String
	{
		var output : StringBuf = new StringBuf();
		output.add('\n');
		output.add("CLEAR                       clears console view.\n");
		output.add("HELP                        shows help menu.\n");
		output.add("MONITOR                     toggles monitor on or off.\n");
		output.add("VARS                        lists availible variables.\n");
		output.add("FCNS                        lists availible functions.\n");
		output.add("SET [variable] [value]      assigns value to variable.\n");
		output.add("CALL [function] [args]*     calls function.\n");
		return Std.string(output);
	}

	public static function setVar(args:Array<String>):String
	{
		if (args.length != 3) {
			return logIncorrectNumberArguments();
		}

		for (i in 0..._variables.length) {
			if (_variables[i].alias == args[1]) {
				Reflect.setProperty(_variables[i].object, _variables[i].name, args[2]);
				return "ok";
			}
		}

		return GC_LOG_ERR + "variable not found.";

	}

	public static function callFunction(args:Array<String>):String
	{
		if (args.length < 2) {
			return (logIncorrectNumberArguments());

		}

		for (i in 0..._functions.length) {
			if (_functions[i].alias == args[1]) {

				args.splice(0, 2);
				Reflect.callMethod(null, Reflect.getProperty(_functions[i].object, _functions[i].name), args);

				return "ok";
			}
		}

		return "function " + args[1] + " not found";
	}

	public static function listVars():String
	{
		var logMessage : StringBuf = new StringBuf();
		for (i in 0..._variables.length)
			logMessage.add(_variables[i].alias + '=' + Reflect.getProperty(_variables[i].object, _variables[i].name) + "  |  ");

		return Std.string(logMessage);
	}

	public static function listFunctions():String
	{
		var list : StringBuf = new StringBuf();
		for (i in 0..._functions.length)
			list.add(_functions[i].alias + '' + '\n');

		return Std.string(list);
	}

	public static function getMonitorOutput():String
	{
		var output:StringBuf = new StringBuf();
		for (i in 0..._variables.length)
			if (_variables[i].monitor)
				output.add(_variables[i].alias + ':' + Std.string(Reflect.getProperty(_variables[i].object, _variables[i].name)) + '\n');

		for (i in 0..._functions.length)
			if (_functions[i].monitor)
				output.add(_functions[i].alias + ':' + Std.string(Reflect.callMethod(null, Reflect.getProperty(_functions[i].object, _functions[i].name), [])) + '\n');

		return Std.string(output);
	}
	//	AUX	------------------------------------------------------

	private static function logIncorrectNumberArguments():String
	{
		return GC_LOG_ERR + "incorrect number of arguments.";
	}
}
