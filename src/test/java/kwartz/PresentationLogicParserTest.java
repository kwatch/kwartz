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
		String resource = "kwartz/test-plogic-parser.yaml";
		try {
			String filename = Util.findResource(resource, PresentationLogicParserTest.class);
			if (filename == null)
				throw new java.io.FileNotFoundException(resource + ": not found.");
			List maplist = Util.loadYamlTestData(filename);
			__testdata = Util.convertMaplistToMaptable(maplist, "name");
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
	public void test_selector1() throws Exception { _test("selector1"); }
	public void test_selector2() throws Exception { _test("selector2"); }
	public void test_selector3() throws Exception { _test("selector3"); }
	public void test_rcurly1()   throws Exception { _test("rcurly1"); }
	public void test_rcurly2()   throws Exception { _test("rcurly2"); }
	public void test_rcurly3()   throws Exception { _test("rcurly3"); }
	public void test_command1()  throws Exception { _test("command1"); }
	public void test_command2()  throws Exception { _test("command2"); }
	public void test_comment1()  throws Exception { _test("comment1"); }
	public void test_comment2()  throws Exception { _test("comment2"); }
	public void test_comment3()  throws Exception { _test("comment3"); }
	
}
