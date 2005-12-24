/**
 *  @(#) StringIndexFunction.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

public class StringIndexFunction extends StringFunction2 {
    public Object perform(String str1, String str2) {
        int index = str1.indexOf(str2);
        return new Integer(index);
    }
}
