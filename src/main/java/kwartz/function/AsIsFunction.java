/**
 *  @(#) AsIsFunction.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.function;

public class AsIsFunction extends EscapeFunction {
    protected Object perform(Object arg) {
        return arg;
    }
}
