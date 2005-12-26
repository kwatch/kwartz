/**
 *  @(#) InterpreterTest.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

//import kwartz.Interpreter;
import junit.framework.TestCase;
//import junit.framework.TestSuite;

import java.util.*;

public class InterpreterTest extends TestCase {
    String _input;
    String _expected;
    Map _context = new HashMap();

    public void _test() {
        Interpreter interpreter = new Interpreter();
        interpreter.compile(_input);
        try {
            java.io.StringWriter writer = new java.io.StringWriter();
            interpreter.execute(_context, writer);
            String actual = writer.toString();
            assertEquals(_expected, actual);
        } catch (java.io.IOException ex) {
            ex.printStackTrace();
        }
        //StatementParser parser = new StatementParser();
        //BlockStatement block = parser.parse(_input);
        //try {
        //    java.io.StringWriter writer = new java.io.StringWriter();
        //    block.execute(_context, writer);
        //    String actual = writer.toString();
        //    assertEquals(_expected, actual);
        //}
        //catch (java.io.IOException ex) {
        //    ex.printStackTrace();
        //}
    }


    // hello world
    public void testInterpreter1() {

        _input = ""
            + "print(\"Hello \", user, \"!\\n\");\n"
            ;

        _expected = ""
            + "Hello World!\n"
            ;

        _context.put("user", "World");

        _test();
    }

    // euclidean algorithm
    public void testInterpreter2() {

        _input = ""
            + "// Euclidean algorithm\n"
            + "x = a;  y = b;\n"
            + "while (y > 0) {\n"
            + "    if (x < y) {\n"
            + "        tmp = y - x;\n"
            + "        y = x;\n"
            + "        x = tmp;\n"
            + "    } else {\n"
            + "        tmp = x - y;\n"
            + "        x = y;\n"
            + "        y = tmp;\n"
            + "    }\n"
            + "}\n"
            + "print(\"GCD(\", a, \",\", b, \") == \", x, \"\\n\");\n"
            + "print(\"(x,y) == (\", x, \",\", y, \")\\n\");\n"
            ;

        _expected = ""
            + "GCD(589,775) == 31\n"
            + "(x,y) == (31,0)\n"
            ;

        _context.put("a", new Integer(589));
        _context.put("b", new Integer(775));

        _test();
    }

    // bordered table
    public void testInterpreter3() {

        _input = ""
            + "print(\"<table>\\n\");\n"
            + "i = 0;\n"
            + "foreach(item in list) {\n"
            + "  i += 1;\n"
            + "  color = i % 2 == 0 ? '#FFCCCC' : '#CCCCFF';\n"
            + "  print('  <tr bgcolor=\"', color, \"\\\">\\n\");\n"
            + "  print(\"    <td>\", item[:name], \"</td><td>\", item[:mail], \"</td>\\n\");\n"
            + "  print(\"  </tr>\\n\");\n"
            + "}\n"
            + "print(\"</table>\\n\");\n"
            ;

        _expected = ""
            + "<table>\n"
            + "  <tr bgcolor=\"#CCCCFF\">\n"
            + "    <td>foo</td><td>foo@mail.com</td>\n"
            + "  </tr>\n"
            + "  <tr bgcolor=\"#FFCCCC\">\n"
            + "    <td>bar</td><td>bar@mail.org</td>\n"
            + "  </tr>\n"
            + "  <tr bgcolor=\"#CCCCFF\">\n"
            + "    <td>baz</td><td>baz@mail.net</td>\n"
            + "  </tr>\n"
            + "</table>\n"
            ;

        //
        List list = new ArrayList();
        //
        Map item1 = new HashMap();
        item1.put("name", "foo");  item1.put("mail", "foo@mail.com");
        list.add(item1);
        //
        Map item2 = new HashMap();
        item2.put("name", "bar");  item2.put("mail", "bar@mail.org");
        list.add(item2);
        //
        Map item3 = new HashMap();
        item3.put("name", "baz");  item3.put("mail", "baz@mail.net");
        list.add(item3);
        //
        _context.put("list", list);

        _test();
    }


}
