/**
 *  @(#) ExpanderTest.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

import kwartz.node.*;
import junit.framework.TestCase;
import java.util.*;

public class ExpanderTest extends TestCase {
    private String _pdata;
    private String _plogic;
    private String _expected;
    private boolean _print;
    private Properties _props = new Properties(Configuration.defaults);

    private void _test() {
        // parse plogic
        DeclarationParser declParser = new DeclarationParser(_props);
        List declList = declParser.parse(_plogic);

        // parse pdata
        Converter converter = new DefaultConverter(_props);
        Statement[] stmts = converter.convert(_pdata);

        // create block statement
        BlockStatement blockStmt = new BlockStatement(stmts);

        // create element table
        List elemList = converter.getElementList();
        Map elementTable = Element.createElementTable(elemList);

        // merge declarations
        Element.mergeDeclarationList(elementTable, declList);

        // expand
        Expander expander = new DefaultExpander(elementTable, _props);
        expander.expand(blockStmt, null);

        // assert
        String actual = blockStmt._inspect().toString();
        if (_print) {
            System.out.println("*** debug: kwartz.escape = " + _props.getProperty("kwartz.escape"));
            System.out.println(actual);
        } else {
            assertEquals(_expected, actual);
        }
    }


    // ...
    public void testExpand01() {
        _pdata = ""
            + "Hello <strong id=\"mark:user\">World</strong>!\n"
            ;

        _plogic = ""
            + "#user {\n"
            + "  value: user;\n"
            + "}\n"
            ;

        _expected = ""
            + ":block\n"
            + "  :print\n"
            + "    \"Hello\"\n"
            + "  :block\n"
            + "    :print\n"
            + "      \" <strong\"\n"
            + "      \">\"\n"
            + "    :print\n"
            + "      user\n"
            + "    :print\n"
            + "      \"</strong>\"\n"
            + "  :print\n"
            + "    \"!\\n\"\n"
            ;

        _test();
    }

    // ...
    public void testExpand02() {
        _pdata = ""
            + "<ul id=\"mark:list\">\n"
            + "  <li>@{item}@</li>\n"
            + "</ul>\n"
            ;

        _plogic = ""
            + "#list {\n"
            + "    plogic: {\n"
            + "        foreach (item in list) {\n"
            + "            @stag;  // start tag\n"
            + "            @cont;  // content\n"
            + "            @etag;  // end tag\n"
            + "        }\n"
            + "    }\n"
            + "}\n"
            ;

        _expected = ""
            + ":block\n"
            + "  :block\n"
            + "    :foreach\n"
            + "      item\n"
            + "      list\n"
            + "      :block\n"
            + "        :print\n"
            + "          \"<ul\"\n"
            + "          \">\\n\"\n"
            + "        :block\n"
            + "          :print\n"
            + "            \"  <li>\"\n"
            + "          :print\n"
            + "            item\n"
            + "          :print\n"
            + "            \"</li>\\n\"\n"
            + "        :print\n"
            + "          \"</ul>\\n\"\n"
            ;

        _test();
    }

    // ...
    public void testExpand03() {
        _pdata = ""
            + "<ul id=\"mark:list\">\n"
            + "  <li>@{item}@</li>\n"
            + "</ul>\n"
            ;

        _plogic = ""
            + "#list {\n"
            + "    plogic: {\n"
            + "        @stag;  // start tag\n"
            + "        foreach (item in list) {\n"
            + "            @cont;  // content\n"
            + "        }\n"
            + "        @etag;  // end tag\n"
            + "    }\n"
            + "}\n"
            ;

        _expected = ""
            + ":block\n"
            + "  :block\n"
            + "    :print\n"
            + "      \"<ul\"\n"
            + "      \">\\n\"\n"
            + "    :foreach\n"
            + "      item\n"
            + "      list\n"
            + "      :block\n"
            + "        :block\n"
            + "          :print\n"
            + "            \"  <li>\"\n"
            + "          :print\n"
            + "            item\n"
            + "          :print\n"
            + "            \"</li>\\n\"\n"
            + "    :print\n"
            + "      \"</ul>\\n\"\n"
            ;

        _test();
    }

    // ...
    public void testExpand04() {
        _pdata = ""
            + "<table id=\"table\">\n"
            + "  <tr class=\"odd\" style=\"color:red\" id=\"mark:list\">\n"
            + "    <td id=\"mark:name\" style=\"font-weight:bold\">foo</td>\n"
            + "    <td><a href=\"...\" id=\"mark:mail\">foo@mail.org</a></td>\n"
            + "  </tr>\n"
            + "  <tr class=\"even\" id=\"mark:dummy\">\n"
            + "    <td>bar</td>\n"
            + "    <td>bar@mail.net</td>\n"
            + "  </tr>\n"
            + "</table>\n"
            ;

        _plogic = ""
            + "#table {\n"
            + "    tagname:  \"html:table\";\n"
            + "    append:   flag ? ' align=\"center\"' : '';\n"
            + "}\n"
            + "#list {\n"
            + "    attrs:  \"class\" klass;\n"
            + "    remove: \"style\", \"width\";\n"
            + "    plogic: {\n"
            + "        i = 0;\n"
            + "        foreach (item in list) {\n"
            + "            i += 1;\n"
            + "            klass = i % 2 == 0 ? 'even' : 'odd';\n"
            + "            @stag;\n"
            + "            @cont;\n"
            + "            @etag;\n"
            + "        }\n"
            + "    }\n"
            + "}\n"
            + "#name {\n"
            + "  value: item.name;\n"
            + "}\n"
            + "#mail {\n"
            + "  value:  item.email;\n"
            + "  attrs:  \"href\" \"mailto:\" .+ item.email;\n"
            + "}\n"
            + "#dummy {\n"
            + "  plogic: { }\n"
            + "}\n"
            ;

        _expected = ""
            + ":block\n"
            + "  :block\n"
            + "    :print\n"
            + "      \"<html:table id=\\\"\"\n"
            + "      \"table\"\n"
            + "      \"\\\"\"\n"
            + "      ?:\n"
            + "        flag\n"
            + "        \" align=\\\"center\\\"\"\n"
            + "        \"\"\n"
            + "      \">\\n\"\n"
            + "    :block\n"
            + "      :block\n"
            + "        :expr\n"
            + "          =\n"
            + "            i\n"
            + "            0\n"
            + "        :foreach\n"
            + "          item\n"
            + "          list\n"
            + "          :block\n"
            + "            :expr\n"
            + "              +=\n"
            + "                i\n"
            + "                1\n"
            + "            :expr\n"
            + "              =\n"
            + "                klass\n"
            + "                ?:\n"
            + "                  ==\n"
            + "                    %\n"
            + "                      i\n"
            + "                      2\n"
            + "                    0\n"
            + "                  \"even\"\n"
            + "                  \"odd\"\n"
            + "            :print\n"
            + "              \"  <tr class=\\\"\"\n"
            + "              klass\n"
            + "              \"\\\"\"\n"
            + "              \">\\n\"\n"
            + "            :block\n"
            + "              :block\n"
            + "                :print\n"
            + "                  \"    <td style=\\\"\"\n"
            + "                  \"font-weight:bold\"\n"
            + "                  \"\\\"\"\n"
            + "                  \">\"\n"
            + "                :print\n"
            + "                  .\n"
            + "                    item\n"
            + "                    name\n"
            + "                :print\n"
            + "                  \"</td>\\n\"\n"
            + "              :print\n"
            + "                \"    <td>\"\n"
            + "              :block\n"
            + "                :print\n"
            + "                  \"<a href=\\\"\"\n"
            + "                  .+\n"
            + "                    \"mailto:\"\n"
            + "                    .\n"
            + "                      item\n"
            + "                      email\n"
            + "                  \"\\\"\"\n"
            + "                  \">\"\n"
            + "                :print\n"
            + "                  .\n"
            + "                    item\n"
            + "                    email\n"
            + "                :print\n"
            + "                  \"</a>\"\n"
            + "              :print\n"
            + "                \"</td>\\n\"\n"
            + "            :print\n"
            + "              \"  </tr>\\n\"\n"
            + "      :block\n"
            + "    :print\n"
            + "      \"</html:table>\\n\"\n"
            ;

        _test();
    }

    // add attributes
    public void testExpand05() {
        _pdata = ""
            + "<img title=\"example image\" src=\"dummy.png\" id=\"mark:image\">\n"
            ;

        _plogic = ""
            + "#image {\n"
            + "    attrs:  \"src\"  image_url, \"class\" klass;\n"
            + "}\n"
            ;

        _expected = ""
            + ":block\n"
            + "  :block\n"
            + "    :print\n"
            + "      \"<img title=\\\"\"\n"
            + "      \"example image\"\n"
            + "      \"\\\" src=\\\"\"\n"
            + "      image_url\n"
            + "      \"\\\" class=\\\"\"\n"
            + "      klass\n"
            + "      \"\\\"\"\n"
            + "      \">\\n\"\n"
            + "    :block\n"
            + "    :print\n"
            ;

        _test();
    }

    // escape
    public void testExpand11() {
        _pdata = ""
            + "<td id=\"mark:name\">foo</td><td>@{email}@</td>\n"
            ;

        _plogic = ""
            + "#name {  value:  name; }\n"
            ;

        _expected = ""
            + ":block\n"
            + "  :block\n"
            + "    :print\n"
            + "      \"<td\"\n"
            + "      \">\"\n"
            + "    :print\n"
            + "      E()\n"
            + "        name\n"
            + "    :print\n"
            + "      \"</td>\"\n"
            + "  :print\n"
            + "    \"<td>\"\n"
            + "  :print\n"
            + "    E()\n"
            + "      email\n"
            + "  :print\n"
            + "    \"</td>\\n\"\n"
            ;

        _props.setProperty("kwartz.escape", "true");
        _test();
    }

    // escape with E() and X()
    public void testExpand12() {
        _pdata = ""
            + "<td id=\"Value:name\">foo</td><td>@{X(email)}@</td>\n"
            ;

        _plogic = ""
            ;

        _expected = ""
            + ":block\n"
            + "  :print\n"
            + "    \"<td>\"\n"
            + "  :print\n"
            + "    E()\n"
            + "      name\n"
            + "  :print\n"
            + "    \"</td>\"\n"
            + "  :print\n"
            + "    \"<td>\"\n"
            + "  :print\n"
            + "    X()\n"
            + "      email\n"
            + "  :print\n"
            + "    \"</td>\\n\"\n"
            ;

        _props.setProperty("kwartz.escape", "true");
        _test();
    }

}
