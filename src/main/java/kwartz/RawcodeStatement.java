/**
 *  @(#) RawcodeStatement.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
import java.util.Map;
import java.io.Writer;

public class RawcodeStatement extends Statement {
    private String _rawcode;
    public RawcodeStatement(String rawcode) {
        super(TokenType.RAWSTMT);
        _rawcode = rawcode;
    }

    public String getRawcode() { return _rawcode; }
    public void setRawcode(String rawcode) { _rawcode = rawcode; }

    public Object execute(Map context, Writer writer) {
        throw new EvaluationException("cannot evaluate rawcode statement.");
        //return null;
    }
    public Object accept(StatementVisitor visitor) {
        return visitor.visitRawcodeStatement(this);
    }

    public Statement accept(Expander expander, Element elem) {
        return expander.expand(this, elem);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        for (int i = 0; i < level; i++) sb.append("  ");
        sb.append("<" + "%=" + _rawcode + "%" + ">");
        return sb;
    }
}
