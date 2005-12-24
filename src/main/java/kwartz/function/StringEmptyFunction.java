/**
 *  @(#) StringEmptyFunction.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.function;
import java.util.Map;

public class StringEmptyFunction extends StringFunction {
    protected Object perform(String str) {
        return str.length() == 0 ? Boolean.TRUE : Boolean.FALSE;
    }
}
