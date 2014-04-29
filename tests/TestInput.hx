package ;
import flash.ui.Keyboard;
import haxe.unit.TestCase;
import flash.events.KeyboardEvent;
import flash.Lib;
import pgr.gconsole.GCInterface;
import pgr.gconsole.GameConsole;
import pgr.gconsole.GConsole;

/**
 * Tests console reaction to keystrokes.
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class TestInput extends TestCase
{	 
	var interfc:GCInterface;
	var console:GConsole;
	var i:Int;
	var f:Float;
	var s:String;
	
	override public function setup() {
		if (console == null) {
			GameConsole.init();
			console = GConsole.instance;
			interfc = console._interface;
		}
		
		console.setShortcutKeyCode(Keyboard.TAB);
		interfc.clearInputText();
		console.clearConsoleText();
		console.enable();
		console.showConsole();
	}
	
	override public function tearDown() {
		GameConsole.disable();
		GConsole.instance = null;
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
		console.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, Keyboard.TAB));
		assertTrue(console.visible);
		console.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, Keyboard.TAB));
		assertFalse(console.visible);
	}
	
	/**
	 * Tests disabled console behaviour to keystrokes.
	 */
	public function testDisable() {
		console.disable();
		console.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, Keyboard.TAB));
		assertFalse(console.visible);
		console.showConsole();
		assertFalse(console.visible);
		console.enable();
		assertTrue(console.visible);
	}
	
	/**
	 * Tests hidden console behaviour to keystrokes.
	 */
	public function testHiddenConsole() {
		console.hideConsole();
		
		interfc.setInputTxt("SomeText");
		console.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, Keyboard.ENTER)); 
		assertTrue(interfc.getConsoleText() == "");
		
		console.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, Keyboard.TAB));
		assertTrue(console.visible);
		console.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, Keyboard.ENTER)); 
		assertFalse(interfc.getConsoleText() == "");
	}
	
	
	public function testLogging() {
		
		// test clearconsole()
		assertTrue(interfc.getConsoleText() == "");
		
		// test simple text logging
		console.log("testlog");
		assertTrue(interfc.getConsoleText().lastIndexOf("testlog") != -1);
		
		// test clearconsole()
		console.clearConsoleText();
		assertTrue(interfc.getConsoleText() == "");
		
		// test complex input
		
		// test null logging
		
		// test different data types logging - object, function, float, bool.
		
	}
	
	
	/**
	 * Test history
	 */
	public function testHistory() {
		
		// no history, try next history, previous history, prompt text remains the same.
		
		// enter some commands.
		
		// test previousHistory
		
		// test nextHistory
		
		// test cycling history
		
		
		
		assertTrue(true);
	}
	
	public function testScroll() {
		
		// enter a lot of text.
		// test pageUp, see if scroll changes.
		// test pageDown, see if scroll returns back.
		
		assertTrue(true);
		
	}
	
}