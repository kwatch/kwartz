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
		String _filename;
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
		
		public String getFilename() {
			return _filename;
		}
		
		public void setFilename(String filename) {
			_filename = filename;
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
		
		
		abstract public Object accept(Visitor visitor) throws KwartzException ;


		public String inspect(int level) {
			StringBuffer sb = new StringBuffer();
			_inspect(level, sb);
			return sb.toString();
		}
		
		public String inspect() {
			return inspect(0);
		}
		
		protected void _inspect(int level, StringBuffer sb) {
			_addValue(level, sb, TokenHelper.tokenSymbol(_token));
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
    	
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
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
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
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
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
    	}
    	
	}
	
	
	static class LogicalExpression extends BinaryExpression {
		public LogicalExpression(int token, Expression left, Expression right) {
			super(token, left, right);
		}
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
    	}
    	
	}
	
	
	static class RelationalExpression extends BinaryExpression {
		public RelationalExpression(int token, Expression left, Expression right) {
			super(token, left, right);
		}
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
    	}
    	
	}
	
	
	static class AssignmentExpression extends BinaryExpression {
		public AssignmentExpression(int token, Expression left, Expression right) {
			super(token, left, right);
		}
		
		public void validate() throws ParseException {
			if (! _left.availableAsLhs()) {
				String s = TokenHelper.tokenSymbol(_token);
				throw new SemanticException("" + s + ": invalid left-side value.", _filename, _linenum, _column);
			}
		}
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
    	}
    	
	}
	
	
	static class IndexExpression extends BinaryExpression {
		public IndexExpression(int token, Expression left, Expression right) {
			super(token, left, right);
		}
		
		public boolean availableAsLhs() {
			return true;
		}
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
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
		
		public String getFuncname() {
			return _funcname;
		}
		
		public Expression[] getArguments() {
			return _arguments;
		}
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
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
		
		public String getMethodName() {
			return _method_name;
		}
		
		public Expression getReceiver() {
			return _receiver;
		}
		
		public Expression[] getArguments() {
			return _arguments;
		}
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
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
		
		public String getPropertyName() {
			return _property_name;
		}
		
		public Expression getReceiver() {
			return _receiver;
		}

    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
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
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
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
		
		public String getValue() {
			return _token_value;
		}
	
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
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
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
    	}
    	
	}
	
	static class StringLiteral extends Literal {
		public StringLiteral(java.lang.String token_value) {
			super(Token.STRING, token_value);
		}
	
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
    	}
    	
		public void _inspect(int level, StringBuffer sb) {
			_addValue(level, sb, Util.inspect(_token_value));
		}
	}
	
	static final StringLiteral EMPTY_STRING_LITERAL = new StringLiteral(""); 
	
	static class IntegerLiteral extends Literal {
		public IntegerLiteral(java.lang.String token_value) {
			super(Token.INTEGER, token_value);
		}
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
    	}
    	
	}

	static class FloatLiteral extends Literal {
		public FloatLiteral(java.lang.String token_value) {
			super(Token.FLOAT, token_value);
		}
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
    	}
    	
	}

	static class TrueLiteral extends Literal {
		public TrueLiteral(java.lang.String token_value) {
			super(Token.TRUE, token_value);
		}
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
    	}
    	
	}

	static class FalseLiteral extends Literal {
		public FalseLiteral(java.lang.String token_value) {
			super(Token.FALSE, token_value);
		}
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
    	}
    	
	}
	
	static class NullLiteral extends Literal {
		public NullLiteral(java.lang.String token_value) {
			super(Token.NULL, token_value);
		}
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
    	}
    	
	}


	////
	
	static abstract class Statement extends Node {
		
		public Statement(int token) {
			super(token);
		}
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
    	}
    	
	}
	
	
	static class PrintStatement extends Statement {
		Expression[] _arguments;
		
		public PrintStatement(Expression[] arguments) {
			super(Token.PRINT);
			assert arguments != null;
			_arguments = arguments;
		}
		
		public PrintStatement(List arguments) {
			super(Token.PRINT);
			assert arguments != null;
			_arguments = new Expression[arguments.size()];
			arguments.toArray(_arguments);
		}
		
		public PrintStatement(Expression expr) {
			this(new Expression[] { expr });
		}
		
		public Expression[] getArguments() {
			return _arguments;
		}
		
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
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

		public Expression getExpression() {
			return _expression;
		}
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
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
		
		public Expression getCondition() {
			return _condition;
		}
		
		public Statement getThenStatement() {
			return _then_stmt;
		}
		
		public Statement getElseStatement() {
			return _else_stmt;
		}
		
		public void setElseStatement(Statement stmt) {
			_else_stmt = stmt;
		}
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
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
		
		public Expression getCondition() {
			return _condition;
		}
		
		public Statement getBodyStatement() {
			return _body;
		}
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
    	}
    	
		protected void _inspect(int level, StringBuffer sb) {
			super._inspect(level, sb);
			_condition._inspect(level+1, sb);
			_body._inspect(level+1, sb);
		}
	}
	
	static class ForeachStatement extends Statement {
		VariableLiteral _item;
		Expression _list;
		Statement _body;
		
		public ForeachStatement(VariableLiteral item, Expression list, Statement body) {
			super(Token.FOREACH);
			_item = item;
			_list = list;
			_body = body;
		}

//		public void validate() throws ParseException {
//			if (_item.getToken() != Token.VARIABLE) {
//				String s = TokenHelper.tokenSymbol(_item.getToken());
//				String mesg = s + ": invalid loop-variable of foreach statement.";
//				throw new SemanticException(mesg, _filename, _item.getLinenum(), _item.getColumn());
//			}
//		}
		
		public VariableLiteral getItemVariable() {
			return _item;
		}
		
		public Expression getListExpression() {
			return _list;
		}
		
		public Statement getBodyStatement() {
			return _body;
		}
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
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
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
    	}
    	
	}
	
	static class ContinueStatement extends Statement {
		public ContinueStatement() {
			super(Token.CONTINUE);
		}
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
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
		
		public BlockStatement(Statement stmt) {
			super(Token.BLOCK);
			_statements = new Statement[] { stmt };
		}
		
		public Statement[] getStatements() {
			return _statements;
		}
		
		public void setStatement(Statement stmt, int index) {
			_statements[index] = stmt;
		}
		
		public void setStatements(List statements) {
			Statement[] stmts = new Statement[statements.size()];
			statements.toArray(stmts);
			_statements = stmts;			
		}

    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
    	}
    	
		protected void _inspect(int level, StringBuffer sb) {
			super._inspect(level, sb);
			for (int i = 0, n = _statements.length; i < n; i++) {
				_statements[i]._inspect(level+1, sb);
			}
		}
	}
	
	
	//// exapnd statement
	
	static class ExpandStatement extends Statement {
		String _name;
		public ExpandStatement(int token, String name) {
			super(token);
			_name = name;
		}
		public ExpandStatement(int token) {
			super(token);
		}
		public String getName() {
			return _name;
		}
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
    	}
    	
	}
	
	
	static class StagStatement extends ExpandStatement {
		public StagStatement() {
			super(Token.STAG);
		}
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
    	}
    	
	}
	
	static class ContStatement extends ExpandStatement {
		public ContStatement() {
			super(Token.CONT);
		}
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
    	}
    	
	}

	static class EtagStatement extends ExpandStatement {
		public EtagStatement() {
			super(Token.ETAG);
		}
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
    	}
    	
	}
	
	static class ElemStatement extends ExpandStatement {
		public ElemStatement() {
			super(Token.ELEM);
		}
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
    	}
    	
	}
	
	static class ElementStatement extends ExpandStatement {
		public ElementStatement(String name) {
			super(Token.ELEMENT, name);
		}
		public void _inspect(int level, StringBuffer sb) {
			_addValue(level, sb, "_element("+_name+")");
		}
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
    	}
    	
	}
	
	static class ContentStatement extends ExpandStatement {
		public ContentStatement(String name) {
			super(Token.CONTENT, name);
		}
		public void _inspect(int level, StringBuffer sb) {
			_addValue(level, sb, "_content("+_name+")");
		}
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
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
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
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
	 *  attr        ::= string expr
	 *  exprs       ::= expr | exprs expr
	 * </pre>
	 */
	static class Declaration extends Node {
		
		private String _propname;
		private Object _propvalue;
		
		public Declaration(int token, String propname, Object propvalue) {
			super(token);
			_propname = propname;
			int escape_flag = Parser.detectEscapeFlag(propname);
			if (escape_flag != 0) {
				String wrap_funcname = escape_flag > 0 ? "E" : "X";
				propvalue = Ast.Helper.wrapWithFunction(propvalue, wrap_funcname);
			}
			_propvalue = propvalue;
		}

		public String getPropertyName() {
			return _propname;
		}
		public Object getPropertyValue() {
			return _propvalue;
		}
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
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
	 * declaration ::= property_name | property_value
	 * </pre>
	 */
	static class Ruleset extends Node {
		
		private List _selectors;
		private List _declarations;
		private Map _prop_table = new HashMap();
		private String[] _selector_names;
		
		public Ruleset(List selectors, List decl_list) {
			super(Token.RULESET);
			_selectors = selectors == null ? new ArrayList() : selectors;
			_declarations = decl_list == null ? new ArrayList() : decl_list;
			_selector_names = new String[_selectors.size()];
			int i = 0;
			for (Iterator it = _selectors.iterator(); it.hasNext(); ) {
				_selector_names[i] = (String)((Selector)it.next()).getValue();
				i++;
			}
			for (Iterator it = decl_list.iterator(); it.hasNext(); ) {
				Declaration decl = (Declaration)it.next();
				addProperty(decl.getToken(), decl.getPropertyValue());
			}
		}
	
		public Ruleset() {
			this(new ArrayList(), new ArrayList());
		}

		
		public Iterator selectorsIterator() {
			return _selectors.iterator();
		}
		
		public Iterator declarationsIterator() {
			return _declarations.iterator();
		}
		
		public String[] selectorNames() {
			return _selector_names;
		}
		
		public void addProperty(int token, Object propvalue) {
			_prop_table.put(new Integer(token), propvalue);
		}
		
		public Object getProperty(int token) {
			return _prop_table.get(new Integer(token));
		}
		
		
		public Ast.Expression getStag() {
			return _getExpression(Token.P_STAG);
		}
		
		public Ast.Expression getEtag() {
			return _getExpression(Token.P_ETAG);
		}
		
		public Ast.Expression getCont() {
			Expression expr = _getExpression(Token.P_CONT);
			if (expr == null) expr = _getExpression(Token.P_VALUE);
			return expr;
		}
		
		public Ast.Expression getElem() {
			return _getExpression(Token.P_ELEM);
		}
		
		public Ast.Expression getValue() {
			return _getExpression(Token.P_VALUE);
		}
		
		private Ast.Expression _getExpression(int token) {
			return (Ast.Expression)getProperty(token);
		}
		
		public Map getAttrs() {
			return (Map)getProperty(Token.P_ATTRS);
		}
		
		public List getAppend() {
			return (List)getProperty(Token.P_APPEND);
		}
		
		public List getRemove() {
			return (List)getProperty(Token.P_REMOVE);
		}
		
		public String getTagname() {
			return (String)getProperty(Token.P_TAGNAME);
		}
		
		public List getLogic() {
			return _getStatements(Token.P_LOGIC);
		}
		
		public List getBefore() {
			List stmts = _getStatements(Token.P_BEFORE);
			if (stmts == null) stmts = _getStatements(Token.P_BEGIN);
			return stmts;
		}
		
		public List getAfter() {
			List stmts = _getStatements(Token.P_AFTER);
			if (stmts == null) stmts = _getStatements(Token.P_END);
			return stmts;
		}
		
		private List _getStatements(int token) {
			if (token < Token.P_LOGIC || Token.P_AFTER < token)
				throw new IllegalArgumentException("Ruleset#getStatement(): token " + token + ": must be Token.P_LOGIC <= token <= Token.P_AFTER.");
			return (List)getProperty(token);
		}
		
		
		public boolean match(String selector_name) {
			for (int i = 0, n = _selector_names.length; i < n; i++) {
				if (_selector_names[i].equals(selector_name))
					return true;
			}
			return false;
		}
		
		
		static Ruleset merged(Ruleset ruleset1, Ruleset ruleset2) {
			Map new_proptable = new HashMap();
			new_proptable.putAll(ruleset1._prop_table);
			new_proptable.putAll(ruleset2._prop_table);
			Map attrs1 = ruleset1.getAttrs();
			Map attrs2 = ruleset2.getAttrs();
			if (attrs1 != null || attrs2 != null) {
				Map new_attrs = new HashMap();
				if (attrs1 != null) new_attrs.putAll(attrs1);
				if (attrs2 != null) new_attrs.putAll(attrs2);
				new_proptable.put(new Integer(Token.P_ATTRS), new_attrs);
			}
			List exprs1 = ruleset1.getAppend();
			List exprs2 = ruleset2.getAppend();
			if (exprs1 != null || exprs2 != null) {
				List new_exprs = new ArrayList();
				if (exprs1 != null) new_exprs.addAll(exprs1);
				if (exprs2 != null) new_exprs.addAll(exprs2);
				new_proptable.put(new Integer(Token.P_APPEND), new_exprs);
			}
			List names1 = ruleset1.getRemove();
			List names2 = ruleset2.getRemove();
			if (names1 != null || names2 != null) {
				List new_names = new ArrayList();
				if (names1 != null) new_names.addAll(names1);
				if (names2 != null) new_names.addAll(names2);
				new_proptable.put(new Integer(Token.P_REMOVE), new_names);
			}
			Ruleset new_ruleset = new Ruleset();
			new_ruleset._prop_table = new_proptable;
			return new_ruleset;
		}
		
    	public Object accept(Visitor visitor) throws KwartzException {
    		return visitor.visit(this);
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
			String[] labels = {"stag:", "cont:", "etag:", "elem:", "value:"}; 
			for (int t = Token.P_STAG; t <= Token.P_VALUE; t++) {
				Expression expr = (Expression)getProperty(t);
				if (expr != null) {
					_addValue(level+1, sb, labels[t - Token.P_STAG]);
					expr._inspect(level+2, sb);
				}
			}
			Map attrs = getAttrs();
			if (attrs != null) {
				_addValue(level+1, sb, "attrs:");
				List names = new ArrayList(attrs.keySet());
				Collections.sort(names);
				for (Iterator it = names.iterator(); it.hasNext(); ) {
					String key = (String)it.next();
					Expression expr = (Expression)attrs.get(key);
					_addValue(level+2, sb, "- '"+key+"'");
					expr._inspect(level+3, sb);
				}
			}
			List exprs = getAppend();
			if (exprs != null) {
				_addValue(level+1, sb, "append:");
				for (Iterator it = exprs.iterator(); it.hasNext(); ) {
					Expression expr = (Expression)it.next();
					expr._inspect(level+2, sb);
				}
			}
			List names = getRemove();
			if (names != null) {
				_addValue(level+1, sb, "remove:");
				for (Iterator it = names.iterator(); it.hasNext(); ) {
					String name = (String)it.next();
					_addValue(level+2, sb, "- '"+name+"'");
				}
			}
			String tagname = (String)getProperty(Token.P_TAGNAME);
			if (tagname != null) {
				_addValue(level+1, sb, "tagname: '"+tagname+"'");
			}
			labels = new String[]{"logic:", "begin:", "end:", "before:", "after:"};
			for (int t = Token.P_LOGIC; t <= Token.P_AFTER; t++) {
				List stmts = (List)getProperty(t);
				if (stmts != null) {
					_addValue(level+1, sb, labels[t - Token.P_LOGIC] + " {");
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


	/////
	
	
	public static class Helper {
		
		
		public static Object wrapWithFunction(Object arg, String funcname) {
			if (arg instanceof Expression) {
				return wrapWithFunction((Expression)arg, funcname);
				//return new Ast.FuncallExpression(funcname, new Expression[] { (Expression)arg });
			}
			if (arg instanceof List) {
				List exprs = (List)arg;
				//for (Iterator it = exprs.iterator(); it.hasNext(); ) {
				for (int i = 0, n = exprs.size(); i < n; i++) {
					//Expression expr = (Expression)it.next();
					Expression expr = (Expression)exprs.get(i);
					exprs.set(i, wrapWithFunction(expr, funcname));
				}
				return exprs;
			}
			if (arg instanceof Map) {
				Map attrs = (Map)arg;
				for (Iterator it = attrs.keySet().iterator(); it.hasNext(); ) {
					String name = (String)it.next();
					attrs.put(name, wrapWithFunction(attrs.get(name), funcname));
				}
				return attrs;
			}
			return arg;
		}
		
		
		public static Expression wrapWithFunction(Expression expr, String funcname) {
			return new Ast.FuncallExpression(funcname, new Expression[] { expr });
		}
		
	}


}