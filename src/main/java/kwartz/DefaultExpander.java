/**
 *  @(#) DefaultExpander.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

import java.util.Map;
import java.util.Properties;

import kwartz.node.ArithmeticExpression;
import kwartz.node.AssignmentExpression;
import kwartz.node.BinaryExpression;
import kwartz.node.BlockStatement;
import kwartz.node.BooleanExpression;
import kwartz.node.ConcatenationExpression;
import kwartz.node.ConditionalExpression;
import kwartz.node.DoubleExpression;
import kwartz.node.ElementStatement;
import kwartz.node.EmptyExpression;
import kwartz.node.EmptyStatement;
import kwartz.node.ExpandStatement;
import kwartz.node.Expression;
import kwartz.node.ExpressionStatement;
import kwartz.node.ExpressionVisitor;
import kwartz.node.ForeachStatement;
import kwartz.node.FunctionExpression;
import kwartz.node.IfStatement;
import kwartz.node.IndexExpression;
import kwartz.node.IntegerExpression;
import kwartz.node.LiteralExpression;
import kwartz.node.LogicalAndExpression;
import kwartz.node.LogicalOrExpression;
import kwartz.node.MethodExpression;
import kwartz.node.NullExpression;
import kwartz.node.PrintStatement;
import kwartz.node.PropertyExpression;
import kwartz.node.RawcodeExpression;
import kwartz.node.RawcodeStatement;
import kwartz.node.RelationalExpression;
import kwartz.node.Statement;
import kwartz.node.StringExpression;
import kwartz.node.UnaryExpression;
import kwartz.node.VariableExpression;
import kwartz.node.WhileStatement;

public class DefaultExpander implements  Expander {

    public static class LiteralVisitor implements ExpressionVisitor {
        public Object visitExpression(Expression expr) { return expr.accept(this); }
        //
        public Object visitUnaryExpression(UnaryExpression expr)                 { return Boolean.FALSE; }
        public Object visitBinaryExpression(BinaryExpression expr)               { return Boolean.FALSE; }
        public Object visitArithmeticExpression(ArithmeticExpression expr)       { return Boolean.FALSE; }
        public Object visitConcatenationExpression(ConcatenationExpression expr) { return Boolean.FALSE; }
        public Object visitRelationalExpression(RelationalExpression expr)       { return Boolean.FALSE; }
        public Object visitAssignmentExpression(AssignmentExpression expr)       { return Boolean.FALSE; }
        public Object visitIndexExpression(IndexExpression expr)                 { return Boolean.FALSE; }
        public Object visitPropertyExpression(PropertyExpression expr)           { return Boolean.FALSE; }
        public Object visitMethodExpression(MethodExpression expr)               { return Boolean.FALSE; }
        public Object visitLogicalAndExpression(LogicalAndExpression expr)       { return Boolean.FALSE; }
        public Object visitLogicalOrExpression(LogicalOrExpression expr)         { return Boolean.FALSE; }
        public Object visitConditionalExpression(ConditionalExpression expr) {
            Object left  = expr.getLeft().accept(this);
            Object right = expr.getRight().accept(this);
            return left == Boolean.TRUE && right == Boolean.TRUE ? Boolean.TRUE : Boolean.FALSE;
        }
        public Object visitEmptyExpression(EmptyExpression expr)                 { return Boolean.FALSE; }
        public Object visitFunctionExpression(FunctionExpression expr)           { return Boolean.FALSE; }
        //
        public Object visitLiteralExpression(LiteralExpression expr)             { return Boolean.TRUE; }
        public Object visitStringExpression(StringExpression expr)               { return Boolean.TRUE; }
        public Object visitIntegerExpression(IntegerExpression expr)             { return Boolean.TRUE; }
        public Object visitDoubleExpression(DoubleExpression expr)               { return Boolean.TRUE; }
        public Object visitVariableExpression(VariableExpression expr)           { return Boolean.FALSE; }
        public Object visitBooleanExpression(BooleanExpression expr)             { return Boolean.TRUE; }
        public Object visitNullExpression(NullExpression expr)                   { return Boolean.TRUE; }
        public Object visitRawcodeExpression(RawcodeExpression expr)             { return Boolean.TRUE; }
    }


    private Map _elementTable;
    private TagHelper _helper = new TagHelper();
    private Properties _props;
    private boolean _flagEscape;
    private LiteralVisitor _literalVisitor = new LiteralVisitor();

    public DefaultExpander(Map elementTable) {
        this(elementTable, new Properties(Configuration.defaults));
    }
    public DefaultExpander(Map elementTable, Properties props) {
        _elementTable = elementTable;
        _props = props;
        String prop = _props.getProperty("kwartz.escape");
        _flagEscape = prop == null || (!prop.equals("false") && !prop.equals("no"));
    }


    public Statement expand(Statement stmt, Element elem) {
        return stmt == null ? null : stmt.accept(this, elem);
    }

    public Statement expand(PrintStatement stmt, Element elem) {
        if (_flagEscape) {
            Expression[] args = stmt.getArguments();
            for (int i = 0; i < args.length; i++) {
                if (args[i].accept(_literalVisitor) == Boolean.TRUE)
                    continue;
                if (args[i].getToken() == TokenType.FUNCTION) {
                    String fname = ((FunctionExpression)args[i]).getFunctionName();
                    if (fname.equals("E") || fname.equals("X"))
                        continue;
                }
                args[i] = new FunctionExpression("E", new Expression[] { args[i] });
            }
        }
        return null;
    }

    public Statement expand(ExpressionStatement stmt, Element elem) {
        return null;
    }

    public Statement expand(BlockStatement stmt, Element elem) {
        Statement[] stmts = stmt.getStatements();
        for (int i = 0; i < stmts.length; i++) {
            Statement st = expand(stmts[i], elem);
            if (st != null) stmts[i] = st;
        }
        return null;
    }

    public Statement expand(ForeachStatement stmt, Element elem) {
        Statement st = expand(stmt.getBodyStatement(), elem);
        if (st != null) stmt.setBodyStatement(st);
        return null;
    }

    public Statement expand(WhileStatement stmt, Element elem) {
        Statement st = expand(stmt.getBodyStatement(), elem);
        if (st != null) stmt.setBodyStatement(st);
        return null;
    }

    public Statement expand(IfStatement stmt, Element elem) {
        Statement st = expand(stmt.getThenStatement(), elem);
        if (st != null) stmt.setThenStatement(st);
        if (stmt.getElseStatement() != null) {
            st = expand(stmt.getElseStatement(), elem);
            if (st != null) stmt.setElseStatement(st);
        }
        return null;
    }

    public Statement expand(ElementStatement stmt, Element elem) {
        assert false;
        return null;
    }

    public Statement expand(ExpandStatement stmt, Element elem) {
        //ExpandStatement expandStmt;
        Statement st;
        Statement[] stmts;
        int type = stmt.getType();
        if (type  == ExpandStatement.STAG) {
            st = _helper.buildPrintStatement(elem.getStag());
            expand((PrintStatement)st, null);
        }
        else if (type == ExpandStatement.ETAG) {
            if (elem.getEtag() == null)
                st = new PrintStatement(new Expression[] {});
            else
                st = _helper.buildPrintStatement(elem.getEtag());
            expand((PrintStatement)st, null);
        }
        else if (type == ExpandStatement.CONT) {
            stmts = elem.getContentStatements();
            st = stmts.length == 1 ? stmts[0] : new BlockStatement(stmts);
            //st = new BlockStatement(stmts);
            Statement st2 = expand(st, null);
            if (st2 != null) st = st2;
        }
        else if (type == ExpandStatement.CONTENT) {
            String name = stmt.getName();
            Element elem2 = (Element)_elementTable.get(name);
            if (elem2 == null) {
                throw new ExpantionException("'@content('" + name + ")': element not found.");
            }
            stmts = elem2.getContentStatements();
            st = stmts.length == 1 ? stmts[0] : new BlockStatement(stmts);
            //st = new BlockStatement(stmts);
            Statement st2 = expand(st, null);
            if (st2 != null) st = st2;
        }
        else if (type == ExpandStatement.ELEMENT) {
            String name = stmt.getName();
            Element elem2 = (Element)_elementTable.get(name);
            if (elem2 == null) {
                throw new ExpantionException("'@element('" + name + ")': element not found.");
            }
            st = elem2.getPresentationLogic(); //block statment
            expand(st, elem2);
        }
        else {
            assert false;
            st = null;
        }
        return st;
    }

    public Statement expand(RawcodeStatement stmt, Element elem) {
        return null;
    }

    public Statement expand(EmptyStatement stmt, Element elem) {
        return null;
    }
}
