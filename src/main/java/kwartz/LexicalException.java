/**
 *  @(#) LexicalException.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

public class LexicalException extends SyntaxException {
    private static final long serialVersionUID = -1904152072142872798L;

    public LexicalException(String message, String filename, int linenum, int column) {
        super(message, filename, linenum, column);
    }
}
