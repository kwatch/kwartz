/**
 *  @(#) StringToLowerFunction.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.function;

public class StringToLowerFunction extends StringFunction {
    protected Object perform(String str) {
        return str.toLowerCase();
    }
}
