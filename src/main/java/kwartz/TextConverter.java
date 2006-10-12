/*
 * $Rev$
 * $Release$
 * $Copyright$
 */
package kwartz;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.Iterator;
import java.util.regex.Pattern;
import java.util.regex.Matcher;


class TagInfo {
	String  _prev_text, _tag_text;
	String  _head_space, _tail_space, _extra_space;
	boolean _is_etag, _is_empty;
	String  _tagname, _attr_str;
	int     _linenum, _linenum_delta;
	String  _dattr_name, _directive_str;
	
//	TagInfo(Matcher m, int linenum) {
//		_prev_text   = m.group(1);
//		_tag_text    = m.group(2);
//		_head_space  = m.group(3);
//		_is_etag     = "/".equals(m.group(4));
//		_tagname     = m.group(5);
//		_attr_str    = m.group(6);
//		_extra_space = m.group(7);
//		_is_empty    = "/".equals(m.group(8));
//		_tail_space  = m.group(9);
//		_linenum     = linenum;
//	}
	
	TagInfo(String prev_text, String tag_text, String head_space, boolean is_etag, String tagname,
			String attr_str, String extra_space, boolean is_empty, String tail_space, int linenum) {
		_prev_text   = prev_text;
		_tag_text    = tag_text;
		_head_space  = head_space;
		_is_etag     = is_etag;
		_tagname     = tagname;
		_attr_str    = attr_str;
		_extra_space = extra_space;
		_is_empty    = is_empty;
		_tail_space  = tail_space;
		_linenum     = linenum;
	}

	String getPrevText() { return _prev_text; }
	String getTagText()  { return _tag_text; }
	String getHeadSpace() { return _head_space; }
	String getTailSpace() { return _tail_space; }
	String getExtraSpace() { return _extra_space; }
	boolean isEtag() { return _is_etag; }
	boolean isEmpty() { return _is_empty; }
	String getTagName() { return _tagname; }
	String getAttrStr() { return _attr_str; }
	int    getLinenum() { return _linenum; }
	
	String getDirectiveAttrName() { return _dattr_name; }    // "kw:d" or "id"
	String getDirectiveStr() { return _directive_str; }
	void   setDirective(String dattr_name, String d_str) {
		_dattr_name = dattr_name;
		_directive_str = d_str;
	}
	
	void setTagName(String tagname) { _tagname = tagname; }
	//void setHeadSpace(String space) { _head_space = space; }
	//void setTailSpace(String space) { _tail_space = space; }
	void deleteHeadSpace() { _head_space = ""; rebuildTagText(null); }
	void deleteTailSpace() { _tail_space = ""; rebuildTagText(null); }
	
	void rebuildTagText(AttrInfo attr_info) {
		if (attr_info != null) {
			StringBuffer sb = new StringBuffer();
			List names = attr_info.getNames();
			AttrInfo a = attr_info;
			for (Iterator it = names.iterator(); it.hasNext(); ) {
				String name = (String)it.next();
				sb.append(a.getSpace(name)).append(name).append("=\"").append(a.getValue(name)).append('"');
			}
			_attr_str = sb.toString();
		}
		StringBuffer sb = new StringBuffer();
		if (_head_space != null) sb.append(_head_space);
		sb.append('<');
		if (_is_etag) sb.append('/');
		sb.append(_tagname);
		if (_attr_str != null) sb.append(_attr_str);
		if (_extra_space != null) sb.append(_extra_space);
		if (_is_empty) sb.append('/');
		sb.append('>');
		if (_tail_space != null) sb.append(_tail_space);
		_tag_text = sb.toString();
	}
	
	void _inspect(int level, StringBuffer sb) {
		String indent = Util.repeatString("  ", level);
		sb.append(indent).append("linenum    : ").append(Integer.toString(_linenum)).append("\n");
		sb.append(indent).append("prev_text  : ").append(Util.inspect(_prev_text)).append("\n");
		sb.append(indent).append("tag_text   : ").append(Util.inspect(_tag_text)).append("\n");
		sb.append(indent).append("head_space : ").append(Util.inspect(_head_space)).append("\n");
		sb.append(indent).append("is_etag    : ").append(Boolean.toString(_is_etag)).append("\n");
		sb.append(indent).append("tagname    : ").append(Util.inspect(_tagname)).append("\n");
		sb.append(indent).append("attr_str   : ").append(Util.inspect(_attr_str)).append("\n");
		sb.append(indent).append("extra_space: ").append(Util.inspect(_extra_space)).append("\n");
		sb.append(indent).append("is_empty   : ").append(Boolean.toString(_is_empty)).append("\n");
		sb.append(indent).append("tail_space : ").append(Util.inspect(_tail_space)).append("\n");
	}
	
	String _inspect(int level) {
		StringBuffer sb = new StringBuffer();
		_inspect(level, sb);
		return sb.toString();
	}
	
	String _inspect() {
		return _inspect(0);
	}

}



class AttrInfo {
	List _names = new ArrayList();
	Map _values = new HashMap();
	Map _spaces = new HashMap();
	
	static Pattern __pat = Pattern.compile("(\\s+)([-:_\\w]+)=\"([^\"]*?)\"");
	
	AttrInfo(String attr_str) {
		Matcher m = __pat.matcher(attr_str);
		while (m.find()) {
			String name = m.group(2);
			_names.add(name);
			_values.put(name, m.group(3));
			_spaces.put(name, m.group(1));
		}
	}
	
	void set(String name, Object value, String space) {
		if (! _names.contains(name))
			_names.add(name);
		_values.put(name, value);  // String or Ast.Expression
		if (space != null)
			_spaces.put(name, space);
		else if (! _spaces.containsKey(name))
			_spaces.put(name, " ");
	}
	
	void remove(String name) {
		_names.remove(name);
		_values.remove(name);
		_spaces.remove(name);
	}
	
	void merge(Map attrs) {
		if (attrs == null)
			return;
		for (Iterator it = attrs.keySet().iterator(); it.hasNext(); ) {
			String name = (String)it.next();
			Object value = attrs.get(name);
			set(name, value, null);
		}
	}
	
	List getNames() {
		return _names;
	}
	
	Object getValue(String name) {
		return _values.get(name);
	}
	
	String getSpace(String name) {
		return (String)_spaces.get(name);
	}
	
	boolean isEmpty() {
		return _names.size() == 0;
	}

}



class ElementInfo {
	
	String   _name;
	TagInfo  _stag_info, _etag_info;
	List     _cont_stmts;              // List<Ast.Statement>
	AttrInfo _attr_info;
	List     _append_exprs;            // List<Ast.Expression>
	List     _logic, _before, _after;  // List<Ast.Statement>
	String   _directive_text;
	boolean  _is_merged = false;
	//
	Ast.Expression _stag_expr, _etag_expr, _cont_expr, _elem_expr;
	
	ElementInfo(TagInfo stag_info, TagInfo etag_info, List cont_stmts, AttrInfo attr_info, List append_exprs) {
		this(null, stag_info, etag_info, cont_stmts, attr_info, append_exprs);
	}

	ElementInfo(TagInfo stag_info, TagInfo etag_info, List cont_stmts, AttrInfo attr_info) {
		this(null, stag_info, etag_info, cont_stmts, attr_info, new ArrayList());
	}
	
	ElementInfo(String name, TagInfo stag_info, TagInfo etag_info, List cont_stmts, AttrInfo attr_info, List append_exprs) {
		_name = name;
		_stag_info  = stag_info;
		_etag_info  = etag_info;
		_cont_stmts = cont_stmts;
		_attr_info  = attr_info;
		_append_exprs = append_exprs;
		_logic = new ArrayList();
		//_logic.add(new Ast.ElementStatement(name));
		_logic.add(new Ast.StagStatement());
		_logic.add(new Ast.ContStatement());
		_logic.add(new Ast.EtagStatement());
	}
	
	String   getName() { return _name; }
	TagInfo  getStagInfo() { return _stag_info; }
	TagInfo  getEtagInfo() { return _etag_info; }
	List     getContStmts() { return _cont_stmts; }
	AttrInfo getAttrInfo() { return _attr_info; }
	List     getAppendExprs() { return _append_exprs; }
	//
	List     getLogic() { return _logic; }
	List     getBefore() { return _before; }
	List     getAfter() { return _after; }
	void     setLogic(List stmt_list) { _logic = stmt_list; } 
	void     setBefore(List stmt_list) { _before= stmt_list; } 
	void     setAfter(List stmt_list) { _after = stmt_list; }
	void     setLogic(Ast.Statement stmt) { (_logic = new ArrayList()).add(stmt); }
	void     setBefore(Ast.Statement stmt) { (_before = new ArrayList()).add(stmt); }
	void     setAfter(Ast.Statement stmt) { (_after = new ArrayList()).add(stmt); }
	//
	boolean  isMerged() { return _is_merged; }
	void     setMerged(boolean flag) { _is_merged = flag; }
	String   getDirectiveText() { return _directive_text; }
	void     setDirectiveText(String s) { _directive_text = s; }
	//
	Ast.Expression getStagExpr() { return _stag_expr; }
	Ast.Expression getContExpr() { return _cont_expr; }
	Ast.Expression getEtagExpr() { return _etag_expr; }
	Ast.Expression getElemExpr() { return _elem_expr; }
	void setStagExpr(Ast.Expression expr) { _stag_expr = expr; }
	void setContExpr(Ast.Expression expr) { _cont_expr = expr; }
	void setEtagExpr(Ast.Expression expr) { _etag_expr = expr; }
	void setElemExpr(Ast.Expression expr) { _elem_expr = expr; }

	ElementInfo duplicate() {
		ElementInfo elem_info = new ElementInfo(_name, _stag_info, _etag_info, _cont_stmts, _attr_info, _append_exprs);
		elem_info.setLogic(_logic);
		elem_info.setBefore(_before);
		elem_info.setAfter(_after);
		elem_info.setStagExpr(_stag_expr);
		elem_info.setContExpr(_cont_expr);
		elem_info.setEtagExpr(_etag_expr);
		elem_info.setElemExpr(_elem_expr);
		return elem_info;
	}
	
	static ElementInfo create(Map values) {
		Map v = values;
		return new ElementInfo((String)v.get("name"), (TagInfo)v.get("stag"), (TagInfo)v.get("etag"),
				               (List)v.get("cont"), (AttrInfo)v.get("attr"), (List)v.get("append"));
	}
	
	boolean isDummySpanTag(String tagname) {
		return tagname.equals(getStagInfo().getTagName()) && _directive_text != null
		       && getAttrInfo().isEmpty() && getAppendExprs().isEmpty();
	}

	void merge(Ast.Ruleset ruleset) {
		//if (! ruleset.match("#"+_name)) return;
		Ast.Expression expr;
		if ((expr = ruleset.getStag()) != null)  _stag_expr = expr;
		if ((expr = ruleset.getCont()) != null)  _cont_expr = expr;
		if ((expr = ruleset.getEtag()) != null)  _etag_expr = expr;
		if ((expr = ruleset.getElem()) != null)  _elem_expr = expr;
		Map attrs;
		if ((attrs = ruleset.getAttrs()) != null) _attr_info.merge(attrs);
		List exprs, names, stmts;
		if ((exprs= ruleset.getAppend()) != null) _append_exprs = exprs;
		if ((names = ruleset.getRemove()) != null)
			for (Iterator it = names.iterator(); it.hasNext(); )
				_attr_info.remove((String)it.next());
		if ((stmts = ruleset.getLogic())  != null) _logic = stmts;
		if ((stmts = ruleset.getBefore()) != null) _before = stmts;
		if ((stmts = ruleset.getAfter())  != null) _after = stmts;
		//String name;
		//if ((name = ruleset.getTagame() != null) _tagname = name;
	}	


	static final List EMPTY_LOGIC = new ArrayList(); 

	
	String inspect() {
		return inspect(0);
	}
	
	String inspect(int level) {
		StringBuffer sb = new StringBuffer();
		_inspect(level, sb);
		return sb.toString();
	}
	
	void _inspect(int level, StringBuffer sb) {
		String indent = Util.repeatString("  ", level);
		if (_stag_expr != null) {
			sb.append(indent).append("stag_expr:\n");
			_stag_expr._inspect(level+1, sb);
		}
		if (_cont_expr != null) {
			sb.append(indent).append("cont_expr:\n");
			_cont_expr._inspect(level+1, sb);
		}
		if (_etag_expr != null) {
			sb.append(indent).append("etag_expr:\n");
			_etag_expr._inspect(level+1, sb);
		}
		if (_elem_expr != null) {
			sb.append(indent).append("elem_expr:\n");
			_elem_expr._inspect(level+1, sb);
		}
		if (_stag_info != null) {
			sb.append(indent).append("stag_info:\n");
			_stag_info._inspect(level+1, sb);
		}
		if (_etag_info != null) {
			sb.append(indent).append("etag_info:\n");
			_etag_info._inspect(level+1, sb);
		}
		if (_cont_stmts != null) {
			sb.append(indent).append("cont_stmts:\n");
			for (Iterator it = _cont_stmts.iterator(); it.hasNext(); ) {
				Ast.Statement stmt = (Ast.Statement)it.next();
				stmt._inspect(level+1, sb);
			}
		}
		if (_attr_info != null && !_attr_info.isEmpty()) {
			sb.append(indent).append("attr_info:\n");
			//_attr_info._inspect(level+1, sb);
			List names = _attr_info.getNames();
			for (Iterator it = names.iterator(); it.hasNext(); ) {
				String name = (String) it.next();
				Object value = _attr_info.getValue(name);
				String space = _attr_info.getSpace(name);
				sb.append(indent).append("  - name: ").append(name).append("\n");
				sb.append(indent).append("    space: ").append(Util.inspect(space)).append("\n");
				sb.append(indent).append("    value:");
				if (value instanceof Ast.Expression)
					((Ast.Expression)value)._inspect(level+3, sb.append('\n'));
				else if (value instanceof String)
					sb.append(' ').append(Util.inspect(value));
				else
					assert false;
				sb.append('\n');
			}
		}
		if (_append_exprs != null && !_append_exprs.isEmpty()) {
			sb.append(indent).append("append_exprs:\n");
			for (Iterator it = _append_exprs.iterator(); it.hasNext();) {
				Ast.Expression expr = (Ast.Expression) it.next();
				expr._inspect(level+1, sb);
			}
		}
		if (_logic != null) {
			sb.append(indent).append("logic:\n");
			for (Iterator it = _logic.iterator(); it.hasNext(); ) {
				((Ast.Statement)it.next())._inspect(level+1, sb);
			}
		}
		if (_before != null) {
			sb.append(indent).append("before:\n");
			for (Iterator it = _before.iterator(); it.hasNext(); ) {
				((Ast.Statement)it.next())._inspect(level+1, sb);
			}
		}
		if (_after!= null) {
			sb.append(indent).append("after:\n");
			for (Iterator it = _after.iterator(); it.hasNext(); ) {
				((Ast.Statement)it.next())._inspect(level+1, sb);
			}
		}
	}
}



public class TextConverter implements Converter {

	private String _pdata;
	private String _rest;
	private Matcher _matcher;
	private int _linenum, _linenum_delta;
	private int _index;
	private HashMap _no_etag_table;

	private Handler _handler;

	private static HashMap __default_no_etag_table = new HashMap();
	static {
		String[] arr = "input img br hr meta link".split(" ");
		__default_no_etag_table = (HashMap)Util.convertArrayToMap(arr);
	}

	
	public TextConverter(Handler handler, Map properties) {
		_handler = handler;
		if (properties != null) {
			Object val;
			if ((val = properties.get("no-etags")) != null) {
				String[] arr = val.toString().split("[ ,]");
				_no_etag_table = (HashMap)Util.convertArrayToMap(arr);
			}
		}
		if (_no_etag_table == null) {
			_no_etag_table = __default_no_etag_table;
		}
	}
	
	public TextConverter(Handler handler) {
		this(handler, null);
	}
	
	void _reset(String pdata, int linenum) {
		_pdata = pdata;
		_linenum = linenum;
		_linenum_delta = 0;
		_index = 0;
		_rest = null;
		_matcher = __fetch_pattern.matcher(pdata);
	}
	
	public List convert(String pdata) throws ConvertException {
		return convert(pdata, 1);
	}
	
	public List convert(String pdata, int linenum) throws ConvertException {
		_reset(pdata, linenum);
		List stmt_list = new ArrayList();
		List stmts;
		Ast.Ruleset docruleset = _handler.getRuleset("#DOCUMENT");
		if (docruleset != null) {
			stmts = docruleset.getBefore();
			if (stmts != null) stmt_list.addAll(stmts);
		}
		_convert(stmt_list, null);
		if (docruleset != null) {
			stmts = docruleset.getAfter();
			if (stmts != null) stmt_list.addAll(stmts);
		}
		return stmt_list;
	}
	
	
	private static Pattern __fetch_pattern;
	static {
		String s = "(^[ \t]*)?<(/?)([-:_\\w]+)((?:\\s+[-:_\\w]+=\"[^\"]*?\")*)(\\s*)(/?)>([ \t]*\r?\n)?";
		__fetch_pattern = Pattern.compile(s, Pattern.MULTILINE);
	}


	TagInfo _fetch() {
		if (_matcher.find()) {
			int start = _matcher.start();
			String prev_text   = _pdata.substring(_index, start);
			String tag_str     = _matcher.group(0);
			String head_space  = _matcher.group(1);
			boolean is_etag    = "/".equals(_matcher.group(2));
			String tagname     = _matcher.group(3);
			String attr_str    = _matcher.group(4);
			String extra_space = _matcher.group(5);
			boolean is_empty   = "/".equals(_matcher.group(6));
			String tail_space  = _matcher.group(7);
			_index = start + tag_str.length();
			_linenum += _linenum_delta + Util.count(prev_text, '\n');
			_linenum_delta =  Util.count(tag_str, '\n'); 
			return new TagInfo(prev_text, tag_str, head_space, is_etag, tagname,
					           attr_str, extra_space, is_empty, tail_space, _linenum);
		}
		else {
			_rest = _pdata.substring(_index);
			return null;
		}
	}
	
	String getRest() {
		return _rest;
	}
	
	private TagInfo _convert(List stmt_list, TagInfo start_tag_info) throws ConvertException {
		String start_tagname = start_tag_info != null ? start_tag_info.getTagName() : null;
		TagInfo taginfo;
		StringBuffer textbuf = new StringBuffer();
		while ((taginfo = _fetch()) != null) {
			/// prev text
			String prev_text = taginfo.getPrevText();
			//if (prev_text != null && prev_text.length() > 0)
			//	stmt_list.add(_createPrintStatement(prev_text));
			if (prev_text != null)
				textbuf.append(prev_text);
			/// end-tag, empty-tag, or start-tag
			if (taginfo.isEtag()) {                                     // end-tag
				if (taginfo.getTagName().equals(start_tagname)) {
					_AddTextbufAsPrintStatement(stmt_list, textbuf);
					return taginfo;  // end-tag info
				}
				else {
					//stmt_list.add(_createPrintStatement(taginfo.getTagText()));
					textbuf.append(taginfo.getTagText());
				}
			}
			else if (taginfo.isEmpty() || _shouldSkipEtag(taginfo)) {   // empty-tag
				AttrInfo attr_info = new AttrInfo(taginfo.getAttrStr());
				if (hasDirective(attr_info, taginfo)) {
					TagInfo stag_info = taginfo;
					TagInfo etag_info = null;
					List cont_stmts = new ArrayList();   // List<Ast.Statement>
					_AddTextbufAsPrintStatement(stmt_list, textbuf);
					handleDirectives(stag_info, etag_info, cont_stmts, attr_info, stmt_list);
				}
				else {
					//stmt_list.add(_createPrintStatement(taginfo.getTagText()));
					textbuf.append(taginfo.getTagText());
				}
			}
			else {                                                      // start-tag
				AttrInfo attr_info = new AttrInfo(taginfo.getAttrStr());
				TagInfo stag_info, etag_info;
				if (hasDirective(attr_info, taginfo)) {
					stag_info = taginfo;
					List cont_stmts = new ArrayList();
					etag_info = _convert(cont_stmts, stag_info);
					_AddTextbufAsPrintStatement(stmt_list, textbuf);
					handleDirectives(stag_info, etag_info, cont_stmts, attr_info, stmt_list);
				}
				else if (matchesRuleset(taginfo, attr_info)) {
					stag_info = taginfo;
					List cont_stmts = new ArrayList();
					etag_info = _convert(cont_stmts, stag_info);
					_AddTextbufAsPrintStatement(stmt_list, textbuf);
					applyRuleset(stag_info, etag_info, cont_stmts, attr_info, stmt_list);
				}
				else if (taginfo.getTagName().equals(start_tagname)) {
					stag_info = taginfo;
					//stmt_list.add(_createPrintStatement(stag_info.getTagText()));
					textbuf.append(stag_info.getTagText());
					_AddTextbufAsPrintStatement(stmt_list, textbuf);
					etag_info = _convert(stmt_list, stag_info);
					//stmt_list.add(_createPrintStatement(etag_info.getTagText()));
					textbuf.append(etag_info.getTagText());
				}
				else {
					//stmt_list.add(_createPrintStatement(taginfo.getTagText()));
					textbuf.append(taginfo.getTagText());
				}
			}//if
		}//while
		// fetch end
		if (start_tag_info != null)
			throw _convertError("'<"+start_tagname+">' is not closed.", start_tag_info.getLinenum());
		//if (_rest != null && _rest.length() > 0)
		//	stmt_list.add(_createPrintStatement(_rest));
		if (_rest != null)
			textbuf.append(_rest);
		_AddTextbufAsPrintStatement(stmt_list, textbuf);
		return null;
	}
	
	private void _AddTextbufAsPrintStatement(List stmt_list, StringBuffer textbuf) {
		if (textbuf.length() > 0) {
			stmt_list.add(_createPrintStatement(textbuf.toString()));
			textbuf.setLength(0);
		}
	}
		
	private boolean _shouldSkipEtag(TagInfo tag_info) {
		return _no_etag_table.containsKey(tag_info.getTagName());
	}
	
	
	protected void handleDirectives(TagInfo stag_info, TagInfo etag_info, List cont_stmts, AttrInfo attr_info, List stmt_list) throws ConvertException {
		ElementInfo elem_info = new ElementInfo(stag_info, etag_info, cont_stmts, attr_info);
		_handler.handleDirectives(elem_info, stmt_list);
	}
	

	protected boolean hasDirective(AttrInfo attr_info, TagInfo taginfo) throws ConvertException {
		return _handler.hasDirective(attr_info, taginfo);
	}

	
	protected boolean matchesRuleset(TagInfo tag_info, AttrInfo attr_info) {
		String idname = (String)attr_info.getValue("id");
		if (idname != null && _handler.getRuleset("#"+idname) != null)
			return true;
		String classname = (String)attr_info.getValue("class");
		if (classname != null && _handler.getRuleset("."+classname) != null)
			return true;
		String tagname = tag_info.getTagName();
		if (_handler.getRuleset(tagname) != null) 
			return true;
		return false;
	}


	protected void applyRuleset(TagInfo stag_info, TagInfo etag_info, List cont_stmts, AttrInfo attr_info, List stmt_list) throws ConvertException {
		ElementInfo elem_info = new ElementInfo(stag_info, etag_info, cont_stmts, attr_info);
		_handler.applyRuleset(elem_info, stmt_list);
	}

	
	private static Ast.PrintStatement _createPrintStatement(String text) {
		Ast.Expression expr = new Ast.StringLiteral(text);
		return new Ast.PrintStatement(new Ast.Expression[] { expr });
	}
	
	
	private static ConvertException _convertError(String message, int linenum) {
		return new ConvertException(message, null, linenum);
	}

	
	public static void main(String[] args) throws Exception {
		String plogic = ""
			+ "#list {\n"
			//+ "  attrs: 'bgcolor' color;\n"
			+ "  logic: {\n"
			//+ "    ctr = 0;\n"
			+ "    foreach (item = list) {\n"
			+ "      ctr += 1;\n"
			+ "      color = ctr % 2 == 0 ? '#FCC' : '#CCF';\n"
			+ "      _stag;\n"
			+ "      _cont;\n"
			+ "      _etag;\n"
			+ "    }\n"
			+ "  }\n"
			+ "}\n"
			+ "#item { value: item; }\n"
			;
		String pdata = ""
			+ "foo\n"
			+ "bar\n"
			+ "<table>\n"
			+ " <tr id=\"set:ctr=0;foreach:item=list;attr:bgcolor=color\">\n"
			+ "  <td id=\"VALUE:item\">foo</td>\n"
			+ " </tr>\n"
			+ "</table>\n"
			+ "baz<br/>\n"
			+ "end"
			;
		Parser parser = new PresentationLogicParser();
		List rulesets = (List)parser.parse(plogic);
//		for (Iterator it = rulesets.iterator(); it.hasNext(); ) {
//			Ast.Ruleset ruleset = (Ast.Ruleset)it.next();
//			System.out.println(ruleset.inspect());
//		}
		Handler handler = new BaseHandler(rulesets, null);
		TextConverter converter = new TextConverter(handler);

//		converter._reset(pdata, 1);
//		TagInfo taginfo;
//		while ((taginfo = converter._fetch()) != null) {
//			System.out.println(taginfo._inspect());
//		}
//		System.out.println("rest: "+Util.inspect(converter.getRest()));
		
		List stmts = converter.convert(pdata);
		for (Iterator it = stmts.iterator(); it.hasNext(); ) {
			Ast.Statement stmt = (Ast.Statement)it.next();
			System.out.println(stmt.inspect());
		}
	}

}
