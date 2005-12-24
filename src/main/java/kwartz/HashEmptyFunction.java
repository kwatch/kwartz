/**
 *  @(#) HashEmptyFunction.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
import java.util.Map;

public class HashEmptyFunction extends HashFunction {
    protected Object perform(Map hash) {
        return hash.size() == 0 ? Boolean.TRUE : Boolean.FALSE;
    }
}
