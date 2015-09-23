#if luxe
package pgr.dconsole.ui;
import pgr.dconsole.DConsole;
import luxe.Input.Key;
import luxe.Input.KeyEvent;
import luxe.Input.TextEvent;
import luxe.options.TextOptions;
import luxe.Rectangle;
import luxe.Sprite;
import luxe.Text;
import luxe.utils.Maths;
import luxe.Vector;
import phoenix.Batcher;
import phoenix.Camera;
import phoenix.Color;
import phoenix.geometry.LineGeometry;

/**
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class LuxePromptText extends Text {
	public var cursor:LineGeometry;
	var index(default, set):Int = 0;
	var console:DConsole;
	
	public function new(options:TextOptions, console:DConsole) {
		super(options);
		this.console = console;
		Luxe.timer.schedule(.5, blinkCursor, true);
	}
	
	override public function ontextinput(event:TextEvent) {
		if (this.visible == false) {
			return;
		}
		
		this.text = text.substr(0, index) + event.text + text.substr(index, text.length);
		index++;
		console.resetHistoryIndex();
	}
	
	override function onkeydown( event:KeyEvent ) {
		if (this.visible == false) {
			return;
		}
		
        switch(event.keycode) {
            case Key.backspace:
				index--;
				text = text.substr(0, index) + text.substr(index + 1, text.length);
            case Key.delete:
				text = text.substr(0, index) + text.substr(index + 1, text.length);
            case Key.left:
				index--;
            case Key.right:
				index++;
        }
    }
	
	public function moveCarretToEnd() {
		index = text.length;
	}
	
	inline function set_index(i:Int) {
		i = Maths.clampi(i, 0, text.length);
		
		index = i;
		
		// update cursor position
		var width = font.width_of(text.substr(0, index), point_size, letter_spacing);
		if (width == 0) {
			width = 1; // fix cursor not visible
		}
		cursor.p0 = new Vector(width, cursor.p0.y);
		cursor.p1 = new Vector(width, cursor.p1.y);
		
		return index;
	}
	
	function blinkCursor() {
		if (!this.visible) {
			return;
		}
		cursor.visible = !cursor.visible;
	}
	
}

class DCLuxeInterface implements DCInterface
{
	public var batcher:Batcher;
	public var camera:Camera;
	
	var monitorDisplay:Sprite;
	var txtMonitorLeft:Text;
	var txtMonitorRight:Text;
	
	var profilerDisplay:Sprite;
	var txtProfiler:Text;
	
	var consoleDisplay:Sprite;
	var promptDisplay:Sprite;
	var txtConsole:Text;
	var txtPrompt:LuxePromptText;
	var promptCursor:LineGeometry;
	
	public var console:DConsole;
	
	var heightPt:Float;
	var align:String;
	
	public function new(heightPt:Float, align:String) {
		if (heightPt <= 0 || heightPt > 100) heightPt = 100; // clamp to >0..1
		if (heightPt > 1) heightPt = Std.int(heightPt) / 100; // turn >0..100 into percentage from 1..0
		
		this.heightPt = heightPt;
		this.align = align;
	}
	
	public function init() {
		batcher = new Batcher(Luxe.renderer, 'dc_batcher');
		camera = new Camera();
		batcher.view = camera;
		batcher.layer = 100;
		Luxe.renderer.add_batch(batcher);
		
		createMonitorDisplay();
		createProfilerDisplay();
		createConsoleDisplay();
		
		//onResize();
		//Lib.current.stage.addEventListener(Event.RESIZE, onResize);
		
	}
	
	function onResize() {
		// TODO on resize
		
		/*if (Std.is(this.parent, Stage)) {
			var stg:Stage = cast this.parent;
			maxWidth = stg.stageWidth;
			maxHeight = stg.stageHeight;
		} else {
			maxWidth = this.parent.width;
			maxHeight = this.parent.height;
		}
		
		drawConsole(); // redraws console.
		drawMonitor();
		drawProfiler();*/
	}
	
	
	function createConsoleDisplay() {
		var PROMPT_HEIGHT = 20;
		
		consoleDisplay = new Sprite( {
			color:new Color().rgb(DCThemes.current.CON_C),
			size: new Vector(Luxe.screen.width, Luxe.screen.height * heightPt - PROMPT_HEIGHT),
			centered:false,
			pos: new Vector(0, Luxe.screen.height - Luxe.screen.height * heightPt),
			batcher:batcher,
		});
		consoleDisplay.color.a = DCThemes.current.CON_A;
		
		promptDisplay = new Sprite( {
			color:new Color().rgb(DCThemes.current.PRM_C),
			size: new Vector(Luxe.screen.width, PROMPT_HEIGHT),
			centered:false,
			depth:1, // fixes bug where prompt display is not visible
			pos: new Vector(0, Luxe.screen.height - PROMPT_HEIGHT),
			batcher:batcher,
		});
		
		txtConsole = new Text( {
			parent:consoleDisplay,
			color: new Color().rgb(DCThemes.current.PRM_TXT_C),
			bounds: new Rectangle(0, 0, consoleDisplay.size.x, 0),
			bounds_wrap: true,
			point_size: 14,
			batcher:batcher,
		});
		txtConsole.color.a = DCThemes.current.CON_TXT_A;
		
		txtConsole.geometry.clip_rect = new Rectangle(
			consoleDisplay.pos.x,
			consoleDisplay.pos.y, 
			consoleDisplay.size.x,
			consoleDisplay.size.y
		);
		
		txtPrompt = new LuxePromptText( {
			parent:promptDisplay,
			color: new Color().rgb(DCThemes.current.PRM_TXT_C),
			bounds: new Rectangle(0, 0, Luxe.screen.width, promptDisplay.size.y),
			point_size: 15,
			depth:1.1,
			align_vertical: TextAlign.center,
			batcher:batcher,
		}, console);
		
		promptCursor = Luxe.draw.line( {
			color: new Color().rgb(DCThemes.current.PRM_TXT_C),
			depth: 10,
			batcher: batcher,
			p0: new Vector(1, Luxe.screen.height - PROMPT_HEIGHT + 3),
			p1: new Vector(1, Luxe.screen.height - PROMPT_HEIGHT + 3 + 15)
		});
		txtPrompt.cursor = promptCursor;
		
		// TODO enable mouse wheel over console
	}
	
	public function showConsole() {
		consoleDisplay.visible = true;
		txtConsole.visible = true;
		promptDisplay.visible = true;
		txtPrompt.visible = true;
		promptCursor.visible = true;
	}
	
	public function hideConsole() {
		consoleDisplay.visible = false;
		txtConsole.visible = false;
		promptDisplay.visible = false;
		txtPrompt.visible = false;
		promptCursor.visible = false;
	}
	
	//---------------------------------------------------------------------------------
	//  MONITOR
	//---------------------------------------------------------------------------------
	function createMonitorDisplay() {
		
		monitorDisplay = new Sprite( {
			size: new Vector(Luxe.screen.width, Luxe.screen.height),
			color: new Color().rgb(DCThemes.current.MON_C),
			centered:false,
			batcher:batcher,
		});
		monitorDisplay.color.a = DCThemes.current.MON_A;
		
		txtMonitorLeft = new Text( {
			color: new Color().rgb(DCThemes.current.MON_TXT_C),
			bounds: new Rectangle(0, 0, Luxe.screen.width / 2, Luxe.screen.height),
			point_size:14,
			bounds_wrap:true,
			batcher:batcher,
		});
		
		txtMonitorRight = new Text( {
			color: new Color().rgb(DCThemes.current.MON_TXT_C),
			bounds: new Rectangle(0, 0, Luxe.screen.width / 2, Luxe.screen.height),
			point_size:14,
			bounds_wrap:true,
			pos: new Vector(Luxe.screen.width / 2, 0),
			batcher:batcher,
		});
		
		txtMonitorLeft.color.a = DCThemes.current.MON_TXT_A;
		txtMonitorRight.color.a = DCThemes.current.MON_TXT_A;
		
	}
	
	// Splits output into left and right monitor text fields
	public function writeMonitorOutput(output:Array<String>) {
		txtMonitorLeft.text = "";
		txtMonitorRight.text = "";
		
		txtMonitorLeft.text += "DC Monitor\n\n";
		txtMonitorRight.text += "\n\n";
		
		var i = 0;
		while (output.length > 0) {
			
			if (i % 2 == 0) {
				txtMonitorLeft.text += output.shift();
			} else {
				txtMonitorRight.text += output.shift();
			}
			i++;
		}
	}
	
	public function showMonitor() {
		monitorDisplay.visible = true;
		txtMonitorLeft.visible = true;
		txtMonitorRight.visible = true;
	}
	
	public function hideMonitor() {
		monitorDisplay.visible = false;
		txtMonitorLeft.visible = false;
		txtMonitorRight.visible = false;
	}
	
	//---------------------------------------------------------------------------------
	//  PROFILER
	//---------------------------------------------------------------------------------
	function createProfilerDisplay() {
		profilerDisplay = new Sprite( {
			size: new Vector(Luxe.screen.width, Luxe.screen.height),
			color: new Color().rgb(DCThemes.current.MON_C),
			centered: false,
			batcher:batcher,
		});
		profilerDisplay.color.a = DCThemes.current.MON_A;
		
		txtProfiler = new Text( {
			color: new Color().rgb(DCThemes.current.MON_TXT_C),
			bounds: new Rectangle(0, 0, Luxe.screen.width, Luxe.screen.height),
			point_size:14, 
			bounds_wrap:true,
			batcher:batcher,
		});
		txtProfiler.color.a = DCThemes.current.MON_TXT_A;
	}
	
	public function writeProfilerOutput(output:String) {
		txtProfiler.text = "DC Profiler\n\n";
		txtProfiler.text += output;
	}
	
	public function showProfiler() {
		profilerDisplay.visible = true;
		txtProfiler.visible = true;
	}
	
	public function hideProfiler() {
		profilerDisplay.visible = false;
		txtProfiler.visible = false;
	}
	
	//---------------------------------------------------------------------------------
	//  PUBLIC METHODS
	//---------------------------------------------------------------------------------
	public function log(data:Dynamic, color:Int) {
		var str:String = txtConsole.text + Std.string(data) + '\n';
		
		// FIX - Luxe (version 1.0.0 alpha 1) creates a polygon and 6 vertexes for each text character.
		// Not only a single geometry is limited to 64k vertexes, long textfields cause big performance lost.
		// For now the console characters are limited to 2000.
		if (str.length > 2000) {
			str = str.substr(str.length - 2000);
		}
		
		txtConsole.text = str;
		scrollToBottom();
	}
	
	public function moveCarretToEnd() {
		txtPrompt.moveCarretToEnd();
	}
	
	public function scrollConsoleUp() {
		txtConsole.pos.y += (consoleDisplay.size.y - txtConsole.geom.point_size);
		if (txtConsole.pos.y > 0) 
			txtConsole.pos.y = 0;
	}
	
	public function scrollConsoleDown() {
		txtConsole.pos.y -= (consoleDisplay.size.y - txtConsole.geom.point_size);
		
		var diff = txtConsole.geom.text_height - consoleDisplay.size.y - txtConsole.geom.point_size;
		if (diff <= 0) {
			txtConsole.pos.y = 0;
		}
		
		if (txtConsole.pos.y < -diff) {
			txtConsole.pos.y = -diff;
		}
	}
	
	function scrollToBottom() {
		var diff = txtConsole.geom.text_height - consoleDisplay.size.y - txtConsole.geom.point_size;
		if (diff > 0) {
			txtConsole.pos.y = -diff; 
		} else {
			txtConsole.pos.y = 0;
		}
	}
	
	/**
	 * Brings this display object to the front of display list.
	 */
	public function toFront() {}
	
	public function setConsoleFont(font:String = null, embed:Bool = false, size:Int = 14, bold:Bool = false, italic:Bool = false, underline:Bool = false ) {
		// TODO
	}
	
	public function setPromptFont(font:String = null, embed:Bool = false, size:Int = 16, bold:Bool = false, ?italic:Bool = false, underline:Bool = false ) {
		// TODO
	}
	
	public function setProfilerFont(font:String = null, embed:Bool = false, size:Int = 14, bold:Bool = false, ?italic:Bool = false, underline:Bool = false ) {
		// TODO
	}
	
	public function setMonitorFont(font:String = null, embed:Bool = false, size:Int = 14, bold:Bool = false, ?italic:Bool = false, underline:Bool = false ){
		// TODO
	}
	
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
	
	
	public function getConsoleText():String {
		return txtConsole.text;
	}
	
	public function getMonitorText() {
		return {
			col1:txtMonitorLeft.text, 
			col2:txtMonitorRight.text, 
		}
	}
	
	public function clearInput() {
		txtPrompt.text = "";
		txtPrompt.moveCarretToEnd();
	}
	
	
	public function clearConsole() {
		txtConsole.text = "";
	}

	
}
#end