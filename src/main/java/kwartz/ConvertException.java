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
	
	public String toString() {
		StringBuffer sb = new StringBuffer();
		sb.append(_filename != null ? _filename : "").append(':');
		if (_linenum > 0) sb.append(_linenum).append(':');
		sb.append(' ').append(getMessage());
		return sb.toString();
	}
	
}
