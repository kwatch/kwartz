/**
 *  @(#) Statement.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.node;
import java.util.Map;
import java.io.Writer;
import java.io.StringWriter;
import java.io.IOException;

import kwartz.Element;
import kwartz.Expander;

abstract public class Statement extends Node {
    public Statement(int token) {
        super(token);
    }

    public Object evaluate(Map context) {
        StringWriter writer = new StringWriter();
        try {
            execute(context, writer);
        } catch (IOException ex) {
            //throw new MiscException(ex);
            ex.printStackTrace();
        }
        return writer.toString();
    }

    abstract public Object execute(Map context, Writer writer) throws IOException;

    public Object accept(NodeVisitor visitor) {
        return accept((StatementVisitor)visitor);
    }

    abstract public Object accept(StatementVisitor visitor);

    abstract public Statement accept(Expander expander, Element elem);
}
