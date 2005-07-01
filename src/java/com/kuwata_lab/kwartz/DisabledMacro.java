/**
 *  @(#) DisabledMacro.java
 *  @Id  $Id$
 *  @copyright (C)2005 kuwata-lab.com all rights reserverd
 */
package com.kuwata_lab.kwartz;

public class DisabledMacro extends Macro {
    public DisabledMacro() {
        super("D");
    }
    public Expression call(Expression expr) {
        Expression left = new StringExpression(" disabled=\"disabled\"");
        Expression right = new StringExpression("");
        return new ConditionalExpression(expr, left, right);
    }
    static {
        Macro.register(new DisabledMacro());
    }
}
