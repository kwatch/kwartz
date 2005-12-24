/**
 *  @(#) ArithmeticExpression.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
import java.util.Map;

public class ArithmeticExpression extends BinaryExpression {
    public ArithmeticExpression(int token, Expression left, Expression right) {
        super(token, left, right);
    }

    public Object evaluate(Map context) {
        Object lvalue = _left.evaluate(context);
        if (lvalue == null)
            throw new EvaluationException("lvalue of '" + TokenType.inspect(_token) + "' is null.");
        if (! (lvalue instanceof Integer || lvalue instanceof Double) )
            throw new EvaluationException("required integer or double but got " + lvalue.getClass().getName() + ".");
        Object rvalue = _right.evaluate(context);
        if (rvalue == null)
            throw new EvaluationException("rvalue of '" + TokenType.inspect(_token) + "' is null.");
        if (! (rvalue instanceof Integer || rvalue instanceof Double) )
            throw new EvaluationException("required integer or double but got " + rvalue.getClass().getName() + ".");
        Number lval = (Number)lvalue;
        Number rval = (Number)rvalue;
        boolean is_int = (lvalue instanceof Integer && rvalue instanceof Integer);
        if (is_int) {
            int l = lval.intValue();
            int r = rval.intValue();
            int v = 0;
            switch (_token) {
              case TokenType.ADD:  v = l + r;  break;
              case TokenType.SUB:  v = l - r;  break;
              case TokenType.MUL:  v = l * r;  break;
              case TokenType.DIV:  v = l / r;  break;
              case TokenType.MOD:  v = l % r;  break;
              default:
                assert false;
            }
            return new Integer(v);
        } else {
            double l = lval.doubleValue();
            double r = rval.doubleValue();
            double v = 0;
            switch (_token) {
              case TokenType.ADD:  v = l + r;  break;
              case TokenType.SUB:  v = l - r;  break;
              case TokenType.MUL:  v = l * r;  break;
              case TokenType.DIV:  v = l / r;  break;
              case TokenType.MOD:  v = l % r;  break;
              default:
                assert false;
            }
            return new Double(v);
        }
        //return null;
    }

    public Object accept(ExpressionVisitor visitor) {
        return visitor.visitArithmeticExpression(this);
    }
}
