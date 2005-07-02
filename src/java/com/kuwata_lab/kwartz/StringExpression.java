/**
 *  @(#) StringExpression.java
 *  @Id  $Id$
 *  @copyright (C)2005 kuwata-lab.com all rights reserverd
 */
package com.kuwata_lab.kwartz;
import java.util.Map;

public class StringExpression extends LiteralExpression {
    private String _value;
    public StringExpression(String value) {
        super(TokenType.STRING);
        _value = value;
    }
    public Object evaluate(Map context) {
        return _value;
    }
    public Object accept(Visitor visitor) {
        return visitor.visitStringExpression(this);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        for (int i = 0; i < level; i++) sb.append("  ");
        sb.append('"');
        for (int i = 0; i < _value.length(); i++) {
            char ch = _value.charAt(i);
            switch (ch) {
              case '\n':  sb.append("\\n"); break;
              case '\r':  sb.append("\\r"); break;
              case '\t':  sb.append("\\t"); break;
              case '\\':  sb.append("\\\\");  break;
              case '"':   sb.append("\\\"");  break;
              default:    sb.append(ch);
            }
        }
        sb.append('"');
        sb.append("\n");
        return sb;
    }
}
