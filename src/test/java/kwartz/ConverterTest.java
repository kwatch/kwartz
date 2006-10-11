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
	
	
	public void _test(String name) throws Exception {
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
		Parser parser = new PresentationLogicParser();
		List rulesets = (List)parser.parse(plogic);
		Handler handler = new BaseHandler(rulesets, properties);
		Converter converter = new TextConverter(handler, properties);
		//
		if (Pattern.matches("fetch\\d+", name)) {
			((TextConverter)converter)._reset(pdata, 1);
			TagInfo tag_info;
			StringBuffer sb = new StringBuffer();
			while ((tag_info = ((TextConverter)converter)._fetch()) != null) {
				sb.append(tag_info._inspect());
				sb.append("\n");
			}
			sb.append("rest: ").append(Util.inspect(((TextConverter)converter).getRest()));
			sb.append("\n");
			assertEquals(expected, sb.toString());
		}
		else if (exception == null) {
			List stmts = converter.convert(pdata);
			StringBuffer sb = new StringBuffer();
			for (Iterator it = stmts.iterator(); it.hasNext(); ) {
				Ast.Statement stmt = (Ast.Statement)it.next();
				sb.append(stmt.inspect());
			}
			assertEquals(expected, sb.toString());
		}
		else {
			try {
				converter.convert(pdata);
				fail("'"+exception+"' is expected but not thrown.");
			}
			catch (Exception ex) {
				assertEquals(exception, ex.getClass().getName());
				assertEquals(errormsg, ex.toString());
			}
		}
	}


	public void test_fetch1() throws Exception { _test("fetch1"); }
	
	public void test_convert01() throws Exception { _test("convert01"); }
	public void test_convert02() throws Exception { _test("convert02"); }
	public void test_convert03() throws Exception { _test("convert03"); }
	public void test_convert04() throws Exception { _test("convert04"); }
	public void test_convert05() throws Exception { _test("convert05"); }
	public void test_convert06() throws Exception { _test("convert06"); }
	public void test_convert07() throws Exception { _test("convert07"); }
	public void test_convert08() throws Exception { _test("convert08"); }
	
	public void test_convert11() throws Exception { _test("convert11"); }
	public void test_convert12() throws Exception { _test("convert12"); }
	public void test_convert13() throws Exception { _test("convert13"); }
	public void test_convert14() throws Exception { _test("convert14"); }
	public void test_convert15() throws Exception { _test("convert15"); }
	public void test_convert16() throws Exception { _test("convert16"); }
	public void test_convert17() throws Exception { _test("convert17"); }
	public void test_convert18() throws Exception { _test("convert18"); }
	public void test_convert19() throws Exception { _test("convert19"); }

	public void test_converter01() throws Exception { _test("converter01"); }
	public void test_converter02() throws Exception { _test("converter02"); }
	public void test_converter03() throws Exception { _test("converter03"); }
	public void test_converter04() throws Exception { _test("converter04"); }
	public void test_converter11() throws Exception { _test("converter11"); }
	public void test_converter12() throws Exception { _test("converter12"); }
	public void test_converter13() throws Exception { _test("converter13"); }
	public void test_converter14() throws Exception { _test("converter14"); }
	public void test_converter15() throws Exception { _test("converter15"); }
	public void test_converter16() throws Exception { _test("converter16"); }

}
