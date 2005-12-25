/**
 *  @(#) ExecutionException.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

public class ExecutionException extends BaseException {
    private static final long serialVersionUID = 3011275883746869947L;

    public ExecutionException(String message) {
        super(message);
    }
    public ExecutionException(String message, Exception cause) {
        super(message, cause);
    }
    public ExecutionException(Exception cause) {
        super(cause);
    }
}
