package pgr.gconsole;

import flash.display.Sprite;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;


/**
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */

class GCInterface extends Sprite
{
	private var _bg:Sprite;
	private var _height:Int;
	private var _promptBg:Sprite;
	private var _monitorBg:Sprite;
	private var _border:Sprite;
	private var _promptFontYOffset:Int;
	private var _theme:GCThemes.Theme;
	private var _width:Int;
	private var _yOffset:Int;
	
	public var txtConsole:TextField;
	public var txtPrompt:TextField;
	public var txtMonitorLeft:TextField;
	public var txtMonitorRight:TextField;
	
	public function new(height:Float, align:String, theme:GCThemes.Theme) {
		
		super();
		
		_width = Lib.current.stage.stageWidth;
		_height = Std.int(Lib.current.stage.stageHeight * height);
		align == "DOWN" ? _yOffset = Lib.current.stage.stageHeight - _height : _yOffset = 0;
		theme == null ? _theme = GCThemes.DEFAULT_THEME : _theme = theme;
		
		createMonitor();
		
		_bg = new Sprite();
		addChild(_bg);
		
		_promptBg = new Sprite();
		addChild(_promptBg);
		
		_border = new Sprite();
		addChild(_border);
		
		txtPrompt = new TextField();
		txtPrompt.type = TextFieldType.INPUT;
		txtPrompt.selectable = false;
		txtPrompt.multiline = false;
		txtPrompt.alpha = _theme.consTxtAlpha;
		setPromptFont();
		addChild(txtPrompt);
		
		txtConsole = new TextField();
		txtConsole.selectable = false;
		txtConsole.multiline = true;
		txtConsole.wordWrap = true;
		txtConsole.alpha = _theme.consTxtAlpha;
		setConsoleFont();
		addChild(txtConsole);
		#if flash
		txtConsole.mouseWheelEnabled = true;
		#end
		
			
		
		drawUI();
		resizeTextFields();
	}
	
	private function createMonitor()
	{
		_monitorBg = new Sprite();
		_monitorBg.graphics.beginFill(_theme.monBgColor, _theme.monBgAlpha);
		_monitorBg.graphics.drawRect(0, 0, Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
		_monitorBg.graphics.endFill();
		addChild(_monitorBg);	
		
		txtMonitorLeft = new TextField();
		txtMonitorLeft.selectable = false;
		txtMonitorLeft.multiline = true;
		txtMonitorLeft.alpha = _theme.monTxtAlpha;
		txtMonitorLeft.x = 0;
		txtMonitorLeft.width = _width / 2;
		txtMonitorLeft.height = _height;
		addChild(txtMonitorLeft);
		
		txtMonitorRight = new TextField();
		txtMonitorRight.selectable = false;
		txtMonitorRight.multiline = true;
		txtMonitorRight.alpha = _theme.monTxtAlpha;
		txtMonitorRight.x = _width / 2;
		txtMonitorRight.width = _width / 2;
		txtMonitorRight.height = _height;
		addChild(txtMonitorRight);
		
		setMonitorFont();
	}
	
	public function setConsoleFont(font:String = null, embed:Bool = false, size:Int = 14, bold:Bool = false, italic:Bool = false, underline:Bool = false )
	{
		if (font == null) font = "Consolas";
		embed ? txtConsole.embedFonts = true : txtConsole.embedFonts = false;
		txtConsole.defaultTextFormat = new TextFormat(font, size, _theme.consTxtColor, bold, italic, underline, '', '', TextFormatAlign.LEFT, 10, 10);
	}
	
	public function setPromptFont(font:String = null, embed:Bool = false, size:Int = 16, yOffset:Int = 22, bold:Bool = false, ?italic:Bool = false, underline:Bool = false )
	{
		if (font == null) font = "Consolas";
		_promptFontYOffset = yOffset;
		embed ? txtPrompt.embedFonts = true : txtPrompt.embedFonts = false;
		txtPrompt.defaultTextFormat = new TextFormat(font, size, _theme.promptTxtColor, bold, italic, underline, '', '' , TextFormatAlign.LEFT, 10, 10);
		resizeTextFields();
	}
	
	public function setMonitorFont(font:String = null, embed:Bool = false, size:Int = 14, bold:Bool = false, ?italic:Bool = false, underline:Bool = false )
	{
		if (font == null) font = "Consolas";
		embed ? txtMonitorLeft.embedFonts = true : txtMonitorLeft.embedFonts = false;
		embed ? txtMonitorRight.embedFonts = true : txtMonitorRight.embedFonts = false;
		txtMonitorLeft.defaultTextFormat = new TextFormat(font, size, _theme.monTxtColor, bold, italic, underline, '', '', TextFormatAlign.LEFT, 10,10);
		txtMonitorRight.defaultTextFormat = new TextFormat(font, size, _theme.monTxtColor, bold, italic, underline, '', '', TextFormatAlign.LEFT, 10,10);
	}
	
	public function drawUI() 
	{	
		_bg.graphics.clear;
		_bg.graphics.beginFill(_theme.consBgColor, 1);
		_bg.graphics.drawRect(0, 0, _width, _height);
		_bg.graphics.endFill();
		
		_promptBg.graphics.clear();
		_promptBg.graphics.beginFill(_theme.promptBgColor);
		_promptBg.graphics.drawRect(0, 0, _width, 20);
		_promptBg.graphics.endFill();
		_promptBg.graphics.lineStyle(3, _theme.promptTxtColor);
		
		_promptBg.graphics.moveTo(5 , 6);
		_promptBg.graphics.lineTo(6 , 7);
		_promptBg.graphics.moveTo(5 , 14);
		_promptBg.graphics.lineTo(6 , 15);
		
		_bg.y = _yOffset;
		_promptBg.y = _height - 20 + _yOffset;
		
		_bg.alpha = _theme.consBgAlpha;
		_promptBg.alpha = _theme.consBgAlpha;
		
		_border.graphics.clear();
		_border.graphics.lineStyle(1, 0xCCCCCC);
		_border.graphics.moveTo(0, 0);
		_border.graphics.lineTo(_width, 0);
		_border.graphics.lineStyle(1, 0x666666);
		_border.graphics.moveTo(0, 1);
		_border.graphics.lineTo(_width, 1);
		_border.alpha = _theme.consBgAlpha;
		
		if (_yOffset == 0) { // ALIGN UP
			_border.y = _promptBg.y + 20 + 2;
			_border.scaleY = -1;
		} else { // ALIGN DONW
			_border.y = _bg.y - 2;
		}
	}
	
	private function resizeTextFields() 
	{
		if (txtConsole == null || txtPrompt == null) return;
		
		txtConsole.x = 0;
		txtConsole.y = 0 + _yOffset;
		txtConsole.width = _width;
		txtConsole.height = _height - _promptFontYOffset;
		
		txtPrompt.x = 5;
		txtPrompt.y = _height - _promptFontYOffset + _yOffset;
		txtPrompt.width = _width;
		txtPrompt.height = 32;
		
		#if (cpp || neko)	// BUGFIX
		// fix margins bug.
		txtConsole.x += 10;
		txtConsole.width -= 10;
		txtPrompt.x += 10;
		txtPrompt.width -= 10;
		// fix bad starting font bug.
		txtPrompt.text = '';
		#end
	}
	public function toggleMonitor(turnOn:Bool) 
	{	
		_monitorBg.visible		= turnOn;
		txtMonitorLeft.visible	= turnOn;
		txtMonitorRight.visible	= turnOn;
	}
	
	public function toggleConsoleOn(turnOn:Bool) 
	{
		_bg.visible 	 	= turnOn;
		_promptBg.visible	= turnOn;
		_border.visible		= turnOn;
		txtConsole.visible	= turnOn;
		txtPrompt.visible	= turnOn;
	}
}