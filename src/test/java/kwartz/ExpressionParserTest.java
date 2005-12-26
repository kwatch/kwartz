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
    String _method;
    Class  _class;

    public ExpressionParser _test() {
        Scanner scanner = new Scanner(_input);
        ExpressionParser parser = new ExpressionParser(scanner);
        Expression expr = null;
        if (_method.equals("parseLiteral")) {
            expr = parser.parseLiteral();
        } else if (_method.equals("parseItem")) {
            expr = parser.parseItem();
        } else if (_method.equals("parseFactor")) {
            expr = parser.parseFactor();
        } else if (_method.equals("parseUnary")) {
            expr = parser.parseUnary();
        } else if (_method.equals("parseTerm")) {
            expr = parser.parseTerm();
        } else if (_method.equals("parseArithmetic")) {
            expr = parser.parseArithmetic();
        } else if (_method.equals("parseRelational")) {
            expr = parser.parseRelational();
        } else if (_method.equals("parseLogicalAnd")) {
            expr = parser.parseLogicalAnd();
        } else if (_method.equals("parseLogicalOr")) {
            expr = parser.parseLogicalOr();
        } else if (_method.equals("parseConditional")) {
            expr = parser.parseConditional();
        } else if (_method.equals("parseAssignment")) {
            expr = parser.parseAssignment();
        } else if (_method.equals("parseExpression")) {
            expr = parser.parseExpression();
        } else {
            fail("*** invalid _method name ***");
        }
        if (expr == null) fail("*** expr is null ***");
        if (_class != null) {
            assertEquals(_class, expr.getClass());
        }
        StringBuffer actual = expr._inspect();
        assertEquals(_expected, actual.toString());
        assertTrue("*** EOF expected ***", scanner.getToken() == TokenType.EOF);
        return parser;
    }


    // integer
    public void testParseLiteral1() {

        _input = ""
            + "100\n"
            ;

        _expected = ""
            + "100\n"
            ;

        _method = "parseLiteral";
        _class = IntegerExpression.class;

        _test();
    }

    // double
    public void testParseLiteral2() {

        _input = ""
            + "3.14\n"
            ;

        _expected = ""
            + "3.14\n"
            ;

        _method = "parseLiteral";
        _class = DoubleExpression.class;

        _test();
    }

    // string
    public void testParseLiteral3() {

        _input = ""
            + "'foo'\n"
            ;

        _expected = ""
            + "\"foo\"\n"
            ;

        _method = "parseLiteral";
        _class = StringExpression.class;

        _test();
    }

    // string
    public void testParseLiteral4() {

        _input = ""
            + "'\\n\\r\\t\\\\\\\\ \\''\n"
            ;

        _expected = ""
            + "\"\\\\n\\\\r\\\\t\\\\\\\\ '\"\n"
            ;

        _method = "parseLiteral";
        _class = StringExpression.class;

        _test();
    }

    // string
    public void testParseLiteral5() {

        _input = ""
            + "\"foo\"\n"
            ;

        _expected = ""
            + "\"foo\"\n"
            ;

        _method = "parseLiteral";
        _class = StringExpression.class;

        _test();
    }

    // string
    public void testParseLiteral6() {

        _input = ""
            + "\"\\n\\r\\t \\\\ \\\" \"\n"
            ;

        _expected = ""
            + "\"\\n\\r\\t \\\\ \\\" \"\n"
            ;

        _method = "parseLiteral";
        _class = StringExpression.class;

        _test();
    }

    // true, false
    public void testParseLiteral7() {

        _input = ""
            + "true\n"
            ;

        _expected = ""
            + "true\n"
            ;

        _method = "parseLiteral";
        _class = BooleanExpression.class;

        _test();
    }

    // true, false
    public void testParseLiteral8() {

        _input = ""
            + "false\n"
            ;

        _expected = ""
            + "false\n"
            ;

        _method = "parseLiteral";
        _class = BooleanExpression.class;

        _test();
    }

    // 
    public void testParseLiteral9() {

        _input = ""
            + "null\n"
            ;

        _expected = ""
            + "null\n"
            ;

        _method = "parseLiteral";
        _class = NullExpression.class;

        _test();
    }

    // variable
    public void testParseItem1() {

        _input = ""
            + "foo\n"
            ;

        _expected = ""
            + "foo\n"
            ;

        _method = "parseItem";
        _class = VariableExpression.class;

        _test();
    }

    // function()
    public void testParseItem2() {

        _input = ""
            + "foo()\n"
            ;

        _expected = ""
            + "foo()\n"
            ;

        _method = "parseItem";
        _class = FunctionExpression.class;

        _test();
    }

    // function(100, 'va', arg)
    public void testParseItem3() {

        _input = ""
            + "foo(100, 'val', arg)\n"
            ;

        _expected = ""
            + "foo()\n"
            + "  100\n"
            + "  \"val\"\n"
            + "  arg\n"
            ;

        _method = "parseItem";
        _class = FunctionExpression.class;

        _test();
    }

    // (expr)
    public void testParseItem4() {

        _input = ""
            + "(a+b)\n"
            ;

        _expected = ""
            + "+\n"
            + "  a\n"
            + "  b\n"
            ;

        _method = "parseItem";
        _class = ArithmeticExpression.class;

        _test();
    }

    // macro C(), S(), D()
    public void testParseItem5() {

        _input = ""
            + "C(flag)\n"
            ;

        _expected = ""
            + "?:\n"
            + "  flag\n"
            + "  \" checked=\\\"checked\\\"\"\n"
            + "  \"\"\n"
            ;

        _method = "parseItem";
        _class = ConditionalExpression.class;

        _test();
    }

    // macro C(), S(), D()
    public void testParseItem6() {

        _input = ""
            + "S(gender=='M')\n"
            ;

        _expected = ""
            + "?:\n"
            + "  ==\n"
            + "    gender\n"
            + "    \"M\"\n"
            + "  \" selected=\\\"selected\\\"\"\n"
            + "  \"\"\n"
            ;

        _method = "parseItem";
        _class = ConditionalExpression.class;

        _test();
    }

    // macro C(), S(), D()
    public void testParseItem7() {

        _input = ""
            + "D(error!=null)\n"
            ;

        _expected = ""
            + "?:\n"
            + "  !=\n"
            + "    error\n"
            + "    null\n"
            + "  \" disabled=\\\"disabled\\\"\"\n"
            + "  \"\"\n"
            ;

        _method = "parseItem";
        _class = ConditionalExpression.class;

        _test();
    }

    // arity of macros
    public void testParseItem8() {

        _input = ""
            + "C(arg1, arg2)\n"
            ;

        _expected = ""
            ;

        _method = "parseItem";
        _class = ConditionalExpression.class;

        try {
            _test();
            fail("SemanticException expected but not throwed.");
        } catch (SemanticException ex) {
            // OK
        }
    }

    // array
    public void testParseFactor1() {

        _input = ""
            + "a[10]\n"
            ;

        _expected = ""
            + "[]\n"
            + "  a\n"
            + "  10\n"
            ;

        _method = "parseFactor";
        _class = IndexExpression.class;

        _test();
    }

    // array
    public void testParseFactor2() {

        _input = ""
            + "a[i+1]\n"
            ;

        _expected = ""
            + "[]\n"
            + "  a\n"
            + "  +\n"
            + "    i\n"
            + "    1\n"
            ;

        _method = "parseFactor";
        _class = IndexExpression.class;

        _test();
    }

    // hash
    public void testParseFactor3() {

        _input = ""
            + "a[:foo]\n"
            ;

        _expected = ""
            + "[:]\n"
            + "  a\n"
            + "  \"foo\"\n"
            ;

        _method = "parseFactor";
        _class = IndexExpression.class;

        _test();
    }

    // property
    public void testParseFactor4() {

        _input = ""
            + "obj.prop1\n"
            ;

        _expected = ""
            + ".\n"
            + "  obj\n"
            + "  prop1\n"
            ;

        _method = "parseFactor";
        _class = PropertyExpression.class;

        _test();
    }

    // method
    public void testParseFactor5() {

        _input = ""
            + "obj.method1(arg1,arg2)\n"
            ;

        _expected = ""
            + ".()\n"
            + "  obj\n"
            + "  method1()\n"
            + "    arg1\n"
            + "    arg2\n"
            ;

        _method = "parseFactor";
        _class = MethodExpression.class;

        _test();
    }

    // nested array,hash
    public void testParseFactor6() {

        _input = ""
            + "a[i][:j][k]\n"
            ;

        _expected = ""
            + "[]\n"
            + "  [:]\n"
            + "    []\n"
            + "      a\n"
            + "      i\n"
            + "    \"j\"\n"
            + "  k\n"
            ;

        _method = "parseFactor";
        _class = IndexExpression.class;

        _test();
    }

    // nested array,hash
    public void testParseFactor7() {

        _input = ""
            + "foo.bar.baz()\n"
            ;

        _expected = ""
            + ".()\n"
            + "  .\n"
            + "    foo\n"
            + "    bar\n"
            + "  baz()\n"
            ;

        _method = "parseFactor";
        _class = MethodExpression.class;

        _test();
    }

    // invalid array
    public void testParseFactor8() {

        _input = ""
            + "a[10;\n"
            ;

        _expected = ""
            ;

        _method = "parseFactor";
        _class = IndexExpression.class;

        try {
            _test();
            fail("SyntaxException expected but not throwed.");
        } catch (SyntaxException ex) {
            // OK
        }
    }

    // ...
    public void testParseFactor9() {

        _input = ""
            + "a[:+]\n"
            ;

        _expected = ""
            ;

        _method = "parseFactor";
        _class = IndexExpression.class;

        try {
            _test();
            fail("SyntaxException expected but not throwed.");
        } catch (SyntaxException ex) {
            // OK
        }
    }

    // ...
    public void testParseFactor10() {

        _input = ""
            + "a[:foo-bar]\n"
            ;

        _expected = ""
            ;

        _method = "parseFactor";
        _class = IndexExpression.class;

        try {
            _test();
            fail("SyntaxException expected but not throwed.");
        } catch (SyntaxException ex) {
            // OK
        }
    }

    // -1, +a, !false
    public void testParseUnary1() {

        _input = ""
            + "-1\n"
            ;

        _expected = ""
            + "-.\n"
            + "  1\n"
            ;

        _method = "parseUnary";
        _class = UnaryExpression.class;

        _test();
    }

    // -1, +a, !false
    public void testParseUnary2() {

        _input = ""
            + "+a\n"
            ;

        _expected = ""
            + "+.\n"
            + "  a\n"
            ;

        _method = "parseUnary";
        _class = UnaryExpression.class;

        _test();
    }

    // -1, +a, !false
    public void testParseUnary3() {

        _input = ""
            + "!false\n"
            ;

        _expected = ""
            + "!\n"
            + "  false\n"
            ;

        _method = "parseUnary";
        _class = UnaryExpression.class;

        _test();
    }

    // - - 1
    public void testParseUnary4() {

        _input = ""
            + "- -1\n"
            ;

        _expected = ""
            ;

        _method = "parseUnary";
        _class = UnaryExpression.class;

        try {
            _test();
            fail("SyntaxException expected but not throwed.");
        } catch (SyntaxException ex) {
            // OK
        }
    }

    // term
    public void testParseTerm1() {

        _input = ""
            + "-x*y\n"
            ;

        _expected = ""
            + "*\n"
            + "  -.\n"
            + "    x\n"
            + "  y\n"
            ;

        _method = "parseTerm";
        _class = ArithmeticExpression.class;

        _test();
    }

    // term
    public void testParseTerm2() {

        _input = ""
            + "a*b/c%d\n"
            ;

        _expected = ""
            + "%\n"
            + "  /\n"
            + "    *\n"
            + "      a\n"
            + "      b\n"
            + "    c\n"
            + "  d\n"
            ;

        _method = "parseTerm";
        _class = ArithmeticExpression.class;

        _test();
    }

    // arithmetic
    public void testParseArithmetic1() {

        _input = ""
            + "-a + b .+ c - d\n"
            ;

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

        _method = "parseArithmetic";
        _class = ArithmeticExpression.class;

        _test();
    }

    // arithmetic
    public void testParseArithmetic2() {

        _input = ""
            + "-a*b + -c/d\n"
            ;

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

        _method = "parseArithmetic";
        _class = ArithmeticExpression.class;

        _test();
    }

    // arithmetic
    public void testParseConcatenation1() {

        _input = ""
            + "'dir/' .+ base .+ '.txt'\n"
            ;

        _expected = ""
            + ".+\n"
            + "  .+\n"
            + "    \"dir/\"\n"
            + "    base\n"
            + "  \".txt\"\n"
            ;

        _method = "parseArithmetic";
        _class = ConcatenationExpression.class;

        _test();
    }

    // 
    public void testParseRelational1() {

        _input = ""
            + "a==b\n"
            ;

        _expected = ""
            + "==\n"
            + "  a\n"
            + "  b\n"
            ;

        _method = "parseRelational";
        _class = RelationalExpression.class;

        _test();
    }

    // 
    public void testParseRelational2() {

        _input = ""
            + "a!=b\n"
            ;

        _expected = ""
            + "!=\n"
            + "  a\n"
            + "  b\n"
            ;

        _method = "parseRelational";
        _class = RelationalExpression.class;

        _test();
    }

    // 
    public void testParseRelational3() {

        _input = ""
            + "a<b\n"
            ;

        _expected = ""
            + "<\n"
            + "  a\n"
            + "  b\n"
            ;

        _method = "parseRelational";
        _class = RelationalExpression.class;

        _test();
    }

    // 
    public void testParseRelational4() {

        _input = ""
            + "a<=b\n"
            ;

        _expected = ""
            + "<=\n"
            + "  a\n"
            + "  b\n"
            ;

        _method = "parseRelational";
        _class = RelationalExpression.class;

        _test();
    }

    // 
    public void testParseRelational5() {

        _input = ""
            + "a>b\n"
            ;

        _expected = ""
            + ">\n"
            + "  a\n"
            + "  b\n"
            ;

        _method = "parseRelational";
        _class = RelationalExpression.class;

        _test();
    }

    // 
    public void testParseRelational6() {

        _input = ""
            + "a>=b\n"
            ;

        _expected = ""
            + ">=\n"
            + "  a\n"
            + "  b\n"
            ;

        _method = "parseRelational";
        _class = RelationalExpression.class;

        _test();
    }

    // a && b
    public void testParseLogicalAnd1() {

        _input = ""
            + "a && b\n"
            ;

        _expected = ""
            + "&&\n"
            + "  a\n"
            + "  b\n"
            ;

        _method = "parseLogicalAnd";
        _class = LogicalAndExpression.class;

        _test();
    }

    // 
    public void testParseLogicalAnd2() {

        _input = ""
            + "0<x&&x<100&&cond1&&cond2\n"
            ;

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

        _method = "parseLogicalAnd";
        _class = LogicalAndExpression.class;

        _test();
    }

    // a || b
    public void testParseLogicalOr1() {

        _input = ""
            + "a||b\n"
            ;

        _expected = ""
            + "||\n"
            + "  a\n"
            + "  b\n"
            ;

        _method = "parseLogicalOr";
        _class = LogicalOrExpression.class;

        _test();
    }

    // 
    public void testParseLogicalOr2() {

        _input = ""
            + "0<x||x<100||cond1||cond2\n"
            ;

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

        _method = "parseLogicalOr";
        _class = LogicalOrExpression.class;

        _test();
    }

    // 
    public void testParseLogicalOr3() {

        _input = ""
            + "a&&b || c&&d || e&&f\n"
            ;

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

        _method = "parseLogicalOr";
        _class = LogicalOrExpression.class;

        _test();
    }

    // 
    public void testParseConditional1() {

        _input = ""
            + "a ? b : c\n"
            ;

        _expected = ""
            + "?:\n"
            + "  a\n"
            + "  b\n"
            + "  c\n"
            ;

        _method = "parseConditional";
        _class = ConditionalExpression.class;

        _test();
    }

    // 
    public void testParseAssignment1() {

        _input = ""
            + "a = b\n"
            ;

        _expected = ""
            + "=\n"
            + "  a\n"
            + "  b\n"
            ;

        _method = "parseAssignment";
        _class = AssignmentExpression.class;

        _test();
    }

    // 
    public void testParseAssignment2() {

        _input = ""
            + "a = 1+f(2)\n"
            ;

        _expected = ""
            + "=\n"
            + "  a\n"
            + "  +\n"
            + "    1\n"
            + "    f()\n"
            + "      2\n"
            ;

        _method = "parseAssignment";
        _class = AssignmentExpression.class;

        _test();
    }

    // 
    public void testParseAssignment3() {

        _input = ""
            + "a[i] = b\n"
            ;

        _expected = ""
            + "=\n"
            + "  []\n"
            + "    a\n"
            + "    i\n"
            + "  b\n"
            ;

        _method = "parseAssignment";
        _class = AssignmentExpression.class;

        _test();
    }

    // 
    public void testParseExpression1() {

        _input = ""
            + "color = i % 2 == 0 ? '#FFCCCC' : '#CCCCFF'\n"
            ;

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

        _method = "parseExpression";
        _class = AssignmentExpression.class;

        _test();
    }

}
