/**
 *  @(#) Function.java
 *  @Id  $Id$
 *  @copyright (C)2005 kuwata-lab.com all rights reserverd
 */

package com.kuwata_lab.kwartz;
import java.util.Map;
import java.util.HashMap;

abstract public class Function {
    protected String _name;
    
    public Function(String funcname) {
        _name = funcname;
    }
    
    public String getName() { return _name; }
    public void setName(String name) { _name = name; }
    
    abstract public Object call(Map context, Expression[] arguments);
    
    static Map _instances = new HashMap();
    public static void register(Function function) {
        register(function.getName(), function);
    }
    public static void register(String funcname, Function function) {
        _instances.put(funcname, function);
    }
    
    public static Function getInstance(String funcname) {
        return (Function)_instances.get(funcname);
    }
    
    public static boolean isRegistered(String funcname) {
        return _instances.containsKey(funcname);
    }
}
