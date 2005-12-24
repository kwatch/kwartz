/**
 *  @(#) ExecutionException.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

public class ExecutionException extends BaseException {
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
