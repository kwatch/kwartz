/*
 * $Rev$
 * $Release$
 * $Copyright$
 */
package kwartz;

public class BaseException extends KwartzException {
	
	private static final long serialVersionUID = -7346731193704237098L;
	
	private String _filename;
	private int    _linenum;
	private int    _column;
	
	public BaseException(String message, String filename, int linenum, int column) {
		super(message);
		_filename = filename;
		_linenum  = linenum;
		_column   = column;
	}

	
	public String toString() {
		return "" + _filename + ":" + _linenum + ":" + _column + ": " + getMessage();
	}
	
	
	public String getFilename() { return _filename; }
	public void setFilename(String filename) { _filename = filename; }
	public int    getLinenum()  { return _linenum; }
	public int    getColumn()   { return _column; }
}
