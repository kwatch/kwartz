/**
 *  @(#) BinaryExpression.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
import java.util.Map;

public class BinaryExpression extends Expression {
    protected Expression _left;
    protected Expression _right;

    public BinaryExpression(int token, Expression left, Expression right) {
        super(token);
        _left = left;
        _right = right;
    }

    public Expression getLeft() { return _left; }
    public void setLeft(Expression expr) { _left = expr; }
    public Expression getRight() { return _right; }
    public void setRight(Expression expr) { _right = expr; }

    /*
    public Object evaluate(Map context, Visitor executer) {
        executer.executeBinaryExpression(context, left, right);
    }*/
    public Object accept(ExpressionVisitor visitor) {
        return visitor.visitBinaryExpression(this);
    }

    public Object evaluate(Map context) {
        return null;
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        super._inspect(level, sb);
        _left._inspect(level+1, sb);
        _right._inspect(level+1, sb);
        return sb;
    }
}
