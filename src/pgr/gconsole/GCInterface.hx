package pgr.gconsole;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import pgr.gconsole.GCThemes.Theme;


/**
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */

class GCInterface extends Sprite
{
	var _width:Int;
	var _height:Int;
	var _promptFontYOffset:Int;
	var _yOffset:Int;
	var margin:Int = 0;
	
	var monitorDisplay:Sprite;
	var txtMonitorLeft:TextField;
	var txtMonitorRight:TextField;
	
	var profilerDisplay:Sprite;
	var txtProfiler:TextField;
	
	var consoleDisplay:Sprite;
	var promptDisplay:Sprite;
	var txtConsole:TextField;
	var txtPrompt:TextField;
	
	public function new(height:Float, align:String) {
		super();
		
		_width = Lib.current.stage.stageWidth;
		_height = Std.int(Lib.current.stage.stageHeight * height);
		align == "DOWN" ? _yOffset = Lib.current.stage.stageHeight - _height : _yOffset = 0;
		
		createMonitorDisplay();
		createProfilerDisplay();
		createConsoleDisplay();
		
		setConsoleFont();
		setMonitorFont();
		setProfilerFont();
		setPromptFont();
		
		drawConsole();
		
		Lib.current.stage.addChild(this);
	}
	
	
	function createConsoleDisplay() {
		consoleDisplay = new Sprite();
		consoleDisplay.alpha = GCThemes.current.CON_TXT_A;
		addChild(consoleDisplay);
		
		promptDisplay = new Sprite();
		addChild(promptDisplay);
		
		txtPrompt = new TextField();
		txtPrompt.type = TextFieldType.INPUT;
		txtPrompt.selectable = true;
		txtPrompt.multiline = false;
		promptDisplay.addChild(txtPrompt);
		
		txtConsole = new TextField();
		txtConsole.selectable = false;
		txtConsole.multiline = true;
		txtConsole.wordWrap = true;
		txtConsole.alpha = GCThemes.current.CON_TXT_A;
		consoleDisplay.addChild(txtConsole);
		#if flash
		txtConsole.mouseWheelEnabled = true;
		#end
		
	}
	
	/** 
	 * Draws console fields after changes to console appearence
	 * TODO - redraw on stage resize.
	 */
	function drawConsole() {	
		
		// draw console background.
		consoleDisplay.graphics.clear();
		consoleDisplay.graphics.beginFill(GCThemes.current.CON_C, 1);
		consoleDisplay.graphics.drawRect(0, 0, _width, _height);
		consoleDisplay.graphics.endFill();
		consoleDisplay.y = _yOffset;
		consoleDisplay.alpha = GCThemes.current.CON_A;
		
		// draw text input field.
		promptDisplay.graphics.clear();
		promptDisplay.graphics.beginFill(GCThemes.current.PRM_C);
		promptDisplay.graphics.drawRect(0, 0, _width, txtPrompt.textHeight);
		promptDisplay.graphics.endFill();
		promptDisplay.y = _height - txtPrompt.textHeight + _yOffset;
		
		// Resize textfields
		txtConsole.width = _width;
		txtConsole.height = _height - txtPrompt.textHeight + 2;
		
		txtPrompt.y = - 2; // -2 just looks better.
		txtPrompt.autoSize = TextFieldAutoSize.LEFT;
		txtPrompt.height = 32;
		
		#if (cpp || neko) // BUGFIX
		// fix margins bug.
		txtConsole.x += 10;
		txtConsole.width -= 10;
		txtPrompt.x += 10;
		txtPrompt.width -= 10;
		// fix bad starting font bug.
		txtPrompt.text = '';
		#end
	}
	
	@:allow(pgr.gconsole.GConsole)
	function showConsole() {
		consoleDisplay.visible = true;
		promptDisplay.visible = true;
		Lib.current.stage.focus = txtPrompt;
	}
	@:allow(pgr.gconsole.GConsole)
	function hideConsole() {
		consoleDisplay.visible = false;
		promptDisplay.visible = false;
	}
	
	//---------------------------------------------------------------------------------
	//  MONITOR
	//---------------------------------------------------------------------------------
	function createMonitorDisplay() {
		
		monitorDisplay = new Sprite();
		monitorDisplay.graphics.beginFill(GCThemes.current.MON_C, GCThemes.current.MON_A);
		monitorDisplay.graphics.drawRect(0, 0, Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
		monitorDisplay.graphics.endFill();
		monitorDisplay.alpha = GCThemes.current.MON_TXT_A;
		addChild(monitorDisplay);
		
		txtMonitorLeft = new TextField();
		txtMonitorLeft.selectable = false;
		txtMonitorLeft.multiline = true;
		txtMonitorLeft.wordWrap = true;
		txtMonitorLeft.x = 0;
		txtMonitorLeft.width = Lib.current.stage.stageWidth / 2;
		txtMonitorLeft.height = Lib.current.stage.stageHeight;
		monitorDisplay.addChild(txtMonitorLeft);
		
		txtMonitorRight = new TextField();
		txtMonitorRight.selectable = false;
		txtMonitorRight.multiline = true;
		txtMonitorRight.wordWrap = true;
		txtMonitorRight.x = Lib.current.stage.stageWidth / 2;
		txtMonitorRight.width = Lib.current.stage.stageWidth / 2;
		txtMonitorRight.height = Lib.current.stage.stageHeight;
		monitorDisplay.addChild(txtMonitorRight);
		monitorDisplay.visible = false;
		
	}
	
	// Splits output into left and right monitor text fields
	public function writeMonitorOutput(output:Array<String>) {
		txtMonitorLeft.text = "";
		txtMonitorRight.text = "";
		
		txtMonitorLeft.text += "GC Monitor\n\n";
		txtMonitorRight.text += "\n\n";
		
		monitorDisplay.graphics.lineStyle(1, GCThemes.current.MON_TXT_C);
		monitorDisplay.graphics.moveTo(0, txtMonitorLeft.textHeight);
		monitorDisplay.graphics.lineTo(Lib.current.stage.stageWidth, txtMonitorLeft.textHeight);
		
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
	
	@:allow(pgr.gconsole.GConsole)
	function showMonitor() {
		monitorDisplay.visible = true;
	}
	@:allow(pgr.gconsole.GConsole)
	function hideMonitor() {
		monitorDisplay.visible = false;
	}
	
	//---------------------------------------------------------------------------------
	//  PROFILER
	//---------------------------------------------------------------------------------
	function createProfilerDisplay() {
		
		profilerDisplay = new Sprite();
		profilerDisplay.graphics.beginFill(GCThemes.current.MON_C, GCThemes.current.MON_A);
		profilerDisplay.graphics.drawRect(0, 0, Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
		profilerDisplay.graphics.endFill();
		addChild(profilerDisplay);
		
		txtProfiler = new TextField();
		txtProfiler.selectable = false;
		txtProfiler.multiline = true;
		txtProfiler.wordWrap = true;
		txtProfiler.alpha = GCThemes.current.MON_TXT_A;
		txtProfiler.x = 0;
		txtProfiler.y = 0;
		txtProfiler.width = Lib.current.stage.stageWidth;
		txtProfiler.height = Lib.current.stage.stageHeight;
		profilerDisplay.addChild(txtProfiler);
		profilerDisplay.visible = false;
	}
	
	public function writeProfilerOutput(output:String) {
		
		txtProfiler.text = "GC Profiler\n\n";
		
		profilerDisplay.graphics.lineStyle(1, GCThemes.current.MON_TXT_C);
		profilerDisplay.graphics.moveTo(0, txtProfiler.textHeight);
		profilerDisplay.graphics.lineTo(Lib.current.stage.stageWidth, txtProfiler.textHeight);
		txtProfiler.text += output;
	}
	
	@:allow(pgr.gconsole.GConsole)
	function showProfiler() {
		profilerDisplay.visible = true;
	}
	
	@:allow(pgr.gconsole.GConsole)
	function hideProfiler() {
		profilerDisplay.visible = false;
	}
	
	//---------------------------------------------------------------------------------
	//  PUBLIC METHODS
	//---------------------------------------------------------------------------------
	public function log(data:Dynamic, color:Int) {
		// Adds text to console interface
		var tf = txtConsole; 
		tf.appendText(Std.string(data) + '\n');
		tf.scrollV = tf.maxScrollV;
		
		// Applies color - is always applied to avoid bug.
		if (color == -1) {
			color = GCThemes.current.CON_TXT_C;
		}
		
		// Applies text formatting
		var format:TextFormat = new TextFormat();
		format.color = color;
		var l = Std.string(data).length;
		tf.setTextFormat(format, tf.text.length - l - 1, tf.text.length - 1);
	}
	
	public function moveCarretToEnd() {
		#if !(cpp || neko)
		txtPrompt.setSelection(txtPrompt.length, txtPrompt.length);
		#end
	}
	
	public function scrollConsoleUp() {
		txtConsole.scrollV += txtConsole.bottomScrollV - txtConsole.scrollV +1;
		if (txtConsole.scrollV > txtConsole.maxScrollV)
			txtConsole.scrollV = txtConsole.maxScrollV;
	}
	
	public function scrollConsoleDown() {
		txtConsole.scrollV -= txtConsole.bottomScrollV - txtConsole.scrollV +1;
		if (txtConsole.scrollV < 0)
			txtConsole.scrollV = 0;
	}
	
	/**
	 * Brings this display object to the front of display list.
	 */
	public function toFront() {
		Lib.current.stage.swapChildren(this, Lib.current.stage.getChildAt(Lib.current.stage.numChildren - 1));
	}
	
	public function setConsoleFont(font:String = null, embed:Bool = false, size:Int = 14, bold:Bool = false, italic:Bool = false, underline:Bool = false ){
		#if (flash || html5)
		if (font == null) {
		#else
		if (font == null && Sys.systemName() == "Windows") {
		#end
			font = "Consolas";
		}
		embed ? txtConsole.embedFonts = true : txtConsole.embedFonts = false;
		txtConsole.defaultTextFormat = new TextFormat(font, size, GCThemes.current.CON_TXT_C, bold, italic, underline, '', '', TextFormatAlign.LEFT, margin, margin);
		// TODO - redraw console here?
	}
	
	
	public function setPromptFont(font:String = null, embed:Bool = false, size:Int = 16, bold:Bool = false, ?italic:Bool = false, underline:Bool = false ){
		#if (flash || html5)
		if (font == null) {
		#else
		if (font == null && Sys.systemName() == "Windows") {
		#end
			font = "Consolas";
		}
		embed ? txtPrompt.embedFonts = true : txtPrompt.embedFonts = false;
		txtPrompt.defaultTextFormat = new TextFormat(font, size, GCThemes.current.PRM_TXT_C, bold, italic, underline, '', '' , TextFormatAlign.LEFT);
		// TODO - redraw console here?
	}
	
	public function setProfilerFont(font:String = null, embed:Bool = false, size:Int = 14, bold:Bool = false, ?italic:Bool = false, underline:Bool = false ){
		#if (flash || html5)
		if (font == null) {
		#else
		if (font == null && Sys.systemName() == "Windows") {
		#end
			font = "Consolas";
		}
		
		embed ? txtProfiler.embedFonts = true : txtProfiler.embedFonts = false;
		txtProfiler.defaultTextFormat = new TextFormat(font, size, GCThemes.current.MON_TXT_C, bold, italic, underline, '', '', TextFormatAlign.LEFT, 10,10);
	}
	
	public function setMonitorFont(font:String = null, embed:Bool = false, size:Int = 14, bold:Bool = false, ?italic:Bool = false, underline:Bool = false ){
		#if (flash || html5)
		if (font == null) {
		#else
		if (font == null && Sys.systemName() == "Windows") {
		#end
			font = "Consolas";
		}
		
		embed ? txtMonitorLeft.embedFonts = true : txtMonitorLeft.embedFonts = false;
		embed ? txtMonitorRight.embedFonts = true : txtMonitorRight.embedFonts = false;
		txtMonitorLeft.defaultTextFormat = new TextFormat(font, size, GCThemes.current.MON_TXT_C, bold, italic, underline, '', '', TextFormatAlign.LEFT, 10,10);
		txtMonitorRight.defaultTextFormat = new TextFormat(font, size, GCThemes.current.MON_TXT_C, bold, italic, underline, '', '', TextFormatAlign.LEFT, 10,10);
	}
	
	/**
	 * Removes last input char
	 */
	public function inputRemoveLastChar() {
		if (txtPrompt.text.length > 0) {
			txtPrompt.text = txtPrompt.text.substr(0, txtPrompt.text.length - 1);
		}
	}
	
	
	public function getInputTxt():String {
		return txtPrompt.text;
	}
	
	
	public function setInputTxt(string:String) {
		txtPrompt.text = string;
	}
	
	
	public function getConsoleText():String {
		return txtConsole.text;
	}
	
	
	public function clearInput() {
		txtPrompt.text = "";
	}
	
	
	public function clearConsole() {
		txtConsole.text = "";
	}

	
}