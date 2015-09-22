package;
import flash.text.TextField;
import flash.ui.Keyboard;
import haxe.unit.TestCase;
import flash.events.KeyboardEvent;
import flash.Lib;
import pgr.dconsole.ui.DCInterface;
import pgr.dconsole.DC;
import pgr.dconsole.DConsole;
import pgr.dconsole.DCProfiler;
import pgr.dconsole.DCMonitor;
import pgr.dconsole.ui.DCOpenflInterface;

/**
 * Tests monitor.
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class TestMonitor extends TestCase
{	 
	var interfc:DCOpenflInterface;
	var console:DConsole;
	var monitor:DCMonitor;
	var profiler:DCProfiler;
	
	var i:Int;
	var b:Bool;
	var f:Float;
	var setter(get, null):String;
	
	
	private function get_setter():String {
		return setter + "_string";
	}
	
	
	override public function setup() {
		if (console == null) {
			DC.init();
			console = DC.instance;
			interfc = cast console.interfc;
			monitor = console.monitor;
			profiler = console.profiler;
		}
		
		console.setConsoleKey(Keyboard.TAB);
		console.setMonitorKey(Keyboard.TAB, true);
		console.setProfilerKey(Keyboard.TAB, false, true);
		interfc.clearInput();
		interfc.clearConsole();
		console.enable();
		console.showConsole();
		console.hideMonitor();
		console.hideProfiler();
		DC.clearMonitor();
		refreshMonitor();
		i = 0;
		b = false;
		f = 0;
	}
	
	
	override public function tearDown():Void {
		console.hideProfiler();
		console.hideMonitor();
		DC.clearMonitor();
		refreshMonitor();
	}
	
	public function testClearMonitor() {
		i = 999;
		
		DC.monitorField(this, "i", "i");
		refreshMonitor();
		
		assertTrue(monitorHasField("i"));
		assertTrue(monitorHasText("999"));
		
		DC.clearMonitor();
		refreshMonitor();
		
		assertFalse(monitorHasField("i"));
		assertFalse(monitorHasText("999"));
	}

	
	// test response with console disabled
	public function testDisable() {
		console.disable();
		// CTRL + console key
		pressKey(console.consoleKey.keycode, true);
		assertFalse(monitor.visible);
		console.showMonitor();
		//assertFalse(monitor.visible);
		//console.enable();
		assertTrue(monitor.visible);
		
		// TODO - monitor.disable
		// TODO - console.disable
		
	}
	
	
	public function testVisibility() {
		console.hideMonitor();
		assertFalse(monitor.visible);
		
		console.showMonitor();
		assertTrue(monitor.visible);
		
		pressKey(console.consoleKey.keycode, true);
		assertFalse(monitor.visible);
		
		pressKey(console.consoleKey.keycode, true);
		assertTrue(monitor.visible);
		
		// tests profiler and monitor not be visible at the same time.
		console.showMonitor();
		console.showProfiler();
		assertTrue(profiler.visible);
		assertFalse(monitor.visible);
		
		console.showProfiler();
		console.showMonitor();
		assertTrue(monitor.visible);
		assertFalse(profiler.visible);
	}
	
	
	public function testAddField() {
		// test adding valid fields
		DC.monitorField(this, "i", "i");
		DC.monitorField(this, "b", "b");
		DC.monitorField(this, "f", "f");
		
		assertTrue(monitor.fields.length == 3);
		assertTrue(monitorHasField("i"));
		assertTrue(monitorHasField("b"));
		assertTrue(monitorHasField("f"));
		
		DC.clearMonitor();
		
		// test adding invalid fields
		DC.monitorField(null, null, null);
		DC.monitorField(this, null, null);
		DC.monitorField(this, "i", null);
		DC.monitorField(this, "", "i");
		DC.monitorField(this, "i", "");
		DC.monitorField(this, null, "i");
		DC.monitorField(this, null, "i");
		
		assertTrue(monitor.fields.length == 0);
	}
	
	
	public function testOutput() {
		i = 999;
		b = true;
		f = 0.001;
		
		DC.monitorField(this, "i", "vari");
		DC.monitorField(this, "b", "varb");
		DC.monitorField(this, "f", "varf");
		
		refreshMonitor();
		
		assertTrue(monitorHasText("vari"));
		assertTrue(monitorHasText("varb"));
		assertTrue(monitorHasText("varf"));
		
		assertTrue(monitorHasText("999"));
		assertTrue(monitorHasText("true"));
		assertTrue(monitorHasText("0.001"));
		
		i = 111;
		b = false;
		f = 0.1;
		
		refreshMonitor(); 
		
		assertFalse(monitorHasText("999"));
		assertFalse(monitorHasText("true"));
		assertFalse(monitorHasText("0.01"));
		
		assertTrue(monitorHasText("111"));
		assertTrue(monitorHasText("false"));
		assertTrue(monitorHasText("0.1"));
	}
	
	
	function pressKey(key:Int, ctrl:Bool = false, shift:Bool = false) {
		#if (cpp && legacy) 
		interfc.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, key, 0, ctrl, false, shift));
		#else 
		interfc.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, key, null, ctrl, false, shift));
		#end
	}
	
	
	function refreshMonitor() {
		monitor.writeOutput();
	}
	
	
	function monitorHasText(txt:String):Bool {
		var txtMonitorLeft:TextField = Reflect.getProperty(interfc, "txtMonitorLeft");
		var txtMonitorRight:TextField = Reflect.getProperty(interfc, "txtMonitorRight");
		return (txtMonitorLeft.text.lastIndexOf(txt) != -1 || txtMonitorRight.text.lastIndexOf(txt) != -1);
	}
	
	
	function monitorHasField(id:String):Bool {
		for (field in monitor.fields) {
			if (field.alias == id) {
				return true;
			}
		}
		return false;
	}
	
}