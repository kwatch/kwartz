/**
 *  @(#) BooleanExpression.java
 *  @Id  $Id$
 *  @copyright (C)2005 kuwata-lab.com all rights reserverd
 */
package com.kuwata_lab.kwartz;
import java.util.Map;

public class BooleanExpression extends LiteralExpression {
    private boolean _value;
    public BooleanExpression(boolean value) {
        super(value ? TokenType.TRUE : TokenType.FALSE);
        _value = value;
    }
    public Object evaluate(Map context) {
        return _value ? Boolean.TRUE : Boolean.FALSE;
    }
    public Object accept(Visitor visitor) {
        return visitor.visitBooleanExpression(this);
    }

    public static boolean isFalse(Object value) {
        //return (value == null || value.equals(Boolean.FALSE));
        return (value == null || value == (Object)Boolean.FALSE);
    }

    public static boolean isTrue(Object value) {
        //return (value != null && ! value.equals(Boolean.FALSE));
        return (value != null && value != (Object)Boolean.FALSE);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        for (int i = 0; i < level; i++) sb.append("  ");
        sb.append(_value ? "true\n" : "false\n");
        return sb;
    }
}
