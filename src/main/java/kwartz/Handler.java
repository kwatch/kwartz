/*
 * $Rev$
 * $Release$
 * $Copyright$
 */
package kwartz;

import java.util.List;

public interface Handler {

	public void handleDirectives(String directive_str, ElementInfo elem_info, List stmt_list) throws ConvertException;  // for Converter
	
	public boolean handle(String directive_name, String directive_arg, String directive_str, ElementInfo elem_info, List stmt_list) throws ConvertException;
	
	public void applyRulesets(ElementInfo elem_info) throws ConvertException;  // for Converter
	
	public void expandElementInfo(ElementInfo elem_info, List stmt_list, boolean content_only) throws ConvertException;
	
	public void expandElementInfo(ElementInfo elem_info, List stmt_list) throws ConvertException;  // for Converter
	
	public Ast.Ruleset getRuleset(String selector_name);
	
	public ElementInfo getElementInfo(String name);  // for Expander class
	
	public List extract(String elem_name, boolean content_only) throws ConvertException; // for Main class
	
}

