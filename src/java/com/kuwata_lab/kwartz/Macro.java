/**
 *  @(#) Macro.java
 *  @Id  $Id$
 *  @copyright (C)2005 kuwata-lab.com all rights reserverd
 */

package com.kuwata_lab.kwartz;
import java.util.Map;
import java.util.HashMap;

abstract public class Macro {
    protected String _name;
    
    public Macro(String macroname) {
        _name = macroname;
    }
    
    public String getName() { return _name; }
    public void setName(String name) { _name = name; }
    
    abstract public Expression call(Expression expr);
    
    static Map _instances = new HashMap();
    public static void register(Macro macro) {
        register(macro.getName(), macro);
    }
    public static void register(String name, Macro macro) {
        _instances.put(name, macro);
    }
    public static Macro getInstance(String name) {
        return (Macro)_instances.get(name);
    }
    public static boolean isRegistered(String name) {
        return _instances.containsKey(name);
    }
}
