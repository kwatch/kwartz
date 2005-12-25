/**
 *  @(#) EvaluationException.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

public class EvaluationException extends BaseException {
    private static final long serialVersionUID = 296684085724897520L;

    public EvaluationException(String message) {
        super(message);
    }
    public EvaluationException(String message, Exception cause) {
        super(message, cause);
    }
    public EvaluationException(Exception cause) {
        super(cause);
    }
}
