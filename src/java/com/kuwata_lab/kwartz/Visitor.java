/**
 *  @(#) Visitor.java
 *  @Id  $Id$
 *  @copyright (C)2005 kuwata-lab.com all rights reserverd
 */
package com.kuwata_lab.kwartz;

public class Visitor {
    public final Object visit(Node node) {
        return node.accept(this);
    }

    //
    public Object visitNode(Node expr)             { return null; }
    public Object visitExpression(Expression expr) { return visitNode(expr); }
    public Object visitStatement(Statement stmt)   { return visitNode(stmt); }
    //
    public Object visitBinaryExpression(BinaryExpression expr)               { return visitExpression(expr); }
    public Object visitArithmeticExpression(ArithmeticExpression expr)       { return visitExpression(expr); }
    public Object visitConcatenationExpression(ConcatenationExpression expr) { return visitExpression(expr); }
    public Object visitRelationalExpression(RelationalExpression expr) { return visitExpression(expr); }
    public Object visitAssignmentExpression(AssignmentExpression expr)       { return visitExpression(expr); }
    public Object visitPostfixExpression(PostfixExpression expr)             { return visitExpression(expr); }
    public Object visitPropertyExpression(PropertyExpression expr)           { return visitExpression(expr); }
    public Object visitLogicalAndExpression(LogicalAndExpression expr)       { return visitExpression(expr); }
    public Object visitLogicalOrExpression(LogicalOrExpression expr)         { return visitExpression(expr); }
    public Object visitConditionalExpression(ConditionalExpression expr)     { return visitExpression(expr); }
    public Object visitFunctionExpression(FunctionExpression expr)           { return visitExpression(expr); }
    //
    public Object visitLiteralExpression(LiteralExpression expr)             { return visitExpression(expr); }
    public Object visitStringExpression(StringExpression expr)               { return visitExpression(expr); }
    public Object visitIntegerExpression(IntegerExpression expr)             { return visitExpression(expr); }
    public Object visitFloatExpression(FloatExpression expr)                 { return visitExpression(expr); }
    public Object visitVariableExpression(VariableExpression expr)           { return visitExpression(expr); }
    public Object visitBooleanExpression(BooleanExpression expr)             { return visitExpression(expr); }
    public Object visitNullExpression(NullExpression expr)                   { return visitExpression(expr); }
    //
    public Object visitBlockStatement(BlockStatement stmt)                   { return visitStatement(stmt); }
    public Object visitPrintStatement(PrintStatement stmt)                   { return visitStatement(stmt); }
    public Object visitExpressionStatement(ExpressionStatement stmt)         { return visitStatement(stmt); }
    public Object visitForeachStatement(ForeachStatement stmt)               { return visitStatement(stmt); }
    public Object visitWhileStatement(WhileStatement stmt)                   { return visitStatement(stmt); }
    public Object visitIfStatement(IfStatement stmt)                         { return visitStatement(stmt); }
    public Object visitElementStatement(ElementStatement stmt)               { return visitStatement(stmt); }
    public Object visitExpandStatement(ExpandStatement stmt)                 { return visitStatement(stmt); }
}
