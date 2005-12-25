/**
 *  @(#) StringFunctionN.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.function;

import kwartz.EvaluationException;
import kwartz.Function;
import kwartz.node.Expression;

import java.util.Map;

abstract public class StringFunctionN extends Function {
    //public int arity() { return N; }

    public Object call(Map context, Expression[] arguments) {
        int len = arity();
        if (len != arguments.length)
            throw new EvaluationException(getName() + "(): number of arguments is expected " + len + " but got " + arguments.length + ".");
        String[] vals = new String[len];
        for (int i = 0; i < len; i++) {
            Expression expr = arguments[0];
            Object val = expr.evaluate(context);
            if (val == null)
                throw new EvaluationException(getName() + "(): argument" + i + " is null.");
            if (! (val instanceof String))
                throw new EvaluationException(getName() + "(): argument" + i + " is not a string.");
            vals[i] = (String)val;
        }
        return perform(vals);
    }

    abstract protected Object perform(String[] args);
}
