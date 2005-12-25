/**
 *  @(#) FunctionTest.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

import kwartz.node.*;
import junit.framework.TestCase;

import java.util.*;
import java.io.*;

public class FunctionTest extends TestCase {
    String _input;
    String _expected;
    Map _context = new Context();

    public void _test() throws Exception {
        _test(false);
    }
    public void _test(boolean flagPrint) throws Exception {
        StatementParser parser = new StatementParser();
        BlockStatement stmt = parser.parse(_input);
        StringWriter writer = new StringWriter();
        stmt.execute(_context, writer);
        String actual = writer.toString();
        writer.close();
        if (flagPrint)
            System.out.println(actual);
        else
            assertEquals(_expected, actual);
    }

    public void testEscapeFunction1() throws Exception {
        _input = ""
                 + "s = \"<em>\\\"A&B\\\"</em>\\n\";\n"
                 + "print(E(s));\n"
                 + "print(X(s));\n"
                 + "print(escape_xml(s));\n"
                 + "print(escape_url('http://localhost/~user/index?arg=<tag attr=\"foo\">'), \"\\n\");\n"
                 + "print(escape_sql(\"'quote'\" .+ '\"doublequote\"' .+ '\\\\escape'), \"\\n\");\n"
                 ;
        _expected = ""
                    + "&lt;em&gt;&quot;A&amp;B&quot;&lt;/em&gt;\n"
                    + "<em>\"A&B\"</em>\n"
                    + "&lt;em&gt;&quot;A&amp;B&quot;&lt;/em&gt;\n"
                    + "http%3A%2F%2Flocalhost%2F%7Euser%2Findex%3Farg%3D%3Ctag+attr%3D%22foo%22%3E\n"
                    + "\\'quote\\'\\\"doublequote\\\"\\\\escape\n"
                    ;
        _test();
    }

    public void testStringFunction1() throws Exception {
        _input = ""
                 + "s = \" abc DEF\";\n"
                 + "print(str_length(s), \"\\n\");\n"
                 + "print(str_tolower(s), \"\\n\");\n"
                 + "print(str_toupper(s), \"\\n\");\n"
                 + "print(str_trim(s), \"\\n\");\n"
                 + "print(str_empty(s) ? \"empty\" : \"not empty\", \"\\n\");\n"
                 + "print(str_empty(\"\") ? \"empty\" : \"not empty\", \"\\n\");\n"
                 ;
        _expected = ""
                    + "8\n"
                    + " abc def\n"
                    + " ABC DEF\n"
                    + "abc DEF\n"
                    + "not empty\n"
                    + "empty\n"
                    ;
        _test();
    }

    public void testListFunction1() throws Exception {
        _input = ""
                 + "list = list_new();\n"
                 + "print(list_length(list), \"\\n\");\n"
                 + "print(list_empty(list) ? \"empty\" : \"not empty\", \"\\n\");\n"
                 + "list[0] = \"a\";\n"
                 + "print(list[0], \"\\n\");\n"
                 + "list_add(list, 123);\n"
                 + "print(list[1], \"\\n\");\n"
                 + "print(list_empty(list) ? \"empty\" : \"not empty\", \"\\n\");\n"
                 ;
        _expected = ""
                    + "0\n"
                    + "empty\n"
                    + "a\n"
                    + "123\n"
                    + "not empty\n"
                    ;
        _test();
    }

    public void testHashFunction1() throws Exception {
        _input = ""
                 + "hash = hash_new();\n"
                 + "print(hash_length(hash), \"\\n\");\n"
                 + "print(hash_empty(hash) ? \"empty\" : \"not empty\", \"\\n\");\n"
                 + "hash['foo'] = \"FOO\";\n"
                 + "print(hash['foo'], \"\\n\");\n"
                 + "hash[:bar]  = \"BAR\";\n"
                 + "print(hash[:bar], \"\\n\");\n"
                 + "list = hash_keys(hash);\n"
                 + "print(list_length(list), \"\\n\");\n"
                 + "print(\"<\", hash['null'], \">\\n\");\n"
                 + "print(hash_length(hash), \"\\n\");\n"
                 + "print(hash_empty(hash) ? \"empty\" : \"not empty\", \"\\n\");\n"
                 ;
        _expected = ""
                    + "0\n"
                    + "empty\n"
                    + "FOO\n"
                    + "BAR\n"
                    + "2\n"
                    + "<>\n"
                    + "2\n"
                    + "not empty\n"
                    ;
        _test();
    }

    // -----

    public static void main(String[] args) {
       junit.textui.TestRunner.run(FunctionTest.class);
    }
}
