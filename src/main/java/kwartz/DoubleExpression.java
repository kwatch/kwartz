/**
 *  @(#) DoubleExpression.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
import java.util.Map;

public class DoubleExpression extends LiteralExpression {
    private double _value;
    public DoubleExpression(double value) {
        super(TokenType.DOUBLE);
        _value = value;
    }
    public Object evaluate(Map context) {
        return new Double(_value);
    }
    public Object accept(ExpressionVisitor visitor) {
        return visitor.visitDoubleExpression(this);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        for (int i = 0; i < level; i++) sb.append("  ");
        sb.append(_value);
        sb.append("\n");
        return sb;
    }
}
