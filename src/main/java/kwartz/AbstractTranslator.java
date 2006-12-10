/*
 * $Rev$
 * $Release$
 * $Copyright$
 */

package kwartz;

import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.Iterator;


abstract class AbstractTranslator extends Visitor implements Translator {
	
	protected StringBuffer _buf;
	protected String _nl;
	protected boolean _escape;
	
	
	public AbstractTranslator() {
		initialize();
	}
	
	
	public AbstractTranslator(Map properties) {
		initialize();
		if (properties != null)
			setProperties(properties);
	}
	
	
	protected void initialize() {
		_buf    = new StringBuffer();
		_nl     = "\n";
		_escape = false;
	}
		

	public void setProperties(Map properties) {
		if (properties == null)
			return;
		Object val;
		if ((val = properties.get("nl")) != null)
			_nl = val.toString();
		if ((val = properties.get("escape")) != null) {
			if (val.toString().equals("true"))
				_escape = true;
			else if (val.toString().equals("false"))
				_escape = false;
		}
	}

	
	public String translate(List nodes) throws KwartzException {
		for (Iterator it = nodes.iterator(); it.hasNext(); ) {
			Ast.Node node = (Ast.Node)it.next();
			node.accept(this);
		}
		return _buf.toString();
	}

	
//	public String translate(Ast.Statement[] statements) throws KwartzException {
//		for (int i = 0, n = statements.length; i < n; i++) {
//			Ast.Statement statement = statements[i];
//			statement.accept(this);
//		}
//		return _buf.toString();
//	}


	public String translate(Ast.Node node) throws KwartzException {
		node.accept(this);
		return _buf.toString();
	}

	
	////
	//// expand statement
	
	public Object visit(Ast.ExpandStatement stmt) throws KwartzException {
		//assert false;
		throw error("*** internal error: expand statement found..", stmt);
	}

//	public Object visit(Ast.StagStatement stmt) throws KwartzException {
//		return visit((Ast.ExpandStatement)stmt);
//	}
//
//	public Object visit(Ast.ContStatement stmt) throws KwartzException {
//		return visit((Ast.ExpandStatement)stmt);
//	}
//
//	public Object visit(Ast.EtagStatement stmt) throws KwartzException {
//		return visit((Ast.ExpandStatement)stmt);
//	}
//
//	public Object visit(Ast.ElemStatement stmt) throws KwartzException {
//		return visit((Ast.ExpandStatement)stmt);
//	}
//
//	public Object visit(Ast.ElementStatement stmt) throws KwartzException {
//		return visit((Ast.ExpandStatement)stmt);
//	}
//
//	public Object visit(Ast.ContentStatement stmt) throws KwartzException {
//		return visit((Ast.ExpandStatement)stmt);
//	}


	
	//// selector, declaration, ruleset
	
	public Object visit(Ast.Selector selector) throws KwartzException {
		//assert false;
		throw error("*** internal error: selector found.", selector);
	}

	public Object visit(Ast.Declaration declaration) throws KwartzException {
		//assert false;
		throw error("*** internal error: declaration found..", declaration);
	}
	
	public Object visit(Ast.Ruleset ruleset) throws KwartzException {
		//assert false;
		throw error("*** internal error: ruleset found.", ruleset);
	}


	abstract String word(String key);

	abstract String funcname(String fname);
	
	
	////
	public static Map generateTranslationTable() {
		HashMap table = new HashMap();
		table.put("+",    " + ");
		table.put("-",    " - ");
		table.put("*",    " * ");
		table.put("/",    " / ");
		table.put("%",    " % ");
		table.put(".+",   " .+ ");
		
		table.put("+=",   " += ");
		table.put("-=",   " -= ");
		table.put("*=",   " *= ");
		table.put("/=",   " /= ");
		table.put("%=",   " %= ");
		table.put(".+=",  " .+= ");
		table.put("&&=",  " &&= ");
		table.put("||=",  " ||= ");
		
		table.put("&&",   " && ");
		table.put("||",   " || ");
		table.put("!",    "!");
		
		table.put("==",   " == ");
		table.put("!=",   " != ");
		table.put("<",    " < ");
		table.put(">",    " > ");
		table.put("<=",   " <= ");
		table.put(">=",   " >= ");
		
		table.put("[",    "[");
		table.put("]",    "]");
		table.put("(",    "(");
		table.put(")",    ")");
		table.put("?",    " ? ");
		table.put(":",    " : ");
		table.put(".",    ".");
		table.put(",",    ", ");
		
		table.put("true",  "true");
		table.put("false", "false");
		table.put("null",  "null");
		
		table.put("print",       "print(");
		table.put("endprint",    ");");
		table.put("eprint",      "print(escape(");
		table.put("endeprint",   "));");
		table.put("expr",        "");
		table.put("endexpr",     ";");
		table.put("if",          "if (");
		table.put("then",        ") {");
		table.put("elseif",      "} else if (");
		table.put("else",        "} else {");
		table.put("endif",       "}");
		table.put("foreach",     "foreach (");
		table.put("in",          " in ");
		table.put("do",          ") {");
		table.put("endforeach",  "}");
		table.put("while",       "while (");
		table.put("endwhile",    "}");
		table.put("break",       "break");
		table.put("continue",    "continue");
		
		return table;
	}
	
	
	////
	
	
	public Object visit(Ast.Expression expr) throws KwartzException {
		assert false;
		return null;
	}

	public Object visit(Ast.ArithmeticExpression expr) throws KwartzException {
		int token = expr.getToken();
		if (token == Token.UPLUS || token == Token.UMINUS)
			translateUnaryExpression(expr);
		else
			translateBinaryExpression(expr);
		return null;
	}


	public Object visit(Ast.LogicalExpression expr) throws KwartzException {
		int token = expr.getToken();
		if (token == '!')
			translateUnaryExpression(expr);
		else  // '&&','||'
			translateBinaryExpression(expr);
		return null;
	}

	public Object visit(Ast.RelationalExpression expr) throws KwartzException {
		translateBinaryExpression(expr);
		return null;
	}

	public Object visit(Ast.AssignmentExpression expr) throws KwartzException {
		translateBinaryExpression(expr);
		return null;
	}

	public Object visit(Ast.IndexExpression expr) throws KwartzException {
		translateChild(expr, expr.getLeft());
		_buf.append(word("["));
		translateChild(expr, expr.getRight());
		_buf.append(word("]"));
		return null;
	}
	
	public Object visit(Ast.FuncallExpression expr) throws KwartzException {
		String funcname = funcname(expr.getFuncname());
		if (funcname == null)
			funcname = expr.getFuncname();
		_buf.append(funcname);
		translateArguments(expr.getArguments(), true);
		return null;
	}
	
	public Object visit(Ast.MethodExpression expr) throws KwartzException {
		translateChild(expr, expr.getReceiver());
		translateArguments(expr.getArguments(), true);
		return null;
	}
	
	public Object visit(Ast.PropertyExpression expr) throws KwartzException {
		translateChild(expr, expr.getReceiver());
		_buf.append(word(".")).append(expr.getPropertyName());
		return null;
	}

	
	public Object visit(Ast.ConditionalExpression expr) throws KwartzException {
		translateChild(expr, expr.getCondition());
		_buf.append(word("?"));
		translateChild(expr, expr.getLeft());
		_buf.append(word(":"));
		translateChild(expr, expr.getRight());
		return null;
	}

	
	//// literal
	
	public Object visit(Ast.Literal literal) throws KwartzException {
		assert false;
		return null;
	}
	
	
	public Object visit(Ast.VariableLiteral literal) throws KwartzException {
		_buf.append(literal.getValue());
		return null;
	}
	
	public Object visit(Ast.StringLiteral literal) throws KwartzException {
		_buf.append(Util.quote(literal.getValue()));
		return null;
	}
	
	public Object visit(Ast.IntegerLiteral literal) throws KwartzException {
		_buf.append(literal.getValue());
		return null;
	}
	
	public Object visit(Ast.FloatLiteral literal) throws KwartzException {
		_buf.append(literal.getValue());
		return null;
	}
	
	public Object visit(Ast.TrueLiteral literal) throws KwartzException {
		_buf.append(word("true"));
		return null;
	}
	
	public Object visit(Ast.FalseLiteral literal) throws KwartzException {
		_buf.append(word("false"));
		return null;
	}
	
	public Object visit(Ast.NullLiteral literal) throws KwartzException {
		_buf.append(word("null"));
		return null;
	}


	
	public Object visit(Ast.Statement stmt) throws KwartzException {
		assert false;
		return null;
	}
	
	public Object visit(Ast.PrintStatement stmt) throws KwartzException {
		Ast.Expression[] args = stmt.getArguments();
		for (int i = 0, n = args.length; i < n; i++) {
			translatePrintArgument(args[i]);
		}
		return null;
	}

	protected void translatePrintArgument(Ast.Expression arg) throws KwartzException {
		if (arg == null)
			return;
		switch (arg.getToken()) {
		case Token.STRING:
		case Token.INTEGER:
		case Token.FLOAT:
			//arg.accept(this);
			_buf.append(((Ast.Literal)arg).getValue());
			break;
		case Token.CONCAT:
			Ast.BinaryExpression concat_expr = (Ast.BinaryExpression)arg;
			translatePrintArgument(concat_expr.getLeft());
			translatePrintArgument(concat_expr.getRight());
			break;
		case Token.FUNCALL:
			Ast.FuncallExpression funcall = (Ast.FuncallExpression)arg;
			String funcname = funcall.getFuncname();
			if (funcname.equals("E")) {
				_buf.append(word("eprint"));
				funcall.getArguments()[0].accept(this);
				_buf.append(word("endeprint"));
				break;
			}
			else if (funcname.equals("X")) {
				_buf.append(word("print"));
				funcall.getArguments()[0].accept(this);
				_buf.append(word("endprint"));
				break;
			}
			//fall-throught
		default:
			_buf.append(word(_escape ? "eprint" : "print"));
			arg.accept(this);
			_buf.append(word(_escape ? "endeprint" : "endprint"));
		}
	}

	
	
	public Object visit(Ast.ExpressionStatement stmt) throws KwartzException {
		_buf.append(word("expr"));
		stmt.getExpression().accept(this);
		_buf.append(word("endexpr"));
		_buf.append(_nl);
		return null;
	}


	public Object visit(Ast.IfStatement if_stmt) throws KwartzException {
		Ast.Statement else_stmt;
		String key = "if";
		while (true) {
			_buf.append(word(key));
			if_stmt.getCondition().accept(this);
			_buf.append(word("then")).append(_nl);
			if_stmt.getThenStatement().accept(this);
			else_stmt = if_stmt.getElseStatement();
			if (else_stmt == null || else_stmt.getToken() != Token.IF)
				break;
			if_stmt = (Ast.IfStatement)else_stmt;
			key = "elseif";
		}
		if (else_stmt != null) {
			_buf.append(word("else")).append(_nl);
			else_stmt.accept(this);
		}
		_buf.append(word("endif")).append(_nl);
		return null;
	}
	
	public Object visit(Ast.WhileStatement while_stmt) throws KwartzException {
		_buf.append(word("while"));
		while_stmt.getCondition().accept(this);
		_buf.append(word("do")).append(_nl);
		while_stmt.getBodyStatement().accept(this);
		_buf.append(word("endwhile"));
		return null;
	}
	
	public Object visit(Ast.ForeachStatement foreach_stmt) throws KwartzException {
		_buf.append(word("foreach"));
		foreach_stmt.getItemVariable().accept(this);
		_buf.append(word("in"));
		foreach_stmt.getListExpression().accept(this);
		_buf.append(word("do")).append(_nl);
		foreach_stmt.getBodyStatement().accept(this);
		_buf.append(word("endforeach"));
		return null;
	}
	
	public Object visit(Ast.BreakStatement stmt) throws KwartzException {
		_buf.append(word("break"));
		return null;
	}
	
	public Object visit(Ast.ContinueStatement stmt) throws KwartzException {
		_buf.append(word("continue"));
		return null;
	}
	
	public Object visit(Ast.BlockStatement block_stmt) throws KwartzException {
		Ast.Statement[] stmts = block_stmt.getStatements();
		for (int i = 0, n = stmts.length; i < n; i++) {
			stmts[i].accept(this);
		}
		return null;
	}
	
	
	
	////
	
	protected TranslateException error(String message, Ast.Node node) {
		return new TranslateException(message, node.getFilename(), node.getLinenum(), node.getColumn());
	}
	
	protected char lastChar() {
		int len = _buf.length();
		return len > 0 ? _buf.charAt(len-1) : '\0';
	}
	
	protected static int[] __priority_table;
	static {
		__priority_table = new int[Token.ERROR];
		int[] t = __priority_table;
		t['='] = t[Token.PLUS_EQ] = t[Token.MINUS_EQ] = t[Token.STAR_EQ] = t[Token.SLASH_EQ] = t[Token.PERCENT_EQ] = t[Token.CONCAT_EQ] = t[Token.AND_EQ] = t[Token.OR_EQ] = 10;
		t[Token.CONDITIONAL]                 = 20;
		t[Token.OR]                          = 30;
		t[Token.AND]                         = 40;
		t[Token.EQ] = t[Token.NE] = t['<'] = t[Token.LE] = t['>'] = t[Token.GE] = 50;
		t['+'] = t['-'] = t[Token.CONCAT]    = 60;
		t['*'] = t['/'] = t['%']             = 70;
		t['!'] = t[Token.UPLUS] = t[Token.UMINUS] = 80;
		t[Token.INDEX]  = t[Token.INDEX] = t[Token.FUNCALL] = t[Token.METHOD] = t['.'] = 90;
		t[Token.VARIABLE] = t[Token.STRING] = t[Token.INTEGER] = t[Token.FLOAT] = t[Token.TRUE] = t[Token.FALSE] = t[Token.NULL] = 100;   
	}
	
	
	protected int comparePriority(Ast.Expression expr1, Ast.Expression expr2) {
		return __priority_table[expr1.getToken()] - __priority_table[expr2.getToken()];
	}
	

	protected void translateChild(Ast.Expression parent, Ast.Expression child) throws KwartzException {
		if (child != null) {
			if (comparePriority(parent, child) > 0) { // parent is higher than child
				_buf.append('(');
				child.accept(this);
				_buf.append(')');
			}
			else {
				child.accept(this);
			}
		}
	}

	protected void translateRightChild(Ast.Expression parent, Ast.Expression child) throws KwartzException {
		if (child != null) {
			if (comparePriority(parent, child) >= 0) { // parent is higher than or equal to child
				_buf.append('(');
				child.accept(this);
				_buf.append(')');
			}
			else {
				child.accept(this);
			}
		}
	}

	protected void translateUnaryExpression(Ast.BinaryExpression unary) throws KwartzException {
		String key = TokenHelper.tokenSymbol(unary.getToken());
		_buf.append(word(key));
		translateChild(unary, unary.getLeft());
	}
	
	protected void translateBinaryExpression(Ast.BinaryExpression expr) throws KwartzException {
		translateChild(expr, expr.getLeft());
		String key = TokenHelper.tokenSymbol(expr.getToken());
		_buf.append(word(key));
		translateRightChild(expr, expr.getRight());
	}

	protected void translateArguments(Ast.Expression[] args, boolean add_parens) throws KwartzException {
		if (add_parens)
			_buf.append(word("("));
		for (int i = 0, n = args.length; i < n; i++) {
			if (i > 0)
				_buf.append(word(","));
			args[i].accept(this);
		}
		if (add_parens)
			_buf.append(word(")"));
	}
	
	
//	protected Ast.Statement convertConditionalAssignmentToIfStatement(Ast.ExpressionStatement stmt) {
//		Ast.Expression expr = stmt.getExpression();
//		if (! (expr instanceof Ast.AssignmentExpression))
//			return stmt;
//		Ast.AssignmentExpression assign = (Ast.AssignmentExpression)expr;
//		if (assign.getRight().getToken() != Token.CONDITIONAL)
//			return stmt;
//		return _convertConditionalAssignmentToIfStatement(assign.getToken(), assign.getLeft(), assign.getRight());
//	}
	
	protected Ast.Statement convertConditionalAssignmentToIfStatement(int assign_token, Ast.Expression lhs, Ast.Expression rhs) {
		if (rhs.getToken() == Token.CONDITIONAL) {
			Ast.ConditionalExpression cond_expr = (Ast.ConditionalExpression)rhs;
			Ast.Expression condition = cond_expr.getCondition();
			Ast.Statement then_stmt, else_stmt;
			then_stmt = convertConditionalAssignmentToIfStatement(assign_token, lhs, cond_expr.getLeft());
			else_stmt = convertConditionalAssignmentToIfStatement(assign_token, lhs, cond_expr.getRight());
			Ast.BlockStatement then_block = new Ast.BlockStatement(then_stmt);
			if (else_stmt.getToken() != Token.IF) else_stmt = new Ast.BlockStatement(else_stmt);
			Ast.IfStatement if_stmt = new Ast.IfStatement(condition, then_block, else_stmt);
			return if_stmt;
		}
		else {
			return new Ast.ExpressionStatement(new Ast.AssignmentExpression(assign_token, lhs, rhs));
		}
	}

}
