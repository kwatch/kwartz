/**
 *  @(#) ConvertionException.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

public class ConvertionException extends BaseException {
    private static final long serialVersionUID = -4252428578302794433L;

    private String _filename;
    private int _linenum;

    public ConvertionException(String message, String filename, int linenum) {
        super(message);
        _filename = filename;
        _linenum  = linenum;
    }

    public String toString() {
        return super.toString() + "(filename " + _filename + ", line " + _linenum + ")";
    }

}
