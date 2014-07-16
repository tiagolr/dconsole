package ;
import haxe.unit.TestRunner;
class TestRunner {
    
    static function main(){
        var r = new haxe.unit.TestRunner();
		
		r.add(new TestInput());
		r.add(new TestRegister());
		r.add(new TestCommands());
		r.add(new TestUtils());
		r.add(new TestMonitor());
		r.add(new TestProfiler());
        r.run();
		
		#if COVERAGE
		var logger = mcover.coverage.MCoverage.getLogger();
		logger.report();
		#end
		
		#if !flash
		Sys.exit(0);
		#end
    }
}