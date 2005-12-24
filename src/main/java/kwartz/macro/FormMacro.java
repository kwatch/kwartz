/**
 *  @(#) FormMacro.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.macro;

import kwartz.Macro;
import kwartz.Expression;
import kwartz.StringExpression;
import kwartz.ConditionalExpression;

abstract public class FormMacro extends Macro {
    public int arity() { return 1; }

    public Expression expand(Expression[] args) {
        assert args.length == arity();
        Expression left = new StringExpression(getValue());
        Expression right = new StringExpression("");
        return new ConditionalExpression(args[0], left, right);
    }

    abstract protected String getValue();
}
