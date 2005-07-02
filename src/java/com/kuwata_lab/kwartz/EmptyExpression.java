/**
 *  @(#) EmptyExpression.java
 *  @Id  $Id$
 *  @copyright (C)2005 kuwata-lab.com all rights reserverd
 */
package com.kuwata_lab.kwartz;
import java.util.Map;

public class EmptyExpression extends Expression {
    protected Expression _arithmetic;
    public EmptyExpression(int token, Expression arithmetic) {
        super(token);
        _arithmetic = arithmetic;
    }
    public Expression getArithmetic() { return _arithmetic; }
    public void setArithmetic(Expression arithmetic) { _arithmetic = arithmetic; }

    public Object evaluate(Map context) {
        Object val = _arithmetic.evaluate(context);
        if (_token == TokenType.EMPTY) {
            if (val == null) return Boolean.TRUE;
            if (val instanceof String && val.equals("")) return Boolean.TRUE;
            return Boolean.FALSE;
        } else if (_token == TokenType.NOTEMPTY) {
            if (val == null) return Boolean.FALSE;
            if (val instanceof String && val.equals("")) return Boolean.FALSE;
            return Boolean.TRUE;
        }
        assert false;
        return null;
    }

    public Object accept(Visitor visitor) {
        return visitor.visitEmptyExpression(this);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        super._inspect(level, sb);
        _arithmetic._inspect(level+1, sb);
        return sb;
    }
}
