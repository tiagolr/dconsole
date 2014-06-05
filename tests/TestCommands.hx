package ;
import flash.ui.Keyboard;
import haxe.unit.TestCase;
import flash.events.KeyboardEvent;
import flash.Lib;
import pgr.gconsole.GCInterface;
import pgr.gconsole.GC;
import pgr.gconsole.GConsole;

/**
 * Tests console runtime commands.
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class TestCommands extends TestCase
{	 
	var interfc:GCInterface;
	var console:GConsole;
	
	var i:Int;
	var f:Float;
	var s:String;
	var b:Bool;
	var setter(get, set):Int;
	var testObject:TestObject;
	
	private function get_setter():Int {
		return 12345;
	}
	
	private function set_setter(value:Int):Int {
		i = value;
		return i;
	}
	
	override public function setup() {
		if (console == null) {
			GC.init();
			console = GConsole.instance;
			interfc = console.interfc;
			testObject = new TestObject();
		}
		
		i = 0;
		f = 0;
		s = "";
		b = false;
		testObject.b = false;
		testObject.i = 0;
		testObject.s = "";
		
		GC.clearRegistry();
		interfc.clearInput();
		interfc.clearConsole();
		GC.showConsole();
		GC.enable();
	}
	
	/** */
	public function testSet() {
		GC.registerObject(this, "o1");
		
		// set this object string
		consoleDo("set o1.s haha");
		assertTrue(s == "haha");
		
		// set this object int
		consoleDo("set o1.i 32");
		assertTrue(i == 32);
		
		// set this object bool
		b = false;
		consoleDo("set o1.b true");
		assertTrue(b == true);
		
		// set this object float
		consoleDo("set o1.f 0.0001");
		assertTrue(f == 0.0001);
		
		// set nested object int
		consoleDo("set o1.testObject.i 32");
		assertTrue(testObject.i == 32);
		
		// set multiple values
		consoleDo("set o1.i -1 -2 -3");
		assertTrue(i == -1);
		
		// set object setter
		consoleDo("set o1.setter 99");
		assertTrue(i == 99);
		
		
		// special incorrect sets (see if program does not crash)
		consoleDo("set _____________");
		consoleDo("set _____________ ____________");
		consoleDo("set null");
		consoleDo("set null null");
		consoleDo("set. . . . . . .");
		consoleDo("set . . . . ");
		consoleDo("set o1.");
		consoleDo("set o1. null");
		consoleDo("set o1");
		consoleDo("set o1 null");
		consoleDo("set o1 200000");
		consoleDo("set o1.______ 1000");
		assertFalse(consoleHasText("OF")); 
		consoleDo("set o1.testObject. string");
		consoleDo("set o1.testObject.. string");
		consoleDo("set o1.testObject.null string");
		consoleDo("set o1.testObject.string string");
		consoleDo("set o1.i string");
		consoleDo("set o1.b string"); 
		
	}
	
	public function testCall() {
		GC.registerFunction(F1, "F1");
		GC.registerFunction(TestCommands.F2, "F2");
		GC.registerFunction(testObject.F, "F3");
		GC.registerFunction(F4, "F4");
		GC.registerObject(this, "o1");
		
		// call this object function
		consoleDo("call F1");
		assertTrue(consoleHasText("F1"));
		consoleDo("call o1.F1");
		assertTrue(consoleHasText("F1"));
		
		// call static function
		consoleDo("call F2");
		assertTrue(consoleHasText("F2"));
		
		// call nested object function
		consoleDo("call o1.testObject.F");
		assertTrue(consoleHasText("OF"));
		
		// call function with arguments
		consoleDo("call F4 test 0 true");
		assertTrue(consoleHasText("testF4"));
		assertTrue(consoleHasText("1"));
		assertTrue(consoleHasText("true"));
		
		// call nested object function with arguments
		consoleDo("call o1.testObject.F2 test 0 true");
		assertTrue(consoleHasText("testOF4"));
		assertTrue(consoleHasText("2"));
		assertTrue(consoleHasText("true"));
		
		// call with incorrect argument data type
		consoleDo("call F4 1.0 true null");
		
		// special incorrect calls (see if program does not crash)
		consoleDo("call _____________");
		consoleDo("call null");
		consoleDo("call .............");
		consoleDo("call.............");
		consoleDo("call o1.");
		consoleDo("call o1");
		consoleDo("call o1.null");
		consoleDo("call o1.nothing");
		consoleDo("call F1 1000000"); // too much arguments
		consoleDo("call F4 1000"); // few arguments
		consoleDo("call o1.testObject.F 1234"); // nested function, too much arguments
		consoleDo("call o1.testObject.");
		consoleDo("call o1.testObject..");
		consoleDo("call o1.testObject.null");
		consoleDo("call o1.testObject.string");
	}
	
	
	public function testPrint() {
		GC.registerObject(this, "o1");
		
		// test print this object int
		this.i = 100;
		consoleDo("print o1.i");
		assertTrue(consoleHasText("100"));
		
		// test print getter
		consoleDo("print o1.setter");
		assertTrue(consoleHasText("12345"));
		
		// test print nested object value
		testObject.i = 11111;
		consoleDo("print o1.testObject.i");
		assertTrue(consoleHasText("11111"));
		
		// special incorrect calls (see if program does not crash)
		consoleDo("print _____________");
		consoleDo("print null");
		consoleDo("print .............");
		consoleDo("print.............");
		consoleDo("print o1.");
		consoleDo("print o1");
		consoleDo("print o1.null");
		consoleDo("print o1.nothing");
		consoleDo("print o1 1000000"); // too much arguments
		consoleDo("print o1 1000"); // few arguments
		consoleDo("print o1.testObject.i 12345"); // nested function, too much arguments
		consoleDo("print o1.testObject.");
		consoleDo("print o1.testObject..");
		consoleDo("print o1.testObject.null");
		consoleDo("print o1.testObject.string");
	}
	
	//---------------------------------------------------------------------------------
	//  AUX
	//---------------------------------------------------------------------------------
	function consoleDo(command:String) {
		interfc.clearConsole();
		interfc.clearInput();
		interfc.setInputTxt(command);
		interfc.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, Keyboard.ENTER)); 
	}
	
	function consoleHasText(txt:String):Bool {
		return interfc.getConsoleText().lastIndexOf(txt) != -1;
	}

	function F1() {
		GC.log("F1");
	}
	
	public static function F2() {
		GC.log("F2");
	}
	
	function F4(s:String, i:Int, b:Bool) {
		GC.log(s + "F4");
		GC.log(i + 1);
		GC.log(!b);
	}

}



private class TestObject {
	public var i:Int;
	public var s:String;
	public var b:Bool;
	
	public function new() {}
	
	public function F() {
		GC.log("OF");
	}
	
	public function F2(s:String, i:Int, b:Bool) {
		GC.log(s + "OF4");
		GC.log(i + 2);
		GC.log(!b);
	}
}