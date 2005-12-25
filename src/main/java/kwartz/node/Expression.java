/**
 *  @(#) Expression.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.node;

import kwartz.BaseException;

abstract public class Expression extends Node {
    public Expression(int token) {
        super(token);
    }

    public Object accept(NodeVisitor visitor) {
        return visitor.visitExpression(this);
    }
    public Object accept(ExpressionVisitor visitor) {
        if (1 == 1) throw new BaseException("*** debug ***");
        return visitor.visitExpression(this);
    }
}
