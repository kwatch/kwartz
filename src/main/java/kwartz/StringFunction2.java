/**
 *  @(#) StringFunction2.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
import java.util.Map;

abstract public class StringFunction2 extends Function {
    public int arity() { return 2; }

    public Object call(Map context, Expression[] arguments) {
        assert arguments.length == 2;
        Object str1 = arguments[0].evaluate(context);
        if (str1 == null)
            throw new EvaluationException(getName() + "(): first argument is null.");
        Object str2 = arguments[1].evaluate(context);
        if (str2 == null)
            throw new EvaluationException(getName() + "(): second argument is null.");
        return perform(str1.toString(), str2.toString());
    }

    abstract protected Object perform(String str1, String str2);
}
