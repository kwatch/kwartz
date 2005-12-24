/**
 *  @(#) HashNewFunction.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.function;

import kwartz.Function;
import kwartz.Expression;
import java.util.Map;
import java.util.HashMap;

public class HashNewFunction extends Function {
    public int arity() { return 0; }

    public Object call(Map context, Expression[] arguments) {
        assert arguments.length == 0;
        return new HashMap();
    }
}
