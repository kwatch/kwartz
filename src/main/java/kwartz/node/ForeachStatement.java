/**
 *  @(#) ForeachStatement.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.node;
import java.util.Map;
import java.util.List;
import java.io.Writer;
import java.io.IOException;

import kwartz.Element;
import kwartz.EvaluationException;
import kwartz.Expander;
import kwartz.TokenType;

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

    public Statement getBodyStatement() { return _body; }
    public void setBodyStatement(Statement stmt) { _body = stmt; }

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

    public Object accept(StatementVisitor visitor) {
        return visitor.visitForeachStatement(this);
    }

    public Statement accept(Expander expander, Element elem) {
        return expander.expand(this, elem);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        super._inspect(level, sb);
        _loopvar._inspect(level+1, sb);
        _list._inspect(level+1, sb);
        _body._inspect(level+1, sb);
        return sb;
    }
}
