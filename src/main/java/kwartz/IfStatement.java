/**
 *  @(#) IfStatement.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
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

    public Expression getCondition() { return _condition; }
    public Statement getThenStatement() { return _then_body; }
    public void setThenStatement(Statement stmt) { _then_body = stmt; }
    public Statement getElseStatement() { return _else_body; }
    public void setElseStatement(Statement stmt) { _else_body = stmt; }

    public Object execute(Map context, Writer writer) throws IOException {
        Object val = _condition.evaluate(context);
        if (val != null && !val.equals(Boolean.FALSE)) {
            _then_body.execute(context, writer);
        } else if (_else_body != null) {
            _else_body.execute(context, writer);
        }
        return null;
    }

    public Object accept(StatementVisitor visitor) {
        return visitor.visitIfStatement(this);
    }

    public Statement accept(Expander expander, Element elem) {
        return expander.expand(this, elem);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        super._inspect(level, sb);
        _condition._inspect(level+1, sb);
        _then_body._inspect(level+1, sb);
        if (_else_body != null)
            _else_body._inspect(level+1, sb);
        return sb;
    }
}
