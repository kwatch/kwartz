/*
 * $Rev$
 * $Release$
 * $Copyright$
 */
package kwartz;

import junit.framework.TestCase;
import java.util.*;
import java.util.regex.*;


public class StatementParserTest extends TestCase {

	static Map __testdata;
	
	static {
		String resource_name = "kwartz/test-stmt-parser.yaml";
		try {
			__testdata = TestUtil.findAndLoadYamlTestData(resource_name, StatementParserTest.class);
		}
		catch(Exception ex) {
			ex.printStackTrace();
		}
	}
	
	static String __testname = null; //"syntaxerr_exprstmt\\d+";
	public void _test(String name) throws Exception {
		if (__testname != null && !Pattern.matches(__testname, name))
			return;
		Map data = (Map)__testdata.get(name);
		String input = (String)data.get("input");
		String expected = (String)data.get("expected");
		String exception = (String)data.get("exception");
		String errormsg = (String)data.get("errormsg");
		//
		Parser parser = new StatementParser();
		String filename = "test-stmt-parser.plogic";
		if (exception == null) {
			List stmts = (List)parser.parse(input, filename);
			StringBuffer sb = new StringBuffer();
			for (Iterator it = stmts.iterator(); it.hasNext(); ) {
				Ast.Statement stmt = (Ast.Statement)it.next();
				sb.append(stmt.inspect());
			}
			String actual = sb.toString();
			assertEquals(expected, actual);
		}
		else {
			try {
				parser.parse(input, filename);
				fail("'"+exception+"' is expected but not thrown.");
			}
			catch (Exception ex) {
				assertEquals(exception, ex.getClass().getName());
				assertEquals(errormsg, ex.toString());
			}
		}
	}
	

	public void test_print1() throws Exception { _test("print1"); }
	public void test_print2() throws Exception { _test("print2"); }
	public void test_print3() throws Exception { _test("print3"); }
	
	public void test_expr1() throws Exception { _test("expr1"); }
	public void test_expr2() throws Exception { _test("expr2"); }
	
	public void test_while1() throws Exception { _test("while1"); }
	public void test_while2() throws Exception { _test("while2"); }
	
	public void test_foreach1() throws Exception { _test("foreach1"); }
	public void test_foreach2() throws Exception { _test("foreach2"); }
	public void test_foreach3() throws Exception { _test("foreach3"); }
	public void test_foreach4() throws Exception { _test("foreach4"); }
	
	public void test_if1() throws Exception { _test("if1"); }
	public void test_if2() throws Exception { _test("if2"); }
	public void test_if3() throws Exception { _test("if3"); }
	public void test_if4() throws Exception { _test("if4"); }
	public void test_if5() throws Exception { _test("if5"); }

	public void test_break1() throws Exception { _test("break1"); }
	public void test_break2() throws Exception { _test("break2"); }
	public void test_continue1() throws Exception { _test("continue1"); }
	public void test_continue2() throws Exception { _test("continue2"); }
	
	public void test_elem1() throws Exception { _test("elem1"); }
	public void test_elem2() throws Exception { _test("elem2"); }
	
	
	public void test_syntaxerr_print1() throws Exception { _test("syntaxerr_print1"); }
	public void test_syntaxerr_print2() throws Exception { _test("syntaxerr_print2"); }
	public void test_syntaxerr_print3() throws Exception { _test("syntaxerr_print3"); }
	public void test_syntaxerr_print4() throws Exception { _test("syntaxerr_print4"); }
	public void test_syntaxerr_exprstmt1() throws Exception { _test("syntaxerr_exprstmt1"); }
	public void test_syntaxerr_exprstmt2() throws Exception { _test("syntaxerr_exprstmt2"); }
	public void test_syntaxerr_exprstmt3() throws Exception { _test("syntaxerr_exprstmt3"); }
	public void test_syntaxerr_exprstmt4() throws Exception { _test("syntaxerr_exprstmt4"); }
	public void test_syntaxerr_foreach1() throws Exception { _test("syntaxerr_foreach1"); }
	public void test_syntaxerr_foreach2() throws Exception { _test("syntaxerr_foreach2"); }
	public void test_syntaxerr_foreach3() throws Exception { _test("syntaxerr_foreach3"); }
	public void test_syntaxerr_foreach4() throws Exception { _test("syntaxerr_foreach4"); }
	public void test_syntaxerr_foreach5() throws Exception { _test("syntaxerr_foreach5"); }
	public void test_syntaxerr_if1() throws Exception { _test("syntaxerr_if1"); }
	public void test_syntaxerr_if2() throws Exception { _test("syntaxerr_if2"); }
	public void test_syntaxerr_if3() throws Exception { _test("syntaxerr_if3"); }
	public void test_syntaxerr_if4() throws Exception { _test("syntaxerr_if4"); }
	public void test_syntaxerr_elseif1() throws Exception { _test("syntaxerr_elseif1"); }
	public void test_syntaxerr_elseif2() throws Exception { _test("syntaxerr_elseif2"); }
	public void test_syntaxerr_elseif3() throws Exception { _test("syntaxerr_elseif3"); }
	public void test_syntaxerr_elseif4() throws Exception { _test("syntaxerr_elseif4"); }
	public void test_syntaxerr_else1() throws Exception { _test("syntaxerr_else1"); }
	public void test_syntaxerr_else2() throws Exception { _test("syntaxerr_else2"); }
	public void test_syntaxerr_while1() throws Exception { _test("syntaxerr_while1"); }
	public void test_syntaxerr_while2() throws Exception { _test("syntaxerr_while2"); }
	public void test_syntaxerr_while3() throws Exception { _test("syntaxerr_while3"); }
	public void test_syntaxerr_while4() throws Exception { _test("syntaxerr_while4"); }
	public void test_syntaxerr_while5() throws Exception { _test("syntaxerr_while5"); }
	public void test_syntaxerr_break1() throws Exception { _test("syntaxerr_break1"); }
	public void test_syntaxerr_continue1() throws Exception { _test("syntaxerr_continue1"); }
	public void test_syntaxerr_stag1() throws Exception { _test("syntaxerr_stag1"); }
	public void test_syntaxerr_etag1() throws Exception { _test("syntaxerr_etag1"); }
	public void test_syntaxerr_cont1() throws Exception { _test("syntaxerr_cont1"); }
	public void test_syntaxerr_elem1() throws Exception { _test("syntaxerr_elem1"); }
	public void test_syntaxerr_element1() throws Exception { _test("syntaxerr_element1"); }
	public void test_syntaxerr_element2() throws Exception { _test("syntaxerr_element2"); }
	public void test_syntaxerr_content1() throws Exception { _test("syntaxerr_content1"); }
	public void test_syntaxerr_content2() throws Exception { _test("syntaxerr_content2"); }
	

}
