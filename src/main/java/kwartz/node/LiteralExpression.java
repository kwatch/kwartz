/**
 *  @(#) LiteralExpression.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.node;

abstract public class LiteralExpression extends Expression {
    public LiteralExpression(int token) {
        super(token);
    }
    public Object accept(ExpressionVisitor visitor) {
        return visitor.visitLiteralExpression(this);
    }
}
