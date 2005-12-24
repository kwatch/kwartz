/**
 *  @(#) StringTrimFunction.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.function;

public class StringTrimFunction extends StringFunction {
    protected Object perform(String str) {
        return str.trim();
    }
}
