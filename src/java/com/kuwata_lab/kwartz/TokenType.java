/**
 *  @(#) TokenType.java
 *  @Id  $Id$
 *  @copyright (C)2005 kuwata-lab.com all rights reserverd
 */

package com.kuwata_lab.kwartz;

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
    public static final int FLOAT          =  16;  // <<float>>
    public static final int VARIABLE       =  17;  // <<variable>>
    public static final int TRUE           =  18;  // true
    public static final int FALSE          =  19;  // false
    public static final int NULL           =  20;  // null
    public static final int EMPTY          =  21;  // empty
    public static final int NAME           =  22;  // <<name>>
    
    // array, hash, property
    public static final int ARRAY          =  23;  // []
    public static final int HASH           =  24;  // [:]
    public static final int PROPERTY       =  25;  // .
    public static final int L_BRACKET      =  26;  // [
    public static final int R_BRACKET      =  27;  // ]
    public static final int L_BRACKETCOLON =  28;  // [:
    
    // function
    public static final int FUNCTION       =  29;  // <<function>>
    
    // conditional operator
    public static final int CONDITIONAL    =  30;  // ?
    
    // relational op
    public static final int EQ             =  31;  // ==
    public static final int NE             =  32;  // !=
    public static final int LT             =  33;  // <
    public static final int LE             =  34;  // <=
    public static final int GT             =  35;  // >
    public static final int GE             =  36;  // >=
    
    // logical op
    public static final int NOT            =  37;  // !
    public static final int AND            =  38;  // &&
    public static final int OR             =  39;  // ||
    
    // statement
    public static final int BLOCK          =  40;  // <<block>>
    public static final int PRINT          =  41;  // :print
    public static final int EXPR           =  42;  // :expr
    public static final int FOREACH        =  43;  // :foreach
    public static final int IN             =  44;  // :in
    public static final int WHILE          =  45;  // :while
    public static final int IF             =  46;  // :if
    public static final int ELSEIF         =  47;  // :elseif
    public static final int ELSE           =  48;  // :else
    public static final int EXPAND         =  49;  // @
    
    // raw expression and raw statement
    public static final int RAWEXPR        =  50;  // <%= %>
    public static final int RAWSTMT        =  51;  // <% %>
    
    // element
    public static final int ELEMENT        =  52;  // #
    public static final int VALUE          =  53;  // value:
    public static final int ATTR           =  54;  // attr:
    public static final int APPEND         =  55;  // append:
    public static final int REMOVE         =  56;  // remove:
    public static final int PLOGIC         =  57;  // plogic:
    public static final int TAGNAME        =  58;  // tagname:

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
        "FLOAT",
        "VARIABLE",
        "TRUE",
        "FALSE",
        "NULL",
        "EMPTY",
        "NAME",
        "ARRAY",
        "HASH",
        "PROPERTY",
        "L_BRACKET",
        "R_BRACKET",
        "L_BRACKETCOLON",
        "FUNCTION",
        "CONDITIONAL",
        "EQ",
        "NE",
        "LT",
        "LE",
        "GT",
        "GE",
        "NOT",
        "AND",
        "OR",
        "BLOCK",
        "PRINT",
        "EXPR",
        "FOREACH",
        "IN",
        "WHILE",
        "IF",
        "ELSEIF",
        "ELSE",
        "EXPAND",
        "RAWEXPR",
        "RAWSTMT",
        "ELEMENT",
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
        "<<float>>",
        "<<variable>>",
        "true",
        "false",
        "null",
        "empty",
        "<<name>>",
        "[]",
        "[:]",
        ".",
        "[",
        "]",
        "[:",
        "<<function>>",
        "?",
        "==",
        "!=",
        "<",
        "<=",
        ">",
        ">=",
        "!",
        "&&",
        "||",
        "<<block>>",
        ":print",
        ":expr",
        ":foreach",
        ":in",
        ":while",
        ":if",
        ":elseif",
        ":else",
        "@",
        "<%= %>",
        "<% %>",
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
          case TokenType.FLOAT:
            return value;
          case TokenType.VARIABLE:
            return value;
          case TokenType.NAME:
            return value;
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
              case '"':   sb.append("\\\"");  break;
              default:
                sb.append(ch);
            }
        }
        sb.append('"');
        return sb.toString();
    }

}
