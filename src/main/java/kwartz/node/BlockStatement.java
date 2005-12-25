/**
 *  @(#) BlockStatement.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.node;
import java.util.List;
import java.util.Map;
import java.io.Writer;
import java.io.IOException;

import kwartz.Element;
import kwartz.Expander;
import kwartz.TokenType;

public class BlockStatement extends Statement {
    private Statement[] _statements;
    public BlockStatement(Statement[] statements) {
        super(TokenType.BLOCK);
        _statements = statements;
    }
    public BlockStatement(List statementList) {
        super(TokenType.BLOCK);
        _statements = new Statement[statementList.size()];
        statementList.toArray(_statements);
    }
    public Statement[] getStatements() { return _statements; }
    public void setStatements(Statement[] statements) { _statements = statements; }

    public Object execute(Map context, Writer writer) throws IOException {
        for (int i = 0; i < _statements.length; i++) {
            _statements[i].execute(context, writer);
        }
        return null;
    }

    public Object accept(StatementVisitor visitor) {
        return visitor.visitBlockStatement(this);
    }

    public Statement accept(Expander expander, Element elem) {
        return expander.expand(this, elem);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        for (int i = 0; i < level; i++) sb.append("  ");
        sb.append(":block\n");
        for (int i = 0; i < _statements.length; i++) {
            _statements[i]._inspect(level + 1, sb);
        }
        return sb;
    }
}
