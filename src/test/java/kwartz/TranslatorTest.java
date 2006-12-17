/*
 * $Rev$
 * $Release$
 * $Copyright$
 */
package kwartz;

import junit.framework.TestCase;
import java.util.*;
import java.util.regex.*;


public class TranslatorTest extends TestCase {

	static Map __testdata;
	
	static {
		String resource_name = "kwartz/test-translator.yaml";
		try {
			__testdata = TestUtil.findAndLoadYamlTestData(resource_name, TranslatorTest.class, null);
		}
		catch (Exception ex) {
			ex.printStackTrace();
		}
	}
	
	
	static String __testname_pattern = null; // "converter_directive_foreach\\d";
	
	
	static String getval(Map map, String key, String lang) {
		Object val = map.get(key + "*");
		if (val != null) {
			return (String)((Map)val).get(lang);
		}
		else {
			return (String)map.get(key);
		}
	}
	
	
	Exception error(String message) {
		return new Exception("*** TranslatorTest: " + message);
	}
	
	public void _test() throws Exception {
		String caller_method = Util.callerMethodName(); 
		Matcher m = Util.matcher("^test_(\\w+)_([a-zA-Z0-9]+)$", caller_method);
		if (! m.find())
			throw error("invalid test name(='"+caller_method+"').");
		String name = m.group(1);
		String lang = m.group(2);
		if (__testname_pattern != null && !Pattern.matches(__testname_pattern, name))
			return;
		Map data = (Map)__testdata.get(name);
		if (data == null)
			throw error("name '"+name+"' is not found.");
		String input     =  getval(data, "input", lang);
		String expected  =  getval(data, "expected", lang);
		String exception =  getval(data, "exception", lang);
		String errormsg  =  getval(data, "errormsg", lang);
		Map properties   = (Map)data.get("properties");
		/// create translator
		Translator translator = null;
		if (Util.matches("jstl\\d*", lang)) {
			if (lang.equals("jstl10")) {
				if (properties == null)
					properties = new HashMap();
				properties.put("jstl", "1.0");
			}
			translator = new JstlTranslator(properties);
		}
		else if (lang.equals("velocity")) {
			translator = null; // new VelocityTranslator(properties);
		}
		else {
			throw error("invalid lang(='"+lang+"').");
		}
		/// translate input
		String result = null;
		String filename = "test-translator.plogic";
		boolean thrown = false;
		try {
			if (Util.matches("expr_.*", name) || Util.matches("literal_.*", name)) {
				UniversalExpressionParser parser = new UniversalExpressionParser();
				Ast.Expression expr = (Ast.Expression)parser.parse(input, filename);
				result = translator.translate(expr);
			}
			else if (Util.matches("stmt_.*", name)) {
				UniversalStatementParser parser = new UniversalStatementParser();
				List stmts = (List)parser.parse(input, filename);
				result = translator.translate(stmts);
			}
			else {
				assert false;
				throw error("invalid name(='"+name+"').");
			}
		}
		catch (Exception ex) {
			thrown = true;
			if (exception == null)
				throw ex;
			String errclass = ex.getClass().getName();
			String msg = exception+" expected but "+errclass+" thrown.";
			assertEquals(msg, exception, errclass); 
			assertEquals(errormsg, ex.toString());
		}
		if (exception == null) {
			assertEquals(expected, result);
		}
		else {
			if (!thrown) {
				fail("exception "+exception+" expected but not thrown.");
			}
		}

	}


	public void test_literal_var1_jstl() throws Exception { _test(); }
	public void test_literal_str1_jstl() throws Exception { _test(); }
	public void test_literal_int1_jstl() throws Exception { _test(); }
	public void test_literal_float1_jstl() throws Exception { _test(); }
	public void test_literal_true1_jstl() throws Exception { _test(); }
	public void test_literal_false1_jstl() throws Exception { _test(); }
	public void test_literal_null1_jstl() throws Exception { _test(); }
	
	public void test_expr_arith1_jstl() throws Exception { _test(); }
	public void test_expr_arith2_jstl() throws Exception { _test(); }
	public void test_expr_logical1_jstl() throws Exception { _test(); }
	public void test_expr_logical2_jstl() throws Exception { _test(); }
	public void test_expr_relational1_jstl() throws Exception { _test(); }
	public void test_expr_assignment1_jstl() throws Exception { _test(); }
	public void test_expr_method1_jstl() throws Exception { _test(); }
	public void test_expr_property1_jstl() throws Exception { _test(); }
	public void test_expr_property2_jstl() throws Exception { _test(); }
	public void test_expr_property3_jstl() throws Exception { _test(); }
	public void test_expr_index1_jstl() throws Exception { _test(); }
	public void test_expr_index2_jstl() throws Exception { _test(); }
	public void test_expr_index3_jstl() throws Exception { _test(); }
	public void test_expr_conditional1_jstl10() throws Exception { _test(); }
	public void test_expr_conditional1_jstl11() throws Exception { _test(); }
	
	public void test_stmt_print1_jstl10() throws Exception { _test(); }
	public void test_stmt_print1_jstl11() throws Exception { _test(); }
	public void test_stmt_print2_jstl10() throws Exception { _test(); }
	public void test_stmt_print2_jstl11() throws Exception { _test(); }
	public void test_stmt_print3_jstl10() throws Exception { _test(); }
	public void test_stmt_print3_jstl11() throws Exception { _test(); }
	public void test_stmt_print4_jstl10() throws Exception { _test(); }
	public void test_stmt_print4_jstl11() throws Exception { _test(); }
	public void test_stmt_print5_jstl10() throws Exception { _test(); }
	public void test_stmt_print5_jstl11() throws Exception { _test(); }
	public void test_stmt_expr1_jstl() throws Exception { _test(); }
	public void test_stmt_expr2_jstl() throws Exception { _test(); }
	public void test_stmt_expr3_jstl10() throws Exception { _test(); }
	public void test_stmt_expr3_jstl11() throws Exception { _test(); }
	public void test_stmt_if1_jstl() throws Exception { _test(); }
	public void test_stmt_elseif1_jstl() throws Exception { _test(); }
	public void test_stmt_else1_jstl() throws Exception { _test(); }
	public void test_stmt_else2_jstl() throws Exception { _test(); }
	public void test_stmt_foreach1_jstl() throws Exception { _test(); }
	public void test_stmt_foreach2_jstl() throws Exception { _test(); }
	public void test_stmt_while1_jstl() throws Exception { _test(); }
	public void test_stmt_break1_jstl() throws Exception { _test(); }
	public void test_stmt_continue1_jstl() throws Exception { _test(); }
	
}
