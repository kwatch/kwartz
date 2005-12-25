/**
 *  @(#) PrintStatement.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.node;

import java.util.List;
import java.util.Map;
import java.io.Writer;
import java.io.IOException;

import kwartz.Element;
import kwartz.Expander;
import kwartz.TokenType;

public class PrintStatement extends Statement {
    private Expression[] _arguments;
    public PrintStatement(Expression[] arguments) {
        super(TokenType.PRINT);
        _arguments = arguments;
    }
    public PrintStatement(List argList) {
        super(TokenType.PRINT);
        Expression[] arguments = new Expression[argList.size()];
        argList.toArray(arguments);
        _arguments = arguments;
    }

    public Expression[] getArguments() { return _arguments; }

    public Object execute(Map context, Writer writer) throws IOException {
        Expression expr;
        Object value;
        for (int i = 0; i < _arguments.length; i++) {
            expr = _arguments[i];
            value = expr.evaluate(context);
            if (value != null) {
                writer.write(value.toString());
            }
        }
        return null;
    }

    public Object accept(StatementVisitor visitor) {
        return visitor.visitPrintStatement(this);
    }

    public Statement accept(Expander expander, Element elem) {
        return expander.expand(this, elem);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        super._inspect(level, sb);
        for (int i = 0; i < _arguments.length; i++) {
            _arguments[i]._inspect(level+1, sb);
        }
        return sb;
    }
}
