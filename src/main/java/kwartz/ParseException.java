/**
 *  @(#) ParseException.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

public class ParseException extends BaseException {
    private static final long serialVersionUID = 7824260596798960405L;

    private int    _linenum;
    private int    _column;
    private String _filename;

    public ParseException(String message, String filename, int linenum, int column) {
        super(message);
        _linenum  = linenum;
        _column   = column;
        _filename = filename;
    }

    public String toString() {
        return super.toString() + "(filename " + _filename + ", line " + _linenum + ", column " + _column + ")";
    }
}
