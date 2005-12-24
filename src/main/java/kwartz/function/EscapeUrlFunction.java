/**
 *  @(#) EscapeUrlFunction.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.function;
import java.net.URLEncoder;

public class EscapeUrlFunction extends EscapeFunction {
    protected Object perform(Object arg) {
        if (arg == null) return null;
        String s = arg.toString();
        return URLEncoder.encode(s);
    }
}
