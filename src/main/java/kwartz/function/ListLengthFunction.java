/**
 *  @(#) ListLengthFunction.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.function;
import java.util.List;

public class ListLengthFunction extends ListFunction {
    protected Object perform(List list) {
        return new Integer(list.size());
    }
    protected Object perform(Object[] list) {
        return new Integer(list.length);
    }
}
