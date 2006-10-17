/*
 * $Rev$
 * $Release$
 * $Copyright$
 */
package kwartz;

public class ConvertException extends BaseException {
	private static final long serialVersionUID = 2999112241439484586L;

	public ConvertException(String message, String filename, int linenum) {
		super(message, filename, linenum, -1);
	}
	
	public String toString() {
		StringBuffer sb = new StringBuffer();
		sb.append(getFilename()).append(':').append(getLinenum()).append(':');
		sb.append(' ').append(getMessage());
		return sb.toString();
	}
	
}
