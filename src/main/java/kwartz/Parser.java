/*
 * $Rev$
 * $Release$
 * $Copyright$
 */
package kwartz;

import java.util.List;
import java.util.Iterator;


abstract public class Parser implements Token {
  
  	private static String[] __tokens = { "<YYERRTOK>",
  		"<IDENT>",
  		"<VARIABLE>", "<INTEGER>", "<FLOAT>", "<STRING>", "true", "false", "null",
  		"+=", "-=", "*=", "/=", "%=",
  		".+", ".+=",
  		"==", "!=", ">", ">=", "<", "<=",
  		"&&", "||", "&&=", "||=",
  		"()", ".()", ".",
  		"[]", "[:]",
  		"+.", "-.", "?:",
  		
  		//
  		":PRINT", ":EXPR", ":IF", ":ELSEIF", ":ELSE", ":WHILE", ":FOREACH", ":BREAK", ":CONTINUE", ":BLOCK",
  		"<% %>", "<%= %>",
  		"_stag", "_cont", "_etag", "_elem", "_element", "_content",
  		
  		//
  		"<COMMAND>", "<SELECTOR>", "<DECLARATION>", "<RULESET>",
  		"stag:", "cont:", "etag:", "elem:", "value:", "attrs:", "append:", "remove:", "tagname:", "logic:",
  		"begin:", "end:", "before:", "after:", "global:",
  	};
  
  	static {
  		assert __tokens.length + Token.YYERRTOK != Token.ERROR;
  	}
  
  
  	public static String tokenSymbol(int token) {
  		if (token < Token.YYERRTOK) {  // YYERRTOK == 256
  			return Character.toString((char)token);
  		}
  		else {
  			return __tokens[token - Token.YYERRTOK];
  		}
  	}
  
  
  	/// -------------------------
  
  	static class Info {
  		int token;
  		String value;
  		int linenum;
  		int column;
  
  		public Info(int token, String value, int linenum, int column) {
  			this.token   = token;
  			this.value   = value;
  			this.linenum = linenum;
  			this.column  = column;
  		}
  
  		public int getToken() { return token; }
  		public String getValue() { return value; }
  		public int getLinenum() { return linenum; }
  		public int getColumn() { return column; }
  	}
  
  
  	/// -------------------------
  
  	Scanner _scanner;
  	int     _token;
  	ParseException _error;
  	NodeFactory _f = new NodeFactory();
  
  	static boolean __debug = false;
  
  	public int yylex() {
  		int    token   = _scanner.scan();
  		String value   = _scanner.getTokenValue();
  		int    linenum = _scanner.getStartLinenum();
  		int    column  = _scanner.getStartColumn();
  		//yylval = new Info(token, value, linenum, column);
  		Info info = new Info(token, value, linenum, column);
  		setYylval(info);
  		return _token = token;
  	}
  
  
  	public void yyerror(String msg) throws ParseException {
  		if (__debug) {
  			Object yyval = getYyval();
  			Object yylval = getYylval();
  			Object[] yyastk = getYyastk();
  			System.out.println("msg="+msg);
  			System.out.println("yyval="+Util.inspect(yyval));
  			System.out.println("yylval="+Util.inspect(yylval));
  			System.out.println("yyastk=[");
  			for (int i = 0, n = yyastk.length; i < n && i < 5; i++) {
  				System.err.println(yyastk[i]);
  			}
  			System.out.println("]");
  		}
  		_error = new SyntaxException(msg, _scanner.getStartLinenum(), _scanner.getStartColumn());
  		throw _error;
  	}
  
  
  	public Object parse(String input) throws ParseException {
  		_scanner = createScanner(input);
  		int result = yyparse();
  		
  		if (result != 0) {
  			if (_error == null)
  				_error = _scanner.getError();
  			throw _error;
  		}
  		Object obj = getYyval();
  		//return obj instanceof List ? new Statement.Block((List)obj) : (Node)obj;
  		return obj;
  	}
  	
  	
  	protected Scanner createScanner(String input) {
  		return new Scanner(input);
  	}
  
  	
  	abstract int      yyparse() throws ParseException;
  	abstract Object   getYyval();
  	abstract Object   getYylval();
  	abstract Object[] getYyastk();
  	abstract void     setYylval(Object val);
  

  	protected List handleCommand(String command, String arg, Parser.Info info) throws ParseException {
  		return handleCommand(command, arg, info.getLinenum(), info.getColumn());
  	}
  	
  	protected List handleCommand(String command, String arg, int linenum, int column) throws ParseException {
  		if (command.equals("import")) {
  			String filename = arg;
  			try {
  				String str = Util.readFile(filename);
  				Parser parser = new PresentationLogicParser();
  				List rulesets = (List)parser.parse(str);
  				return rulesets;
  			}
  			catch (Exception ex) {
  				throw new SemanticException(ex.getMessage(), linenum, column);
  			}
  		}
  		throw new SyntaxException("@"+command+"("+arg+"): unkown command.", linenum, column);
  	}
  	
  	static void debug(String msg) {
  		System.err.println("*** debug: "+msg);
  	}
  	static void debug(Object obj, String name) {
  		System.err.print("*** debug: "+name+"=");
  		if (obj == null) {
  			System.out.println("null");
  		} else if (obj instanceof Ast.Node){
  			System.out.println(((Ast.Node)obj).inspect());
  		} else {
  			System.out.println(Util.inspect(obj));
  		}
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
  		//Parser parser = new ExpressionParser();
  		//Expression.Binary expr = (Expression.Binary)parser.parse(input);
  		//debug(expr, "expr");
  		//
  		//String input = "break; continue;";
  		//Parser parser = new StatementParser();
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
  		Parser parser = new PresentationLogicParser();
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
