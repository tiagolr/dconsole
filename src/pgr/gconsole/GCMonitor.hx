package pgr.gconsole;

import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

typedef MonitorField = {
	object:Dynamic,
	field:String,
	alias:String,
}

/**
 * ...
 * @author TiagoLr
 */
class GCMonitor extends Sprite {

	public var startTime(default, null):Int;
	public var refreshRate(default, null):Int;
	
	public var fields:Array<MonitorField>;
	public var txtMonitorLeft:TextField;
	public var txtMonitorRight:TextField;
	
	var output:Array<String>;
	
	var hidden:Bool;
	
	public function new() {
		super();
		
		refreshRate = 100;
		output = new Array<String>();
		
		fields = new Array<MonitorField>();
		create();
		
	}
	
	//---------------------------------------------------------------------------------
	//  VISUAL
	//---------------------------------------------------------------------------------
	/**
	 * Creates visual monitor.
	 */
	private function create() {
		
		graphics.beginFill(GCThemes.current.MON_C, GCThemes.current.MON_A);
		graphics.drawRect(0, 0, Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
		graphics.endFill();
		
		txtMonitorLeft = new TextField();
		txtMonitorLeft.selectable = false;
		txtMonitorLeft.multiline = true;
		txtMonitorLeft.alpha = GCThemes.current.MON_TXT_A;
		txtMonitorLeft.x = 0;
		txtMonitorLeft.width = Lib.current.stage.width / 2;
		txtMonitorLeft.height = Lib.current.stage.height;
		addChild(txtMonitorLeft);
		
		txtMonitorRight = new TextField();
		txtMonitorRight.selectable = false;
		txtMonitorRight.multiline = true;
		txtMonitorRight.alpha = GCThemes.current.MON_TXT_A;
		txtMonitorRight.x = Lib.current.stage.width / 2;
		txtMonitorRight.width = Lib.current.stage.width / 2;
		txtMonitorRight.height = Lib.current.stage.height;
		addChild(txtMonitorRight);
		
		// loads default font.
		setFont();
	}
	
	public function setFont(font:String = null, embed:Bool = false, size:Int = 14, bold:Bool = false, ?italic:Bool = false, underline:Bool = false ){
		if (font == null) {
			font = "Consolas";
		}
		
		embed ? txtMonitorLeft.embedFonts = true : txtMonitorLeft.embedFonts = false;
		embed ? txtMonitorRight.embedFonts = true : txtMonitorRight.embedFonts = false;
		txtMonitorLeft.defaultTextFormat = new TextFormat(font, size, GCThemes.current.MON_TXT_C, bold, italic, underline, '', '', TextFormatAlign.LEFT, 10,10);
		txtMonitorRight.defaultTextFormat = new TextFormat(font, size, GCThemes.current.MON_TXT_C, bold, italic, underline, '', '', TextFormatAlign.LEFT, 10,10);
	}
	
	
	public function writeOutput() {
		
		txtMonitorLeft.text = "";
		txtMonitorRight.text = "";
		
		txtMonitorLeft.text += "GC Monitor\n";
		txtMonitorRight.text += "\n";
		
		graphics.lineStyle(1, GCThemes.current.MON_TXT_C);
		graphics.moveTo(0, txtMonitorLeft.textHeight);
		graphics.lineTo(Lib.current.stage.width, txtMonitorLeft.textHeight);
		
		txtMonitorLeft.text += "\n";
		txtMonitorRight.text += "\n";
		
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
	
	//---------------------------------------------------------------------------------
	//  LOGIC
	//---------------------------------------------------------------------------------
	public function show() {
		this.visible = true;
		
		GConsole.instance.profiler.hide();
		
		removeEventListener(Event.ENTER_FRAME, refresh);  // prevent duplicate listeners
		addEventListener(Event.ENTER_FRAME, refresh);

		startTime = Lib.getTimer();
		refresh(null);	// renders first frame.
	}

	
	public function hide() {
		this.visible = false;
		removeEventListener(Event.ENTER_FRAME, refresh);
	}
		
	
	public function addField(object:Dynamic, fieldName:String, alias:String) {
		var mfield:MonitorField = { object:object, field:fieldName, alias:alias };
		
		fields.push(mfield);
	}
	
	
	public function setRefreshRate(refreshRate:Int) {
		this.refreshRate = refreshRate;
	}
	
	public function toggle() {
		if (visible) {
			hide();
		} else {
			show();
		}
	}
	
	
	private function refresh(e:Event):Void {
		var elapsed = Lib.getTimer() - startTime;
		
		if (elapsed > refreshRate || e == null) {
			
			// refreshes monitor screen
			refreshOutput();
			writeOutput();
			startTime = Lib.getTimer();
		}
	}
	
	public function refreshOutput() {
		output = new Array<String>();
		
		for (v in fields) {
			output.push(v.alias + ':' + Reflect.getProperty(v.object, v.field) + '\n');
		}
	}
	

}