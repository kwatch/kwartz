/**
 *  @(#) LogicalAndExpression.java
 *  @Id  $Id$
 *  @copyright (C)2005 kuwata-lab.com all rights reserverd
 */

package com.kuwata_lab.kwartz;
import java.util.Map;

public class LogicalAndExpression extends BinaryExpression {
    public LogicalAndExpression(Expression left, Expression right) {
        super(TokenType.AND, left, right);
    }
    public Object evaluate(Map context) {
        Object value;
        value = _left.evaluate(context);
        if (BooleanExpression.isFalse(value))
            return Boolean.FALSE;
        value = _right.evaluate(context);
        if (BooleanExpression.isFalse(value))
            return Boolean.FALSE;
        return Boolean.TRUE;
    }
    public Object accept(Visitor visitor) {
        return visitor.visitLogicalAndExpression(this);
    }
}
