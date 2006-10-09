/*
 * $Rev$
 * $Release$
 * $Copyright$
 */
package kwartz;

import java.util.List;

public interface Handler {

	public boolean handle(List stmt_list, HandlerArgument arg) throws ConvertException;
	
	public boolean hasDirective(AttrInfo attr_info, TagInfo tag_info) throws ConvertException;
	
	public void applyRuleset(TagInfo stag_info, TagInfo tag_info, List cont_stmts, AttrInfo attr_info, List stmt_list) throws ConvertException;
	
	public Ast.Ruleset getRuleset(String selector_name);
	
}

