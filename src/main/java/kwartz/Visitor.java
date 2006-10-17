/*
 * $Rev$
 * $Release$
 * $Copyright$
 */
package kwartz;


public class Visitor {
	
	public Object visit(Ast.Node node) throws KwartzException {
		return node.accept(this);
	}

	
	//// expression
	
	public Object visit(Ast.Expression expr) throws KwartzException {
		return visit((Ast.Node)expr);
	}

	
	public Object visit(Ast.ArithmeticExpression expr) throws KwartzException {
		return visit((Ast.Expression)expr);
	}

	public Object visit(Ast.LogicalExpression expr) throws KwartzException {
		return visit((Ast.Expression)expr);
	}

	public Object visit(Ast.RelationalExpression expr) throws KwartzException {
		return visit((Ast.Expression)expr);
	}

	public Object visit(Ast.AssignmentExpression expr) throws KwartzException {
		return visit((Ast.Expression)expr);
	}

	public Object visit(Ast.IndexExpression expr) throws KwartzException {
		return visit((Ast.Expression)expr);
	}

	public Object visit(Ast.FuncallExpression expr) throws KwartzException {
		return visit((Ast.Expression)expr);
	}

	public Object visit(Ast.MethodExpression expr) throws KwartzException {
		return visit((Ast.Expression)expr);
	}

	public Object visit(Ast.PropertyExpression expr) throws KwartzException {
		return visit((Ast.Expression)expr);
	}

	public Object visit(Ast.ConditionalExpression expr) throws KwartzException {
		return visit((Ast.Expression)expr);
	}

	
    
	//// literal
	
	public Object visit(Ast.Literal literal) throws KwartzException {
		return visit((Ast.Node)literal);
	}
	
	
	public Object visit(Ast.VariableLiteral literal) throws KwartzException {
		return visit((Ast.Literal)literal);
	}
	
	public Object visit(Ast.StringLiteral literal) throws KwartzException {
		return visit((Ast.Literal)literal);
	}
	
	public Object visit(Ast.IntegerLiteral literal) throws KwartzException {
		return visit((Ast.Literal)literal);
	}
	
	public Object visit(Ast.FloatLiteral literal) throws KwartzException {
		return visit((Ast.Literal)literal);
	}
	
	public Object visit(Ast.TrueLiteral literal) throws KwartzException {
		return visit((Ast.Literal)literal);
	}
	
	public Object visit(Ast.FalseLiteral literal) throws KwartzException {
		return visit((Ast.Literal)literal);
	}
	
	public Object visit(Ast.NullLiteral literal) throws KwartzException {
		return visit((Ast.Literal)literal);
	}

	
	
	//// statement
	
	public Object visit(Ast.Statement stmt) throws KwartzException {
		return visit((Ast.Node)stmt);
	}


	public Object visit(Ast.PrintStatement stmt) throws KwartzException {
		return visit((Ast.Statement)stmt);
	}

	public Object visit(Ast.ExpressionStatement stmt) throws KwartzException {
		return visit((Ast.Statement)stmt);
	}

	public Object visit(Ast.IfStatement stmt) throws KwartzException {
		return visit((Ast.Statement)stmt);
	}

	public Object visit(Ast.WhileStatement stmt) throws KwartzException {
		return visit((Ast.Statement)stmt);
	}

	public Object visit(Ast.ForeachStatement stmt) throws KwartzException {
		return visit((Ast.Statement)stmt);
	}

	public Object visit(Ast.BreakStatement stmt) throws KwartzException {
		return visit((Ast.Statement)stmt);
	}

	public Object visit(Ast.ContinueStatement stmt) throws KwartzException {
		return visit((Ast.Statement)stmt);
	}

	public Object visit(Ast.BlockStatement stmt) throws KwartzException {
		return visit((Ast.Statement)stmt);
	}


	
	//// expand statement
	
	public Object visit(Ast.ExpandStatement stmt) throws KwartzException {
		return visit((Ast.Statement)stmt);
	}

	public Object visit(Ast.StagStatement stmt) throws KwartzException {
		return visit((Ast.ExpandStatement)stmt);
	}

	public Object visit(Ast.ContStatement stmt) throws KwartzException {
		return visit((Ast.ExpandStatement)stmt);
	}

	public Object visit(Ast.EtagStatement stmt) throws KwartzException {
		return visit((Ast.ExpandStatement)stmt);
	}

	public Object visit(Ast.ElemStatement stmt) throws KwartzException {
		return visit((Ast.ExpandStatement)stmt);
	}

	public Object visit(Ast.ElementStatement stmt) throws KwartzException {
		return visit((Ast.ExpandStatement)stmt);
	}

	public Object visit(Ast.ContentStatement stmt) throws KwartzException {
		return visit((Ast.ExpandStatement)stmt);
	}


	
	//// selector, declaration, ruleset
	
	public Object visit(Ast.Selector selector) throws KwartzException {
		return visit((Ast.Node)selector);
	}

	public Object visit(Ast.Declaration declaration) throws KwartzException {
		return visit((Ast.Node)declaration);
	}
	
	public Object visit(Ast.Ruleset ruleset) throws KwartzException {
		return visit((Ast.Node)ruleset);
	}


}
