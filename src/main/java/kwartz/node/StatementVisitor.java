/**
 *  @(#) StatementVisitor.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.node;

public interface StatementVisitor {
//    public final Object visit(Node node);
    //
    public Object visitStatement(Statement stmt);
    //
    public Object visitBlockStatement(BlockStatement stmt)                   ;
    public Object visitPrintStatement(PrintStatement stmt)                   ;
    public Object visitExpressionStatement(ExpressionStatement stmt)         ;
    public Object visitForeachStatement(ForeachStatement stmt)               ;
    public Object visitWhileStatement(WhileStatement stmt)                   ;
    public Object visitIfStatement(IfStatement stmt)                         ;
    public Object visitElementStatement(ElementStatement stmt)               ;
    public Object visitExpandStatement(ExpandStatement stmt)                 ;
    public Object visitRawcodeStatement(RawcodeStatement stmt)               ;
    public Object visitEmptyStatement(EmptyStatement stmt)                   ;
}
