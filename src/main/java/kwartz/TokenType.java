/**
 *  @(#) TokenType.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */

package kwartz;

public class TokenType {

    // EOF
    public static final int EOF            =   0;  // <<EOF>>
    
    // arithmetic
    public static final int ADD            =   1;  // +
    public static final int SUB            =   2;  // -
    public static final int MUL            =   3;  // *
    public static final int DIV            =   4;  // /
    public static final int MOD            =   5;  // %
    public static final int CONCAT         =   6;  // .+
    
    // assignment
    public static final int ASSIGN         =   7;  // =
    public static final int ADD_TO         =   8;  // +=
    public static final int SUB_TO         =   9;  // -=
    public static final int MUL_TO         =  10;  // *=
    public static final int DIV_TO         =  11;  // /=
    public static final int MOD_TO         =  12;  // %=
    public static final int CONCAT_TO      =  13;  // .+=
    
    // literal
    public static final int STRING         =  14;  // <<string>>
    public static final int INTEGER        =  15;  // <<integer>>
    public static final int DOUBLE         =  16;  // <<double>>
    public static final int VARIABLE       =  17;  // <<variable>>
    public static final int TRUE           =  18;  // true
    public static final int FALSE          =  19;  // false
    public static final int NULL           =  20;  // null
    public static final int NAME           =  21;  // <<name>>
    
    // empty, not empty
    public static final int EMPTY          =  22;  // empty
    public static final int NOTEMPTY       =  23;  // notempty
    
    // array, hash
    public static final int ARRAY          =  24;  // []
    public static final int HASH           =  25;  // [:]
    public static final int L_BRACKET      =  26;  // [
    public static final int R_BRACKET      =  27;  // ]
    public static final int L_BRACKETCOLON =  28;  // [:
    
    // function, method, property
    public static final int FUNCTION       =  29;  // <<function>>
    public static final int METHOD         =  30;  // .()
    public static final int PROPERTY       =  31;  // .
    
    // relational op
    public static final int EQ             =  32;  // ==
    public static final int NE             =  33;  // !=
    public static final int LT             =  34;  // <
    public static final int LE             =  35;  // <=
    public static final int GT             =  36;  // >
    public static final int GE             =  37;  // >=
    
    // logical op
    public static final int NOT            =  38;  // !
    public static final int AND            =  39;  // &&
    public static final int OR             =  40;  // ||
    
    // unary op
    public static final int PLUS           =  41;  // +.
    public static final int MINUS          =  42;  // -.
    
    // statement
    public static final int BLOCK          =  43;  // :block
    public static final int PRINT          =  44;  // :print
    public static final int EXPR           =  45;  // :expr
    public static final int FOREACH        =  46;  // :foreach
    public static final int IN             =  47;  // :in
    public static final int WHILE          =  48;  // :while
    public static final int IF             =  49;  // :if
    public static final int ELSEIF         =  50;  // :elseif
    public static final int ELSE           =  51;  // :else
    public static final int EMPTYSTMT      =  52;  // :empty_stmt
    
    // symbols
    public static final int COLON          =  53;  // :
    public static final int SEMICOLON      =  54;  // ;
    public static final int L_PAREN        =  55;  // (
    public static final int R_PAREN        =  56;  // )
    public static final int L_CURLY        =  57;  // {
    public static final int R_CURLY        =  58;  // }
    public static final int CONDITIONAL    =  59;  // ?:
    public static final int PERIOD         =  60;  // .
    public static final int COMMA          =  61;  // ,
    
    // expand
    public static final int EXPAND         =  62;  // @
    //STAG		@stag
    //ETAG		@etag
    //CONT		@cont
    //ELEMENT		@element
    //CONTENT		@content
    
    // raw expression and raw statement
    public static final int RAWEXPR        =  63;  // <%= %>
    public static final int RAWSTMT        =  64;  // <% %>
    
    // element
    public static final int SHARP          =  65;  // #
    public static final int ENTRY          =  66;  // #
    public static final int VALUE          =  67;  // value:
    public static final int ATTR           =  68;  // attr:
    public static final int APPEND         =  69;  // append:
    public static final int REMOVE         =  70;  // remove:
    public static final int PLOGIC         =  71;  // plogic:
    public static final int TAGNAME        =  72;  // tagname:

    public static int assignToArithmetic(int token) {
        return token - TokenType.ADD_TO + TokenType.ADD;
    }
    public static int arithmeticToAssign(int token) {
        return token - TokenType.ADD + TokenType.ADD_TO;
    }

    public static String[] tokenNames = {
        //"(dummy)",
        "EOF",
        "ADD",
        "SUB",
        "MUL",
        "DIV",
        "MOD",
        "CONCAT",
        "ASSIGN",
        "ADD_TO",
        "SUB_TO",
        "MUL_TO",
        "DIV_TO",
        "MOD_TO",
        "CONCAT_TO",
        "STRING",
        "INTEGER",
        "DOUBLE",
        "VARIABLE",
        "TRUE",
        "FALSE",
        "NULL",
        "NAME",
        "EMPTY",
        "NOTEMPTY",
        "ARRAY",
        "HASH",
        "L_BRACKET",
        "R_BRACKET",
        "L_BRACKETCOLON",
        "FUNCTION",
        "METHOD",
        "PROPERTY",
        "EQ",
        "NE",
        "LT",
        "LE",
        "GT",
        "GE",
        "NOT",
        "AND",
        "OR",
        "PLUS",
        "MINUS",
        "BLOCK",
        "PRINT",
        "EXPR",
        "FOREACH",
        "IN",
        "WHILE",
        "IF",
        "ELSEIF",
        "ELSE",
        "EMPTYSTMT",
        "COLON",
        "SEMICOLON",
        "L_PAREN",
        "R_PAREN",
        "L_CURLY",
        "R_CURLY",
        "CONDITIONAL",
        "PERIOD",
        "COMMA",
        "EXPAND",
        "RAWEXPR",
        "RAWSTMT",
        "SHARP",
        "ENTRY",
        "VALUE",
        "ATTR",
        "APPEND",
        "REMOVE",
        "PLOGIC",
        "TAGNAME",
    };
    public static String tokenName(int token) {
        return tokenNames[token];
    }

    public static String[] tokenTexts = {
        //"(dummy)",
        "<<EOF>>",
        "+",
        "-",
        "*",
        "/",
        "%",
        ".+",
        "=",
        "+=",
        "-=",
        "*=",
        "/=",
        "%=",
        ".+=",
        "<<string>>",
        "<<integer>>",
        "<<double>>",
        "<<variable>>",
        "true",
        "false",
        "null",
        "<<name>>",
        "empty",
        "notempty",
        "[]",
        "[:]",
        "[",
        "]",
        "[:",
        "<<function>>",
        ".()",
        ".",
        "==",
        "!=",
        "<",
        "<=",
        ">",
        ">=",
        "!",
        "&&",
        "||",
        "+.",
        "-.",
        ":block",
        ":print",
        ":expr",
        ":foreach",
        ":in",
        ":while",
        ":if",
        ":elseif",
        ":else",
        ":empty_stmt",
        ":",
        ";",
        "(",
        ")",
        "{",
        "}",
        "?:",
        ".",
        ",",
        "@",
        "<%= %>",
        "<% %>",
        "#",
        "#",
        "value:",
        "attr:",
        "append:",
        "remove:",
        "plogic:",
        "tagname:",
    };
    public static String tokenText(int token) {
        return tokenTexts[token];
    }


    public static String inspect(int token) {
        return inspect(token, null);
    }

    public static String inspect(int token, String value) {
        switch (token) {
          case TokenType.STRING:
            return inspectString(value);
          case TokenType.INTEGER:
            return value;
          case TokenType.DOUBLE:
            return value;
          case TokenType.VARIABLE:
            return value;
          case TokenType.NAME:
            return value;
          case TokenType.RAWEXPR:
            return "<" + "%=" + value + "%" + ">";
          case TokenType.RAWSTMT:
            return "<" + "%" + value + "%" + ">";
          case TokenType.EXPAND:
            return "@" + value;
          default:
            return tokenTexts[token];
        }
    }

    public static String inspectString(String s) {
        StringBuffer sb = new StringBuffer();
        sb.append('"');
        for (int i = 0; i < s.length(); i++) {
            char ch = s.charAt(i);
            switch (ch) {
              case '\n':  sb.append("\\n");   break;
              case '\r':  sb.append("\\r");   break;
              case '\t':  sb.append("\\t");   break;
              case '\\':  sb.append("\\\\");  break;
              case '"':   sb.append("\\\"");  break;
              default:
                sb.append(ch);
            }
        }
        sb.append('"');
        return sb.toString();
    }

}
