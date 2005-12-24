/**
 *  @(#) StringLinebreakFunction.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.function;

public class StringLinebreakFunction extends StringFunction {
    protected Object perform(String str) {
        return str.replaceAll("\\r?\\n", "<br />\\0");
    }
}
