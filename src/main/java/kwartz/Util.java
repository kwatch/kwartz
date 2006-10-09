/**
 * $Rev$
 * $Release$
 * $Copyright$
 */
package kwartz;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.io.File;
import java.util.regex.Pattern;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Collection;



/**
 * utilities.
 */
public class Util {
	


	/**
	 * convert object to string with proper format
	 */
	public static String inspect(Object obj) {
		StringBuffer sb = new StringBuffer();
		inspect(obj, sb);
		return sb.toString();
	}

	
	/**
	 * convert object to string with proper format.
	 */
	public static void inspect(Object obj, StringBuffer sb) {
		if (obj == null)
			sb.append("null");
		else if (obj instanceof String)
			inspect((String)obj, sb);
		else if (obj instanceof Map)
			inspect((Map)obj, sb);
		else if (obj instanceof Collection)
			inspect((Collection)obj, sb);
		else if (obj instanceof Number)
			sb.append(obj.toString());
		else if (obj instanceof Boolean)
			sb.append(obj.toString());
		else if (obj instanceof Character)
			sb.append('\'').append(((Character)obj).charValue()).append('\'');
		else
			sb.append('<').append(obj.getClass().getName()).append('>');
	}
	
	
	/**
	 * inspect string
	 */
	public static void inspect(String str, StringBuffer sb) {
		sb.append('"');
		for (int i = 0, n = str.length(); i < n; i++) {
			char ch = str.charAt(i);
			switch (ch) {
			case '"':   sb.append("\\\"");  break;
			case '\\':  sb.append("\\\\");  break;
			case '\n':  sb.append("\\n");   break;
			case '\t':  sb.append("\\t");   break;
			case '\b':  sb.append("\\b");   break;
			case '\r':  sb.append("\\r");   break;
			default:    sb.append(ch);
			}
		}
		sb.append('"');
	}
	
	
	/**
	 * inspect Collection
	 */
	public static void inspect(Collection list, StringBuffer sb) {
		if (list == null) {
			sb.append("null");
			return;
		}
		sb.append('[');
		String sep = "";
		for (Iterator it = list.iterator(); it.hasNext(); ) {
			Object obj = it.next();
			sb.append(sep);
			inspect(obj, sb);
			sep = ", ";
		}
		sb.append(']');
	}
	
	
	/**
	 * inspect Map
	 */
	public static void inspect(Map map, StringBuffer sb) {
		if (map == null) {
			sb.append("null");
			return;
		}
		sb.append('{');
		String sep =  "";
		for (Iterator it = map.keySet().iterator(); it.hasNext(); ) {
			Object key = it.next();
			Object val = map.get(key);
			sb.append(sep);
			inspect(key, sb);
			sb.append(": ");
			inspect(val, sb);
			sep = ", ";
		}
		sb.append('}');
	}
	
	
	/**
	 * expand tab characters in string.
	 */
	public static String untabify(String str, int width) {
		String[] list = str.split("\t");
		if (list.length == 1) {
			return str;
		}
		StringBuffer sb = new StringBuffer();
		int n = list.length - 1;
		for (int i = 0; i < n; i++) {
			String s = list[i];
			sb.append(s);
			int pos = s.lastIndexOf('\n');
			int column = pos < 0 ? s.length() : s.length() - pos - 1;
			for (int j = width - (column % width); j > 0; j--) {
				sb.append(' ');
			}
		}
		sb.append(list[n]);
		return sb.toString();
	}

	/**
	 * expand tab characters to 8 width spaces.
	 */
	public static String untabify(String str) {
		return untabify(str, 8);
	}

	
	/**
	 * count characters in string 
	 */
	public static int count(String str, char ch) {
		if (str == null)
			return 0;
		int ctr = 0;
		for (int i = 0, n = str.length(); i < n; i++) {
			if (str.charAt(i) == ch)
				ctr++;
		}
		return ctr;
	}
	
	
	/**
	 * 
	 */
	public static Object or(Object obj1, Object obj2) {
		return obj1 != null ? obj1 : obj2;
	}
	

	/**
	 * read file content
	 */
	public static String readFile(String filename, String encoding) throws IOException {
		InputStream stream = null;
		try {
			stream = new FileInputStream(filename);
			String s = readInputStream(stream, encoding);
			return s;
		}
		finally {
			if (stream != null) {
				stream.close();
			}
		}
	}


	/**
	 * read file content with default encoding
	 */
	public static String readFile(String filename) throws IOException {
		return readFile(filename, null);
	}


	/**
	 * read standard input
	 */
	public static String readStdin(String encoding) throws IOException {
		String s = readInputStream(System.in, encoding);
		return s;
	}


	/**
	 * read input stream
	 */
	public static String readInputStream(InputStream stream, String encoding) throws IOException {
		Reader reader = null;
		try {
			if (encoding == null) {
				reader = new InputStreamReader(stream);
			}
			else {
				reader = new InputStreamReader(stream, encoding);
			}
			StringBuffer sb = new StringBuffer();
			int ch;
			while ((ch = reader.read()) >= 0) {
				sb.append((char)ch);
			}
			return sb.toString();
		}
		finally {
			if (reader != null) {
				reader.close();
			}
		}
	}


	/**
	 * write file
	 */
	public static void writeFile(String filename, String str, String encoding) throws IOException {
		OutputStream stream = null;
		try {
			stream = new FileOutputStream(filename);
			writeOutputStream(stream, str, encoding);
		}
		finally {
			if (stream != null) {
				stream.close();
			}
		}
	}


	/**
	 * write file with default encoding
	 */
	public static void writeFile(String filename, String str) throws IOException {
		writeFile(filename, str, null);
	}


	/**
	 * write to standard output
	 */
	public static void writeStdout(String str, String encoding) throws IOException {
		writeOutputStream(System.out, str, encoding);
	}


	/**
	 * write to standard error
	 */
	public static void writeStderr(String str, String encoding) throws IOException {
		writeOutputStream(System.err, str, encoding);
	}


	/**
	 * write output stream
	 */
	public static void writeOutputStream(OutputStream stream, String str, String encoding) throws IOException {
		Writer writer = null;
		try {
			if (encoding != null) {
				writer = new OutputStreamWriter(stream, encoding);
			}
			else {
				writer = new OutputStreamWriter(stream);
			}
			writer.write(str);
			writer.flush();
		}
		finally {
			if (writer != null) {
				writer.close();
			}
		}
	}


	/**
	 * check whether file exists or no
	 */
	public static boolean fileExists(String filename) {
		File file = new File(filename);
		return file.exists();
	}


	/**
	 * remove file
	 */
	public static void deleteFile(String filename) {
		File file = new File(filename);
		if (file.exists()) {
			file.delete();
		}
	}


	/**
	 * return suffix of filename
	 */
	public static String suffix(String filename) {
		assert filename != null;
		int pos = filename.lastIndexOf('.');
		if (pos < 0) {
			return null;
		}
		return filename.substring(pos);
	}


	/**
	 * escape regex meta characters 
	 */
	public static String escapeRegexMetaCharacter(String str) {
		StringBuffer sb = new StringBuffer();
		for (int i = 0, len = str.length(); i < len; i++) {
			char ch = str.charAt(i);
			switch (ch) {
			case '.':  case '\\':
			case '*':  case '+':  case '?':
			case '^':  case '$':
			case '[':  case ']':
			case '(':  case ')':
			case '{':  case '}':
				sb.append('\\');
			}
			sb.append(ch);
		}
		return sb.toString();
	}


	/**
	 * repeat string N times and append it to string buffer
	 */
	public static void repeatString(String s, int n, StringBuffer sb) {
		while (--n >= 0) {
			sb.append(s);
		}
	}

	
	/**
	 * repeat string N times and return it
	 */
	public static String repeatString(String s, int n) {
		StringBuffer sb = new StringBuffer();
		repeatString(s, n, sb);
		return sb.toString();
	}


	/**
	 * parse string and convert into proper object
	 */
	public static Object convertStringToValue(String s) {
		if (s == null) {
			return null;
		}
		else if (s.equals("true") || s.equals("yes")) {
			return Boolean.TRUE;
		}
		else if (s.equals("false") || s.equals("no")) {
			return Boolean.FALSE;
		}
		else if (s.equals("null") || s.equals("nil")) {
			return null;
		}
		else if (Pattern.matches("^\\d+$", s)) {
			return new Integer(Integer.parseInt(s));
		}
		else if (Pattern.matches("^\\d+\\.\\d+", s)) {
			return new Float(Float.parseFloat(s));
		}
		return s;
	}


	/**
	 * convert "ture" and "yes" into true, and "false" and "no" into false.
	 * 
	 * @throws IllegalArgumentException str is not "true", "yes", "false", nor "no".
	 */
	public static boolean stringToBoolean(String str, boolean nullval) throws IllegalArgumentException {
		if (str == null) {
			return nullval;
		}
		if (str.equals("true") || str.equals("yes")) {
			return true;
		}
		if (str.equals("false") || str.equals("no")) {
			return false;
		}
		throw new IllegalArgumentException();
	}


	/**
	 * split string into lines with keeping '\n' character.
	 */
	public static List stringToLinesList(String str) {
		List lines = new ArrayList();
		String line;
		int i, pos, len;
		for (i = 0, pos = 0, len = str.length(); i < len; i++) {
			char ch = str.charAt(i);
			if (ch == '\n') {
				line = str.substring(pos, i+1);
				lines.add(line);
				pos = i + 1;
			}
		}
		if (pos < i) {
			line = str.substring(pos, i);
			lines.add(line);
		}
		return lines; 
	}


	/**
	 * split string into lines with keeping '\n' character.
	 */
	public static String[] stringToLinesArray(String str) {
		List list = stringToLinesList(str);
		String[] lines = new String[list.size()];
		list.toArray(lines);
		return lines;
	}


	/**
	 *  find resource name
	 *
	 *  ex.
	 *  <pre>
	 *  String res_name = "erubis/MainTest.yaml";
	 *  String filepath = Util.findResource(res_name, MainTest.class);
	 *  </pre>
	 */
	public static String findResource(String res_name, Class klass) {
		ClassLoader loader = klass.getClassLoader();
		java.net.URL url = loader.getResource(res_name);
		if (url == null)
			return null;
		String filepath= url.getPath();
		return filepath;
	}


	/**
	 *  load yaml file
	 */
	static Object loadYamlFile(String filename, boolean untabify) throws kwalify.SyntaxException, IOException {
		String yaml_str = Util.readFile(filename);
		yaml_str = Util.untabify(yaml_str);
		Util.writeFile("/tmp/hoge.out", yaml_str);
		kwalify.YamlParser parser = new kwalify.YamlParser(yaml_str);
		Object ydoc = parser.parse();
		return ydoc;
	}
	
	
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
	public static List loadYamlTestData(String filename) throws IOException, kwalify.SyntaxException, Exception {
		String str = Util.readFile(filename);
		str = Util.untabify(str);
		kwalify.YamlParser yamlparser = new kwalify.YamlParser(str);
		List list = (List)yamlparser.parse();
		for (Iterator it = list.iterator(); it.hasNext(); ) {
			Map data = (Map)it.next();
			String name = (String)data.get("name");
			if (name == null)
				throw new Exception("*** name not found. ("+filename+")");
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
		return list;
	}
	

	/**
	 * create map of map from list of map unsing key.
	 */
	public static Map convertMaplistToMaptable(List maplist, String key) throws Exception {
		Map maptable = new HashMap();
		for (Iterator it = maplist.iterator(); it.hasNext(); ) {
			Map map = (Map)it.next();
			Object keyobj = map.get(key);
			if (maptable.containsKey(keyobj)) {
				throw new Exception("*** "+key+"+'"+keyobj+"' is duplicated.");
			}
			maptable.put(map.get(key), map);
		}
		return maptable;
	}


	/**
	 * quote single-quotation and backslash
	 */
	public static String squote(String str) {
		return str.replaceAll("(['\\\\])", "\\\\$1");  // Java1.4
	}
	
	
	/**
	 * quote double-quotation and backslash
	 */
	public static String dquote(String str) {
		return str.replaceAll("([\"\\\\])", "\\\\$1");  // Java1.4
	}
	
	
	/**
	 * capitalize word (upcase the first character)
	 */
	public static String capitalize(String str) {
		return Character.toString(str.charAt(0)).toUpperCase() + str.substring(1);
	}


}
