package kwartz;

import java.util.List;

public class NodeFactory {

	
	private void setInfo(Ast.Node node, Parser.Info info) {
		node.setLinenum(info.getLinenum());
		node.setColumn(info.getColumn());
	}
	
	public Ast.Expression createArithmeticExpression(Parser.Info info, Ast.Expression left, Ast.Expression right) {
		Ast.Expression expr = new Ast.ArithmeticExpression(info.getToken(), left, right);
		setInfo(expr, info);
		return expr;
	}
	
	public Ast.Expression createUnaryExpression(Parser.Info info, Ast.Expression primary) {
		int token = info.getToken();
		token = token == '-' ? Token.UMINUS : Token.UPLUS;
		Ast.Expression expr = new Ast.ArithmeticExpression(token, primary, null);
		setInfo(expr, info);
		return expr;
	}

	public Ast.Expression createLogicalExpression(Parser.Info info, Ast.Expression left, Ast.Expression right) {
		Ast.Expression expr = new Ast.LogicalExpression(info.getToken(), left, right);
		setInfo(expr, info);
		return expr;
	}

	public Ast.Expression createRelationalExpression(Parser.Info info, Ast.Expression left, Ast.Expression right) {
		Ast.Expression expr = new Ast.RelationalExpression(info.getToken(), left, right);
		setInfo(expr, info);
		return expr;
	}

	public Ast.Expression createAssignmentExpression(Parser.Info info, Ast.Expression left, Ast.Expression right) throws ParseException {
		Ast.Expression expr = new Ast.AssignmentExpression(info.getToken(), left, right);
		setInfo(expr, info);
		expr.validate();
		return expr;
	}
	
	public Ast.Expression createIndexExpression(Parser.Info info, Ast.Expression primary, Ast.Expression arg) {
		Ast.Expression expr = new Ast.IndexExpression(Token.INDEX, primary, arg);
		setInfo(expr, info);
		return expr;
	}
	
	public Ast.Expression createIndex2Expression(Parser.Info info, Ast.Expression primary, Ast.Literal word) {
		Ast.Expression expr = new Ast.IndexExpression(Token.INDEX2, primary, word);
		setInfo(expr, info);
		return expr;
	}
	
	
	public Ast.Expression createFuncallExpression(Parser.Info info, List arguments) {
		Ast.Expression[] args = new Ast.Expression[arguments.size()];
		arguments.toArray(args);
		String funcname = info.getValue();
		Ast.Expression expr = new Ast.FuncallExpression(funcname, args);
		setInfo(expr, info);
		return expr;
	}
	
	public Ast.Expression createMethodExpression(Parser.Info info, Ast.Expression receiver, String methodname, List arguments) {
		Ast.Expression[] args = new Ast.Expression[arguments.size()];
		arguments.toArray(args);
		Ast.Expression expr = new Ast.MethodExpression(receiver, methodname, args);
		setInfo(expr, info);
		return expr;
	}
	
	public Ast.Expression createPropertyExpression(Parser.Info info, Ast.Expression receiver, String property_name) {
		Ast.Expression expr = new Ast.PropertyExpression(receiver, property_name);
		setInfo(expr, info);
		return expr;
	}
	
	public Ast.Expression createConditionalExpression(Parser.Info info, Ast.Expression condition, Ast.Expression left, Ast.Expression right) {
		Ast.Expression expr = new Ast.ConditionalExpression(condition, left, right);
		setInfo(expr, info);
		return expr;
	}
	
	//
	
	public Ast.Literal createVariableLiteral(Parser.Info info) {
		Ast.Literal literal = new Ast.VariableLiteral(info.getValue());
		setInfo(literal, info);
		return literal;
	}
	
	public Ast.Literal createStringLiteral(Parser.Info info) {
		Ast.Literal literal = new Ast.StringLiteral(info.getValue());
		setInfo(literal, info);
		return literal;
	}
	
	public Ast.Literal createIntegerLiteral(Parser.Info info) {
		Ast.Literal literal = new Ast.IntegerLiteral(info.getValue());
		setInfo(literal, info);
		return literal;
	}
	
	public Ast.Literal createFloatLiteral(Parser.Info info) {
		Ast.Literal literal = new Ast.FloatLiteral(info.getValue());
		setInfo(literal, info);
		return literal;
	}
	
	public Ast.Literal createTrueLiteral(Parser.Info info) {
		Ast.Literal literal = new Ast.TrueLiteral(info.getValue());
		setInfo(literal, info);
		return literal;
	}

	public Ast.Literal createFalseLiteral(Parser.Info info) {
		Ast.Literal literal = new Ast.FalseLiteral(info.getValue());
		setInfo(literal, info);
		return literal;
	}

	public Ast.Literal createNullLiteral(Parser.Info info) {
		Ast.Literal literal = new Ast.NullLiteral(info.getValue());
		setInfo(literal, info);
		return literal;
	}

	//
	
	public Ast.Statement createPrintStatement(Parser.Info info, List arguments) {
		Ast.Expression[] args = new Ast.Expression[arguments.size()];
		arguments.toArray(args);
		Ast.Statement stmt = new Ast.PrintStatement(args);
		setInfo(stmt, info);
		return stmt;
	}
	
	public Ast.Statement createForeachStatement(Parser.Info info, Ast.Expression item, Ast.Expression list, Ast.Statement body) throws ParseException {
		Ast.Statement stmt = new Ast.ForeachStatement(item, list, body);
		setInfo(stmt, info);
		stmt.validate();
		return stmt;
	}

	public Ast.Statement createWhileStatement(Parser.Info info, Ast.Expression condition, Ast.Statement body) {
		Ast.Statement stmt = new Ast.WhileStatement(condition, body);
		setInfo(stmt, info);
		return stmt;
	}
	
	public Ast.Statement createIfStatement(Parser.Info info, Ast.Expression condition, Ast.Statement then_stmt, Ast.Statement else_stmt) {
		Ast.Statement stmt = new Ast.IfStatement(condition, then_stmt, else_stmt);
		setInfo(stmt, info);
		return stmt;
	}
	
	public Ast.Statement createBreakStatement(Parser.Info info) {
		Ast.Statement stmt = new Ast.BreakStatement();
		setInfo(stmt, info);
		return stmt;
	}
	
	public Ast.Statement createContinueStatement(Parser.Info info) {
		Ast.Statement stmt = new Ast.ContinueStatement();
		setInfo(stmt, info);
		return stmt;
	}
	
	public Ast.Statement createExpressionStatement(Parser.Info info, Ast.Expression expr) {
		Ast.Statement stmt = new Ast.ExpressionStatement(expr);
		setInfo(stmt, info);
		return stmt;
	}
	
	public Ast.Statement createBlockStatement(Parser.Info info, List statements) {
		Ast.Statement stmt = new Ast.BlockStatement(statements);
		setInfo(stmt, info);
		return stmt;
	}

	//
	
	public Ast.Statement createStagStatement(Parser.Info info) {
		Ast.Statement stmt = new Ast.StagStatement();
		setInfo(stmt, info);
		return stmt;
	}

	public Ast.Statement createContStatement(Parser.Info info) {
		Ast.Statement stmt = new Ast.ContStatement();
		setInfo(stmt, info);
		return stmt;
	}
	
	public Ast.Statement createEtagStatement(Parser.Info info) {
		Ast.Statement stmt = new Ast.EtagStatement();
		setInfo(stmt, info);
		return stmt;
	}

	public Ast.Statement createElemStatement(Parser.Info info) {
		Ast.Statement stmt = new Ast.ElemStatement();
		setInfo(stmt, info);
		return stmt;
	}

	public Ast.Statement createElementStatement(Parser.Info info, Parser.Info arg) {
		Ast.Statement stmt = new Ast.ElementStatement(arg.getValue());
		setInfo(stmt, info);
		return stmt;
	}

	public Ast.Statement createContentStatement(Parser.Info info, Parser.Info arg) {
		Ast.Statement stmt = new Ast.ContentStatement(arg.getValue());
		setInfo(stmt, info);
		return stmt;
	}

	//
	
	public Ast.Selector createSelector(Parser.Info info) {
		Ast.Selector selector = new Ast.Selector(info.getValue());
		setInfo(selector, info);
		return selector;
	}
	
	public Ast.Declaration createDeclaration(Parser.Info info, Object arg) {
		String propname = info.getValue();
		Ast.Declaration decl = new Ast.Declaration(info.getToken(), propname, arg);
		setInfo(decl, info);
		return decl;
	}
	
	public Ast.Declaration createLogicDeclaration(Parser.Info info, List stmts, Parser.Info rcurly) throws ParseException {
		if (info.getColumn() != rcurly.getColumn() && info.getLinenum() != rcurly.getLinenum()) {
			String msg = "'}': column of closing curly bracket is not matched with of property '"+info.getValue()+"'"
	                   + " starting at line "+info.getLinenum()+", column "+info.getColumn()+".";
			throw new SyntaxException(msg, rcurly.getLinenum(), rcurly.getColumn());
		}
		String propname = info.getValue();
		Ast.Declaration decl = new Ast.Declaration(info.getToken(), propname, stmts);
		setInfo(decl, info);
		return decl;
	}
	
	public Ast.Ruleset createRuleset(Parser.Info info, List selectors, List declarations, Parser.Info rcurly) throws ParseException {
		Ast.Selector selector = (Ast.Selector)selectors.get(0);
		if (selector.getColumn() != rcurly.getColumn() && selector.getLinenum() != rcurly.getLinenum()) {
			String msg = "'}': column of closing curly bracket is not matched with of selector '"+selector.getValue()+"'"
			           + " starting at line "+selector.getLinenum()+", column "+selector.getColumn()+".";
			throw new SyntaxException(msg, rcurly.getLinenum(), rcurly.getColumn());
		}		
		Ast.Ruleset ruleset = new Ast.Ruleset(selectors, declarations);
		setInfo(ruleset, info);
		return ruleset;
	}
	
}
