/**
 *  @(#) ListEmptyFunction.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.function;
import java.util.List;

public class ListEmptyFunction extends ListFunction {
    protected Object perform(List list) {
        return list.size() == 0 ? Boolean.TRUE : Boolean.FALSE;
    }
    protected Object perform(Object[] list) {
        return list.length == 0 ? Boolean.TRUE : Boolean.FALSE;
    }
}
