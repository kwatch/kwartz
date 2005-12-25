/**
 *  @(#) Optimizer.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;

import java.util.List;
import java.util.ArrayList;
import java.util.Properties;

import kwartz.node.BlockStatement;
import kwartz.node.ElementStatement;
import kwartz.node.EmptyStatement;
import kwartz.node.ExpandStatement;
import kwartz.node.Expression;
import kwartz.node.ExpressionStatement;
import kwartz.node.ForeachStatement;
import kwartz.node.IfStatement;
import kwartz.node.PrintStatement;
import kwartz.node.RawcodeStatement;
import kwartz.node.Statement;
import kwartz.node.StatementVisitor;
import kwartz.node.StringExpression;
import kwartz.node.WhileStatement;

public class Optimizer implements StatementVisitor {   // statement visitor

    private Properties _props; // for future use

    public Optimizer() {
        this(new Properties(Configuration.defaults));
    }
    public Optimizer(Properties props) {
        _props = props;
    }

    private void _concatArgs(Expression[] args, List argList, StringBuffer sb) {
        for (int i = 0; i < args.length; i++) {
            if (args[i].getToken() == TokenType.STRING) {
                String s = ((StringExpression)args[i]).getValue();
                sb.append(s);
            } else {
                if (sb.length() > 0) {
                    argList.add(new StringExpression(sb.toString()));
                    sb.delete(0, sb.length());
                }
                argList.add(args[i]);
            }
        }
    }

    private void _addPrintStatement(List stmtList, List argList, StringBuffer sb) {
        if (sb.length() > 0) {
            argList.add(new StringExpression(sb.toString()));
            sb.delete(0, sb.length());
        }
        if (argList.size() > 0) {
            stmtList.add(new PrintStatement(argList));
            argList.clear();
        }
    }

    private void _concatBlock(Statement[] stmts, List stmtList, List argList, StringBuffer sb) {
        for (int i = 0; i < stmts.length; i++) {
            int token = stmts[i].getToken();
            if (token == TokenType.PRINT) {
                Expression[] args = ((PrintStatement)stmts[i]).getArguments();
                _concatArgs(args, argList, sb);
            } else if (token == TokenType.BLOCK) {
                Statement[] stmts2 = ((BlockStatement)stmts[i]).getStatements();
                _concatBlock(stmts2, stmtList, argList, sb);
            } else {
                _addPrintStatement(stmtList, argList, sb);
                //Statement st = (Statement)stmts[i].accept(this);
                //stmtList.add(st);
                stmtList.add(stmts[i].accept(this));
            }
        }
    }

    public void optimize(BlockStatement blockStmt) {
        visitBlockStatement(blockStmt);
    }

    public Object visitStatement(Statement stmt) {
        return stmt.accept(this);
    }

    public Object visitBlockStatement(BlockStatement blockStmt) {
        Statement[] stmts = blockStmt.getStatements();
        List stmtList = new ArrayList();
        List argList = new ArrayList();
        StringBuffer sb = new StringBuffer();
        _concatBlock(stmts, stmtList, argList, sb);
        _addPrintStatement(stmtList, argList, sb);
        Statement[] newStmts = new Statement[stmtList.size()];
        stmtList.toArray(newStmts);
        blockStmt.setStatements(newStmts);
        return null;
    }

    public Object visitPrintStatement(PrintStatement stmt) {
        assert false;
        return null;
    }
    public Object visitExpressionStatement(ExpressionStatement stmt) {
        return stmt;
    }
    public Object visitForeachStatement(ForeachStatement stmt) {
        stmt.getBodyStatement().accept(this);
        return stmt;
    }
    public Object visitWhileStatement(WhileStatement stmt) {
        stmt.getBodyStatement().accept(this);
        return stmt;
    }
    public Object visitIfStatement(IfStatement stmt) {
        stmt.getThenStatement().accept(this);
        Statement st = stmt.getElseStatement();
        if (st != null) st.accept(this);
        return stmt;
    }
    public Object visitElementStatement(ElementStatement stmt) {
        assert false;
        return null;
    }
    public Object visitExpandStatement(ExpandStatement stmt) {
        assert false;
        return null;
    }
    public Object visitRawcodeStatement(RawcodeStatement stmt) {
        return stmt;
    }
    public Object visitEmptyStatement(EmptyStatement stmt) {
        return stmt;
    }

}
