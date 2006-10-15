package kwartz;

public abstract class ParseException extends Exception {

	private String _filename;
	private int _linenum;
	private int _column;
	
	public ParseException(String message, String filename, int linenum, int column) {
		super(message);
		_filename = filename;
		_linenum = linenum;
		_column = column;
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
	
	public int getColumn() {
		return _column;
	}
	
	public String toString() {
		return "" + _filename + ":" + _linenum + ":" + _column + ": " + getMessage();
	}
	
}


class LexicalException extends ParseException {
	private static final long serialVersionUID = 3375932246192210086L;

	public LexicalException(String message, String filename, int linenum, int column) {
		super(message, filename, linenum, column);
	}
}


class SyntaxException extends ParseException {
	private static final long serialVersionUID = 6286154360674917994L;

	public SyntaxException(String message, String filename, int linenum, int column) {
		super(message, filename, linenum, column);
	}
}


class SemanticException extends ParseException {
	private static final long serialVersionUID = -6387243429274657383L;

	public SemanticException(String message, String filename, int linenum, int column) {
		super(message, filename, linenum, column);
	}
}
