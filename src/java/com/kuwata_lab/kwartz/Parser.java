/**
 *  @(#) Parser.java
 *  @Id  $Id$
 *  @copyright (C)2005 kuwata-lab.com all rights reserverd
 */
package com.kuwata_lab.kwartz;

public class Parser {
    protected Scanner _scanner;

    public Parser(Scanner scanner) {
        _scanner = scanner;
        _scanner.scan();
    }

    public int token() {
        return _scanner.getToken();
    }
    public String value() {
        return _scanner.getValue();
    }
    public int linenum() {
        return _scanner.getLinenum();
    }
    public int column() {
        return _scanner.getColumn();
    }
    public String filename() {
        return _scanner.getFilename();
    }
    public int scan() {
        return _scanner.scan();
    }

    public void reset(String input, int linenum) {
        _scanner.reset(input, linenum);
        _scanner.scan();
    }


    //abstract public Node parse(String code) throws SyntaxExpression;


    public void syntaxError(String msg) {
        throw new SyntaxException(msg, filename(), linenum(), column());
    }

    public void semanticError(String msg) {
        throw new SemanticException(msg, filename(), linenum(), column());
    }
}
