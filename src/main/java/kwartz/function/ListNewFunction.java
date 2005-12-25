/**
 *  @(#) ListNewFunction.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.function;

import kwartz.Function;
import kwartz.node.Expression;

import java.util.Map;
import java.util.ArrayList;

public class ListNewFunction extends Function {
    public int arity() { return 0; }

    public Object call(Map context, Expression[] arguments) {
        return new ArrayList();
    }
}
