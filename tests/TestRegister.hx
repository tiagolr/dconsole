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
class TestRegister extends TestCase
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

	
	public function testRegisterMethods() {
		
		// register existing method
		// register null
		// register varied types (non functions)
		// register methods with same alias
		// register methods with wierd alias
		
		// unregister method that exists
		// unregister method that does not exist
		// unregister method with wierd alias
		// unregister null
		
		assertTrue(true);
	}
	
	public function testRegisterObjects() {
		
		// register existing object
		// register null
		// register varied types (non object)
		// register object with same alias
		// register object with wierd alias
		
		// unregister object that exists
		// unregister object that does not exist
		// unregister object with wierd alias
		// unregister null
		
		assertTrue(true);
	}
	
}