/**
 *  @(#) LogicalAndExpression.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
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
    public Object accept(ExpressionVisitor visitor) {
        return visitor.visitLogicalAndExpression(this);
    }
}
