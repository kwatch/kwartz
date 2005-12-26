/**
 *  @(#) KwartzClassTest.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
import junit.framework.TestCase;
import java.util.*;
import java.io.*;

public class KwartzClassTest extends TestCase {

    private String _pdata;
    private String _plogic;
    private String _elemdef;
    private Context _context = new Context();
    private Properties _props = new Properties();
    private String _expected;
    private String _basename;


    private static final String PREFIX = ".KwartzClassTest";
    private static final String CHARSET = System.getProperty("file.encoding");

    public void _test() {
        String pdataFilename   = _pdata   == null ? null : PREFIX + _basename + ".html";
        String plogicFilename  = _plogic  == null ? null : PREFIX + _basename + ".plogic";
        String elemdefFilename = _elemdef == null ? null : PREFIX + _basename + ".elem.html";

        try {
            _createFile(pdataFilename, _pdata);
            _createFile(plogicFilename, _plogic);
            _createFile(elemdefFilename, _elemdef);
            Kwartz kwartz = new Kwartz(_props);
            String cacheKey = _basename;
            Template template = kwartz.getTemplate(cacheKey, pdataFilename, plogicFilename, elemdefFilename, CHARSET);
            //System.err.println("*** debug: template=" + template.getBlockStatement()._inspect() + ".");
            StringWriter writer = new StringWriter();
            template.execute(_context, writer);
            String actual = writer.toString();
            writer.close();
            assertEquals(_expected, actual);
        }
        catch (IOException ex) {
            //ex.printStackTrace();
            fail(ex.getMessage());
        }
        finally {
            _deleteFile(pdataFilename);
            _deleteFile(plogicFilename);
            if (_elemdef != null) _deleteFile(elemdefFilename);
        }
    }

    private void _createFile(String filename, String content) throws IOException {
        if (content == null) return;
        OutputStream output = new FileOutputStream(filename);
        Writer writer = new OutputStreamWriter(output, CHARSET);
        writer.write(content);
        writer.flush();
    }

    private void _deleteFile(String filename) {
        File file = new File(filename);
        file.delete();
    }



    // kwartz properties for Kwartz()
    public void testGetTemplate1() {

        _pdata = ""
            + "<html>\n"
            + " <body>\n"
            + "  <table id=\"LIST:item=list\">\n"
            + "   <tr id=\"mark:list\">\n"
            + "    <td><a href=\"#\" id=\"mark:item\">foo</a></td><td>@{item}@</td>\n"
            + "   </tr>\n"
            + "  </table>\n"
            + " </body>\n"
            + "</html>\n"
            ;

        _plogic = ""
            + "#list {\n"
            + "  attrs:  \"bgcolor\" item_tgl;\n"
            + "  //attrs: \"bgcolor\" color;\n"
            + "  //plogic: {\n"
            + "  //  i = 0;\n"
            + "  //  foreach (item in list) {\n"
            + "  //    i += 1;\n"
            + "  //    color = i % 2 == 0 ? \"#FFCCCC\" : \"#CCCCFF\";\n"
            + "  //    @stag;\n"
            + "  //    @cont;\n"
            + "  //    @etag;\n"
            + "  //  }\n"
            + "  //}\n"
            + "}\n"
            + "#item {\n"
            + "  value: X(item);\n"
            + "  attrs: \"href\" E(\"?id=\" .+ item .+ \"&page=_top\");\n"
            + "}\n"
            ;

        _expected = ""
            + "<html>\n"
            + " <body>\n"
            + "  <table>\n"
            + "   <tr bgcolor=\"#CCCCFF\">\n"
            + "    <td><a href=\"?id=foo&amp;page=_top\">foo</a></td><td>foo</td>\n"
            + "   </tr>\n"
            + "   <tr bgcolor=\"#FFCCCC\">\n"
            + "    <td><a href=\"?id=&lt;b&gt;bar&lt;/b&gt;&amp;page=_top\"><b>bar</b></a></td><td>&lt;b&gt;bar&lt;/b&gt;</td>\n"
            + "   </tr>\n"
            + "  </table>\n"
            + " </body>\n"
            + "</html>\n"
            ;

        _context.put("list", new String[] { "foo", "<b>bar</b>" });
        _props.setProperty("kwartz.escape", "true");         // kwartz.escape
        _props.setProperty("kwartz.even", "'#FFCCCC'");      // kwartz.even
        _props.setProperty("kwartz.odd",  "'#CCCCFF'");      // kwartz.odd

        _basename = "1";
        _test();
    }

}
