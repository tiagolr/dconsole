package pgr.gconsole;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import pgr.gconsole.GCProfiler.PFSample;

typedef PFSample = {
	name:String,			
	startTime:Int,
	elapsed:Int,
	instances:Int, 		// number of begin() 
	openInstances:Int, 	// number of begin() without end()
	numParents:Int, 	// number of parents
	childrenElapsed:Int	// time elapsed for all children
}

/**
 * Mesures time elapsed between two points inside an application code.
 * Writes the last elapsed time and average to monitor output.
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class GCProfiler extends Sprite {
	
	/** Number of spaces between each display field (Elapsed, average, etc..) */
	static public inline var NUM_SPACES:Int = 8;
	
	public var startTime(default, null):Int;
	public var refreshRate(default, null):Int;
	
	var samples:Map<String,PFSample>;
	var txtOutput:TextField;
	var history:Map<String, SampleHistory>;
	
	public function new() {
		super();
		
		refreshRate = 1;
		history = new Map<String, SampleHistory>();
		
		samples = new Map<String, PFSample>();
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
		
		txtOutput = new TextField();
		txtOutput.selectable = false;
		txtOutput.multiline = true;
		txtOutput.wordWrap = true;
		txtOutput.alpha = GCThemes.current.MON_TXT_A;
		txtOutput.x = 0;
		txtOutput.y = 0;
		txtOutput.width = Lib.current.stage.width;
		txtOutput.height = Lib.current.stage.height;
		addChild(txtOutput);
		
		// loads default font.
		setFont();
	}
	
	public function setFont(font:String = null, embed:Bool = false, size:Int = 14, bold:Bool = false, ?italic:Bool = false, underline:Bool = false ){
		if (font == null) {
			font = "Consolas";
		}
		
		embed ? txtOutput.embedFonts = true : txtOutput.embedFonts = false;
		txtOutput.defaultTextFormat = new TextFormat(font, size, GCThemes.current.MON_TXT_C, bold, italic, underline, '', '', TextFormatAlign.LEFT, 10,10);
	}
	
	//---------------------------------------------------------------------------------
	//  LOGIC
	//---------------------------------------------------------------------------------
	public function show() {
		this.visible = true;
		
		GConsole.instance.monitor.hide();
		
		removeEventListener(Event.ENTER_FRAME, refresh);  // prevent duplicate listeners
		addEventListener(Event.ENTER_FRAME, refresh);

		startTime = Lib.getTimer();
		refresh(null);	// renders first frame.
	}

	
	public function hide() {
		this.visible = false;		
		removeEventListener(Event.ENTER_FRAME, refresh);
	}
		
	
	public function begin(sampleName:String) {
		
		var sample:PFSample;
		
		if (samples.exists(sampleName)) {
			
			sample = samples.get(sampleName);
			sample.openInstances++;
			sample.instances++;
			sample.startTime = Lib.getTimer();
			sample.childrenElapsed = 0;
			
			if (sample.openInstances > 1) {
				throw sampleName + " already started.";
			}
			
		} else {
			// create new sample.
			sample = 
			{
				name:sampleName,
				startTime:Lib.getTimer(),
				elapsed:0,
				instances:1,
				openInstances:1,
				numParents:0,
				childrenElapsed:0
			};
			
			samples.set(sampleName, sample);
		}
		
	}
	
	public function end(sampleName:String) {
		if (!samples.exists(sampleName)) {
			throw sampleName + "not found";
		}
		
		var sample:PFSample = samples.get(sampleName);
		var parent:String = "";
		var elapsed:Int;
		
		
		if (sample.openInstances < 1) {
			throw sampleName + " is not started";
		}
		
		sample.openInstances--;
		
		// find sample most direct parent (if any)
		sample.numParents = 0;
		for (s in samples.iterator()) {
			if (s.openInstances > 0 && s.name != sample.name) { // any other opened samples are parents.
				sample.numParents++;
				
				// set newly found parent.
				if (parent == "") {
					parent = s.name; 
				} else {
					
					// update to more immediate parent.
					if (s.startTime >= samples.get(parent).startTime) {
						parent = s.name;
					}
				}
			}
		}
		
		// accumulate elapsed time
		var elapsed = Lib.getTimer() - sample.startTime;
		sample.elapsed += elapsed;
		
		// accumulate parent.childrenElapsed with sample elapsed time
		if (parent != "") {
			samples[parent].childrenElapsed += elapsed;
		}
		
		
		// if this sample is not nested, create output.
		if (sample.numParents == 0) {
			createOutput(sample);
		}
		
	}
	
	
	private function createOutput(sample:PFSample) {	
		var entry:SampleHistory;
		
		// updates history existing entry or 
		// creates new entry for this sample
		if (history.exists(sample.name)) {
		 	entry = history[sample.name];
			entry.addEntry(sample);
		} else {
			entry = new SampleHistory(sample);
			history.set(entry.name, entry);
		}
		
		// updates children entries for the sample.
		for (s in samples.iterator()) {
			
			// all instances must be closed when the last instance ends.
			if (s.openInstances > 0) { 
				throw "nested sample " + s.name + " is still open when closing " + sample.name;
			}
			
			if (s.name != sample.name) {
				entry.addChildEntry(samples[s.name]);
			}
		}
			
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
			writeOutput();
			startTime = Lib.getTimer();
		}
	}
	
	function addFormatedDisplay(data:String, addSeparator = true) {
		txtOutput.text += StringTools.lpad(data, " ", NUM_SPACES);
		txtOutput.text += " ";
		if (addSeparator) {
			txtOutput.text += "|";
		}
	}
	
	
	public function writeOutput() {
		
		txtOutput.text = "";
		txtOutput.text += "GC Profiler\n";
		
		graphics.lineStyle(1, GCThemes.current.MON_TXT_C);
		graphics.moveTo(0, txtOutput.textHeight);
		graphics.lineTo(Lib.current.stage.width, txtOutput.textHeight);
		
		txtOutput.text += "\n";
		addFormatedDisplay("EL");
		addFormatedDisplay("AVG");
		addFormatedDisplay("EL (%)");
		addFormatedDisplay("AVG(%)");
		addFormatedDisplay("#");
		addFormatedDisplay("NAME", false);
		
		txtOutput.text += "\n";
		txtOutput.text += StringTools.rpad("-", "-", (NUM_SPACES + 1) * 7);
		txtOutput.text += "\n";
		
		for (entry in history.iterator()) {
			
			addFormatedDisplay(entry.getElapsed());
			addFormatedDisplay(entry.getAverage());
			addFormatedDisplay(entry.getPercentElapsed(entry.totalElapsed));
			addFormatedDisplay(entry.getPercentAverage(entry.totalElapsed));
			addFormatedDisplay(Std.string(entry.instances));
			txtOutput.text += " " + entry.getFormattedName();
			txtOutput.text += "\n";
			
			for (child in entry.childHistory.iterator()) {
				addFormatedDisplay(child.getElapsed());
				addFormatedDisplay(child.getAverage());
				addFormatedDisplay(child.getPercentElapsed(entry.totalElapsed));
				addFormatedDisplay(child.getPercentAverage(entry.totalElapsed));
				addFormatedDisplay(Std.string(child.instances));
				txtOutput.text += " " + child.getFormattedName();
				txtOutput.text += "\n";
			}
		}
		
	}
	
}

private class SampleHistory {
	
	public var name:String;
	public var elapsed:Int;
	public var totalElapsed:Int;
	public var minElapsed:Int;
	public var maxElapsed:Int;
	public var avgElapsed:Int;
	public var childrenElapsed:Int;
	public var totalChildrenElapsed:Int;
	public var instances:Int;
	public var numParents:Int;
	
	private var nLogs:Int;
	
	public var childHistory:Map<String, SampleHistory>;
	
	public function new (s:PFSample) {
		childHistory = new Map<String, SampleHistory>();
		nLogs = 1;
		
		this.name = s.name;
		this.elapsed = s.elapsed;
		// todo total elapsed.
		// todo min elapsed.
		// todo max elapsed.
		// todo avg elapsed.
		
		this.childrenElapsed = s.childrenElapsed;
		this.instances = s.instances;
		this.numParents = s.numParents;
		
		this.totalElapsed += elapsed;
		this.totalChildrenElapsed += childrenElapsed;
	}
	
	public function addEntry(s:PFSample) {
		if (s.name != name) {
			throw "adding profile history entry from different sample.";
		}
		
		this.childrenElapsed = s.childrenElapsed;
		this.elapsed = s.elapsed;
		this.instances = s.instances;
		this.numParents = s.numParents;
		
		this.totalElapsed += elapsed;
		this.totalChildrenElapsed += elapsed;
		
		nLogs++;
		
		// clears child history for this next entry
		childHistory = new Map<String, SampleHistory>(); 
		
	}
	/**
	 * Adds child history sample.
	 */
	public function addChildEntry(s:PFSample) {
		if (s.name == name) {
			throw "adding " + s.name + " to " + name + " as child sample.";
		}
		
		var child:SampleHistory;
		
		if (!childHistory.exists(s.name)) {
			child = new SampleHistory(s);
			childHistory.set(child.name, child);
		} else {
			child = childHistory[s.name];
			child.addEntry(s);
		}
	}
	/**
	 * Returns elapsed time.
	 */
	public function getElapsed():String {
		return Std.string(elapsed);
	}
	/**
	 * Returns average elapsed time.
	 */
	public function getAverage():String {
		return Std.string(totalElapsed / nLogs);
	}
	/**
	 * Returns elapsed time relative to children.
	 */
	public function getRelElapsed():String {
		return Std.string(elapsed - childrenElapsed);
	}
	/**
	 * Returns average elapsed time relative to children.
	 */
	public function getRelAverage():String {
		return Std.string(Std.int((totalElapsed - totalChildrenElapsed) / nLogs));
	}
	/**
	 * Gets relative time usage percentage 
	 */
	public function getPercentElapsed(totalTime:Int):String {
		return Std.string(Std.int((elapsed - childrenElapsed) * 100 / totalTime * 10) / 10);
	}
	/**
	 * 
	 */
	public function getPercentAverage(totalTime:Int):String {
		return Std.string(Std.int((totalElapsed - totalChildrenElapsed) / nLogs * 100 / totalTime * 10) / 10);
	}
	
	/**
	 * Returns idented name.
	 */
	public function getFormattedName():String {
		var s = "";
		for (i in 0...this.numParents) {
			s += "    ";
		}
		s += name;
		return s;
	}
	
}

