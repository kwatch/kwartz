/**
 *  @(#) StringToUpperFunction.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

public class StringToUpperFunction extends StringFunction {
    protected Object perform(String str) {
        return str.toUpperCase();
    }
}
