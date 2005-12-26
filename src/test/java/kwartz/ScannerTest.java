/**
 *  @(#) ScannerTest.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

import junit.framework.TestCase;

public class ScannerTest extends TestCase {

    private String _input;
    private String _expected;

    public Scanner _test() {
        return _test(true);
    }

    public Scanner _test(boolean flag_test) {
        if (! flag_test) return null;
        Scanner scanner = new Scanner(_input);
        StringBuffer sbuf = new StringBuffer();
        while (scanner.scan() != TokenType.EOF) {
            sbuf.append(TokenType.tokenName(scanner.getToken()));
            sbuf.append(' ');
            String s = TokenType.inspect(scanner.getToken(), scanner.getValue());
            sbuf.append(s);
            sbuf.append("\n");
        }
        String actual = sbuf.toString();
        assertEquals(_expected, actual);
        return scanner;
    }


    public void testScanner0() {  // basic test
        _input = "if while foo";
        _expected = "IF :if\nWHILE :while\nNAME foo\nEOF <<EOF>>\nEOF <<EOF>>\n";
        Scanner scanner = new Scanner(_input);
        StringBuffer sbuf = new StringBuffer();
        for (int i = 0; i < 5; i++) {
            scanner.scan();
            sbuf.append(TokenType.tokenName(scanner.getToken()));
            sbuf.append(' ');
            sbuf.append(TokenType.inspect(scanner.getToken(), scanner.getValue()));
            sbuf.append("\n");
        }
        String actual = sbuf.toString();
        assertEquals(_expected, actual);
    }



    // keywords
    public void testScanner11() {
        _input = "  if while  foreach else\nelseif\t\nin  ";

        _expected = ""
            + "IF :if\n"
            + "WHILE :while\n"
            + "FOREACH :foreach\n"
            + "ELSE :else\n"
            + "ELSEIF :elseif\n"
            + "IN :in\n"
            ;

        _test();
    }

    // keywords
    public void testScanner12() {
        _input = "true false null nil empty";

        _expected = ""
            + "TRUE true\n"
            + "FALSE false\n"
            + "NULL null\n"
            + "NAME nil\n"
            + "EMPTY empty\n"
            ;

        _test();
    }

    // integer, double
    public void testScanner13() {
        _input = "100 3.14";

        _expected = ""
            + "INTEGER 100\n"
            + "DOUBLE 3.14\n"
            ;

        _test();
    }

    // lexcal exception
    public void testScanner14() {
        _input = "100abc";

        _expected = ""
            ;

        try {
            _test();
            fail("LexicalException expected but not happened.");
        } catch (LexicalException ex) {
            // OK
        }
    }

    // lexcal exception
    public void testScanner15() {
        _input = "3.14abc";

        _expected = ""
            ;

        try {
            _test();
            fail("LexicalException expected but not happened.");
        } catch (LexicalException ex) {
            // OK
        }
    }

    // comment
    public void testScanner16() {
        _input = "// foo\n123/* // \n*/456";

        _expected = ""
            + "INTEGER 123\n"
            + "INTEGER 456\n"
            ;

        _test();
    }

    // comment
    public void testScanner17() {
        _input = "/* \n//";

        _expected = ""
            ;

        try {
            _test();
            fail("LexicalException expected but not happened.");
        } catch (LexicalException ex) {
            // OK
        }
    }

    // string
    public void testScanner18() {
        _input = "'str1'";

        _expected = ""
            + "STRING \"str1\"\n"
            ;

        _test();
    }

    // string
    public void testScanner19() {
        _input = "'\n\r\t\\ \\''";

        _expected = ""
            + "STRING \"\\n\\r\\t\\\\ '\"\n"
            ;

        _test();
    }

    // string
    public void testScanner20() {
        _input = "\"str\"";

        _expected = ""
            + "STRING \"str\"\n"
            ;

        _test();
    }

    // string
    public void testScanner21() {
        _input = "\"\\n\\r\\t'\\\"\"";

        _expected = ""
            + "STRING \"\\n\\r\\t'\\\"\"\n"
            ;

        _test();
    }

    // alithmetic op
    public void testScanner31() {
        _input = "+ - * / % .+";

        _expected = ""
            + "ADD +\n"
            + "SUB -\n"
            + "MUL *\n"
            + "DIV /\n"
            + "MOD %\n"
            + "CONCAT .+\n"
            ;

        _test();
    }

    // assignment op
    public void testScanner32() {
        _input = "= += -= *= /= %= .+=";

        _expected = ""
            + "ASSIGN =\n"
            + "ADD_TO +=\n"
            + "SUB_TO -=\n"
            + "MUL_TO *=\n"
            + "DIV_TO /=\n"
            + "MOD_TO %=\n"
            + "CONCAT_TO .+=\n"
            ;

        _test();
    }

    // comparable op
    public void testScanner33() {
        _input = "== != < <= > >=";

        _expected = ""
            + "EQ ==\n"
            + "NE !=\n"
            + "LT <\n"
            + "LE <=\n"
            + "GT >\n"
            + "GE >=\n"
            ;

        _test();
    }

    // logical op
    public void testScanner34() {
        _input = "! && ||";

        _expected = ""
            + "NOT !\n"
            + "AND &&\n"
            + "OR ||\n"
            ;

        _test();
    }

    // symbols
    public void testScanner35() {
        _input = "[][::;?.,#";

        _expected = ""
            + "L_BRACKET [\n"
            + "R_BRACKET ]\n"
            + "L_BRACKETCOLON [:\n"
            + "COLON :\n"
            + "SEMICOLON ;\n"
            + "CONDITIONAL ?:\n"
            + "PERIOD .\n"
            + "COMMA ,\n"
            + "SHARP #\n"
            ;

        _test();
    }

    // expand
    public void testScanner36() {
        _input = "@stag";

        _expected = ""
            + "EXPAND @stag\n"
            ;

        _test();
    }

    // raw expr
    public void testScanner41() {
        _input = "s=<%= $foo %>;";

        _expected = ""
            + "NAME s\n"
            + "ASSIGN =\n"
            + "RAWEXPR <%= $foo %>\n"
            + "SEMICOLON ;\n"
            ;

        _test();
    }

    // raw stmt
    public void testScanner42() {
        _input = "<% $foo %>";

        _expected = ""
            + "RAWSTMT <% $foo %>\n"
            ;

        _test();
    }

    // invalid char
    public void testScanner51() {
        _input = "~";

        _expected = ""
            ;

        try {
            _test();
            fail("LexicalException expected but not happened.");
        } catch (LexicalException ex) {
            // OK
        }
    }

    // invalid char
    public void testScanner52() {
        _input = "^";

        _expected = ""
            ;

        try {
            _test();
            fail("LexicalException expected but not happened.");
        } catch (LexicalException ex) {
            // OK
        }
    }

    // invalid char
    public void testScanner53() {
        _input = "$";

        _expected = ""
            ;

        try {
            _test();
            fail("LexicalException expected but not happened.");
        } catch (LexicalException ex) {
            // OK
        }
    }

}
