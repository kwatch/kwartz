/**
 *  @(#) SemanticException.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

public class SemanticException extends ParseException {
    public SemanticException(String message, String filename, int linenum, int column) {
        super(message, filename, linenum, column);
    }
}
