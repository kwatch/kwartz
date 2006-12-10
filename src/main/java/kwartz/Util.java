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
import java.util.Map.Entry;
import java.util.regex.Matcher;
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
		else if (obj.getClass().isArray())
			inspect((Object[])obj, sb);
		else
			sb.append('<').append(obj.getClass().getName()).append('>');
	}
	
	
	/**
	 * 
	 */
	public static void inspect(Object[] arr, StringBuffer sb) {
		String signature = arr.getClass().getName();
		String classname = signature.substring(2, signature.length()-1);
		if (classname.startsWith("java.lang.")) {
			classname = classname.substring("java.lang.".length());
		}
		sb.append("(").append(classname).append("[])[");
		for (int i = 0, n = arr.length; i < n; i++) {
			if (i > 0)
				sb.append(", ");
			inspect(arr[i], sb);
		}
		sb.append("]");
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
	 * quote string by single quotation
	 */
	public static String quote(String str) {
		StringBuffer sb = new StringBuffer();
		sb.append('\'');
		for (int i = 0, n = str.length(); i < n; i++) {
			char ch = str.charAt(i);
			if (ch == '\'' || ch == '\\')
				sb.append(ch);
			sb.append(ch);
		}
		sb.append('\'');
		return sb.toString();
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
	 * string to Integer, Boolean, etc
	 */
	public static Object stringToValue(String str) {
		if (str == null)
			return null;
		if (Util.matches("^\\d+$", str))
			return new Integer(Integer.parseInt(str));
		if (Util.matches("^\\d+\\.\\d+$", str))
			return new Double(Double.parseDouble(str));
		if (str.equals("true") || str.equals("yes"))
			return Boolean.TRUE;
		if (str.equals("false") || str.equals("no"))
			return Boolean.FALSE;
		if (str.equals("null"))
			return null;
		return null;
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
	 * create map from list
	 */
	public static Map convertListToMap(List list) {
		HashMap map = new HashMap();
		for (Iterator it = list.iterator(); it.hasNext();) {
			Object key = it.next();
			map.put(key, Boolean.TRUE);
		}
		return map;
	}

	
	/**
	 * create map from array
	 */
	public static Map convertArrayToMap(String[] arr) {
		HashMap map = new HashMap();
		for (int i = 0, n = arr.length; i < n; i++) {
			String key = arr[i];
			map.put(key, Boolean.TRUE);
		}
		return map;
	}
	
	
	/**
	 * copy map
	 */
	public static Map copy(Map map) {
		Map map2 = new HashMap();
		for (Iterator it = map.entrySet().iterator(); it.hasNext();) {
			Entry entry = (Entry)it.next();
			map2.put(entry.getKey(), entry.getValue());
		}
		return map2;
	}
	
	
	/**
	 * return default value if key is not found
	 */
	public static Object fetch(Map map, Object key, Object defaultval) {
		return map.containsKey(key) ? map.get(key) : defaultval;
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
	
	
	/**
	 * compile string into regex pattern with caching
	 */
	public static Pattern pattern(String pattern_str) {
		Pattern pat = (Pattern)__pattern_cache.get(pattern_str);
		if (pat == null) {
			pat = Pattern.compile(pattern_str);
			__pattern_cache.put(pattern_str, pat);
		}
		return pat;
	}
	private static HashMap __pattern_cache = new HashMap();


	/**
	 * get matcher object
	 */
	public static Matcher matcher(String pattern_str, String target) {
		Pattern pat = Util.pattern(pattern_str);
		return pat.matcher(target);
	}
	
	
	/**
	 * matching regex pattern with string 
	 */
	public static boolean matches(String pattern_str, String target) {
		Matcher m = Util.matcher(pattern_str, target);
		return m.find();
	}

	
	
	/**
	 * caller information.
	 */
	public static StackTraceElement caller(int i) {
		StackTraceElement info = null;
		try {
			throw new Exception();
		}
		catch (Exception ex) {
			info = ex.getStackTrace()[i+1];
		}
		return info;
	}
	
	
	/**
	 * caller information. equals to Util.caller(1)
	 */
	public static StackTraceElement caller() {
		return Util.caller(1+1);
	}
	
	
	/**
	 * current method name
	 */
	public static String currentMethodName() {
		return Util.caller(0+1).getMethodName();
	}
	
	
	/**
	 * method name of caller
	 */
	public static String callerMethodName() {
		return Util.caller(1+1).getMethodName();
	}
	
	

	/**
	 * array slice
	 */
	public static String[] slice(String[] array, int start, int end) {
		if (end < 0) {
			end = array.length + end;
		}
		int len = end - start;
		String[] newarray = new String[len];
		for (int i = 0, j = start; i < len; i++, j++) {
			assert j < end;
			newarray[i] = array[j];
		}
		return newarray;
	}
	
	
	/**
	 * array slice
	 */
	public static String[] slice(String[] array, int start) {
		return slice(array, start, array.length);
	}
	
	
	/**
	 * list slice
	 */
	public static List slice(List list, int start, int end) {
		if (end < 0) {
			end = list.size() + end;
		}
		int len = end - start;
		List newlist = new ArrayList(len);
		for (int i = start; i < end; i++) {
			newlist.add(list.get(i));
		}
		return newlist;
	}
	
	
	/**
	 * list slice
	 */
	public static List slice(List list, int start) {
		return slice(list, start, list.size());
	}
	
	
	
}
