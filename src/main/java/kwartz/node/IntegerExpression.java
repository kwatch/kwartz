/**
 *  @(#) IntegerExpression.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.node;
import java.util.Map;

import kwartz.TokenType;

public class IntegerExpression extends LiteralExpression {
    private int _value;
    public IntegerExpression(int value) {
        super(TokenType.INTEGER);
        _value = value;
    }
    public Object evaluate(Map context) {
        return new Integer(_value);
    }
    public Object accept(ExpressionVisitor visitor) {
        return visitor.visitIntegerExpression(this);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        for (int i = 0; i < level; i++) sb.append("  ");
        sb.append(_value);
        sb.append("\n");
        return sb;
    }
}
