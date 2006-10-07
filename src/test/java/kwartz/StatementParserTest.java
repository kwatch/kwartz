package kwartz;

import junit.framework.TestCase;
import java.util.*;



public class StatementParserTest extends TestCase {

	static Map __testdata;
	
	static {
		String resource = "kwartz/test-stmt-parser.yaml";
		try {
			String filename = Util.findResource(resource, StatementParserTest.class);
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
		String input = (String)data.get("input");
		String expected = (String)data.get("expected");
		String exception = (String)data.get("exception");
		String errormsg = (String)data.get("errormsg");
		//
		Parser parser = new StatementParser();		
		if (exception == null) {
			List stmts = (List)parser.parse(input);
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
				parser.parse(input);
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

}
