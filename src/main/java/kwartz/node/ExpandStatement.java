/**
 *  @(#) ExpandStatement.java
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

public class ExpandStatement extends Statement {

    public static final int STAG    = 1;
    public static final int CONT    = 2;
    public static final int ETAG    = 3;
    public static final int ELEMENT = 4;
    public static final int CONTENT = 5;

    private int _type;
    private String _name;
    public ExpandStatement(int type, String name) {
        super(TokenType.EXPAND);
        _type = type;
        _name = name;
    }
    public ExpandStatement(int type) {
        this(type, null);
    }

    public String getName() { return _name; }
    public int getType() { return _type; }

    public Object execute(Map context, Writer writer) {
        return null;
    }
    public Object accept(StatementVisitor visitor) {
        return visitor.visitExpandStatement(this);
    }

    public Statement accept(Expander expander, Element elem) {
        return expander.expand(this, elem);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        for (int i = 0; i < level; i++) sb.append("  ");
        switch (_type) {
          case ExpandStatement.STAG:
            sb.append("@stag"); break;
          case ExpandStatement.ETAG:
            sb.append("@etag"); break;
          case ExpandStatement.CONT:
            sb.append("@cont"); break;
          case ExpandStatement.ELEMENT:
            sb.append("@element(" + _name + ")");  break;
          case ExpandStatement.CONTENT:
            sb.append("@content(" + _name + ")");  break;
          default:
            assert false;
        }
        sb.append("\n");
        return sb;
    }
}
