package pgr.dconsole.input;
import pgr.dconsole.DConsole;

/**
 * Handles input
 * @author TiagoLr
 */
interface DCInput {

	var console:DConsole;
	
	public function init():Void;
	public function enable():Void;
	public function disable():Void;
	
}