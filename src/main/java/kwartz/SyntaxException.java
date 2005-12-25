/**
 *  @(#) SyntaxException.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

public class SyntaxException extends ParseException {
    private static final long serialVersionUID = 3283815577466418928L;

    public SyntaxException(String message, String filename, int linenum, int column) {
        super(message, filename, linenum, column);
    }
}
