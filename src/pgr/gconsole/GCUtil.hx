package pgr.gconsole;
import flash.errors.Error;
import pgr.gconsole.GCCommands.Register;

class GCUtil
{
	static public function autoComplete(input:String):Array<String>
	{
		//GameConsole.log("AUTOCOMPLETE " + input);
		
		var args:Array<String> = input.split(' ');
		var argsLC:Array < String > = input.toLowerCase().split(' ');
		var output:Array<String> = null;
		
		if ((argsLC[0] == "set" || argsLC[0] == "call") && argsLC.length == 2) {
			output = processInput(args[1], argsLC[0]);
		}
		
		return output;
	}
	
	static private function processInput(input:String, command:String):Array<String>
	{
		var listResults:Array<String> = null; // list of autocomplete results.
		var object:Dynamic;
		var args:Array<String> = input.split('.');
		
		// If there is at least one input after command, autocomplete will look 
		// for a registered object based on input, if no object is found, the 
		// output will be the list of all registered objects and functions matching
		// the input.
		object = null;
		if (args.length > 1)  
		{
			object = lookForObject(args); 
		}
		// call function
		if (command == "call")
		{
			if (object == null && args.length == 1) 
			{
				listResults = listRegFunctions(); // stores all functions.
			} 
			else 
			{
				listResults = autoCListFunctions(object); // stores all object functions.
			}
		}
		// set variable
		else if (command == "set")
		{
			if (object == null && args.length == 1)
			{
				listResults = listRegVariables(); // stores all variables.
			} 
			else 
			{
				listResults = autoCListVariables(object); // stores all object variables.
			}
		}
		// filter results
		if (listResults != null && listResults.length > 0)
		{
			autoCFilterResults(args[args.length - 1], listResults); // filter stored results according to input.
		}
		
		return listResults;
	}
	/**
	 * Using reflect on the input, looks for nested object until last input.
	 * 
	 * @param	args 	A list of words to search the object using reflect.
	 * @return			The object found or null.
	 */
	static public function lookForObject(args:Array<String>):Dynamic 
	{
		var object = GCCommands.getObject(args[0]);
		
		if (object == null) return null;
		
		args.shift();
		
		try {
		while (args.length > 1)
		{
			var temp = Reflect.getProperty(object, args[0]);
				
			if (Reflect.isObject(temp))
			{
				object = temp;
			} else
			{
				return null;
			}
			
			args.shift();
		} }
		catch ( e : Error )
		{ return null; } 
		
		return object;
	}
	
	static private function autoCFilterResults(input:String, listOptions:Array<String>) 
	{
		var i:Int = 0;
		var entry:String;
		while (i < listOptions.length)
		{
			entry = listOptions[i];
			i++;
			
			if (entry.length < input.length)
			{
				listOptions.remove(entry);
				i--;
				continue;
			}
			
			for (j in 0...input.length)
			{
				if (input.charAt(j) != entry.charAt(j)) 
				{
					listOptions.remove(entry);
					i--;
					break;
				}
			}
		}
	}
	
	static private function listRegFunctions():Array<String>
	{
		var results:Array<String> = new Array<String>();
		
		for (entry in GCCommands._functions) 
		{
			results.push(entry.alias);
		}
		
		for (entry in GCCommands._objects) 
		{
			results.push(entry.alias);
		}
		
		return results;
	}
	
	static private function listRegVariables():Array<String>
	{
		var results:Array<String> = new Array<String>();
		
		for (entry in GCCommands._variables) 
		{
			results.push(entry.alias);
		}
		
		for (entry in GCCommands._objects) 
		{
			results.push(entry.alias);
		}
		
		return results;
	}
	/**
	 * Lists all the methods of an object.
	 * 
	 * @param	object	
	 * @return
	 */
	static private function autoCListFunctions(object:Dynamic):Array<String>
	{
		var results:Array<String> = new Array<String>();

		if (object == null) // No object, list all functions.
		{
			return null; 
		}
			
		else 
		{
			var fields = Type.getInstanceFields(Type.getClass(object));
			
			var i:Int = results.length;
			
			for (s in fields)
			{
				try 
				{
					var property:Dynamic = Reflect.getProperty(object, s);
					if (Reflect.isFunction(property))
					{
						results.push(s);
					}
					//else
					//if (Type.getInstanceFields(Type.getClass(property)).length > 0)
					//{
						//results.push(s);
					//}
				}
				catch (e:Error) {}
			}
		}
		
		return results;
	}
	/**
	 * Lists all the fields of an object.
	 * If the input is null, lists all the registered functions and objects.
	 * 
	 * @param	object	
	 * @return
	 */
	static private function autoCListVariables(object:Dynamic):Array<String>
	{
		var results:Array<String> = new Array<String>();

		if (object == null) 
		{
			return null;
		}
		else 
		{
			var fields = Type.getInstanceFields(Type.getClass(object));
			
			var i:Int = results.length;
			
			for (s in fields)
			{
				try 
				{
					var property:Dynamic = Reflect.getProperty(object, s);
					if (!Reflect.isFunction(property))
					{
						results.push(s);
					} 
				}
				catch (e:Error) {}
			}
		}
		
		return results;
	}
	
	static public function joinResult(promptTxt:String, aCResult:String):String
	{
		if (aCResult == ".")
		{
			promptTxt += ".";
			return promptTxt;
		}
		
		var i:Int = aCResult.length;
		var index = -1;
		var temp:String;
		
		while (i > 0) // Looks for the closest match to the acResult, when found, removes it and adds the result to the string.
		{
			temp = aCResult.substr(0, i);
			index = promptTxt.lastIndexOf(temp);
			
			if (index != -1) 
			{
				promptTxt = promptTxt.substr(0, index); // Found a match
				promptTxt += aCResult;
				return promptTxt;
			}
			
			i--;
		}
		
		return promptTxt;
	}

	static public function generateAlias(type:String, object:Dynamic, name:String="", alias:String) 
	{
		var map:Map<String,Register>;
		var autoAlias:String;
		switch (type)
		{
			case "function" : 
							map = GCCommands._functions;
							autoAlias = Type.getClassName(Type.getClass(object)).toLowerCase() + "_" + name;
			case "variable" : 
							map = GCCommands._variables;
							autoAlias = Type.getClassName(Type.getClass(object)).toLowerCase() + "_" + name;
			case "object"	: 
							map = GCCommands._objects;
							autoAlias = Type.getClassName(Type.getClass(object)).toLowerCase();
							
			default 		: throw "Unknown alias type: " + type;
		}
		
		
		var i:Int = 1;
		while (true)
		{
			if (map.exists(autoAlias))
			{
				if (i > 1)
					autoAlias = autoAlias.substring(0, autoAlias.length - Std.string(i).length - 1); // removes added number
				autoAlias += "_" + Std.string(i) ;
				i++;
			}
			else 
			{
				break;
			}
		}
		
		return autoAlias;
	}
	
}