package;
import haxe.unit.TestCase;
import pgr.dconsole.DC;
import pgr.dconsole.DConsole;
import pgr.dconsole.ui.DCInterface;

/**
 * Tests console object and function register.
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class TestRegister extends TestCase
{	 
	var interfc:DCInterface;
	var console:DConsole;
	var i:Int;
	var f:Float;
	var s:String;
	var args:Array<String>;
	
	override public function setup() {
		if (console == null) {
			DC.init();
			console = DC.instance;
			interfc = console.interfc;
		}
		
		DC.clearRegistry();
	}
	
	function commandDummy(Args:Array<String>) {
		args = Args;
	}
	
	public function testRegisterCommand() {
		
		var numcms = commandsCount();
		// tests registering non functions
		DC.registerCommand(null, null);
		DC.registerCommand(commandDummy, null);
		DC.registerCommand(commandDummy, "!.@.()");
		DC.registerCommand(commandDummy, "");
		assertTrue(commandsCount() == numcms); // no commands were added
		
		// tests if command is called and receives arguments
		DC.registerCommand(commandDummy, "commandDummy");
		console.commands.evaluate("commandDummy 123");
		assertTrue(args.length == 1);
		console.commands.evaluate("commandDummy"); // no args
		assertTrue(args.length == 0);
		console.commands.evaluate("CoMmanDDumMy test"); // case sensitivity test
		assertTrue(args.length == 1);
	}
	
	public function testRegisterMethods() {
		
		// test registering non functions		
		DC.registerFunction(null, " "); 
		DC.registerFunction(this, " ");
		DC.registerFunction("", " ");
		assertTrue(functionsCount() == 0);
		
		// test registering methods with same alias 
		DC.registerFunction(testF2, "f1");
		DC.registerFunction(testF1, "f1");
		DC.registerFunction(TestRegister.testF1(), "");
		assertTrue(functionsCount() == 2);
		
		var numfs = functionsCount();
		// test unregister
		DC.unregisterFunction("invalid function name");
		DC.unregisterFunction("f1");
		assertTrue(functionsCount() == numfs - 1);
	}
	
	public function testRegisterObjects() {
		
		// test register non objects
		DC.registerObject(null);
		DC.registerObject(testF1);
		DC.registerObject(1234);
		DC.registerObject(true);
		assertTrue(objectsCount() == 0);
		
		// duplicate register.
		DC.registerObject(this, "this");
		DC.registerObject(this, "this");
		assertTrue(objectsCount() == 2); // two objects added
		
		// test unique alias generation
		DC.registerObject(this);
		DC.registerObject(this);
		DC.registerObject(this, "");
		DC.registerObject(this, null);
		assertTrue(objectsCount() == 6); // four objects added
		
		// test unregister object
		DC.unregisterObject("test alias");
		DC.unregisterObject("this");
		assertTrue(objectsCount() == 5); // one object removed
	}
	
	public function testClear() {
		
		DC.registerFunction(testF1, "testF1");
		DC.registerObject(this, "this");
		
		assertTrue(functionsCount() == 1);
		assertTrue(objectsCount() == 1);
		
		DC.clearRegistry();
		
		assertTrue(functionsCount() == 0);
		assertTrue(objectsCount() == 0);
	}
	
	//---------------------------------------------------------------------------------
	//  AUX
	//---------------------------------------------------------------------------------
	function objectsCount():Int {
		return Lambda.array(console.commands.objectsMap).length;
	}
	
	function functionsCount():Int {
		return Lambda.array(console.commands.functionsMap).length;
	}
	
	function commandsCount():Int {
		return Lambda.array(console.commands.commandsMap).length;
	}
	
	public static function testF1():String {
		return "F1";
	}
	
	public static function testF2():String {
		return "F2";
	}
}