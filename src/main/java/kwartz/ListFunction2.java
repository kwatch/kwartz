/**
 *  @(#) ListFunction2.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
import java.util.Map;
import java.util.List;

abstract public class ListFunction2 extends Function {
    public int arity() { return 2; }

    public Object call(Map context, Expression[] arguments) {
        assert arguments.length == 2;
        Object list = arguments[0].evaluate(context);
        if (list == null)  throw new EvaluationException(getName() + "(): argument is null.");
        Object val = arguments[1].evaluate(context);
        if (list instanceof List) {
            return perform((List)list, val);
        }
        if (list.getClass().isArray()) {
            return perform((Object[])list, val);
        }
        throw new EvaluationException(getName() + "(): argument is not a List nor an Array.");
    }

    abstract protected Object perform(List list, Object val);
    abstract protected Object perform(Object[] list, Object val);
}
