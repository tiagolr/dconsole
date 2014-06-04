package pgr.gconsole;
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
class GCMonitor {

	public var startTime(default, null):Int;
	public var visible(default, null):Bool;
	public var refreshRate(default, null):Int;
	public var fields:Array<MonitorField>;
	
	var refreshTimer:Timer;
	var hidden:Bool;
	
	public function new() {
		fields = new Array<MonitorField>();
		setRefreshRate();
	}
	//---------------------------------------------------------------------------------
	//  LOGIC
	//---------------------------------------------------------------------------------
	@:allow(pgr.gconsole.GConsole)
	function show() {
		visible = true;
		stopTimer();
		startTimer();
		writeOutput(); // renders first frame.
	}

	@:allow(pgr.gconsole.GConsole)
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
			output.push(v.alias + ':' + Reflect.getProperty(v.object, v.field) + '\n');
		}
		
		GConsole.instance.interfc.writeMonitorOutput(output);
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