/**
 *  @(#) LogicalOrExpression.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
import java.util.Map;

public class LogicalOrExpression extends BinaryExpression {
    public LogicalOrExpression(Expression left, Expression right) {
        super(TokenType.OR, left, right);
    }
    public Object evaluate(Map context) {
        Object value;
        value = _left.evaluate(context);
        if (BooleanExpression.isTrue(value))
            return Boolean.TRUE;
        value = _right.evaluate(context);
        if (BooleanExpression.isTrue(value))
            return Boolean.TRUE;
        return Boolean.FALSE;
    }
    public Object accept(ExpressionVisitor visitor) {
        return visitor.visitLogicalOrExpression(this);
    }
}
