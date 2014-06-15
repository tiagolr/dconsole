package ;
import flash.ui.Keyboard;
import haxe.unit.TestCase;
import flash.events.KeyboardEvent;
import flash.Lib;
import pgr.gconsole.GCInterface;
import pgr.gconsole.GC;
import pgr.gconsole.GCMonitor;
import pgr.gconsole.GConsole;
import pgr.gconsole.GCProfiler;

/**
 * Tests profiler.
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class TestProfiler extends TestCase
{	 
	var monitor:GCMonitor;
	var profiler:GCProfiler;
	var interfc:GCInterface;
	var console:GConsole;
	
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
		GC.clearProfiler();
	}
	
	override public function tearDown():Void {
		// clear profiler
		GC.clearProfiler();
		console.hideProfiler();
		console.hideMonitor();
	}

	// test response with console disabled
	public function testDisable() {
		console.disable();
		pressKey(console.toggleKey, false, true);
		assertFalse(profiler.visible);
		console.showProfiler();
		//assertFalse(monitor.visible);
		//console.enable();
		assertTrue(profiler.visible);
		
		// TODO - monitor.disable
		// TODO - console.disable
	}
	
	public function testVisibility() {
		console.hideProfiler();
		assertFalse(profiler.visible);
		
		console.showProfiler();
		assertTrue(profiler.visible);
		
		// SHIFT + console key
		pressKey(console.toggleKey, false, true);
		assertFalse(profiler.visible);
		
		// SHIFT + Console key
		pressKey(console.toggleKey, false, true);
		assertTrue(profiler.visible);
		
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
	
	public function testBeginProfile() {
		// test opening same sample twice.
		try {
			GC.beginProfile("start1");
			GC.beginProfile("start1");
			assertTrue(false); // this should not be reached
		} catch (s:String) {}
		
		GC.clearProfiler();
		assertFalse(existsSample("start1"));
		
		// test samples status after begin
		GC.beginProfile("start1");
		assertTrue(existsSample("start1"));
		assertTrue(getSample("start1").openInstances == 1);
		assertTrue(getSample("start1").instances == 1);
		
		GC.endProfile("start1");
		assertTrue(existsSample("start1")); // sample now exists but has 0 open instances
		assertTrue(getSample("start1").openInstances == 0);
		
		try {
			GC.beginProfile("start1");
			GC.beginProfile("start2");
			GC.beginProfile("start1"); // test opening same sample as a nested nested child
			assertTrue(false);
		} catch (s:String) {}
		
	}
	
	
	public function testEndProfile() {
		try {
			GC.endProfile("start1"); // ending non existing sample
			assertTrue(false); // this line should not be reached.
		} catch (s:String) {}
		
		try {
			GC.beginProfile("start1");
			GC.endProfile("start1");
			GC.endProfile("start1"); // ending same sample twice
			assertTrue(false); // this line should not be reached.
		} catch (s:String) { }
		
		assertTrue(true);
	}
	
	
	public function testCrossProfile() {
		try {
			GC.beginProfile("s1");
			GC.beginProfile("s2");
			GC.endProfile("s1");
			assertTrue(false); // code not supposed to be reached.
		} catch (s:Dynamic) {}
		
		assertTrue(true); // cross profile exception catched.
	}
	
	// test samples statistics
	public function testSample() {
		
		var startTime:Int;
		var delta;
		var h1, h2:SampleHistory;
		var lastElapsed;
		
		// Run sample, verify statistics
		GC.beginProfile("start1");
		startTime = Lib.getTimer();
		delaySample("start1", 100);
		GC.endProfile("start1");
		delta = Lib.getTimer() - startTime;
		
		h1 = getHistory("start1");
		assertTrue(h1.elapsed >= 100 && h1.elapsed <= 100 + delta);
		assertTrue(h1.numParents == 0);
		assertTrue(h1.nLogs == 1);
		assertTrue(h1.totalElapsed == h1.elapsed);
		assertTrue(h1.childrenElapsed == 0);
		assertTrue(h1.instances == 1);
		lastElapsed = h1.elapsed;
		
		// Re-Run sample, verify updated statistics
		GC.beginProfile("start1");
		startTime = Lib.getTimer();
		delaySample("start1", 200);
		GC.endProfile("start1");
		delta = Lib.getTimer() - startTime;
		
		assertTrue(h1.elapsed >= 200 && h1.elapsed <= 200 + delta);
		assertTrue(h1.numParents == 0);
		assertTrue(h1.nLogs == 2);
		assertTrue(h1.totalElapsed == lastElapsed + h1.elapsed);
		assertTrue(h1.childrenElapsed == 0);
		assertTrue(h1.instances == 2);
		lastElapsed = h1.elapsed;
		
	}
	
	// test samples history/statistics with nested samples
	public function testNestedSample() {
		
		var startTime:Int;
		var delta;
		var h1, h2:SampleHistory;
		var lastElapsed;
		
		// run samples 1 and 2, sample 2 multiple times inside 1
		GC.beginProfile("start1");
		startTime = Lib.getTimer();
		delaySample("start1", 100);
			GC.beginProfile("start2");
			delaySample("start2", 100);
			GC.endProfile("start2");
		GC.endProfile("start1");
		delta = Lib.getTimer() - startTime;
		
		h1 = getHistory("start1");
		h2 = getChild("start1", "start2");
		
		assertFalse(h1 == null);
		assertFalse(h2 == null);
		assertFalse(existsHistory("start2")); // sample 2 exists only as a child of sample1
		
		assertTrue(h1.elapsed >= 200 && h1.elapsed <= 200 + delta);
		assertTrue(h1.numParents == 0);
		assertTrue(h1.nLogs == 1);
		assertTrue(h1.totalElapsed == h1.elapsed);
		assertTrue(h1.childrenElapsed == h2.elapsed);
		assertTrue(h1.instances == 1);
		
		// children stats
		assertTrue(h2.elapsed >= 100 && h2.elapsed <= 100 + delta);
		assertTrue(h2.numParents == 1);
		assertTrue(h2.nLogs == 1);
		assertTrue(h2.totalElapsed == h2.elapsed);
		assertTrue(h2.childrenElapsed == 0);
		assertTrue(h2.instances == 1);
		
		lastElapsed = h1.elapsed;
		
		// Run samples 1 and 2, sample 2 multiple times inside 1
		
		// Run sample 2 alone
		
		// Run sample 1 alone
	}
	
	//---------------------------------------------------------------------------------
	//  AUX
	//---------------------------------------------------------------------------------
	function pressKey(key:Int, ctrl:Bool = false, shift:Bool = false) {
		#if flash
		interfc.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, key, null, ctrl, false, shift));
		#else 
		interfc.stage.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, 0, key, 0, ctrl, false, shift));
		#end
	}
	
	function existsSample(s:String):Bool {
		return (profiler.getSample(s) != null);
	}
	
	function getSample(s:String):PFSample {
		return profiler.getSample(s);
	}
	
	function existsHistory(s:String):Bool {
		return (profiler.getHistory(s) != null);
	}
	
	function getHistory(s:String):SampleHistory {
		return profiler.getHistory(s);
	}
	
	function delaySample(sampleName:String, delay:Int) {
		var sample = getSample(sampleName);
		
		sample.startTime -= delay;
		
		for (s in profiler.samples) {
			if (s.openInstances > 0 && s.name != sample.name) {
				// also apply the delay to sample parents
				s.startTime -= delay;
			}
		}
	}
	
	function getChild(sampleName:String, childName:String):SampleHistory {
		return getHistory(sampleName).getChild(childName);
	}
	
}