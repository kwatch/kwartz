/**
 *  @(#) SyntaxException.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

public class SyntaxException extends ParseException {
    public SyntaxException(String message, String filename, int linenum, int column) {
        super(message, filename, linenum, column);
    }
}
