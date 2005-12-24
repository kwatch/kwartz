/**
 *  @(#) DisabledMacro.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

public class DisabledMacro extends FormMacro {
    protected String getValue() { return " disabled=\"disabled\""; }
}
