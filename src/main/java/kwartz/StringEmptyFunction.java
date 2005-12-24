/**
 *  @(#) StringEmptyFunction.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
import java.util.Map;

public class StringEmptyFunction extends StringFunction {
    protected Object perform(String str) {
        return str.length() == 0 ? Boolean.TRUE : Boolean.FALSE;
    }
}
