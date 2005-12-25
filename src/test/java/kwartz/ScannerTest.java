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

    public void testScanner11() {  // keywords
        _input = "  if while  foreach else\nelseif\t\nin  ";
        _expected = "IF :if\nWHILE :while\nFOREACH :foreach\nELSE :else\nELSEIF :elseif\nIN :in\n";
        _test();
        _input = "true false null nil empty";
        _expected = "TRUE true\nFALSE false\nNULL null\nNAME nil\nEMPTY empty\n";
        _test();
    }

    public void testScanner12() {  // integer, double
        _input = "100 3.14";
        _expected = "INTEGER 100\nDOUBLE 3.14\n";
        _test();
        _input = "100abc";
        _expected = null;
        try {
            _test();
            fail("'100abc': LexicalException expected.");
        } catch (LexicalException ex) {
            // OK
        } catch (Exception ex) {
            fail("'100abc': LexicalException expected.");
        }
        _input = "3.14abc";
        _expected = null;
        try {
            _test();
            fail("'3.14abc': LexicalException expected.");
        } catch (LexicalException ex) {
            // OK
        } catch (Exception ex) {
            fail("'3.14abc': LexicalException expected.");
        }
    }

    public void testScanner13() {  // comment
        _input = "// foo\n123/* // \n*/456";
        _expected = "INTEGER 123\nINTEGER 456\n";
        _test();
        _input = "/* \n//";
        _expected = null;
        try {
            _test();
            fail("LexicalException expected.");
        } catch (LexicalException ex) {
            // OK
        } catch (Exception ex) {
            fail("LexicalException expected but " + ex.getClass().getName() + " throwed.");
        }
    }

    public void testScanner14() {  // 'string'
        _input = "'str1'";
        _expected = "STRING \"str1\"\n";
        _test();
        _input = "'\n\r\t\\ \\''";
        _expected = "STRING \"\\n\\r\\t\\\\ '\"\n";
        _test();
    }

    public void testScanner15() {  // "string"
        _input = "\"str\"";
        _expected = "STRING \"str\"\n";
        _test();
        _input = "\"\\n\\r\\t\\'\\\"\"";
        _expected = "STRING \"\\n\\r\\t'\\\"\"\n";
        _test();
    }

    public void testScanner21() {  // alithmetic op
        _input = "+ - * / % .+";
        _expected = "ADD +\nSUB -\nMUL *\nDIV /\nMOD %\nCONCAT .+\n";
        _test();
    }

    public void testScanner22() {  // assignment op
        _input = "= += -= *= /= %= .+=";
        _expected = "ASSIGN =\nADD_TO +=\nSUB_TO -=\nMUL_TO *=\nDIV_TO /=\nMOD_TO %=\nCONCAT_TO .+=\n";
        _test();
    }

    public void testScanner23() {  // comparable op
        _input = "== != < <= > >=";
        _expected = "EQ ==\nNE !=\nLT <\nLE <=\nGT >\nGE >=\n";
        _test();
    }

    public void testScanner24() {  // logical op
        _input = "! && ||";
        _expected = "NOT !\nAND &&\nOR ||\n";
        _test();
    }

    public void testScanner25() {  // symbols
        _input = "[][::;?.,#";
        _expected = "L_BRACKET [\nR_BRACKET ]\nL_BRACKETCOLON [:\nCOLON :\n"
                         + "SEMICOLON ;\nCONDITIONAL ?:\nPERIOD .\nCOMMA ,\nSHARP #\n";
        _test();
    }

    public void testScanner26() {  // expand
        _input = "@stag";
        _expected = "EXPAND @stag\n";
        _test();
    }

    public void testScanner31() {  // raw expr
        _input = "s=" + "<" + "%= $foo %" + ">;";
        _expected = "NAME s\nASSIGN =\nRAWEXPR <" + "%= $foo %" + ">\nSEMICOLON ;\n";
        _test();
    }

    public void testScanner32() {  // raw stmt
        _input = "<" + "% $foo %" + ">";
        _expected = "RAWSTMT <" + "% $foo %" + ">\n";
        _test();
    }

    public void testScanner41() {  // invalid char
        _expected = null;
        try {
            _input = "~";
            _test();
            fail("LexicalException expected (ch = '~').");
        } catch (LexicalException ex) {
            // OK
        }
        try {
            _input = "^";
            _test();
            fail("LexicalException expected (ch = '~').");
        } catch (LexicalException ex) {
            // OK
        }
        try {
            _input = "$";
            _test();
            fail("LexicalException expected (ch = '~').");
        } catch (LexicalException ex) {
            // OK
        }
    }

    // -----

    public static void main(String[] args) {
       junit.textui.TestRunner.run(ScannerTest.class);
    }
}
