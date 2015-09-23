#if luxe
package pgr.dconsole.input;
import luxe.Entity;
import luxe.Input.Key;
import luxe.Input.KeyEvent;
import pgr.dconsole.DConsole;

/**
 * Handles input
 * @author TiagoLr
 */
class DCLuxeInput implements DCInput {

	public var console:DConsole;
	public var inputListener:InputListener;
	var enabled:Bool;
	
	public function new() {}
	
	public function init() {
		enable();
		
		inputListener = new InputListener();
		inputListener.console = this.console;
	}
	
	
	public function enable() { enabled = true;}
	public function disable() { enabled = false;}	
}


private class InputListener extends Entity {
	public var console:DConsole;
	
	public function new () {
		super({name:'dc_input_entity'});
	}
	
	override public function onkeyup(event:KeyEvent) {
		if (!console.enabled) {
			return;
		}
		
		// TOGGLE MONITOR
		if (matchesKey(event.keycode, console.monitorKey)) {
			console.toggleMonitor();
		}
		
		// TOGGLE PROFILER
		else if (matchesKey(event.keycode, console.profilerKey)) {
			console.toggleProfiler();
		}
		
		// SHOW / HIDE CONSOLE
		else if (matchesKey(event.keycode, console.consoleKey)) {
			
			console.visible ? 
				console.hideConsole():
				console.showConsole();
				
		} else if (console.visible) {
			
			// CONSOLE INPUT HANDLING
			switch (event.keycode) {
				case Key.enter: console.processInputLine();
				case Key.pagedown: console.scrollDown();
				case Key.pageup: console.scrollUp();
				case Key.down: console.prevHistory();
				case Key.up: console.nextHistory();
			}
		}
		
		return super.onkeydown(event);
	}
	
	private function matchesKey(pressedKey:Int, key:SCKey) {
		return pressedKey == key.keycode
			&& (Luxe.input.keydown(Key.lshift) == key.shiftKey || Luxe.input.keydown(Key.rshift) == key.shiftKey)
			&& (Luxe.input.keydown(Key.lctrl) == key.ctrlKey || Luxe.input.keydown(Key.rctrl) == key.ctrlKey)
			&& (Luxe.input.keydown(Key.lalt) == key.altKey || Luxe.input.keydown(Key.ralt) == key.altKey);
	}
}
#end