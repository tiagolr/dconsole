package ;
import flash.ui.Keyboard;
import haxe.unit.TestCase;
import flash.events.KeyboardEvent;
import flash.Lib;
import pgr.dconsole.DCCommands;
import pgr.dconsole.DCInterface;
import pgr.dconsole.DC;
import pgr.dconsole.DConsole;
import pgr.dconsole.DCUtil;

/**
 * Tests console runtime commands.
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class TestUtils extends TestCase
{	 
	var interfc:DCInterface;
	var console:DConsole;
	var i:Int;
	var f:Float;
	var s:String;
	
	override public function setup() {
		if (console == null) {
			DC.init();
			console = DConsole.instance;
			interfc = console.interfc;
		}
		
		console.setToggleKey(Keyboard.TAB);
		interfc.clearInput();
		interfc.clearConsole();
		console.enable();
		console.showConsole();
		DC.clearRegistry();
	}
	
	public function testAutoAlias() {
		var alias:String;
		
		alias = DCUtil.formatAlias("", ALIAS_TYPE.OBJECT);
		assertTrue(alias == null);
		
		alias = DCUtil.formatAlias(null, ALIAS_TYPE.OBJECT);
		assertTrue(alias == null);
		
		alias = DCUtil.formatAlias(".invalidName", ALIAS_TYPE.OBJECT);
		assertTrue(alias == null);
		
		alias = DCUtil.formatAlias("(invalidName)", ALIAS_TYPE.OBJECT);
		assertTrue(alias == null);
		
		alias = DCUtil.formatAlias(" invalidName)", ALIAS_TYPE.OBJECT);
		assertTrue(alias == null);
		
		alias = DCUtil.formatAlias("!invalidName)", ALIAS_TYPE.OBJECT);
		assertTrue(alias == null);
		
		DC.registerCommand(commandDummy, "c", "cs");
		DC.registerCommand(commandDummy, "c", "cs");
		DC.registerCommand(commandDummy, "c", "cs");
		assertTrue(existsCommand("c"));
		assertTrue(existsCommand("cc"));
		assertTrue(existsCommand("ccc"));
		assertTrue(existsCommand("C")); // test case insesitivity
		assertTrue(existsCommand("cs")); // test shortcut
		assertTrue(existsCommand("ccs"));
		assertTrue(existsCommand("cccs"));
		assertTrue(existsCommand("CS")); // test shortcut case insensivity
		
		DC.registerObject(this, "o");
		DC.registerObject(this, "o");
		DC.registerObject(this, "o");
		DC.registerObject(this, "c");
		assertTrue(existsObject("o"));
		assertTrue(existsObject("o1"));
		assertTrue(existsObject("o2"));
		assertTrue(existsObject("c1"));
		
		DC.registerFunction(fDummy, "f");
		DC.registerFunction(fDummy, "f");
		DC.registerFunction(fDummy, "f");
		
		assertTrue(existsFunction("f"));
		assertTrue(existsFunction("ff"));
		assertTrue(existsFunction("fff"));
	}
	
	function commandDummy(args:Array<String>) { }
	
	function fDummy() {};
	
	function existsCommand(c:String) {
		return DCCommands.getCommand(c) != null;
	}
	
	function existsFunction(f:String) {
		return DCCommands.getFunction(f) != null;
	}
	
	function existsObject(o:String) {
		return DCCommands.getObject(o) != null;
	}
	
}