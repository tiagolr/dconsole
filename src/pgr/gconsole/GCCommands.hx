package pgr.gconsole;

import flash.errors.Error;
import flash.Lib;
import pgr.gconsole.GCCommands.Register;

typedef Register = {
	var name:String;
	var alias:String;
	var object:Dynamic;
	var monitor:Bool;
	var completion:String -> Array<String>;
}
/**
 * GCCommands contains the logic used by GameConsole to execute the commands
 * given by the user.
 *
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class GCCommands
{
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
		name : name,
		alias : alias,
		object : object,
		monitor : monitor,
		completion : null
		});
	}

	static public function registerFunction(object:Dynamic, name:String, alias:String, monitor:Bool, ?completionHandler:String -> Array<String>)
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
			completion : completionHandler,
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
			completion : null,
		});

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
	public static function showHelp() {
		var output : StringBuf = new StringBuf();
		output.add('\n');
		output.add("Type \"COMMANDS\" to view availible commands.\n");
		output.add("Use 'CTRL' + 'SPACE' for AUTO-COMPLETE .\n");
		output.add("Use 'PAGEUP' or 'PAGEDOWN' to scroll this console text.\n");
		output.add("Use 'UP' or 'DOWN' keys to view recent commands history.\n");
		output.add("Use 'CTRL' + 'CONSOLE SCKEY' to toggle monitor on/off.\n");
		GameConsole.logInfo(output);
	}

	public static function showCommands()
	{
		var output : StringBuf = new StringBuf();
		output.add('\n');
		output.add("CLEAR                       clears console view.\n");
		output.add("HELP                        shows help menu.\n");
		output.add("MONITOR                     toggles monitor on or off.\n");
		output.add("VARS                        lists availible variables.\n");
		output.add("FUNCS                       lists availible functions.\n");
		output.add("SET [variable] [value]      assigns value to variable.\n");
		output.add("CALL [function] [args]*     calls function.\n");
		
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
		var logMessage : StringBuf = new StringBuf();

		for ( o in _variables.iterator() ) 
			logMessage.add(o.alias + '=' + Reflect.getProperty(o.object, o.name) + "  |  ");
		
		if (logMessage.toString() == '') {
			GameConsole.logInfo("no variables registered.");
		} else
			GameConsole.logConfirmation(logMessage);
	}

	public static function listFunctions()
	{
		var list : StringBuf = new StringBuf();
		for (o in _functions.iterator()) 
			list.add(o.alias + '' + '\n'); 

		if (list.toString() == '') {
			GameConsole.logInfo("no functions registered.");
		} else
			GameConsole.logConfirmation(list);
	}

	public static function listObjects()
	{
		var list : StringBuf = new StringBuf();
		for (o in _objects.iterator()) 
			list.add(o.alias + '' + '\n'); 

		if (list.toString() == '') {
			GameConsole.logInfo("no objects registered.");
		} else 
			GameConsole.logConfirmation(list);
	}

	public static function getMonitorOutput():String
	{
		var output:StringBuf = new StringBuf();
		for (v in _variables.iterator())
			if (v.monitor)
				output.add(v.alias + ':' + Reflect.getProperty(v.object, v.name) + '\n');

		for (f in _functions.iterator())
			if (f.monitor)
				output.add(f.alias + ':' + Reflect.callMethod(null, Reflect.getProperty(f.object, f.name), null) + '\n');

		return Std.string(output);
	}

	public static function getFunctionNames():Array<String> {
		var out:Array<String> = [];
		for (f in _functions.iterator()) {
			out.push(f.alias);
		}
		return out;
	}

	public static function getFunction(alias:String):Register {
		if (_functions.exists(alias))
			return _functions.get(alias);
		return null;
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
