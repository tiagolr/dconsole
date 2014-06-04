package pgr.gconsole;
import flash.events.KeyboardEvent;
import flash.Lib;
import pgr.gconsole.GConsole;

/**
 * Handles input
 * @author TiagoLr
 */
class GCInput{

	var _console:GConsole;
	
	public function new(console:GConsole) {
		
		_console = console;
		
		enable();
	}
	
	
	public function enable() {
		// make sure events are removed first.
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp, false);
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false);
	}
	
	
	public function disable() {
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp, false);
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false);
	}
	
	
	private function onKeyDown(e:KeyboardEvent):Void {
		#if !(cpp || neko) // BUGFIX
		if (_console.enabled && !_console.hidden)
			e.stopImmediatePropagation();
		#end
	}
	
	
	private function onKeyUp(e:KeyboardEvent):Void {
		// TOGGLE MONITOR
		if (e.ctrlKey && cast(e.keyCode, Int) == _console.toggleKey) {
			_console.toggleMonitor();
			return;
		}
		
		// TOGGLE PROFILER
		else 
		if (e.shiftKey && cast(e.keyCode, Int) == _console.toggleKey) {
			_console.toggleProfiler();
			return;
		}
		
		// SHOW/HIDE CONSOLE
		else 
		if (cast(e.keyCode, Int) == _console.toggleKey) {
			if (!_console.hidden) {
				_console.hide();
			} else {
				_console.show();
			}
			return;
		}
		
		// IGNORE INPUT IF CONSOLE HIDDEN
		else 
		if (_console.hidden) {
			return;
		}

		// ENTER KEY
		else 
		if (e.keyCode == 13) {
			_console.processInputLine();
		}
		
		// PAGE DOWN
		else if (e.keyCode == 33) {
			_console.scrollDown();
		}
		
		// PAGE UP
		else 
		if (e.keyCode == 34) { 
			_console.scrollUp();
		}
		
		// DOWN KEY
		else
		if (e.keyCode == 38) {
			_console.nextHistory();
		}
		
		// UP KEY
		else 
		if (e.keyCode == 40) { 
			_console.prevHistory();
		}
		
		// CONTROL + SPACE = AUTOCOMPLETE
		else 
		if (e.keyCode == 32 && e.ctrlKey)  
		{   
			_console.autoComplete();
		}
		
		else 
		{
			_console.resetHistoryIndex();
		}

		#if !(cpp || neko) // BUGFIX
		e.stopImmediatePropagation(); // BUG - cpp issues.
		#end
	}
	
}