/**
 *  @(#) TokenType.java
 *  @Id  $Id$
 *  @copyright (C)2005 kuwata-lab.com all rights reserverd
 */

package com.kuwata_lab.kwartz;

public class TokenType {

    // arithmetic
    public static final int ADD		= 1 ;	// '+'
    public static final int SUB		= 2 ;	// '-'
    public static final int MUL		= 3 ;	// '*'
    public static final int DIV		= 4 ;	// '/'
    public static final int MOD		= 5 ;	// '%'
    public static final int CONCAT	= 6 ;	// '.+'

    // assignment
    public static final int ASSIGN	= 7 ;	// '='
    public static final int ADD_TO	= 8 ;	// '+='
    public static final int SUB_TO	= 9 ;	// '-='
    public static final int MUL_TO	= 10 ;	// '*='
    public static final int DIV_TO	= 11 ;	// '/='
    public static final int MOD_TO	= 12 ;	// '%='
    public static final int CONCAT_TO	= 13 ;	// '.+='

    // literal
    public static final int STRING	= 14 ;	// string
    public static final int INTEGER	= 15 ;	// integer
    public static final int FLOAT	= 16 ;	// float
    public static final int VARIABLE	= 17 ;	// variable
    public static final int TRUE	= 18 ;	// variable
    public static final int FALSE	= 19 ;	// variable
    public static final int NULL	= 20 ;	// variable
    

    // array, hash, property
    public static final int ARRAY	= 21 ;	// var[expr]
    public static final int HASH	= 22 ;	// var[:name]
    public static final int PROPERTY	= 23 ;	// var.name

    // function
    public static final int FUNCTION	= 24 ;	// func(arg1, arg2)
    
    // conditional operator
    public static final int CONDITIONAL	= 25 ; // flag ? true : false

    // relational op
    public static final int EQ		= 26 ;	// '=='
    public static final int NE		= 27 ;	// '!='
    public static final int LT		= 28 ;	// '<'
    public static final int LE		= 29 ;	// '<='
    public static final int GT		= 30 ;	// '>'
    public static final int GE		= 31 ;	// '>='

    // logical op
    public static final int NOT		= 32 ;	// '!'
    public static final int AND		= 33 ;	// '&&'
    public static final int OR		= 34 ;	// '||'

    // statement
    public static final int BLOCK	= 35 ;	// { ... }
    public static final int PRINT	= 36 ;	// print(...)
    public static final int EXPR	= 37 ;	// expression ;
    public static final int FOREACH	= 38 ;	// foreach(var in list) ...
    public static final int WHILE	= 39 ;	// while(...) ...
    public static final int IF		= 40 ;	// while(...) ...
    public static final int EXPAND	= 41 ;	// @stag, @cont, @etag, @element(name)

    // element
    public static final int ELEMENT	= 42 ;	// element foo { ... }
    public static final int VALUE	= 43 ;	// value:
    public static final int ATTR	= 44 ;	// attr:
    public static final int APPEND	= 45 ;	// append:
    public static final int REMOVE	= 46 ;	// remove:
    public static final int PLOGIC	= 47 ;	// plogic:


    public static int assignToArithmetic(int token) {
        return token - TokenType.ADD_TO + TokenType.ADD;
    }
    public static int arithmeticToAssign(int token) {
        return token - TokenType.ADD + TokenType.ADD_TO;
    }
    
    public static String[] tokenNames = {
        "(dummy)",
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
        "ARRAY",
        "HASH",
        "PROPERTY",
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
        "WHILE",
        "IF",
        "EXPAND",
        "ELEMENT",
        "VALUE",
        "ATTR",
        "APPEND",
        "REMOVE",
        "PLOGIC",
    };
    public static String tokenName(int token) {
        return tokenNames[token];
    }
}
