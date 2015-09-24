package pgr.dconsole;
import haxe.Timer;

typedef MonitorField = {
	object:Dynamic,
	field:String,
	alias:String,
}

/**
 * ...
 * @author TiagoLr
 */
class DCMonitor {

	public var startTime(default, null):Int;
	public var visible(default, null):Bool;
	public var refreshRate(default, null):Int = 100;
	public var fields:Array<MonitorField>;
	
	var refreshTimer:Timer;
	var hidden:Bool;
	var console:DConsole;
	
	public function new(console:DConsole) {
		this.console = console;
		fields = new Array<MonitorField>();
		setRefreshRate();
	}
	//---------------------------------------------------------------------------------
	//  LOGIC
	//---------------------------------------------------------------------------------
	@:allow(pgr.dconsole.DConsole)
	function show() {
		visible = true;
		writeOutput();
		startTimer();
	}

	@:allow(pgr.dconsole.DConsole)
	function hide() {
		visible = false;
	}
	
	public function addField(object:Dynamic, fieldName:String, alias:String) {
		var mfield:MonitorField = { object:object, field:fieldName, alias:alias };
		fields.push(mfield);
	}
	
	public function clear() {
		fields = new Array<MonitorField>();
	}
	
	
	public function setRefreshRate(refreshRate:Int = 100) {
		this.refreshRate = refreshRate;
	}
	
	public function writeOutput() {
		var output = new Array<String>();
		
		for (v in fields) {
			output.push(v.alias + ': ' + Reflect.getProperty(v.object, v.field) + '\n');
		}
		
		console.interfc.writeMonitorOutput(output);
	}
	
	function startTimer() {
		if (!this.visible) {
			return;
		}
		
		function onTimer() {
			writeOutput();
			startTimer();
		}
		
		#if openfl
		Timer.delay(onTimer, refreshRate);
		#elseif luxe
		Luxe.timer.schedule(refreshRate / 1000, onTimer);
		#end
	}
	
	
	
}
