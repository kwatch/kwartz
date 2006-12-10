/*
 * $Rev$
 * $Release$
 * $Copyright$
 */
package kwartz;

import java.util.List;

public interface Handler {

	public void handleDirectives(String directive_str, ElementInfo elem_info, List stmt_list) throws ConvertException;
	
	public boolean handle(String directive_name, String directive_arg, String directive_str, ElementInfo elem_info, List stmt_list) throws ConvertException;
	
	public void applyRuleset(ElementInfo elem_info, List stmt_list) throws ConvertException;
	
	public Ast.Ruleset getRuleset(String selector_name);
	
	public ElementInfo getElementInfo(String name);  // for Expander class
	
}

