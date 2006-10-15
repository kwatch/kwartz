package kwartz;

import junit.framework.TestCase;
import java.util.*;

public class ExpressionParserTest extends TestCase {

	static Map __testdata;
	
	static {
		String resource_name = "kwartz/test-expr-parser.yaml";
		try {
			__testdata = TestUtil.findAndLoadYamlTestData(resource_name, ExpressionParserTest.class);
		}
		catch(Exception ex) {
			ex.printStackTrace();
		}
	}
	
	
	public void _test(String name) throws Exception {
		Map data = (Map)__testdata.get(name);
		String input = (String)data.get("input");
		List   inputs = (List)data.get("inputs");
		String expected = (String)data.get("expected");
		String exception = (String)data.get("exception");
		String errormsg = (String)data.get("errormsg");
		//
		if (inputs == null) {
			inputs = new ArrayList();
			inputs.add(input);
		}
		//
		Parser parser = new ExpressionParser();
		Ast.Expression expr;
		String filename = "test-expr-parser.plogic";
		for (Iterator it = inputs.iterator(); it.hasNext(); ) {
			input = (String)it.next();
			if (exception == null) {
				expr = (Ast.Expression)parser.parse(input, filename);
				String actual = expr.inspect();
				assertEquals(expected, actual);
			}
			else {
				try {
					expr = (Ast.Expression)parser.parse(input, filename);
					fail("'"+exception+"' is expected but not thrown.");
				}
				catch (Exception ex) {
					assertEquals(exception, ex.getClass().getName());
					assertEquals(errormsg, ex.toString());
				}
			}
		}
	}
	
	
	
	public void test_literal1() throws Exception { _test("literal1"); }
	public void test_literal2() throws Exception { _test("literal2"); }
	public void test_literal3() throws Exception { _test("literal3"); }
	public void test_literal4() throws Exception { _test("literal4"); }
	public void test_literal5() throws Exception { _test("literal5"); }
	public void test_literal6() throws Exception { _test("literal6"); }
	public void test_literal7() throws Exception { _test("literal7"); }
	/* */
	
	public void test_arithmetic1() throws Exception { _test("arithmetic1"); }
	public void test_arithmetic2() throws Exception { _test("arithmetic2"); }
	public void test_arithmetic3() throws Exception { _test("arithmetic3"); }
	/* */
	
	public void test_relational1() throws Exception { _test("relational1"); }
	public void test_relational2() throws Exception { _test("relational2"); }
	public void test_relational3() throws Exception { _test("relational3"); }
	public void test_relational4() throws Exception { _test("relational4"); }
	public void test_relational5() throws Exception { _test("relational5"); }
	public void test_relational6() throws Exception { _test("relational6"); }
	public void test_relational7() throws Exception { _test("relational9"); }
	/* */
	
	public void test_logical1() throws Exception { _test("logical1"); }
	public void test_logical2() throws Exception { _test("logical2"); }
	public void test_logical3() throws Exception { _test("logical3"); }
	public void test_logical4() throws Exception { _test("logical4"); }
	public void test_logical5() throws Exception { _test("logical5"); }
	public void test_logical6() throws Exception { _test("logical6"); }
	/* */
	
	public void test_index1() throws Exception { _test("index1"); }
	public void test_index2() throws Exception { _test("index2"); }
	public void test_index3() throws Exception { _test("index3"); }
	public void test_index4() throws Exception { _test("index4"); }
	/* */
	
	public void test_funcall1() throws Exception { _test("funcall1"); }
	public void test_funcall2() throws Exception { _test("funcall2"); }
	public void test_funcall3() throws Exception { _test("funcall3"); }
	public void test_funcall4() throws Exception { _test("funcall4"); }
	/* */
	
	public void test_method1() throws Exception { _test("method1"); }
	public void test_method2() throws Exception { _test("method2"); }
	public void test_method3() throws Exception { _test("method3"); }
	public void test_method4() throws Exception { _test("method4"); }
	/* */
	
	public void test_property1() throws Exception { _test("property1"); }
	public void test_property2() throws Exception { _test("property2"); }
	public void test_property3() throws Exception { _test("property3"); }
	/* */
	
	public void test_assignment1() throws Exception { _test("assignment1"); }
	public void test_assignment2() throws Exception { _test("assignment2"); }
	public void test_assignment3() throws Exception { _test("assignment3"); }
	public void test_assignment4() throws Exception { _test("assignment4"); }
	public void test_assignment5() throws Exception { _test("assignment5"); }
	public void test_assignment6() throws Exception { _test("assignment6"); }
	public void test_assignment7() throws Exception { _test("assignment7"); }
	public void test_assignment8() throws Exception { _test("assignment8"); }
	public void test_assignment9() throws Exception { _test("assignment9"); }
	public void test_assignment11() throws Exception { _test("assignment11"); }
	public void test_assignment12() throws Exception { _test("assignment12"); }
	public void test_assignment13() throws Exception { _test("assignment13"); }
	public void test_assignment14() throws Exception { _test("assignment19"); }
	/* */
	
	public void test_conditional1() throws Exception { _test("conditional1"); }
	public void test_conditional2() throws Exception { _test("conditional2"); }
	public void test_conditional3() throws Exception { _test("conditional3"); }
	/* */

}
