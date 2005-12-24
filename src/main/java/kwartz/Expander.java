/**
 *  @(#) Expander.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

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
