/*
 * $Rev$
 * $Release$
 * $Copyright$
 */
package kwartz;

import java.util.IdentityHashMap;
import java.util.List;
import java.util.Map;
import java.util.HashMap;



public class JstlTranslator extends AbstractTranslator {
	
	static String JSTL11 = "1.1";
	static String JSTL10 = "1.0";
	
	private String _jstl = JSTL11;
	private boolean _loopctr = false;   // detect loop counter
	private Map _word_table = __jstl11_translation_table;
	private Map _varstatus_stmt_table;
	
	
	public JstlTranslator() {
		this(null);
	}
	
	public JstlTranslator(Map properties) {
		initialize();
		if (properties != null)
			setProperties(properties);
	}
	
	
	protected void initialize() {
		super.initialize();
		_escape = true;
	}
	
	
	public void setProperties(Map properties) {
		if (properties == null)
			return;
		super.setProperties(properties);
		Object val;
		if ((val = properties.get("jstl")) != null) {
			if (JSTL11.equals(val.toString())) {
				_jstl = JSTL11;
				_word_table = __jstl11_translation_table;
			}
			else if (JSTL10.equals(val.toString())) {
				_jstl = JSTL10;
				_word_table = __jstl10_translation_table;
			}
		}
		if ((val = properties.get("loopctr")) != null && val.toString().equals("true")) {
			_loopctr = true;
		}
	}

	
	protected static Map __jstl10_translation_table, __jstl11_translation_table;
	static {
		__jstl10_translation_table = AbstractTranslator.generateTranslationTable();
		Map t = __jstl10_translation_table;
		t.put("&&", " and ");
		t.put("||", " or ");
		t.put("!",  "not ");
		t.put("/",  " div ");
		t.put("%",  " mod ");
		t.put("==", " eq ");
		t.put("!=", " ne ");
		t.put("<",  " lt ");
		t.put(">",  " gt ");
		t.put("<=", " le ");
		t.put(">=", " ge ");
		t.put(".+", "}${");
		t.put("print",      "<c:out value=\"${");
		t.put("endprint",   "}\" escapeXml=\"false\"/>");
		t.put("eprint",     "<c:out value=\"${");
		t.put("endeprint",  "}\"/>");
		t.put("if",         "<c:if test=\"${");
		t.put("then",       "}\">");
		t.put("else",       null);
		t.put("endif",      "</c:if>");
		t.put("foreach",    "<c:forEach var=\"");
		t.put("in",         "\" items=\"${");
		t.put("do",         "}\">");
		t.put("endforeach", "</c:forEach>");
		t.put("while",      null);
		t.put("endwhile",   null);
		t.put("expr",       null);
		t.put("endexpr",    null);
		
		__jstl11_translation_table = Util.copy(__jstl10_translation_table);
		t = __jstl11_translation_table;
		t.put("eprint", "${");
		t.put("endeprint", "}");
	}
	
	
	protected String word(String key) {
		return (String)_word_table.get(key);
	}

	
	////
	
	public Object visit(Ast.AssignmentExpression expr) throws KwartzException {
		throw error("assignment is available only as independent statement in JSTL.", expr);
	}

	public Object visit(Ast.IndexExpression expr) throws KwartzException {
		translateChild(expr, expr.getLeft());
		if (expr.getToken() == Token.INDEX2) {
			_buf.append(".");
			_buf.append(((Ast.StringLiteral)expr.getRight()).getValue());
		} else {
			_buf.append(word("["));
			translateChild(expr, expr.getRight());
			_buf.append(word("]"));
		}
		return null;
	}

	
	public Object visit(Ast.FuncallExpression expr) throws KwartzException {
		String jstl_funcname = funcname(expr.getFuncname());
		if (jstl_funcname == null)
			throw error(expr.getFuncname() + "(): this function is not available in JSTL.", expr);
		super.visit(expr);
		return null;
	}
	
	
	protected static Map __funcname_table;
	static {
		__funcname_table = new HashMap();
		__funcname_table.put("escape_xml",    "fn:escapeXml");
		__funcname_table.put("escape_url",    null);
		__funcname_table.put("escape_sql",    null);
		__funcname_table.put("str_length",    "fn:length");
		__funcname_table.put("str_index",     "fn:index");
		__funcname_table.put("str_linebreak", null);
		__funcname_table.put("str_replace",   "fn:replace");
		__funcname_table.put("str_tolower",   "fn:toLowerCase");
		__funcname_table.put("str_toupper",   "fn:toUpperCase");
		__funcname_table.put("str_trim",      "fn:trim");
		__funcname_table.put("str_empty",     "empty");
		__funcname_table.put("list_new",      null);
		__funcname_table.put("list_length",   "fn:length");
		__funcname_table.put("list_empty",    "empty");
		__funcname_table.put("list_add",      null);
		__funcname_table.put("hash_new",      null);
		__funcname_table.put("list_length",   "fn:length");
		__funcname_table.put("hash_empty",    "empty");
		__funcname_table.put("hash_keys",     null);
	}
	
	
	protected String funcname(String funcname) {
		return (String)__funcname_table.get(funcname);
	}

	
	public Object visit(Ast.MethodExpression expr) throws KwartzException {
		throw error(expr.getMethodName() + "(): method call is not available in JSTL.", expr);
	}


	
	public Object visit(Ast.ConditionalExpression expr) throws KwartzException {
		if (_jstl == JSTL10)
			throw error("conditional operator is not available in JSTL 1.1.", expr);
		super.visit(expr);
		return null;
	}


	//// statement
	
	protected void translatePrintArgument(Ast.Expression arg) throws KwartzException {
		if (_jstl == JSTL10 && arg.getToken() == Token.CONDITIONAL) {
			Ast.ConditionalExpression cond_expr = (Ast.ConditionalExpression)arg;
			_buf.append("<c:choose><c:when test=\"${");
			cond_expr.getCondition().accept(this);
			_buf.append("}\">");
			translatePrintArgument(cond_expr.getLeft());
			_buf.append("</c:when><c:otherwise>");
			translatePrintArgument(cond_expr.getRight());
			_buf.append("</c:otherwise></c:choose>");
		}
		else {
			super.translatePrintArgument(arg);
		}
	}
	
	public Object visit(Ast.ExpressionStatement stmt) throws KwartzException {
		Ast.Expression expr = stmt.getExpression();
		if (! (expr instanceof Ast.AssignmentExpression))
			throw error("only assignment expression can be translated into JSTL.", expr);
		Ast.AssignmentExpression assign = (Ast.AssignmentExpression)expr;
		if (_jstl == JSTL10 && assign.getRight().getToken() == Token.CONDITIONAL) { 
			Ast.Statement if_stmt = convertConditionalAssignmentToIfStatement(assign.getToken(), assign.getLeft(), assign.getRight());
			if_stmt.accept(this);
		}
		else {
			int token = assign.getToken();
			Ast.Expression left  = assign.getLeft();
			Ast.Expression right = assign.getRight();
			if (token == '=')
				_translateAssignmentExpr(left, right);
			else if (token == Token.PLUS_EQ)
				_translateAssignmentExpr(left, new Ast.ArithmeticExpression('+', left, right));
			else if (token == Token.MINUS_EQ)
				_translateAssignmentExpr(left, new Ast.ArithmeticExpression('-', left, right));
			else if (token == Token.STAR_EQ)
				_translateAssignmentExpr(left, new Ast.ArithmeticExpression('*', left, right));
			else if (token == Token.SLASH_EQ)
				_translateAssignmentExpr(left, new Ast.ArithmeticExpression('/', left, right));
			else if (token == Token.PERCENT_EQ)
				_translateAssignmentExpr(left, new Ast.ArithmeticExpression('%', left, right));
			else if (token == Token.CONCAT_EQ)
				_translateAssignmentExpr(left, new Ast.ArithmeticExpression(Token.CONCAT, left, right));
			else if (token == Token.AND_EQ)
				_translateAssignmentExpr(left, new Ast.LogicalExpression(Token.AND, left, right));
			else if (token == Token.OR_EQ)
				_translateAssignmentExpr(left, new Ast.LogicalExpression(Token.OR, left, right));
			else
				assert false;
		}
		return null;
	}


	private void _translateAssignmentExpr(Ast.Expression left, Ast.Expression right) throws KwartzException {
		assert left.availableAsLhs();
		int l_token = left.getToken();
		if (l_token == Token.VARIABLE) {
			_appendSetTag(left, null, right);
		}
		else if (l_token == Token.PROPERTY) {
			Ast.PropertyExpression prop_expr = (Ast.PropertyExpression)left; 
			Ast.Expression receiver = prop_expr.getReceiver();
			if (receiver.getToken() != Token.VARIABLE) 
				throw error("expression is too complex to translate into JSTL.", prop_expr);
			_appendSetTag(receiver, prop_expr.getPropertyName(), right);
		}
		else if (l_token == Token.INDEX || l_token == Token.INDEX2) {
			Ast.IndexExpression index_expr = (Ast.IndexExpression)left;
			if (index_expr.getLeft().getToken() != Token.VARIABLE) 
				throw error("expression is too complex to translate into JSTL.", index_expr);
			if (index_expr.getRight().getToken() != Token.STRING)
				throw error("only string key is available as index in JSTL.", index_expr);
			String key = ((Ast.StringLiteral)index_expr.getRight()).getValue();
			_appendSetTag(index_expr.getLeft(), key, right);
		}
		else {
			assert false;  // unreachable
		}
	}
	
	
	private void _appendSetTag(Ast.Expression variable, String property, Ast.Expression expr) throws KwartzException {
		assert variable.getToken() == Token.VARIABLE;
		_buf.append("<c:set var=\"");
		variable.accept(this);
		_buf.append("\"");
		if (property != null) {
			_buf.append(" property=\"").append(property).append("\"");
		}
		_buf.append(" value=\"${");
		expr.accept(this);
		_buf.append("}\"/>").append(_nl);
	}
	
	public Object visit(Ast.IfStatement if_stmt) throws KwartzException {
		Ast.Statement then_stmt = if_stmt.getThenStatement();
		Ast.Statement else_stmt = if_stmt.getElseStatement();
		if (else_stmt == null) {
			super.visit(if_stmt);
			return null;
		}
		_buf.append("<c:choose>");
		while (true) {
			_buf.append("<c:when test=\"${");
			if_stmt.getCondition().accept(this);
			_buf.append("}\">").append(_nl);
			then_stmt.accept(this);
			_buf.append("</c:when>");
			if (else_stmt == null || else_stmt.getToken() != Token.IF)
				break;
			if_stmt = (Ast.IfStatement)else_stmt;
			then_stmt = if_stmt.getThenStatement();
			else_stmt = if_stmt.getElseStatement();
		}
		if (else_stmt != null) {
			_buf.append("<c:otherwise>").append(_nl);
			else_stmt.accept(this);
			_buf.append("</c:otherwise>");
		}
		_buf.append("</c:choose>").append(_nl);
		return null;
	}

	public Object visit(Ast.WhileStatement while_stmt) throws KwartzException {
		throw error("while statement is not available in JSTL.", while_stmt);
	}

	public Object visit(Ast.ForeachStatement foreach_stmt) throws KwartzException {
		String item_name = foreach_stmt.getItemVariable().getValue();
		_buf.append(word("foreach")).append(item_name).append(word("in"));
		foreach_stmt.getListExpression().accept(this);
		if (_loopctr && _varstatus_stmt_table != null && _varstatus_stmt_table.containsKey(foreach_stmt)) {
			String loopvar = item_name + "_loop";
			_buf.append("}\" varStatus=\"").append(loopvar).append("\">").append(_nl);
		}
		else {
			_buf.append(word("do")).append(_nl);
		}
		foreach_stmt.getBodyStatement().accept(this);
		_buf.append(word("endforeach")).append(_nl);
		return null;
	}

	public Object visit(Ast.BreakStatement stmt) throws KwartzException {
		throw error("break statement is not available in JSTL.", stmt);
	}

	public Object visit(Ast.ContinueStatement stmt) throws KwartzException {
		throw error("continue statement is not available in JSTL.", stmt);
	}

	public Object visit(Ast.BlockStatement block_stmt) throws KwartzException {
		Ast.Statement[] stmts = block_stmt.getStatements();
		_translateStatements(stmts);
		return null;
	}

	public String translate(List stmt_list) throws KwartzException {
		Ast.Statement[] stmts = new Ast.Statement[stmt_list.size()];
		stmt_list.toArray(stmts);
		_translateStatements(stmts);
		return _buf.toString();
	}


	private void _translateStatements(Ast.Statement[] stmts) throws KwartzException {
		if (_loopctr) {
			/// find foreach-stmt and counter-increment
			for (int i = 0, n = stmts.length, m = 0; i < n; i++) {
				if (stmts[i].getToken() != Token.FOREACH)
					continue;
				Ast.ForeachStatement foreach_stmt = (Ast.ForeachStatement)stmts[i];
				Ast.Statement first_stmt = _firstStatement(foreach_stmt.getBodyStatement());
				if (first_stmt == null || ! _isIncrement(first_stmt))
					continue;
				String counter = _assignVarname(first_stmt);
				for (int j = i; j >= m; j--) {
					boolean init_ctr = _isZeroAssignment(stmts[j]) && _assignVarname(stmts[j]).equals(counter); 
					if (! init_ctr)
						continue;
					// 'counter = 0;' => 'print();'
					stmts[j] = new Ast.PrintStatement(new Ast.Expression[] {});
					// 'counter += 1;' => 'counter = item_loop.count;'
					String itemvar = foreach_stmt.getItemVariable().getValue();
					Ast.Statement count_stmt = null;
					try {
						String s = ""+counter+"="+itemvar+"_loop.count;";
						count_stmt = (Ast.Statement)((List)new StatementParser().parse(s)).get(0);
					}
					catch (ParseException neverthrown) {
						assert false;
					}
					((Ast.BlockStatement)foreach_stmt.getBodyStatement()).setStatement(count_stmt, 0);
					// '<c:forEach>' => '<c:forEach varStatus="...">'
					if (_varstatus_stmt_table == null)
						_varstatus_stmt_table = new IdentityHashMap();
					_varstatus_stmt_table.put(foreach_stmt, Boolean.TRUE);
				}
				m = i + 1;
			}
		}
		for (int i = 0, n = stmts.length; i < n; i++) {
			stmts[i].accept(this);
		}
	}
	
	
	private Ast.Statement _firstStatement(Ast.Statement block_stmt) {
		if (block_stmt.getToken() != Token.BLOCK)
			return block_stmt;
		Ast.Statement[] stmts = ((Ast.BlockStatement)block_stmt).getStatements();
		return stmts.length > 0 ? stmts[0] : null;
	}
	
	private String _assignVarname(Ast.Expression expr) {
		return ((Ast.VariableLiteral)((Ast.AssignmentExpression)expr).getLeft()).getValue();
	}

	private String _assignVarname(Ast.Statement stmt) {
		return _assignVarname(((Ast.ExpressionStatement)stmt).getExpression());
	}

	private boolean _isZeroAssignment(Ast.Statement stmt) {
		if (stmt.getToken() != Token.EXPR) return false;
		Ast.Expression expr = ((Ast.ExpressionStatement)stmt).getExpression();
		return _detectAssignment(expr, (int)'=', "0");
	}
			
	private boolean _isIncrement(Ast.Statement stmt) {
		if (stmt == null) return false;
		if (stmt.getToken() != Token.EXPR) return false;
		Ast.Expression expr = ((Ast.ExpressionStatement)stmt).getExpression();
		return _detectAssignment(expr, Token.PLUS_EQ, "1");
	}
	
	private boolean _detectAssignment(Ast.Expression expr, int token, String valstr) {
		if (expr.getToken() != token) return false;
		Ast.AssignmentExpression assign = (Ast.AssignmentExpression)expr;
		if (assign.getLeft().getToken() != Token.VARIABLE) return false;
		if (assign.getRight().getToken() != Token.INTEGER) return false;
		Ast.IntegerLiteral intexpr = (Ast.IntegerLiteral)assign.getRight();
		return intexpr.getValue().equals(valstr);
	}

	
	public static void main(String[] args) throws Exception {
		String pdata, plogic;
		pdata = ""
			+ "<table>\n"
			+ " <tr id=\"mark:list\">\n"
			+ "  <td id=\"mark:item\">foo</td>\n"
			+ " </tr>\n"
			+ "</table>\n"
			+ "<input type=\"checkbox\" id=\"chk\">\n"
			;
		plogic = ""
			+ "#list {\n"
			+ "  attrs: 'bgcolor' color;\n"
			+ "  logic: {\n"
			+ "    i = 0;\n"
			+ "    foreach (item in list) {\n"
			+ "      i += 1;\n"
			+ "      color = i % 2 == 0 ? '#FCC' : '#CCF';\n"
			+ "      _elem;\n"
			+ "    }\n"
			+ "  }\n"
			+ "}\n"
			+ "#item {\n"
			+ "  value: '/' .+ item .+ '.html';\n"
			+ "}\n"
			+ "#chk {\n"
			+ "  append: checked ? ' checked=\"checked\"' : '';\n"
			+ "}\n"
			;
		Map properties = new HashMap();
		properties.put("jstl", "1.0");
		properties.put("varstatus", Boolean.TRUE);
		PresentationLogicParser parser = new PresentationLogicParser();
		List rulesets = (List)parser.parse(plogic);
		Handler handler = new BaseHandler(rulesets, properties);
		Converter converter = new TextConverter(handler, properties);
		List stmts = converter.convert(pdata);
		for (java.util.Iterator it = stmts.iterator(); it.hasNext(); ) {
			Ast.Statement stmt = (Ast.Statement)it.next();
			System.out.println(stmt.inspect());
		}
		Translator translator = new JstlTranslator(properties);
		String result = translator.translate(stmts);
		System.out.println(result);
	}

}
