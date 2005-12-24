/**
 *  @(#) EscapeSqlFunction.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

public class EscapeSqlFunction extends EscapeFunction {
    protected Object perform(Object arg) {
        if (arg == null) return null;
        String s = arg.toString();
        s = s.replaceAll("\\\\", "\\\\\\\\");
        s = s.replaceAll("'", "\\\\'");
        s = s.replaceAll("\"", "\\\\\"");
        return s;
    }
}
