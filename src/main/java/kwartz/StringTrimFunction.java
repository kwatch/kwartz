/**
 *  @(#) StringTrimFunction.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

public class StringTrimFunction extends StringFunction {
    protected Object perform(String str) {
        return str.trim();
    }
}
