/**
 *  @(#) Function.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
import java.util.Map;
import java.util.HashMap;

abstract public class Function {
    protected String _name;

    //public Function(String funcname) {
    //    _name = funcname;
    //}

    public String getName() { return _name; }
    public void setName(String name) { _name = name; }

    abstract public Object call(Map context, Expression[] arguments);

    abstract public int arity();

    static Map __instances = new HashMap();
    static Map instances() { return __instances; }
    public static void register(String funcname, Function function) {
        __instances.put(funcname, function);
        function.setName(funcname);
    }
    public static Function getInstance(String funcname) {
        return (Function)__instances.get(funcname);
    }
    public static boolean isRegistered(String funcname) {
        return __instances.containsKey(funcname);
    }
}
