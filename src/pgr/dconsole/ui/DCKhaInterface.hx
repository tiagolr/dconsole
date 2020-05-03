#if kha_debug_html5
package pgr.dconsole.ui;

import Std;
import haxe.io.Bytes;

import kha.System;
import kha.Scheduler;
import kha.Image;
import kha.Color;
import kha.Assets;
import kha.Framebuffer;
import kha.math.Vector2;
import kha.Font;
import kha.input.KeyCode;
import kha.input.Keyboard;
import Math;
using kha.graphics2.GraphicsExtension;

import kha2d.Sprite;


class KhaPromptCursor {
  public var color: Int;
  public var p0: Vector2;
  public var p1: Vector2;
  public var visible = true;
  public var thickness = 8;
  public function new(color: Int, p0: Vector2, p1: Vector2) {
    this.color = color;
    this.p0 = p0;
    this.p1 = p1;
  }
}

class KhaPromptText {
  //Text options
  public var text: String = "";
  public var visible: Bool = true;
  var color: Int;
  public var font: Font;
  var fontSize: Int;
  var x: Float;
  var y: Float;
  /////////////

	public var cursor: KhaPromptCursor;
	var index(default, set):Int = 0;
	var console:DConsole;

	public function new(color: Int, font: Font, fontSize: Int, x: Float, y: Float,
    console:DConsole, cursor: KhaPromptCursor) {
    this.color = color;
    this.font = font;
    this.fontSize = fontSize;
    this.x = x;
    this.y = y;

    this.console = console;
    this.cursor = cursor;

    if (Keyboard.get() != null) Keyboard.get().notify(onKeyDown, null, pressListener);
    Scheduler.addTimeTask(blinkCursor, 0, .5);
  }

  public function pressListener(char: String) {
    if (this.visible == false) {
      return;
    }
    this.text = text.substr(0, index) + char + text.substr(index, text.length);
    index += char.length;
    console.resetHistoryIndex();
  }

  public function onKeyDown(k: KeyCode) {
    if (this.visible == false) {
      return;
    }
    switch(k) {
        case KeyCode.Backspace:
    index--;
    text = text.substr(0, index) + text.substr(index + 1, text.length);
        case KeyCode.Delete:
    text = text.substr(0, index) + text.substr(index + 1, text.length);
        case KeyCode.Left:
    index--;
        case KeyCode.Right:
    index++;
      //TODO: move to KhaInput
        case KeyCode.Return:
          console.commands.evaluate(text);
        default: return;
    }
  }

	public function moveCarretToEnd() {
		index = text.length;
	}

	inline function set_index(i:Int) {
		index = Std.int(Math.min(text.length, Math.max(0, i)));


    //update cursor position
    var width = font.width(fontSize, text.substr(0, index));
		if (width == 0) {
			width = 1; // fix cursor not visible
		}
		cursor.p0 = new Vector2(width, cursor.p0.y);
		cursor.p1 = new Vector2(width, cursor.p1.y);

		return index;
	}

  public function render(fb: Framebuffer) {
    if (font != null) {
      fb.g2.color = color;
      fb.g2.font = font;
      fb.g2.fontSize = fontSize;
      fb.g2.drawString(text, x, y);
    }
    if (cursor.visible == true) {
      fb.g2.color = cursor.color;
      fb.g2.drawLine(cursor.p0.x, cursor.p0.y, cursor.p1.x, cursor.p1.y, cursor.thickness);
    }
  }

  function blinkCursor() {
    if (!this.visible) {
      return;
    }
    cursor.visible = !cursor.visible;
  }
}



class DCKhaInterface implements DCInterface {
  public var console:DConsole;

  var align:String;
  var heightPt:Float; // percentage height

  var consoleDisplay:Sprite;
  var promptDisplay: Sprite;

  var txtPrompt: KhaPromptText;
  var promptCursor: KhaPromptCursor;

  var font:Font = null;
  var fontSize: Int = 15;

  var PROMPT_HEIGHT = 20;

  public function new(heightPt: Float, align:String) {
    if (heightPt <= 0 || heightPt > 100) heightPt = 100; // clamp to >0..1
    if (heightPt > 1) heightPt = Std.int(heightPt) / 100; // turn >0..100 into percentage from 1..0

    this.heightPt = heightPt;
    this.align = align;
  }

  public function init() {
		createConsoleDisplay();
    System.notifyOnFrames(function (framebuffers) { render(framebuffers[0]); });
    Assets.loadFont("Consolas", function(font:Font) {txtPrompt.font = font;});
  }

  function createImageBytes(color: Color, width: Int, height: Int): Bytes {
    var bytes = Bytes.alloc(width * height * 4);
    var i = 0;
    while (i < width * height * 4) {
      bytes.set(i, color.Rb);
      bytes.set(i + 1, color.Gb);
      bytes.set(i + 2, color.Bb);
      bytes.set(i + 3, color.Ab);
      i += 4;
    }
    return bytes;
  }

  function createConsoleDisplay() {
    //consoleDisplay
    var color = Color.fromValue(
      (Std.int(DCThemes.current.CON_A * 255) << 24) | DCThemes.current.CON_C);

    var bytes = createImageBytes(color, System.windowWidth(),
      Std.int(System.windowHeight() * heightPt) - PROMPT_HEIGHT);

    var image = Image.fromBytes(
      bytes,
      System.windowWidth(),
      Std.int(System.windowHeight() * heightPt) - PROMPT_HEIGHT);

    consoleDisplay = new Sprite(image);

    consoleDisplay.setPosition(
      new Vector2(0, System.windowHeight() - Std.int(System.windowHeight() * heightPt)));
    //////////////

    //promptDisplay
    var color = Color.fromValue((255 << 24) | DCThemes.current.PRM_C);

    var bytes = createImageBytes(color, System.windowWidth(), PROMPT_HEIGHT);

    var image = Image.fromBytes(
      bytes,
      System.windowWidth(),
      PROMPT_HEIGHT);

    promptDisplay = new Sprite(image);

    promptDisplay.setPosition(
      new Vector2(0, System.windowHeight() - PROMPT_HEIGHT));
    //////////////

    promptCursor = new KhaPromptCursor(
      (255 << 24) | DCThemes.current.PRM_TXT_C,
      new Vector2(1, System.windowHeight() - PROMPT_HEIGHT + 3),
      new Vector2(1, System.windowHeight() - PROMPT_HEIGHT + 3 + fontSize));

    //TODO: align
    txtPrompt = new KhaPromptText((255 << 24) | DCThemes.current.PRM_TXT_C,
      font, fontSize, promptDisplay.x, promptDisplay.y + 3, console, promptCursor);
  }


  public function render(fb: Framebuffer): Void {
    fb.g2.begin(false);
    consoleDisplay.render(fb.g2);
    promptDisplay.render(fb.g2);
    txtPrompt.render(fb);
    fb.g2.end();
  }




  public function showConsole() : Void {}

  public function hideConsole() : Void {}

  public function writeMonitorOutput(output:Array<String>) : Void {}

  public function showMonitor() : Void {}

  public function hideMonitor() : Void {}

  public function writeProfilerOutput(output:String) : Void {}

  public function showProfiler() : Void {}

  public function hideProfiler() : Void {}

  //---------------------------------------------------------------------------------
  //  PUBLIC METHODS
  //---------------------------------------------------------------------------------
  public function log(data:Dynamic, color:Int) : Void {trace(Std.string(data));}

  public function moveCarretToEnd() {
		txtPrompt.moveCarretToEnd();
	}

  public function scrollConsoleUp() : Void {}

  public function scrollConsoleDown() : Void {}

  /**
   * Brings this display object to the front of display list.
   */
  public function toFront() : Void {}

  public function setConsoleFont(font:String = null, embed:Bool = false, size:Int = 14, bold:Bool = false, italic:Bool = false, underline:Bool = false ) : Void {}

  public function setPromptFont(font:String = null, embed:Bool = false, size:Int = 16, bold:Bool = false, ?italic:Bool = false, underline:Bool = false ) : Void {}

  public function setProfilerFont(font:String = null, embed:Bool = false, size:Int = 14, bold:Bool = false, ?italic:Bool = false, underline:Bool = false ) : Void {}

  public function setMonitorFont(font:String = null, embed:Bool = false, size:Int = 14, bold:Bool = false, ?italic:Bool = false, underline:Bool = false ) : Void {}

  /**
   * Removes last input char
   */
   public function inputRemoveLastChar() {
 		if (txtPrompt.text.length > 0) {
 			txtPrompt.text = txtPrompt.text.substr(0, txtPrompt.text.length - 1);
 			txtPrompt.moveCarretToEnd();
 		}
 	}


 	public function getInputTxt():String {
 		return txtPrompt.text;
 	}


 	public function setInputTxt(string:String) {
 		txtPrompt.text = string;
 		txtPrompt.moveCarretToEnd();
 	}

  public function getConsoleText() : String {return null;}

  public function getMonitorText() : { col1:String, col2:String } {
    return null;
  }

  public function clearInput() {
		txtPrompt.text = "";
		txtPrompt.moveCarretToEnd();
	}

  public function clearConsole() : Void {}
}
#end
