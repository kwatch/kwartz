/**
 *  @(#) StringReplaceFunction.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

public class StringReplaceFunction extends StringFunctionN {
    public int arity() { return 3; }

    protected Object perform(String[] args) {
        assert args.length == arity();
        return args[0].replaceAll(args[1], args[2]);
        //return args[0].replaceFirst(args[1], args[2]);
    }
}
