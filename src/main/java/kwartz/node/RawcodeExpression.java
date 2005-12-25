/**
 *  @(#) RawcodeExpression.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.node;
import java.util.Map;

import kwartz.EvaluationException;
import kwartz.TokenType;

public class RawcodeExpression extends LiteralExpression {
    String _rawcode;
    public RawcodeExpression(String rawcode) {
        super(TokenType.RAWEXPR);
        _rawcode = rawcode;
    }
    public String getRawcode() { return _rawcode; }
    public void setRawcode(String rawcode) { _rawcode = rawcode; }

    public Object evaluate(Map context) {
        throw new EvaluationException("cannot evaluate rawcode expression");
        //return null;
    }
    public Object accept(ExpressionVisitor visitor) {
        return visitor.visitRawcodeExpression(this);
    }
    public StringBuffer _inspect(int level, StringBuffer sb) {
        for (int i = 0; i < level; i++) sb.append("  ");
        sb.append("<" + "%=" + _rawcode + "%" + ">");
        return sb;
    }
}
