/**
 *  @(#) StringToUpperFunction.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.function;

public class StringToUpperFunction extends StringFunction {
    protected Object perform(String str) {
        return str.toUpperCase();
    }
}
