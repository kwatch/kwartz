/**
 *  @(#) MethodExpression.java
 *  @Id  $Id$
 *  @copyright $Copyright$
 *  @release $Release$
 */
package kwartz.node;

import java.util.Map;
import kwartz.EvaluationException;
import kwartz.TokenType;
//import java.lang.reflect.Method;
//import java.lang.reflect.InvocationTargetException;

public class MethodExpression extends Expression {
    private Expression _object;
    private String _name;
    private Expression[] _args;
    protected Class[] _argtypes;
    public MethodExpression(Expression object, String method_name, Expression[] args) {
        super(TokenType.METHOD);
        _object = object;
        _name = method_name;
        _args = args;
        _argtypes = new Class[args.length];
        for (int i = 0; i < args.length; i++) {
            _argtypes[i] = Object.class;
        }
    }

    public Object evaluate(Map context) {
        Object value = _object.evaluate(context);
        try {
            java.lang.reflect.Method method =
                value.getClass().getMethod(_name, _argtypes);
            return method.invoke(value, null);
        }
        catch (java.lang.NoSuchMethodException ex) {
            throw new EvaluationException(ex.toString());
        }
        catch (java.lang.reflect.InvocationTargetException ex) {
            throw new EvaluationException("invalid object to invoke method '" + _name + "'.", ex);
        }
        catch (java.lang.IllegalArgumentException ex) {
            throw new EvaluationException(_name + ": invalid method argument.", ex);
        }
        catch (java.lang.IllegalAccessException ex) {
            throw new EvaluationException(_name + ": cannot access to the method.", ex);
        }
    }

    public Object accept(ExpressionVisitor visitor) {
        return visitor.visitMethodExpression(this);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        super._inspect(level, sb);
        _object._inspect(level+1, sb);
        for (int i = 0; i < level + 1; i++) sb.append("  ");
        sb.append(_name);
        sb.append("()\n");
        for (int i = 0; i < _args.length; i++) {
            _args[i]._inspect(level+2, sb);
        }
        return sb;
    }
}
