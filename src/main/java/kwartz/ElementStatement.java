/**
 *  @(#) ElementStatement.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

import java.util.Map;
import java.io.Writer;

public class ElementStatement extends Statement {
    private Statement _plogic;
    public ElementStatement(Statement plogic) {
        super(TokenType.ENTRY);
        _plogic = plogic;
    }
    public Object execute(Map context, Writer writer) {
        return null;
    }
    public Object accept(StatementVisitor visitor) {
        return visitor.visitElementStatement(this);
    }

    public Statement accept(Expander expander, Element elem) {
        return expander.expand(this, elem);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        super._inspect(level, sb);
        _plogic._inspect(level+1, sb);
        return sb;
    }
}
