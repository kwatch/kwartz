/**
 *  @(#) FloatExpression.java
 *  @Id  $Id$
 *  @copyright (C)2005 kuwata-lab.com all rights reserverd
 */

package com.kuwata_lab.kwartz;
import java.util.Map;

public class FloatExpression extends LiteralExpression {
    private float _value;
    public FloatExpression(float value) {
        super(TokenType.FLOAT);
        _value = value;
    }
    public Object evaluate(Map context) {
        return new Float(_value);
    }
    public Object accept(Visitor visitor) {
        return visitor.visitFloatExpression(this);
    }
    
    public StringBuffer _inspect(int level, StringBuffer sb) {
        for (int i = 0; i < level; i++) sb.append("  ");
        sb.append(_value);
        sb.append("\n");
        return sb;
    }
}
