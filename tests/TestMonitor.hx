package ;
import flash.ui.Keyboard;
import haxe.unit.TestCase;
import flash.events.KeyboardEvent;
import flash.Lib;
import pgr.gconsole.GCInterface;
import pgr.gconsole.GameConsole;
import pgr.gconsole.GConsole;

/**
 * Tests console object and function register.
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class TestMonitor extends TestCase
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

	// test response with console disabled
	public function testDisable() {
		assertTrue(true);
	}
	
	public function testVisibility() {
		assertTrue(true);
		
		// test monitor show and hide
		// test profiler must not be visible at same time
		// test shortcut key
	}
	
	public function testAddField() {
		
		// test adding diferent kinds of fields
	}
	
	public function testOutput() {
		
		// test monitoring fields, 
		// manipulate those fields and see result in the output
	}
	
}