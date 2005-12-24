/**
 *  @(#) DefaultConverter.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Properties;

public class DefaultConverter implements Converter {

    private String _pdata;
    private String _filename;
    private Map _properties = new HashMap();
    private int    _remained_linenum;
    private String _remained_text;
    private List _elementList = new ArrayList();
    private Map _handlerTable = new HashMap();
    private DirectiveHandler _handler;
    private TagHelper _helper;
    private Properties _props;
    private Map _noendTags = null;


    public DefaultConverter() {
        this(new Properties(Configuration.defaults));
    }

    public DefaultConverter(Properties props) {
        _props = props;
        _helper = new TagHelper(_props);
        _handler = new DirectiveHandler(this, _props);
        _registerHandlers(_handlerTable);
        //
        _noendTags = new HashMap();
        String noend = _props.getProperty("kwartz.noend");
        if (noend != null) {
            String[] tagnames = noend.split(",");
            for (int i = 0; i < tagnames.length; i++) {
                String tagname = tagnames[i].trim();
                if (tagname.length() > 0)
                  _noendTags.put(tagname, Boolean.TRUE);
            }
        }
    }

    //public String getProperty(String key) { _props.getProperty(key); }
    //public void setProperty(String key, String value) { _props.setProperty(key, value); }


    private boolean _isNoend(String tagname) {
        return _noendTags.containsKey(tagname);
    }


    public List getElementList() { return _elementList; }
    public void addElement(Element element) {
        _elementList.add(element);
    }

    public String getFilename() { return _filename; }
    public void setFilename(String filename) { _filename = filename; _helper.setFilename(filename); }

    protected static final String TAG_PATTERN = "([ \t]*)<(/?)([-:_\\w]+)((?:\\s+[-:_\\w]+=\"[^\"]*?\")*)(\\s*)(/?)>([ \t]*\r?\n?)";

    public List fetchAll(String pdata) {
        final Pattern tagPattern = Pattern.compile(TAG_PATTERN);
        _pdata = pdata;
        int index = 0;
        int linenum = 1;
        char lastchar = '\0';
        Matcher m = tagPattern.matcher(pdata);
        List list = new ArrayList();
        Tag data;
        while (m.find()) {
            data = new Tag();
            data.tag_str      = m.group(0);
            data.before_space = m.group(1);
            data.is_etag      = "/".equals(m.group(2));
            data.tagname      = m.group(3);
            data.attr_str     = m.group(4);
            data.extra_space  = m.group(5);
            data.is_empty     = "/".equals(m.group(6));
            data.after_space  = m.group(7);
            data.start_pos    = m.start();
            data.end_pos      = m.end();
            data.before_text  = pdata.substring(index, m.start());
            list.add(data);
            index = m.end();

            // linenum
            String before_text = data.before_text;
            int len = before_text.length();
            for (int i = 0; i < len; i++) {
                if (before_text.charAt(i) == '\n') linenum += 1;
            }
            data.linenum  = linenum;
            String tag_str = data.tag_str;
            len = tag_str.length();
            for (int i = 0; i < len; i++) {
                if (tag_str.charAt(i) == '\n') linenum += 1;
            }

            // is_begline, is_endline
            if (before_text.length() > 0) {
                data.is_begline = before_text.charAt(before_text.length() - 1) == '\n';
            } else {
                data.is_begline = lastchar == '\n' || lastchar == '\0';
            }
            lastchar = tag_str.charAt(tag_str.length() - 1);
            data.is_endline = lastchar == '\n';
        }

        // remained text
        _remained_linenum = linenum;
        _remained_text    = pdata.substring(index);

        return list;
    }


    public static void main(String[] args) {
        try {
            java.io.Writer writer = new java.io.OutputStreamWriter(System.out);
            StringBuffer sb = new StringBuffer();
            for (int i = 0; i < args.length; i++) {
                java.io.InputStream input = new java.io.FileInputStream(args[i]);
                java.io.Reader reader = new java.io.InputStreamReader(input);
                int ch;
                while ((ch = reader.read()) > 0) {
                    sb.append((char)ch);
                }
            }
            DefaultConverter converter = new DefaultConverter();
            List list = converter.fetchAll(sb.toString());
            for (Iterator it = list.iterator(); it.hasNext(); ) {
                Tag data = (Tag)it.next();
                System.out.println(data._inspect());
            }
        } catch (java.io.UnsupportedEncodingException ex) {
            ex.printStackTrace();
        } catch (java.io.IOException ex) {
            ex.printStackTrace();
        }
    }


    public Statement[] convert(String pdata) {
        final Pattern newlinePattern = Pattern.compile("\\r?\\n");
        if (! _properties.containsKey("newline")) {
            Matcher m = newlinePattern.matcher(pdata);
            if (m.find())  _properties.put("newline", m.group(0));
        }
        List datalist = fetchAll(pdata);
        Iterator it = datalist.iterator();
        List stmtList = new ArrayList();
        _convert(it, stmtList, null);
        if (_remained_text != null && _remained_text.length() > 0)
            stmtList.add(_helper.createPrintStatement(_remained_text, _remained_linenum));
        //return new BlockStatement.new(stmts);
        Statement[] stmts = new Statement[stmtList.size()];
        stmtList.toArray(stmts);
        return stmts;
    }


    private Expression _parseExpression(String str, int linenum) {
        return _helper.parseExpression(str, linenum);
    }


    private void _handleDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        DirectiveHandlerIF handler = (DirectiveHandlerIF)_handlerTable.get(stag.directive_name);
        if (handler == null) {
            String msg = "'" + stag.directive_name + "': invalid directive name.";
            throw new ConvertionException(msg, _filename, stag.linenum);
        }
        handler.handle(stmtList, stag, etag, bodyStmtList);
    }


    private interface DirectiveHandlerIF {
        public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList);
    }

    private void _registerHandlers(Map handlerTable) {
        // mark
        handlerTable.put("mark", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleMarkDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        // value, Value, VALUE
        handlerTable.put("value", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleValueDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        handlerTable.put("Value", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleValueDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        handlerTable.put("VALUE", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleValueDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        // foreach, Foreach, FOREACH
        handlerTable.put("foreach", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleForeachDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        handlerTable.put("Foreach", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleForeachDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        handlerTable.put("FOREACH", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleForeachDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        // list, List, LIST
        handlerTable.put("list", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleListDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        handlerTable.put("List", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleListDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        handlerTable.put("LIST", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleListDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        // while, loop
        handlerTable.put("while", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleWhileDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        handlerTable.put("loop", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleLoopDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        // if, elseif, else
        handlerTable.put("if", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleIfDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        handlerTable.put("elseif", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleElseifDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        handlerTable.put("else", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleElseDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        // set
        handlerTable.put("set", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleSetDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        // dummy
        handlerTable.put("dummy", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleDummyDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        // replace, placeholder
        handlerTable.put("replace", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleReplaceDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        handlerTable.put("placeholder", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handlePlaceholderDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        // include, Include, INCLUDE
        handlerTable.put("include", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handlePlaceholderDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        handlerTable.put("Include", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handlePlaceholderDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        handlerTable.put("INCLUDE", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handlePlaceholderDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
    }


    private static final String ATTR_PATTERN = "(\\s*)([-:_\\w]+)=\"(.*?)\"";
    private static final String WORD_PATTERN = "\\A[-_\\w]+\\z";

    private void _parseAttributes(Tag tag) {
        final Pattern attrPattern = Pattern.compile(ATTR_PATTERN);
        Matcher m = attrPattern.matcher(tag.attr_str);
        Attr id_attr = null;
        Attr kd_attr = null;
        while (m.find()) {
            String aspace  = m.group(1);
            String aname   = m.group(2);
            String avalue  = m.group(3);
            if (tag.attrs == null) tag.attrs = new ArrayList();
            Attr attr = new Attr(aspace, aname, avalue);
            tag.attrs.add(attr);
            if (aname.equals("id")) id_attr = attr;
            else if (aname.equals("kw:d")) kd_attr = attr;
        }
        if (id_attr != null) {
            String id_value = (String)id_attr.value;
            _parseIdAttribute(id_value, tag);   // set tag.directive_name and tag.directive_arg
            final Pattern word_pat = Pattern.compile(WORD_PATTERN);
            if (! word_pat.matcher(id_value).find()) {
                tag.attrs.remove(id_attr);
            }
        }
        if (kd_attr != null) {
            String kd_value = (String)kd_attr.value;
            _parseKdAttribute(kd_value, tag);   // set tag.directive_name and tag.directive_arg
            tag.attrs.remove(kd_attr);
        }
    }

    private void _parseIdAttribute(String avalue, Tag tag) {
        final Pattern pat = Pattern.compile("\\A[-_\\w]+\\z");
        if (! pat.matcher(avalue).find()) {
            _parseKdAttribute(avalue, tag);
        } else if (avalue.indexOf('-') < 0) {  // is it need?
            tag.directive_name = "mark";
            tag.directive_arg  = avalue;
        }
    }

    private void _parseKdAttribute(String kdstr, Tag tag) {
        String directive_name = null;
        String directive_arg  = null;
        String[] directives = kdstr.split(";");
        final Pattern pat = Pattern.compile("\\A\\s*(\\w+):(.*)\\z");
        for (int i = 0; i < directives.length; i++) {
            Matcher m = pat.matcher(directives[i]);
            if (! m.find())
                throw new ConvertionException("'" + directives[i] + "': invalid directive.", _filename, tag.linenum);
            String dname = m.group(1);   // directive name
            String darg  = m.group(2);   // directive arg
            if (dname.equals("attr") || dname.equals("Attr") || dname.equals("ATTR")) {
                final Pattern p2 = Pattern.compile("\\A([-_\\w]+(?::[-_\\w]+)?)[:=](.*)\\z");
                Matcher m2 = p2.matcher(darg);
                if (! m2.find())
                    throw new ConvertionException("'" + directives[i] + "': invalid attr directive.", _filename, tag.linenum);
                String aname  = m2.group(1);
                String avalue = m2.group(2);
                String s;
                if      (dname.equals("attr"))   s = avalue;
                else if (dname.equals("Attr"))   s = "E(" + avalue + ")";
                else                             s = "X(" + avalue + ")";
                Expression expr = _helper.parseExpression(s, tag.linenum);
                Attr attr = null;
                if (tag.attrs == null) {
                    tag.attrs = new ArrayList();
                    attr = new Attr(" ", aname, expr);
                    tag.attrs.add(attr);
                } else {
                    for (int j = 0; j < tag.attrs.size(); j++) {
                        Attr attr2 = (Attr)tag.attrs.get(j);
                        if (aname.equals(attr2.name)) {
                            attr = attr2;
                            break;
                        }
                    }
                    if (attr == null) {
                        attr = new Attr(" ", aname, expr);
                        tag.attrs.add(attr);
                    } else {
                        attr.value = expr;
                    }
                }
            }
            else if (dname.equals("append") || dname.equals("Append") || dname.equals("APPEND")) {
                String s;
                if      (dname.equals("append")) s = darg;
                else if (dname.equals("Append")) s = "E(" + darg + ")";
                else                             s = "X(" + darg + ")";
                Expression expr = _helper.parseExpression(s, tag.linenum);
                if (tag.append_exprs == null) tag.append_exprs = new ArrayList();
                tag.append_exprs.add(expr);
            }
            else {
                if (! _handlerTable.containsKey(dname))
                    throw new ConvertionException("'" + dname + "': invalid directive name.", _filename, tag.linenum);
                if (directive_name != null) {
                    String msg = "directive '" + directive_name + "' and '" + dname + "': cannot specify two or more directives in an element.";
                    throw new ConvertionException(msg, _filename, tag.linenum);
                }
                directive_name = dname;
                directive_arg  = darg;
            }
        }
        tag.directive_name = directive_name;
        tag.directive_arg  = directive_arg;
    }


    public Expression[] expandEmbeddedExpression(String str, int linenum) {
        return _helper.expandEmbeddedExpression(str, linenum);
    }


    private Tag _convert(Iterator it, List stmtList, Tag startTag) {
        while (it.hasNext()) {
            Tag tag = (Tag)it.next();
            if (tag.before_text.length() > 0) {
                stmtList.add(_helper.createPrintStatement(tag.before_text, tag.linenum));
            }
            assert tag.tagname != null;
            if (tag.is_etag) {                                          // end-tag
                if (startTag != null && tag.tagname.equals(startTag.tagname)) {
                    return tag;   // return Tag of end-tag
                } else {
                    stmtList.add(_helper.createPrintStatement(tag.tag_str, tag.linenum));
                }
            }
            else if (tag.is_empty || _isNoend(tag.tagname)) {          // empty-tag
                _parseAttributes(tag);
                if (tag.directive_name == null) {
                    stmtList.add(_helper.buildPrintStatement(tag));
                } else {
                    List bodyStmtList = new ArrayList();
                    if (tag.directive_name.equals("mark")) {
                        // nothing
                    } else {
                        boolean tagDelete = tag.tagname.equals("span") && (tag.attrs == null || tag.attrs.size() == 0);
                        bodyStmtList.add(_helper.createTagPrintStatement(tag, tagDelete));
                    }
                    Tag stag = tag;
                    Tag etag = null;
                    _handleDirective(stmtList, stag, etag, bodyStmtList);
                }
            }
            else {                                                       // start-tag
                _parseAttributes(tag);
                boolean hasDirective = tag.directive_name != null;
                List bodyStmtList;
                if (hasDirective) {
                    bodyStmtList = new ArrayList();
                } else if (startTag != null && tag.tagname.equals(startTag.tagname)) {
                    bodyStmtList = stmtList;
                } else {
                    stmtList.add(_helper.buildPrintStatement(tag));
                    continue;
                }
                // handle stag
                Tag stag = tag;
                boolean tagSkip = hasDirective && tag.directive_name.equals("mark");
                boolean tagDelete = false;
                if (! tagSkip) {
                    tagDelete = stag.tagname.equals("span") && (stag.attrs == null || stag.attrs.size() == 0);
                    bodyStmtList.add(_helper.createTagPrintStatement(stag, tagDelete));
                }
                // handle content
                Tag etag = _convert(it, bodyStmtList, stag);
                // handle etag
                if (! tagSkip) {
                    bodyStmtList.add(_helper.createTagPrintStatement(etag, tagDelete));
                }
                // handle directive
                if (hasDirective) {
                    _handleDirective(stmtList, stag, etag, bodyStmtList);
                }
            }
        }  // end of while
        //
        if (startTag != null)
            throw new ConvertionException("'<" + startTag.tagname + ">' is not closed by end-tag.", _filename, startTag.linenum);
        return null;
    }

}
