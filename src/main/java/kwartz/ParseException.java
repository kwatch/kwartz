package kwartz;

public abstract class ParseException extends BaseException {

	public ParseException(String message, String filename, int linenum, int column) {
		super(message, filename, linenum, column);
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
