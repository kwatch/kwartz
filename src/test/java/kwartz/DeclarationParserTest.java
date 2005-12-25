/**
 *  @(#) DeclarationParserTest.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

import junit.framework.TestCase;
import java.util.*;

public class DeclarationParserTest extends TestCase {
    private String _input;
    private String _expected;

    private void _test() {
        _test(false);
    }

    private void _test(boolean flagPrint) {
        DeclarationParser parser = new DeclarationParser();
        List decls = parser.parse(_input);
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < decls.size(); i++) {
            PresentationDeclaration decl = (PresentationDeclaration)decls.get(i);
            decl._inspect(0, sb);
        }
        String actual = sb.toString();
        if (flagPrint)
            System.out.println(actual);
        else
            assertEquals(_expected, actual);
    }

    public void testValuePart1() {
        _input = ""
                 + "#foo {\n"
                 + "    value: expr;\n"
                 + "}\n"
                 ;
        _expected = ""
                    + "#foo {\n"
                    + "  value:\n"
                    + "    expr\n"
                    + "}\n"
                    ;
        _test();
    }

    public void testAttrsPart1() {
        _input = ""
                 + "#foo {\n"
                 + "   attrs: \"id\" xid, \"href\" \"mailto:\" .+ email;\n"
                 + "}\n"
                 ;
        _expected = ""
                    + "#foo {\n"
                    + "  attrs:\n"
                    + "    \"href\"\n"
                    + "    .+\n"
                    + "      \"mailto:\"\n"
                    + "      email\n"
                    + "    \"id\"\n"
                    + "    xid\n"
                    + "}\n"
                    ;
        _test();
    }

    public void testRemovePart1() {
        _input = ""
                 + "#foo {\n"
                 + "    remove: \"checked\", \"id\", \"c:flag\";\n"
                 + "}\n"
                 ;
        _expected = ""
                    + "#foo {\n"
                    + "  remove:\n"
                    + "    \"checked\"\n"
                    + "    \"id\"\n"
                    + "    \"c:flag\"\n"
                    + "}\n"
                    ;
        _test();
    }

    public void testAppendPart1() {
        _input = ""
                 + "#foo {\n"
                 + "    append: flag1 ? ' checked=\"checked\"' : '', flag2 ? ' selected=\"selected\"' : '';\n"
                 + "}\n"
                 ;
        _expected = ""
                    + "#foo {\n"
                    + "  append:\n"
                    + "    ?:\n"
                    + "      flag1\n"
                    + "      \" checked=\\\"checked\\\"\"\n"
                    + "      \"\"\n"
                    + "    ?:\n"
                    + "      flag2\n"
                    + "      \" selected=\\\"selected\\\"\"\n"
                    + "      \"\"\n"
                    + "}\n"
                    ;
        _test();
    }

    public void testTagnamePart1() {
        _input = ""
                 + "#foo {\n"
                 + "    tagname  :  \"html:html\";\n"
                 + "}\n"
                 ;
        _expected = ""
                    + "#foo {\n"
                    + "  tagname:\n"
                    + "    \"html:html\"\n"
                    + "}\n"
                    ;
        _test();
    }

    public void testPlogicPart1() {
        _input = ""
                 + "#foo {\n"
                 + "    plogic : {\n"
                 + "        foreach (item in list) {\n"
                 + "            @stag;\n"
                 + "            @cont;\n"
                 + "            @etag;\n"
                 + "        }\n"
                 + "    }\n"
                 + "}\n"
                 ;
        _expected = ""
                    + "#foo {\n"
                    + "  plogic:\n"
                    + "    :block\n"
                    + "      :foreach\n"
                    + "        item\n"
                    + "        list\n"
                    + "        :block\n"
                    + "          @stag\n"
                    + "          @cont\n"
                    + "          @etag\n"
                    + "}\n"
                    ;
        _test();
    }


    public void testParseDeclaration1() {
        _input = ""
                 + "#user_list {\n"
                 + "        attrs:   \"bgcolor\" color;   // set bgcolor attribute value\n"
                 + "        remove:  \"id\";              // remove id attribute\n"
                 + "        plogic:  {\n"
                 + "            i = 0;\n"
                 + "            foreach (user in user_list) {\n"
                 + "                i += 1;\n"
                 + "                color = i%2==0 ? '#CCCCFF' : '#FFCCCC';\n"
                 + "                @stag;              // start tag\n"
                 + "                @cont;              // content\n"
                 + "                @etag;              // end tag\n"
                 + "            }\n"
                 + "        }\n"
                 + "}\n"
                 + "\n"
                 + "#name {\n"
                 + "        value:   user['name'];      // replace content by expression value\n"
                 + "        remove:  \"id\";              // remove id attribute\n"
                 + "}\n"
                 + "\n"
                 + "#email {\n"
                 + "        value:   user['email'];     // replace content by expression value\n"
                 + "        remove:  \"id\";              // remove id attribute\n"
                 + "        attrs:   \"href\" 'mailto:' .+ user['email'];    // set href attribute value\n"
                 + "}\n"
                 + "\n"
                 + "#dummy {\n"
                 + "        plogic: { }                 // remove an element\n"
                 + "}\n"
                 ;
        _expected = ""
                    + "#user_list {\n"
                    + "  remove:\n"
                    + "    \"id\"\n"
                    + "  attrs:\n"
                    + "    \"bgcolor\"\n"
                    + "    color\n"
                    + "  plogic:\n"
                    + "    :block\n"
                    + "      :expr\n"
                    + "        =\n"
                    + "          i\n"
                    + "          0\n"
                    + "      :foreach\n"
                    + "        user\n"
                    + "        user_list\n"
                    + "        :block\n"
                    + "          :expr\n"
                    + "            +=\n"
                    + "              i\n"
                    + "              1\n"
                    + "          :expr\n"
                    + "            =\n"
                    + "              color\n"
                    + "              ?:\n"
                    + "                ==\n"
                    + "                  %\n"
                    + "                    i\n"
                    + "                    2\n"
                    + "                  0\n"
                    + "                \"#CCCCFF\"\n"
                    + "                \"#FFCCCC\"\n"
                    + "          @stag\n"
                    + "          @cont\n"
                    + "          @etag\n"
                    + "}\n"
                    + "#name {\n"
                    + "  remove:\n"
                    + "    \"id\"\n"
                    + "  value:\n"
                    + "    []\n"
                    + "      user\n"
                    + "      \"name\"\n"
                    + "}\n"
                    + "#email {\n"
                    + "  remove:\n"
                    + "    \"id\"\n"
                    + "  attrs:\n"
                    + "    \"href\"\n"
                    + "    .+\n"
                    + "      \"mailto:\"\n"
                    + "      []\n"
                    + "        user\n"
                    + "        \"email\"\n"
                    + "  value:\n"
                    + "    []\n"
                    + "      user\n"
                    + "      \"email\"\n"
                    + "}\n"
                    + "#dummy {\n"
                    + "  plogic:\n"
                    + "    :block\n"
                    + "}\n"
                    ;
        _test();
    }

}
