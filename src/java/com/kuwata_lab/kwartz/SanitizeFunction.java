/**
 *  @(#) SanitizeFunction.java
 *  @Id  $Id$
 *  @copyright (C)2005 kuwata-lab.com all rights reserverd
 */

package com.kuwata_lab.kwartz;
import java.util.Map;

public class SanitizeFunction extends Function {
    public SanitizeFunction() {
        super("E");	// 'E' means 'escape'
    }
    
    public Object call(Map context, Expression[] arguments) {
        assert arguments.length == 1;
        Expression expr = arguments[0];
        Object val = expr.evaluate(context);
        String s = (String)val;
        s = s.replaceAll("&", "&amp;");
        s = s.replaceAll("<", "&lt;");
        s = s.replaceAll(">", "&gt;");
        s = s.replaceAll("\"", "&quot");
        return s;
    }
    
    static {
        Function.register(new SanitizeFunction());
    }
}
