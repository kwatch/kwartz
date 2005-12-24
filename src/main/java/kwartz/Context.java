/**
 *  @(#) Context.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

import java.util.HashMap;

public class Context extends HashMap {
    public void putAll(Object[][] tuples) {
        for (int i = 0; i < tuples.length; i++) {
            Object[] tuple = tuples[i];
            Object key   = tuple[0];
            Object value = tuple[1];
            this.put(key, value);
        }
    }
}
