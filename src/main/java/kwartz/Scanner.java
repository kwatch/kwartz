/**
 *  @(#) Scanner.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
import java.util.Map;
import java.util.HashMap;
import java.util.Properties;

public class Scanner {
    private String _code;
    private int    _index;
    private int    _column;
    private int    _linenum;
    private String _filename;
    private char   _ch;
    private Properties _props;

    private int    _token;
    private StringBuffer _value = new StringBuffer();


    public Scanner() {
        this("", null, new Properties(Configuration.defaults));
    }
    public Scanner(Properties props) {
        this("", null, props);
    }
    public Scanner(String code) {
        this(code, null, new Properties(Configuration.defaults));
    }
    public Scanner(String code, Properties props) {
        this(code, null, props);
    }
    public Scanner(String code, String filename) {
        this(code, filename, new Properties(Configuration.defaults));
    }
    public Scanner(String code, String filename, Properties props) {
        _props = props;
        reset(code);
        _filename = filename;
    }

    public Properties getProperties() { return _props; }
    public String getProperty(String key) { return _props.getProperty(key); }
    //public String setProperty(String key, String value) { _props.setProperty(key, value); }

    public int getLinenum() { return _linenum; }
    public int getColumn()  { return _column; }
    public String getFilename() { return _filename; }
    public void setFilename(String filename) { _filename = filename; }
    public int getToken()   { return _token; }
    public String getValue()   { return _value.toString(); }
    //public String getCode() { return _code; }

    private void _clearValue() {
        _value.delete(0, _value.length());
    }

    public void reset(String code, int linenum) {
        _code    = code;
        _index   = -1;
        _column  = -1;
        _linenum = linenum;
        _token   = -1;
        _clearValue();
        read();
    }

    public void reset(String code) {
        reset(code, 1);
    }

    public char read() {
        _index++;
        _column++;
        if (_index >= _code.length()) {
            _ch = '\0';
            return _ch;
        }
        _ch = _code.charAt(_index);
        if (_ch == '\n') {
            _linenum++;
            _column = -1;         // Aha!
        }
        return _ch;
    }

    protected static Map keywords;
    protected static byte[] _op_table1  = new byte[Byte.MAX_VALUE];
    protected static byte[] _op_table2 = new byte[Byte.MAX_VALUE];
    protected static byte[] _op_table3 = new byte[Byte.MAX_VALUE];
    static {
        keywords = new HashMap();
        keywords.put("print",   new Integer(TokenType.PRINT));
        keywords.put("foreach", new Integer(TokenType.FOREACH));
        keywords.put("in",      new Integer(TokenType.IN));
        keywords.put("while",   new Integer(TokenType.WHILE));
        keywords.put("if",      new Integer(TokenType.IF));
        keywords.put("else",    new Integer(TokenType.ELSE));
        keywords.put("elseif",  new Integer(TokenType.ELSEIF));
        keywords.put("true",    new Integer(TokenType.TRUE));
        keywords.put("false",   new Integer(TokenType.FALSE));
        keywords.put("null",    new Integer(TokenType.NULL));
        keywords.put("empty",   new Integer(TokenType.EMPTY));
        //
        _op_table1['+'] = TokenType.ADD;
        _op_table1['-'] = TokenType.SUB;
        _op_table1['*'] = TokenType.MUL;
        _op_table1['/'] = TokenType.DIV;
        _op_table1['%'] = TokenType.MOD;
        _op_table1['='] = TokenType.ASSIGN;
        _op_table1['!'] = TokenType.NOT;
        _op_table1['<'] = TokenType.LT;
        _op_table1['>'] = TokenType.GT;
        //
        _op_table2['+'] = TokenType.ADD_TO;
        _op_table2['-'] = TokenType.SUB_TO;
        _op_table2['*'] = TokenType.MUL_TO;
        _op_table2['/'] = TokenType.DIV_TO;
        _op_table2['%'] = TokenType.MOD_TO;
        _op_table2['='] = TokenType.EQ;
        _op_table2['!'] = TokenType.NE;
        _op_table2['<'] = TokenType.LE;
        _op_table2['>'] = TokenType.GE;
        //
        _op_table3['('] = TokenType.L_PAREN;
        _op_table3[')'] = TokenType.R_PAREN;
        _op_table3['{'] = TokenType.L_CURLY;
        _op_table3['}'] = TokenType.R_CURLY;
        _op_table3[']'] = TokenType.R_BRACKET;
        _op_table3['?'] = TokenType.CONDITIONAL;
        _op_table3[':'] = TokenType.COLON;
        _op_table3[';'] = TokenType.SEMICOLON;
        _op_table3[','] = TokenType.COMMA;
        _op_table3['#'] = TokenType.SHARP;
    }

    public int scan() throws LexicalException {
        String msg;
        char ch, ch2;
        int start_linenum, start_column;

        // ignore whitespaces
        ch = _ch;
        while (CharacterUtil.isWhitespace(ch)) {
            ch = read();
        }

        // EOF
        if (ch == '\0')
            return _token = TokenType.EOF;

        // keyword, ture, false, null, name
        if (CharacterUtil.isAlphabet(ch)) {
            _clearValue();
            _value.append(ch);
            while ((ch = read()) != '\0' && CharacterUtil.isWordLetter(ch)) {
                _value.append(ch);
            }
            Integer keyword = (Integer)keywords.get(_value.toString());
            _token = keyword != null ? keyword.intValue() : TokenType.NAME;
            return _token;
        }

        // integer, double
        if (CharacterUtil.isDigit(ch)) {
            _clearValue();
            _value.append(ch);
            _token = TokenType.INTEGER;
            while (true) {
                while ((ch = read()) != '\0' && CharacterUtil.isDigit(ch)) {
                    _value.append(ch);
                }
                if (CharacterUtil.isAlphabet(ch) || ch == '_') {
                    _value.append(ch);
                    while ((ch = read()) != '\0' && CharacterUtil.isWordLetter(ch)) {
                        _value.append(ch);
                    }
                    msg = "'" + _value.toString() + "': invalid token.";
                    throw new LexicalException(msg, getFilename(), _linenum, _column);
                }
                if (ch != '.') {
                    break;
                } else if (_token == TokenType.INTEGER) {
                    _token = TokenType.DOUBLE;
                    _value.append('.');
                    continue;
                } else {
                    msg = "'" + _value.toString() + "': invalid double.";
                    throw new LexicalException(msg, getFilename(), _linenum, _column);
                }
            }
            return _token;
        }

        // string literal
        if (ch == '\'' || ch == '"') {
            start_linenum = _linenum;
            start_column  = _column;
            _clearValue();
            char quote = ch;
            while ((ch = read()) != '\0' && ch != quote) {
                if (ch == '\\') {
                    switch (quote) {
                      case '\'':
                        if ((ch = read()) != '\'' && ch != '\\') _value.append('\\');
                        break;
                      case '"':
                        ch = read();
                        switch (ch) {
                          case 'n':  ch = '\n';  break;
                          case 't':  ch = '\t';  break;
                          case 'r':  ch = '\r';  break;
                        }
                        break;
                      default:
                        assert false;
                    }
                }
                _value.append(ch);
            }
            if (ch == '\0') {
                msg = "string literal is not closed by " + (quote == '\'' ? "\"'\"." : "'\"'.");
                throw new LexicalException(msg, getFilename(), start_linenum, start_column);
            }
            read();
            return _token = TokenType.STRING;
        }

        // comment
        if (ch == '/') {
            ch = read();
            if (ch == '/') {   // line comment
                while ((ch = read()) != '\0' && ch != '\n')
                    ;
                if (ch == '\0')
                    return _token = TokenType.EOF;
                read();
                return scan();
            }
            if (ch == '*') {   // region comment
                start_linenum = _linenum;
                start_column  = _column;
                while ((ch = read()) != '\0') {
                    if (ch == '*') {
                        if ((ch = read()) == '/') {
                            read();
                            return scan();
                        }
                    }
                }
                if (ch == '\0') {
                    msg = "'/*' is not closed by '*/'.";
                    throw new LexicalException(msg, getFilename(), start_linenum, start_column);
                }
                assert false;
            }
            if (ch == '=') {
                read();
                return _token = TokenType.DIV_TO;
            }
            return _token = TokenType.DIV;
        }

        // < <= <%...%> <?...?>
        if (ch == '<') {
            ch = read();
            if (ch == '=') {
                read();
                return _token = TokenType.LE;
            }
            if (ch == '%' || ch == '?') {
                char delim = ch;
                start_linenum = _linenum;
                start_column  = _column;
                _clearValue();
                ch = read();
                if (ch == '=') {
                    ch = read();
                    _token = TokenType.RAWEXPR;
                } else {
                    _token = TokenType.RAWSTMT;
                }
                while (ch != '\0') {
                    if (ch == delim) {
                        ch = read();
                        if (ch == '>') break;
                        _value.append('%');
                    }
                    _value.append(ch);
                    ch = read();
                }
                if (ch == '\0') {
                    String stag = "<" + delim + (_token == TokenType.RAWEXPR ? "=" : "");
                    String etag = "" + delim + ">";
                    msg = "'" + stag + "' is not closed by '" + etag + "'.";
                    throw new LexicalException(msg, getFilename(), start_linenum, start_column);
                }
                read();
                return _token;
            }
            return _token = TokenType.LT;
        }

        // + - * / % = ! < >
        if (ch < 128 && _op_table1[ch] != 0) {
            ch2 = read();
            if (ch2 == '=') {
                read();
                return _token = _op_table2[ch];
            }
            return _token = _op_table1[ch];
        }

        // &&, ||
        if (ch == '&' || ch == '|') {
            ch2 = read();
            if (ch != ch2) {
                msg = "'" + ch + "': invalid token.";
                throw new LexicalException(msg, getFilename(), _linenum, _column);
            }
            read();
            return _token = ch == '&' ? TokenType.AND : TokenType.OR;
        }

        // [ [:
        if (ch == '[') {
            ch = read();
            if (ch == ':') {
                read();
                return _token = TokenType.L_BRACKETCOLON;
            }
            return _token = TokenType.L_BRACKET;
        }

        // @
        if (ch == '@') {
            _clearValue();
            while ((ch = read()) != '\0' && CharacterUtil.isWordLetter(ch)) {
                _value.append(ch);
            }
            return _token = TokenType.EXPAND;
        }

        // .
        if (ch == '.') {
            if ((ch = read()) != '+') return _token = TokenType.PERIOD;
            if ((ch = read()) != '=') return _token = TokenType.CONCAT;
            read();
            return _token = TokenType.CONCAT_TO;
        }
        //if (ch == '.') {
        //    ch = read();
        //    if (ch == '+') {
        //        ch = read();
        //        if (ch == '=') {
        //            read();
        //            return _token = TokenType.CONCAT_TO;
        //        }
        //        return _token = TokenType.CONCAT;
        //    }
        //    return _token = TokenType.PERIOD;
        //}


        // ( ) ] : ? ; , #
        if (ch < Byte.MAX_VALUE && _op_table3[ch] != 0) {
            read();
            return _token = _op_table3[ch];
        }

        msg = "'" + ch + "': invalid character.";
        throw new LexicalException(msg, getFilename(), _linenum, _column);
    }

}
