/*
 * $Rev$
 * $Release$
 * $Copyright$
 */

package kwartz;

public class TranslateException extends BaseException {
	
	private static final long serialVersionUID = 9064620139342373782L;

	public TranslateException(String message, String filename, int linenum, int column) {
		super(message, filename, linenum, column);
	}

}
