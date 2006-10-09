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



class HandlerHelper {
	
	//// converter helper
	
	public ConvertException convertError(String message, int linenum) {
		return new ConvertException(message, null, linenum);
	}
	
	public void errorIfEmptyTag(HandlerArgument arg) throws ConvertException {
		if (arg.getEtagInfo() == null) {
			String msg = "'"+arg.getDirectiveStr()+"': "+arg.getDirectiveName()
			            +" directive is not available with empty tag.";
			throw convertError(msg, arg.getStagInfo().getLinenum());
		}
	}
	
	public void errorWhenLastStmtIsNotIf(List stmt_list, HandlerArgument arg) throws ConvertException {
		int t = _lastStatementToken(stmt_list);
		if (t != Token.IF && t != Token.ELSEIF) {
			String msg = "'"+arg.getDirectiveStr()+"': previous statement should be 'if' or 'elseif'.";
			throw convertError(msg, arg.getStagInfo().getLinenum());
		}
	}
	
	public int _lastStatementToken(List stmt_list) {
		if (stmt_list == null || stmt_list.size() == 0)
			return -1;
		Ast.Statement last_stmt = (Ast.Statement)stmt_list.get(stmt_list.size() - 1);
		return last_stmt.getToken();
	}
	
	//// statement heldper
	
	public Ast.PrintStatement createTextPrintStatement(String text) {
		Ast.Expression expr = new Ast.StringLiteral(text);
		return new Ast.PrintStatement(new Ast.Expression[] { expr });
	}
	
	public List buildPrintStatementArguments(TagInfo taginfo, AttrInfo attr_info, List append_exprs) {
		List args = new ArrayList();
		if (taginfo.getTagName() == null)
			return args;
		if (attr_info == null && append_exprs == null) {
			args.add(new Ast.StringLiteral(taginfo.getTagText()));  // or list.add(taginfo.getTagText()) ?
			return args;
		}
		TagInfo t = taginfo;
		StringBuffer sb = new StringBuffer();
		String s;
		if ((s = t.getHeadSpace()) != null) sb.append(s);
		sb.append('<');
		if (t.isEtag()) sb.append('/');
		sb.append(t.getTagName());
		List names = attr_info.getNames();
		for (Iterator it = names.iterator(); it.hasNext(); ) {
			String name = (String)it.next();
			Object value = attr_info.getValue(name);
			String space = attr_info.getSpace(name);
			sb.append(space).append(name).append("=\"");
			if (value instanceof Ast.Expression) {
				args.add(new Ast.StringLiteral(sb.toString()));
				args.add(value);
				sb.setLength(0);
			}
			else {
				sb.append((String)value);
			}
			sb.append('"');
		}
		if (append_exprs != null && append_exprs.size() > 0) {
			if (sb.length() > 0) {
				args.add(new Ast.StringLiteral(sb.toString()));
				sb.setLength(0);
			}
			args.addAll(append_exprs);
		}
		if ((s = t.getExtraSpace()) != null) sb.append(s);
		if (t.isEmpty()) sb.append('/');
		sb.append('>');
		if ((s = t.getTailSpace()) != null) sb.append(s);
		args.add(new Ast.StringLiteral(sb.toString()));
		return args;
	}

	
	public Ast.PrintStatement buildPrintStatement(TagInfo taginfo, AttrInfo attr_info, List append_exprs) {
		List args = buildPrintStatementArguments(taginfo, attr_info, append_exprs);
		return new Ast.PrintStatement(args);
	}
	
	public Ast.PrintStatement buildPrintStatementForExpression(Ast.Expression expr, TagInfo stag_info, TagInfo etag_info) {
		String head_space = (stag_info != null ? stag_info : etag_info).getHeadSpace();
		String tail_space = (etag_info != null ? etag_info : stag_info).getTailSpace();
		List args = new ArrayList();
		if (head_space != null && head_space.length() > 0)
			args.add(new Ast.StringLiteral(head_space));
		args.add(expr);
		if (tail_space != null && tail_space.length() > 0)
			args.add(new Ast.StringLiteral(tail_space));
		return new Ast.PrintStatement(args);
	}
	
	public Ast.PrintStatement stagStatement(HandlerArgument arg) {
		return buildPrintStatement(arg.getStagInfo(), arg.getAttrInfo(), arg.getAppendExprs());
	}
	
	public Ast.PrintStatement etagStatement(HandlerArgument arg) {
		return buildPrintStatement(arg.getEtagInfo(), null, null);
	}
	
	////
	public Ast.Expression parseAndEscapeExpression(String directive_name, String directive_arg, int linenum) throws ConvertException {
		Ast.Expression expr = null;
		try {
			Parser parser = new ExpressionParser();
			expr = (Ast.Expression)parser.parse(directive_arg);
		}
		catch (ParseException ex) {
			throw convertError(ex.getMessage(), linenum);
		}
		int escape_flag = Parser.detectEscapeFlag(directive_name);
		if (escape_flag != 0) {
			String funcname = escape_flag > 0 ? "E" : "X";
			expr = (Ast.Expression)Ast.Helper.wrapWithFunction(expr, funcname);
		}
		return expr;
	}
	
	
	////
	private static HandlerHelper __instance = new HandlerHelper();
	
	public static HandlerHelper getInstance() {
		return __instance;
	}
	
}



class HandlerArgument {
	String   _directive_name;
	String   _directive_arg;
	String   _directive_str;
	TagInfo  _stag_info, _etag_info;
	List     _cont_stmts;   // List<Ast.Statement>
	AttrInfo _attr_info;
	List     _append_exprs;  // List<Ast.Expression>

	HandlerArgument(String directive_name, String directive_arg, String directive_str,
			TagInfo stag_info, TagInfo etag_info, List cont_stmts, AttrInfo attr_info, List append_exprs) {
		_directive_name = directive_name;
		_directive_arg  = directive_arg;
		_directive_str  = directive_str;
		_stag_info      = stag_info;
		_etag_info      = etag_info;
		_cont_stmts     = cont_stmts;
		_attr_info      = attr_info;
		_append_exprs   = append_exprs;
	}
	
	String   getDirectiveName() { return _directive_name; }
	String   getDirectiveArg()  { return _directive_arg; }
	String   getDirectiveStr()  { return _directive_str; }
	TagInfo  getStagInfo()      { return _stag_info; }
	TagInfo  getEtagInfo()      { return _etag_info; }
	List     getContStmts()     { return _cont_stmts; }
	AttrInfo getAttrInfo()      { return _attr_info; }
	List     getAppendExprs()   { return _append_exprs; }

}



public class BaseHandler implements Handler {
	List    _rulesets;
	Map     _ruleset_table = new HashMap();
	Map     _elem_info_table = new HashMap();
	boolean _delspan = false;
	String  _dattr = "kw:d";
	HandlerHelper _helper = HandlerHelper.getInstance();

	public BaseHandler(List rulesets, Map properties) {
		_rulesets = rulesets;
		for (Iterator it = rulesets.iterator(); it.hasNext(); ) {
			Ast.Ruleset ruleset = (Ast.Ruleset)it.next();
			String[] selector_names = ruleset.selectorNames();
			for (int i = 0, n = selector_names.length; i < n; i++) {
				_registerRuleset(selector_names[i], ruleset);
			}
		}
		if (properties != null) {
			Object val = properties.get("delspan");
			_delspan = val == Boolean.TRUE;
			val = properties.get("dattr");
			if (val != null && val instanceof String)
				_dattr = (String)val;
		}
	}
	
	public BaseHandler(List rulesets) {
		this(rulesets, null);
	}

	private void _registerRuleset(String key, Ast.Ruleset ruleset) {
		Ast.Ruleset ruleset2 = (Ast.Ruleset)_ruleset_table.get(key);
		if (ruleset2 != null)
			ruleset = Ast.Ruleset.merged(ruleset2, ruleset);
		_ruleset_table.put(key, ruleset);
	}
	
	public Ast.Ruleset getRuleset(String selector_name) {
		return (Ast.Ruleset)_ruleset_table.get(selector_name);
	}

	
	public boolean hasDirective(AttrInfo attr_info, TagInfo tag_info) throws ConvertException {
		// kw:d attribute
		String dattr_name = _dattr;         // ex. _dattr == 'kw:d'
		String dattr_value = (String)attr_info.getValue(dattr_name); 
		if (dattr_value != null && dattr_value.length() > 0) {
			if (dattr_value.charAt(0) == ' ') {
				String value = dattr_value.substring(1, dattr_value.length()-1);
				String space = null;
				attr_info.set(dattr_name, value, space);
				dattr_value = null;
			}
			else {
				if (! Pattern.matches("\\A\\w+:.*", dattr_value))
					throw _helper.convertError("'"+dattr_name+"=\""+dattr_value+"\"': invalid directive pattern.", tag_info.getLinenum());
				attr_info.remove(dattr_name);
			}
			tag_info.rebuildTagText(attr_info);
		}
		if (dattr_value == null) {
			dattr_name = "id";
			dattr_value = (String)attr_info.getValue(dattr_name);
			if (dattr_value != null) {
				if (Pattern.matches("\\A\\w+\\z", dattr_value)) {
					dattr_value = "mark:" + dattr_value;
				}
				else if (Pattern.matches("\\A\\w+:.*", dattr_value)) {
					attr_info.remove("id");
					tag_info.rebuildTagText(attr_info);
				}
				else {
					dattr_value = null;
				}
			}	
		}
		if (dattr_value == null)
			return false;
		tag_info.setDirective(dattr_name, dattr_value);
		return true;
	}

	
	public void applyRuleset(TagInfo stag_info, TagInfo etag_info, List cont_stmts, AttrInfo attr_info, List stmt_list) throws ConvertException  {
		String name = null;
		List append_exprs = null;
		ElementInfo elem_info = new ElementInfo(name, stag_info, etag_info, cont_stmts, attr_info, append_exprs); 
		Ast.Ruleset ruleset;
		String tagname = stag_info.getTagName();
		if ((ruleset = (Ast.Ruleset)_ruleset_table.get(tagname)) != null)
			elem_info.merge(ruleset);
		String classname = (String)attr_info.getValue("class");
		if (classname != null && (ruleset = (Ast.Ruleset)_ruleset_table.get("."+classname)) != null)
			elem_info.merge(ruleset);
		String idname = (String)attr_info.getValue("id");
		if (idname != null && (ruleset = (Ast.Ruleset)_ruleset_table.get("#"+idname)) != null)
			elem_info.merge(ruleset);
		Ast.Statement stmt = expandElementInfo(elem_info, false);
		assert stmt != null;
		stmt_list.add(stmt);
	}
	
	
	public boolean handle(List stmt_list, HandlerArgument arg) throws ConvertException {
		String d_name = arg.getDirectiveName();
		String d_arg = arg.getDirectiveArg();
		String d_str = arg.getDirectiveStr();
		//
		TagInfo  stag_info = arg.getStagInfo();
		TagInfo  etag_info = arg.getEtagInfo();
		List     cont_stmts = arg.getContStmts();
		AttrInfo attr_info = arg.getAttrInfo();
		List     append_exprs = arg.getAppendExprs();
		int stag_linenum = stag_info.getLinenum();
		//
		if (d_name == null) {
			assert !attr_info.isEmpty() || !append_exprs.isEmpty();  // ???
			stmt_list.add(_helper.stagStatement(arg));
			stmt_list.addAll(cont_stmts);
			if (etag_info != null)
				stmt_list.add(_helper.etagStatement(arg));   // when not empty-tag
		}
		else if ("dummy".equals(d_name)) {
			// nothing
		}
		else if ("id".equals(d_name) || "mark".equals(d_name)) {
			if (! Pattern.matches("\\A\\w+\\z", d_arg))
				throw _helper.convertError("'"+d_str+"': invalid marking name.", stag_linenum);
			String name = d_arg;
			ElementInfo elem_info = new ElementInfo(name, stag_info, etag_info, cont_stmts, attr_info, append_exprs);
			if (_elem_info_table.containsKey(name)) {
				int previous_linenum = ((ElementInfo)_elem_info_table.get(name)).getStagInfo().getLinenum();
				String msg = "'"+d_str+"': id '"+name+"' is already used at line "+previous_linenum+".";
				throw _helper.convertError(msg, stag_linenum);
			}
			_elem_info_table.put(name, elem_info);
			boolean content_only = false;
			Ast.Statement stmt = expandElementInfo(elem_info, content_only);
			assert stmt != null;
			stmt_list.add(stmt);
		}
		else if ("stag".equals(d_name) || "Stag".equals(d_name) || "STAG".equals(d_name)) {
			_helper.errorIfEmptyTag(arg);
			Ast.Expression expr = _helper.parseAndEscapeExpression(d_name, d_arg, stag_linenum);
			stmt_list.add(_helper.buildPrintStatementForExpression(expr, stag_info, etag_info));
			stmt_list.addAll(cont_stmts);
			stmt_list.add(_helper.etagStatement(arg));
		}
		else if ("etag".equals(d_name) || "Etag".equals(d_name) || "ETAG".equals(d_name)) {
			_helper.errorIfEmptyTag(arg);
			Ast.Expression expr = _helper.parseAndEscapeExpression(d_name, d_arg, stag_linenum);
			stmt_list.add(_helper.stagStatement(arg));
			stmt_list.addAll(cont_stmts);
			stmt_list.add(_helper.buildPrintStatementForExpression(expr, stag_info, etag_info));
		}
		else if ("cont".equals(d_name) || "Cont".equals(d_name) || "CONT".equals(d_name)
				 || "value".equals(d_name) || "Value".equals(d_name) || "VALUE".equals(d_name)) {
			_helper.errorIfEmptyTag(arg);
			stag_info.setTailSpace("");
			etag_info.setHeadSpace("");
			List pargs = _helper.buildPrintStatementArguments(stag_info, attr_info, append_exprs);
			Ast.Expression expr = _helper.parseAndEscapeExpression(d_name, d_arg, stag_linenum);
			pargs.add(expr);
			if (etag_info.getTagName() != null)
				pargs.add(etag_info.getTagText());
			stmt_list.add(new Ast.PrintStatement(pargs));
		}
		else if ("elem".equals(d_name) || "Elem".equals(d_name) || "ELEM".equals(d_name)) {
			Ast.Expression expr = _helper.parseAndEscapeExpression(d_name, d_arg, stag_linenum);
			stmt_list.add(_helper.buildPrintStatementForExpression(expr, stag_info, etag_info));
		}
		else if ("attr".equals(d_name) || "Attr".equals(d_name) || "ATTR".equals(d_name)) {
			Pattern pattern = Pattern.compile("\\A(\\w+(?::\\w+)?)[:=](.*)\\z");
			Matcher m = pattern.matcher(d_arg);
			if (! m.find())
				throw _helper.convertError("'"+d_str+"': invalid attr pattern.", stag_linenum);
			String aname = m.group(1), avalue = m.group(2);
			Ast.Expression expr = _helper.parseAndEscapeExpression(d_name, avalue, stag_linenum);
			attr_info.set(aname, expr, null);
		}
		else if ("append".equals(d_name) || "Append".equals(d_name) || "APPEND".equals(d_name)) {
			Ast.Expression expr = _helper.parseAndEscapeExpression(d_name, d_arg, stag_linenum);
			append_exprs.add(expr);
		}
		else if ("replace_element_with_element".equals(d_name) || "replace_content_with_element".equals(d_name)
				|| "replace_element_with_content".equals(d_name) || "replace_content_with_content".equals(d_name)) {
			// TBC
		}
		else {
			return false;
		}
		return true;
	}

	
	public Ast.Statement expandElementInfo(ElementInfo elem_info, boolean content_only) throws ConvertException {
		String name = elem_info.getName();
		if (name != null) {
			Ast.Ruleset ruleset = (Ast.Ruleset)_ruleset_table.get("#"+name);
			if (ruleset != null && !elem_info.isMerged())
				elem_info.merge(ruleset);
		}
		Ast.Statement stmt;
		if (content_only) {
			stmt = new Ast.ContStatement();
			return expandStatement(stmt, elem_info);
		}
		else {
			List stmts = new ArrayList();
			for (Iterator it = elem_info.getLogic().iterator(); it.hasNext(); ) {
				stmt = (Ast.Statement)it.next();
				Ast.Statement stmt2 = expandStatement(stmt, elem_info);
				stmts.add(stmt2 != null ? stmt2 : stmt);
			}
			return new Ast.BlockStatement(stmts);
		}
		
//		if (content_only) {
//			Ast.Statement stmt = new Ast.ContentStatement(elem_info.getName());
//			return expandStatement(stmt, elem_info);
//		}
//		else {
//			List stmt_list = elem_info.getLogic();
//			List stmts = new ArrayList();
//			for (Iterator it = stmt_list.iterator(); it.hasNext(); ) {
//				Ast.Statement stmt = (Ast.Statement)it.next();
//				Ast.Statement stmt2 = expandStatement(stmt, elem_info);
//				if (stmt2 == null) stmt2 = stmt;
//				stmts.add(stmt2);
//			}
//			return new Ast.BlockStatement(stmts);
//		}
	}
	
	
	
	/**
	 * expand _stag, _cont, _etag, _elem, _element(), and _content().
	 * 
	 * @return Statement if stmt is one of the _stag, _cont, _etag, _elem, _elemen(), or _content(). Otherwise, Null. 
	 */
	public Ast.Statement expandStatement(Ast.Statement stmt, ElementInfo elem_info) throws ConvertException {
		ElementInfo e = elem_info;
		// delete dummy <span> tag
		if (_delspan && e.getStagInfo().getTagName().equals("span") && e.getAttrInfo().isEmpty() && e.getAppendExprs().isEmpty()) {
			e.getStagInfo().setTagName(null);
			e.getEtagInfo().setTagName(null);
		}
		//
		int t = stmt.getToken();
		switch (t) {
		case Token.PRINT:
			return null;
		case Token.EXPR:
			return null;
		case Token.FOREACH:
			expandStatement(((Ast.ForeachStatement)stmt).getBodyStatement(), elem_info);
			return null;
		case Token.IF:
			Ast.IfStatement if_stmt = (Ast.IfStatement)stmt; 
			expandStatement(if_stmt.getThenStatement(), elem_info);
			if (if_stmt.getElseStatement() != null)
				expandStatement(if_stmt.getElseStatement(), elem_info);
			return null;
		case Token.WHILE:
			expandStatement(((Ast.WhileStatement)stmt).getBodyStatement(), elem_info);
			return null;
		case Token.BREAK:
			return null;
		case Token.CONTINUE:
			return null;
		case Token.BLOCK:
			Ast.Statement[] stmts = ((Ast.BlockStatement)stmt).getStatements();
			for (int i = 0, n = stmts.length; i < n; i++) {
				Ast.Statement st = expandStatement(stmts[i], elem_info);
				if (st != null) stmts[i] = st;
			}
			return null;
		case Token.STAG:
			assert elem_info != null;
			if (e.getStagExpr() != null)
				return _helper.buildPrintStatementForExpression(e.getStagExpr(), e.getStagInfo(), null);
			else
				return _helper.buildPrintStatement(e.getStagInfo(), e.getAttrInfo(), e.getAppendExprs());
		case Token.ETAG:
			assert elem_info != null;
			if (e.getEtagExpr() != null)
				return _helper.buildPrintStatementForExpression(e.getEtagExpr(), null, e.getEtagInfo());
			else if (e.getEtagInfo() != null)  // e.getEtagInfo() is null when <br>, <input>, <hr>, <img>, and <meta>
				return _helper.buildPrintStatement(e.getEtagInfo(), null, null);
			return null;
		case Token.CONT:
			assert elem_info != null;
			if (e.getContExpr() != null) {
				return new Ast.PrintStatement(new Ast.Expression[] { e.getContExpr() });
			}
			else {
				Ast.BlockStatement block_stmt = new Ast.BlockStatement(e.getContStmts());
				expandStatement(block_stmt, elem_info);
				return block_stmt;
			}
		case Token.ELEM:
			if (e.getElemExpr() != null) {
				return _helper.buildPrintStatementForExpression(e.getElemExpr(), e.getStagInfo(), e.getEtagInfo());
			}
			else {
				List list = new ArrayList();
				stmt.setToken(Token.STAG);
				list.add(expandStatement(stmt, elem_info));
				stmt.setToken(Token.CONT);
				list.add(expandStatement(stmt, elem_info));
				stmt.setToken(Token.ETAG);
				list.add(expandStatement(stmt, elem_info));
				stmt.setToken(Token.ELEM);
				return new Ast.BlockStatement(list);
			}
		case Token.ELEMENT:
		case Token.CONTENT:
			String name = ((Ast.ExpandStatement)stmt).getName();
			ElementInfo elem_info2 = (ElementInfo)_elem_info_table.get(name);
			if (elem_info2 == null)
				throw _helper.convertError("element '"+name+"' is not found.", stmt.getLinenum());
			boolean content_only = t == Token.CONTENT;
			return expandElementInfo(elem_info2, content_only);
		default:
			assert false;
		}
		return null;	
	}
	
	
	
	public Ast.Statement extract(String elem_name, boolean content_only) throws ConvertException {
		ElementInfo elem_info = (ElementInfo)_elem_info_table.get(elem_name);
		if (elem_info == null) {
			throw _helper.convertError("element '"+elem_name+"' not found.", elem_info.getStagInfo().getLinenum());
		}
		return expandElementInfo(elem_info, content_only);
	}


	
	public static void main(String[] args) throws Exception {
		String plogic = ""
			+ "#list {\n"
			+ "  logic: {\n"
			+ "    foreach (item = list) {\n"
			+ "      _stag;\n"
			+ "      _cont;\n"
			+ "      _etag;\n"
			+ "    }\n"
			+ "  }\n"
			+ "}\n"
			+ "#item { value: item; }\n"
			;
		String pdata = ""
			+ "<table>\n"
			+ " <tr kw:d=\"value:list\">\n"
			+ "  <td id=\"mark:item\">foo</td>\n"
			+ " </tr>\n"
			+ "</table>\n"
			;
		Parser parser = new PresentationLogicParser();
		List rulesets = (List)parser.parse(plogic);
//		for (Iterator it = rulesets.iterator(); it.hasNext(); ) {
//			Ast.Ruleset ruleset = (Ast.Ruleset)it.next();
//			System.out.println(ruleset.inspect());
//		}
		Handler handler = new BaseHandler(rulesets, null);
		TextConverter converter = new TextConverter(handler);
		converter._reset(pdata, 1);
		TagInfo tag_info;
		List list = new ArrayList();
		while ((tag_info = converter._fetch()) != null) {
			list.add(tag_info);
		}
		TagInfo stag_info = (TagInfo)list.get(1), etag_info = (TagInfo)list.get(3);
		AttrInfo attr_info = new AttrInfo(stag_info.getAttrStr());
		List cont_stmts = new ArrayList();
		cont_stmts.add(new Ast.PrintStatement(new Ast.Expression[] { new Ast.StringLiteral("hoge")}));
		boolean result = handler.hasDirective(attr_info, stag_info);
		String d_name = "mark", d_arg = "list", d_str="mark:list";
		List append_exprs = new ArrayList();
		HandlerArgument arg = new HandlerArgument(d_name, d_arg, d_str, stag_info, etag_info, cont_stmts, attr_info, append_exprs);
		List stmt_list = new ArrayList();
		handler.handle(stmt_list, arg);
		for (int i = 0, n = stmt_list.size(); i < n; i++) {
			System.out.println(((Ast.Statement)stmt_list.get(i)).inspect());
		}
		//
		//System.out.println(tag_info._inspect());
		//System.out.println(Util.inspect(attr_info.getNames()));
		//System.out.println("result="+result);
	}


}
