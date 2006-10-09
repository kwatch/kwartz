/*
 * $Rev$
 * $Release$
 * $Copyright$
 */
package kwartz;

public class ConvertException extends KwartzException {
	private static final long serialVersionUID = 2999112241439484586L;

	String _filename;
	int    _linenum;

	public ConvertException(String message, String filename, int linenum) {
		super(message);
		_filename = filename;
		_linenum = linenum;
	}
	
	public String getFilename() {
		return _filename;
	}
	
	public void setFilename(String filename) {
		_filename = filename;
	}
	
	public int getLinenum() {
		return _linenum;
	}
	
}
