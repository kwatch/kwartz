/**
 *  @(#) ExpressionParserTest.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

import kwartz.node.*;
import junit.framework.TestCase;

public class ExpressionParserTest extends TestCase {

    String _input;
    String _expected;

    public ExpressionParser _test(String method) {
        return _test(method, null);
    }

    public ExpressionParser _test(String method, Class klass) {
        Scanner scanner = new Scanner(_input);
        ExpressionParser parser = new ExpressionParser(scanner);
        Expression expr = null;
        if (method.equals("parseLiteral")) {
            expr = parser.parseLiteral();
        } else if (method.equals("parseItem")) {
            expr = parser.parseItem();
        } else if (method.equals("parseFactor")) {
            expr = parser.parseFactor();
        } else if (method.equals("parseUnary")) {
            expr = parser.parseUnary();
        } else if (method.equals("parseTerm")) {
            expr = parser.parseTerm();
        } else if (method.equals("parseArithmetic")) {
            expr = parser.parseArithmetic();
        } else if (method.equals("parseRelational")) {
            expr = parser.parseRelational();
        } else if (method.equals("parseLogicalAnd")) {
            expr = parser.parseLogicalAnd();
        } else if (method.equals("parseLogicalOr")) {
            expr = parser.parseLogicalOr();
        } else if (method.equals("parseConditional")) {
            expr = parser.parseConditional();
        } else if (method.equals("parseAssignment")) {
            expr = parser.parseAssignment();
        } else if (method.equals("parseExpression")) {
            expr = parser.parseExpression();
        } else {
            fail("*** invalid method name ***");
        }
        if (expr == null) fail("*** expr is null ***");
        if (klass != null) {
            assertEquals(klass, expr.getClass());
        }
        StringBuffer actual = expr._inspect();
        assertEquals(_expected, actual.toString());
        assertTrue("*** EOF expected ***", scanner.getToken() == TokenType.EOF);
        return parser;
    }

    public void testParseLiteral1() {  // integer
        _input = "100";
        _expected = "100\n";
        _test("parseLiteral", IntegerExpression.class);
    }
    public void testParseLiteral2() {  // double
        _input = "3.14";
        _expected = "3.14\n";
        _test("parseLiteral", DoubleExpression.class);
    }
    public void testParseLiteral3() {  // 'string'
        _input = "'foo'";
        _expected = "\"foo\"\n";
        _test("parseLiteral", StringExpression.class);
        _input = "'\\n\\r\\t\\\\ \\''";              // '\n\r\t\\\\ \''
        _expected = "\"\\\\n\\\\r\\\\t\\\\ '\"\n";   // "\\n\\r\\t\\ '"
        _test("parseLiteral", StringExpression.class);
    }
    public void testParseLiteral4() {  // "string"
        _input = "\"foo\"";
        _expected = "\"foo\"\n";
        _test("parseLiteral", StringExpression.class);
        _input = "\"\\n\\r\\t \\\\ \\\" \"";        // "\n\r\t \\ \" "
        _expected = "\"\\n\\r\\t \\\\ \\\" \"\n";   // "\n\r\t \\ \" "
        _test("parseLiteral", StringExpression.class);
    }
    public void testParseLiteral5() {  // true, false
        _input = "true";
        _expected = "true\n";
        _test("parseLiteral", BooleanExpression.class);
        _input = "false";
        _expected = "false\n";
        _test("parseLiteral", BooleanExpression.class);
    }
    public void testParseLiteral6() {  // null
        _input = "null";
        _expected = "null\n";
        _test("parseLiteral", NullExpression.class);
    }


    public void testParseItem1() {  // variable
        _input = "foo";
        _expected = "foo\n";
        _test("parseItem", VariableExpression.class);
    }
    public void testParseItem2() {  // function()
        _input = "foo()";
        _expected = "foo()\n";
        _test("parseItem", FunctionExpression.class);
    }
    public void testParseItem3() {  // function(100, 'va', arg)
        _input = "foo(100, 'val', arg)";
        _expected = ""
                    + "foo()\n"
                    + "  100\n"
                    + "  \"val\"\n"
                    + "  arg\n"
                    ;
        _test("parseItem", FunctionExpression.class);
    }
    public void testParseItem4() {  // (expr)
        _input = "(a+b)";
        _expected = ""
                    + "+\n"
                    + "  a\n"
                    + "  b\n"
                    ;
        _test("parseItem", ArithmeticExpression.class);
    }
    public void testParseItem5() { // macro C(), S(), D()
        _input = "C(flag)";
        _expected = ""
                    + "?:\n"
                    + "  flag\n"
                    + "  \" checked=\\\"checked\\\"\"\n"
                    + "  \"\"\n"
                    ;
        _test("parseItem", ConditionalExpression.class);
        _input = "S(gender=='M')";
        _expected = ""
                    + "?:\n"
                    + "  ==\n"
                    + "    gender\n"
                    + "    \"M\"\n"
                    + "  \" selected=\\\"selected\\\"\"\n"
                    + "  \"\"\n"
                    ;
        _test("parseItem", ConditionalExpression.class);
        _input = "D(error!=null)";
        _expected = ""
                    + "?:\n"
                    + "  !=\n"
                    + "    error\n"
                    + "    null\n"
                    + "  \" disabled=\\\"disabled\\\"\"\n"
                    + "  \"\"\n"
                    ;
        _test("parseItem", ConditionalExpression.class);
    }
    public void testParseItem6() { // arity of macros
        _input = "C(arg1, arg2)";
        _expected = "";
        try {
            _test("parseItem", ConditionalExpression.class);
            fail("SemanticError expected but not throwed.");
        } catch (SemanticException ex) {
            // OK
        }
    }

    public void testParseFactor1() {  // array
        _input = "a[10]";
        _expected = ""
                    + "[]\n"
                    + "  a\n"
                    + "  10\n"
                    ;;
        _test("parseFactor", IndexExpression.class);
        _input = "a[i+1]";
        _expected = "[]\n  a\n  +\n    i\n    1\n";
        _test("parseFactor", IndexExpression.class);
    }
    public void testParseFactor2() {  // hash
        _input = "a[:foo]";
        _expected = ""
                    + "[:]\n"
                    + "  a\n"
                    + "  \"foo\"\n"
                    ;
        _test("parseFactor", IndexExpression.class);
    }
    public void testParseFactor3() {  // property
        _input = "obj.prop1";
        _expected = ""
                    + ".\n"
                    + "  obj\n"
                    + "  prop1\n"
                    ;
        _test("parseFactor", PropertyExpression.class);
    }
    public void testParseFactor4() {  // method
        _input = "obj.method1(arg1,arg2)";
        _expected = ""
                    + ".()\n"
                    + "  obj\n"
                    + "  method1()\n"
                    + "    arg1\n"
                    + "    arg2\n"
                    ;
        _test("parseFactor", MethodExpression.class);
    }
    public void testParseFactor5() {  // nested array,hash
        _input = "a[i][:j][k]";
        _expected = ""
                    + "[]\n"
                    + "  [:]\n"
                    + "    []\n"
                    + "      a\n"
                    + "      i\n"
                    + "    \"j\"\n"
                    + "  k\n"
                    ;
        _test("parseFactor", IndexExpression.class);
        _input = "foo.bar.baz()";
        _expected = ""
                    + ".()\n"
                    + "  .\n"
                    + "    foo\n"
                    + "    bar\n"
                    + "  baz()\n"
                    ;
        _test("parseFactor", MethodExpression.class);
    }

    public void testParseFactor6() {  // invalid array
        _input = "a[10;";
        _expected = null;
        try {
            _test("parseFactor", IndexExpression.class);
        } catch (SyntaxException ex) {
            // OK
        }
    }
    public void testParseFactor7() {
        _input = "a[:+]";
        _expected = null;
        try {
            _test("parseFactor", IndexExpression.class);
        } catch (SyntaxException ex) {
            // OK
        }
        _input = "a[:foo-bar]";
        _expected = null;
        try {
            _test("parseFactor", IndexExpression.class);
        } catch (SyntaxException ex) {
            // OK
        }
    }


    public void testParseUnary1() {  // -1, +a, !false
        _input = "-1";
        _expected = ""
                    + "-.\n"
                    + "  1\n"
                    ;
        _test("parseUnary", UnaryExpression.class);
        _input = "+a";
        _expected = ""
                    + "+.\n"
                    + "  a\n"
                    ;
        _test("parseUnary", UnaryExpression.class);
        _input = "!false";
        _expected = ""
                    + "!\n"
                    + "  false\n"
                    ;
        _test("parseUnary", UnaryExpression.class);
    }

    public void testParseUnary2() { // - - 1
        _input = "- -1";
        _expected = null;
        try {
            _test("parseUnary");
        } catch (SyntaxException ex) {
            // OK
        }
    }

    public void testParseTerm1() {  // term
        _input = "-x*y";
        _expected = ""
                    + "*\n"
                    + "  -.\n"
                    + "    x\n"
                    + "  y\n"
                    ;
        _test("parseTerm", ArithmeticExpression.class);
        _input = "a*b/c%d";
        _expected = ""
                    + "%\n"
                    + "  /\n"
                    + "    *\n"
                    + "      a\n"
                    + "      b\n"
                    + "    c\n"
                    + "  d\n"
                    ;
        _test("parseTerm", ArithmeticExpression.class);
    }

    public void testParseArithmetic1() {  // arithmetic
        _input = "-a + b .+ c - d";
        _expected = ""
                    + "-\n"
                    + "  .+\n"
                    + "    +\n"
                    + "      -.\n"
                    + "        a\n"
                    + "      b\n"
                    + "    c\n"
                    + "  d\n"
                    ;
        _test("parseArithmetic", ArithmeticExpression.class);
    }

    public void testParseArithmetic2() {  // arithmetic
        _input = "-a*b + -c/d";
        _expected = ""
                    + "+\n"
                    + "  *\n"
                    + "    -.\n"
                    + "      a\n"
                    + "    b\n"
                    + "  /\n"
                    + "    -.\n"
                    + "      c\n"
                    + "    d\n"
                    ;
        _test("parseArithmetic", ArithmeticExpression.class);
    }

    public void testParseConcatenation1() {  // arithmetic
        _input = "'dir/' .+ base .+ '.txt'";
        _expected = ""
                    + ".+\n"
                    + "  .+\n"
                    + "    \"dir/\"\n"
                    + "    base\n"
                    + "  \".txt\"\n"
                    ;
        _test("parseArithmetic", ConcatenationExpression.class);
    }


    public void testParseRelational1() {
        _input = "a==b";
        _expected = ""
                    + "==\n"
                    + "  a\n"
                    + "  b\n"
                    ;
        _test("parseRelational", RelationalExpression.class);
        _input = "a!=b";
        _expected = ""
                    + "!=\n"
                    + "  a\n"
                    + "  b\n"
                    ;
        _test("parseRelational", RelationalExpression.class);
        _input = "a<b";
        _expected = ""
                    + "<\n"
                    + "  a\n"
                    + "  b\n"
                    ;
        _test("parseRelational", RelationalExpression.class);
        _input = "a<=b";
        _expected = ""
                    + "<=\n"
                    + "  a\n"
                    + "  b\n"
                    ;
        _test("parseRelational", RelationalExpression.class);
        _input = "a>b";
        _expected = ""
                    + ">\n"
                    + "  a\n"
                    + "  b\n"
                    ;
        _test("parseRelational", RelationalExpression.class);
        _input = "a>=b";
        _expected = ""
                    + ">=\n"
                    + "  a\n"
                    + "  b\n"
                    ;
    }


    public void testParseLogicalAnd1() {  // a && b
        _input = "a && b";
        _expected = ""
                    + "&&\n"
                    + "  a\n"
                    + "  b\n"
                    ;
        _test("parseLogicalAnd", LogicalAndExpression.class);
        _input = "0<x&&x<100&&cond1&&cond2";
        _expected = ""
                    + "&&\n"
                    + "  &&\n"
                    + "    &&\n"
                    + "      <\n"
                    + "        0\n"
                    + "        x\n"
                    + "      <\n"
                    + "        x\n"
                    + "        100\n"
                    + "    cond1\n"
                    + "  cond2\n"
                    ;
        _test("parseLogicalAnd", LogicalAndExpression.class);
    }

    public void testParseLogicalOr1() {   // a || b
        _input = "a||b";
        _expected = "||\n  a\n  b\n";
        _test("parseLogicalOr", LogicalOrExpression.class);
        _input = "0<x||x<100||cond1||cond2";
        _expected = ""
                    + "||\n"
                    + "  ||\n"
                    + "    ||\n"
                    + "      <\n"
                    + "        0\n"
                    + "        x\n"
                    + "      <\n"
                    + "        x\n"
                    + "        100\n"
                    + "    cond1\n"
                    + "  cond2\n"
                    ;
        _test("parseLogicalOr", LogicalOrExpression.class);
        _input = "a&&b || c&&d || e&&f";
        _expected = ""
                    + "||\n"
                    + "  ||\n"
                    + "    &&\n"
                    + "      a\n"
                    + "      b\n"
                    + "    &&\n"
                    + "      c\n"
                    + "      d\n"
                    + "  &&\n"
                    + "    e\n"
                    + "    f\n"
                    ;
        _test("parseLogicalOr", LogicalOrExpression.class);
    }

    public void testParseConditional1() {
        _input = "a ? b : c";
        _expected = ""
                    + "?:\n"
                    + "  a\n"
                    + "  b\n"
                    + "  c\n"
                    ;
        _test("parseConditional", ConditionalExpression.class);
    }

    public void testParseAssignment1() {
        _input = "a = b";
        _expected = ""
                    + "=\n"
                    + "  a\n"
                    + "  b\n"
                    ;
        _test("parseAssignment", AssignmentExpression.class);
        _input = "a = 1+f(2)";
        _expected = ""
                    + "=\n"
                    + "  a\n"
                    + "  +\n"
                    + "    1\n"
                    + "    f()\n"
                    + "      2\n"
                    ;
        _test("parseAssignment", AssignmentExpression.class);
    }

    public void testParseAssignment2() {
        _input = "a[i] = b";
        _expected = ""
                    + "=\n"
                    + "  []\n"
                    + "    a\n"
                    + "    i\n"
                    + "  b\n"
                    ;
        _test("parseAssignment", AssignmentExpression.class);
    }


    public void testParseExpression1() {
        _input = "color = i % 2 == 0 ? '#FFCCCC' : '#CCCCFF'";
        _expected = ""
                    + "=\n"
                    + "  color\n"
                    + "  ?:\n"
                    + "    ==\n"
                    + "      %\n"
                    + "        i\n"
                    + "        2\n"
                    + "      0\n"
                    + "    \"#FFCCCC\"\n"
                    + "    \"#CCCCFF\"\n"
                    ;
        _test("parseExpression", AssignmentExpression.class);
    }


    // -----

    public static void main(String[] args) {
       junit.textui.TestRunner.run(ExpressionParserTest.class);
    }

}
