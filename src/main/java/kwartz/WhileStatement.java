/**
 *  @(#) WhileStatement.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
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

    public Statement getBodyStatement() { return _body; }
    public void setBodyStatement(Statement stmt) { _body = stmt; }

    public Object execute(Map context, Writer writer) throws IOException {
        int i = 0;
        while (BooleanExpression.isTrue(_condition.evaluate(context))) {
            if (++i > MaxCount)
                throw new ExecutionException("while-loop may be infinte.");
            _body.execute(context, writer);
        }
        return null;
    }

    public Object accept(StatementVisitor visitor) {
        return visitor.visitWhileStatement(this);
    }

    public Statement accept(Expander expander, Element elem) {
        return expander.expand(this, elem);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        super._inspect(level, sb);
        _condition._inspect(level+1, sb);
        _body._inspect(level+1, sb);
        return sb;
    }
}
