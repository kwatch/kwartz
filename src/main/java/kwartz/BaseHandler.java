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
	
	public static ConvertException convertError(String message, int linenum) {
		return new ConvertException(message, null, linenum);
	}
	
	
	////
	
	public static void errorIfEmptyTag(ElementInfo elem_info, String directive_str) throws ConvertException {
		if (elem_info.getEtagInfo() == null) {
			String msg = "'"+directive_str+"': "+" directive is not available with empty tag.";
			throw convertError(msg, elem_info.getStagInfo().getLinenum());
		}
	}
	
	public static void errorWhenLastStmtIsNotIf(ElementInfo elem_info, String directive_str, List stmt_list) throws ConvertException {
		int t = _lastStatementToken(stmt_list);
		if (t != Token.IF && t != Token.ELSEIF) {
			String msg = "'"+directive_str+"': previous statement should be 'if' or 'elseif'.";
			throw convertError(msg, elem_info.getStagInfo().getLinenum());
		}
	}
	
	public static int _lastStatementToken(List stmt_list) {
		if (stmt_list == null || stmt_list.size() == 0)
			return -1;
		Ast.Statement last_stmt = (Ast.Statement)stmt_list.get(stmt_list.size() - 1);
		return last_stmt.getToken();
	}
	
	//// statement heldper
	
	
	public static Ast.PrintStatement createPrintStatement(String text) {
		Ast.Expression expr = new Ast.StringLiteral(text);
		return new Ast.PrintStatement(new Ast.Expression[] { expr });
	}
	
	public static Ast.PrintStatement createTextPrintStatement(String text, int linenum) throws ConvertException {
		List exprs = parseEmbeddedExpression(text, linenum);
		return new Ast.PrintStatement(exprs);
	}
	
	public static List buildPrintStatementArguments(TagInfo taginfo, AttrInfo attr_info, List append_exprs) {
		List args = new ArrayList();
		if (taginfo.getTagName() == null) {
			String s;
			if ((s = taginfo.getHeadSpace()) != null && s.length() > 0)
				args.add(new Ast.StringLiteral(s));
			if ((s = taginfo.getTailSpace()) != null && s.length() > 0)
				args.add(new Ast.StringLiteral(s));
			return args;
		}
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
			if (value instanceof Ast.StringLiteral) {
				sb.append(((Ast.StringLiteral)value).getValue());
			}
			else if (value instanceof Ast.Expression) {
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

	
	public static Ast.PrintStatement buildPrintStatement(TagInfo taginfo, AttrInfo attr_info, List append_exprs) {
		List args = buildPrintStatementArguments(taginfo, attr_info, append_exprs);
		return new Ast.PrintStatement(args);
	}
	
	public static Ast.PrintStatement buildPrintStatementForExpression(Ast.Expression expr, TagInfo stag_info, TagInfo etag_info) {
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
	
	public static Ast.PrintStatement stagStatement(ElementInfo elem_info) {
		return buildPrintStatement(elem_info.getStagInfo(), elem_info.getAttrInfo(), elem_info.getAppendExprs());
	}
	
	public static Ast.PrintStatement etagStatement(ElementInfo elem_info) {
		return buildPrintStatement(elem_info.getEtagInfo(), null, null);
	}
	
	////
	public static Ast.Expression parseAndEscapeExpression(String directive_name, String directive_arg, int linenum) throws ConvertException {
		Ast.Expression expr = parseExpression(directive_arg, linenum);
		int escape_flag = Parser.detectEscapeFlag(directive_name);
		if (escape_flag != 0) {
			String funcname = escape_flag > 0 ? "E" : "X";
			expr = (Ast.Expression)Ast.Helper.wrapWithFunction(expr, funcname);
		}
		return expr;
	}

	public static Ast.Expression parseExpression(String expr_str, int linenum) throws ConvertException {
		try {
			return _parseExpression(expr_str, linenum);
		}
		catch (ParseException ex) {
			//throw convertError(ex.getMessage(), linenum);
			throw convertError(""+expr_str+": expression has syntax error.", linenum);
		}
	}
	
	public static Ast.Expression _parseExpression(String expr_str, int linenum) throws ParseException {
		Parser parser = new ExpressionParser();
		Ast.Expression expr = (Ast.Expression)parser.parse(expr_str);
		return expr;
	}

	
	public static Ast.ExpressionStatement createExpressionStatement(String expr_str) throws ConvertException {
		Ast.Expression expr = parseExpression(expr_str, -1);
		return new Ast.ExpressionStatement(expr);
	}


	static final Pattern EMBED_EXPRESSION_PATTERN = Pattern.compile("@(!*)\\{(.*?)\\}@");
	

	public static List parseEmbeddedExpression(String text, int linenum) throws ConvertException {
		String embedded_expr_str = null;
		try {
			ArrayList exprs = new ArrayList();
			int index = 0;
			Matcher m = EMBED_EXPRESSION_PATTERN.matcher(text);
			while (m.find()) {
				int pos = m.start();
				if (pos > index) {
					String prev_text = text.substring(index, pos);
					exprs.add(new Ast.StringLiteral(prev_text));
					linenum += Util.count(prev_text, '\n');
				}
				embedded_expr_str = m.group(0);
				index = pos + embedded_expr_str.length();
				String expr_str = m.group(2);
				Ast.Expression expr = _parseExpression(expr_str, linenum);
				linenum += Util.count(expr_str, '\n');
				String indicator = m.group(1);
				switch (indicator.length()) {
				case 0:
					expr = Ast.Helper.wrapWithFunction(expr, "E");
					break;
				case 1:
					/// nothing
					break;
				case 2:
					/// debug: report expression value into stderr
					break;
				default:
				}
				exprs.add(expr);
			}
			String rest = text.substring(index);
			if (rest.length() > 0)
				exprs.add(new Ast.StringLiteral(rest));
			return exprs;
		}
		catch (ParseException ex) {
			throw convertError(""+embedded_expr_str+": embedded expression has syntax error.", linenum);
		}
	}


}



public class BaseHandler implements Handler {
	List    _rulesets;
	Map     _ruleset_table = new HashMap();
	Map     _elem_info_table = new HashMap();
	boolean _delspan = false;
	String  _dattr = "kw:d";
	String  _even = "'even'";
	String  _odd  = "'odd'";

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
			if (val != null && val instanceof Boolean)
				_delspan = ((Boolean)val).booleanValue();
			if ((val = properties.get("dattr")) != null)
				_dattr = val.toString();		
			if ((val = properties.get("even")) != null)
				_even = val.toString();
			if ((val = properties.get("odd")) != null)
				_odd = val.toString();
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
		String dattr_value = null;
		Ast.Expression dattr_value_expr = attr_info.getValue(dattr_name);
		if (dattr_value_expr != null) {
			//if (! (dattr_value_expr instanceof Ast.StringLiteral))
			//	throw HandlerHelper.convertError(_dattr+"=\"...\": directive cannot contain '@{...}@'.", tag_info.getLinenum());
			if (dattr_value_expr instanceof Ast.StringLiteral)
				dattr_value = ((Ast.StringLiteral)dattr_value_expr).getValue();
		}
		if (dattr_value != null && dattr_value.length() > 0) {
			if (dattr_value.charAt(0) == ' ') {
				String value = dattr_value.substring(1, dattr_value.length()-1);
				String space = null;
				attr_info.set(dattr_name, value, space);
				dattr_value = null;
			}
			else {
				if (! Pattern.matches("\\A\\w+:.*", dattr_value))
					throw HandlerHelper.convertError("'"+dattr_name+"=\""+dattr_value+"\"': invalid directive pattern.", tag_info.getLinenum());
				attr_info.remove(dattr_name);
			}
			tag_info.rebuildTagText(attr_info);
		}
		if (dattr_value == null) {
			dattr_name = "id";
			dattr_value = attr_info.getValueIfString(dattr_name);
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

	
	
	private static Pattern __directive_pattern = Pattern.compile("\\A(\\w+):\\s*(.*)");

	
	public void handleDirectives(ElementInfo elem_info, List stmt_list) throws ConvertException {
		
		_findAndMergeRuleset(elem_info, true, true, false);

		TagInfo stag_info = elem_info.getStagInfo(), etag_info = elem_info.getEtagInfo();

		String directive_name = null, directive_arg = null, directive_str = null;
		String[] strs = stag_info.getDirectiveStr().split(";");
		Pattern pattern = __directive_pattern;   //  /\A(\w+):\s*(.*)/
		for (int i = 0, n = strs.length; i < n; i++) {
			String d_str = strs[i].trim();
			Matcher m = pattern.matcher(d_str);
			if (! m.find()) {
				throw HandlerHelper.convertError("'"+d_str+"': invalid directive pattern.", stag_info.getLinenum());
			}
			String d_name = m.group(1);   // directive_name
			String d_arg  = m.group(2);   // directive_arg
			int d_code = directiveCode(d_name);
			if (d_code == D_ATTR || d_code == D_APPEND || d_code == D_SET) {
				boolean handled = handle(d_name, d_arg, d_str, elem_info, stmt_list);
				if (! handled)
					throw HandlerHelper.convertError("'"+d_str+"': unknown directive.", stag_info.getLinenum());
			}
			else {
				if (directive_name != null)
					throw HandlerHelper.convertError("'"+d_str+"': not available with other directive '"+directive_name+"' at one time.", stag_info.getLinenum());
				directive_name = d_name;
				directive_arg  = d_arg;
				directive_str  = d_str;
			}
		}

		/// remove dummy <span> tag
		if (_delspan && elem_info.isDummySpanTag("span")) {
			stag_info.setAsDummyTag();
			etag_info.setAsDummyTag();
		}
		
		/// handle directives
		if (directive_name != null) {
			boolean handled = handle(directive_name, directive_arg, directive_str, elem_info, stmt_list);
			if (! handled)
				throw HandlerHelper.convertError("'"+directive_str+"': unknown directive.", stag_info.getLinenum());	
		}

		// expand elem_info and append to stmt_list
		Ast.BlockStatement block_stmt = expandElementInfo(elem_info);
		Ast.Statement[] stmts = block_stmt.getStatements();
		for (int i = 0, n = stmts.length; i < n; i++) {
			stmt_list.add(stmts[i]);
		}
		
	}

	

	public boolean handle(String directive_name, String directive_arg, String directive_str, ElementInfo elem_info, List stmt_list) throws ConvertException {
		assert directive_name != null;
		String d_name = directive_name;
		String d_arg = directive_arg;
		String d_str = directive_str;
		//
		TagInfo  stag_info    = elem_info.getStagInfo();
		TagInfo  etag_info    = elem_info.getEtagInfo();
		int stag_linenum = stag_info.getLinenum();
		//
		Ast.Expression expr;
		Ast.Statement stmt, block_stmt;
		List stmts;
		Matcher m;
		int d_code = directiveCode(d_name);
		switch (d_code) {
		case D_DUMMY:
			elem_info.setLogic(ElementInfo.EMPTY_LOGIC);
			elem_info.setBefore((List)null);
			elem_info.setAfter((List)null);
			return true;
		case D_ID:
		case D_MARK:
			if (! Pattern.matches("\\A\\w+\\z", d_arg))
				throw HandlerHelper.convertError("'"+d_str+"': invalid marking name.", stag_linenum);
			String name = d_arg;
			Ast.Ruleset ruleset = (Ast.Ruleset)_ruleset_table.get("#"+name); 
			if (ruleset != null)
				elem_info.merge(ruleset);
			if (_elem_info_table.containsKey(name)) {
				int previous_linenum = ((ElementInfo)_elem_info_table.get(name)).getStagInfo().getLinenum();
				String msg = "'"+d_str+"': id '"+name+"' is already used at line "+previous_linenum+".";
				throw HandlerHelper.convertError(msg, stag_linenum);
			}
			_elem_info_table.put(name, elem_info);
			return true;
		case D_STAG:
			HandlerHelper.errorIfEmptyTag(elem_info, directive_str);					
			expr = HandlerHelper.parseAndEscapeExpression(d_name, d_arg, stag_linenum);
			elem_info.setStagExpr(expr);
			return true;
		case D_ETAG:
			HandlerHelper.errorIfEmptyTag(elem_info, directive_str);
			expr = HandlerHelper.parseAndEscapeExpression(d_name, d_arg, stag_linenum);
			elem_info.setEtagExpr(expr);
			return true;
		case D_CONT:
		case D_VALUE:
			HandlerHelper.errorIfEmptyTag(elem_info, directive_str);
			stag_info.deleteTailSpace();
			etag_info.deleteHeadSpace();
			expr = HandlerHelper.parseAndEscapeExpression(d_name, d_arg, stag_linenum);
			elem_info.setContExpr(expr);
			return true;
		case D_ELEM:
			expr = HandlerHelper.parseAndEscapeExpression(d_name, d_arg, stag_linenum);
			elem_info.setElemExpr(expr);
			return true;
		case D_ATTR:
			Pattern pattern = Pattern.compile("\\A(\\w+(?::\\w+)?)[:=](.*)\\z");
			m = pattern.matcher(d_arg);
			if (! m.find())
				throw HandlerHelper.convertError("'"+d_str+"': invalid attr pattern.", stag_linenum);
			String aname = m.group(1), avalue = m.group(2);
			expr = HandlerHelper.parseAndEscapeExpression(d_name, avalue, stag_linenum);
			elem_info.getAttrInfo().set(aname, expr, null);
			return true;
		case D_APPEND:
			expr = HandlerHelper.parseAndEscapeExpression(d_name, d_arg, stag_linenum);
			elem_info.getAppendExprs().add(expr);
			return true;
		case D_REPLACE1:
		case D_REPLACE2:
		case D_REPLACE3:
		case D_REPLACE4:
			stmts = new ArrayList();
			name = d_arg;
			ElementInfo elem_info2 = (ElementInfo)_elem_info_table.get(name);
			if (elem_info2 == null)
				throw HandlerHelper.convertError("'"+d_str+"': element not found.", stag_linenum);
			boolean replace_content = d_code == D_REPLACE3 || d_code == D_REPLACE4;
			boolean with_content    = d_code == D_REPLACE2 || d_code == D_REPLACE4;
			if (replace_content)
				stmts.add(new Ast.StagStatement());
			if (with_content)
				stmts.add(new Ast.ContentStatement(name));
			else
				stmts.add(new Ast.ElementStatement(name));
			if (replace_content)
				stmts.add(new Ast.EtagStatement());
			elem_info.setLogic(stmts);
			return true;
		case D_SET:
			expr = HandlerHelper.parseExpression(d_arg, stag_linenum);
			stmts = elem_info.getBefore();
			if (stmts == null)
				elem_info.setBefore(stmts = new ArrayList());
			stmts.add(new Ast.ExpressionStatement(expr));
			return true;
		case D_IF:
			expr = HandlerHelper.parseExpression(d_arg, stag_linenum);  // condition
			Ast.Statement then_stmt = new Ast.BlockStatement(elem_info.getLogic());
			Ast.Statement else_stmt = null;
			elem_info.setLogic(new Ast.IfStatement(expr, then_stmt, else_stmt));
			return true;
		case D_ELSEIF:
		case D_ELSE:
			stmt = null;
			if (stmt_list.size() > 0)
				stmt = (Ast.Statement)stmt_list.get(stmt_list.size()-1);
			if (stmt == null || stmt.getToken() != Token.IF)
				throw HandlerHelper.convertError("'"+d_str+"': previous is not if-statement nor elseif-statement.", stag_linenum);
			Ast.IfStatement if_stmt = (Ast.IfStatement)stmt;
			else_stmt = if_stmt.getElseStatement();
			while (else_stmt != null && else_stmt.getToken() == Token.IF) {
				if_stmt = (Ast.IfStatement)else_stmt;
				else_stmt = if_stmt.getElseStatement();
			}
			if (else_stmt != null)
				throw HandlerHelper.convertError("'"+d_str+"': previous if-statement already takes other statement.", stag_linenum);
			stmt = new Ast.BlockStatement(elem_info.getLogic());
			if (d_code == D_ELSEIF) {
				expr = HandlerHelper.parseExpression(d_arg, stag_linenum);  // condition
				stmt = new Ast.IfStatement(expr, stmt, else_stmt);
			}
			_expandStatement(stmt, elem_info);
			if_stmt.setElseStatement(stmt);
			elem_info.setLogic(ElementInfo.EMPTY_LOGIC);
			return true;
		case D_WHILE:
			expr = HandlerHelper.parseExpression(d_arg, stag_linenum);  // condition
			block_stmt = new Ast.BlockStatement(elem_info.getLogic());
			stmt = new Ast.WhileStatement(expr, block_stmt);
			elem_info.setLogic(stmt);
			return true;
		case D_LOOP:
			HandlerHelper.errorIfEmptyTag(elem_info, directive_str);
			expr = HandlerHelper.parseExpression(d_arg, stag_linenum);  // condition
			stmts = new ArrayList();
			stmts.add(new Ast.StagStatement());
			stmts.add(new Ast.WhileStatement(expr, new Ast.BlockStatement(new Ast.ContStatement())));
			stmts.add(new Ast.EtagStatement());
			elem_info.setLogic(stmts);
			return true;
		case D_FOREACH:
		case D_LIST:
			if (d_code == D_LIST)
				HandlerHelper.errorIfEmptyTag(elem_info, directive_str);
			int indicator = _detectKind(d_name);
			Pattern pat = Pattern.compile("\\A([a-zA-Z_]\\w*)[:=](.+)\\z");
			m = pat.matcher(d_arg);
			if (! m.find())
				throw HandlerHelper.convertError("'"+d_str+"': invalid directive syntax.", stag_linenum);
			Ast.Expression item_expr = HandlerHelper.parseExpression(m.group(1), stag_linenum);
			Ast.Expression loop_expr = HandlerHelper.parseExpression(m.group(2), stag_linenum);
			String counter = indicator != 0 ? m.group(1) + "_ctr" : null;
			String toggle  = indicator <  0 ? m.group(1) + "_tgl" : null;
			stmts = new ArrayList();
			if (counter != null)
				stmts.add(HandlerHelper.createExpressionStatement(counter+"+=1"));
			if (toggle != null)
				stmts.add(HandlerHelper.createExpressionStatement(toggle+"="+counter+"%2==0?"+_even+":"+_odd));
			if (d_code == D_FOREACH) {
				stmts.add(new Ast.ElemStatement());
				block_stmt = new Ast.BlockStatement(stmts);
				stmts = new ArrayList();
				if (counter != null)
					stmts.add(HandlerHelper.createExpressionStatement(counter+"=0"));
				stmts.add(new Ast.ForeachStatement(item_expr, loop_expr, block_stmt));
				elem_info.setLogic(stmts);
			}
			else {
				stmts.add(new Ast.ContStatement());
				block_stmt = new Ast.BlockStatement(stmts);
				stmts = new ArrayList();
				stmts.add(new Ast.StagStatement());
				if (counter != null)
					stmts.add(HandlerHelper.createExpressionStatement(counter+"=0"));
				stmts.add(new Ast.ForeachStatement(item_expr, loop_expr, block_stmt));
				stmts.add(new Ast.EtagStatement());
				elem_info.setLogic(stmts);
			}
			return true;
		case D_DEFAULT:
			HandlerHelper.errorIfEmptyTag(elem_info, directive_str);
			expr = HandlerHelper.parseExpression(d_arg, stag_linenum);
			then_stmt = new Ast.BlockStatement(new Ast.PrintStatement(expr));
			else_stmt = new Ast.BlockStatement(new Ast.ContStatement());
			expr = HandlerHelper.parseExpression("!str_empty("+d_arg+")", stag_linenum); // condition
			stmt = new Ast.IfStatement(expr, then_stmt, else_stmt);
			stmts = new ArrayList();
			stmts.add(new Ast.StagStatement());
			stmts.add(new Ast.IfStatement(expr, then_stmt, else_stmt));
			stmts.add(new Ast.EtagStatement());
			elem_info.setLogic(stmts);
			return true;
		}
		return false;
	}
	
	private static final int D_DUMMY    = 0;
	private static final int D_ID       = 1;
	private static final int D_MARK     = 2;
	private static final int D_STAG     = 3;
	private static final int D_CONT     = 4;
	private static final int D_ETAG     = 5;
	private static final int D_ELEM     = 6;
	private static final int D_VALUE    = 7;
	private static final int D_ATTR     = 8;
	private static final int D_APPEND   = 9;
	private static final int D_REPLACE1 = 10;
	private static final int D_REPLACE2 = 11;
	private static final int D_REPLACE3 = 12;
	private static final int D_REPLACE4 = 13;
	//
	private static final int D_SET      = 14;
	private static final int D_IF       = 15;
	private static final int D_ELSEIF   = 16;
	private static final int D_ELSE     = 17;
	private static final int D_WHILE    = 18;
	private static final int D_LOOP     = 19;
	private static final int D_FOREACH  = 20;
	private static final int D_LIST     = 21;
	private static final int D_DEFAULT  = 22;


	private static final HashMap __directive_code_table;
	static {
		__directive_code_table = new HashMap();
		__directive_code_table.put("dummy",  new Integer(D_DUMMY));
		__directive_code_table.put("id",     new Integer(D_ID));
		__directive_code_table.put("mark",   new Integer(D_MARK));
		__directive_code_table.put("stag",   new Integer(D_STAG));
		__directive_code_table.put("Stag",   new Integer(D_STAG));
		__directive_code_table.put("STAG",   new Integer(D_STAG));
		__directive_code_table.put("cont",   new Integer(D_CONT));
		__directive_code_table.put("Cont",   new Integer(D_CONT));
		__directive_code_table.put("CONT",   new Integer(D_CONT));
		__directive_code_table.put("etag",   new Integer(D_ETAG));
		__directive_code_table.put("Etag",   new Integer(D_ETAG));
		__directive_code_table.put("ETAG",   new Integer(D_ETAG));
		__directive_code_table.put("elem",   new Integer(D_ELEM));
		__directive_code_table.put("Elem",   new Integer(D_ELEM));
		__directive_code_table.put("ELEM",   new Integer(D_ELEM));
		__directive_code_table.put("value",  new Integer(D_VALUE));
		__directive_code_table.put("Value",  new Integer(D_VALUE));
		__directive_code_table.put("VALUE",  new Integer(D_VALUE));
		__directive_code_table.put("attr",   new Integer(D_ATTR));
		__directive_code_table.put("Attr",   new Integer(D_ATTR));
		__directive_code_table.put("ATTR",   new Integer(D_ATTR));
		__directive_code_table.put("append", new Integer(D_APPEND));
		__directive_code_table.put("Append", new Integer(D_APPEND));
		__directive_code_table.put("APPEND", new Integer(D_APPEND));
		__directive_code_table.put("replace_element_with_element", new Integer(D_REPLACE1));
		__directive_code_table.put("replace_element_with_content", new Integer(D_REPLACE2));
		__directive_code_table.put("replace_content_with_element", new Integer(D_REPLACE3));
		__directive_code_table.put("replace_content_with_content", new Integer(D_REPLACE4));
		//
		__directive_code_table.put("set",     new Integer(D_SET));
		__directive_code_table.put("if",      new Integer(D_IF));
		__directive_code_table.put("elseif",  new Integer(D_ELSEIF));
		__directive_code_table.put("else",    new Integer(D_ELSE));
		__directive_code_table.put("while",   new Integer(D_WHILE));
		__directive_code_table.put("While",   new Integer(D_WHILE));
		__directive_code_table.put("WHILE",   new Integer(D_WHILE));
		__directive_code_table.put("loop",    new Integer(D_LOOP));
		__directive_code_table.put("Loop",    new Integer(D_LOOP));
		__directive_code_table.put("LOOP",    new Integer(D_LOOP));
		__directive_code_table.put("foreach", new Integer(D_FOREACH));
		__directive_code_table.put("Foreach", new Integer(D_FOREACH));
		__directive_code_table.put("FOREACH", new Integer(D_FOREACH));
		__directive_code_table.put("list",    new Integer(D_LIST));
		__directive_code_table.put("List",    new Integer(D_LIST));
		__directive_code_table.put("LIST",    new Integer(D_LIST));
		__directive_code_table.put("default", new Integer(D_DEFAULT));
		__directive_code_table.put("Default", new Integer(D_DEFAULT));
		__directive_code_table.put("DEFAULT", new Integer(D_DEFAULT));
	}
	
	static int directiveCode(String directive_name) {
		Integer val = (Integer)__directive_code_table.get(directive_name);
		return val == null ? -1 : val.intValue();
	}


	/**
	 * return 0 if 'name', return 1 if 'Name', or return -1 if 'NAME'
	 */
	private int _detectKind(String name) {
		char ch = name.charAt(0);
		if (Character.isLowerCase(ch)) return 0;
		char last_ch = name.charAt(name.length() - 1);
		return Character.isLowerCase(last_ch) ? 1 : -1;
	}


	private void _addBlockStatement(List stmt_list, Ast.BlockStatement block_stmt) {
		Ast.Statement[] stmts = block_stmt.getStatements();
		for (int i = 0, n = stmts.length; i < n; i++)
			stmt_list.add(stmts[i]);
	}
	
	
//	private void _addStatement(List stmt_list, Ast.Statement stmt) {
//		if (stmt.getToken() == Token.BLOCK)
//			_addBlockStatement(stmt_list, (Ast.BlockStatement)stmt);
//		else
//			stmt_list.add(stmt);
//	}
	


	private void _findAndMergeRuleset(ElementInfo elem_info, boolean flag_tagname, boolean flag_classname, boolean flag_idname) {
		Ast.Ruleset ruleset;
		TagInfo stag_info = elem_info.getStagInfo();
		if (flag_tagname) {
			String tagname = stag_info.getTagName();
			if ((ruleset = (Ast.Ruleset)_ruleset_table.get(tagname)) != null)
				elem_info.merge(ruleset);
		}
		AttrInfo attr_info = elem_info.getAttrInfo();
		if (flag_classname) {
			String classname = attr_info.getValueIfString("class");
			if (classname != null && (ruleset = (Ast.Ruleset)_ruleset_table.get("."+classname)) != null)
				elem_info.merge(ruleset);
		}
		if (flag_idname) {
			String idname = attr_info.getValueIfString("id");
			if (idname != null && (ruleset = (Ast.Ruleset)_ruleset_table.get("#"+idname)) != null)
				elem_info.merge(ruleset);
		}
	}


	public void applyRuleset(ElementInfo elem_info, List stmt_list) throws ConvertException {
		_findAndMergeRuleset(elem_info, true, true, true);
		Ast.Statement stmt = expandElementInfo(elem_info, false);
		assert stmt != null;
		//stmt_list.add(stmt);
		assert stmt.getToken() == Token.BLOCK;
		_addBlockStatement(stmt_list, (Ast.BlockStatement)stmt);
	}

		
	public Ast.BlockStatement expandElementInfo(ElementInfo elem_info) throws ConvertException {
		return expandElementInfo(elem_info, false);
	}


	public Ast.BlockStatement expandElementInfo(ElementInfo elem_info, boolean content_only) throws ConvertException {
		// clear stag and etag if content_only is true (= '_content(name)' )
		if (content_only) {
			elem_info = elem_info.duplicate();
			elem_info.clearStag();
			elem_info.clearEtag();
		}
		// before
		Ast.Statement stmt;
		List stmt_list = new ArrayList();
		if (elem_info.getBefore() != null) {
			stmt_list.addAll(elem_info.getBefore());
		}
		// logic
		if (elem_info.getElemExpr() != null) {
			ElementInfo e = elem_info;
			stmt = HandlerHelper.buildPrintStatementForExpression(e.getElemExpr(), e.getStagInfo(), e.getEtagInfo());
			stmt_list.add(stmt);
		}
		else {
			for (Iterator it = elem_info.getLogic().iterator(); it.hasNext(); ) {
				stmt = (Ast.Statement)it.next();
				Ast.Statement stmt2 = _expandStatement(stmt, elem_info);
				stmt_list.add(stmt2 != null ? stmt2 : stmt);
				//_addStatement(stmt_list, stmt2 != null ? stmt2 : stmt);
			}
		}
		// after
		if (elem_info.getAfter() != null) {
			stmt_list.addAll(elem_info.getAfter());
		}
		//
		Ast.BlockStatement block_stmt = new Ast.BlockStatement(stmt_list);   
		return block_stmt;
	}



	/**
	 * expand _stag, _cont, _etag, _elem, _element(), and _content().
	 * 
	 * @return Statement if stmt is one of the _stag, _cont, _etag, _elem, _elemen(), or _content(). Otherwise, Null. 
	 */
	private Ast.Statement _expandStatement(Ast.Statement stmt, ElementInfo elem_info) throws ConvertException {
		//
		int t = stmt.getToken();
		switch (t) {
		case Token.PRINT:
			return null;
		case Token.EXPR:
			return null;
		case Token.IF:
			Ast.IfStatement if_stmt = (Ast.IfStatement)stmt; 
			_expandStatement(if_stmt.getThenStatement(), elem_info);
			if (if_stmt.getElseStatement() != null) {
				_expandStatement(if_stmt.getElseStatement(), elem_info);
			}
			return null;
		case Token.ELSEIF:
		case Token.ELSE:
			assert false; /* unreachable */
			return null;
		case Token.WHILE:
			_expandStatement(((Ast.WhileStatement)stmt).getBodyStatement(), elem_info);
			return null;
		case Token.FOREACH:
			_expandStatement(((Ast.ForeachStatement)stmt).getBodyStatement(), elem_info);
			return null;
		case Token.BREAK:
			return null;
		case Token.CONTINUE:
			return null;
		case Token.BLOCK:
			Ast.Statement[] stmts = ((Ast.BlockStatement)stmt).getStatements();
			for (int i = 0, n = stmts.length; i < n; i++) {
				Ast.Statement st = _expandStatement(stmts[i], elem_info);
				if (st != null) stmts[i] = st;
			}
			return null;
		case Token.NATIVE_STMT:
			return null;
		case Token.NATIVE_EXPR:
			assert false; /* unreachable */
			return null;
		case Token.STAG:
			assert elem_info != null;
			return _expandStagStatement(elem_info);
		case Token.CONT:
			assert elem_info != null;
			return _expandContStatement(elem_info);
		case Token.ETAG:
			assert elem_info != null;
			return _expandEtagStatement(elem_info);
		case Token.ELEM:
			ElementInfo e = elem_info;
			if (e.getElemExpr() != null) {
				return HandlerHelper.buildPrintStatementForExpression(e.getElemExpr(), e.getStagInfo(), e.getEtagInfo());
			}
			else {
				List list = new ArrayList();
				Ast.Statement st;
				st = _expandStagStatement(elem_info);  if (st != null) list.add(st);
				st = _expandContStatement(elem_info);  if (st != null) list.add(st);  //_addStatement(list, st);
				st = _expandEtagStatement(elem_info);  if (st != null) list.add(st);
				return new Ast.BlockStatement(list);
			}
		case Token.ELEMENT:
		case Token.CONTENT:
			String name = ((Ast.ExpandStatement)stmt).getName();
			ElementInfo elem_info2 = (ElementInfo)_elem_info_table.get(name);
			if (elem_info2 == null)
				throw HandlerHelper.convertError("element '"+name+"' is not found.", stmt.getLinenum());
			boolean content_only2 = t == Token.CONTENT;
			return expandElementInfo(elem_info2, content_only2);
		default:
			assert false;
		}
		return null;	
	}
	
	private Ast.Statement _expandStagStatement(ElementInfo e) {
		if (e.getStagExpr() != null)
			return HandlerHelper.buildPrintStatementForExpression(e.getStagExpr(), e.getStagInfo(), null);
		else
			return HandlerHelper.buildPrintStatement(e.getStagInfo(), e.getAttrInfo(), e.getAppendExprs());
	}

	private Ast.Statement _expandEtagStatement(ElementInfo e) {
		if (e.getEtagExpr() != null)
			return HandlerHelper.buildPrintStatementForExpression(e.getEtagExpr(), null, e.getEtagInfo());
		else if (e.getEtagInfo() == null)  // e.getEtagInfo() is null when <br>, <input>, <hr>, <img>, and <meta>
			return HandlerHelper.createPrintStatement("");
		else
			return HandlerHelper.buildPrintStatement(e.getEtagInfo(), null, null);
	}
	
	private Ast.Statement _expandContStatement(ElementInfo e) throws ConvertException {
		if (e.getContExpr() != null) {
			return new Ast.PrintStatement(new Ast.Expression[] { e.getContExpr() });
		}
		else {
			Ast.BlockStatement block_stmt = new Ast.BlockStatement(e.getContStmts());
			_expandStatement(block_stmt, e);
			return block_stmt;
		}
	}
	
	
	public Ast.Statement extract(String elem_name, boolean content_only) throws ConvertException {
		ElementInfo elem_info = (ElementInfo)_elem_info_table.get(elem_name);
		if (elem_info == null) {
			throw HandlerHelper.convertError("element '"+elem_name+"' not found.", elem_info.getStagInfo().getLinenum());
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
		
		pdata = ""
			+ "<ul id=\"mark:menulist\">\n"
			+ " <li>menu1</li>\n"
			+ "</ul>\n"
			+ "<p>...</p>\n"
			+ "<ol id=\"replace_element_with_content:menulist\">\n"
			+ " <li>...</li>\n"
			+ "</ol>\n"
			;
		plogic = ""
			+ "#menulist {\n"
			+ "  logic: {\n"
			//+ "    _stag;\n"
			+ "    foreach (menu = menulist) {\n"
			//+ "      _cont;\n"
			+ "      _elem;\n"
			+ "    }\n"
			//+ "    _etag;\n"
			+ "  }\n"
			+ "}\n"
			;

		pdata = ""
			+ "<ul id=\"mark:menulist\">\n"
		    + "<li id=\"value:menu\">menu1</li>\n"
		    + "</ul>\n"
		    + "<p>...</p>\n"
		    + "<ol id=\"replace_element_with_element:menulist\">\n"
		    + "<li>menu1</li>\n"
		    + "</ol>\n"
		    ;
		plogic = ""
			+ 	"#menulist {\n"
			+	"  logic: {\n"
			+   "    _stag;\n"
			+   "    foreach (menu = menulist) {\n"
			+   "      _cont;\n"
			+   "    }\n"
			+   "   _etag;\n"
			+   "  }\n"
			+   "}\n"
			;

		Parser parser = new PresentationLogicParser();
		List rulesets = (List)parser.parse(plogic);
		Handler handler = new BaseHandler(rulesets, null);
		TextConverter converter = new TextConverter(handler);
		List stmt_list = converter.convert(pdata);
		for (Iterator it = stmt_list.iterator(); it.hasNext(); ) {
			Ast.Statement stmt = (Ast.Statement)it.next();
			System.out.println(stmt.inspect());
		}
		
	}


}
