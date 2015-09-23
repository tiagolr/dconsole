#if openfl
package pgr.dconsole.ui;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import openfl.display.Stage;
import openfl.events.Event;
import pgr.dconsole.DCThemes.Theme;

/**
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */

class DCOpenflInterface extends Sprite implements DCInterface
{
	public var console:DConsole;
	
	var _promptFontYOffset:Int;
	var yAlign:String;
	var heightPt:Float; // percentage height
	var widthPt:Float; // percentage width
	var maxWidth:Float; // width in pixels
	var maxHeight:Float; // height in pixels
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
	
	public function new(heightPt:Float, align:String) {
		super();
		Lib.current.stage.addChild(this); // by default the interface adds itself to the stage.
		
		if (heightPt <= 0 || heightPt > 100) heightPt = 100; // clamp to >0..1
		if (heightPt > 1) heightPt = Std.int(heightPt) / 100; // turn >0..100 into percentage from 1..0
		
		this.heightPt = heightPt;
		yAlign = align;
	}
	
	public function init() {
		createMonitorDisplay();
		createProfilerDisplay();
		createConsoleDisplay();
		
		setConsoleFont();
		setMonitorFont();
		setProfilerFont();
		setPromptFont();
		
		onResize();
		Lib.current.stage.addEventListener(Event.RESIZE, onResize);
	}
	
	function onResize(e:Event = null) {
		
		//if (Std.is(this.parent, openfl.display.Stage)) {
			//var stg:Stage = cast this.parent;
			maxWidth = this.stage.stageWidth;
			maxHeight = this.stage.stageHeight;
		//} else {
			//maxWidth = this.parent.width;
			//maxHeight = this.parent.height;
		//}
		
		drawConsole(); // redraws console.
		drawMonitor();
		drawProfiler();
	}
	
	
	function createConsoleDisplay() {
		consoleDisplay = new Sprite();
		consoleDisplay.alpha = DCThemes.current.CON_TXT_A;
		consoleDisplay.mouseEnabled = false;
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
		txtConsole.mouseEnabled = false;
		txtConsole.multiline = true;
		txtConsole.wordWrap = true;
		txtConsole.alpha = DCThemes.current.CON_TXT_A;
		consoleDisplay.addChild(txtConsole);
		#if flash
		txtConsole.mouseWheelEnabled = true;
		#end
		
	}
	
	/** 
	 * Draws console fields after changes to console appearence
	 */
	function drawConsole() {
		
		var _yOffset = (yAlign == DC.ALIGN_DOWN) ? maxHeight - maxHeight * heightPt: 0; 
		
		// draw console background.
		consoleDisplay.graphics.clear();
		consoleDisplay.graphics.beginFill(DCThemes.current.CON_C, 1);
		consoleDisplay.graphics.drawRect(0, 0, maxWidth, maxHeight * heightPt);
		consoleDisplay.graphics.endFill();
		consoleDisplay.y = _yOffset;
		consoleDisplay.alpha = DCThemes.current.CON_A;
		
		// draw text input field.
		promptDisplay.graphics.clear();
		promptDisplay.graphics.beginFill(DCThemes.current.PRM_C);
		promptDisplay.graphics.drawRect(0, 0, maxWidth, txtPrompt.textHeight);
		promptDisplay.graphics.endFill();
		promptDisplay.y = consoleDisplay.y + maxHeight * heightPt - txtPrompt.textHeight;
		
		// Resize textfields
		txtConsole.width = maxWidth;
		txtConsole.x = 0;
		txtPrompt.x = 0;
		txtConsole.height = maxHeight * heightPt - txtPrompt.textHeight + 2;
		
		txtPrompt.y = - 2; // -2 just looks better.
		txtPrompt.width = maxWidth;
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
	
	public function showConsole() {
		consoleDisplay.visible = true;
		promptDisplay.visible = true;
		toFront();
		Lib.current.stage.focus = txtPrompt;
	}
	
	public function hideConsole() {
		consoleDisplay.visible = false;
		promptDisplay.visible = false;
		Lib.current.stage.focus = null;
	}
	
	//---------------------------------------------------------------------------------
	//  MONITOR
	//---------------------------------------------------------------------------------
	function createMonitorDisplay() {
		
		monitorDisplay = new Sprite();
		monitorDisplay.mouseEnabled = false;
		monitorDisplay.mouseChildren = false;
		addChild(monitorDisplay);
		
		txtMonitorLeft = new TextField();
		txtMonitorLeft.selectable = false;
		txtMonitorLeft.multiline = true;
		txtMonitorLeft.wordWrap = true;
		monitorDisplay.addChild(txtMonitorLeft);
		
		txtMonitorRight = new TextField();
		txtMonitorRight.selectable = false;
		txtMonitorRight.multiline = true;
		txtMonitorRight.wordWrap = true;
		monitorDisplay.addChild(txtMonitorRight);
		monitorDisplay.visible = false;
	}
	
	function drawMonitor() {
		
		// draws background
		monitorDisplay.graphics.clear(); 
		monitorDisplay.graphics.beginFill(DCThemes.current.MON_C, DCThemes.current.MON_A);
		monitorDisplay.graphics.drawRect(0, 0, maxWidth, maxHeight);
		monitorDisplay.graphics.endFill();
		// draws decoration line
		var s = txtMonitorLeft.text;
		txtMonitorLeft.text = " ";
		var h = txtMonitorLeft.textHeight; 
		monitorDisplay.alpha = DCThemes.current.MON_TXT_A; 
		monitorDisplay.graphics.lineStyle(1, DCThemes.current.MON_TXT_C);
		monitorDisplay.graphics.moveTo(0, h);
		monitorDisplay.graphics.lineTo(maxWidth, h);
		txtMonitorLeft.text = s;
		// position and scales left text
		txtMonitorLeft.x = 0;
		txtMonitorLeft.width = maxWidth / 2;
		txtMonitorLeft.height = maxHeight;
		// position and scale right text
		txtMonitorRight.x = maxWidth / 2;
		txtMonitorRight.width = maxWidth / 2;
		txtMonitorRight.height = maxHeight;
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
	}
	public function hideMonitor() {
		monitorDisplay.visible = false;
	}
	
	//---------------------------------------------------------------------------------
	//  PROFILER
	//---------------------------------------------------------------------------------
	function createProfilerDisplay() {
		
		profilerDisplay = new Sprite();
		profilerDisplay.mouseEnabled = false;
		profilerDisplay.mouseChildren = false;
		addChild(profilerDisplay);
		
		txtProfiler = new TextField();
		txtProfiler.selectable = false;
		txtProfiler.multiline = true;
		txtProfiler.wordWrap = true;
		profilerDisplay.addChild(txtProfiler);
		profilerDisplay.visible = false;
	}
	
	function drawProfiler() {
		
		// draw background
		profilerDisplay.graphics.clear();
		profilerDisplay.graphics.beginFill(DCThemes.current.MON_C, DCThemes.current.MON_A);
		profilerDisplay.graphics.drawRect(0, 0, maxWidth, maxHeight);
		profilerDisplay.graphics.endFill();
		// draw decoration line
		var s = txtProfiler.text;
		txtProfiler.text = " ";
		var h = txtProfiler.textHeight;
		profilerDisplay.graphics.lineStyle(1, DCThemes.current.MON_TXT_C); 
		profilerDisplay.graphics.moveTo(0, h);
		profilerDisplay.graphics.lineTo(maxWidth, h);
		txtProfiler.text = s;
		// position and scale monitor text
		txtProfiler.alpha = DCThemes.current.MON_TXT_A;
		txtProfiler.width = maxWidth;
		txtProfiler.height = maxHeight;
	}
	
	public function writeProfilerOutput(output:String) {
		txtProfiler.text = "DC Profiler\n\n";
		txtProfiler.text += output;
	}
	
	public function showProfiler() {
		profilerDisplay.visible = true;
	}
	
	public function hideProfiler() {
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
			color = DCThemes.current.CON_TXT_C;
		}
		
		// Applies text formatting
		var format:TextFormat = new TextFormat();
		format.color = color;
		var l = Std.string(data).length;
		tf.setTextFormat(format, tf.text.length - l - 1, tf.text.length - 1);
		scrollToBottom();
	}
	
	public function moveCarretToEnd() {
		#if !(cpp || neko)
		txtPrompt.setSelection(txtPrompt.length, txtPrompt.length);
		#end
	}
	
	public function scrollConsoleUp() {
		txtConsole.scrollV -= txtConsole.bottomScrollV - txtConsole.scrollV +1;
		if (txtConsole.scrollV < 0)
			txtConsole.scrollV = 0;
	}
	
	public function scrollConsoleDown() {
		txtConsole.scrollV += txtConsole.bottomScrollV - txtConsole.scrollV +1;
		if (txtConsole.scrollV > txtConsole.maxScrollV)
			txtConsole.scrollV = txtConsole.maxScrollV;
	}
	
	function scrollToBottom() {
		txtConsole.scrollV = txtConsole.maxScrollV;
	}
	
	/**
	 * Brings this display object to the front of display list.
	 */
	public function toFront() {
		parent.setChildIndex(this, parent.numChildren - 1);
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
		txtConsole.defaultTextFormat = new TextFormat(font, size, DCThemes.current.CON_TXT_C, bold, italic, underline, '', '', TextFormatAlign.LEFT, margin, margin);
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
		txtPrompt.defaultTextFormat = new TextFormat(font, size, DCThemes.current.PRM_TXT_C, bold, italic, underline, '', '' , TextFormatAlign.LEFT);
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
		txtProfiler.defaultTextFormat = new TextFormat(font, size, DCThemes.current.MON_TXT_C, bold, italic, underline, '', '', TextFormatAlign.LEFT, 10,10);
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
		txtMonitorLeft.defaultTextFormat = new TextFormat(font, size, DCThemes.current.MON_TXT_C, bold, italic, underline, '', '', TextFormatAlign.LEFT, 10,10);
		txtMonitorRight.defaultTextFormat = new TextFormat(font, size, DCThemes.current.MON_TXT_C, bold, italic, underline, '', '', TextFormatAlign.LEFT, 10,10);
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
	
	public function getMonitorText() {
		return {
			col1:txtMonitorLeft.text, 
			col2:txtMonitorRight.text, 
		}
	}
	
	
	public function clearInput() {
		txtPrompt.text = "";
	}
	
	
	public function clearConsole() {
		txtConsole.text = "";
	}

	
}
#end