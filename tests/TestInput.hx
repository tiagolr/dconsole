package tests;
import haxe.unit.TestCase;
import nme.events.KeyboardEvent;
import nme.Lib;
import pgr.gconsole.GCInterface;
import pgr.gconsole.GameConsole;

/**
 * Tests console log output.
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */

 
 // NOTE - After running test prompt does not focus automatically.
class TestInput extends TestCase
{	 
	var interfc:GCInterface;
	var console:GameConsole;
	var i:Int;
	var f:Float;
	var s:String;
	
	override public function setup() {
		if (console == null) {
			console = new GameConsole();
			interfc = cast(Reflect.field(console, "_interface"), GCInterface);
		}
		clearText();
		console.clearRegistry();
		console.clearConsole();
		console.disable();
		console.enable();
	}
	
	public function testLog() 
	{
		console.showConsole();
		console.log("testing Log..");
		assertEquals("testing Log..", interfc.txtConsole.text);  
	}

	public function testInput() 
	{
		clearText();
		var str = "Test";
		
		interfc.txtPrompt.text = str + "1";
		Lib.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, 13)); // ENTER  
		console.showConsole();
		console.disable();
		console.showConsole();
		interfc.txtPrompt.text = str + "2";
		Lib.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, 13)); // ENTER
		console.enable();
		console.showConsole();
		interfc.txtPrompt.text = str + "3";
		Lib.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, 13)); // ENTER
		console.hideConsole();
		interfc.txtPrompt.text = str + "4";
		Lib.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, 13)); // ENTER
		
		assertEquals(": Test3" , interfc.txtConsole.text);
	}
	
	public function testRegisterFields()
	{
		clearText();
		console.registerVariable(null, "null", "null");
		console.registerVariable(this, "", "null");
		console.registerVariable(this, "i", "int");
		console.registerVariable(this, "i", "int");
		console.registerVariable(this, "i2", "int");
		console.registerVariable(this, "f", "float");
		console.registerVariable(this, "f", "float");
		console.registerVariable(this, "f2", "float");
		console.registerVariable(this, "s", "string");
		console.registerVariable(this, "s", "string");
		console.registerVariable(this, "s2", "string");
		
		console.showConsole();
		
		interfc.txtPrompt.text = "set int 1234";
		Lib.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, 13)); // ENTER
		
		interfc.txtPrompt.text = "set float 0.1234";
		Lib.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, 13)); // ENTER
		
		interfc.txtPrompt.text = "set string string";
		Lib.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, 13)); // ENTER
		
		console.clearConsole();
		
		interfc.txtPrompt.text = "vars";
		Lib.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, 13)); // ENTER
		
		var ai = (~/(int).+(1234)/).split(interfc.txtConsole.text);	
		var af = (~/(float).+(0.1234)/).split(interfc.txtConsole.text);
		var as = (~/(string).+(string)/).split(interfc.txtConsole.text);
		
		assertTrue(ai.length == 2 && af.length == 2 && as.length == 2);
	}
	
	public function testUnregisterFields()
	{
		assertTrue(true);
	}
	
	public function testUnregisterObject()
	{
		assertTrue(true);
	}
	
	public function testRegisterFunctions()
	{
		assertTrue(true);
	}
	
	public function testMonitor()
	{
		assertTrue(true);
	}
	
	override public function tearDown() {
		setup();
	}
	
	private function clearText() {
		interfc.txtConsole.text = '';
		interfc.txtPrompt.text = '';
		interfc.txtMonitorLeft.text = '';
		interfc.txtMonitorRight.text = '';
	}
	
	private function returnString(str:String):String {
		return str;
	}
	
}