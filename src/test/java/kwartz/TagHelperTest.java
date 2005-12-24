/**
 *  @(#) TagHelperTest.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
import junit.framework.TestCase;
import java.util.*;

public class TagHelperTest extends TestCase {

    private String _input;
    private String _expected;
    private String _actual;
    private TagHelper _helper = new TagHelper();

    public void testConverter01() throws Exception {   // _parseExpression()
        _input    = "x+y*z";
        _expected = ""
                    + "+\n"
                    + "  x\n"
                    + "  *\n"
                    + "    y\n"
                    + "    z\n"
                    ;
        Expression expr = _helper.parseExpression(_input, 1);
        _actual = expr._inspect().toString();
        assertEquals(_expected, _actual);
    }

    public void testConverter02() throws Exception {  // _parseExpression()
        _input    = "x+y*z 100";
        _expected = "";
        try {
            Expression expr = _helper.parseExpression(_input, 1);
            fail("ConversionException expected but nothing happened.");
        } catch (ConvertionException ex) {
            // OK
        }
    }

    public void testConvert03() throws Exception {  // expandEmbeddedExpression()
        _input    = ""
                    + "<span id=\"@{user.id}@\">Hello @{user[:name]}@!</span>\n"
                    ;
        Expression[] exprs = _helper.expandEmbeddedExpression(_input, 1);
        assertEquals(5, exprs.length);
        assertEquals(StringExpression.class, exprs[0].getClass());
        assertEquals("<span id=\"", ((StringExpression)exprs[0]).getValue());
        assertEquals(PropertyExpression.class, exprs[1].getClass());
        assertEquals(StringExpression.class, exprs[2].getClass());
        assertEquals("\">Hello ", ((StringExpression)exprs[2]).getValue());
        assertEquals(IndexExpression.class, exprs[3].getClass());
        assertEquals(StringExpression.class, exprs[4].getClass());
        assertEquals("!</span>\n", ((StringExpression)exprs[4]).getValue());
        //
        _input    = "foo@{var}@";
        exprs = _helper.expandEmbeddedExpression(_input, 1);
        assertEquals(2, exprs.length);
        //
        _input    = "@{var}@foo";
        exprs = _helper.expandEmbeddedExpression(_input, 1);
        assertEquals(2, exprs.length);
        //
        _input    = ""
                    + "<body>\n"
                    + " <span id=\"@{user.id}@\">Hello @{user[:name].+}@!</span>\n"
                    + "</body>\n"
                    ;
        try {
            exprs = _helper.expandEmbeddedExpression(_input, 1);
            fail("SyntaxException expected but not happened.");
        } catch (SyntaxException ex) {
            // OK
        }
    }

}
