package pgr.dconsole;
import haxe.Timer;
import pgr.dconsole.DCProfiler.PFSample;
import pgr.dconsole.DCProfiler.SampleHistory;

typedef PFSample = {
	name:String,			
	startTime:Int,
	elapsed:Int,
	instances:Int, 		// number of begin() 
	openInstances:Int, 	// number of begin() without end()
	numParents:Int, 	// number of parents
	parentName:String,
	childrenElapsed:Int	// time elapsed for all children
}

/**
 * Mesures time elapsed between two points inside an application code.
 * Writes the last elapsed time and average to monitor output.
 * 
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class DCProfiler {
	
	/** Number of spaces between each display field (Elapsed, average, etc..) */
	static public inline var NUM_SPACES:Int = 8;
	
	public var refreshRate(default, null):Int = 100;
	public var visible(default, null):Bool;
	public var samples:Array<PFSample>;
	public var history:Array<SampleHistory>;
	
	var console:DConsole;
	var refreshTimer:Timer;
	
	public function new(console:DConsole) {
		this.console = console;
		history = new Array<SampleHistory>();
		samples = new Array<PFSample>();
		setRefreshRate();
	}
	
	public function clear() {
		for (sample in samples) {
			if (sample.openInstances > 0) {
				DC.logWarning("cannot clear profiler while samples are open");
			}
		}
		
		history = new Array<SampleHistory>();
		samples = new Array<PFSample>();
	}
	
	//---------------------------------------------------------------------------------
	//  LOGIC
	//---------------------------------------------------------------------------------
	@:allow(pgr.dconsole.DConsole)
	function show() {
		visible = true;
		startTimer();
		writeOutput();	// renders first frame.
	}

	@:allow(pgr.dconsole.DConsole)
	function hide() {
		visible = false;
	}
		
	
	public function begin(sampleName:String) {
		
		var sample:PFSample = getSample(sampleName);
		
		if (sample != null) {
			
			// reset some stats and relaunch sample.
			sample.openInstances++;
			sample.instances++;
			sample.startTime = getTimeMS();
			sample.parentName = "";
			
			if (sample.openInstances > 1) {
				throw sampleName + " already started.";
			}
			
		} else {
			// create new sample.
			sample = 
			{
				name:sampleName,
				startTime: getTimeMS(),
				elapsed:0,
				instances:1,
				openInstances:1,
				numParents:0,
				parentName:"",
				childrenElapsed:0
			};
			samples.push(sample);
		}
		setSampleParent(sample);
	}
	
	public function end(sampleName:String) {
		var sample:PFSample = getSample(sampleName);
		
		if (sample == null) {
			throw sampleName + "not found";
		}
		var endTime = getTimeMS();
		var elapsed = endTime - sample.startTime;
		
		if (sample.openInstances < 1) {
			throw sampleName + " is not started";
		}
		
		sample.openInstances--;
		
		// accumulate elapsed time
		sample.elapsed += elapsed;
		
		// accumulate parent.childrenElapsed with sample elapsed time
		if (sample.parentName != "") {		
			getSample(sample.parentName).childrenElapsed += elapsed;
		}
		
		// if this sample is not nested, create (or update) output for sample and its children
		if (sample.numParents == 0) {
			createHistory(sample);
		}
	}
	
	
	private function createHistory(sample:PFSample) {	
		var entry:SampleHistory = getHistory(sample.name);
		
		// updates history entry
		if (entry != null) {
			entry.clearBranchSamples();
			entry.update(sample);
		} else {
			// creates new entry
			entry = new SampleHistory(sample);
			history.push(entry);
		}
		
		for (s in samples) {
			//
			// updates children entries for the sample.
			if (s.numParents > 0 && s.name != sample.name) {
				entry.addChildEntry(s);
			}
			
			if (s.openInstances > 0) {
				throw "cross sampling detected: " + s.name + " is still open inside " + sample.name; 
			}
			
			// clears all samples after top tree sample has finished.
			s.numParents = 0;
			s.parentName = "";
			s.elapsed = 0;
			s.openInstances = 0;
			s.instances = 0;
			s.childrenElapsed = 0;
		}
	}
	
	
	public function setRefreshRate(refreshRate:Int = 100) {
		this.refreshRate = refreshRate;
	}
	
	
	function getFormatedDisplay(data:String, addSeparator = true):String {
		var formatted:String = "";
		
		formatted += StringTools.lpad(data, " ", NUM_SPACES);
		formatted += " ";
		if (addSeparator) {
			formatted += "|";
		}
		
		return formatted;
	}
	
	
	public function writeOutput() {
		
		var output:String = "";
		
		output += getFormatedDisplay("EL");
		output += getFormatedDisplay("AVG");
		output += getFormatedDisplay("EL(%)");
		output += getFormatedDisplay("AVG(%)");
		output += getFormatedDisplay("#");
		output += getFormatedDisplay("NAME", false);
		output += "\n";
		output += StringTools.rpad("-", "-", (NUM_SPACES + 1) * 7);
		output += "\n";
		
		for (entry in history) {
			
			output += getFormatedDisplay(entry.getRelElapsed());
			output += getFormatedDisplay(entry.getRelAverage());
			output += getFormatedDisplay(entry.getPercentElapsed(entry.elapsed));
			output += getFormatedDisplay(entry.getPercentAverage(entry.totalElapsed));
			output += getFormatedDisplay(Std.string(entry.branchInstances));
			output += " " + entry.getFormattedName();
			output += "\n";
			
			for (child in entry.childHistory) {
				output += getFormatedDisplay(child.getRelElapsed());
				output += getFormatedDisplay(child.getRelAverage());
				output += getFormatedDisplay(child.getPercentElapsed(entry.elapsed));
				output += getFormatedDisplay(child.getPercentAverage(entry.totalElapsed));
				output += getFormatedDisplay(Std.string(child.branchInstances));
				output += " " + child.getFormattedName();
				output += "\n";
			}
		}
		
		console.interfc.writeProfilerOutput(output);
		
	}
	
	public function setSampleParent(sample:PFSample) {
		sample.numParents = 0;
		
		for (s in samples) {
			if (s.openInstances > 0 && s.name != sample.name) { // any other opened samples are parents.
				
				sample.numParents++;
				// set newly found parent.
				if (sample.parentName == "") {
					sample.parentName = s.name;
				} else {
					// set open sample with most parents as this sample parent
					if (s.numParents > getSample(sample.parentName).numParents) {
						sample.parentName = s.name;
					}
				}
			}
		}
	}
	
	public function getSample(sampleName):PFSample {
		for (sample in samples) {
			if (sample.name == sampleName) {
				return sample;
			}
		}
		return null;
	}
	
	public function getHistory(entryName):SampleHistory {
		for (entry in history) {
			if (entry.name == entryName) {
				return entry;
			}
		}
		return null;
	}
	
	
	function startTimer() {
		if (!visible) {
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
	
	function getTimeMS():Int {
		return Std.int(Timer.stamp() * 1000);
	}
}

class SampleHistory {
	
	public var name:String = "";
	public var elapsed:Int = 0;
	public var totalElapsed:Int = 0;
	public var minElapsed:Int = 0;
	public var maxElapsed:Int = 0;
	public var avgElapsed:Int = 0;
	public var childrenElapsed:Int = 0;
	public var totalChildrenElapsed:Int = 0;
	public var branchInstances:Int = 0;
	public var instances:Int = 0;
	public var numParents:Int = 0;
	public var startTime:Int; // used to sort history arrays
	
	public var nLogs:Int = 0;
	
	public var childHistory:Array<SampleHistory>;
	
	public function new (s:PFSample) {
		childHistory = new Array<SampleHistory>();
		
		this.name = s.name;
		this.elapsed = s.elapsed;
		minElapsed = elapsed;
		maxElapsed = elapsed;
		
		update(s);
	}
	
	public function clearBranchSamples() {
		branchInstances = 0;
		for (child in childHistory) {
			child.branchInstances = 0;
		}
	}
	
	public function update(s:PFSample) {
		if (s.name != name) {
			throw "updating history from different sample.";
		}
		
		this.childrenElapsed = s.childrenElapsed;
		this.elapsed = s.elapsed;
		
		if (elapsed > maxElapsed) {
			maxElapsed = elapsed;
		}
		
		if (elapsed < minElapsed) {
			minElapsed = elapsed;
		}
		this.startTime = s.startTime;
		this.instances += s.instances;
		this.branchInstances += s.instances;
		this.numParents = s.numParents;
		
		this.totalElapsed += elapsed;
		this.totalChildrenElapsed += childrenElapsed;
		
		nLogs++;
	}
	/**
	 * Adds child history sample.
	 */
	public function addChildEntry(s:PFSample) {
		if (s.name == name) {
			throw "adding " + s.name + " to " + name + " as child sample.";
		}
		
		var child:SampleHistory = getChild(s.name);
		
		if (child == null) {
			child = new SampleHistory(s);
			childHistory.push(child);
		} else {
			child.update(s);
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
	 * 
	 */
	public function getMinElapsed():String {
		return Std.string(minElapsed);
	}
	/**
	 * 
	 */
	public function getMaxElapsed():String {
		return Std.string(maxElapsed);
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
	public function getPercentElapsed(parentElapsed:Int):String {
		return Std.string(Std.int((elapsed - childrenElapsed) * 100 / parentElapsed * 10) / 10);
	}
	/**
	 * 
	 */
	public function getPercentAverage(totalTime:Int):String {
		return Std.string(Std.int((totalElapsed - totalChildrenElapsed) * 100 / totalTime * 10) / 10);
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
	
	public function getChild(childName):SampleHistory {
		for (child in childHistory) {
			if (child.name == childName) {
				return child;
			}
		}
		return null;
	}
	
}

