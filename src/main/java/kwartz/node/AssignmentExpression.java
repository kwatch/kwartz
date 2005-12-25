/**
 *  @(#) AssignmentExpression.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.node;
import java.util.List;
import java.util.Map;

import kwartz.EvaluationException;
import kwartz.TokenType;

public class AssignmentExpression extends BinaryExpression {
    public AssignmentExpression(int token, Expression left, Expression right) {
        super(token, left, right);
    }

    public Object evaluate(Map context) {
        // convert 'foo += 1'  to 'foo = foo + 1'
        if (_token != TokenType.ASSIGN) {
            synchronized(this) {
                if (_token != TokenType.ASSIGN) {
                    int op = TokenType.assignToArithmetic(_token);
                    /*
                    _right = op == TokenType.CONCAT ? new ConcatenationExpression(op, _left, _right)
                                                    : new ArithmeticExpression(op, _left, _right);
                     */
                    if (op == TokenType.CONCAT) {
                        _right = new ConcatenationExpression(op, _left, _right);
                    } else {
                        _right = new ArithmeticExpression(op, _left, _right);
                    }
                    _token = TokenType.ASSIGN;
                }
            }
        }

        // get right-hand value
        Object rvalue = _right.evaluate(context);

        // assgin into variable
        switch (_left.getToken()) {
          case TokenType.VARIABLE:
            String varname = ((VariableExpression)_left).getName();
            context.put(varname, rvalue);
            break;
          case TokenType.ARRAY:
            Expression expr = ((IndexExpression)_left).getLeft();
            Object obj = expr.evaluate(context);
            expr = ((IndexExpression)_left).getRight();
            Object idx = expr.evaluate(context);
            if (obj instanceof Map) {
                ((Map)obj).put(idx, rvalue);
            } else if (obj instanceof List) {
                if (! (idx instanceof Integer))
                    throw new EvaluationException("index of List object is not an integer.");
                ((List)obj).add(((Integer)idx).intValue(), rvalue);
            } else if (obj.getClass().isArray()) {
                if (! (idx instanceof Integer))
                    throw new EvaluationException("index of array is not an integer.");
                ((Object[])obj)[((Integer)idx).intValue()] = rvalue;
            } else {
                throw new EvaluationException("invalid '[]' operator for non-list,map,nor array.");
            }
            break;
          case TokenType.HASH:
            expr = ((IndexExpression)_left).getLeft();
            obj = expr.evaluate(context);
            expr = ((IndexExpression)_left).getRight();
            idx = expr.evaluate(context);
            if (obj instanceof Map) {
                ((Map)obj).put(idx, rvalue);
            } else {
                throw new EvaluationException("invalid '[:]' operator for non-map object.");
            }
            break;
          default:
            // error
            //throw new SemanticException("invalid assignment: left-value should be varaible, array or hash.");
            throw new EvaluationException("invalid assignment: left-value should be varaible, array or hash.");
        }
        return rvalue;
    }

    public Object accept(ExpressionVisitor visitor) {
        return visitor.visitAssignmentExpression(this);
    }
}
