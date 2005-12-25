/**
 *  @(#) SemanticException.java
 *  @Id  $Id: SemanticException.java 23 2005-12-24 00:45:48Z kwatch $
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;


public class SemanticException extends ParseException {
    private static final long serialVersionUID = 5743614619260664632L;

    public SemanticException(String message, String filename, int linenum, int column) {
        super(message, filename, linenum, column);
    }
}
