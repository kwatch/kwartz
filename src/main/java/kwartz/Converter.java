/**
 *  @(#) Converter.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

import java.util.List;

import kwartz.node.Expression;
import kwartz.node.Statement;

public interface Converter {
    public Statement[] convert(String pdata);

    public String getFilename();
    public void setFilename(String filename);

    public List getElementList();
    public void addElement(Element element);

    public Expression[] expandEmbeddedExpression(String pdata, int linenum);

    //public void setProperty(String key, String value);
    //public String getProperty(String key);
}
