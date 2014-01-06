package pgr.gconsole;

import flash.display.MovieClip;
import flash.errors.Error;
import flash.Lib;

typedef Register = {
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
	
	public static var _Oldvariables:Array<Register> = new Array<Register>();
	public static var _Oldfunctions:Array<Register> = new Array<Register>();
	public static var _Oldobjects:Array<Register> = new Array<Register>();
	
	
	
	public static var _variables:Map<String, Register> = new Map<String, Register>();
	public static var _functions:Map<String, Register> = new Map<String, Register>();
	public static var _objects:Map<String, Register> = new Map<String, Register>();
	
	public function new() { }
	
	// ========================
	// ======   REGISTER  =====
	// ========================
	public static function registerVariable(object:Dynamic, name:String, alias:String, monitor:Bool)
	{
		if (alias == "")
		{
			alias = GCUtil.generateAlias("variable", object, name, alias);
		}
		
		if (_variables.exists(alias)) 
		{
			GameConsole.logWarning("variable " + alias + " overriden.");
		}
			
		_variables.set(alias, {
			name 	: name,
			alias	: alias,
			object	: object,
			monitor	: monitor,
		} );
	}
	
	static public function registerFunction(object:Dynamic, name:String, alias:String, monitor:Bool)
	{
		if (alias == "")
		{
			alias = GCUtil.generateAlias("function", object, name, alias);
		}
		
		if (_functions.exists(alias))
		{
			GameConsole.logWarning("function " + alias + " overriden");
		}
		_functions.set(alias, {
			name 	: name,
			alias	: alias,
			object	: object,
			monitor	: monitor,
		} );
	}
	
	static public function registerObject(object:Dynamic, alias:String)
	{
		if (alias == "")
		{
			alias = GCUtil.generateAlias("object", object, "", alias);
		}
		
		if (_objects.exists(alias))
		{
			GameConsole.logWarning("object " + alias + " overriden.");
		}

		_objects.set(alias, {
			name 	: "noName",
			alias	: alias,
			object	: object,
			monitor	: false,
		} );
			
	}
	// ========================
	// ====== UNREGISTER  =====
	// ========================
	public static function unregisterVariable(alias:String):Bool
	{
		if (_variables.exists(alias))
		{
			_variables.remove(alias);
			return true;
		}
		return false;
	}
	
		
	public static function unregisterFunction(alias:String):Bool
	{
		if (_functions.exists(alias))
		{
			_functions.remove(alias);
			return true;
		}
		return false;
	}
	
	public static function unregisterObject(alias:String):Bool
	{
		if (_objects.exists(alias))
		{
			_objects.remove(alias);
			return true;
		}
		return false;
	}
	
	// TODO - delete this.
	//static public function testMethod()
	//{
		//for (object in _objects) {
			//var arr:Array<String> = Type.getClassFields(Type.getClass(object.object));
			//for (str in arr) {
				//GameConsole.log(str);
			//}
		//}
		//
	//}
	
	public static function clearRegistry()
	{
		_variables  = new Map<String, Register>();
		_functions  = new Map<String, Register>();
		_objects	= new Map<String, Register>();
	}
	
	// ========================
	// =====   COMMANDS   =====
	// ========================
	public static function showHelp()
	{
		var output = '';
		output += '\n';
		output += "GAME CONSOLE v1.0\n\n";
		output += "Type \"commands\" to view availible commands.\n";
		output += "Use 'PAGEUP' or 'PAGEDOWN' to scroll this console text.\n";
		output += "Use 'UP' or 'DOWN' keys to view recent commands history.\n";
		output += "Use 'CTRL' + 'CONSOLE SCKEY' to toggle monitor on/off.\n";
		
		GameConsole.logInfo(output);
	}
	
	public static function showCommands()
	{
		var output = '';
		output += '\n';
		output += "CLEAR                       clears console view.\n";
		output += "HELP                        shows help menu.\n";
		output += "MONITOR                     toggles monitor on or off.\n";
		output += "VARS                        lists availible variables.\n";
		output += "FUNCS                        lists availible functions.\n";
		output += "SET [variable] [value]      assigns value to variable.\n";
		output += "CALL [function] [args]*     calls function.\n";
		
		GameConsole.logInfo(output);
	}

	public static function setVar(args:Array<String>)
	{
		if (args.length != 3) {
			GameConsole.logError("incorrect number of arguments.");
			return;
		}
		
		var objs = args[1].split('.');
		
		if (objs.length == 1) { // SET REGISTERED VARIABLE
			if (_variables.exists(args[1]))
			{
				var v:Register = _variables.get(args[1]);
				Reflect.setProperty(v.object, v.name, args[2]);
				GameConsole.logConfirmation(v.name + " set.");
			} else 
			{
				GameConsole.logError("variable " + args[1] + " not found.");
			}
		} else if (objs.length == 2) // SET VARIABLE INSIDE OBJECT
		{
			if (_objects.exists(objs[0]))
			{
				var o = _objects.get(objs[0]); // gets first object.
				try {
					Reflect.setProperty(o, objs[1], args[2]); // sets object property.
				} catch (e:Error) { 
					GameConsole.logError("Property " + objs[1] + " could not be set."); 
					return; 
				}
				GameConsole.logConfirmation(args[1] + " set.");
			} else
			{
				GameConsole.logError("object " + objs[0] + " not found.");
			}
		}
	}
		
	public static function callFunction(args:Array<String>)
	{
		if (args.length < 2) {
			GameConsole.logError("not enough arguments.");
			return;
		}
		var objs = args[1].split('.');
		
		if (objs.length == 1) { // CALL REGISTERED FUNCTION
			if (_functions.exists(args[1]))
			{
				var f = _functions.get(args[1]);
				args.splice(0, 2);
				Reflect.callMethod(null, Reflect.getProperty(f.object, f.name), args);
				GameConsole.logConfirmation(f.name + " called.");
			} else 
			{
				GameConsole.logError("function " + args[1] + " not found");
			}
		} else if (objs.length == 2) // CALL FUNCTION INSIDE OBJECT
		{
			if (_objects.exists(objs[0])) // gets first object.
			{
				var o = _objects.get(objs[0]);
				try {
					Reflect.callMethod(null, Reflect.getProperty(o, objs[1]), args); // calls object function.
				} catch (e:Error) {
					GameConsole.logError("function " + objs[1] + " could not be called."); 
					return; 
				}
				GameConsole.logConfirmation(args[1] + " called.");
			} else
			{
				GameConsole.logError("object " + objs[0] + " not found.");
			}
		}
	}

	public static function listVars()
	{
		var logMessage:String = '';
		
		for ( o in _variables.iterator() ) 
			logMessage += (o.alias + '=' + Reflect.getProperty(o.object, o.name) + "  |  ");
		
		if (logMessage == '') {
			logMessage = "no variables registered.";
			GameConsole.logInfo(logMessage);
		} else
			GameConsole.logConfirmation(logMessage);
	}
	
	public static function listFunctions()
	{
		var list = '';
		for (o in _functions.iterator()) 
			list += o.alias + '' + '\n'; 
			
		if (list == '') {
			list = "no functions registered.";
			GameConsole.logInfo(list);
		} else
			GameConsole.logConfirmation(list);
	}
	
	public static function listObjects()
	{
		var list = '';
		for (o in _objects.iterator()) 
			list += o.alias + '' + '\n'; 
			
		if (list == '') {
			list = "no objects registered.";
			GameConsole.logInfo(list);
		} else 
			GameConsole.logConfirmation(list);
	}
	
	public static function getMonitorOutput():String
	{
		var output:String = '';
		for (v in _variables.iterator())
			if (v.monitor)
				output += (v.alias + ':' + Reflect.getProperty(v.object, v.name) + '\n');
		
		for (f in _functions.iterator())
			if (f.monitor)
				output += (f.alias + ':' + Reflect.callMethod(null, Reflect.getProperty(f.object, f.name), null) + '\n');
				
		return output;
	}
	
	static public function getObject(alias:String) 
	{
		if (_objects.exists(alias))
		{
			return _objects.get(alias).object;
		}  
		return null;
	}
	//	AUX	------------------------------------------------------

}