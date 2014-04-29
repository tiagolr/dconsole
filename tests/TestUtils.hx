package ;
import flash.ui.Keyboard;
import haxe.unit.TestCase;
import flash.events.KeyboardEvent;
import flash.Lib;
import pgr.gconsole.GCInterface;
import pgr.gconsole.GameConsole;
import pgr.gconsole.GConsole;

/**
 * Tests console runtime commands.
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class TestUtils extends TestCase
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
	
	public function testAutoComplete() {
		assertTrue(true);
	}
	
}