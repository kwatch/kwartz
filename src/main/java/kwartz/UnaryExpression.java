/**
 *  @(#) UnaryExpression.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
import java.util.Map;

public class UnaryExpression extends Expression {
    protected Expression _factor;

    public UnaryExpression(int token, Expression factor) {
        super(token);
        _factor = factor;
    }

    public Expression getFactor() { return _factor; }

    /*
    public Object evaluate(Map context, Visitor executer) {
        executer.executeUnaryExpression(context, _factor);
    }
     */

    public Object accept(ExpressionVisitor visitor) {
        return visitor.visitUnaryExpression(this);
    }

    public Object evaluate(Map context) {
        Object val = _factor.evaluate(context);
        switch (_token) {
          case TokenType.PLUS:
            if (val instanceof Integer || val instanceof Double) {
                return val;
            } else {
                throw new EvaluationException("unary plus operator should be used with number.");
            }
          case TokenType.MINUS:
            if (val instanceof Integer) {
                return new Integer(((Integer)val).intValue() * -1);
            } else if (val instanceof Double) {
                return new Double(((Double)val).doubleValue() * -1);
            } else {
                throw new EvaluationException("unary plus operator should be used with number.");
            }
          case TokenType.NOT:
            if (val == Boolean.TRUE) {
                return Boolean.FALSE;
            } else if (val == Boolean.FALSE) {
                return Boolean.TRUE;
            } else {
                throw new EvaluationException("unary not operator should be used with boolean.");
            }
        }
        assert false;
        return null;
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        super._inspect(level, sb);
        _factor._inspect(level+1, sb);
        return sb;
    }
}
