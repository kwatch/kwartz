/**
 *  @(#) StringLengthFunction.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

public class StringLengthFunction extends StringFunction {
    protected Object perform(String str) {
        return new Integer(str.length());
    }
}
