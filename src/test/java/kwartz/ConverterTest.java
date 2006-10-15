/*
 * $Rev$
 * $Release$
 * $Copyright$
 */
package kwartz;

import junit.framework.TestCase;
import java.util.*;
import java.util.regex.*;


public class ConverterTest extends TestCase {

	static Map __testdata;
	
	static {
		String resource_name = "kwartz/test-converter.yaml";
		try {
			__testdata = TestUtil.findAndLoadYamlTestData(resource_name, ConverterTest.class);
		}
		catch (Exception ex) {
			ex.printStackTrace();
		}
	}
	
	
	static String __testname_pattern = null; // "converter_directive_foreach\\d";
	
	public void _test(String name) throws Exception {
		if (__testname_pattern != null && !Pattern.matches(__testname_pattern, name))
			return;
		Map data = (Map)__testdata.get(name);
		if (data == null)
			throw new Exception("*** ConverterTest: name '"+name+"' is not found.");
		String pdata = (String)data.get("pdata");
		String plogic = (String)data.get("plogic");
		String expected = (String)data.get("expected");
		String exception = (String)data.get("exception");
		String errormsg = (String)data.get("errormsg");
		Map properties = (Map)data.get("properties");
		//
		String filename = "test-converter.plogic";
		Parser parser = new PresentationLogicParser();
		List rulesets = (List)parser.parse(plogic, filename);
		Handler handler = new BaseHandler(rulesets, properties);
		Converter converter = new TextConverter(handler, properties);
		//
		filename = "test-converter.html";
		if (Pattern.matches(".*_fetch\\d+$", name)) {
			((TextConverter)converter)._reset(pdata, filename, 1);
			TagInfo tag_info;
			StringBuffer sb = new StringBuffer();
			while ((tag_info = ((TextConverter)converter)._fetch()) != null) {
				sb.append(tag_info.inspect());
				sb.append("\n");
			}
			sb.append("rest: ").append(Util.inspect(((TextConverter)converter).getRest()));
			sb.append("\n");
			assertEquals(expected, sb.toString());
		}
		else if (exception == null) {
			List stmts = converter.convert(pdata, filename);
			StringBuffer sb = new StringBuffer();
			for (Iterator it = stmts.iterator(); it.hasNext(); ) {
				Ast.Statement stmt = (Ast.Statement)it.next();
				sb.append(stmt.inspect());
			}
			assertEquals(expected, sb.toString());
		}
		else {
			try {
				converter.convert(pdata, filename);
				fail("'"+exception+"' is expected but not thrown.");
			}
			catch (Exception ex) {
				assertEquals(exception, ex.getClass().getName());
				assertEquals(errormsg, ex.toString());
			}
		}
	}


	public void test_convert_fetch1() throws Exception { _test("convert_fetch1"); }
	
	public void test_convert_pdata1() throws Exception { _test("convert_pdata1"); }
	public void test_convert_pdata2() throws Exception { _test("convert_pdata2"); }
	public void test_convert_pdata3() throws Exception { _test("convert_pdata3"); }
	public void test_convert_pdata4() throws Exception { _test("convert_pdata4"); }
	public void test_convert_pdata5() throws Exception { _test("convert_pdata5"); }
	public void test_convert_pdata6() throws Exception { _test("convert_pdata6"); }
	public void test_convert_pdata7() throws Exception { _test("convert_pdata7"); }
	public void test_convert_pdata9() throws Exception { _test("convert_pdata9"); }
	
	public void test_convert_prop_stag1() throws Exception { _test("convert_prop_stag1"); }
	public void test_convert_prop_etag1() throws Exception { _test("convert_prop_etag1"); }
	public void test_convert_prop_cont1() throws Exception { _test("convert_prop_cont1"); }
	public void test_convert_prop_elem1() throws Exception { _test("convert_prop_elem1"); }
	public void test_convert_prop_value1() throws Exception { _test("convert_prop_value1"); }
	public void test_convert_prop_attrs1() throws Exception { _test("convert_prop_attrs1"); }
	public void test_convert_prop_append1() throws Exception { _test("convert_prop_append1"); }
	public void test_convert_prop_remove1() throws Exception { _test("convert_prop_remove1"); }
	public void test_convert_prop_logic1() throws Exception { _test("convert_prop_logic1"); }
	public void test_convert_prop_before1() throws Exception { _test("convert_prop_before1"); }
	public void test_convert_prop_after1() throws Exception { _test("convert_prop_after1"); }
	
	public void test_convert_directive_dummy1() throws Exception { _test("convert_directive_dummy1"); }
	public void test_convert_directive_mark1() throws Exception { _test("convert_directive_mark1"); }
	public void test_convert_directive_stag1() throws Exception { _test("convert_directive_stag1"); }
	public void test_convert_directive_stag2() throws Exception { _test("convert_directive_stag2"); }
	public void test_convert_directive_etag1() throws Exception { _test("convert_directive_etag1"); }
	public void test_convert_directive_etag2() throws Exception { _test("convert_directive_etag2"); }
	public void test_convert_directive_cont1() throws Exception { _test("convert_directive_cont1"); }
	public void test_convert_directive_cont2() throws Exception { _test("convert_directive_cont2"); }
	public void test_convert_directive_elem1() throws Exception { _test("convert_directive_elem1"); }
	public void test_convert_directive_elem2() throws Exception { _test("convert_directive_elem2"); }
	public void test_convert_directive_value1() throws Exception { _test("convert_directive_value1"); }
	public void test_convert_directive_value2() throws Exception { _test("convert_directive_value2"); }
	public void test_convert_directive_attr1() throws Exception { _test("convert_directive_attr1"); }
	public void test_convert_directive_attr2() throws Exception { _test("convert_directive_attr2"); }
	public void test_convert_directive_append1() throws Exception { _test("convert_directive_append1"); }
	public void test_convert_directive_append2() throws Exception { _test("convert_directive_append2"); }
	public void test_convert_directive_replace1() throws Exception { _test("convert_directive_replace1"); }
	public void test_convert_directive_replace2() throws Exception { _test("convert_directive_replace2"); }
	public void test_convert_directive_replace3() throws Exception { _test("convert_directive_replace3"); }
	public void test_convert_directive_replace4() throws Exception { _test("convert_directive_replace4"); }
	public void test_convert_directive_replace9() throws Exception { _test("convert_directive_replace9"); }
	public void test_convert_directive_set1() throws Exception { _test("convert_directive_set1"); }
	public void test_convert_directive_set2() throws Exception { _test("convert_directive_set2"); }
	public void test_convert_directive_if1() throws Exception { _test("convert_directive_if1"); }
	public void test_convert_directive_elseif1() throws Exception { _test("convert_directive_elseif1"); }
	public void test_convert_directive_elseif2() throws Exception { _test("convert_directive_elseif2"); }
	public void test_convert_directive_elseif9() throws Exception { _test("convert_directive_elseif9"); }
	public void test_convert_directive_else1() throws Exception { _test("convert_directive_else1"); }
	public void test_convert_directive_else2() throws Exception { _test("convert_directive_else2"); }
	public void test_convert_directive_else9() throws Exception { _test("convert_directive_else9"); }
	public void test_convert_directive_while1() throws Exception { _test("convert_directive_while1"); }
	public void test_convert_directive_loop1() throws Exception { _test("convert_directive_loop1"); }
	public void test_convert_directive_foreach1() throws Exception { _test("convert_directive_foreach1"); }
	public void test_convert_directive_foreach2() throws Exception { _test("convert_directive_foreach2"); }
	public void test_convert_directive_foreach3() throws Exception { _test("convert_directive_foreach3"); }
	public void test_convert_directive_foreach4() throws Exception { _test("convert_directive_foreach4"); }
	public void test_convert_directive_foreach9() throws Exception { _test("convert_directive_foreach9"); }
	public void test_convert_directive_list1() throws Exception { _test("convert_directive_list1"); }
	public void test_convert_directive_list2() throws Exception { _test("convert_directive_list2"); }
	public void test_convert_directive_list3() throws Exception { _test("convert_directive_list3"); }
	public void test_convert_directive_list9() throws Exception { _test("convert_directive_list9"); }
	public void test_convert_directive_default1() throws Exception { _test("convert_directive_default1"); }
	public void test_convert_directive_error1() throws Exception { _test("convert_directive_error1"); }
	public void test_convert_directive_error2() throws Exception { _test("convert_directive_error2"); }
	public void test_convert_directive_combination1() throws Exception { _test("convert_directive_combination1"); }

	public void test_converter01() throws Exception { _test("converter01"); }
	public void test_converter02() throws Exception { _test("converter02"); }
	public void test_converter03() throws Exception { _test("converter03"); }
	public void test_converter04() throws Exception { _test("converter04"); }
	public void test_converter_selector_id1() throws Exception { _test("converter_selector_id1"); }
	public void test_converter_selector_class1() throws Exception { _test("converter_selector_class1"); }
	public void test_converter_selector_tag1() throws Exception { _test("converter_selector_tag1"); }
	public void test_converter_selector_mixed1() throws Exception { _test("converter_selector_mixed1"); }
	public void test_converter_selector_mixed2() throws Exception { _test("converter_selector_mixed2"); }
	public void test_converter_selector_mixed3() throws Exception { _test("converter_selector_mixed3"); }
	
	public void test_converter_embedexpr1() throws Exception { _test("converter_embedexpr1"); }
	public void test_converter_embedexpr2() throws Exception { _test("converter_embedexpr2"); }
	public void test_converter_embedexpr3() throws Exception { _test("converter_embedexpr3"); }
	public void test_converter_embedexpr4() throws Exception { _test("converter_embedexpr4"); }
	public void test_converter_embedexpr5() throws Exception { _test("converter_embedexpr5"); }
	public void test_converter_embedexpr7() throws Exception { _test("converter_embedexpr7"); }
	public void test_converter_embedexpr8() throws Exception { _test("converter_embedexpr8"); }
	public void test_converter_embedexpr9() throws Exception { _test("converter_embedexpr9"); }
	
	public void test_converter_delspan1() throws Exception { _test("converter_delspan1"); }
	public void test_converter_delspan2() throws Exception { _test("converter_delspan2"); }
	public void test_converter_delspan3() throws Exception { _test("converter_delspan3"); }
	public void test_converter_delspan4() throws Exception { _test("converter_delspan4"); }
	public void test_converter_delspan5() throws Exception { _test("converter_delspan5"); }
	
	public void test_convert_document1() throws Exception { _test("convert_document1"); }
	public void test_convert_document2() throws Exception { _test("convert_document2"); }
	public void test_convert_document3() throws Exception { _test("convert_document3"); }

}
