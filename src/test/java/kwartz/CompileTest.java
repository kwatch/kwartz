/*
 * $Rev$
 * $Release$
 * $Copyright$
 */
package kwartz;

import junit.framework.TestCase;
import java.util.*;
import java.util.regex.*;


public class CompileTest extends TestCase {

	static Map __testdata;
	
	static {
		String resource_name = "kwartz/test-compile.yaml";
		try {
			__testdata = TestUtil.findAndLoadYamlTestData(resource_name, CompileTest.class, null);
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
		return new Exception("*** CompileTest: " + message);
	}
	
	String normalize(String str) {
		Matcher m = Util.matcher("\\{\\{\\*(.*?)\\*\\}\\}", str);
		return m.replaceAll("$1");
		//StringBuffer sb = new StringBuffer();
		//while (m.find()) {
		//	m.appendReplacement(sb, "$1");
		//}
		//m.appendTail(sb);
		//return sb.toString();
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
		//String input     =  getval(data, "input", lang);
		String pdata     =  getval(data, "pdata", "java");
		String plogic    =  getval(data, "plogic", "java");
		String expected  =  getval(data, "expected", lang);
		String exception =  getval(data, "exception", lang);
		String errormsg  =  getval(data, "errormsg", lang);
		Map properties   = (Map)data.get("properties");
		///
		pdata = normalize(pdata);
		plogic = normalize(plogic);
		expected = normalize(expected);
		///
		boolean thrown = false;
		try {
			/// parse plogic
			Parser parser = new PresentationLogicParser();
			List rulesets = (List)parser.parse(plogic, "test-compile.html");
			/// convert pdata
			Handler handler = new BaseHandler(rulesets, properties);
			Converter converter = new TextConverter(handler, properties);
			List stmt_list = converter.convert(pdata, "test-compile.plogic");
			/// create translator
			Translator translator = null;
			if (Util.matches("jstl\\d*", lang)) {
				//System.err.println("*** debug: lang="+Util.inspect(lang)+", properties=" + Util.inspect(properties));
				if (lang.equals("jstl10")) {
					properties = properties == null ? new HashMap() : Util.copy(properties);
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
			/// translate statements
			String actual = translator.translate(stmt_list);
			assertEquals(expected, actual);
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
		if (exception != null && !thrown) {
			fail("exception "+exception+" expected but not thrown.");
		}

	}


	public void test_bordered_table1_jstl10() throws Exception { _test(); }
	public void test_bordered_table1_jstl11() throws Exception { _test(); }
	public void test_embedded_expr1_jstl10() throws Exception { _test(); }
	public void test_embedded_expr1_jstl11() throws Exception { _test(); }

}
