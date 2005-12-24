/**
 *  @(#) Element.java
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

public class Element {
    private String _name;
    private Tag    _stag;
    private Tag    _etag;
    private List   _cont;           // list of Statement
    private PresentationDeclaration _decl;
    private BlockStatement _plogic;

    public Element(String name, Tag stag, Tag etag, List cont) {
        _name = name;
        _stag = stag;
        _etag = etag;
        _cont = cont;
    }

    public Tag getStag() { return _stag; }
    public Tag getEtag() { return _etag; }
    public List getCont() { return _cont; }
    public String getName() { return _name; }

    public static Map createElementTable(List elementList) {
        return addElementList(new HashMap(), elementList);
    }

    public static Map addElementList(Map elementTable, List elementList) {
        for (Iterator it = elementList.iterator(); it.hasNext(); ) {
            Element elem = (Element)it.next();
            elementTable.put(elem.getName(), elem);
        }
        return elementTable;
    }

    public static void mergeDeclarationList(Map elementTable, List declList) {
        // merge declarations
        if (elementTable == null) return;
        if (declList == null) return;
        for (Iterator it = declList.iterator(); it.hasNext(); ) {
            PresentationDeclaration decl = (PresentationDeclaration)it.next();
            for (int i = 0; i < decl.names.length; i++) {
                String name = decl.names[i];
                Element elem = (Element)elementTable.get(name);
                if (elem != null)  elem.setDeclaration(decl);
            }
        }
    }



    public PresentationDeclaration getDeclaration() {
        return _decl;
    }

    public void setDeclaration(PresentationDeclaration decl) {
        _decl = decl;
        if (decl.value != null) {
            Expression[] args = { decl.value };
            PrintStatement stmt = new PrintStatement(args);
            _cont = new ArrayList();
            _cont.add(stmt);
        }
        if (decl.tagname != null) {
            // TBI
            if (decl.tagname.getToken() == TokenType.STRING) {
                String tagname = ((StringExpression)decl.tagname).getValue();
                _stag.tagname = tagname;
                _etag.tagname = tagname;
            }
        }
        if (decl.remove != null) {
            if (_stag.attrs != null) {
                for (int i = _stag.attrs.size() - 1; i >= 0; i--) {
                    Attr attr = (Attr)_stag.attrs.get(i);
                    Object aname = attr.name;
                    if (decl.remove.contains(aname))
                       _stag.attrs.remove(i);
                }
            }
        }
        if (decl.attrs != null) {
            if (_stag.attrs == null) _stag.attrs = new ArrayList();
            for (Iterator it = decl.attrs.keySet().iterator(); it.hasNext(); ) {
                String aname = (String)it.next();
                Object expr  = decl.attrs.get(aname);
                int i;
                int len = _stag.attrs.size();
                for (i = 0; i < len; i++) {
                    Attr attr = (Attr)_stag.attrs.get(i);
                    if (aname.equals(attr.name)) {
                        attr.value = expr;
                        break;
                    }
                }
                if (i >= len) {
                    Attr attr = new Attr(" ", aname, expr);
                    _stag.attrs.add(attr);
                }
            }
            //for (int i = _stag.attrs.size() -1; i >= 0; i--) {
            //    Attr attr = (Attr)_stag.attrs.get(i);
            //    String aname = attr.name;
            //    Object expr = decl.attrs.get(aname);
            //    if (expr != null)  attr.value = expr;
            //}
        }
        if (decl.append != null) {
            if (_stag.append_exprs == null)
                _stag.append_exprs = decl.append;
            else
                _stag.append_exprs.addAll(decl.append);
        }
        if (decl.plogic != null) {
            _plogic = decl.plogic;
        }
    }

    public BlockStatement getPresentationLogic() {
        if (_plogic == null) {
            Statement[] stmts = {
                new ExpandStatement(ExpandStatement.STAG),
                new ExpandStatement(ExpandStatement.CONT),
                new ExpandStatement(ExpandStatement.ETAG),
            };
            _plogic = new BlockStatement(stmts);
        }
        return _plogic;
    }


    public Statement[] getContentStatements() {
        Statement[] stmts = new Statement[_cont.size()];
        _cont.toArray(stmts);
        return stmts;
    }


    public StringBuffer _inspect() {
        return _inspect(0, new StringBuffer());
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        for (int i = 0; i < level; i++) sb.append("  ");
        sb.append("Element(");
        sb.append(_name);
        sb.append(")\n");
        for (Iterator it = _cont.iterator(); it.hasNext(); ) {
            Statement stmt = (Statement)it.next();
            stmt._inspect(level + 1, sb);
        }
        return sb;
    }
}
