package pgr.dconsole;
import hscript.Interp;

/**
 * Overrides hscript interp with small changes.
 * @author TiagoLr
 */
class DCInterp extends Interp {

	public function new () {
		super();
		declared = new Array();
		depth = 0;
	}
	
	override function get( o : Dynamic, f : String ) : Dynamic {
        if( o == null ) throw hscript.Expr.Error.EInvalidAccess(f);
        return Reflect.getProperty(o,f);
    }

    override function set( o : Dynamic, f : String, v : Dynamic ) : Dynamic {
        if( o == null ) throw hscript.Expr.Error.EInvalidAccess(f);
        Reflect.setProperty(o,f,v);
        return v;
    }
	
}