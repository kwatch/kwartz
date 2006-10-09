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
		String resource = "kwartz/test-converter.yaml";
		try {
			String filename = Util.findResource(resource, ConverterTest.class);
			if (filename == null)
				throw new java.io.FileNotFoundException(resource + ": not found.");
			List maplist = Util.loadYamlTestData(filename);
			__testdata = Util.convertMaplistToMaptable(maplist, "name");
		}
		catch(Exception ex) {
			ex.printStackTrace();
		}
	}
	
	
	public void _test(String name) throws Exception {
		Map data = (Map)__testdata.get(name);
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
	public void test_converter1() throws Exception { _test("converter1"); }
	public void test_converter2() throws Exception { _test("converter2"); }
	public void test_converter11() throws Exception { _test("converter11"); }
	public void test_converter12() throws Exception { _test("converter12"); }
	public void test_converter13() throws Exception { _test("converter13"); }
}
