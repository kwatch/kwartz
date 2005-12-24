/**
 *  @(#) HashKeysFunction.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.function;
import java.util.Map;
import java.util.ArrayList;

public class HashKeysFunction extends HashFunction {
    protected Object perform(Map hash) {
        return new ArrayList(hash.keySet());
    }
}
