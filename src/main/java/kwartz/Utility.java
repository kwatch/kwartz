/**
 *  @(#) Utility.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

import java.io.InputStream;
import java.io.FileInputStream;
import java.io.Reader;
import java.io.InputStreamReader;
import java.io.IOException;

public class Utility {
    public static String capitalize(String str) {
        return Character.toUpperCase(str.charAt(0)) + str.substring(1);
    }

    public static String inspectString(String s) {
        return inspectString(s, false);
    }

    public static String inspectString(String s, boolean flag_escape_only) {
        if (s == null) return null;
        StringBuffer sb = new StringBuffer();
        if (! flag_escape_only) sb.append('"');
        for (int i = 0; i < s.length(); i++) {
            char ch = s.charAt(i);
            switch (ch) {
              case '\n':  sb.append("\\n");   break;
              case '\r':  sb.append("\\r");   break;
              case '\t':  sb.append("\\t");   break;
              case '\\':  sb.append("\\\\");  break;
              case '"':   sb.append("\\\"");  break;
              default:
                sb.append(ch);
            }
        }
        if (! flag_escape_only) sb.append('"');
        return sb.toString();
    }

    public String escapeHtml(String str) {
        if (str == null) return null;
        StringBuffer sb = new StringBuffer();
        char[] chars = str.toCharArray();
        for (int i = 0; i < chars.length; i++) {
            switch (chars[i]) {
              case '&':
                sb.append("&amp;");  break;
              case '<':
                sb.append("&lt;");   break;
              case '>':
                sb.append("&gt;");   break;
              case '"':
                sb.append("&quot;"); break;
              default:
                sb.append(chars[i]);
            }
        }
        return sb.toString();
    }


    public static String readFile(String filename) throws IOException {
        String charset = System.getProperty("file.encoding");
        return Utility.readFile(filename, charset);
    }

    public static String readFile(String filename, String charset) throws IOException {
        if (filename == null)
            return null;
        if (charset == null) {
            charset = System.getProperty("file.encoding");
        }
        InputStream stream = null;
        Reader reader = null;
        try {
            stream = new FileInputStream(filename);
            reader = new InputStreamReader(stream, charset);
            char[] cbuf = new char[512];
            StringBuffer sb = new StringBuffer();
            int len;
            while ((len = reader.read(cbuf, 0, cbuf.length)) >= 0) {
                sb.append(cbuf, 0, len);
            }
            return sb.toString();
        } finally {
            if (reader != null) reader.close();
            if (stream != null) stream.close();
        }
    }

}
