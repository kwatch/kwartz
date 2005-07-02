/**
 *  @(#) ForeachStatement.java
 *  @Id  $Id$
 *  @copyright (C)2005 kuwata-lab.com all rights reserverd
 */
package com.kuwata_lab.kwartz;
import java.util.Map;
import java.util.List;
import java.io.Writer;
import java.io.IOException;

public class ForeachStatement extends Statement {
    private VariableExpression _loopvar;
    private Expression _list;
    private Statement _body;

    public ForeachStatement(VariableExpression loopvar, Expression list, Statement body) {
        super(TokenType.FOREACH);
        _loopvar = loopvar;
        _list    = list;
        _body    = body;
    }

    public Object execute(Map context, Writer writer) throws IOException {
        Object listval = _list.evaluate(context);
        Object[] array = null;
        if (listval instanceof List) {
            array = ((List)listval).toArray();
        } else if (listval.getClass().isArray()) {
            array = (Object[])listval;
        } else {
            //throw new SemanticException("List or Array required in foreach-statement.");
            throw new EvaluationException("List or Array required in foreach-statement.");
        }
        String loopvar_name = _loopvar.getName();
        for (int i = 0; i < array.length; i++) {
            context.put(loopvar_name, array[i]);
            _body.execute(context, writer);
        }
        return null;
    }

    public Object accept(Visitor visitor) {
        return visitor.visitForeachStatement(this);
    }
}
