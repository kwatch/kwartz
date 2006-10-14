/*
 * $Rev$
 * $Release$
 * $Copyright$
 */
package kwartz;

import junit.framework.TestCase;
import java.util.*;


public class PresentationLogicParserTest extends TestCase {

	static Map __testdata;
	
	static {
		String resource_name = "kwartz/test-plogic-parser.yaml";
		try {
			__testdata = TestUtil.findAndLoadYamlTestData(resource_name, PresentationLogicParserTest.class);
		}
		catch(Exception ex) {
			ex.printStackTrace();
		}
	}
	
	List _tmpfiles = null;

	public void _test(String name) throws Exception {
		Map data = (Map)__testdata.get(name);
		String input = (String)data.get("input");
		String expected = (String)data.get("expected");
		String exception = (String)data.get("exception");
		String errormsg = (String)data.get("errormsg");
		//
		_tmpfiles = (List)data.get("tmpfiles");
		if (_tmpfiles != null) {
			for (Iterator it = _tmpfiles.iterator(); it.hasNext(); ) {
				Map m = (Map)it.next();
				String filename = (String)m.get("name");
				String content  = (String)m.get("content");
				if (filename == null)
					throw new Exception("*** test_"+name+": filename is not specified.");
				if (content == null)
					throw new Exception("*** test_"+name+": content is missing.");
				Util.writeFile(filename, content);
			}
		}
		//
		Parser parser = new PresentationLogicParser();		
		if (exception == null) {
			List rulesets = (List)parser.parse(input);
			StringBuffer sb = new StringBuffer();
			for (Iterator it = rulesets.iterator(); it.hasNext(); ) {
				Ast.Ruleset ruleset = (Ast.Ruleset)it.next();
				sb.append(ruleset.inspect());
			}
			String actual = sb.toString();
			assertEquals(expected, actual);
		}
		else {
			try {
				parser.parse(input);
				fail("'"+exception+"' is expected but not thrown.");
			}
			catch (Exception ex) {
				assertEquals(exception, ex.getClass().getName());
				assertEquals(errormsg, ex.toString());
			}
		}
	}
	
	public void tearDown() throws Exception {
		if (_tmpfiles != null) {
			for (Iterator it = _tmpfiles.iterator(); it.hasNext(); ) {
				Map m = (Map)it.next();
				String filename = (String)m.get("name");
				if (Util.fileExists(filename)) {
					Util.deleteFile(filename);
				}
			}
		}
	}
	

	public void test_ruleset1()  throws Exception { _test("ruleset1"); }
	public void test_ruleset2()  throws Exception { _test("ruleset2"); }
	public void test_ruleset3()  throws Exception { _test("ruleset3"); }
	public void test_ruleset4()  throws Exception { _test("ruleset4"); }
	public void test_ruleset5()  throws Exception { _test("ruleset5"); }
	public void test_ruleset6()  throws Exception { _test("ruleset6"); }
	public void test_ruleset7()  throws Exception { _test("ruleset7"); }
	public void test_ruleset8()  throws Exception { _test("ruleset8"); }
	public void test_selector1() throws Exception { _test("selector1"); }
	public void test_selector2() throws Exception { _test("selector2"); }
	public void test_selector3() throws Exception { _test("selector3"); }
	public void test_command1()  throws Exception { _test("command1"); }
	public void test_command2()  throws Exception { _test("command2"); }
	public void test_comment1()  throws Exception { _test("comment1"); }
	public void test_comment2()  throws Exception { _test("comment2"); }
	public void test_comment3()  throws Exception { _test("comment3"); }
	
	public void test_syntaxerr_ruleset1() throws Exception { _test("syntaxerr_ruleset1"); }
	public void test_syntaxerr_ruleset2() throws Exception { _test("syntaxerr_ruleset2"); }
	public void test_syntaxerr_selector1() throws Exception { _test("syntaxerr_selector1"); }
	public void test_syntaxerr_selector2() throws Exception { _test("syntaxerr_selector2"); }
	public void test_syntaxerr_selector3() throws Exception { _test("syntaxerr_selector3"); }
	public void test_syntaxerr_selector4() throws Exception { _test("syntaxerr_selector4"); }
	public void test_syntaxerr_stag1() throws Exception { _test("syntaxerr_stag1"); }
	public void test_syntaxerr_cont1() throws Exception { _test("syntaxerr_cont1"); }
	public void test_syntaxerr_etag1() throws Exception { _test("syntaxerr_etag1"); }
	public void test_syntaxerr_elem1() throws Exception { _test("syntaxerr_elem1"); }
	public void test_syntaxerr_value1() throws Exception { _test("syntaxerr_value1"); }
	public void test_syntaxerr_value2() throws Exception { _test("syntaxerr_value2"); }
	public void test_syntaxerr_attrs1() throws Exception { _test("syntaxerr_attrs1"); }
	public void test_syntaxerr_attrs2() throws Exception { _test("syntaxerr_attrs2"); }
	public void test_syntaxerr_attrs3() throws Exception { _test("syntaxerr_attrs3"); }
	public void test_syntaxerr_attrs4() throws Exception { _test("syntaxerr_attrs4"); }
	public void test_syntaxerr_append1() throws Exception { _test("syntaxerr_append1"); }
	public void test_syntaxerr_append2() throws Exception { _test("syntaxerr_append2"); }
	public void test_syntaxerr_remove1() throws Exception { _test("syntaxerr_remove1"); }
	public void test_syntaxerr_remove2() throws Exception { _test("syntaxerr_remove2"); }
	/* public void test_syntaxerr_tagname1() throws Exception { _test("syntaxerr_tagname1"); } */
	public void test_syntaxerr_logic1() throws Exception { _test("syntaxerr_logic1"); }
	public void test_syntaxerr_logic2() throws Exception { _test("syntaxerr_logic2"); }
	public void test_syntaxerr_before1() throws Exception { _test("syntaxerr_before1"); }
	public void test_syntaxerr_before2() throws Exception { _test("syntaxerr_before2"); }
	public void test_syntaxerr_after1() throws Exception { _test("syntaxerr_after1"); }
	public void test_syntaxerr_after2() throws Exception { _test("syntaxerr_after2"); }
	public void test_syntaxerr_command1() throws Exception { _test("syntaxerr_command1"); }
	public void test_syntaxerr_command2() throws Exception { _test("syntaxerr_command2"); }
	public void test_syntaxerr_command3() throws Exception { _test("syntaxerr_command3"); }
	
	public void test_rcurly1()   throws Exception { _test("rcurly1"); }
	public void test_rcurly2()   throws Exception { _test("rcurly2"); }
	public void test_rcurly3()   throws Exception { _test("rcurly3"); }
	
}

