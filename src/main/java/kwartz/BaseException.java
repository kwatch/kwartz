/**
 *  @(#) BaseException.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

public class BaseException extends RuntimeException {
    private static final long serialVersionUID = -6474403282066115815L;

    public BaseException(String message) {
        super(message);
    }
    public BaseException(String message, Throwable cause) {
        super(message, cause);
    }
    public BaseException(Throwable cause) {
        super(cause);
    }
}
