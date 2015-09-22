package;
import pgr.dconsole.input.DCInput;
import pgr.dconsole.ui.DCInterface;
import flash.text.TextField;
import flash.ui.Keyboard;
import haxe.unit.TestCase;
import flash.events.KeyboardEvent;
import flash.Lib;
import pgr.dconsole.ui.DCInterface;
import pgr.dconsole.DC;
import pgr.dconsole.DConsole;
import pgr.dconsole.ui.DCOpenflInterface;

/**
 * Tests console reaction to keystrokes.
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class TestInput extends TestCase
{	 
	var input:DCInput;
	var interfc:DCOpenflInterface;
	var console:DConsole;
	var i:Int;
	var f:Float;
	var s:String;
	
	override public function setup() {
		if (console == null) {
			DC.init();
			console = DC.instance;
			interfc = cast console.interfc;
			input = console.input;
		}
		
		console.setConsoleKey(Keyboard.TAB);
		console.setMonitorKey(Keyboard.TAB, true);
		console.setProfilerKey(Keyboard.TAB, false, true);
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
		pressKey(console.consoleKey.keycode);
		assertTrue(console.visible);
		pressKey(console.consoleKey.keycode);
		assertFalse(console.visible);
	}
	
	/**
	 * Tests disabled console behaviour to keystrokes.
	 */
	@:access(pgr.dconsole.ui.DCOpenflInterface.consoleDisplay)
	public function testDisable() {
		
		var consoleDisplay = interfc.consoleDisplay;
		
		console.disable();
		pressKey(console.consoleKey.keycode);
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
		pressKey(Keyboard.ENTER); 
		assertTrue(interfc.getConsoleText() == "");
		
		pressKey(console.consoleKey.keycode);
		assertTrue(console.visible);
		pressKey(Keyboard.ENTER); 
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
		pressKey(Keyboard.UP); 
		assertTrue(inputIsEmpty());
		pressKey(Keyboard.DOWN); 
		assertTrue(inputIsEmpty());
		
		// enter some commands.
		interfc.setInputTxt("1");
		pressKey(Keyboard.ENTER);
		interfc.setInputTxt("2");
		pressKey(Keyboard.ENTER);
		interfc.setInputTxt("3");
		pressKey(Keyboard.ENTER);
		assertTrue(inputIsEmpty());
		
		// test previousHistory
		pressKey(Keyboard.UP);
		assertTrue(inputHasText("3"));
		pressKey(Keyboard.UP);
		assertTrue(inputHasText("2"));
		pressKey(Keyboard.UP);
		assertTrue(inputHasText("1"));
		pressKey(Keyboard.UP);
		assertTrue(inputHasText("1"));
		// test nextHistory
		pressKey(Keyboard.DOWN);
		assertTrue(inputHasText("2"));
		pressKey(Keyboard.DOWN);
		assertTrue(inputHasText("3"));
		pressKey(Keyboard.DOWN);
		assertTrue(inputHasText("3"));
		
		pressKey(Keyboard.ENTER);
		pressKey(Keyboard.UP);
		pressKey(Keyboard.UP);
		assertTrue(inputHasText("3"));
		
	}
	
	@:access(pgr.dconsole.ui.DCOpenflInterface.txtConsole)
	public function testScroll() {
		
		// enter a lot of text.
		// test pageUp, see if scroll changes.
		// test pageDown, see if scroll returns back.
		
		for (i in 0...30) {
			console.log("...");
		}
		
		var txtConsole:TextField = interfc.txtConsole;
		
		assertTrue(txtConsole.scrollV == txtConsole.maxScrollV);
		pressKey(Keyboard.PAGE_UP);
		assertTrue(txtConsole.scrollV < txtConsole.maxScrollV);
		pressKey(Keyboard.PAGE_DOWN);
		assertTrue(txtConsole.scrollV == txtConsole.maxScrollV);
		
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
	
	private function pressKey(key:UInt) {
		interfc.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, key)); 
	}
	
}