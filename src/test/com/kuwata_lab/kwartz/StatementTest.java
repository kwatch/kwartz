/**
 *  @(#) StatementTest.java
 *  @Id  $Id$
 *  @copyright (C)2005 kuwata-lab.com all rights reserverd
 */

package com.kuwata_lab.kwartz;
import junit.framework.TestCase;
import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;
import java.io.Writer;
import java.io.StringWriter;
import java.io.IOException;

public class StatementTest extends TestCase {
    private Map _context = new HashMap();
    private Statement _stmt;

    public void _testPrint(String expected) {
        _testPrint(expected, _stmt);
    }
    
    public void _testPrint(String expected, Statement stmt) {
        try {
            StringWriter writer = new StringWriter();
            stmt.execute(_context, writer);
            String actual = writer.toString();
            assertEquals(expected, actual);
        }
        catch (IOException ex) {
            ex.printStackTrace();
        }
    }

    public void _testInspect(String expected) {
        _testInspect(expected, _stmt);
    }
    
    public void _testInspect(String expected, Statement stmt) {
        assertEquals(expected, stmt._inspect());
    }
    
    public void testPrintStatement1() {  // literal
        Expression[] arglist = {
            new IntegerExpression(123),
            new StringExpression("foo"),
            new FloatExpression(0.4f),
            new BooleanExpression(true),
            new BooleanExpression(false),
            new NullExpression(),
        };
        Statement stmt = new PrintStatement(arglist);
        _testPrint("123foo0.4truefalse", stmt);
    }

    public void testPrintStatement2() {  // variable
        Expression[] arglist = {
            new VariableExpression("x"),
            new VariableExpression("y"),
        };
        _context.put("x", new String("foo"));
        _context.put("y", new Integer(123));
        Statement stmt = new PrintStatement(arglist);
        _testPrint("foo123", stmt);
    }

    public void testPrintStatement3() {  // null value
        Expression[] arglist = {
            new VariableExpression("x"),
            new VariableExpression("y"),
        };
        _context.put("x", new String("foo"));
        //_context.put("y", new Integer(123));
        Statement stmt = new PrintStatement(arglist);
        _testPrint("foo", stmt);
    }

    public void testPrintStatement4() {  // expression
        Expression x = new VariableExpression("x");
        Expression y = new VariableExpression("y");
        _context.put("x", new Integer(20));
        _context.put("y", new Integer(5));
        Expression[] arglist = {
            new ArithmeticExpression(TokenType.SUB,
                                     x,
                                     new ArithmeticExpression(TokenType.MUL,
                                                              new IntegerExpression(2),
                                                              y)),
            new ConcatenationExpression(TokenType.CONCAT,
                                        new StringExpression("foo"),
                                        new StringExpression("bar")),
        };
        Statement stmt = new PrintStatement(arglist);
        _testPrint("10foobar", stmt);
    }

    public void testExpressinStatement1() { // x = y = 100
        Expression expr;
        expr = new AssignmentExpression(TokenType.ASSIGN,
                                        new VariableExpression("x"),
                                        new AssignmentExpression(TokenType.ASSIGN,
                                                                 new VariableExpression("y"),
                                                                 new IntegerExpression(100)));
        Statement stmt = new ExpressionStatement(expr);
        try {
            stmt.execute(_context, null);
        } catch (IOException ex) {
            ex.printStackTrace();
        }
        assertEquals(_context.get("x"), new Integer(100));
        assertEquals(_context.get("y"), new Integer(100));
    }

    public void testBlockStatement1() { // { x = 10; x += 1; print(x); }
        Expression x = new VariableExpression("x");
        Expression v = new IntegerExpression(10);
        Expression d = new IntegerExpression(1);
        Expression expr1 = new AssignmentExpression(TokenType.ASSIGN, x, v);
        Expression expr2 = new AssignmentExpression(TokenType.ADD_TO, x, d);
        Expression[] arglist = { x };
        Statement[] stmts = {
            new ExpressionStatement(expr1),
            new ExpressionStatement(expr2),
            new PrintStatement(arglist),
        };
        Statement stmt = new BlockStatement(stmts);
        _testPrint("11", stmt);
        assertEquals(_context.get("x"), new Integer(11));
    }

    public void testForeachStatement1() {  // foreach(item in list) { print "item = ", item, "\n"; }
        // list = [ "foo", 123, "list" ]
        List list = new ArrayList();
        list.add("foo");
        list.add(new Integer(123));
        list.add("bar");
        _context.put("list", list);

        // print "item = ", item, "\n"
        Expression[] args = {
            new StringExpression("item = "),
            new VariableExpression("item"),
            new StringExpression("\n"),
        };
        Statement[] stmts = {
            new PrintStatement(args),
        };

        // foreach(...) { ... }
        Statement block = new BlockStatement(stmts);
        Statement stmt = new ForeachStatement(new VariableExpression("item"),
                                              new VariableExpression("list"),
                                              block);

        // test
        StringBuffer sb = new StringBuffer();
        sb.append("item = foo\n");
        sb.append("item = 123\n");
        sb.append("item = bar\n");
        _testPrint(sb.toString(), stmt);
    }


    public void testWhileStatement1() {  // while (...) { ... }
        // i = 5;
        Expression i = new VariableExpression("i");
        _context.put("i", new Integer(5));

        // i > 0
        Expression condition = new RelationalExpression(TokenType.GT, i, new IntegerExpression(0));

        // i -= 1; print i;
        Expression assign = new AssignmentExpression(TokenType.SUB_TO, i, new IntegerExpression(1));
        Expression[] args = { new VariableExpression("i"), new StringExpression(","), };
        Statement[] stmts = {
            new ExpressionStatement(assign),
            new PrintStatement(args),
        };

        // while (...) { ... }
        Statement block = new BlockStatement(stmts);
        Statement stmt = new WhileStatement(condition, block);

        // test
        String expected = "4,3,2,1,0,";
        _testPrint(expected, stmt);
    }

    public void testIfStatement1() {
        Expression condition1 = new RelationalExpression(TokenType.EQ,
                                                         new StringExpression("foo"),
                                                         new StringExpression("foo"));
        Expression condition2 = new RelationalExpression(TokenType.EQ,
                                                         new StringExpression("foo"),
                                                         new StringExpression("bar"));
        Expression[] args1 = { new StringExpression("Yes"), };
        Expression[] args2 = { new StringExpression("No"), };
        Statement then_body = new PrintStatement(args1);
        Statement else_body = new PrintStatement(args2);
        Statement stmt;
        stmt = new IfStatement(condition1, then_body, null);
        _testPrint("Yes", stmt);
        stmt = new IfStatement(condition2, then_body, null);
        _testPrint("", stmt);
        stmt = new IfStatement(condition1, then_body, else_body);
        _testPrint("Yes", stmt);
        stmt = new IfStatement(condition2, then_body, else_body);
        _testPrint("No", stmt);
    }

    // -----
    
    public static void main(String[] args) {
       junit.textui.TestRunner.run(StatementTest.class);
    }
}
