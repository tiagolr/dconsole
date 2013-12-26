package ;
import flash.ui.Keyboard;
import pgr.gconsole.GConsole;
import massive.munit.Assert;
import flash.events.KeyboardEvent;
import flash.Lib;
import pgr.gconsole.GCInterface;
import pgr.gconsole.GameConsole;
import pgr.gconsole.GameConsole;
class ConsoleTest {
	var interfc:GCInterface;
	var i:Int;
	var f:Float;
	var s:String;

	@Before public function startup() {
		GameConsole.init();
		interfc = GConsole.instance._interface;
		clearText();
	}

	@After public function tearDown():Void {
		GameConsole.disable();
		GConsole.instance = null;
	}

	@Test public function testInput():Void {
		GameConsole.enable();
		var str = "Test";
		interfc.txtPrompt.text = str + "1";
		Lib.current.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, 13)); // ENTER
		GameConsole.showConsole();
		GameConsole.disable();
		GameConsole.showConsole();
		interfc.txtPrompt.text = str + "2";
		Lib.current.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, 13)); // ENTER
		GameConsole.enable();
		GameConsole.showConsole();
		interfc.txtPrompt.text = str + "3";
		Lib.current.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, 13)); // ENTER
		GameConsole.hideConsole();
		interfc.txtPrompt.text = str + "4";
		Lib.current.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, 13)); // ENTER
		var strings = interfc.txtConsole.text.split('\r');
		Assert.areEqual(": Test3", strings[strings.length - 2]);
	}

	@Test public function testRegisterFields():Void {
		GameConsole.registerVariable(this, "i", "int");
		GameConsole.registerVariable(this, "i", "int");
		GameConsole.registerVariable(this, "f", "float");
		GameConsole.registerVariable(this, "f", "float");
		GameConsole.registerVariable(this, "s", "string");
		GameConsole.registerVariable(this, "s", "string");

		GameConsole.showConsole();

		interfc.txtPrompt.text = "set int 1234";
		Lib.current.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, 13)); // ENTER

		interfc.txtPrompt.text = "set float 0.1234";
		Lib.current.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, 13)); // ENTER

		interfc.txtPrompt.text = "set string string";
		Lib.current.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, 13)); // ENTER

		GameConsole.clearConsole();

		interfc.txtPrompt.text = "vars";
		Lib.current.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, 13)); // ENTER

		var ai = (~/(int).+(1234)/).split(interfc.txtConsole.text);
		var af = (~/(float).+(0.1234)/).split(interfc.txtConsole.text);
		var as = (~/(string).+(string)/).split(interfc.txtConsole.text);

		Assert.isTrue(ai.length == 2 && af.length == 2 && as.length == 2);
	}

	@Test public function testAutocompleteMainCommands():Void {
		GameConsole.showConsole();
		interfc.txtPrompt.text = "c";
		Lib.current.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, Keyboard.TAB)); // ENTER
		Assert.areEqual("clear", interfc.txtPrompt.text);
		Lib.current.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, Keyboard.TAB)); // ENTER
		Assert.areEqual("commands", interfc.txtPrompt.text);
	}

	@Test public function testAutocompleteRegisteredCommands():Void {
		GameConsole.showConsole();
		GameConsole.registerFunction(this, "emptyFunc", "empty");
		interfc.txtPrompt.text = "e";
		Lib.current.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, Keyboard.TAB)); // ENTER
		Assert.areEqual("empty", interfc.txtPrompt.text);
	}

	@Test public function testAutocompleteArguments():Void {
		GameConsole.showConsole();
		GameConsole.registerFunction(this, "emptyFunc", "empty",
		function(s:String) {
			return ["foo", "bar"];
		});
		interfc.txtPrompt.text = "empty ";
		Lib.current.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, Keyboard.TAB)); // ENTER
		Assert.areEqual("empty foo", interfc.txtPrompt.text);
		Lib.current.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, Keyboard.TAB)); // ENTER
		Assert.areEqual("empty bar", interfc.txtPrompt.text);
	}

	private function emptyFunc():Void {

	}

	private function clearText() {
		interfc.txtConsole.text = '';
		interfc.txtPrompt.text = '';
		interfc.txtMonitorLeft.text = '';
		interfc.txtMonitorRight.text = '';
	}
}