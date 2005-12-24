/**
 *  @(#) PresentationDeclaration.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.Iterator;

public class PresentationDeclaration {
    public String[]       names;
    public Expression     tagname;
    public List           remove;
    public Map            attrs;
    public List           append;
    public Expression     value;
    public BlockStatement plogic;

    public PresentationDeclaration() {
        this(null);
    }

    public PresentationDeclaration(String[] names) {
        this.names = names;
        remove = new ArrayList();
        attrs  = new HashMap();
        append = new ArrayList();
        //Statement[] stmts = {
        //    new ExpandStatement(ExpandStatement.STAG),
        //    new ExpandStatement(ExpandStatement.CONT),
        //    new ExpandStatement(ExpandStatement.ETAG),
        //};
        //plogic = new BlockStatement(stmts);
    }

    public StringBuffer _inspect() {
        return _inspect(0, new StringBuffer());
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        if (names != null) {
            for (int i = 0; i < names.length; i++) {
                if (i > 0) sb.append(", ");
                sb.append("#" + names[i]);
            }
            sb.append(" ");
        }
        sb.append("{\n");
        if (tagname != null) {
            sb.append("  tagname:\n");
            tagname._inspect(2, sb);
        }
        if (remove != null && remove.size() > 0) {
            sb.append("  remove:\n");
            for (int i = 0; i < remove.size(); i++) {
                String aname = (String)remove.get(i);
                sb.append("    " + Utility.inspectString(aname) + "\n");
            }
        }
        if (attrs != null && attrs.size() > 0) {
            sb.append("  attrs:\n");
            for (Iterator it = attrs.keySet().iterator(); it.hasNext(); ) {
                String aname = (String)it.next();
                Expression expr = (Expression)attrs.get(aname);
                sb.append("    " + Utility.inspectString(aname) + "\n");
                expr._inspect(2, sb);
            }
        }
        if (append != null && append.size() > 0) {
            sb.append("  append:\n");
            for (int i = 0; i < append.size(); i++) {
                Expression expr = (Expression)append.get(i);
                expr._inspect(2, sb);
            }
        }
        if (value != null) {
            sb.append("  value:\n");
            value._inspect(2, sb);
        }
        if (plogic != null) {
            sb.append("  plogic:\n");
            plogic._inspect(2, sb);
        }
        sb.append("}\n");
        return sb;
    }
}
