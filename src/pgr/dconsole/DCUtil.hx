package pgr.dconsole;


enum ALIAS_TYPE {
	COMMAND;
	OBJECT;
	FUNCTION;
}

class DCUtil
{		
	static public function formatAlias(commands:DCCommands, alias:String, type:ALIAS_TYPE):String {
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
		// while alias exists in any of the arrays, modify alias adding prefixes or suffixes.
		while (commands.getCommand(alias) != null 
			   || commands.getObject(alias) != null 
			   || commands.getFunction(alias) != null 
			   || commands.getClass(alias) != null)
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