/**
 *  @(#) EmptyStatement.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.node;
import java.util.Map;
import java.io.Writer;

import kwartz.Element;
import kwartz.Expander;
import kwartz.TokenType;

public class EmptyStatement extends Statement {
    public EmptyStatement() {
        super(TokenType.EMPTYSTMT);
    }

    public Object execute(Map context, Writer writer) {
        return null;
    }
    public Object accept(StatementVisitor visitor) {
        return visitor.visitEmptyStatement(this);
    }

    public Statement accept(Expander expander, Element elem) {
        return expander.expand(this, elem);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        return super._inspect(level, sb);
    }
}
