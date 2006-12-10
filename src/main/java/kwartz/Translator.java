/*
 * $Rev$
 * $Release$
 * $Copyright$
 */
package kwartz;

import java.util.List;
import java.util.Map;


public interface Translator {
	
	public String translate(Ast.Node node) throws KwartzException;

	public String translate(List nodes) throws KwartzException;
	
	public void setProperties(Map properties);
	
}
