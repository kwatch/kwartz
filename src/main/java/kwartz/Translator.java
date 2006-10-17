/*
 * $Rev$
 * $Release$
 * $Copyright$
 */
package kwartz;

import java.util.List;


public interface Translator {
	
	public String translate(Ast.Node node) throws KwartzException;

	public String translate(List nodes) throws KwartzException;
	
}


