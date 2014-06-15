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
		consoleDo("o1.s = 'haha'");
		assertTrue(s == "haha");
		
		// set this object int
		consoleDo("o1.i = 32");
		assertTrue(i == 32);
		
		// set this object bool
		b = false;
		consoleDo("o1.b = true");
		assertTrue(b == true);
		
		// set this object float
		consoleDo("o1.f = 0.0001");
		assertTrue(f == 0.0001);
		
		// set nested object int
		consoleDo("o1.testObject.i = 32");
		assertTrue(testObject.i == 32);
		
		// set multiple values
		consoleDo("o1.i = -1 -2 -3");
		assertTrue(i == -6);
		
		// set object setter
		consoleDo("o1.setter = 99");
		assertTrue(i == 99);
		
		
		// special incorrect sets (see if program does not crash)
		consoleDo("_____________ =");
		consoleDo("_____________ = ____________");
		consoleDo("= null");
		consoleDo("null = null");
		consoleDo(". = . = . = . = . = . = .");
		consoleDo(". . . . ");
		consoleDo("o1. = null");
		consoleDo("o1.null = null");
		consoleDo("o1 = ");
		consoleDo("o1.null");
		consoleDo("o1.200000");
		consoleDo("o1.______ = 1000");
		consoleDo("o1.testObject. = 'string'");
		consoleDo("o1.testObject.. = 'string'");
		consoleDo("o1.testObject.null = 'string'");
		consoleDo("o1.testObject.string = 'string'");
		consoleDo("o1.i = 'string'");
		consoleDo("o1.b = 'string'"); 
	}
	
	public function testCall() {
		GC.registerFunction(F1, "F1");
		GC.registerFunction(TestCommands.F2, "F2");
		GC.registerFunction(testObject.F, "F3");
		GC.registerFunction(F4, "F4");
		GC.registerObject(this, "o1");
		
		// call this object function
		consoleDo("F1()");
		assertTrue(consoleHasText("F1 LOGGED"));
		consoleDo("o1.F1()");
		assertTrue(consoleHasText("F1 LOGGED"));
		
		// call static function
		consoleDo("F2()");
		assertTrue(consoleHasText("F2 LOGGED"));
		
		// call nested object function
		GC.clearConsole();
		assertFalse(consoleHasText("OF LOGGED"));
		consoleDo("o1.testObject.F()");
		assertTrue(consoleHasText("OF LOGGED"));
		
		// call function with arguments
		GC.clearConsole();
		consoleDo("F4('test',0, true)");
		assertTrue(consoleHasText("testF4 LOGGED"));
		assertTrue(consoleHasText("1"));
		assertTrue(consoleHasText("true"));
		
		// call nested object function with arguments
		GC.clearConsole();
		consoleDo("o1.testObject.F2('test',0,true)");
		assertTrue(consoleHasText("testOF4 LOGGED"));
		assertTrue(consoleHasText("2"));
		assertTrue(consoleHasText("true"));
		
		
		// special incorrect calls (see if program does not crash)
		consoleDo("F4(1.0,true,null)"); // (incorrect data types)
		consoleDo("F4(1.0,'str',1.3)"); // (incorrect data types)
		consoleDo("(_____________)");
		consoleDo("(null)");
		consoleDo("(.............)");
		consoleDo("(.............)");
		consoleDo("o1.()");
		consoleDo("o1()");
		consoleDo("o1.(null)");
		consoleDo("o1.(nothing)");
		consoleDo("F1(1000000)"); // too much arguments
		consoleDo("F4(1000)"); // few arguments
		consoleDo("o1.testObject.F(1234)"); // nested function, too much arguments
		consoleDo("o1.testObject.()");
		consoleDo("o1.testObject.(.)");
		consoleDo("o1.testObject.(null)");
		consoleDo("o1.testObject.('string')");
	}
	
	
	public function testPrint() {
		GC.registerObject(this, "o1");
		
		// test print this object int
		this.i = 100;
		consoleDo("o1.i");
		assertTrue(consoleHasText("100"));
		
		// test print getter
		consoleDo("o1.setter");
		assertTrue(consoleHasText("12345"));
		
		// test print nested object value
		testObject.i = 11111;
		consoleDo("o1.testObject.i");
		assertTrue(consoleHasText("11111"));
		
		// special incorrect calls (see if program does not crash)
		consoleDo("_____________");
		consoleDo("null");
		consoleDo(".............");
		consoleDo(".............");
		consoleDo("o1.");
		consoleDo("o1");
		consoleDo("o1.null");
		consoleDo("o1.nothing");
		consoleDo("o1 1000000"); // too much arguments
		consoleDo("o1 1000"); // few arguments
		consoleDo("o1.testObject.i 12345"); // nested function, too much arguments
		consoleDo("o1.testObject.");
		consoleDo("o1.testObject..");
		consoleDo("o1.testObject.null");
		consoleDo("o1.testObject.string");
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
		GC.log("F1 LOGGED");
	}
	
	public static function F2() {
		GC.log("F2 LOGGED");
	}
	
	function F4(s:String, i:Int, b:Bool) {
		GC.log(s + "F4 LOGGED");
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
		GC.log("OF LOGGED");
	}
	
	public function F2(s:String, i:Int, b:Bool) {
		GC.log(s + "OF4 LOGGED");
		GC.log(i + 2);
		GC.log(!b);
	}
}