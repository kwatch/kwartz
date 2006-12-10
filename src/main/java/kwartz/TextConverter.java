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
	
	TagInfo() {
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
	
	void setTagName(String tagname) { _tagname = tagname; }
	void deleteHeadSpace() { _head_space = ""; rebuildTagText(null); }
	void deleteTailSpace() { _tail_space = ""; rebuildTagText(null); }
	
	void rebuildTagText(AttrInfo attr_info) {
		if (attr_info != null) {
			StringBuffer sb = new StringBuffer();
			List names = attr_info.getNames();
			AttrInfo a = attr_info;
			for (Iterator it = names.iterator(); it.hasNext(); ) {
				String name = (String)it.next();
				sb.append(a.getSpace(name)).append(name).append("=\"").append(a.get(name)).append('"');
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

	void clearAsDummyTag() {
		_tagname = null;
		if (_head_space != null && _tail_space != null)
			_head_space = _tail_space = null;
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
	
	String inspect(int level) {
		StringBuffer sb = new StringBuffer();
		_inspect(level, sb);
		return sb.toString();
	}
	
	String inspect() {
		return inspect(0);
	}

}



class AttrInfo {
	List _names = new ArrayList();   // List<String>
	Map _values = new HashMap();     // List<Ast.Expression>
	Map _spaces = new HashMap();     // List<String>
	
	static Pattern __pat = Pattern.compile("(\\s+)([-:_\\w]+)=\"([^\"]*?)\"");
	
	AttrInfo(String attr_str, int linenum) throws ConvertException {
		Matcher m = __pat.matcher(attr_str);
		while (m.find()) {
			String name = m.group(2);
			_names.add(name);
			_spaces.put(name, m.group(1));
			_values.put(name, _parseAttrValue(m.group(3), linenum));
		}
	}
	
	AttrInfo() {
	}
	
	private Ast.Expression _parseAttrValue(String str, int linenum) throws ConvertException {
		List exprs = HandlerHelper.parseEmbeddedExpression(str, linenum);
		Ast.Expression expr = (Ast.Expression)exprs.get(0);
		for (int i = 1, n = exprs.size(); i < n; i++) {
			expr = new Ast.ArithmeticExpression(Token.CONCAT, expr, (Ast.Expression)exprs.get(i));
		}
		return expr;
	}
	
	
	boolean has(String name) {
		return _values.containsKey(name);
	}
	
	
	void set(String name, String value, String space) throws ConvertException {
		set(name, _parseAttrValue(value, -999), space);
	}

	void set(String name, String value) throws ConvertException {
		set(name, value, null);
	}

	void set(String name, Ast.Expression value, String space) {
		boolean has_name = has(name);
		if (! has_name)
			_names.add(name);
		_values.put(name, value);
		if (space != null)
			_spaces.put(name, space);
		else if (! has_name)
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
			Ast.Expression value = (Ast.Expression)attrs.get(name);
			set(name, value, null);
		}
	}
	
	List getNames() {
		return _names;
	}
	
	Ast.Expression get(String name) {
		return (Ast.Expression)_values.get(name);
	}
	
	String getIfString(String name) {
		Object val = _values.get(name);
		if (val == null) return null;
		if (val instanceof String)
			return (String)val;
		if (val instanceof Ast.StringLiteral)
			return ((Ast.StringLiteral)val).getValue();
		assert val instanceof Ast.Expression;
		return null;
	}
	
	String getSpace(String name) {
		return (String)_spaces.get(name);
	}
	
	boolean isEmpty() {
		return _names.size() == 0;
	}

}



class ElementInfo {
	
	TagInfo  _stag_info, _etag_info;
	List     _cont_stmts;              // List<Ast.Statement>
	AttrInfo _attr_info;
	List     _append_exprs;            // List<Ast.Expression>
	List     _logic, _before, _after;  // List<Ast.Statement>
	String   _directive_text;
	String   _name;
	boolean  _is_applied = false;
	//
	Ast.Expression _stag_expr, _etag_expr, _cont_expr, _elem_expr;
	
	ElementInfo(TagInfo stag_info, TagInfo etag_info, List cont_stmts, AttrInfo attr_info) {
		this(stag_info, etag_info, cont_stmts, attr_info, new ArrayList());
	}
	
	//ElementInfo(List cont_stmts) {
	//	this(new TagInfo(), new TagInfo(), cont_stmts, new AttrInfo(), new ArrayList());
	//}
	
	ElementInfo(TagInfo stag_info, TagInfo etag_info, List cont_stmts, AttrInfo attr_info, List append_exprs) {
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
	boolean  isApplied() { return _is_applied; }
	void     setApplied(boolean flag) { _is_applied = flag; }
	String   getName() { return _name; }
	void     setName(String name) { _name = name; }
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
		ElementInfo elem_info = new ElementInfo(_stag_info, _etag_info, _cont_stmts, _attr_info, _append_exprs);
		elem_info.setLogic(_logic);
		elem_info.setBefore(_before);
		elem_info.setAfter(_after);
		elem_info.setStagExpr(_stag_expr);
		elem_info.setContExpr(_cont_expr);
		elem_info.setEtagExpr(_etag_expr);
		elem_info.setElemExpr(_elem_expr);
		return elem_info;
	}
	
	void clearStag() {
		_stag_expr = null;
		_stag_info = new TagInfo();
	}

	void clearEtag() {
		_etag_expr = null;
		_etag_info = new TagInfo();
	}
	
	static ElementInfo create(Map values) {
		Map v = values;
		return new ElementInfo((TagInfo)v.get("stag"), (TagInfo)v.get("etag"), (List)v.get("cont"), 
				               (AttrInfo)v.get("attr"), (List)v.get("append"));
	}
	
	boolean isDummySpanTag(String tagname) {
		return tagname.equals(getStagInfo().getTagName()) 
		       && getAttrInfo().isEmpty() && getAppendExprs().isEmpty();
	}

	void setAttribute(String name, String value) throws ConvertException {
		_attr_info.set(name, value, null);
	}

	void setAttribute(String name, Ast.Expression value) throws ConvertException {
		_attr_info.set(name, value, null);
	}

	void appendExpression(Ast.Expression expr) {
		_append_exprs.add(expr);
	}

	void apply(Ast.Ruleset ruleset) {
		//if (! ruleset.match("#"+_name)) return;
		Ast.Expression expr;
		if ((expr = ruleset.getStag()) != null)  _stag_expr = expr;
		if ((expr = ruleset.getCont()) != null)  _cont_expr = expr;
		if ((expr = ruleset.getEtag()) != null)  _etag_expr = expr;
		if ((expr = ruleset.getElem()) != null)  _elem_expr = expr;
		Map attrs;
		if ((attrs = ruleset.getAttrs()) != null) _attr_info.merge(attrs);
		List exprs, names, stmts;
		if ((exprs= ruleset.getAppend()) != null) _append_exprs = _append(_append_exprs, exprs);
		if ((names = ruleset.getRemove()) != null)
			for (Iterator it = names.iterator(); it.hasNext(); )
				_attr_info.remove((String)it.next());
		if ((stmts = ruleset.getLogic())  != null) _logic = stmts;
		if ((stmts = ruleset.getBefore()) != null) _before = _append(_before, stmts);
		if ((stmts = ruleset.getAfter())  != null) _after = _append(_after, stmts);
	}
	
	private List _append(List list1, List list2) {
		if (list2 == null) return list1;
		if (list1 == null) list1 = new ArrayList();
		list1.addAll(list2);
		return list1;
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
			List names = _attr_info.getNames();
			for (Iterator it = names.iterator(); it.hasNext(); ) {
				String name = (String) it.next();
				Object value = _attr_info.get(name);
				String space = _attr_info.getSpace(name);
				sb.append(indent).append("  - name: ").append(name).append('\n');
				sb.append(indent).append("    space: ").append(Util.inspect(space)).append('\n');
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
	private String _filename;
	private String _rest;
	private Matcher _matcher;
	private int _linenum, _linenum_delta;
	private int _index;
	private HashMap _no_etag_table;
	String  _dattr = "kw:d";

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
			if ((val = properties.get("dattr")) != null)
				_dattr = val.toString();		
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
	
	void _reset(String pdata, String filename, int linenum) {
		_pdata = pdata;
		_filename = filename;
		_linenum = linenum;
		_linenum_delta = 0;
		_index = 0;
		_rest = null;
		_matcher = __fetch_pattern.matcher(pdata);
	}
	
	
	public List convert(String pdata, String filename) throws ConvertException {
		return convert(pdata, filename, 1);
	}
	
	public List convert(String pdata) throws ConvertException {
		return convert(pdata, null, 1);
	}
	
	public List convert(String pdata, int linenum) throws ConvertException {
		return convert(pdata, null, linenum);
	}
	
	public List convert(String pdata, String filename, int linenum) throws ConvertException {
		try {
			_reset(pdata, filename, linenum);
			List stmt_list = new ArrayList();
			Ast.Ruleset docruleset = _handler.getRuleset("#DOCUMENT");
			if (docruleset == null) {
				_convert(stmt_list, null);
			}
			else {
				List cont_stmts = new ArrayList();
				_convert(cont_stmts, null);
				ElementInfo elem_info = new ElementInfo(new TagInfo(), new TagInfo(), cont_stmts, new AttrInfo(), new ArrayList());
				//elem_info.setAttribute("id", "DOCUMENT");
				//_handler.applyRulesets(elem_info);
				elem_info.apply(docruleset);
				_handler.expandElementInfo(elem_info, stmt_list);
			}
			return stmt_list;
		}
		catch (ConvertException ex) {
			if (ex.getFilename() == null)
				ex.setFilename(_filename);
			throw ex;
		}
	}
	
	
	private static Pattern __fetch_pattern = 
		Pattern.compile("(^[ \t]*)?<(/?)([-:_\\w]+)((?:\\s+[-:_\\w]+=\"[^\"]*?\")*)(\\s*)(/?)>([ \t]*\r?\n)?",
		                Pattern.MULTILINE);

	TagInfo _fetch() {
		Matcher m = _matcher;
		if (m.find()) {
			int start = m.start();
			String prev_text   = _pdata.substring(_index, start);
			String tag_str     = m.group(0);
			String head_space  = m.group(1);
			boolean is_etag    = "/".equals(m.group(2));
			String tagname     = m.group(3);
			String attr_str    = m.group(4);
			String extra_space = m.group(5);
			boolean is_empty   = "/".equals(m.group(6));
			String tail_space  = m.group(7);
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
		int linenum = _linenum + _linenum_delta;
		while ((taginfo = _fetch()) != null) {
			/// prev text
			String prev_text = taginfo.getPrevText();
			if (prev_text != null)
				textbuf.append(prev_text);
			/// end-tag, empty-tag, or start-tag
			if (taginfo.isEtag()) {                                     // end-tag
				if (taginfo.getTagName().equals(start_tagname)) {
					_addTextbufAsPrintStatement(stmt_list, textbuf, linenum);
					linenum = _linenum + _linenum_delta;
					return taginfo;  // end-tag info
				}
				else {
					textbuf.append(taginfo.getTagText());
				}
			}
			else if (taginfo.isEmpty() || _shouldSkipEtag(taginfo)) {   // empty-tag
				AttrInfo attr_info = new AttrInfo(taginfo.getAttrStr(), _linenum);
				String directive_str = getDirective(attr_info, taginfo);
				if (directive_str != null) {
					TagInfo stag_info = taginfo;
					List cont_stmts = new ArrayList();   // List<Ast.Statement>
					TagInfo etag_info = null;
					_addTextbufAsPrintStatement(stmt_list, textbuf, linenum);
					ElementInfo elem_info = new ElementInfo(stag_info, etag_info, cont_stmts, attr_info);
					_handler.applyRulesets(elem_info);
					_handler.handleDirectives(directive_str, elem_info, stmt_list);
					linenum = _linenum + _linenum_delta;
				}
				else {
					textbuf.append(taginfo.getTagText());
				}
			}
			else {                                                      // start-tag
				AttrInfo attr_info = new AttrInfo(taginfo.getAttrStr(), _linenum);
				TagInfo stag_info, etag_info;
				String directive_str = getDirective(attr_info, taginfo);
				if (directive_str != null) {
					stag_info = taginfo;
					List cont_stmts = new ArrayList();
					etag_info = _convert(cont_stmts, stag_info);
					_addTextbufAsPrintStatement(stmt_list, textbuf, linenum);
					ElementInfo elem_info = new ElementInfo(stag_info, etag_info, cont_stmts, attr_info);
					_handler.applyRulesets(elem_info);
					_handler.handleDirectives(directive_str, elem_info, stmt_list);
					linenum = _linenum + _linenum_delta;
				}
				else if (matchesRuleset(taginfo, attr_info)) {
					stag_info = taginfo;
					List cont_stmts = new ArrayList();
					etag_info = _convert(cont_stmts, stag_info);
					_addTextbufAsPrintStatement(stmt_list, textbuf, linenum);
					ElementInfo elem_info = new ElementInfo(stag_info, etag_info, cont_stmts, attr_info);
					_handler.applyRulesets(elem_info);
					_handler.expandElementInfo(elem_info, stmt_list);
					linenum = _linenum + _linenum_delta;
				}
				else if (taginfo.getTagName().equals(start_tagname)) {
					stag_info = taginfo;
					textbuf.append(stag_info.getTagText());
					_addTextbufAsPrintStatement(stmt_list, textbuf, linenum);
					etag_info = _convert(stmt_list, stag_info);
					textbuf.append(etag_info.getTagText());
					linenum = _linenum + _linenum_delta;
				}
				else {
					textbuf.append(taginfo.getTagText());
				}
			}//if
		}//while
		/// fetch end
		if (start_tag_info != null)
			throw _convertError("'<"+start_tagname+">' is not closed.", start_tag_info.getLinenum());
		if (_rest != null)
			textbuf.append(_rest);
		_addTextbufAsPrintStatement(stmt_list, textbuf, linenum);
		return null;
	}


	private void _addTextbufAsPrintStatement(List stmt_list, StringBuffer textbuf, int linenum) throws ConvertException {
		if (textbuf.length() > 0) {
			stmt_list.add(_createPrintStatement(textbuf.toString(), linenum));
			textbuf.setLength(0);
		}
	}

	
	private boolean _shouldSkipEtag(TagInfo tag_info) {
		return _no_etag_table.containsKey(tag_info.getTagName());
	}
	
	
	public String getDirective(AttrInfo attr_info, TagInfo tag_info) throws ConvertException {
		// kw:d attribute
		String dattr_name = _dattr;         // ex. _dattr == 'kw:d'
		String dattr_value = null;
		Ast.Expression dattr_value_expr = attr_info.get(dattr_name);
		if (dattr_value_expr != null) {
			//if (! (dattr_value_expr instanceof Ast.StringLiteral))
			//	throw _convertError(_dattr+"=\"...\": directive cannot contain '@{...}@'.", tag_info.getLinenum());
			if (dattr_value_expr instanceof Ast.StringLiteral)
				dattr_value = ((Ast.StringLiteral)dattr_value_expr).getValue();
		}
		if (dattr_value != null && dattr_value.length() > 0) {
			if (dattr_value.charAt(0) == ' ') {
				String value = dattr_value.substring(1, dattr_value.length()-1);
				attr_info.set(dattr_name, value);
				tag_info.rebuildTagText(attr_info);
			}
			else {
				if (! Pattern.matches("\\A\\w+:.*", dattr_value))
					throw _convertError("'"+dattr_name+"=\""+dattr_value+"\"': invalid directive pattern.", tag_info.getLinenum());
				attr_info.remove(dattr_name);
				tag_info.rebuildTagText(attr_info);
				String directive_str = dattr_value;
				return directive_str;
			}
		}
		// id attribute
		dattr_name = "id";
		dattr_value = attr_info.getIfString(dattr_name);
		if (dattr_value != null) {
			if (Pattern.matches("\\A[-\\w]+\\z", dattr_value)) {
				String directive_str = "mark:" + dattr_value;
				return directive_str;
			}
			else if (Pattern.matches("\\A\\w+:.*", dattr_value)) {
				attr_info.remove("id");
				tag_info.rebuildTagText(attr_info);
				String directive_str = dattr_value;
				return directive_str;
			}
		}
		return null;
	}


	protected boolean matchesRuleset(TagInfo tag_info, AttrInfo attr_info) {
		String idname = attr_info.getIfString("id");
		if (idname != null && _handler.getRuleset("#"+idname) != null)
			return true;
		String classname = attr_info.getIfString("class");
		if (classname != null && _handler.getRuleset("."+classname) != null)
			return true;
		String tagname = tag_info.getTagName();
		if (_handler.getRuleset(tagname) != null) 
			return true;
		return false;
	}


	static Pattern __embed_pattern = Pattern.compile("@(!*)\\{(.*?)\\}@");
	
	private static Ast.PrintStatement _createPrintStatement(String text, int linenum) throws ConvertException {
		return HandlerHelper.createTextPrintStatement(text, linenum);
	}
	
	
	private ConvertException _convertError(String message, int linenum) {
		//return HandlerHelper.convertError(message, linenum);
		return new ConvertException(message, _filename, linenum);
	}

	
	public static void main(String[] args) throws Exception {
		String plogic = ""
			+ "#list {\n"
			//+ "  attrs: 'bgcolor' color;\n"
			+ "  logic: {\n"
			//+ "    ctr = 0;\n"
			+ "    foreach (item = list;) {\n"
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
			+ "bar@!{title}@\n"
			+ "<table class=\"@{klass1}@\">\n"
			+ " <tr id=\"set:ctr=0;foreach:item=list;attr:bgcolor=color\" class=\"@{klass2}@\">\n"
			+ "  <td id=\"VALUE:item\">foo</td>\n"
			+ "  <td>@{item}@</td>\n"
			+ " </tr>\n"
			+ "</table>\n"
			+ "baz@{var}@<br/>\n"
			+ "end"
			;
		pdata = ""
			+ "<ul id=\"mark:foo\" class=\"klass\">\n"
			+ "<li>item</li>\n"
			+ "</ul>\n"
			;
		pdata = ""
			+ "<p>\n"
			//+ "  <span id=\"mark:bar\">BAR</span>\n"
			+ "  <span id=\"mark:bar\">\n"
			+ "    BAR\n"
			+ "  </span>\n"
			//+ "  <span kw:d=\"id:baz\">BAZ</span>\n"
			+ "</p>\n"
			;
		plogic = ""
			+ "@import 'foo.plogic'\n"
			+ "#foo {\n"
			+ "  value: x;\n"
			+ "}\n"
			;


		Parser parser = new PresentationLogicParser();
		List rulesets = (List)parser.parse(plogic);
//		for (Iterator it = rulesets.iterator(); it.hasNext(); ) {
//			Ast.Ruleset ruleset = (Ast.Ruleset)it.next();
//			System.out.println(ruleset.inspect());
//		}
		Map properties = new HashMap();
		properties.put("delspan", Boolean.TRUE);
		Handler handler = new BaseHandler(rulesets, properties);
		TextConverter converter = new TextConverter(handler, properties);

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
