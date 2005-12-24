/**
 *  @(#) Tag.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
import java.util.List;

public class Tag {
    public String tag_str;
    public String before_text;
    public String before_space;
    public String tagname;
    public String attr_str;
    public String extra_space;
    public String after_space;
    public boolean is_etag;
    public boolean is_empty;
    public boolean is_begline;
    public boolean is_endline;
    public int start_pos;
    public int end_pos;
    public int linenum;

    //
    public String directive_name;
    public String directive_arg;
    public List attrs;              // list of Attr
    public List append_exprs;

    public String _inspect() {
        StringBuffer sb = new StringBuffer();
        if (tag_str != null) {
            sb.append("tag_str      = " + Utility.inspectString(tag_str)       + "\n");
            sb.append("before_text  = " + Utility.inspectString(before_text)   + "\n");
            sb.append("before_space = " + Utility.inspectString(before_space)  + "\n");
            sb.append("tagname      = " + Utility.inspectString(tagname)       + "\n");
            sb.append("attr_str     = " + Utility.inspectString(attr_str)      + "\n");
            sb.append("extra_space  = " + Utility.inspectString(extra_space)   + "\n");
            sb.append("after_space  = " + Utility.inspectString(after_space)   + "\n");
            sb.append("is_etag      = " + is_etag       + "\n");
            sb.append("is_empty     = " + is_empty      + "\n");
            sb.append("is_begline   = " + is_begline    + "\n");
            sb.append("is_endline   = " + is_endline    + "\n");
            sb.append("start_pos    = " + start_pos     + "\n");
            sb.append("end_pos      = " + end_pos       + "\n");
            sb.append("linenum      = " + linenum       + "\n");
        } else {
            sb.append("before_text  = " + Utility.inspectString(before_text)   + "\n");
            sb.append("linenum      = " + linenum       + "\n");
        }
        return sb.toString();
    }
}
