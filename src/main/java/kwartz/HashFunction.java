/**
 *  @(#) HashFunction.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
import java.util.Map;

abstract public class HashFunction extends Function {
    public int arity() { return 1; }

    public Object call(Map context, Expression[] arguments) {
        assert arguments.length == 1;
        Object hash = arguments[0].evaluate(context);
        if (hash == null)  throw new EvaluationException(getName() + "(): argument is null.");
        if (hash instanceof Map) {
            return perform((Map)hash);
        }
        throw new EvaluationException(getName() + "(): argument is not a Map.");
    }

    abstract protected Object perform(Map hash);
}
