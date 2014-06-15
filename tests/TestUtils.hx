package ;
import flash.ui.Keyboard;
import haxe.unit.TestCase;
import flash.events.KeyboardEvent;
import flash.Lib;
import pgr.gconsole.GCCommands;
import pgr.gconsole.GCInterface;
import pgr.gconsole.GC;
import pgr.gconsole.GConsole;
import pgr.gconsole.GCUtil;

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
		GC.clearRegistry();
	}
	
	public function testAutoAlias() {
		var alias:String;
		
		alias = GCUtil.formatAlias("", ALIAS_TYPE.OBJECT);
		assertTrue(alias == null);
		
		alias = GCUtil.formatAlias(null, ALIAS_TYPE.OBJECT);
		assertTrue(alias == null);
		
		alias = GCUtil.formatAlias(".invalidName", ALIAS_TYPE.OBJECT);
		assertTrue(alias == null);
		
		alias = GCUtil.formatAlias("(invalidName)", ALIAS_TYPE.OBJECT);
		assertTrue(alias == null);
		
		alias = GCUtil.formatAlias(" invalidName)", ALIAS_TYPE.OBJECT);
		assertTrue(alias == null);
		
		alias = GCUtil.formatAlias("!invalidName)", ALIAS_TYPE.OBJECT);
		assertTrue(alias == null);
		
		GC.registerCommand(commandDummy, "c", "cs");
		GC.registerCommand(commandDummy, "c", "cs");
		GC.registerCommand(commandDummy, "c", "cs");
		assertTrue(existsCommand("c"));
		assertTrue(existsCommand("cc"));
		assertTrue(existsCommand("ccc"));
		assertTrue(existsCommand("C")); // test case insesitivity
		assertTrue(existsCommand("cs")); // test shortcut
		assertTrue(existsCommand("ccs"));
		assertTrue(existsCommand("cccs"));
		assertTrue(existsCommand("CS")); // test shortcut case insensivity
		
		GC.registerObject(this, "o");
		GC.registerObject(this, "o");
		GC.registerObject(this, "o");
		GC.registerObject(this, "c");
		assertTrue(existsObject("o"));
		assertTrue(existsObject("o1"));
		assertTrue(existsObject("o2"));
		assertTrue(existsObject("c1"));
		
		GC.registerFunction(fDummy, "f");
		GC.registerFunction(fDummy, "f");
		GC.registerFunction(fDummy, "f");
		
		assertTrue(existsFunction("f"));
		assertTrue(existsFunction("ff"));
		assertTrue(existsFunction("fff"));
	}
	
	function commandDummy(args:Array<String>) { }
	
	function fDummy() {};
	
	function existsCommand(c:String) {
		return GCCommands.getCommand(c) != null;
	}
	
	function existsFunction(f:String) {
		return GCCommands.getFunction(f) != null;
	}
	
	function existsObject(o:String) {
		return GCCommands.getObject(o) != null;
	}
	
}