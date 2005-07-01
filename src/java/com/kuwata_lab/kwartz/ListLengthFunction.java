/**
 *  @(#) ListLengthFunction.java
 *  @Id  $Id$
 *  @copyright (C)2005 kuwata-lab.com all rights reserverd
 */
package com.kuwata_lab.kwartz;
import java.util.Map;
import java.util.List;

public class ListLengthFunction extends Function {
    public ListLengthFunction() {
        super("list_length");
    }
    public Object call(Map context, Expression[] arguments) {
        assert arguments.length == 1;
        Expression expr = arguments[0];
        Object val = expr.evaluate(context);
        if (val instanceof List) {
            return new Integer(((List)val).size());
        }
        if (val.getClass().isArray()) {
            int len = ((Object[])val).length;
            return new Integer(len);
        }
        throw new EvaluationException("list_length(): argument is not a List nor an Array.");
    }
}
