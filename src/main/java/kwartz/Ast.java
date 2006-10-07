package kwartz;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Collections;

public class Ast {

	abstract static class Node {
	
		int _token;
		int _linenum;
		int _column;
		
		//public AbstractNode(int token) {
		public Node(int token) {
			_token = token;
		}
		
		public void validate() throws ParseException {
			// empty
		}
		
		public int getToken() {
			return _token;
		}
		
		public void setToken(int token) {
			_token = token;
		}
		
		public int getLinenum() {
			return _linenum;
		}
		
		public void setLinenum(int linenum) {
			_linenum = linenum;
		}
		
		public int getColumn() {
			return _column;
		}
		
		public void setColumn(int column) {
			_column = column;
		}
		
		public String inspect(int level) {
			StringBuffer sb = new StringBuffer();
			_inspect(level, sb);
			return sb.toString();
		}
		
		public String inspect() {
			return inspect(0);
		}
		
		protected void _inspect(int level, StringBuffer sb) {
			_addValue(level, sb, Parser.tokenSymbol(_token));
		}
		
		protected void _addValue(int level, StringBuffer sb, String value) {
			_addIndent(level, sb);
			sb.append(value).append('\n');
		}
		
		protected void _addIndent(int level, StringBuffer sb) {
			for (int i = 0; i < level; i++) {
				sb.append("  ");
			}
		}
	}


    static class Expression extends Node {
	
    	public Expression(int token) {
    		super(token);
    	}
	
    	public boolean availableAsLhs() {
    		return false;
    	}
    }
    
    
    static class BinaryExpression extends Expression {
    	Expression _left;
    	Expression _right;
		
    	public BinaryExpression(int token, Expression left, Expression right) {
    		super(token);
			_left = left;
			_right = right;
		}
		
		public Expression getLeft() {
			return _left;
		}
		
		public Expression getRight() {
			return _right;
		}
		
		protected void _inspect(int level, StringBuffer sb) {
			super._inspect(level, sb);
			if (_left != null)  _left._inspect(level+1, sb);
			if (_right != null) _right._inspect(level+1, sb);
		}
	}
	
	
	static class ArithmeticExpression extends BinaryExpression {
		public ArithmeticExpression(int token, Expression left, Expression right) {
			super(token, left, right);
		}
	}
	
	
	static class LogicalExpression extends BinaryExpression {
		public LogicalExpression(int token, Expression left, Expression right) {
			super(token, left, right);
		}
	}
	
	
	static class RelationalExpression extends BinaryExpression {
		public RelationalExpression(int token, Expression left, Expression right) {
			super(token, left, right);
		}
	}
	
	
	static class AssignmentExpression extends BinaryExpression {
		public AssignmentExpression(int token, Expression left, Expression right) {
			super(token, left, right);
		}
		
		public void validate() throws ParseException {
			if (! _left.availableAsLhs()) {
				String s = Parser.tokenSymbol(_token);
				throw new SemanticException("" + s + ": invalid left-side value.", _linenum, _column);
			}
		}
	}
	
	
	static class IndexExpression extends BinaryExpression {
		public IndexExpression(int token, Expression left, Expression right) {
			super(token, left, right);
		}
		
		public boolean availableAsLhs() {
			return true;
		}
	}
	
	
	static class FuncallExpression extends Expression {
		String _funcname;
		Expression[] _arguments;
		
		public FuncallExpression(String funcname, Expression[] arguments) {
			super(Token.FUNCALL);
			_funcname = funcname;
			_arguments = arguments;
			assert arguments != null;
		}
		
		public void _inspect(int level, StringBuffer sb) {
			_addValue(level, sb, _funcname + "()");
			for (int i = 0, n = _arguments.length; i < n; i++) {
				Expression expr = _arguments[i];
				expr._inspect(level+1, sb);
			}
		}
	}
	
	
	static class MethodExpression extends Expression {
		String _method_name;
		Expression _receiver;
		Expression[] _arguments;
		
		public MethodExpression(Expression receiver, String method_name, Expression[] arguments) {
			super(Token.METHOD);
			_receiver = receiver;
			_method_name = method_name;
			_arguments = arguments;
			assert arguments != null;
		}
		
		public void _inspect(int level, StringBuffer sb) {
			super._inspect(level, sb);
			_receiver._inspect(level+1, sb);
			_addValue(level+1, sb, "."+_method_name+"()");
			for (int i = 0, n = _arguments.length; i < n; i++) {
				Expression expr = _arguments[i];
				expr._inspect(level+2, sb);
			}
		}
	}
	
	
	static class PropertyExpression extends Expression {
		String _property_name;
		Expression _receiver;
		
		public PropertyExpression(Expression receiver, String property_name) {
			super((int)'.');
			_receiver = receiver;
			_property_name = property_name;
		}

		public boolean availableAsLhs() {
			return true;
		}

		public void _inspect(int level, StringBuffer sb) {
			super._inspect(level, sb);
			_receiver._inspect(level+1, sb);
			_addValue(level+1, sb, "."+_property_name);
		}
	}
	
	
	static class ConditionalExpression extends Expression {
		Expression _condition;
		Expression _left;
		Expression _right;
		
		public Expression getCondition() {
			return _condition;
		}
		
		public Expression getLeft() {
			return _left;
		}
		
		public Expression getRight() {
			return _right;
		}
		
		public ConditionalExpression(Expression condition, Expression left, Expression right) {
			super(Token.CONDITIONAL);
			_condition = condition;
			_left = left;
			_right = right;
		}
		
		protected void _inspect(int level, StringBuffer sb) {
			super._inspect(level, sb);
			_condition._inspect(level+1, sb);
			_left._inspect(level+1, sb);
			_right._inspect(level+1, sb);
		}
	}
	


	static abstract class Literal extends Expression {
	
		protected java.lang.String _token_value;
	
		public Literal(int token, java.lang.String token_value) {
			super(token);
			_token_value = token_value;
		}
	
		public void _inspect(int level, StringBuffer sb) {
			_addValue(level, sb, _token_value);
		}
	}
	
	
	static class VariableLiteral extends Literal {
		public VariableLiteral(java.lang.String token_value) {
			super(Token.VARIABLE, token_value);
		}
		public boolean availableAsLhs() {
			return true;
		}
	}
	
	static class StringLiteral extends Literal {
		public StringLiteral(java.lang.String token_value) {
			super(Token.STRING, token_value);
		}
		
		public void _inspect(int level, StringBuffer sb) {
			_addValue(level, sb, Util.inspect(_token_value));
		}
	}
	
	static class IntegerLiteral extends Literal {
		public IntegerLiteral(java.lang.String token_value) {
			super(Token.INTEGER, token_value);
		}
	}

	static class FloatLiteral extends Literal {
		public FloatLiteral(java.lang.String token_value) {
			super(Token.FLOAT, token_value);
		}
	}

	static class TrueLiteral extends Literal {
		public TrueLiteral(java.lang.String token_value) {
			super(Token.TRUE, token_value);
		}
	}

	static class FalseLiteral extends Literal {
		public FalseLiteral(java.lang.String token_value) {
			super(Token.FALSE, token_value);
		}
	}
	
	static class NullLiteral extends Literal {
		public NullLiteral(java.lang.String token_value) {
			super(Token.NULL, token_value);
		}
	}


	
	static abstract class Statement extends Node {
		
		public Statement(int token) {
			super(token);
		}
	}
	
	
	static class PrintStatement extends Statement {
		Expression[] _arguments;
		
		public PrintStatement(Expression[] arguments) {
			super(Token.PRINT);
			_arguments = arguments;
			assert arguments != null;
		}
		
		protected void _inspect(int level, StringBuffer sb) {
			super._inspect(level, sb);
			for (int i = 0, n = _arguments.length; i < n; i++) {
				Expression expr = _arguments[i];
				expr._inspect(level+1, sb);
			}
		}
	}
	
	static class ExpressionStatement extends Statement {
		Expression _expression;
	
		public ExpressionStatement(Expression expression) {
			super(Token.EXPR);
			_expression = expression;
			assert expression != null;
		}
		
		protected void _inspect(int level, StringBuffer sb) {
			super._inspect(level, sb);
			_expression._inspect(level+1, sb);
		}
	}
	
	static class IfStatement extends Statement {
		Expression _condition;
		Statement _then_stmt;
		Statement _else_stmt;
		
		public IfStatement(Expression condition, Statement then_stmt, Statement else_stmt) {
			super(Token.IF);
			_condition = condition;
			_then_stmt = then_stmt;
			_else_stmt = else_stmt;
		}
		
		protected void _inspect(int level, StringBuffer sb) {
			super._inspect(level, sb);
			_condition._inspect(level+1, sb);
			_then_stmt._inspect(level+1, sb);
			if (_else_stmt != null) 
				_else_stmt._inspect(level+1, sb);
		}
	}
	
	static class WhileStatement extends Statement {
		Expression _condition;
		Statement  _body;
		
		public WhileStatement(Expression condition, Statement body) {
			super(Token.WHILE);
			_condition = condition;
			_body = body;
		}
		
		protected void _inspect(int level, StringBuffer sb) {
			super._inspect(level, sb);
			_condition._inspect(level+1, sb);
			_body._inspect(level+1, sb);
		}
	}
	
	static class ForeachStatement extends Statement {
		Expression _item;
		Expression _list;
		Statement _body;
		
		public ForeachStatement(Expression item, Expression list, Statement body) {
			super(Token.FOREACH);
			_item = item;
			_list = list;
			_body = body;
		}
		
		public void validate() throws ParseException {
			if (_item.getToken() != Token.VARIABLE) {
				String s = Parser.tokenSymbol(_item.getToken());
				String mesg = s + ": invalid loop-variable of foreach statement.";
				throw new SemanticException(mesg, _item.getLinenum(), _item.getColumn());
			}
		}
		
		protected void _inspect(int level, StringBuffer sb) {
			super._inspect(level, sb);
			_item._inspect(level+1, sb);
			_list._inspect(level+1, sb);
			_body._inspect(level+1, sb);
		}
	}
	
	static class BreakStatement extends Statement {
		public BreakStatement() {
			super(Token.BREAK);
		}
	}
	
	static class ContinueStatement extends Statement {
		public ContinueStatement() {
			super(Token.CONTINUE);
		}
	}
	
	static class BlockStatement extends Statement {
		Statement[] _statements;
		
		public BlockStatement(Statement[] statements) {
			super(Token.BLOCK);
			_statements = statements;
		}
		
		public BlockStatement(List statements) {
			super(Token.BLOCK);
			setStatements(statements);
		}
		
		public Statement[] getStatements() {
			return _statements;
		}
		
		public void setStatements(Statement[] statements) {
			_statements = statements;
		}
		
		public void setStatements(List statements) {
			Statement[] stmts = new Statement[statements.size()];
			statements.toArray(stmts);
			_statements = stmts;			
		}

		protected void _inspect(int level, StringBuffer sb) {
			super._inspect(level, sb);
			for (int i = 0, n = _statements.length; i < n; i++) {
				_statements[i]._inspect(level+1, sb);
			}
		}
	}
	
	
	////
	
	static class StagStatement extends Statement {
		public StagStatement() {
			super(Token.STAG);
		}
	}
	
	static class ContStatement extends Statement {
		public ContStatement() {
			super(Token.CONT);
		}
	}

	static class EtagStatement extends Statement {
		public EtagStatement() {
			super(Token.ETAG);
		}
	}
	
	static class ElemStatement extends Statement {
		public ElemStatement() {
			super(Token.ELEM);
		}
	}
	
	static class ElementStatement extends Statement {
		private String _name;
		public ElementStatement(String name) {
			super(Token.ELEMENT);
			_name = name;
		}
		public void _inspect(int level, StringBuffer sb) {
			_addValue(level, sb, "_element("+_name+")");
		}
	}
	
	static class ContentStatement extends Statement {
		private String _name;
		public ContentStatement(String name) {
			super(Token.CONTENT);
			_name = name;
		}
		public void _inspect(int level, StringBuffer sb) {
			_addValue(level, sb, "_content("+_name+")");
		}
	}
	


	/**
	 * selecotr class (ex. '#foo', '.foo', or 'foo')
	 */
	static class Selector extends Node {
		private String _value;   // '#foo', '.foo', or 'foo'
		private int _kind;       // '#', '.', or '<'
		
		public Selector(String value) {
			super(Token.SELECTOR);
			_value = value;
			_kind = value.charAt(0);
			if (_kind != '#' && _kind != '.')
				_kind = '<';
		}
	
		public String getValue() {
			return _value;
		}
	
		public int getKind() {
			return _kind;
		}
	}
	

	/**
	 * declaration
	 * 
	 * BNF:
	 * <pre>
	 *  declaration ::= property_name ':' value
	 *  value       ::= expression | attrs | exprs
	 *  attrs       ::= attr | attrs ',' attr
	 *  attr        ::= string expression
	 *  exprs       ::= expr | exprs expr
	 * </pre>
	 */
	static class Declaration extends Node {
		
		private String _propname;
		private Object _argument;
		
		public Declaration(int token, String propname, Object argument) {
			super(token);
			_propname = propname;
			String wrap_func = _wrapFunctionName(propname);
			if (wrap_func != null) {
				argument = _wrap(argument, wrap_func);
			}
			_argument = argument;
		}

		public String getPropertyName() {
			return _propname;
		}
		public Object getArgument() {
			return _argument;
		}
	
		private String _wrapFunctionName(String propname) {
			if (Character.isLowerCase(propname.charAt(0)))
				return null;
			else if (Character.isLowerCase(propname.charAt(propname.length()-1)))
				return "E";  // escape
			else
				return "X";  // not escape
		}
		
		private Object _wrap(Object arg, String funcname) {
			if (arg instanceof Expression) {
				return new Ast.FuncallExpression(funcname, new Expression[] { (Expression)arg });
			}
			if (arg instanceof List) {
				List exprs = (List)arg;
				//for (Iterator it = exprs.iterator(); it.hasNext(); ) {
				for (int i = 0, n = exprs.size(); i < n; i++) {
					//Expression expr = (Expression)it.next();
					Expression expr = (Expression)exprs.get(i);
					exprs.set(i, _wrap(expr, funcname));
				}
				return exprs;
			}
			if (arg instanceof Map) {
				Map attrs = (Map)arg;
				for (Iterator it = attrs.keySet().iterator(); it.hasNext(); ) {
					String name = (String)it.next();
					attrs.put(name, _wrap(attrs.get(name), funcname));
				}
				return attrs;
			}
			return arg;
		}

	}


	/**
	 * ruleset
	 * 
	 * BNF:
	 * <pre>
	 * ruleset ::= selectors '{' declarations '}'
	 * selectors ::= selector | selectors ',' selecotr
	 * declarations ::= declaration | declarations declaration
	 * </pre>
	 */
	static class Ruleset extends Node {
		
		private List _selectors;
		private Map _declarations;
		
		public Ruleset(List selectors, Map declarations) {
			super(Token.RULESET);
			_selectors = selectors == null ? new ArrayList() : selectors;
			_declarations = declarations == null ? (Map)new HashMap() : declarations;
		}
	
		public Ruleset(List selectors, List decl_list) {
			this(selectors, new HashMap());
			for (Iterator it = decl_list.iterator(); it.hasNext(); ) {
				addDeclaration((Declaration)it.next());
			}
		}
	
		public Ruleset() {
			this(new ArrayList(), new HashMap());
		}
		
		public void addSelector(String selector) {
			_selectors.add(selector);
		}
		
		public Iterator selectors() {
			return _selectors.iterator();
		}
		
		public void addDeclaration(Declaration decl) {
			_declarations.put(new Integer(decl.getToken()), decl);
		}
		
		public Declaration getDeclaration(int token) {
			return (Declaration)_declarations.get(new Integer(token));
		}
		
		public Iterator declarations() {
			return _declarations.values().iterator();
		}
		
		public boolean match(String selector_str) {
			Selector selector = (Selector)_selectors.get(0);
			if (selector.getValue().equals(selector_str))
				return true;
			for (Iterator it = _selectors.iterator(); it.hasNext(); ) {
				selector = (Selector)it.next();
				if (selector.getValue().equals(selector_str))
					return true;
			}
			return false;
		}
	
		protected void _inspect(int level, StringBuffer sb) {
			sb.append(Util.repeatString("  ", level));
			String sep = "";
			for (Iterator it = _selectors.iterator(); it.hasNext(); ){
				Selector selector = (Selector)it.next();
				sb.append(sep).append(selector.getValue());
				sep = ", ";
			}
			sb.append(" {\n");
			Declaration decl = null;
			for (int i = Token.P_STAG; i <= Token.P_VALUE; i++) {
				if ((decl = getDeclaration(i)) != null) {
					_addValue(level+1, sb, decl.getPropertyName() + ":");
					((Expression)decl.getArgument())._inspect(level+2, sb);
				}
			}
			if ((decl = getDeclaration(Token.P_ATTRS)) != null) {
				_addValue(level+1, sb, decl.getPropertyName() + ":");
				Map map = (Map)decl.getArgument();
				List names = new ArrayList(map.keySet());
				Collections.sort(names);
				for (Iterator it = names.iterator(); it.hasNext(); ) {
					String key = (String)it.next();
					Expression expr = (Expression)map.get(key);
					_addValue(level+2, sb, "- '" + key + "'");
					expr._inspect(level+3, sb);
				}
			}
			if ((decl = getDeclaration(Token.P_APPEND)) != null) {
				_addValue(level+1, sb, decl.getPropertyName() + ":");
				List exprs = (List)decl.getArgument();
				for (Iterator it = exprs.iterator(); it.hasNext(); ) {
					Expression expr = (Expression)it.next();
					expr._inspect(level+2, sb);
				}
			}
			if ((decl = getDeclaration(Token.P_REMOVE)) != null) {
				_addValue(level+1, sb, decl.getPropertyName() + ":");
				List names = (List)decl.getArgument();
				for (Iterator it = names.iterator(); it.hasNext(); ) {
					String name = (String)it.next();
					_addValue(level+2, sb, "- '" + name + "'");
				}
			}
			if ((decl = getDeclaration(Token.P_TAGNAME)) != null) {
				String name = (String)decl.getArgument();
				_addValue(level+1, sb, decl.getPropertyName() + ": '" + name + "'");
			}
			for (int t = Token.P_LOGIC; t <= Token.P_AFTER; t++) {
				if ((decl = getDeclaration(t)) != null) {
					_addValue(level+1, sb, decl.getPropertyName() + ": {");
					List stmts = (List)decl.getArgument();
					for (Iterator it = stmts.iterator(); it.hasNext(); ) {
						Statement stmt = (Statement)it.next();
						stmt._inspect(level+2, sb);
					}
					_addValue(level+1, sb, "}");
				}
			}
			_addValue(level, sb, "}");
		}
	}

	
}