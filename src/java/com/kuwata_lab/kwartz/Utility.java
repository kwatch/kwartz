/**
 *  @(#) Utility.java
 *  @Id  $Id$
 *  @copyright (C)2005 kuwata-lab.com all rights reserverd
 */
package com.kuwata_lab.kwartz;

public class Utility {
    public static String capitalize(String str) {
        return Character.toUpperCase(str.charAt(0)) + str.substring(1);
    }

    //public String capitalize(String str) {
    //    return Character.toUpperCase(str.charAt(0)) + str.substring(1);
    //}

    public String escapeString(String str) {
        if (str == null) return null;
        StringBuffer sb = new StringBuffer();
        char[] chars = str.toCharArray();
        for (int i = 0; i < chars.length ; i++) {
            switch (chars[i]) {
              case '"':
                sb.append("\\\"");   break;
              case '\\':
                sb.append("\\\\");   break;
              case '\n':
                sb.append("\\n");    break;
              case '\r':
                sb.append("\\r");    break;
              default:
                sb.append(chars[i]);
            }
        }
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
}
