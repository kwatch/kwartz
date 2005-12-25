/**
 *  @(#) StatementParserTest.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

import kwartz.node.*;
import junit.framework.TestCase;

public class StatementParserTest extends TestCase {

    String _input, _expected;

    public Parser _test(String method) {
        return _test(method, null);
    }
    public Parser _test(String method, Class klass) {
        Scanner scanner = new Scanner(_input);
        StatementParser parser = new StatementParser(scanner);
        Statement stmt = null;
        Statement[] stmts = null;
        if (method.equals("parsePrintStatement")) {
            stmt = parser.parsePrintStatement();
        } else if (method.equals("parseExpressionStatement")) {
            stmt = parser.parseExpressionStatement();
        } else if (method.equals("parseIfStatement")) {
            stmt = parser.parseIfStatement();
        } else if (method.equals("parseForeachStatement")) {
            stmt = parser.parseForeachStatement();
        } else if (method.equals("parseWhileStatement")) {
            stmt = parser.parseWhileStatement();
        } else if (method.equals("parseExpandStatement")) {
            stmt = parser.parseExpandStatement();
        } else if (method.equals("parseElementStatement")) {
            stmt = parser.parseElementStatement();
        } else if (method.equals("parseRawcodeStatement")) {
            stmt = parser.parseRawcodeStatement();
        } else if (method.equals("parseBlockStatement")) {
            stmt = parser.parseBlockStatement();
        } else if (method.equals("parseStatementList")) {
            stmts = parser.parseStatementList();
        } else {
            fail("*** invalid method name ***");
        }

        //Scanner scanner = parser.getScanner();
        if (scanner.getToken() != TokenType.EOF)
            fail("TokenType.EOF expected but got " + TokenType.inspect(scanner.getToken(), scanner.getValue()));

        if (klass != null) {
            assertEquals(klass, stmt.getClass());
        }
        if (stmt != null) {
            StringBuffer actual = stmt._inspect();
            assertEquals(_expected, actual.toString());
        } else if (stmts != null) {
            StringBuffer sb = new StringBuffer();
            for (int i = 0; i < stmts.length; i++) {
                stmts[i]._inspect(0, sb);
            }
            assertEquals(_expected, sb.toString());
        } else {
            assert false;
        }
        return parser;
    }


    public void testParseBlockStatement1() {
        _input = "{ print(foo); print(bar); print(baz); }";
        _expected = ":block\n  :print\n    foo\n  :print\n    bar\n  :print\n    baz\n";
        _test("parseBlockStatement", BlockStatement.class);
    }

    public void testParseBlockStatement2() {
        _input = "{ i=0; i+=1; ; }";
        _expected = ""
                    + ":block\n"
                    + "  :expr\n"
                    + "    =\n"
                    + "      i\n"
                    + "      0\n"
                    + "  :expr\n"
                    + "    +=\n"
                    + "      i\n"
                    + "      1\n"
                    + "  :empty_stmt\n"
                    ;
        _test("parseBlockStatement", BlockStatement.class);
    }


    public void testParsePrintStatement1() { // print('foo');
        _input = "print('foo');";
        _expected = ""
                    + ":print\n"
                    + "  \"foo\"\n"
                    ;
        _test("parsePrintStatement", PrintStatement.class);
    }
    public void testParsePrintStatement2() { // print(a, 'foo'.+b, 100);
        _input = "print(a, 'foo'.+b, 100);";
        _expected = ""
                    + ":print\n"
                    + "  a\n"
                    + "  .+\n"
                    + "    \"foo\"\n"
                    + "    b\n"
                    + "  100\n"
                    ;
        _test("parsePrintStatement", PrintStatement.class);
    }

    public void testParseExpressionStatement1() { // x = 100;
        _input = "x = 100;";
        _expected = ""
                    + ":expr\n"
                    + "  =\n"
                    + "    x\n"
                    + "    100\n"
                    ;
        _test("parseExpressionStatement", ExpressionStatement.class);
    }

    public void testParseExpressionStatement2() { // x[i][j] = i > j ? 0 : 1;
        _input = "x[i][j] = i > j ? 0 : 1;";
        _expected = ""
                    + ":expr\n"
                    + "  =\n"
                    + "    []\n"
                    + "      []\n"
                    + "        x\n"
                    + "        i\n"
                    + "      j\n"
                    + "    ?:\n"
                    + "      >\n"
                    + "        i\n"
                    + "        j\n"
                    + "      0\n"
                    + "      1\n"
                    ;
        _test("parseExpressionStatement", ExpressionStatement.class);
    }


    public void testParseForeachStatement1() {
        _input = "foreach(item in list) { print(item); }";
        _expected = ""
                    + ":foreach\n"
                    + "  item\n"
                    + "  list\n"
                    + "  :block\n"
                    + "    :print\n"
                    + "      item\n"
                    ;
        _test("parseForeachStatement", ForeachStatement.class);
    }

    public void testParseForeachStatement2() {
        _input = "foreach(item in list) print(item);";
        _expected = ""
                    + ":foreach\n"
                    + "  item\n"
                    + "  list\n"
                    + "  :print\n"
                    + "    item\n"
                    ;
        _test("parseForeachStatement", ForeachStatement.class);
    }


    public void testParseIfStatement1() {
        _input = "if (flag) print(flag);";
        _expected = ""
                    + ":if\n"
                    + "  flag\n"
                    + "  :print\n"
                    + "    flag\n"
                    ;
        _test("parseIfStatement", IfStatement.class);
    }

    public void testParseIfStatement2() {
        _input = "if (flag) print(true); else print(false);";
        _expected = ""
                    + ":if\n"
                    + "  flag\n"
                    + "  :print\n"
                    + "    true\n"
                    + "  :print\n"
                    + "    false\n"
                    ;
        _test("parseIfStatement", IfStatement.class);
    }

    public void testParseIfStatement3() {
        _input = "if (flag1) print(aaa); else if (flag2) print(bbb); elseif(flag3) print(ccc); else print(ddd);";
        _expected = ""
                    + ":if\n"
                    + "  flag1\n"
                    + "  :print\n"
                    + "    aaa\n"
                    + "  :if\n"
                    + "    flag2\n"
                    + "    :print\n"
                    + "      bbb\n"
                    + "    :if\n"
                    + "      flag3\n"
                    + "      :print\n"
                    + "        ccc\n"
                    + "      :print\n"
                    + "        ddd\n"
                    ;
        _test("parseIfStatement", IfStatement.class);
    }


    public void testParseWhileStatement1() {
        _input = "while (i < max) i += 1;";
        _expected = ""
                    + ":while\n"
                    + "  <\n"
                    + "    i\n"
                    + "    max\n"
                    + "  :expr\n"
                    + "    +=\n"
                    + "      i\n"
                    + "      1\n"
                    ;
        _test("parseWhileStatement", WhileStatement.class);
    }


    public void testParseExpandStatement1() {
        _input = "@stag;";
        _expected = "@stag\n";
        _test("parseExpandStatement", ExpandStatement.class);
        _input = "@cont;";
        _expected = "@cont\n";
        _test("parseExpandStatement", ExpandStatement.class);
        _input = "@etag;";
        _expected = "@etag\n";
        _test("parseExpandStatement", ExpandStatement.class);
        _input = "@content(foo);";
        _expected = "@content(foo)\n";
        _test("parseExpandStatement", ExpandStatement.class);
        _input = "@element(foo);";
        _expected = "@element(foo)\n";
        _test("parseExpandStatement", ExpandStatement.class);
    }


    public void testParseExpandStatement2() {
        _input = "@foo;";
        _expected = "";
        try {
            _test("parseExpandStatement", ExpandStatement.class);
            fail("SyntaxException expected but not happened.");
        } catch (SyntaxException ex) {
            // OK
        }
    }


    public void testParseStatementList1() {
        _input = ""
                 + "print(\"<table>\\n\");\n"
                 + "i = 0;\n"
                 + "foreach(item in list) {\n"
                 + "  i += 1;\n"
                 + "  color = i % 2 == 0 ? '#FFCCCC' : '#CCCCFF';\n"
                 + "  print(\"<tr bgcolor=\\\"\", color, \"\\\">\\n\");\n"
                 + "  print(\"<td>\", item, \"</td>\\n\");\n"
                 + "  print(\"</tr>\\n\");\n"
                 + "}\n"
                 + "print(\"</table>\\n\");\n"
                 ;
        _expected = ""
                    + ":print\n"
                    + "  \"<table>\\n\"\n"
                    + ":expr\n"
                    + "  =\n"
                    + "    i\n"
                    + "    0\n"
                    + ":foreach\n"
                    + "  item\n"
                    + "  list\n"
                    + "  :block\n"
                    + "    :expr\n"
                    + "      +=\n"
                    + "        i\n"
                    + "        1\n"
                    + "    :expr\n"
                    + "      =\n"
                    + "        color\n"
                    + "        ?:\n"
                    + "          ==\n"
                    + "            %\n"
                    + "              i\n"
                    + "              2\n"
                    + "            0\n"
                    + "          \"#FFCCCC\"\n"
                    + "          \"#CCCCFF\"\n"
                    + "    :print\n"
                    + "      \"<tr bgcolor=\\\"\"\n"
                    + "      color\n"
                    + "      \"\\\">\\n\"\n"
                    + "    :print\n"
                    + "      \"<td>\"\n"
                    + "      item\n"
                    + "      \"</td>\\n\"\n"
                    + "    :print\n"
                    + "      \"</tr>\\n\"\n"
                    + ":print\n"
                    + "  \"</table>\\n\"\n"
                    ;
        _test("parseStatementList");
    }


    // -----

    public static void main(String[] args) {
       junit.textui.TestRunner.run(StatementParserTest.class);
    }
}
