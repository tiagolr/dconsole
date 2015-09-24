package;
#if openfl
import flash.text.TextField;
import flash.ui.Keyboard;
#end
import haxe.unit.TestCase;
import pgr.dconsole.DC;
import pgr.dconsole.DConsole;
import pgr.dconsole.input.DCInput;
import pgr.dconsole.ui.DCInterface;
/**
 * Tests console reaction to keystrokes.
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class TestInput extends TestCase
{	 
	var input:DCInput;
	var interfc:DCInterface;
	var console:DConsole;
	var i:Int;
	var f:Float;
	var s:String;
	
	var key_up:Int;
	var key_down:Int;
	var key_enter:Int;
	var key_pageup:Int;
	var key_pagedown:Int;
	
	override public function setup() {
		if (console == null) {
			DC.init();
			console = DC.instance;
			interfc = console.interfc;
			input = console.input;
		}
		
		#if openfl
		console.setConsoleKey(Keyboard.TAB);
		console.setMonitorKey(Keyboard.TAB, true);
		console.setProfilerKey(Keyboard.TAB, false, true);
		key_up 		 = Keyboard.UP;
		key_down 	 = Keyboard.DOWN;
		key_pageup 	 = Keyboard.PAGE_UP;
		key_pagedown = Keyboard.PAGE_DOWN;
		key_enter 	 = Keyboard.ENTER;
		#elseif luxe
		console.setConsoleKey(luxe.Input.Key.key_a);
		console.setMonitorKey(luxe.Input.Key.key_b);
		console.setProfilerKey(luxe.Input.Key.key_c);
		key_up 		 = luxe.Input.Key.up;
		key_down 	 = luxe.Input.Key.down;
		key_pageup 	 = luxe.Input.Key.pageup;
		key_pagedown = luxe.Input.Key.pagedown;
		key_enter 	 = luxe.Input.Key.enter;
		#end
		interfc.clearInput();
		interfc.clearConsole();
		console.enable();
		console.showConsole();
	}
	
	/**
	 * Tests show/hide commands.
	 */
	public function testVisibility() {
		console.hideConsole();
		assertFalse(console.visible);
		console.showConsole();
		assertTrue(console.visible);
	}
	
	/**
	 * Tests opening/closing console with shortcut key
	 */
	public function testConsoleToggleKey() {
		console.hideConsole();
		assertFalse(console.visible);
		TestRunner.pressKey(console.consoleKey.keycode);
		assertTrue(console.visible);
		TestRunner.pressKey(console.consoleKey.keycode);
		assertFalse(console.visible);
	}
	
	/**
	 * Tests disabled console behaviour to keystrokes.
	 */
	@:access(pgr.dconsole.ui.DCOpenflInterface.consoleDisplay)
	@:access(pgr.dconsole.ui.DCLuxeInterface.consoleDisplay)
	public function testDisable() {
		
		#if openfl 
		var consoleDisplay = cast(interfc, pgr.dconsole.ui.DCOpenflInterface).consoleDisplay;
		#elseif luxe
		var consoleDisplay = cast(interfc, pgr.dconsole.ui.DCLuxeInterface).consoleDisplay;
		#end
		
		console.disable();
		TestRunner.pressKey(console.consoleKey.keycode);
		assertFalse(consoleDisplay.visible);
		console.showConsole();
		assertFalse(consoleDisplay.visible);
		console.enable();
		assertTrue(consoleDisplay.visible);
	}
	
	/**
	 * Tests hidden console behaviour to keystrokes.
	 */
	public function testHiddenConsole() {
		console.hideConsole();
		
		interfc.setInputTxt("SomeText");
		TestRunner.pressKey(key_enter); 
		assertTrue(interfc.getConsoleText() == "");
		
		TestRunner.pressKey(console.consoleKey.keycode);
		assertTrue(console.visible);
		TestRunner.pressKey(key_enter); 
		assertFalse(interfc.getConsoleText() == "");
	}
	
	
	public function testLogging() {
		
		// test clearconsole()
		assertTrue(consoleIsEmpty());
		
		// test simple text logging
		console.log("testlog");
		assertTrue(consoleHasText("testlog"));
		
		// test clearconsole()
		console.clearConsole();
		assertTrue(consoleIsEmpty());
		
		// test different data types logging - object, function, float, bool.
		// checks results and detects if console crashes
		console.log(null);
		assertTrue(consoleHasText("null"));
		
		console.clearConsole();
		console.log([ "1" => 1, "2" => 2, "3" => 3 ]);
		assertFalse(consoleIsEmpty());
		
		console.log(this);
		assertFalse(consoleIsEmpty());
		
		console.log(1234);
		assertTrue(consoleHasText("1234"));
		
		console.log(1234.1234);
		assertTrue(consoleHasText("1234.1234"));
		
		console.log(12 * 12);
		assertTrue(consoleHasText("144"));
		
		console.log(testLogging);
		assertTrue(consoleHasText("function"));
		
		console.log(true);
		assertTrue(consoleHasText("true"));
		
	}
	
	/**
	 * Test history
	 */
	public function testHistory() {
		
		// no history, try next history, previous history, prompt text remains the same.
		console.clearHistory();
		assertTrue(inputIsEmpty());
		TestRunner.pressKey(key_up); 
		assertTrue(inputIsEmpty());
		TestRunner.pressKey(key_down); 
		assertTrue(inputIsEmpty());
		
		// enter some commands.
		interfc.setInputTxt("1");
		TestRunner.pressKey(key_enter);
		interfc.setInputTxt("2");
		TestRunner.pressKey(key_enter);
		interfc.setInputTxt("3");
		TestRunner.pressKey(key_enter);
		assertTrue(inputIsEmpty());
		
		// test previousHistory
		TestRunner.pressKey(key_up);
		assertTrue(inputHasText("3"));
		TestRunner.pressKey(key_up);
		assertTrue(inputHasText("2"));
		TestRunner.pressKey(key_up);
		assertTrue(inputHasText("1"));
		TestRunner.pressKey(key_up);
		assertTrue(inputHasText("1"));
		// test nextHistory
		TestRunner.pressKey(key_down);
		assertTrue(inputHasText("2"));
		TestRunner.pressKey(key_down);
		assertTrue(inputHasText("3"));
		TestRunner.pressKey(key_down);
		assertTrue(inputHasText("3"));
		
		TestRunner.pressKey(key_enter);
		TestRunner.pressKey(key_up);
		TestRunner.pressKey(key_up);
		assertTrue(inputHasText("3"));
		
	}
	
	@:access(pgr.dconsole.ui.DCOpenflInterface.txtConsole)
	@:access(pgr.dconsole.ui.DCLuxeInterface.txtConsole)
	public function testScroll() {
		
		// enter a lot of text.
		// test pageUp, see if scroll changes.
		// test pageDown, see if scroll returns back.
		
		for (i in 0...30) {
			console.log("...");
		}
		
		#if openfl
		var txtConsole:TextField = cast(interfc, pgr.dconsole.ui.DCOpenflInterface).txtConsole;
		
		assertTrue(txtConsole.scrollV == txtConsole.maxScrollV);
		TestRunner.pressKey(key_pageup);
		assertTrue(txtConsole.scrollV < txtConsole.maxScrollV);
		TestRunner.pressKey(key_pagedown);
		assertTrue(txtConsole.scrollV == txtConsole.maxScrollV);
		
		#elseif luxe
		var txt = cast(interfc, pgr.dconsole.ui.DCLuxeInterface).txtConsole;
		var startY = txt.pos.y;
		
		TestRunner.pressKey(key_pageup);
		assertTrue(txt.pos.y > startY);
		TestRunner.pressKey(key_pagedown);
		assertEquals(txt.pos.y, startY);
		#end
		
	}
	
	//---------------------------------------------------------------------------------
	//  AUX
	//---------------------------------------------------------------------------------
	private function consoleHasText(txt:String):Bool {
		return interfc.getConsoleText().lastIndexOf(txt) != -1;
	}
	
	private function consoleIsEmpty():Bool {
		return interfc.getConsoleText() == "";
	}
	
	private function inputHasText(txt:String):Bool {
		return interfc.getInputTxt().lastIndexOf(txt) != -1;
	}
	
	private function inputIsEmpty():Bool {
		return interfc.getInputTxt() == "";
	}
	
}