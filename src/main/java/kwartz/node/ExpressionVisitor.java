/**
 *  @(#) ExpressionVisitor.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.node;

public interface ExpressionVisitor {
//    public Object visit(Expression expr) ;
    //
    public Object visitExpression(Expression expr);
    //
    public Object visitUnaryExpression(UnaryExpression expr)                 ;
    public Object visitBinaryExpression(BinaryExpression expr)               ;
    public Object visitArithmeticExpression(ArithmeticExpression expr)       ;
    public Object visitConcatenationExpression(ConcatenationExpression expr) ;
    public Object visitRelationalExpression(RelationalExpression expr)       ;
    public Object visitAssignmentExpression(AssignmentExpression expr)       ;
    public Object visitIndexExpression(IndexExpression expr)                 ;
    public Object visitPropertyExpression(PropertyExpression expr)           ;
    public Object visitMethodExpression(MethodExpression expr)               ;
    public Object visitLogicalAndExpression(LogicalAndExpression expr)       ;
    public Object visitLogicalOrExpression(LogicalOrExpression expr)         ;
    public Object visitConditionalExpression(ConditionalExpression expr)     ;
    public Object visitEmptyExpression(EmptyExpression expr)                 ;
    public Object visitFunctionExpression(FunctionExpression expr)           ;
    //;
    public Object visitLiteralExpression(LiteralExpression expr)             ;
    public Object visitStringExpression(StringExpression expr)               ;
    public Object visitIntegerExpression(IntegerExpression expr)             ;
    public Object visitDoubleExpression(DoubleExpression expr)               ;
    public Object visitVariableExpression(VariableExpression expr)           ;
    public Object visitBooleanExpression(BooleanExpression expr)             ;
    public Object visitNullExpression(NullExpression expr)                   ;
    public Object visitRawcodeExpression(RawcodeExpression expr)             ;
    //
}
