/**
 *  @(#) SelectedMacro.java
 *  @Id  $Id$
 *  @copyright (C)2005 kuwata-lab.com all rights reserverd
 */

package com.kuwata_lab.kwartz;

public class SelectedMacro extends Macro {
    public SelectedMacro() {
        super("S");
    }
    public Expression call(Expression expr) {
        Expression left = new StringExpression(" checked=\"checked\"");
        Expression right = new StringExpression("");
        return new ConditionalExpression(expr, left, right);
    }
    static {
        Macro.register(new SelectedMacro());
    }
}
