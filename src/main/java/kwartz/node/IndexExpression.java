/**
 *  @(#) IndexExpression.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.node;
import java.util.Map;
import java.util.List;

import kwartz.EvaluationException;
import kwartz.TokenType;

public class IndexExpression extends BinaryExpression {
    public IndexExpression(int token, Expression left, Expression right) {
        super(token, left, right);
    }
    public Object evaluate(Map context) {
        Object lvalue = _left.evaluate(context);
        Object rvalue = _right.evaluate(context);
        switch (_token) {
          case TokenType.ARRAY:
            if (lvalue instanceof Map) {
                return ((Map)lvalue).get(rvalue);
            }
            else if (lvalue instanceof List) {
                if (! (rvalue instanceof Integer)) {
                    throw new EvaluationException("index of List object is not an integer.");
                }
                int index = ((Integer)rvalue).intValue();
                return ((List)lvalue).get(index);
            }
            else if (lvalue.getClass().isArray()) {
                if (! (rvalue instanceof Integer)) {
                    throw new EvaluationException("index of array is not an integer.");
                }
                int index = ((Integer)rvalue).intValue();
                return ((Object[])lvalue)[index];
            }
            throw new EvaluationException("invalid '[]' operator for non-list,map,nor array.");
            //break;

          case TokenType.HASH:
            if (lvalue instanceof Map) {
                return ((Map)lvalue).get(rvalue);
            }
            throw new EvaluationException("invalid '[:]' operator for non-map object.");

          default:
            assert false;
        }
        return null;
    }
    public Object accept(ExpressionVisitor visitor) {
        return visitor.visitIndexExpression(this);
    }

}
