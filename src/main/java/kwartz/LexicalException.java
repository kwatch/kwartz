/**
 *  @(#) LexicalException.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

public class LexicalException extends SyntaxException {
    public LexicalException(String message, String filename, int linenum, int column) {
        super(message, filename, linenum, column);
    }
}
