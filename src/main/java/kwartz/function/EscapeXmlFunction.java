/**
 *  @(#) EscapeXmlFunction.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.function;

public class EscapeXmlFunction extends EscapeFunction {
    protected Object perform(Object arg) {
        //if (arg == null) return null;   // or return "";
        //String s = arg.toString();
        //s = s.replaceAll("&",  "&amp;");
        //s = s.replaceAll("<",  "&lt;");
        //s = s.replaceAll(">",  "&gt;");
        //s = s.replaceAll("\"", "&quot;");
        //return s;
        // ----------
        if (arg == null) return null;   // or return "";
        String s = arg.toString();
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < s.length(); i++) {
            char ch = s.charAt(i);
            switch (ch) {
              case '<':   sb.append("&lt;");    break;
              case '>':   sb.append("&gt;");    break;
              case '&':   sb.append("&amp;");   break;
              case '"':   sb.append("&quot;");  break;
              default:    sb.append(ch);
            }
        }
        return sb.toString();
        // ----------
        //if (arg == null) return null;  // or return "";
        //String s = arg.toString();
        //StringBuffer sb = null;
        //for (int i = 0; i < s.length(); i++) {
        //    char ch = s.charAt(i);
        //    String escaped;
        //    switch (ch) {
        //      case '<':   escaped = "&lt;";   break;
        //      case '>':   escaped = "&gt;";   break;
        //      case '&':   escaped = "&amp";   break;
        //      case '"':   escaped = "&quot";  break;
        //      default:    escaped = null;
        //    }
        //    if (escaped == null) {
        //        if (sb != null) sb.append(ch);
        //    } else {
        //        if (sb == null) {
        //            sb = new StringBuffer();
        //            sb.append(s.substring(0, i));
        //        }
        //        sb.append(escaped);
        //    }
        //}
        //return sb == null ? s : sb.toString();
    }
}
