/*
 * $Rev$
 * $Release$
 * $Copyright$
 */
package kwartz;

import java.util.Map;
import java.util.HashMap;

public class Scanner {

	private String _filename;
	private String _input;
	private int    _input_length;
	private int    _linenum = 1;
	private int    _column = 0;
	private int    _index = -1;
	private int    _ch;
	private String _token_value;
	private int    _start_linenum;
	private int    _start_column;
	private boolean _is_ruleset = false;
	private LexicalException _error;
	private StringBuffer _sbuf = new StringBuffer();
	
	
	public String getTokenValue() {
		return _token_value;
	}
	
	public LexicalException getError() {
		return _error;
	}
	
	public int getLinenum() {
		return _linenum;
	}
	
	public int getColumn() {
		return _column;
	}
	
	public int getStartLinenum() {
		return _start_linenum;
	}
	
	public int getStartColumn() {
		return _start_column;
	}
	
	public void setRulesetMode(boolean is_ruleset) {
		_is_ruleset = is_ruleset;
	}

	
	public Scanner(String input) {
		this(input, null);
	}


	public Scanner(String input, String filename) {
		_filename = filename;
		_input = input == null ? "" : input;
		_input_length = _input.length();
		// init
		getChar();
	}


//	public int getChar() {
//		_index++;
//		if (_index >= _input_length)
//			return _ch = 0;
//		_ch = _input.charAt(_index);
//		if (_ch == '\n') {
//			_linenum++;
//			_column = 0;
//		}
//		else {
//			_column++;
//		}
//		return _ch;
//	}
	public int getChar() {
		_index++;
		if (_index >= _input_length)
			return _ch = 0;
		if (_ch == '\n') {
			_linenum++;
			_column = 1;
		}
		else {
			_column++;
		}
		_ch = _input.charAt(_index);
		return _ch;
	}
	
	
	public static boolean isAlphabet(int ch) {
		return 'a' <= ch && ch <= 'z' || 'A' <= ch && ch <= 'Z';
	}
	
	
	public static boolean isDigit(int ch) {
		//return Character.isDigit(ch);
		return '0' <= ch && ch <= '9';
	}
	
	
	public static boolean isWhite(int ch) {
		return Character.isWhitespace(ch);
	}


	protected LexicalException error(String message, int linenum, int column) {
		return new LexicalException(message, _filename, linenum, column);
	}
	
	
	public int scanIdentifier() {
		int ch = _ch;
		if (!isAlphabet(ch) && ch != '_') {
			return 0;
		}
		StringBuffer sbuf = _sbuf;
		sbuf.setLength(0);
		sbuf.append((char)ch);
		while (isAlphabet(ch = getChar()) || isDigit(ch) || ch == '_') {
			sbuf.append((char)ch);
		}
		_token_value = sbuf.toString();
		return Token.IDENT;
	}


	/*
	public String scanInteger() {
		int ch = _ch;
		if (!isDigit(ch)) {
			return null;
		}
		StringBuffer sbuf = _sbuf;
		sbuf.setLength(0);
		sbuf.append((char)ch);
		while (isDigit(ch = getChar())) {
			sbuf.append((char)ch);
		}
		return sbuf.toString();
	}
	*/
	
	
	public int scanNumber() {
		int ch = _ch;
		if (!isDigit(ch)) {
			return 0;
		}
		StringBuffer sbuf = _sbuf;
		sbuf.setLength(0);
		sbuf.append((char)ch);
		while (isDigit(ch = getChar())) {
			sbuf.append((char)ch);
		}
		if (ch != '.') {
			_token_value = sbuf.toString();
			return Token.INTEGER;
		}
		sbuf.append((char)ch);
		while (isDigit(ch = getChar())) {
			sbuf.append((char)ch);
		}
		_token_value = sbuf.toString();
		return Token.FLOAT;
	}
	
	
	public int scanString() {
		if (_ch == '\'') {
			return scanSingleQuotedString();
		}
		else if (_ch == '"') {
			return scanDoubleQuotedString();
		}
		assert false;  /* unreachable */
		return 0;
	}
	
	
	public int scanSingleQuotedString() {
		int ch = _ch;
		if (ch != '\'')
			return 0;
		int start_linenum = _linenum;
		int start_column  = _column;
		StringBuffer sbuf = _sbuf;
		sbuf.setLength(0);
		while ((ch = getChar()) != '\'' && ch != 0) {
			if (ch == '\\') {
				ch = getChar();
				if (ch == 0)
					break;
				if (ch != '\\' && ch != '\'')
					sbuf.append('\\');
			}
			sbuf.append((char)ch);
		}
		if (ch == 0) {
			_error = error("'\\'': string is not closed.", start_linenum, start_column);
			return Token.ERROR;
		}
		assert ch == '\'';
		getChar();
		_token_value = sbuf.toString();
		return Token.STRING;
	}
	
	
	public int scanDoubleQuotedString() {
		int ch = _ch;
		if (ch != '"')
			return 0;
		int start_linenum = _linenum;
		int start_column = _column;
		StringBuffer sbuf = _sbuf;
		sbuf.setLength(0);
		while ((ch = getChar()) != '"' && ch != 0) {
			if (ch == '\\') {
				ch = getChar();
				switch (ch) {
				case 'n':  sbuf.append('\n');  break;
				case 'b':  sbuf.append('\b');  break;
				case 'r':  sbuf.append('\r');  break;
				case 't':  sbuf.append('\t');  break;
				case 'f':  sbuf.append('\f');  break;
				case '"':  sbuf.append('"');   break;
				case '\\': sbuf.append('\\');  break;
				default:   sbuf.append('\\');  sbuf.append((char)ch);
				}
			}
			else {
				sbuf.append((char)ch);
			}
		}
		if (ch == 0) {
			_error = error("'\"': string is not closed.", start_linenum, start_column);
			return Token.ERROR;
		}
		assert ch == '"';
		getChar();
		_token_value = sbuf.toString();
		return Token.STRING;
	}

	
	public int scan() {
		//return _token_id = _scan();
		return _scan();
	}
	
	
	private int _scan() {
		int ch = _ch;
		while (isWhite(ch)) {
			ch = getChar();
		}
		if (ch == 0)
			return 0;
		_start_linenum = _linenum;
		_start_column  = _column;

		/// '/', '/=', '/*', '//'
		if (ch == '/') {
			ch = getChar();
			if (ch == '*') {        /// region comment
				int start_linenum = _linenum;
				int start_column = _column;
				while (true) {
					while ((ch = getChar()) != '*' && ch != 0)
						;
					if (ch == 0) {
						_error = error("comment is not closed.", start_linenum, start_column);
						return Token.ERROR;
					}
					if ((ch = getChar()) != '/')  /// comment is closed
						continue;
					getChar();
					return _scan();  // call recursively
				}
			}
			else if (ch == '/') {   /// line comment
				while ((ch = getChar()) != '\n' && ch != 0)
					;
				if (ch == 0)
					return 0;
				return _scan();  // call recursively
			}
			else if (_is_ruleset) {
				return _invalidChar('/');
			}
			else if (ch == '=') {
				ch = getChar();
				return Token.SLASH_EQ;   // "/="
			}
			else {
				return '/';
			}
		}

		/// ruleset mode
		if (_is_ruleset) {
			return _scanForRuleset(ch);
		}
		
		/// keyword or identifier
		if (isAlphabet(ch) || ch == '_') {
			scanIdentifier();
			Integer obj = (Integer)__keywords.get(_token_value);
			return obj != null ? obj.intValue() : Token.IDENT;
		}
		
		/// number
		if (isDigit(ch)) {
			int start_linenum = _linenum;
			int start_column = _column;
			int token = scanNumber();
			if (isAlphabet(_ch) || _ch == '_') {
				String numstr = _token_value;
				scanIdentifier();
				_error = error("'" + numstr + _token_value + "': invalid word.", start_linenum, start_column);
				return Token.ERROR;
			}
			return token;
		}
		
		/// string
		if (ch == '"' || ch == '\'') {
			return scanString();
		}
		
		
		/// '<', '<=', '<%', '<%='
		if (ch == '<') {
			ch = getChar();
			if (ch == '=') {
				getChar();
				return Token.LE;  // "<="
			}
			else if (ch == '%') {
				int start_linenum = _linenum;
				int start_column = _column;
				ch = getChar();
				boolean is_expr = false;
				String start_pat = "<%";
				if (ch == '=') {
					ch = getChar();
					is_expr = true;
					start_pat = "<%=";
				}
				StringBuffer sbuf = _sbuf;
				sbuf.setLength(0);
				while (true) {
					while (ch != '%' && ch != 0) {
						sbuf.append((char)ch);
						ch = getChar();
					}
					if (ch == 0) {
						_error = error("'" + start_pat + "': native code is not closed.", start_linenum, start_column);
						return Token.ERROR;
					}
					ch = getChar();
					if (ch == '>')
						break;
					sbuf.append('%').append(ch);
					ch = getChar();
				}
				_token_value = sbuf.toString();
				return is_expr ? Token.NATIVE_EXPR : Token.NATIVE_STMT;
			}
			else {
				return '<';
			}
		}

		/// '+', '-', '*', '%', '=', '!', '>'
		if (   ch == '+' || ch == '-' || ch == '*' || ch == '%'
			|| ch == '=' || ch == '!' || ch == '>') {
			if (getChar() != '=')
				return ch;
			getChar();
			switch (ch) {
			case '+':  return Token.PLUS_EQ;       // '+='
			case '-':  return Token.MINUS_EQ;      // '-='
			case '*':  return Token.STAR_EQ;       // '*='
			case '/':  return Token.SLASH_EQ;      // '/='
			case '%':  return Token.PERCENT_EQ;    // '%='
			case '=':  return Token.EQ;            // '=='
			case '!':  return Token.NE;            // '!='
			case '>':  return Token.GE;            // '>='
			default:   assert false;
			}
		}

		/// '&&', '||'
		if (ch == '&' || ch == '|') {
			int ch2 = getChar();
			int linenum = _linenum;
			int column = _column;
			if (ch != ch2) {
				_error = error("'" + ch + "': invalid character.", linenum, column);
				return Token.ERROR;
			}
			ch2 = getChar();
			if (ch2 != '=')
				return ch == '&' ? Token.AND : Token.OR;  // "&&" : "||"
			getChar();
			return ch == '&' ? Token.AND_EQ : Token.OR_EQ;  // "&&=" : "||="
		}

		/// '{', '}', '(', ')', ']', ';', ',', '?', ':'
		if (   ch == '{' || ch == '}' || ch == '(' || ch == ')' || ch == ']'
			|| ch == ';' || ch == ',' || ch == '?' || ch == ':') {
			getChar();
			return ch;
		}
		
		/// '.', '.+', '.+='
		if (ch == '.') {
			if (getChar() != '+')
				return '.';
			if (getChar() != '=')
				return Token.CONCAT;  // '.+'
			getChar();
			return Token.CONCAT_EQ;   // '.+='
		}
		
		/// '[:', '['
		if (ch == '[') {
			if (getChar() != ':')
				return '[';  // '[';
			getChar();
			return Token.INDEX2;     // '[:'
		}
		
		//_token_value = Character.toString((char)ch);
		//return ":ERROR";
		return _invalidChar(ch);
	}
	
	
	private int _invalidChar(int ch) {
		_token_value = Character.toString((char)ch);
		_error = error("'" + (char)ch + "': invalid character.", _start_linenum, _start_column);
		return Token.ERROR;   // or ch ?
	}
	
	
	private int _scanForRuleset(int ch) {
		if (ch == '#' || ch == '.') {
			int ch2 = getChar();
			if (! isAlphabet(ch2) && ch2 != '_')
				return _invalidChar(ch);
			scanIdentifier();
			_token_value = Character.toString((char)ch) + _token_value;
			return Token.SELECTOR;
		}
		if (ch == '{' || ch == '}' || ch == ':' || ch == ';' || ch == ',') {
			getChar();
			return ch;
		}
		if (ch == '@') {
			int ch2 = getChar();
			if (! isAlphabet(ch2) && ch2 != '_')
				return _invalidChar(ch);
			scanIdentifier();
			return Token.COMMAND;
		}
		if (ch == '"' || ch == '\'') {
			return scanString();
		}
		if (isAlphabet(ch) || ch == '_') {
			scanIdentifier();
			String word = _token_value;
			Integer intobj = (Integer)__properties.get(word);
			return intobj != null ? intobj.intValue() : Token.IDENT; 
		}
		return _invalidChar(ch);
	}
	
	
	private static Map __keywords;
	private static Map __properties;
	static {
		__keywords = new HashMap();
		__keywords.put("if",       new Integer(Token.IF));
		__keywords.put("else",     new Integer(Token.ELSE));
		__keywords.put("elseif",   new Integer(Token.ELSEIF));
		__keywords.put("foreach",  new Integer(Token.FOREACH));
		__keywords.put("while",    new Integer(Token.WHILE));
		__keywords.put("print",    new Integer(Token.PRINT));
		__keywords.put("break",    new Integer(Token.BREAK));
		__keywords.put("continue", new Integer(Token.CONTINUE));
		__keywords.put("true",     new Integer(Token.TRUE));
		__keywords.put("false",    new Integer(Token.FALSE));
		__keywords.put("null",     new Integer(Token.NULL));
		__keywords.put("_stag",    new Integer(Token.STAG));
		__keywords.put("_cont",    new Integer(Token.CONT));
		__keywords.put("_etag",    new Integer(Token.ETAG));
		__keywords.put("_elem",    new Integer(Token.ELEM));
		__keywords.put("_element", new Integer(Token.ELEMENT));
		__keywords.put("_content", new Integer(Token.CONTENT));
		
		__properties = new HashMap();
		__properties.put("stag",    new Integer(Token.P_STAG));
		__properties.put("Stag",    new Integer(Token.P_STAG));
		__properties.put("STAG",    new Integer(Token.P_STAG));
		__properties.put("etag",    new Integer(Token.P_ETAG));
		__properties.put("Etag",    new Integer(Token.P_ETAG));
		__properties.put("ETAG",    new Integer(Token.P_ETAG));
		__properties.put("cont",    new Integer(Token.P_CONT));
		__properties.put("Cont",    new Integer(Token.P_CONT));
		__properties.put("CONT",    new Integer(Token.P_CONT));
		__properties.put("elem",    new Integer(Token.P_ELEM));
		__properties.put("Elem",    new Integer(Token.P_ELEM));
		__properties.put("ELEM",    new Integer(Token.P_ELEM));
		__properties.put("value",   new Integer(Token.P_VALUE));
		__properties.put("Value",   new Integer(Token.P_VALUE));
		__properties.put("VALUE",   new Integer(Token.P_VALUE));
		__properties.put("attrs",   new Integer(Token.P_ATTRS));
		__properties.put("Attrs",   new Integer(Token.P_ATTRS));
		__properties.put("ATTRS",   new Integer(Token.P_ATTRS));
		__properties.put("append",  new Integer(Token.P_APPEND));
		__properties.put("Append",  new Integer(Token.P_APPEND));
		__properties.put("APPEND",  new Integer(Token.P_APPEND));
		__properties.put("remove",  new Integer(Token.P_REMOVE));
		__properties.put("tagname", new Integer(Token.P_TAGNAME));
		__properties.put("logic",   new Integer(Token.P_LOGIC));
		__properties.put("begin",   new Integer(Token.P_BEGIN));
		__properties.put("end",     new Integer(Token.P_END));
		__properties.put("before",  new Integer(Token.P_BEFORE));
		__properties.put("after",   new Integer(Token.P_AFTER));
		__properties.put("global",  new Integer(Token.P_GLOBAL));
	}

	
	public static void main(String[] args) throws Exception {
		String input;
		input = "if (x > 0) { print(x); }";
		input = "while (x && y || z) { x + y * z / 3 .+ \"foo\"; }";
		
		Scanner scanner = new Scanner(input);
		int token;
		while ((token = scanner.scan()) != 0) {
			System.out.println("token="+TokenHelper.tokenSymbol(token)+"("+token+"), value="+scanner.getTokenValue());
		}
	}


}
