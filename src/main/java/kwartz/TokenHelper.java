/*
 * $Rev$
 * $Release$
 * $Copyright$
 */
package kwartz;


public class TokenHelper implements Token {
	
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
  		"ERROR",
  	};
  
  	static {
  		assert __tokens.length + Token.YYERRTOK == Token.ERROR;
  	}
  
  
  	public static String tokenSymbol(int token) {
  		if (token < Token.YYERRTOK) {  // YYERRTOK == 256
  			return Character.toString((char)token);
  		}
  		else {
  			try {
  				return __tokens[token - Token.YYERRTOK];
  			}
  			catch (RuntimeException ex) {
  				System.err.println("*** debug: token=" + token);
  				for (int i = 0, n = __tokens.length; i < n; i++) {
  					System.err.println("*** __tokens["+i+"]="+__tokens[i]);
  				}
  				throw ex;
  			}
  		}
  	}
  

}
