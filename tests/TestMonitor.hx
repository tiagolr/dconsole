package ;
import flash.text.TextField;
import flash.ui.Keyboard;
import haxe.unit.TestCase;
import flash.events.KeyboardEvent;
import flash.Lib;
import pgr.gconsole.GCInterface;
import pgr.gconsole.GC;
import pgr.gconsole.GConsole;
import pgr.gconsole.GCProfiler;
import pgr.gconsole.GCMonitor;

/**
 * Tests monitor.
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class TestMonitor extends TestCase
{	 
	var interfc:GCInterface;
	var console:GConsole;
	var monitor:GCMonitor;
	var profiler:GCProfiler;
	
	var i:Int;
	var b:Bool;
	var f:Float;
	var setter(get, null):String;
	
	
	private function get_setter():String {
		return setter + "_string";
	}
	
	
	override public function setup() {
		if (console == null) {
			GC.init();
			console = GConsole.instance;
			interfc = console.interfc;
			monitor = console.monitor;
			profiler = console.profiler;
		}
		
		console.setToggleKey(Keyboard.TAB);
		interfc.clearInput();
		interfc.clearConsole();
		console.enable();
		console.showConsole();
		console.hideMonitor();
		console.hideProfiler();
		GC.clearMonitor();
		refreshMonitor();
		i = 0;
		b = false;
		f = 0;
	}
	
	
	override public function tearDown():Void {
		console.hideProfiler();
		console.hideMonitor();
		GC.clearMonitor();
		refreshMonitor();
	}
	
	public function testClearMonitor() {
		i = 999;
		
		GC.monitorField(this, "i", "i");
		refreshMonitor();
		
		assertTrue(monitorHasField("i"));
		assertTrue(monitorHasText("999"));
		
		GC.clearMonitor();
		refreshMonitor();
		
		assertFalse(monitorHasField("i"));
		assertFalse(monitorHasText("999"));
	}

	
	// test response with console disabled
	public function testDisable() {
		console.disable();
		// CTRL + console key
		pressKey(console.toggleKey, true);
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
		
		pressKey(console.toggleKey, true);
		assertFalse(monitor.visible);
		
		pressKey(console.toggleKey, true);
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
		GC.monitorField(this, "i", "i");
		GC.monitorField(this, "b", "b");
		GC.monitorField(this, "f", "f");
		
		assertTrue(monitor.fields.length == 3);
		assertTrue(monitorHasField("i"));
		assertTrue(monitorHasField("b"));
		assertTrue(monitorHasField("f"));
		
		GC.clearMonitor();
		
		// test adding invalid fields
		GC.monitorField(null, null, null);
		GC.monitorField(this, null, null);
		GC.monitorField(this, "i", null);
		GC.monitorField(this, "", "i");
		GC.monitorField(this, "i", "");
		GC.monitorField(this, null, "i");
		GC.monitorField(this, null, "i");
		
		assertTrue(monitor.fields.length == 0);
	}
	
	
	public function testOutput() {
		i = 999;
		b = true;
		f = 0.001;
		
		GC.monitorField(this, "i", "vari");
		GC.monitorField(this, "b", "varb");
		GC.monitorField(this, "f", "varf");
		
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
		#if flash
		interfc.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, key, null, ctrl, false, shift));
		#else 
		interfc.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, key, 0, ctrl, false, shift));
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