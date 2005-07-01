/**
 *  @(#) AsIsFunction.java
 *  @Id  $Id$
 *  @copyright (C)2005 kuwata-lab.com all rights reserverd
 */
package com.kuwata_lab.kwartz;
import java.util.Map;

public class AsIsFunction extends Function {
    public AsIsFunction() {
        super("X");
    }

    public Object call(Map context, Expression[] arguments) {
        assert arguments.length == 1;
        Expression expr = arguments[0];
        return expr.evaluate(context);
    }

    static {
        Function.register(new AsIsFunction());
    }
}
