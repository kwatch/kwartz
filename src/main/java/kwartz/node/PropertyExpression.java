/**
 *  @(#) PropertyExpression.java
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

public class PropertyExpression extends Expression {
    private Expression _object;
    private String _name;
    private String _getter;
    private String _setter;
    protected static Class[] _getter_argtypes_ = {};
    protected static Class[] _setter_argtypes_ = { Object.class };
    public PropertyExpression(Expression object, String prop_name) {
        super(TokenType.PROPERTY);
        _object = object;
        _name = prop_name;
        _getter = "get" + Character.toUpperCase(_name.charAt(0)) + _name.substring(1);
        _setter = "set" + Character.toUpperCase(_name.charAt(0)) + _name.substring(1);
    }
    public String _getter() { return _getter; }
    public String _setter() { return _setter; }

    public Object evaluate(Map context) {
        Object value = _object.evaluate(context);
        if (value == null)
            throw new EvaluationException("object of property `" + _name + "' is null.");
        try {
            java.lang.reflect.Method method =
                value.getClass().getMethod(_getter, _getter_argtypes_);
            return method.invoke(value, null);
        } catch (java.lang.NoSuchMethodException ex) {
            // raises on Class.getMethod()
            //throw new EvaluationException(_name + ": no such property.", ex);
            throw new EvaluationException(ex.toString());
        }
        catch (java.lang.reflect.InvocationTargetException ex) {
            // raises on method.invoke()
            throw new EvaluationException("invalid object to access property '" + _name + "'.", ex);
        }
        catch (java.lang.IllegalArgumentException ex) {
            // raises on method.invoke()
            throw new EvaluationException(_name + ": invalid property.", ex);
        }
        catch (java.lang.IllegalAccessException ex) {
            // raises on method.invoke()
            throw new EvaluationException(_name + ": cannot access to the property.", ex);
        }
    }

    public Object accept(ExpressionVisitor visitor) {
        return visitor.visitPropertyExpression(this);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        super._inspect(level, sb);
        _object._inspect(level+1, sb);
        for (int i = 0; i < level + 1; i++) sb.append("  ");
        sb.append(_name);
        sb.append('\n');
        return sb;
    }
}
