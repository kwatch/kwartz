/**
 *  @(#) Expander.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

import kwartz.node.BlockStatement;
import kwartz.node.ElementStatement;
import kwartz.node.EmptyStatement;
import kwartz.node.ExpandStatement;
import kwartz.node.ExpressionStatement;
import kwartz.node.ForeachStatement;
import kwartz.node.IfStatement;
import kwartz.node.PrintStatement;
import kwartz.node.RawcodeStatement;
import kwartz.node.Statement;
import kwartz.node.WhileStatement;

public interface Expander {

    public Statement expand(Statement           stmt, Element elem);
    public Statement expand(PrintStatement      stmt, Element elem);
    public Statement expand(ExpressionStatement stmt, Element elem);
    public Statement expand(ForeachStatement    stmt, Element elem);
    public Statement expand(WhileStatement      stmt, Element elem);
    public Statement expand(IfStatement         stmt, Element elem);
    public Statement expand(BlockStatement      stmt, Element elem);
    public Statement expand(ExpandStatement     stmt, Element elem);
    public Statement expand(ElementStatement    stmt, Element elem);
    public Statement expand(RawcodeStatement    stmt, Element elem);
    public Statement expand(EmptyStatement      stmt, Element elem);

}
