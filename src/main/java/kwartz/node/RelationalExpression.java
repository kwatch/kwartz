/**
 *  @(#) RelationalExpression.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.node;
import java.util.Map;

import kwartz.EvaluationException;
import kwartz.TokenType;

public class RelationalExpression extends BinaryExpression {
    public RelationalExpression(int token, Expression left, Expression right) {
        super(token, left, right);
    }

    /*
    public Object evaluate(Map context, Evaluator evaluator) {
        return evaluator.evaluateRelationalExpression(context, self);
    }*/

    public Object evaluate(Map context) {
        Object lvalue = _left.evaluate(context);
        //if (lvalue == null)
        //    throw new EvaluationException("lvalue of '" + TokenType.inspect(_token) + "' is null.");
        Object rvalue = _right.evaluate(context);
        //if (rvalue == null)
        //    throw new EvaluationException("rvalue of '" + TokenType.inspect(_token) + "' is null.");
        //boolean is_number = false;
        if (lvalue instanceof Integer && rvalue instanceof Integer) {
            int lval = ((Number)lvalue).intValue();
            int rval = ((Number)rvalue).intValue();
            switch (_token) {
              case TokenType.LT:  return lval < rval  ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.GT:  return lval > rval  ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.LE:  return lval <= rval ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.GE:  return lval >= rval ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.EQ:  return lval == rval ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.NE:  return lval != rval ? Boolean.TRUE : Boolean.FALSE;
              default:
                assert false;
            }
        }
        else if (   (lvalue instanceof Integer || lvalue instanceof Double)
                 && (rvalue instanceof Integer || rvalue instanceof Double)) {
            double lval = ((Number)lvalue).doubleValue();
            double rval = ((Number)rvalue).doubleValue();
            switch (_token) {
              case TokenType.LT:  return lval < rval  ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.GT:  return lval > rval  ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.LE:  return lval <= rval ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.GE:  return lval >= rval ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.EQ:  return lval == rval ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.NE:  return lval != rval ? Boolean.TRUE : Boolean.FALSE;
              default:
                assert false;
            }
        }
        else if (lvalue == null || rvalue == null) {
            switch (_token) {
              case TokenType.EQ:
                return (lvalue == null && rvalue == null) ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.NE:
                return (lvalue == null && rvalue == null) ? Boolean.FALSE : Boolean.TRUE;
              case TokenType.LT:
              case TokenType.GT:
              case TokenType.LE:
              case TokenType.GE:
                String msg = (lvalue == null ? "lvalue" : "rvalue") + TokenType.inspect(_token) + " is null.";
                throw new EvaluationException(msg);
              default:
                assert false;
            }
        }
        else if ( (_token == TokenType.EQ || _token == TokenType.NE) && (lvalue == null || rvalue == null) ) {
            switch (_token) {
              case TokenType.EQ:
                return (lvalue == null && rvalue == null) ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.NE:
                return (lvalue == null && rvalue == null) ? Boolean.FALSE : Boolean.TRUE;
              default:
                assert false;
            }
        }
        else if (   (lvalue instanceof String || lvalue instanceof Integer || lvalue instanceof Double)
                 && (rvalue instanceof String || rvalue instanceof Integer || rvalue instanceof Double)) {
            String lval = lvalue.toString();
            String rval = rvalue.toString();
            switch (_token) {
              case TokenType.LT:  return lval.compareTo(rval) <  0 ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.GT:  return lval.compareTo(rval) >  0 ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.LE:  return lval.compareTo(rval) <= 0 ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.GE:  return lval.compareTo(rval) >= 0 ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.EQ:  return lval.compareTo(rval) == 0 ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.NE:  return lval.compareTo(rval) != 0 ? Boolean.TRUE : Boolean.FALSE;
              default:
                assert false;
            }
        }
        else {
            // error
            if (! (lvalue instanceof String || lvalue instanceof Integer || lvalue instanceof Double)) {
                throw new EvaluationException("cannot compare a '" + lvalue.getClass().getName() + "' object.");
            }
            if (! (rvalue instanceof String || rvalue instanceof Integer || rvalue instanceof Double)) {
                throw new EvaluationException("cannot compare a '" + rvalue.getClass().getName() + "' object.");
            }
            assert false;
        }
        return null;
    }

    public Object accept(ExpressionVisitor visitor) {
        return visitor.visitRelationalExpression(this);
    }
}
