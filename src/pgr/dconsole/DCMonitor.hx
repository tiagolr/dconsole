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
	public var refreshRate(default, null):Int;
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
		stopTimer();
		startTimer();
		writeOutput(); // renders first frame.
	}

	@:allow(pgr.dconsole.DConsole)
	function hide() {
		visible = false;
		stopTimer();
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
		startTimer();
	}
	
	public function writeOutput() {
		var output = new Array<String>();
		
		for (v in fields) {
			output.push(v.alias + ': ' + Reflect.getProperty(v.object, v.field) + '\n');
		}
		
		console.interfc.writeMonitorOutput(output);
	}
	
	
	
	function stopTimer() {
		if (refreshTimer != null) {
			refreshTimer.stop();
			refreshTimer = null;
		}
	}
	
	function startTimer() {
		if (refreshTimer != null) {
			stopTimer();
		}
		refreshTimer = new Timer(refreshRate);
		refreshTimer.run = writeOutput;
	}
	
}
