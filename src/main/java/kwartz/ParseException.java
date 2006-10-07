package kwartz;

public abstract class ParseException extends Exception {

	private int _linenum;
	private int _column;
	
	public ParseException(String message, int linenum, int column) {
		super(message);
		_linenum = linenum;
		_column = column;
	}

	public int getLinenum() {
		return _linenum;
	}
	
	public int getColumn() {
		return _column;
	}
	
	public String toString() {
		return "" + _linenum + ":" + _column + ": " + getMessage();
	}
	
}


class LexicalException extends ParseException {
	private static final long serialVersionUID = 3375932246192210086L;

	public LexicalException(String message, int linenum, int column) {
		super(message, linenum, column);
	}
}


class SyntaxException extends ParseException {
	private static final long serialVersionUID = 6286154360674917994L;

	public SyntaxException(String message, int linenum, int column) {
		super(message, linenum, column);
	}
}


class SemanticException extends ParseException {
	private static final long serialVersionUID = -6387243429274657383L;

	public SemanticException(String message, int linenum, int column) {
		super(message, linenum, column);
	}
}
