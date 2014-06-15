package pgr.gconsole;


enum ALIAS_TYPE {
	COMMAND;
	OBJECT;
	FUNCTION;
}

class GCUtil
{
	
	
	static public function autoComplete(input:String):Array<String>
	{
		var args:Array<String> = input.split(' ');
		var argsLC:Array<String> = input.toLowerCase().split(' ');
		var output:Array<String> = null;
		
		if ((argsLC[0] == "set" || argsLC[0] == "call" || argsLC[0] == "print") && argsLC.length == 2) {
			output = processInput(args[1], argsLC[0]);
		}
		
		return output;
	}
	
	static function processInput(input:String, command:String):Array<String>
	{
		var listResults:Array<String> = null; // list of autocomplete results.
		var object:Dynamic = null;
		var args:Array<String> = input.split('.');
		
		if (args.length > 1)  
		{
			var argsCopy = args.copy(); // destructive operations ahead.
			argsCopy.pop(); // ignore last entry for object search.
			
			object = lookForObject(argsCopy); 
			
			if (object == null) {
				// failed to find object in the chain, return empty results.
				return new Array<String>();
			}
		} 
		
		if (command == "call")
		{
			listResults = listFunctions(object);
		} 
		
		else if (command == "set" || command == "print")
		{
			listResults = listObjects(object);
		}
		
		// filter results
		if (listResults != null && listResults.length > 0)
		{
			filterResults(args[args.length - 1], listResults); // filter stored results according to input.
		}
		
		return listResults;
	}
	/**
	 * Recursivelly searches for an object following a list of object names.
	 * Example: 
	 *	 Having registered object1 that contains object2 that contains object3
	 *   Calling lookForObject( [ "object1", "object2", "object3"] ) returns object3.
	 * 
	 * @param	args 	A list of words to search the object.
	 * @return			The object found or null.
	 */
	static public function lookForObject(args:Array<String>, parent:Dynamic = null):Dynamic {
		var object:Dynamic = null;
		var objectName = args.shift();
		
		if (objectName == null) {
			return null; // bug fix
		}
		
		if (parent == null) {
			
			// first entry, fetch object from registered objects
			object = GCCommands.getObject(objectName);
		} else {
			try {
				
				// search nested object using reflect
				object = Reflect.getProperty(parent, objectName);
			} catch (e:Dynamic) {
				
				// object not found
				return null; 
			}
		}
		
		if (args.length == 0) {
			
			// no more words to look for.
			return object;
		} else {

			// search object inside the last object found.
			return lookForObject(args, object);
		}
		
	}
	
	/**
	 * Filters results not suitable for autocomplete.
	 * Entires with different characters on the matching input positions are rejected.
	 */
	static function filterResults(input:String, listOptions:Array<String>) 
	{
		var i:Int = 0;
		var entry:String;
		while (i < listOptions.length)
		{
			entry = listOptions[i];
			i++;
			
			// removes entries with smaller length than current input
			if (entry.length < input.length)
			{
				listOptions.remove(entry);
				i--;
				continue;
			}
			
			// removes entries with different characters for the same position as input.
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

	/**
	 * Lists objects inside object passed
	 * @param	object
	 * @return
	 */
	static function listFunctions(object:Dynamic):Array<String> {
		var results:Array<String> = new Array<String>();
		
		if (object == null) {
			
			// fetch registered functions.
			for (key in GCCommands.functionsMap.keys()) {
				results.push(key);
			}
			// also include registered objects
			for (key in GCCommands.objectsMap.keys()) {
				results.push(key);
			}
		} else 
		{
			results = listFields(object, true, true, false);
		}
		
		return results;
	}
	
	
	/**
	 *  Lists other objects inside object passed.
	 */
	static function listObjects(object:Dynamic):Array<String> {
		var results:Array<String> = new Array<String>(); 
		
		if (object == null) {
			
			for (key in GCCommands.objectsMap.keys()) {
				results.push(key);
			}
			
		} else {
			results = listFields(object, false, true, true);
		}
			
		return results;
	}
	
	/**
	 * Lists fields inside object, fields are optionaly functions, objects, or variables.
	 */
	static function listFields(object:Dynamic, functions:Bool, objects:Bool, variables:Bool):Array<String> {
		var results:Array<String> = new Array<String>();
			
		var fields = Type.getInstanceFields(Type.getClass(object));
		for (field in fields) {
			try {
				var prop = Reflect.getProperty(object, field);
				var isf:Bool = Reflect.isFunction(prop);
				var iso:Bool = Reflect.isObject(prop);
				
				if (( functions && Reflect.isFunction(prop) ) ||
					( objects && Reflect.isObject(prop) ) ||
					( variables && !Reflect.isFunction(prop) && !Reflect.isObject(prop) )) 
				{
					results.push(field);
				}
			} catch (e:Dynamic) {}
		}
			
		return results;
	}
	
	static public function joinResult(promptTxt:String, aCResult:String):String {
		if (aCResult == ".") {
			promptTxt += ".";
			return promptTxt;
		}
		
		var i:Int = aCResult.length;
		var index = -1;
		var temp:String;
		
		while (i > 0) { // Looks for the closest match to the acResult, when found, removes it and adds the result to the string.
			temp = aCResult.substr(0, i);
			index = promptTxt.lastIndexOf(temp);
			
			if (index != -1) {
				promptTxt = promptTxt.substr(0, index); // Found a match
				promptTxt += aCResult;
				return promptTxt;
			}
			
			i--;
		}
		
		return promptTxt;
	}
	
	
	static public function formatAlias(alias:String, type:ALIAS_TYPE):String {
		var i:Int = 1;
		
		// make sure alias is valid
		if (alias == null || alias == "") {
			return null;
		}
		
		//Variable names are case sensitive in Haxe. A valid variable name starts with a letter or underscore,
		//followed by any number of letters, numbers, or underscores.
		var r = ~/^[a-zA-Z_\x7f-\xff][a-zA-Z0-9_\x7f-\xff]*/;
		if (!r.match(alias)) {
			return null;
		}
		
		if (type == ALIAS_TYPE.COMMAND) {
			alias = alias.toLowerCase();
		}
		
		var aux = alias;
		// make alias unique
		while (GCCommands.getCommand(alias) != null 
			   || GCCommands.getObject(alias) != null 
			   || GCCommands.getFunction(alias) != null) 
		{
			switch (type) {
				case COMMAND:
					//concatenate c
					alias = 'c' + alias;
				case FUNCTION:
					// concatenate f
					alias = 'f' + alias;
				case OBJECT:
					// append i
					alias = aux + Std.string(i);
					i++;
			}
		}
		
		return alias;
	}
	
}