#if kha_debug_html5
package pgr.dconsole.input;

import kha.input.Keyboard;
import kha.input.KeyCode;
import pgr.dconsole.DConsole;

class DCKhaInput implements DCInput {

  public var console:DConsole;
  var altDown:Bool = false;
  var ctrlDown:Bool = false;
  var shiftDown:Bool = false;

  public function new() {}

  public function init():Void {
    enable();
  }
  public function enable():Void {
    if (Keyboard.get() != null) Keyboard.get().remove(onKeyDown, onKeyUp, null);
    if (Keyboard.get() != null) Keyboard.get().notify(onKeyDown, onKeyUp, null);
  }
  public function disable():Void {
    if (Keyboard.get() != null) Keyboard.get().remove(onKeyDown, onKeyUp, null);
  }

  public function onKeyDown(k: KeyCode) {
    switch (k) {
      case KeyCode.Alt: altDown = true;
      case KeyCode.Control: ctrlDown = true;
      case KeyCode.Shift: shiftDown = true;
      default: return;
    }
  }

  public function onKeyUp(k: KeyCode) {
    switch (k) {
      case KeyCode.Alt: altDown = false;
      case KeyCode.Control: ctrlDown = false;
      case KeyCode.Shift: shiftDown = false;
      default: k;
    }

    if (matchesKey(console.monitorKey, k)) {
      console.toggleMonitor();
    }
    else if (matchesKey(console.profilerKey, k)) {
      console.toggleProfiler();
    }
    else if (matchesKey(console.consoleKey, k)) {
      if (console.visible) console.hideConsole();
      else console.showConsole();
    }

    else if (console.visible) {
			switch (k) {
				case KeyCode.Return: console.processInputLine();
				case KeyCode.PageDown: console.scrollDown();
				case KeyCode.PageUp: console.scrollUp();
				case KeyCode.Down: console.prevHistory();
				case KeyCode.Up: console.nextHistory();
        default: return;
			}
		}
  }

  function matchesKey(key: SCKey, k: KeyCode) {
    return key.keycode == cast(k, Int)
      && key.altKey == altDown
      && key.ctrlKey == ctrlDown
      && key.shiftKey == shiftDown;
  }
}

#end
