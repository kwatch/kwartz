/**
 *  @(#) ExpressionStatement.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
import java.util.Map;
import java.io.Writer;

public class ExpressionStatement extends Statement {
    private Expression _expr;
    public ExpressionStatement(Expression expr) {
        super(TokenType.EXPR);
        _expr = expr;
    }

    public Object execute(Map context, Writer writer) {
        _expr.evaluate(context);
        return null;
    }

    public Object accept(StatementVisitor visitor) {
        return visitor.visitExpressionStatement(this);
    }

    public Statement accept(Expander expander, Element elem) {
        return expander.expand(this, elem);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        super._inspect(level, sb);
        _expr._inspect(level+1, sb);
        return sb;
    }
}
