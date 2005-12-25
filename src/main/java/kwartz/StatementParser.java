/**
 *  @(#) StatementParser.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.Properties;

import kwartz.node.BlockStatement;
import kwartz.node.EmptyStatement;
import kwartz.node.ExpandStatement;
import kwartz.node.Expression;
import kwartz.node.ExpressionStatement;
import kwartz.node.ForeachStatement;
import kwartz.node.IfStatement;
import kwartz.node.PrintStatement;
import kwartz.node.RawcodeStatement;
import kwartz.node.Statement;
import kwartz.node.VariableExpression;
import kwartz.node.WhileStatement;

/**
 * 
 * @author kwatch
 *
 */
public class StatementParser extends Parser {
    private ExpressionParser _exprParser;

    public StatementParser() {
        this(new Scanner());
    }
    public StatementParser(Properties props) {
        this(new Scanner(props));
    }
    public StatementParser(Scanner scanner) {
        this(scanner, scanner.getProperties());
    }
    public StatementParser(Scanner scanner, Properties props) {
        this(scanner, props, true);
    }
    public StatementParser(Scanner scanner, Properties props, boolean flagInit) {
        super(scanner, props);
        _exprParser = new ExpressionParser(scanner, props, false);
        if (flagInit) _scanner.scan();
    }

    public ExpressionParser getExpressionParser() { return _exprParser; }



    /*
     *  BNF:
     *
     */
    public Statement parseStatement() {
        int t = getToken();
        Statement stmt = null;
        switch (t) {
          //case TokenType.R_CURLY:
          //  stmt = null;
          //  break;
          case TokenType.L_CURLY:
            stmt = parseBlockStatement();
            break;
          case TokenType.PRINT:
            stmt = parsePrintStatement();
            break;
          case TokenType.NAME:
          case TokenType.L_PAREN:
            stmt = parseExpressionStatement();
            break;
          case TokenType.IF:
            stmt = parseIfStatement();
            break;
          case TokenType.FOREACH:
          //case TokenType.FOR:
            stmt = parseForeachStatement();
            break;
          case TokenType.WHILE:
            stmt = parseWhileStatement();
            break;
          case TokenType.EXPAND:
            stmt = parseExpandStatement();
            break;
          case TokenType.SHARP:
            stmt = parseElementStatement();
            break;
          case TokenType.RAWSTMT:
            stmt = parseRawcodeStatement();
            break;
          case TokenType.SEMICOLON:
            stmt = parseEmptyStatement();
            break;
          default:
            syntaxError("statement expected but got '" + getToken() + "'.");
        }
        return stmt;
    }


    /*
     * BNF:
     *  stmt-list    ::=  statement | stmt-list statement
     *               ::=  statement { statement }
     *  block-stmt   ::=  '{' '}' | '{' stmt-list '}'
     */
    public Statement parseBlockStatement() {
        assert getToken() == TokenType.L_CURLY;
        int start_linenum = getLinenum();
        scan();
        Statement[] stmts = parseStatementList();
        if (getToken() != TokenType.R_CURLY)
            syntaxError("block-statement(starts at line " + start_linenum + ") requires '}'.");
        scan();
        return new BlockStatement(stmts);
    }

    public Statement[] parseStatementList() {
        List list = new ArrayList();
        Statement stmt;
        while (getToken() != TokenType.EOF) {
            if (getToken() == TokenType.R_CURLY)
                break;
            stmt = parseStatement();
            list.add(stmt);
            //if (! (stmt instanceof EmptyStatement)) {
            //    list.add(stmt);
            //}
        }
        Statement[] stmts = new Statement[list.size()];
        list.toArray(stmts);
        return stmts;
    }


    /*
     *  BNF:
     *    print-stmt   ::=  'print' '(' arguments ')' ';'
     */
    public Statement parsePrintStatement() {
        assert getToken() == TokenType.PRINT;
        int t = scan();
        if (t != TokenType.L_PAREN)
            syntaxError("print-statement requires '('.");
        t = scan();
        Expression[] args = _exprParser.parseArguments();
        if (getToken() != TokenType.R_PAREN)
            syntaxError("print-statement requires ')'.");
        t = scan();
        if (t != TokenType.SEMICOLON)
            syntaxError("print-statement requires ';'.");
        scan();
        return new PrintStatement(args);
    }

    /*
     *  BNF:
     *
     */
    public Statement parseExpressionStatement() {
        //assert getToken() == TokenType.NAME || getToken() == TokenType.L_PAREN;
        Expression expr = _exprParser.parseExpression();
        if (getToken() != TokenType.SEMICOLON)
            syntaxError("expression-statement requires ';'.");
        scan();
        return new ExpressionStatement(expr);
    }


    /*
     *  BNF:
     *    if-stmt     ::=  'if' '(' expression ')' statement
     *                   | 'if' '(' expression ')' statement elseif-part
     *                   | 'if' '(' expression ')' statement elseif-part 'else' statement
     *                ::=  'if' '(' expression ')' statement
     *                      { 'elseif' '(' expression ')' statement }
     *                      [ 'else' statement ]
     */
    public Statement parseIfStatement() {
        assert getToken() != TokenType.IF || getToken() != TokenType.ELSEIF;
        String word = getToken() == TokenType.IF ? "if" : "elseif";
        int t = scan();
        if (t != TokenType.L_PAREN)
            syntaxError(word + "-statement requires '('.");
        scan();
        Expression condition = _exprParser.parseExpression();
        if (getToken() != TokenType.R_PAREN)
            syntaxError(word + "-statement requires ')'.");
        scan();
        Statement thenBody = parseStatement();
        Statement elseBody = null;
        if (getToken() == TokenType.ELSEIF) {
            elseBody = parseIfStatement();
        } else if (getToken() == TokenType.ELSE) {
            scan();
            elseBody = parseStatement();
        }
        return new IfStatement(condition, thenBody, elseBody);
    }


    /*
     *  BNF:
     *    foreach-stmt ::=  'foreach' '(' variable 'in' expression ')' statement
     */
    public Statement parseForeachStatement() {
        assert getToken() == TokenType.FOREACH;
        int t = scan();
        if (t != TokenType.L_PAREN)
            syntaxError("foreach-statement requires '('.");
        t = scan();
        if (t != TokenType.NAME)
            syntaxError("foreach-statement requires loop-variable but got '" + TokenType.inspect(getToken(), getValue()) + "'.");
        String varname = getValue();
        VariableExpression loopvar = new VariableExpression(varname);
        t = scan();
        if (t != TokenType.IN && t != TokenType.ASSIGN)
            syntaxError("foreach-statement requires loop-variable but got '" + TokenType.inspect(getToken(), getValue()) + "'.");
        scan();
        Expression list = _exprParser.parseExpression();
        if (getToken() != TokenType.R_PAREN)
            syntaxError("foreach-statement requires ')'.");
        scan();
        Statement body = parseStatement();
        return new ForeachStatement(loopvar, list, body);
    }


    /*
     *  BNF:
     *    while-stmt   ::=  'while' '(' expression ')' statement
     */
    public Statement parseWhileStatement() {
        assert getToken() == TokenType.WHILE;
        scan();
        if (getToken() != TokenType.L_PAREN)
            syntaxError("while-statement requires '('");
        scan();
        Expression condition = _exprParser.parseExpression();
        if (getToken() != TokenType.R_PAREN)
            syntaxError("while-statement requires ')'");
        scan();
        Statement body = parseStatement();
        return new WhileStatement(condition, body);
    }


    /*
     *  BNF:
     *
     */
    public Statement parseExpandStatement() {
        assert getToken() == TokenType.EXPAND;
        String marking = null;
        String typeStr = getValue();
        Integer typeObj = (Integer)_expandTypes.get(typeStr);
        if (typeObj == null)
            syntaxError("'@" + typeStr + "': invalid expand statement.");
        int type = typeObj.intValue();
        if (type == ExpandStatement.CONTENT || type == ExpandStatement.ELEMENT) {
            scan();
            if (getToken() != TokenType.L_PAREN)
                syntaxError("`@" + typeStr + "' requires '('.");
            scan();
            if (getToken() != TokenType.NAME)
                syntaxError("`@" + typeStr + "()' requires a marking name.");
            marking = getValue();
            scan();
            if (getToken() != TokenType.R_PAREN)
                syntaxError("`@" + typeStr + "' requires ')'.");
        }
        scan();
        if (getToken() != TokenType.SEMICOLON)
            syntaxError("`@" + typeStr + "()' requires ';'.");
        scan();
        return new ExpandStatement(type, marking);
    }

    private static final Map _expandTypes = new HashMap();
    static {
        _expandTypes.put("stag",    new Integer(ExpandStatement.STAG));
        _expandTypes.put("cont",    new Integer(ExpandStatement.CONT));
        _expandTypes.put("etag",    new Integer(ExpandStatement.ETAG));
        _expandTypes.put("content", new Integer(ExpandStatement.CONTENT));
        _expandTypes.put("element", new Integer(ExpandStatement.ELEMENT));
    }


    /*
     *  BNF:
     *
     */
    public Statement parseElementStatement() {
        return null;
    }


    /*
     *  BNF:
     *
     */
    public Statement parseRawcodeStatement() {
        assert getToken() == TokenType.RAWSTMT;
        String rawcode = getValue();
        scan();
        return new RawcodeStatement(rawcode);
    }


    /*
     *  BNF:
     *
     */
    public Statement parseEmptyStatement() {
        assert getToken() == TokenType.SEMICOLON;
        scan();
        return new EmptyStatement();
    }


    /*
     *
     */
    public BlockStatement parse(String input) {
        return parse(input, 1);
    }
    public BlockStatement parse(String input, int baselinenum) {
        _scanner.reset(input, baselinenum);
        _scanner.scan();
        Statement[] stmts = parseStatementList();
        if (getToken() != TokenType.EOF)
            syntaxError("EOF expected but '" + TokenType.inspect(getToken(), getValue()) + "'.");
        return new BlockStatement(stmts);
    }

}
