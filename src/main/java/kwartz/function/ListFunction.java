/**
 *  @(#) ListFunction.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.function;

import kwartz.EvaluationException;
import kwartz.Function;
import kwartz.node.Expression;

import java.util.Map;
import java.util.List;

abstract public class ListFunction extends Function {
    public int arity() { return 1; }

    public Object call(Map context, Expression[] arguments) {
        assert arguments.length == 1;
        Object list = arguments[0].evaluate(context);
        if (list == null)  throw new EvaluationException(getName() + "(): argument is null.");
        if (list instanceof List) {
            return perform((List)list);
        }
        if (list.getClass().isArray()) {
            return perform((Object[])list);
        }
        throw new EvaluationException(getName() + "(): argument is not a List nor an Array.");
    }

    abstract protected Object perform(List list);
    abstract protected Object perform(Object[] list);
}
