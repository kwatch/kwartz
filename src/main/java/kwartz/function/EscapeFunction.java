/**
 *  @(#) EscapeFunction.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.function;

import kwartz.Function;
import kwartz.node.Expression;

import java.util.Map;

abstract public class EscapeFunction extends Function {
    public int arity() { return 1; }

    public Object call(Map context, Expression[] arguments) {
        assert arguments.length == 1;
        Expression expr = arguments[0];
        Object val = expr.evaluate(context);
        return perform(val);
    }

    abstract protected Object perform(Object arg);
}
