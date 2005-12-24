/**
 *  @(#) StringFunction.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.function;

import kwartz.Function;
import kwartz.Expression;
import kwartz.EvaluationException;
import java.util.Map;

abstract public class StringFunction extends Function {
    public int arity() { return 1; }

    public Object call(Map context, Expression[] arguments) {
        assert arguments.length == 1;
        Object str = arguments[0].evaluate(context);
        if (str == null)
            throw new EvaluationException(getName() + "(): argument is null.");
        return perform(str.toString());
    }

    abstract protected Object perform(String str);
}
