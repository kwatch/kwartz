/**
 *  @(#) HashLengthFunction.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.function;
import java.util.Map;

public class HashLengthFunction extends HashFunction {
    protected Object perform(Map hash) {
        return new Integer(hash.size());
    }
}
