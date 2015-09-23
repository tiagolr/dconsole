package;
import haxe.unit.TestRunner;
import pgr.dconsole.DC;
class TestRunner 
#if luxe 
extends luxe.Game
#end
{
    #if openfl 
    static function main() {
	#elseif luxe
	override function ready() {
	#end
		
        var r = new haxe.unit.TestRunner();
		
		r.add(new TestInput());
		r.add(new TestRegister());
		r.add(new TestCommands());
		r.add(new TestUtils());
		r.add(new TestMonitor());
		r.add(new TestProfiler());
		
        r.run();
		
		#if COVERAGE
		var logger = mcover.coverage.MCoverage.getLogger();
		logger.report();
		#end
		
		#if (cpp || neko)
		Sys.exit(0);
		#end
    }
	
	public static function pressKey(key:Int, ctrl:Bool = false, shift:Bool = false) {
		var interfc = DC.instance.interfc;
		var input = DC.instance.input;
		
		#if (openfl && cpp && legacy) 
		cast(interfc, pgr.dconsole.ui.DCOpenflInterface).stage.dispatchEvent(new flash.events.KeyboardEvent(flash.events.KeyboardEvent.KEY_UP, true, false, 0, key, 0, ctrl, false, shift));
		#elseif openfl
		cast(interfc, pgr.dconsole.ui.DCOpenflInterface).stage.dispatchEvent(new flash.events.KeyboardEvent(flash.events.KeyboardEvent.KEY_UP, true, false, 0, key, null, ctrl, false, shift));
		#elseif luxe
		cast(input, pgr.dconsole.input.DCLuxeInput).inputListener.onkeyup( {
			scancode : 0,
			keycode : key,
			state : null,
			mod : null,
			repeat : false,
			timestamp : 0,
			window_id : 0,
		});
		#end
	}
}