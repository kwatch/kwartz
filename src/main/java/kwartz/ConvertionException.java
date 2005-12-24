/**
 *  @(#) ConvertionException.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

import java.util.Properties;

public class ConvertionException extends BaseException {
    private String _filename;
    private int _linenum;

    public ConvertionException(String message, String filename, int linenum) {
        super(message);
        _filename = filename;
        _linenum  = linenum;
    }

    public String toString() {
        return super.toString() + "(filename " + _filename + ", line " + _linenum + ")";
    }

}
