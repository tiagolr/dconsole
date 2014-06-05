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
class TestUtils extends TestCase
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
		
		console.setToggleKey(Keyboard.TAB);
		interfc.clearInput();
		interfc.clearConsole();
		console.enable();
		console.showConsole();
	}

	public function testAutoComplete() {
		assertTrue(true);
	}
	
	public function testAutoAlias() {
		assertTrue(true);
	}
	
}