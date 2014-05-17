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
	
	override public function setup() {
		if (console == null) {
			GC.init();
			console = GConsole.instance;
			interfc = console.interfc;
		}
		
		GC.clearRegistry();
	}
	
	public function testRegisterMethods() {
		
		// test registering non functions		
		GC.registerFunction(null, " "); 
		GC.registerFunction(this, " ");
		GC.registerFunction("", " ");
		// test registering bad alias
		GC.registerFunction(TestRegister.testF1(), "");
		
		assertTrue(Lambda.array(GCCommands.functionsMap).length == 0);
		
		// test registering methods with same alias 
		GC.registerFunction(testF2, "f1");
		GC.registerFunction(testF1, "f1");
		
		assertTrue(Lambda.array(GCCommands.functionsMap).length == 1);
		
		// test unregister
		GC.unregisterFunction("test alias");
		GC.unregisterFunction("f1");
		
		assertTrue(Lambda.array(GCCommands.functionsMap).length == 0);
	}
	
	public function testRegisterObjects() {
		
		// test register non objects
		GC.registerObject(null);
		GC.registerObject(testF1);
		GC.registerObject(1234);
		GC.registerObject(true);
		
		assertTrue(Lambda.array(GCCommands.objectsMap).length == 0);
		
		// duplicate register.
		GC.registerObject(this, "this");
		GC.registerObject(this, "this");
		
		assertTrue(Lambda.array(GCCommands.objectsMap).length == 1);
		
		// test unique alias generation
		GC.registerObject(this);
		GC.registerObject(this);
		
		assertTrue(Lambda.array(GCCommands.objectsMap).length == 3);
		
		// test unregister object
		GC.unregisterObject("test alias");
		GC.unregisterObject("this");
		
		assertTrue(Lambda.array(GCCommands.objectsMap).length == 2);
	}
	
	public function testClear() {
		
		GC.registerFunction(testF1, "testF1");
		GC.registerObject(this, "this");
		
		assertTrue(Lambda.array(GCCommands.functionsMap).length == 1);
		assertTrue(Lambda.array(GCCommands.objectsMap).length == 1);
		
		GC.clearRegistry();
		
		assertTrue(Lambda.array(GCCommands.functionsMap).length == 0);
		assertTrue(Lambda.array(GCCommands.objectsMap).length == 0);
	}
	
	//---------------------------------------------------------------------------------
	//  AUX
	//---------------------------------------------------------------------------------
	public static function testF1():String {
		return "F1";
	}
	
	public static function testF2():String {
		return "F2";
	}
}