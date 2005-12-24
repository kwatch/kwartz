/**
 *  @(#) ListAddFunction.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
import java.util.List;

public class ListAddFunction extends ListFunction2 {
    protected Object perform(List list, Object val) {
        list.add(val);
        return list;
    }
    protected Object perform(Object[] list, Object val) {
        throw new EvaluationException(getName() + "(): cannot add value to an array.");
    }
}
