/**
 *  @(#) WhileStatement.java
 *  @Id  $Id$
 *  @copyright (C)2005 kuwata-lab.com all rights reserverd
 */

package com.kuwata_lab.kwartz;
import java.util.Map;
import java.io.Writer;
import java.io.IOException;

public class WhileStatement extends Statement {
    private Expression _condition;
    private Statement _body;
    public static int MaxCount = 10000;
    
    public WhileStatement(Expression condition, Statement body) {
        super(TokenType.WHILE);
        _condition = condition;
        _body = body;
    }
    
    public Object execute(Map context, Writer writer) throws IOException {
        int i = 0;
        while (BooleanExpression.isTrue(_condition.evaluate(context))) {
            if (++i > MaxCount)
                throw new ExecutionException("while-loop may be infinte.");
            _body.execute(context, writer);
        }
        return null;
    }
    
    public Object accept(Visitor visitor) {
        return visitor.visitWhileStatement(this);
    }
}
