/**
 *  @(#) NodeVisitor.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

public abstract class NodeVisitor  { //implements ExpressionVisitor, StatementVisitor {
    private ExpressionVisitor _exprVisitor;
    private StatementVisitor  _stmtVisitor;

    public NodeVisitor(ExpressionVisitor exprVisitor, StatementVisitor stmtVisitor) {
        _exprVisitor = exprVisitor;
        _stmtVisitor = stmtVisitor;
    }

    public Object visitNode(Node node) {
        if (node instanceof Expression)
            return ((Expression)node).accept(_exprVisitor);
        else if (node instanceof Statement)
            return ((Statement)node).accept(_stmtVisitor);
        else
            assert false;
        return null;
    }

    //
    //public Object visitNode(Node expr)             { return null; }
    public Object visitExpression(Expression expr) {
        //return _exprVisitor.visitExpression(expr);
        return expr.accept(_exprVisitor);
    }
    public Object visitStatement(Statement stmt)   {
        //return _stmtVisitor.visitStatement(stmt);
        return stmt.accept(_stmtVisitor);
    }
    //
    //public Object visitUnaryExpression(UnaryExpression expr)                 { return _exprVisitor.visitUnaryExpression(expr)         ; }
    //public Object visitBinaryExpression(BinaryExpression expr)               { return _exprVisitor.visitBinaryExpression(expr)        ; }
    //public Object visitArithmeticExpression(ArithmeticExpression expr)       { return _exprVisitor.visitArithmeticExpression(expr)    ; }
    //public Object visitConcatenationExpression(ConcatenationExpression expr) { return _exprVisitor.visitConcatenationExpression(expr) ; }
    //public Object visitRelationalExpression(RelationalExpression expr)       { return _exprVisitor.visitRelationalExpression(expr)    ; }
    //public Object visitAssignmentExpression(AssignmentExpression expr)       { return _exprVisitor.visitAssignmentExpression(expr)    ; }
    //public Object visitIndexExpression(IndexExpression expr)                 { return _exprVisitor.visitIndexExpression(expr)         ; }
    //public Object visitPropertyExpression(PropertyExpression expr)           { return _exprVisitor.visitPropertyExpression(expr)      ; }
    //public Object visitMethodExpression(MethodExpression expr)               { return _exprVisitor.visitMethodExpression(expr)        ; }
    //public Object visitLogicalAndExpression(LogicalAndExpression expr)       { return _exprVisitor.visitLogicalAndExpression(expr)    ; }
    //public Object visitLogicalOrExpression(LogicalOrExpression expr)         { return _exprVisitor.visitLogicalOrExpression(expr)     ; }
    //public Object visitConditionalExpression(ConditionalExpression expr)     { return _exprVisitor.visitConditionalExpression(expr)   ; }
    //public Object visitEmptyExpression(EmptyExpression expr)                 { return _exprVisitor.visitEmptyExpression(expr)         ; }
    //public Object visitFunctionExpression(FunctionExpression expr)           { return _exprVisitor.visitFunctionExpression(expr)      ; }
    ////
    //public Object visitLiteralExpression(LiteralExpression expr)             { return _exprVisitor.visitLiteralExpression(expr)       ; }
    //public Object visitStringExpression(StringExpression expr)               { return _exprVisitor.visitStringExpression(expr)        ; }
    //public Object visitIntegerExpression(IntegerExpression expr)             { return _exprVisitor.visitIntegerExpression(expr)       ; }
    //public Object visitDoubleExpression(DoubleExpression expr)               { return _exprVisitor.visitDoubleExpression(expr)        ; }
    //public Object visitVariableExpression(VariableExpression expr)           { return _exprVisitor.visitVariableExpression(expr)      ; }
    //public Object visitBooleanExpression(BooleanExpression expr)             { return _exprVisitor.visitBooleanExpression(expr)       ; }
    //public Object visitNullExpression(NullExpression expr)                   { return _exprVisitor.visitNullExpression(expr)          ; }
    //public Object visitRawcodeExpression(RawcodeExpression expr)             { return _exprVisitor.visitRawcodeExpression(expr)       ; }
    ////
    //public Object visitBlockStatement(BlockStatement stmt)                   { return _stmtVisitor.visitBlockStatement(stmt)          ; }
    //public Object visitPrintStatement(PrintStatement stmt)                   { return _stmtVisitor.visitPrintStatement(stmt)          ; }
    //public Object visitExpressionStatement(ExpressionStatement stmt)         { return _stmtVisitor.visitExpressionStatement(stmt)     ; }
    //public Object visitForeachStatement(ForeachStatement stmt)               { return _stmtVisitor.visitForeachStatement(stmt)        ; }
    //public Object visitWhileStatement(WhileStatement stmt)                   { return _stmtVisitor.visitWhileStatement(stmt)          ; }
    //public Object visitIfStatement(IfStatement stmt)                         { return _stmtVisitor.visitIfStatement(stmt)             ; }
    //public Object visitElementStatement(ElementStatement stmt)               { return _stmtVisitor.visitElementStatement(stmt)        ; }
    //public Object visitExpandStatement(ExpandStatement stmt)                 { return _stmtVisitor.visitExpandStatement(stmt)         ; }
    //public Object visitRawcodeStatement(RawcodeStatement stmt)               { return _stmtVisitor.visitRawcodeStatement(stmt)        ; }
    //public Object visitEmptyStatement(EmptyStatement stmt)                   { return _stmtVisitor.visitEmptyStatement(stmt)          ; }
}
