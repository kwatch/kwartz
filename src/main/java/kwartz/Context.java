/**
 *  @(#) Context.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

import java.util.HashMap;

public class Context extends HashMap {
    private static final long serialVersionUID = 2886240200539383385L;

    public void putAll(Object[][] tuples) {
        for (int i = 0; i < tuples.length; i++) {
            Object[] tuple = tuples[i];
            Object key   = tuple[0];
            Object value = tuple[1];
            this.put(key, value);
        }
    }
}
