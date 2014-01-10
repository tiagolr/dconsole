package ;
import flash.ui.Keyboard;
import haxe.unit.TestCase;
import flash.events.KeyboardEvent;
import flash.Lib;
import pgr.gconsole.GCInterface;
import pgr.gconsole.GameConsole;
import pgr.gconsole.GConsole;

/**
 * Tests console log output.
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */

 
 // NOTE - After running test prompt does not focus automatically.
class TestInput extends TestCase
{	 
	public var interfc:GCInterface;
	public var console:GConsole;
	public var i:Int;
	public var f:Float;
	public var s:String;
	
	override public function setup() {
        GameConsole.init();
        console = GConsole.instance;
        interfc = console._interface;
		clearText();
	}
	
	override public function tearDown() {
		GameConsole.disable();
		GConsole.instance = null;
	}
	
	public function testLog() 
	{
		console.showConsole();
		console.log("testing Log..");
		assertEquals("testing Log..", interfc.txtConsole.text.substr(0, 13));  
	}

	// Tests keyboard input while console is disabled and hidden.
	public function testInput() 
	{
		clearText();
		var str = "Test";
		
		interfc.txtPrompt.text = str + "1";
		console.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, 13)); // ENTER  
		console.showConsole();
		console.disable();
		console.showConsole();
		interfc.txtPrompt.text = str + "2";
		console.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, 13)); // ENTER
		console.enable();
		console.showConsole();
		interfc.txtPrompt.text = str + "3";
		console.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, 13)); // ENTER
		console.hideConsole();
		interfc.txtPrompt.text = str + "4";
		console.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, 13)); // ENTER
		
		assertEquals("Test3" , interfc.txtConsole.text.substr(2, 5));
	}
	
	public function testRegisterFields()
	{
		clearText();

		try
		{
		console.registerVariable(null, "null", "null");
		} catch (msg:String)
		{
			assertTrue(msg.lastIndexOf("null is not an object") > 0);
		}

		//console.registerVariable(this, "", "null");
		console.registerVariable(this,  "i", "int");
		console.registerVariable(this, "i", "int");
		console.registerVariable(this, "f", "float");
		console.registerVariable(this, "f", "float");
		console.registerVariable(this, "s", "string");
		console.registerVariable(this, "s", "string");

		try {
		console.registerVariable(this, "i2", "int");
		} catch (msg:String) {
			assertTrue(msg.lastIndexOf("field was not found") > 0);
		}

		console.showConsole();

		interfc.txtPrompt.text = "set int 1234";
		console.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, 13)); // ENTER

		interfc.txtPrompt.text = "set float 0.1234";
		console.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, 13)); // ENTER

		interfc.txtPrompt.text = "set string string";
		console.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, 13)); // ENTER

		console.clearConsole();

		interfc.txtPrompt.text = "vars";
		console.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, 13)); // ENTER

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
	
	public function testAutocompleteMainCommands():Void {
		GameConsole.showConsole();
		interfc.txtPrompt.text = "c";
        console.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, Keyboard.F1)); // ENTER
		assertEquals("clear", interfc.txtPrompt.text);
        console.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, Keyboard.F1)); // ENTER
		assertEquals("commands", interfc.txtPrompt.text);
	}

	public function testAutocompleteRegisteredCommands():Void {
		GameConsole.showConsole();
		GameConsole.registerFunction(this, "emptyFunc", "empty");
		interfc.txtPrompt.text = "e";
        console.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, Keyboard.F1)); // ENTER
		assertEquals("empty", interfc.txtPrompt.text);
	}

	public function testAutocompleteArguments():Void {
		GameConsole.showConsole();
		GConsole.instance.registerFunction(this, "emptyFunc", "empty", false,
		function(s:String) {
			return ["foo", "bar"];
		});
		interfc.txtPrompt.text = "empty ";
        console.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, Keyboard.F1)); // ENTER
		assertEquals("empty foo", interfc.txtPrompt.text);
        console.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, Keyboard.F1)); // ENTER
		assertEquals("empty bar", interfc.txtPrompt.text);
	}

    public function emptyFunc():Void {

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