/**
 *  @(#) Macro.java
 *  @Id  $Id: Macro.java 23 2005-12-24 00:45:48Z kwatch $
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
import java.util.Map;
import java.util.HashMap;

import kwartz.node.Expression;

abstract public class Macro {
    protected String _name;

    //public Macro(String macroname) {
    //    _name = macroname;
    //}

    public String getName() { return _name; }
    public void setName(String name) { _name = name; }

    abstract public int arity();
    abstract public Expression expand(Expression[] args);

    static Map __instances = new HashMap();
    public static Map instances() { return __instances; }
    public static void register(String name, Macro macro) {
        __instances.put(name, macro);
        macro.setName(name);
    }
    public static Macro getInstance(String name) {
        return (Macro)__instances.get(name);
    }
    public static boolean isRegistered(String name) {
        return __instances.containsKey(name);
    }
}
