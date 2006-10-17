package kwartz;

import java.util.List;

public class NodeFactory {

	private String _filename;
	
	public NodeFactory(String filename) {
		_filename = filename;
	}
	
	public NodeFactory() {
		_filename = null;
	}
	
	public String getFilename() {
		return _filename;
	}
	
	public void setFilename(String name) {
		_filename = name;
	}
	
	
	private void setInfo(Ast.Node node, ParseInfo info) {
		node.setLinenum(info.getLinenum());
		node.setColumn(info.getColumn());
		node.setFilename(_filename);
	}
	
	public Ast.Expression createArithmeticExpression(ParseInfo info, Ast.Expression left, Ast.Expression right) {
		Ast.Expression expr = new Ast.ArithmeticExpression(info.getToken(), left, right);
		setInfo(expr, info);
		return expr;
	}
	
	public Ast.Expression createUnaryExpression(ParseInfo info, Ast.Expression primary) {
		int token = info.getToken();
		token = token == '-' ? Token.UMINUS : Token.UPLUS;
		Ast.Expression expr = new Ast.ArithmeticExpression(token, primary, null);
		setInfo(expr, info);
		return expr;
	}

	public Ast.Expression createLogicalExpression(ParseInfo info, Ast.Expression left, Ast.Expression right) {
		Ast.Expression expr = new Ast.LogicalExpression(info.getToken(), left, right);
		setInfo(expr, info);
		return expr;
	}

	public Ast.Expression createRelationalExpression(ParseInfo info, Ast.Expression left, Ast.Expression right) {
		Ast.Expression expr = new Ast.RelationalExpression(info.getToken(), left, right);
		setInfo(expr, info);
		return expr;
	}

	public Ast.Expression createAssignmentExpression(ParseInfo info, Ast.Expression left, Ast.Expression right) throws ParseException {
		Ast.Expression expr = new Ast.AssignmentExpression(info.getToken(), left, right);
		setInfo(expr, info);
		expr.validate();
		return expr;
	}
	
	public Ast.Expression createIndexExpression(ParseInfo info, Ast.Expression primary, Ast.Expression arg) {
		Ast.Expression expr = new Ast.IndexExpression(Token.INDEX, primary, arg);
		setInfo(expr, info);
		return expr;
	}
	
	public Ast.Expression createIndex2Expression(ParseInfo info, Ast.Expression primary, Ast.Literal word) {
		Ast.Expression expr = new Ast.IndexExpression(Token.INDEX2, primary, word);
		setInfo(expr, info);
		return expr;
	}
	
	
	public Ast.Expression createFuncallExpression(ParseInfo info, List arguments) {
		Ast.Expression[] args = new Ast.Expression[arguments.size()];
		arguments.toArray(args);
		String funcname = info.getValue();
		Ast.Expression expr = new Ast.FuncallExpression(funcname, args);
		setInfo(expr, info);
		return expr;
	}
	
	public Ast.Expression createMethodExpression(ParseInfo info, Ast.Expression receiver, String methodname, List arguments) {
		Ast.Expression[] args = new Ast.Expression[arguments.size()];
		arguments.toArray(args);
		Ast.Expression expr = new Ast.MethodExpression(receiver, methodname, args);
		setInfo(expr, info);
		return expr;
	}
	
	public Ast.Expression createPropertyExpression(ParseInfo info, Ast.Expression receiver, String property_name) {
		Ast.Expression expr = new Ast.PropertyExpression(receiver, property_name);
		setInfo(expr, info);
		return expr;
	}
	
	public Ast.Expression createConditionalExpression(ParseInfo info, Ast.Expression condition, Ast.Expression left, Ast.Expression right) {
		Ast.Expression expr = new Ast.ConditionalExpression(condition, left, right);
		setInfo(expr, info);
		return expr;
	}
	
	//
	
	public Ast.Literal createVariableLiteral(ParseInfo info) {
		Ast.Literal literal = new Ast.VariableLiteral(info.getValue());
		setInfo(literal, info);
		return literal;
	}
	
	public Ast.Literal createStringLiteral(ParseInfo info) {
		Ast.Literal literal = new Ast.StringLiteral(info.getValue());
		setInfo(literal, info);
		return literal;
	}
	
	public Ast.Literal createIntegerLiteral(ParseInfo info) {
		Ast.Literal literal = new Ast.IntegerLiteral(info.getValue());
		setInfo(literal, info);
		return literal;
	}
	
	public Ast.Literal createFloatLiteral(ParseInfo info) {
		Ast.Literal literal = new Ast.FloatLiteral(info.getValue());
		setInfo(literal, info);
		return literal;
	}
	
	public Ast.Literal createTrueLiteral(ParseInfo info) {
		Ast.Literal literal = new Ast.TrueLiteral(info.getValue());
		setInfo(literal, info);
		return literal;
	}

	public Ast.Literal createFalseLiteral(ParseInfo info) {
		Ast.Literal literal = new Ast.FalseLiteral(info.getValue());
		setInfo(literal, info);
		return literal;
	}

	public Ast.Literal createNullLiteral(ParseInfo info) {
		Ast.Literal literal = new Ast.NullLiteral(info.getValue());
		setInfo(literal, info);
		return literal;
	}

	//
	
	public Ast.Statement createPrintStatement(ParseInfo info, List arguments) {
		Ast.Expression[] args = new Ast.Expression[arguments.size()];
		arguments.toArray(args);
		Ast.Statement stmt = new Ast.PrintStatement(args);
		setInfo(stmt, info);
		return stmt;
	}
	
	public Ast.Statement createForeachStatement(ParseInfo info, Ast.Expression item, Ast.Expression list, Ast.Statement body) throws ParseException {
		if (item.getToken() != Token.VARIABLE) {
			String s = TokenHelper.tokenSymbol(item.getToken());
			String mesg = s + ": invalid loop-variable of foreach statement.";
			throw new SemanticException(mesg, _filename, item.getLinenum(), item.getColumn());
		}
		Ast.Statement stmt = new Ast.ForeachStatement((Ast.VariableLiteral)item, list, body);
		setInfo(stmt, info);
		stmt.validate();
		return stmt;
	}

	public Ast.Statement createWhileStatement(ParseInfo info, Ast.Expression condition, Ast.Statement body) {
		Ast.Statement stmt = new Ast.WhileStatement(condition, body);
		setInfo(stmt, info);
		return stmt;
	}
	
	public Ast.Statement createIfStatement(ParseInfo info, Ast.Expression condition, Ast.Statement then_stmt, Ast.Statement else_stmt) {
		Ast.Statement stmt = new Ast.IfStatement(condition, then_stmt, else_stmt);
		setInfo(stmt, info);
		return stmt;
	}
	
	public Ast.Statement createBreakStatement(ParseInfo info) {
		Ast.Statement stmt = new Ast.BreakStatement();
		setInfo(stmt, info);
		return stmt;
	}
	
	public Ast.Statement createContinueStatement(ParseInfo info) {
		Ast.Statement stmt = new Ast.ContinueStatement();
		setInfo(stmt, info);
		return stmt;
	}
	
	public Ast.Statement createExpressionStatement(ParseInfo info, Ast.Expression expr) {
		Ast.Statement stmt = new Ast.ExpressionStatement(expr);
		setInfo(stmt, info);
		return stmt;
	}
	
	public Ast.Statement createBlockStatement(ParseInfo info, List statements) {
		Ast.Statement stmt = new Ast.BlockStatement(statements);
		setInfo(stmt, info);
		return stmt;
	}

	//
	
	public Ast.Statement createStagStatement(ParseInfo info) {
		Ast.Statement stmt = new Ast.StagStatement();
		setInfo(stmt, info);
		return stmt;
	}

	public Ast.Statement createContStatement(ParseInfo info) {
		Ast.Statement stmt = new Ast.ContStatement();
		setInfo(stmt, info);
		return stmt;
	}
	
	public Ast.Statement createEtagStatement(ParseInfo info) {
		Ast.Statement stmt = new Ast.EtagStatement();
		setInfo(stmt, info);
		return stmt;
	}

	public Ast.Statement createElemStatement(ParseInfo info) {
		Ast.Statement stmt = new Ast.ElemStatement();
		setInfo(stmt, info);
		return stmt;
	}

	public Ast.Statement createElementStatement(ParseInfo info, ParseInfo arg) {
		Ast.Statement stmt = new Ast.ElementStatement(arg.getValue());
		setInfo(stmt, info);
		return stmt;
	}

	public Ast.Statement createContentStatement(ParseInfo info, ParseInfo arg) {
		Ast.Statement stmt = new Ast.ContentStatement(arg.getValue());
		setInfo(stmt, info);
		return stmt;
	}

	//
	
	public Ast.Selector createSelector(ParseInfo info) {
		Ast.Selector selector = new Ast.Selector(info.getValue());
		setInfo(selector, info);
		return selector;
	}
	
	public Ast.Declaration createDeclaration(ParseInfo info, Object arg) {
		String propname = info.getValue();
		Ast.Declaration decl = new Ast.Declaration(info.getToken(), propname, arg);
		setInfo(decl, info);
		return decl;
	}
	
	public Ast.Declaration createLogicDeclaration(ParseInfo info, List stmts, ParseInfo rcurly) throws ParseException {
		if (info.getColumn() != rcurly.getColumn() && info.getLinenum() != rcurly.getLinenum()) {
			String msg = "'}': column of closing curly bracket is not matched with of property '"+info.getValue()+"'"
	                   + " starting at line "+info.getLinenum()+", column "+info.getColumn()+".";
			throw new SyntaxException(msg, _filename, rcurly.getLinenum(), rcurly.getColumn());
		}
		String propname = info.getValue();
		Ast.Declaration decl = new Ast.Declaration(info.getToken(), propname, stmts);
		setInfo(decl, info);
		return decl;
	}
	
	public Ast.Ruleset createRuleset(ParseInfo info, List selectors, List declarations, ParseInfo rcurly) throws ParseException {
		Ast.Selector selector = (Ast.Selector)selectors.get(0);
		if (selector.getColumn() != rcurly.getColumn() && selector.getLinenum() != rcurly.getLinenum()) {
			String msg = "'}': column of closing curly bracket is not matched with of selector '"+selector.getValue()+"'"
			           + " starting at line "+selector.getLinenum()+", column "+selector.getColumn()+".";
			throw new SyntaxException(msg, _filename, rcurly.getLinenum(), rcurly.getColumn());
		}		
		Ast.Ruleset ruleset = new Ast.Ruleset(selectors, declarations);
		setInfo(ruleset, info);
		return ruleset;
	}
	
}
