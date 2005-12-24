/**
 *  @(#) StatementTest.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
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
    private String _expected = null;

    public void _testPrint() {
        try {
            StringWriter writer = new StringWriter();
            _stmt.execute(_context, writer);
            String actual = writer.toString();
            assertEquals(_expected, actual);
        }
        catch (IOException ex) {
            ex.printStackTrace();
        }
    }

    public void _testInspect() {
        assertEquals(_expected, _stmt._inspect());
    }

    public void testPrintStatement1() {  // literal
        Expression[] arglist = {
            new IntegerExpression(123),
            new StringExpression("foo"),
            new DoubleExpression(0.4),
            new BooleanExpression(true),
            new BooleanExpression(false),
            new NullExpression(),
        };
        _stmt = new PrintStatement(arglist);
        _expected = "123foo0.4truefalse";
        _testPrint();
    }

    public void testPrintStatement2() {  // variable
        Expression[] arglist = {
            new VariableExpression("x"),
            new VariableExpression("y"),
        };
        _context.put("x", new String("foo"));
        _context.put("y", new Integer(123));
        _stmt = new PrintStatement(arglist);
        _expected = "foo123";
        _testPrint();
    }

    public void testPrintStatement3() {  // null value
        Expression[] arglist = {
            new VariableExpression("x"),
            new VariableExpression("y"),
        };
        _context.put("x", new String("foo"));
        //_context.put("y", new Integer(123));
        _stmt = new PrintStatement(arglist);
        _expected = "foo";
        try {
            _testPrint();
            fail("EvaluationException expected but not happened.");
        } catch (EvaluationException ex) {
            // OK
        }
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
        _stmt = new PrintStatement(arglist);
        _expected = "10foobar";
        _testPrint();
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
        _stmt = new BlockStatement(stmts);
        _expected = "11";
        _testPrint();
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
        _stmt = new ForeachStatement(new VariableExpression("item"),
                                     new VariableExpression("list"),
                                     block);

        // test
        _expected = ""
                    + "item = foo\n"
                    + "item = 123\n"
                    + "item = bar\n"
                    ;
        _testPrint();
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
        _stmt = new WhileStatement(condition, block);

        // test
        _expected = "4,3,2,1,0,";
        _testPrint();
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
        _stmt = new IfStatement(condition1, then_body, null);
        _expected = "Yes";
        _testPrint();
        _stmt = new IfStatement(condition2, then_body, null);
        _expected = "";
        _testPrint();
        _stmt = new IfStatement(condition1, then_body, else_body);
        _expected = "Yes";
        _testPrint();
        _stmt = new IfStatement(condition2, then_body, else_body);
        _expected = "No";
        _testPrint();
    }

    // -----

    public static void main(String[] args) {
       junit.textui.TestRunner.run(StatementTest.class);
    }
}
