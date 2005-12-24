/**
 *  @(#) FunctionExpression.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz;
import java.util.Map;

public class FunctionExpression extends Expression {
    private String _funcname;
    private Expression[] _arguments;
    private Function _function;

    public FunctionExpression(String funcname, Expression[] arguments) {
        this(funcname, arguments, Function.getInstance(funcname));
    }
    public FunctionExpression(String funcname, Expression[] arguments, Function function) {
        super(TokenType.FUNCTION);
        _funcname = funcname;
        _arguments = arguments;
        _function = function;
    }

    public String getFunctionName() { return _funcname; }
    public Expression[] getArguments()   { return _arguments; }
    public Function getFunction() { return _function; }
    public void setFunction(Function function) { _function = function; }

    public Object evaluate(Map context) {
        if (_function == null) {
            //assert false;
            throw new EvaluationException("'" + _funcname + "': undefined function.");
        }
        return _function.call(context, _arguments);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        for (int i = 0; i < level; i++) sb.append("  ");
        sb.append(_funcname);
        sb.append("()\n");
        if (_arguments != null) {
            for (int i = 0; i < _arguments.length; i++) {
                _arguments[i]._inspect(level+1, sb);
            }
        }
        return sb;
    }

    public Object accept(ExpressionVisitor visitor) {
        return visitor.visitFunctionExpression(this);
    }
}
