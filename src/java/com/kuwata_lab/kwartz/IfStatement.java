/**
 *  @(#) IfStatement.java
 *  @Id  $Id$
 *  @copyright (C)2005 kuwata-lab.com all rights reserverd
 */

package com.kuwata_lab.kwartz;
import java.util.Map;
import java.io.Writer;
import java.io.IOException;

public class IfStatement extends Statement {
    private Expression _condition;
    private Statement  _then_body;
    private Statement  _else_body;

    public IfStatement(Expression condition, Statement then_body, Statement else_body) {
        super(TokenType.IF);
        _condition = condition;
        _then_body = then_body;
        _else_body = else_body;
    }

    public Object execute(Map context, Writer writer) throws IOException {
        Object val = _condition.evaluate(context);
        if (val != null && !val.equals(Boolean.FALSE)) {
            _then_body.execute(context, writer);
        } else if (_else_body != null) {
            _else_body.execute(context, writer);
        }
        return null;
    }

    public Object accept(Visitor visitor) {
        return visitor.visitIfStatement(this);
    }
}
