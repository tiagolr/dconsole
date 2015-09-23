package;
#if openfl 
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;
#end
import haxe.unit.TestCase;
import pgr.dconsole.DC;
import pgr.dconsole.DConsole;
import pgr.dconsole.ui.DCInterface;

/**
 * Tests console runtime commands.
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class TestCommands extends TestCase
{	 
	var interfc:DCInterface;
	var console:DConsole;
	
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
			DC.init();
			console = DC.instance;
			interfc = cast console.interfc;
			testObject = new TestObject();
		}
		
		i = 0;
		f = 0;
		s = "";
		b = false;
		testObject.b = false;
		testObject.i = 0;
		testObject.s = "";
		
		DC.clearRegistry();
		interfc.clearInput();
		interfc.clearConsole();
		DC.showConsole();
		DC.enable();
	}
	
	/** */
	public function testSet() {
		DC.registerObject(this, "o1");
		
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
		DC.registerFunction(F1, "F1");
		DC.registerFunction(TestCommands.F2, "F2");
		DC.registerFunction(testObject.F, "F3");
		DC.registerFunction(F4, "F4");
		DC.registerObject(this, "o1");
		
		// call this object function
		consoleDo("F1()");
		assertTrue(consoleHasText("F1 LOGGED"));
		consoleDo("o1.F1()");
		assertTrue(consoleHasText("F1 LOGGED"));
		
		// call static function
		consoleDo("F2()");
		assertTrue(consoleHasText("F2 LOGGED"));
		
		// call nested object function
		DC.clearConsole();
		assertFalse(consoleHasText("OF LOGGED"));
		consoleDo("o1.testObject.F()");
		assertTrue(consoleHasText("OF LOGGED"));
		
		// call function with arguments
		DC.clearConsole();
		consoleDo("F4('test',0, true)");
		assertTrue(consoleHasText("testF4 LOGGED"));
		assertTrue(consoleHasText("1"));
		assertTrue(consoleHasText("true"));
		
		// call nested object function with arguments
		DC.clearConsole();
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
		DC.registerObject(this, "o1");
		
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
	
	// TODO - Test register class.
	
	//---------------------------------------------------------------------------------
	//  AUX
	//---------------------------------------------------------------------------------
	function consoleDo(command:String) {
		interfc.clearConsole();
		interfc.clearInput();
		interfc.setInputTxt(command);
		#if openfl
		cast(interfc, pgr.dconsole.ui.DCOpenflInterface).stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, Keyboard.ENTER)); 
		#elseif luxe
		cast(console.input, pgr.dconsole.input.DCLuxeInput).inputListener.onkeyup( {
			scancode : 0,
			keycode : luxe.Input.Key.enter,
			state : null,
			mod : null,
			repeat : false,
			timestamp : 0,
			window_id : 0,
		});
		#end
	}
	
	function consoleHasText(txt:String):Bool {
		return interfc.getConsoleText().lastIndexOf(txt) != -1;
	}

	function F1() {
		DC.log("F1 LOGGED");
	}
	
	public static function F2() {
		DC.log("F2 LOGGED");
	}
	
	function F4(s:String, i:Int, b:Bool) {
		DC.log(s + "F4 LOGGED");
		DC.log(i + 1);
		DC.log(!b);
	}

}


private class TestObject {
	public var i:Int;
	public var s:String;
	public var b:Bool;
	
	public function new() {}
	
	public function F() {
		DC.log("OF LOGGED");
	}
	
	public function F2(s:String, i:Int, b:Bool) {
		DC.log(s + "OF4 LOGGED");
		DC.log(i + 2);
		DC.log(!b);
	}
}