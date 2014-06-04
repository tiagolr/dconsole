package pgr.gconsole;
import flash.events.KeyboardEvent;
import flash.Lib;
import flash.ui.Keyboard;
import pgr.gconsole.GConsole;

/**
 * Handles input
 * @author TiagoLr
 */
class GCInput{

	var console:GConsole;
	
	public function new() {
		
		console = GConsole.instance;
		console.setToggleKey(Keyboard.TAB); // ensures TAB key using openfl
		
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
		if (console.enabled && console.consoleVisible) {
			e.stopImmediatePropagation();
		}
		#end
	}
	
	
	private function onKeyUp(e:KeyboardEvent):Void {
		// TOGGLE MONITOR
		if (e.ctrlKey && cast(e.keyCode, Int) == console.toggleKey) {
			console.toggleMonitor();
			return;
		}
		
		// TOGGLE PROFILER
		else 
		if (e.shiftKey && cast(e.keyCode, Int) == console.toggleKey) {
			console.toggleProfiler();
			return;
		}
		
		// SHOW/HIDE CONSOLE
		else 
		if (cast(e.keyCode, Int) == console.toggleKey) {
			if (console.consoleVisible) {
				console.hideConsole();
			} else {
				console.showConsole();
			}
			return;
		}
		
		// IGNORE INPUT IF CONSOLE HIDDEN
		else 
		if (!console.consoleVisible) {
			return;
		}

		// ENTER KEY
		else 
		if (e.keyCode == 13) {
			console.processInputLine();
		}
		
		// PAGE DOWN
		else if (e.keyCode == 33) {
			console.scrollDown();
		}
		
		// PAGE UP
		else 
		if (e.keyCode == 34) { 
			console.scrollUp();
		}
		
		// DOWN KEY
		else
		if (e.keyCode == 38) {
			console.nextHistory();
		}
		
		// UP KEY
		else 
		if (e.keyCode == 40) { 
			console.prevHistory();
		}
		
		// CONTROL + SPACE = AUTOCOMPLETE
		else 
		if (e.keyCode == 32 && e.ctrlKey)  
		{   
			console.autoComplete();
		}
		
		else 
		{
			console.resetHistoryIndex();
		}

		#if !(cpp || neko) // BUGFIX
		e.stopImmediatePropagation(); // BUG - cpp issues.
		#end
	}
	
}