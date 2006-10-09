/*
 * $Rev$
 * $Release$
 * $Copyright$
 */

package kwartz;

import java.util.List;


public interface Converter {

	public List convert(String pdata) throws ConvertException; // List<Ast.Statement>
	
}
