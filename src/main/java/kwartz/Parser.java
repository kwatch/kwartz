/*
 * $Rev$
 * $Release$
 * $Copyright$
 */
package kwartz;

import java.util.List;
import java.util.Iterator;
import java.util.Stack;



class ParseInfo {
	int    _token;
	String _value;
	int    _linenum;
	int    _column;
  
	public ParseInfo(int token, String value, int linenum, int column) {
		_token   = token;
		_value   = value;
		_linenum = linenum;
		_column  = column;
	}
  
	public int getToken()    { return _token; }
	public String getValue() { return _value; }
	public int getLinenum()  { return _linenum; }
	public int getColumn()   { return _column; }	
	
	
	public String getWord() {
		if (_token < 256) {
			return Character.toString((char)_token);
		}
		switch (_token) {
		case Token.IDENT:
		case Token.STRING:
		case Token.INTEGER:
		case Token.FLOAT:
		case Token.TRUE:
		case Token.FALSE:
		case Token.NULL:
			return getValue();
		case Token.PRINT:
		case Token.IF:
		case Token.ELSEIF:
		case Token.ELSE:
		case Token.WHILE:
		case Token.FOREACH:
		case Token.BREAK:
		case Token.CONTINUE:
			return getValue();
		}
		return TokenHelper.tokenSymbol(_token);
	}

	public int getEndLinenum() {
		String word = getWord();
		return getLinenum() + Util.count(word, '\n'); 
	}
	
	public int getEndColumn() {
		String word = getWord();
		int pos = word.lastIndexOf('\n');
		int n = pos < 0 ? getColumn() + word.length() : word.length() - pos - 1;
		return getToken() == Token.STRING ? n + 2 : n; 
	}
	
	
	public String inspect() {
		return inspect(0);
	}

	public String inspect(int level) {
		StringBuffer sb = new StringBuffer();
		_inspect(level, sb);
		return sb.toString();
	}
	
	void _inspect(int level, StringBuffer sb) {
		for (int i = 0; i < level; i++)
			sb.append("  ");
		sb.append("<ParseInfo:");
		sb.append(_linenum).append(':').append(_column).append(':').append('\'');
		sb.append(TokenHelper.tokenSymbol(_token)).append('\'').append(':').append(Util.inspect(_value));
		sb.append(">");
	}
}
  
 

abstract public class Parser implements Token {
	
	// ----------------------- moved from kmyacc.kwartz.parser
	/** lexical element object **/
	protected Object yylval;

	/** Semantic value */
	protected Object yyval;

	/** Semantic stack **/
	protected Object yyastk[];

	/** Syntax stack **/
	protected short yysstk[];

	/** Stack pointer **/
	protected int yysp;

	/** Error handling state **/
	protected int yyerrflag;
	
	/** lookahead token **/
	protected int yychar;
	// -----------------------

	
	String  _filename;
  	Scanner _scanner;
  	int     _token;
  	int     _expected;
  	Stack   _block_stack = new Stack();
  	Object  _prev_yylval;
  	ParseException _error;
  	NodeFactory _f;
  	  

  	public int yylex() {
  		int    token   = _scanner.scan();
  		String value   = _scanner.getTokenValue();
  		int    linenum = _scanner.getStartLinenum();
  		int    column  = _scanner.getStartColumn();
  		_prev_yylval = yylval;
  		ParseInfo info = new ParseInfo(token, value, linenum, column);
  		yylval = info;
  		//setYylval(info);
  		return _token = token;
  	}


  	abstract int      yyparse() throws ParseException;
  	//abstract Object   getYyval();
  	//abstract Object   getYylval();
  	//abstract Object[] getYyastk();
  	//abstract void     setYylval(Object val);

  	
  	public Object parse(String input) throws ParseException {
  		return parse(input, null);
  	}
  	
  	public Object parse(String input, String filename) throws ParseException {
  		_filename = filename;
  		_scanner = createScanner(input, filename);
  		_f = new NodeFactory(filename);
  		int result = -1;
  		try {
  			result = yyparse();
  		}
  		catch (ParseException ex) {
  			if (ex.getFilename() == null)
  				ex.setFilename(_filename);
  			throw ex;
  		}
  		
  		if (result != 0) {
  			if (_error == null)
  				_error = _scanner.getError();
  			throw _error;
  		}
  		//Object obj = getYyval();
  		Object obj = yyval;
  		//return obj instanceof List ? new Statement.Block((List)obj) : (Node)obj;
  		return obj;
  	}

  	
  	static boolean __debug = false;
    
  	public void yyerror(String msg) throws ParseException {
  		int linenum = _scanner.getStartLinenum();
  		int column  = _scanner.getStartColumn();
  		
  		boolean block_not_closed = false;
  		if (_expected != 0) {
  			switch (_expected) {
  			case 'X':   msg = "expression syntax error.";   break;
  			case 'N':   msg = "element name expected.";     break;
  			case 'S':   msg = "selector expected.";         break;
  			case 'A':   msg = "attribute name expected.";   break;
  			default:    msg = "'" + Character.toString((char)_expected) + "' expected.";
  			}
  			ParseInfo pinfo = (ParseInfo)yylval;
  			if (_expected == ';' && _prev_yylval != null) {
  				ParseInfo prev_info = (ParseInfo)_prev_yylval;
  				linenum = prev_info.getEndLinenum();
  				column  = prev_info.getEndColumn();
  			}
  			else if (_expected == '{') {
  				if (pinfo.getToken() == Token.SELECTOR)
  					msg = "compound selector is not available.";
  			}
  			else if (_expected == '}') {
  				if (pinfo.getToken() == Token.IDENT && pinfo.getValue().equals("attr"))
  					msg = "'attr' may be typo of 'attrs'.";
  				else if (! _block_stack.empty())
  					block_not_closed = true;
  			}
  		}
  		else if (!_block_stack.empty()) {
  			block_not_closed = true;
  		}
  		if (block_not_closed) {
  			ParseInfo info = (ParseInfo)_block_stack.pop();
  			msg = "'{' is not closed.";
  			linenum = info.getLinenum();
  			column  = info.getColumn();
  		}
  		if (__debug) {
  			System.err.println("_expected="+Character.toString((char)_expected));
  			//
  			//Object yyval = getYyval();
  			//Object yylval = getYylval();
  			//Object[] yyastk = getYyastk();
  			System.err.println("msg="+msg);
  			//System.err.println("yyval="+Util.inspect(yyval));
  			//System.err.println("yylval="+Util.inspect(yylval));
  			System.err.println("yyval="+_inspectObj(yyval));
  			System.err.println("yylval="+_inspectObj(yylval));
  			System.err.println("yysp="+yysp);
  			System.err.println("yychar="+yychar+"("+TokenHelper.tokenSymbol(yychar)+")");
  			System.err.println("yysstk=[");
  			for (int i = 0,n = yysstk.length; i < n && i <= yysp; i++) {
  				System.err.println("yysstk["+i+"]="+yysstk[i]);
  			}
  			System.err.println("yyastk=[");
  			for (int i = 0, n = yyastk.length; i < n && i <= yysp+4; i++) {
  				System.err.println("yyastk["+i+"]="+_inspectObj(yyastk[i]));
  			}
  			System.err.println("]");
  		}
  		_error = new SyntaxException(msg, _filename, linenum, column);
  		throw _error;
  	}
  
  
  	String _inspectObj(Object obj) {
  		if (obj instanceof ParseInfo) {
  			return ((ParseInfo)obj).inspect();
  		}
  		else if (obj instanceof Ast.Node) {
  			Ast.Node node = (Ast.Node)obj;
  			String s = node.inspect();
  			return "<"+node.getClass().getName()+":"+s.substring(0, s.length()-1)+">";
  		}
  		else {
  			return Util.inspect(obj);
  		}
  	}
  	
  	
  	void enterBlock() {
  		_block_stack.push(yylval);    // ParseInfo:'{'
  	}
  	
  	void exitBlock() {
  		ParseInfo info = (ParseInfo)_block_stack.pop();
  		assert info != null;
  	}
  	
  	
  	protected Scanner createScanner(String input, String filename) {
  		return new Scanner(input, filename);
  	}
  

  	protected List handleCommand(String command, String arg, ParseInfo info) throws ParseException {
  		return handleCommand(command, arg, info.getLinenum(), info.getColumn());
  	}
  	
  	
  	
  	
  	
  	
  	protected List handleCommand(String command, String arg, int linenum, int column) throws ParseException {
  		if (command.equals("import")) {
  			String filename = arg;
  			try {
  				String str = Util.readFile(filename);
  				Parser parser = new UniversalPresentationLogicParser();
  				List rulesets = (List)parser.parse(str);
  				return rulesets;
  			}
  			catch (Exception ex) {
  				throw new SemanticException(ex.getMessage(), _filename, linenum, column);
  			}
  		}
  		throw new SyntaxException("'@"+command+"': unknown command.", _filename, linenum, column);
  	}
  	

	public static int detectEscapeFlag(String propname) {
		if (Character.isLowerCase(propname.charAt(0)))
			return 0;
		else if (Character.isLowerCase(propname.charAt(propname.length()-1)))
			return 1;
		else
			return -1;
	}

	
  	public static void main(String[] args) throws ParseException {
  		//String input = "3 + 1";
  		//Parser parser = new UniversalExpressionParser();
  		//Expression.Binary expr = (Expression.Binary)parser.parse(input);
  		//debug(expr, "expr");
  		//
  		//String input = "break; continue;";
  		//Parser parser = new UniversalStatementParser();
  		//Statement stmt = (Statement)parser.parse(input);
  		//System.out.println(stmt.inspect());
  		//
  		//String input = "#foo { stag: foo(); etag: bar(); cont: baz(); elem: boo(); }";
  		//String input = "#foo { value: x; attrs: 'class' klass, 'href' 'http://'.+host; append: flag?' checked':''; }";
  		//String input = "#foo { remove: 'foo', 'bar'; tagname: 'html:logic'; }";
  		//String input = "#foo {logic: { i=0; foreach (item=list) { i+=1;_stag; _cont; _etag; }}}";
  		//String input = "#foo { ATTRS: 'class' klass, 'href' url; }";
  		String input = "" 
  		    + "@import 'foobar.plogic';\n"
  		    ;
  		Parser parser = new UniversalPresentationLogicParser();
  		System.err.println("*** debug: parser created.");
  		List rulesets = null;
  		try {
  			rulesets = (List)parser.parse(input);
  		} catch (ParseException ex) {
  			System.err.println("** debug: ex.class="+ex.getClass().getName());
  		}
  		//List rulesets = (List)parser.parse(input);
  		System.err.println("*** debug: rulesets="+Util.inspect(rulesets));
  		for (Iterator it = rulesets.iterator(); it.hasNext(); ) {
  			Ast.Ruleset ruleset = (Ast.Ruleset)it.next();
  			System.out.println(ruleset.inspect());
  		}
  	}


}
