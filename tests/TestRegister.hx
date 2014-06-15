package ;
import flash.ui.Keyboard;
import haxe.unit.TestCase;
import flash.events.KeyboardEvent;
import flash.Lib;
import pgr.gconsole.GCCommands;
import pgr.gconsole.GCInterface;
import pgr.gconsole.GC;
import pgr.gconsole.GConsole;

/**
 * Tests console object and function register.
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class TestRegister extends TestCase
{	 
	var interfc:GCInterface;
	var console:GConsole;
	var i:Int;
	var f:Float;
	var s:String;
	var args:Array<String>;
	
	override public function setup() {
		if (console == null) {
			GC.init();
			console = GConsole.instance;
			interfc = console.interfc;
		}
		
		GC.clearRegistry();
	}
	
	function commandDummy(Args:Array<String>) {
		args = Args;
	}
	
	public function testRegisterCommand() {
		
		var numcms = commandsCount();
		// tests registering non functions
		GC.registerCommand(null, null);
		GC.registerCommand(commandDummy, null);
		GC.registerCommand(commandDummy, "!.@.()");
		GC.registerCommand(commandDummy, "");
		assertTrue(commandsCount() == numcms); // no commands were added
		
		// tests if command is called and receives arguments
		GC.registerCommand(commandDummy, "commandDummy");
		GCCommands.evaluate("commandDummy 123");
		assertTrue(args.length == 1);
		GCCommands.evaluate("commandDummy"); // no args
		assertTrue(args.length == 0);
		GCCommands.evaluate("CoMmanDDumMy test"); // case sensitivity test
		assertTrue(args.length == 1);
	}
	
	public function testRegisterMethods() {
		
		// test registering non functions		
		GC.registerFunction(null, " "); 
		GC.registerFunction(this, " ");
		GC.registerFunction("", " ");
		assertTrue(functionsCount() == 0);
		
		// test registering methods with same alias 
		GC.registerFunction(testF2, "f1");
		GC.registerFunction(testF1, "f1");
		GC.registerFunction(TestRegister.testF1(), "");
		assertTrue(functionsCount() == 2);
		
		var numfs = functionsCount();
		// test unregister
		GC.unregisterFunction("invalid function name");
		GC.unregisterFunction("f1");
		assertTrue(functionsCount() == numfs - 1);
	}
	
	public function testRegisterObjects() {
		
		// test register non objects
		GC.registerObject(null);
		GC.registerObject(testF1);
		GC.registerObject(1234);
		GC.registerObject(true);
		assertTrue(objectsCount() == 0);
		
		// duplicate register.
		GC.registerObject(this, "this");
		GC.registerObject(this, "this");
		assertTrue(objectsCount() == 2); // two objects added
		
		// test unique alias generation
		GC.registerObject(this);
		GC.registerObject(this);
		GC.registerObject(this, "");
		GC.registerObject(this, null);
		assertTrue(objectsCount() == 6); // four objects added
		
		// test unregister object
		GC.unregisterObject("test alias");
		GC.unregisterObject("this");
		assertTrue(objectsCount() == 5); // one object removed
	}
	
	public function testClear() {
		
		GC.registerFunction(testF1, "testF1");
		GC.registerObject(this, "this");
		
		assertTrue(functionsCount() == 1);
		assertTrue(objectsCount() == 1);
		
		GC.clearRegistry();
		
		assertTrue(functionsCount() == 0);
		assertTrue(objectsCount() == 0);
	}
	
	//---------------------------------------------------------------------------------
	//  AUX
	//---------------------------------------------------------------------------------
	static function objectsCount():Int {
		return Lambda.array(GCCommands.objectsMap).length;
	}
	
	static function functionsCount():Int {
		return Lambda.array(GCCommands.functionsMap).length;
	}
	
	static function commandsCount():Int {
		return Lambda.array(GCCommands.commandsMap).length;
	}
	
	public static function testF1():String {
		return "F1";
	}
	
	public static function testF2():String {
		return "F2";
	}
}