/*
 * $Rev$
 * $Release$
 * $Copyright$
 */
package kwartz;

import java.util.*;
import java.io.*;


public class TestUtil {

	
	/**
	 * load testdata in YAML format.
	 * 
	 * ex.
	 * <pre>
	 *  String resource = "kwartz/testdata.yaml";
	 *  try {
	 *     String filename = Util.findResource(resource, StatementParserTest.class);
	 *     if (filename == null)
	 *        throw new Exception(resource + ": not found.");
	 *     List maplist = Util.oadYamlTestData(filename);
	 *     Map testdata = Util.convertMaplistToMaptable(maplist, "name");
	 *  } catch (Exception ex) {
	 *     ex.printStackTrace();
	 *  }
	 * </pre>
	 */
	public static List loadYamlTestData(String filename, String lang) throws IOException, kwalify.SyntaxException, Exception {
		String str = Util.readFile(filename);
		str = Util.untabify(str);
		kwalify.YamlParser yamlparser = new kwalify.YamlParser(str);
		List list = (List)yamlparser.parse();
		for (Iterator it = list.iterator(); it.hasNext(); ) {
			Map data = (Map)it.next();
			String name = (String)data.get("name");
			if (name == null)
				throw new Exception("*** name not found. ("+filename+")");
			if (lang != null) {
				List keys = null;
				for (Iterator it2 = data.keySet().iterator(); it2.hasNext(); ) {
					String key = (String)it2.next();
					if (key.charAt(key.length()-1) == '*') {
						if (keys == null)
							keys = new ArrayList();
						keys.add(key);
					}
				}
				if (keys != null) {
					for (Iterator it3 = keys.iterator(); it3.hasNext(); ) {
						String key = (String)it3.next();
						Map m = (Map)data.remove(key);
						key = key.substring(0, key.length()-1); // 'key*' => 'key'
						data.put(key, m.get("java"));
					}
				}
			}
		}
		return list;
	}

	public static List loadYamlTestData(String filename) throws IOException, kwalify.SyntaxException, Exception {
		return loadYamlTestData(filename, "java");
	}


	

	/**
	 * find and load YAML testdata, and convert maplist into maptable.
	 */
	public static Map findAndLoadYamlTestData(String resource_name, Class klass, String lang) throws Exception {
		String filename = Util.findResource(resource_name, klass);
		if (filename == null)
			throw new java.io.FileNotFoundException(resource_name + ": not found.");
		List maplist = TestUtil.loadYamlTestData(filename, lang);
		Map maptable = Util.convertMaplistToMaptable(maplist, "name");
		return maptable;
	}
	
	public static Map findAndLoadYamlTestData(String resource_name, Class klass) throws Exception {
		return findAndLoadYamlTestData(resource_name, klass, "java");
	}


}
