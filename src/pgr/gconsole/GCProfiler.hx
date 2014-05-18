package pgr.gconsole;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import pgr.gconsole.GCProfiler.PFSample;
import pgr.gconsole.GCProfiler.SampleHistory;

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
class GCProfiler extends Sprite {
	
	/** Number of spaces between each display field (Elapsed, average, etc..) */
	static public inline var NUM_SPACES:Int = 8;
	
	public var refreshTimer(default, null):Int;
	public var refreshRate(default, null):Int;
	
	public var samples:Array<PFSample>;
	public var history:Array<SampleHistory>;
	public var txtOutput:TextField;
	
	public function new() {
		super();
		
		refreshRate = 100;
		history = new Array<SampleHistory>();
		
		samples = new Array<PFSample>();
		create();
		
	}
	
	public function clear() {
		for (sample in samples) {
			if (sample.openInstances > 0) {
				GC.logWarning("cannot clear profiler while samples are open");
			}
		}
		
		history = new Array<SampleHistory>();
		samples = new Array<PFSample>();
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
		txtOutput.width = Lib.current.stage.stageWidth;
		txtOutput.height = Lib.current.stage.stageHeight;
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

		refreshTimer = Lib.getTimer();
		refresh(null);	// renders first frame.
	}

	
	public function hide() {
		this.visible = false;		
		removeEventListener(Event.ENTER_FRAME, refresh);
	}
		
	
	public function begin(sampleName:String) {
		
		var sample:PFSample = getSample(sampleName);
		
		if (sample != null) {
			
			// reset some stats and relaunch sample.
			sample.openInstances++;
			sample.instances++;
			sample.startTime = Lib.getTimer();
			sample.parentName = "";
			
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
		
		
		var endTime = Lib.getTimer();
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
			
			// clears all samples after top tree sample has finished.
			s.numParents = 0;
			s.parentName = "";
			s.elapsed = 0;
			s.openInstances = 0;
			s.instances = 0;
			s.childrenElapsed = 0;
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
		var elapsed = Lib.getTimer() - refreshTimer;
		
		if (elapsed > refreshRate || e == null) {
			
			 //refreshes monitor screen
			writeOutput();
			refreshTimer = Lib.getTimer();
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
		graphics.lineTo(Lib.current.stage.stageWidth, txtOutput.textHeight);
		
		txtOutput.text += "\n";
		addFormatedDisplay("EL");
		addFormatedDisplay("AVG");
		addFormatedDisplay("EL(%)");
		addFormatedDisplay("AVG(%)");
		addFormatedDisplay("#");
		addFormatedDisplay("NAME", false);
		
		txtOutput.text += "\n";
		txtOutput.text += StringTools.rpad("-", "-", (NUM_SPACES + 1) * 7);
		txtOutput.text += "\n";
		
		
		for (entry in history) {
			
			addFormatedDisplay(entry.getRelElapsed());
			addFormatedDisplay(entry.getRelAverage());
			addFormatedDisplay(entry.getPercentElapsed(entry.elapsed));
			addFormatedDisplay(entry.getPercentAverage(entry.totalElapsed));
			addFormatedDisplay(Std.string(entry.branchInstances));
			txtOutput.text += " " + entry.getFormattedName();
			txtOutput.text += "\n";
			
			
			for (child in entry.childHistory) {
				addFormatedDisplay(child.getRelElapsed());
				addFormatedDisplay(child.getRelAverage());
				addFormatedDisplay(child.getPercentElapsed(entry.elapsed));
				addFormatedDisplay(child.getPercentAverage(entry.totalElapsed));
				addFormatedDisplay(Std.string(child.branchInstances));
				txtOutput.text += " " + child.getFormattedName();
				txtOutput.text += "\n";
			}
		}
		
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

