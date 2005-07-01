#/usr/bin/ruby

###
### usage: ruby kwartz-java.java
###

SRC_ROOT   = 'src/java'
TEST_ROOT  = 'src/test'
PACKAGE = 'com.kuwata_lab.kwartz'

Dir.mkdir(SRC_ROOT)  unless test(?d, SRC_ROOT)
Dir.mkdir(TEST_ROOT) unless test(?d, TEST_ROOT)

header = ''
while line = DATA.gets()
   break if line =~ /^\/\/ -----/
   header << line
end

while line = DATA.gets()
   if line =~ /\Apackage\s+(.*);/
      package = $1.gsub(/__PACKAGE__/, PACKAGE)

      klass = nil
      code = ''
      code << line
      while line = DATA.gets()
         code << line
         if line =~ /\A(public|protected|private|class|abstract)\s+.*?([A-Z]\w+[a-z])/
            klass = $2
         end
         break if line =~ /\A\}$/
      end
      unless klass
         raise "cannot detect class name. ($.=#{$.})"
      end

      root = klass =~ /Test$/ ? TEST_ROOT : SRC_ROOT
      path = root.dup
      package.split('.').each do |name|
         path << "/#{name}"
         Dir.mkdir(path) unless test(?d, path)
      end

      filename = "#{path}/#{klass}.java"
      File.open(filename, 'w') do |f|
         f.write(header.gsub(/__CLASS__/, klass).gsub(/__PACKAGE__/, PACKAGE))
         f.write(code.gsub(/__PACKAGE__/, PACKAGE))
      end
   end
end


###
### generate TokenType.java
###
tokentype_str = <<END
// EOF
EOF		<<EOF>>

// arithmetic
ADD		+
SUB		-
MUL		*
DIV		/
MOD		%
CONCAT		.+

// assignment
ASSIGN		=
ADD_TO		+=
SUB_TO		-=
MUL_TO		*=
DIV_TO		/=
MOD_TO		%=
CONCAT_TO	.+=

// literal
STRING		<<string>>
INTEGER		<<integer>>
FLOAT		<<float>>
VARIABLE	<<variable>>
TRUE		true
FALSE		false
NULL		null
EMPTY		empty
NAME		<<name>>

// array, hash, property
ARRAY		[]
HASH		[:]
PROPERTY	.
L_BRACKET	[
R_BRACKET	]
L_BRACKETCOLON	[:

// function
FUNCTION	<<function>>

// conditional operator
CONDITIONAL	?

// relational op
EQ		==
NE		!=
LT		<
LE		<=
GT		>
GE		>=

// logical op
NOT		!
AND		&&
OR		||

// statement
BLOCK		<<block>>
PRINT		:print
EXPR		:expr
FOREACH		:foreach
IN		:in
WHILE		:while
IF		:if
ELSEIF		:elseif
ELSE		:else
EXPAND		@

// raw expression and raw statement
RAWEXPR		<%= %>
RAWSTMT		<% %>

// element
ELEMENT		#
VALUE		value:
ATTR		attr:
APPEND		append:
REMOVE		remove:
PLOGIC		plogic:
TAGNAME		tagname:
END

words = []

klass = 'TokenType'
package = PACKAGE.dup;
path = SRC_ROOT + "/" + package.gsub(/\./, '/')

template = <<END
#{ header.gsub(/__CLASS__/, klass).gsub(/__PACKAGE__/, PACKAGE) }
package #{PACKAGE};

END

template << <<'END'
public class TokenType {

% i = -1
% tokentype_str.each_line do |line|
%    if line =~ /^$/ || line =~ /^\/\//
    <%= line.chop %>
%    elsif line =~ /^(\w+)\s+(.*)/
%       i += 1; word = $1;  text = $2;  words << [word, text]
    public static final int <%= "%-14s" % word %> = <%= "%3d" % i %>;  // <%= text %>
%    end
% end

    public static int assignToArithmetic(int token) {
        return token - TokenType.ADD_TO + TokenType.ADD;
    }
    public static int arithmeticToAssign(int token) {
        return token - TokenType.ADD + TokenType.ADD_TO;
    }

    public static String[] tokenNames = {
        //"(dummy)",
% words.each do |tuple|
%    word = tuple[0]
        "<%= word %>",
% end
    };
    public static String tokenName(int token) {
        return tokenNames[token];
    }

    public static String[] tokenTexts = {
        //"(dummy)",
% words.each do |tuple|
%    word = tuple[0]; text = tuple[1];
        "<%= text %>",
% end
    };
    public static String tokenText(int token) {
        return tokenTexts[token];
    }


    public static String inspect(int token) {
        return inspect(token, null);
    }

    public static String inspect(int token, String value) {
        switch (token) {
          case TokenType.STRING:
            return inspectString(value);
          case TokenType.INTEGER:
            return value;
          case TokenType.FLOAT:
            return value;
          case TokenType.VARIABLE:
            return value;
          case TokenType.NAME:
            return value;
          default:
            return tokenTexts[token];
        }
    }

    public static String inspectString(String s) {
        StringBuffer sb = new StringBuffer();
        sb.append('"');
        for (int i = 0; i < s.length(); i++) {
            char ch = s.charAt(i);
            switch (ch) {
              case '\n':  sb.append("\\n");   break;
              case '\r':  sb.append("\\r");   break;
              case '\t':  sb.append("\\t");   break;
              case '"':   sb.append("\\\"");  break;
              default:
                sb.append(ch);
            }
        }
        sb.append('"');
        return sb.toString();
    }

}
END


require 'erb'
trim_mode = '%'
erb = ERB.new(template, $SAFE, trim_mode)
s = erb.result(binding())
File.open("#{path}/#{klass}.java", "w") { |f| f.write(s) }

__END__
/**
 *  @(#) __CLASS__.java
 *  @Id  $Id$
 *  @copyright (C)2005 kuwata-lab.com all rights reserverd
 */
// --------------------------------------------------------------------------------

package __PACKAGE__;

public class BaseException extends RuntimeException {
    public BaseException(String message) {
        super(message);
    }
    public BaseException(String message, Throwable cause) {
        super(message, cause);
    }
    public BaseException(Throwable cause) {
        super(cause);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

public class SemanticException extends BaseException {
    public SemanticException(String message) {
        super(message);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

public class EvaluationException extends BaseException {
    public EvaluationException(String message) {
        super(message);
    }
    public EvaluationException(String message, Exception cause) {
        super(message, cause);
    }
    public EvaluationException(Exception cause) {
        super(cause);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

public class ExecutionException extends BaseException {
    public ExecutionException(String message) {
        super(message);
    }
    public ExecutionException(String message, Exception cause) {
        super(message, cause);
    }
    public ExecutionException(Exception cause) {
        super(cause);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

public class MiscException extends BaseException {
    public MiscException(Exception cause) {
        super(cause);
    }
}

// ================================================================================

package __PACKAGE__;

public class Utility {
    public static String capitalize(String str) {
        return Character.toUpperCase(str.charAt(0)) + str.substring(1);
    }

    //public String capitalize(String str) {
    //    return Character.toUpperCase(str.charAt(0)) + str.substring(1);
    //}

    public String escapeString(String str) {
        if (str == null) return null;
        StringBuffer sb = new StringBuffer();
        char[] chars = str.toCharArray();
        for (int i = 0; i < chars.length ; i++) {
            switch (chars[i]) {
              case '"':
                sb.append("\\\"");   break;
              case '\\':
                sb.append("\\\\");   break;
              case '\n':
                sb.append("\\n");    break;
              case '\r':
                sb.append("\\r");    break;
              default:
                sb.append(chars[i]);
            }
        }
        return sb.toString();
    }

    public String escapeHtml(String str) {
        if (str == null) return null;
        StringBuffer sb = new StringBuffer();
        char[] chars = str.toCharArray();
        for (int i = 0; i < chars.length; i++) {
            switch (chars[i]) {
              case '&':
                sb.append("&amp;");  break;
              case '<':
                sb.append("&lt;");   break;
              case '>':
                sb.append("&gt;");   break;
              case '"':
                sb.append("&quot;"); break;
              default:
                sb.append(chars[i]);
            }
        }
        return sb.toString();
    }
}

// ================================================================================

package __PACKAGE__;
import java.util.Map;

abstract class Node {
    protected int _token;
    public Node(int token) {
        _token = token;
    }
    public int getToken() { return _token; }
    public void setToken(int token) { _token = token; }

    abstract public Object evaluate(Map context);
    abstract public Object accept(Visitor visitor);

    public StringBuffer _inspect(int level, StringBuffer sb) {
        for (int i = 0; i < level; i++) sb.append("  ");
        sb.append(TokenType.tokenName(_token));
        sb.append("\n");
        return sb;
    }
    public StringBuffer _inspect() {
        return _inspect(0, new StringBuffer());
    }
}

// ================================================================================

package __PACKAGE__;

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

// ================================================================================

package __PACKAGE__;

abstract public class Expression extends Node {
    public Expression(int token) {
        super(token);
    }

    public Object accept(Visitor visitor) {
        return visitor.visitExpression(this);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;

public class BinaryExpression extends Expression {
    protected Expression _left;
    protected Expression _right;

    public BinaryExpression(int token, Expression left, Expression right) {
        super(token);
        _left = left;
        _right = right;
    }

    public Expression getLeft() { return _left; }
    public void setLeft(Expression expr) { _left = expr; }
    public Expression getRight() { return _right; }
    public void setRight(Expression expr) { _right = expr; }

    /*
    public Object evaluate(Map context, Visitor executer) {
        executer.executeBinaryExpression(context, left, right);
    }*/
    public Object accept(Visitor visitor) {
        return visitor.visitBinaryExpression(this);
    }

    public Object evaluate(Map context) {
        return null;
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        super._inspect(level, sb);
        _left._inspect(level+1, sb);
        _right._inspect(level+1, sb);
        return sb;
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;

public class ArithmeticExpression extends BinaryExpression {
    public ArithmeticExpression(int token, Expression left, Expression right) {
        super(token, left, right);
    }

    public Object evaluate(Map context) {
        Object lvalue = _left.evaluate(context);
        if (! (lvalue instanceof Integer || lvalue instanceof Float) ) {
            throw new EvaluationException("required integer or float.");
        }
        Object rvalue = _right.evaluate(context);
        if (! (rvalue instanceof Integer || rvalue instanceof Float) ) {
            throw new EvaluationException("required integer or float.");
        }
        Number lval = (Number)lvalue;
        Number rval = (Number)rvalue;
        boolean is_int = (lvalue instanceof Integer && rvalue instanceof Integer);
        if (is_int) {
            int l = lval.intValue();
            int r = rval.intValue();
            int v = 0;
            switch (_token) {
              case TokenType.ADD:  v = l + r;  break;
              case TokenType.SUB:  v = l - r;  break;
              case TokenType.MUL:  v = l * r;  break;
              case TokenType.DIV:  v = l / r;  break;
              case TokenType.MOD:  v = l % r;  break;
              default:
                assert false;
            }
            return new Integer(v);
        } else {
            float l = lval.floatValue();
            float r = rval.floatValue();
            float v = 0;
            switch (_token) {
              case TokenType.ADD:  v = l + r;  break;
              case TokenType.SUB:  v = l - r;  break;
              case TokenType.MUL:  v = l * r;  break;
              case TokenType.DIV:  v = l / r;  break;
              case TokenType.MOD:  v = l % r;  break;
              default:
                assert false;
            }
            return new Float(v);
        }
        //return null;
    }

    public Object accept(Visitor visitor) {
        return visitor.visitArithmeticExpression(this);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;

public class ConcatenationExpression extends BinaryExpression {
    public ConcatenationExpression(int token, Expression left, Expression right) {
        super(token, left, right);
    }
    public ConcatenationExpression(Expression left, Expression right) {
        super(TokenType.CONCAT, left, right);
    }

    public Object evaluate(Map context) {
        Object lvalue = _left.evaluate(context);
        Object rvalue = _right.evaluate(context);
        if (! (lvalue instanceof String || lvalue instanceof Number)) {
            throw new EvaluationException("cannot concatenate not string nor number.");
        }
        if (! (rvalue instanceof String || rvalue instanceof Number)) {
            throw new EvaluationException("cannot concatenate not string nor number.");
        }
        return lvalue.toString() + rvalue.toString();
    }

    public Object accept(Visitor visitor) {
        return visitor.visitConcatenationExpression(this);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;

public class AssignmentExpression extends BinaryExpression {
    public AssignmentExpression(int token, Expression left, Expression right) {
        super(token, left, right);
    }

    public Object evaluate(Map context) {
        // convert 'foo += 1'  to 'foo = foo + 1'
        if (_token != TokenType.ASSIGN) {
            synchronized(this) {
                if (_token != TokenType.ASSIGN) {
                    int op = TokenType.assignToArithmetic(_token);
                    /*
                    _right = op == TokenType.CONCAT ? new ConcatenationExpression(op, _left, _right)
                                                    : new ArithmeticExpression(op, _left, _right);
                     */
                    if (op == TokenType.CONCAT) {
                        _right = new ConcatenationExpression(op, _left, _right);
                    } else {
                        _right = new ArithmeticExpression(op, _left, _right);
                    }
                    _token = TokenType.ASSIGN;
                }
            }
        }

        // get right-hand value
        Object rvalue = _right.evaluate(context);

        // assgin into variable
        switch (_left.getToken()) {
          case TokenType.VARIABLE:
            String varname = ((VariableExpression)_left).getName();
            context.put(varname, rvalue);
            break;
          case TokenType.ARRAY:
            // TBC
            break;
          case TokenType.HASH:
            // TBC
            break;
          default:
            // error
            throw new SemanticException("invalid assignment: left-value should be varaible, array or hash.");
        }
        return rvalue;
    }

    public Object accept(Visitor visitor) {
        return visitor.visitAssignmentExpression(this);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;

public class RelationalExpression extends BinaryExpression {
    public RelationalExpression(int token, Expression left, Expression right) {
        super(token, left, right);
    }

    /*
    public Object evaluate(Map context, Evaluator evaluator) {
        return evaluator.evaluateRelationalExpression(context, self);
    }*/

    public Object evaluate(Map context) {
        Object lvalue = _left.evaluate(context);
        Object rvalue = _right.evaluate(context);
        boolean is_number = false;
        if (lvalue instanceof Integer && rvalue instanceof Integer) {
            int lval = ((Number)lvalue).intValue();
            int rval = ((Number)rvalue).intValue();
            switch (_token) {
              case TokenType.LT:  return lval < rval  ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.GT:  return lval > rval  ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.LE:  return lval <= rval ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.GE:  return lval >= rval ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.EQ:  return lval == rval ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.NE:  return lval != rval ? Boolean.TRUE : Boolean.FALSE;
              default:
                assert false;
            }
        }
        else if (   (lvalue instanceof Integer || lvalue instanceof Float)
                 && (rvalue instanceof Integer || rvalue instanceof Float)) {
            float lval = ((Number)lvalue).floatValue();
            float rval = ((Number)rvalue).floatValue();
            switch (_token) {
              case TokenType.LT:  return lval < rval  ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.GT:  return lval > rval  ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.LE:  return lval <= rval ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.GE:  return lval >= rval ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.EQ:  return lval == rval ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.NE:  return lval != rval ? Boolean.TRUE : Boolean.FALSE;
              default:
                assert false;
            }
        }
        else if (   (lvalue instanceof String || lvalue instanceof Integer || lvalue instanceof Float)
                 && (rvalue instanceof String || rvalue instanceof Integer || rvalue instanceof Float)) {
            String lval = lvalue.toString();
            String rval = rvalue.toString();
            switch (_token) {
              case TokenType.LT:  return lval.compareTo(rval) <  0 ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.GT:  return lval.compareTo(rval) >  0 ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.LE:  return lval.compareTo(rval) <= 0 ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.GE:  return lval.compareTo(rval) >= 0 ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.EQ:  return lval.compareTo(rval) == 0 ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.NE:  return lval.compareTo(rval) != 0 ? Boolean.TRUE : Boolean.FALSE;
              default:
                assert false;
            }
        }
        else {
            // error
            if (! (lvalue instanceof String || lvalue instanceof Integer || lvalue instanceof Float)) {
                throw new EvaluationException("cannot compare a '" + lvalue.getClass().getName() + "' object.");
            }
            if (! (rvalue instanceof String || rvalue instanceof Integer || rvalue instanceof Float)) {
                throw new EvaluationException("cannot compare a '" + rvalue.getClass().getName() + "' object.");
            }
            assert false;
        }
        return null;
    }

    public Object accept(Visitor visitor) {
        return visitor.visitRelationalExpression(this);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;
import java.util.List;

public class PostfixExpression extends BinaryExpression {
    public PostfixExpression(int token, Expression left, Expression right) {
        super(token, left, right);
    }
    public Object evaluate(Map context) {
        Object lvalue = _left.evaluate(context);
        Object rvalue = _right.evaluate(context);
        switch (_token) {
          case TokenType.ARRAY:
            if (lvalue instanceof Map) {
                return ((Map)lvalue).get(rvalue);
            }
            else if (lvalue instanceof List) {
                if (! (rvalue instanceof Integer)) {
                    throw new EvaluationException("index of List object is not an integer.");
                }
                int index = ((Integer)rvalue).intValue();
                return ((List)lvalue).get(index);
            }
            else if (lvalue.getClass().isArray()) {
                if (! (rvalue instanceof Integer)) {
                    throw new EvaluationException("index of array is not an integer.");
                }
                int index = ((Integer)rvalue).intValue();
                return ((Object[])lvalue)[index];
            }
            throw new EvaluationException("invalid '[]' operator for non-list,map,nor array.");
            //break;

          case TokenType.PROPERTY:
            // TBC
            break;

          case TokenType.HASH:
            if (lvalue instanceof Map) {
                return ((Map)lvalue).get(rvalue);
            }
            throw new EvaluationException("invalid '[:]' operator for non-map object.");

          default:
            assert false;
        }
        return null;
    }
    public Object accept(Visitor visitor) {
        return visitor.visitPostfixExpression(this);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;
import java.util.List;
import java.lang.reflect.Method;
import java.lang.reflect.InvocationTargetException;

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

    public Object accept(Visitor visitor) {
        return visitor.visitPropertyExpression(this);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;

public class LogicalAndExpression extends BinaryExpression {
    public LogicalAndExpression(Expression left, Expression right) {
        super(TokenType.AND, left, right);
    }
    public Object evaluate(Map context) {
        Object value;
        value = _left.evaluate(context);
        if (BooleanExpression.isFalse(value))
            return Boolean.FALSE;
        value = _right.evaluate(context);
        if (BooleanExpression.isFalse(value))
            return Boolean.FALSE;
        return Boolean.TRUE;
    }
    public Object accept(Visitor visitor) {
        return visitor.visitLogicalAndExpression(this);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;

public class LogicalOrExpression extends BinaryExpression {
    public LogicalOrExpression(Expression left, Expression right) {
        super(TokenType.AND, left, right);
    }
    public Object evaluate(Map context) {
        Object value;
        value = _left.evaluate(context);
        if (BooleanExpression.isTrue(value))
            return Boolean.TRUE;
        value = _right.evaluate(context);
        if (BooleanExpression.isTrue(value))
            return Boolean.TRUE;
        return Boolean.FALSE;
    }
    public Object accept(Visitor visitor) {
        return visitor.visitLogicalOrExpression(this);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;

public class ConditionalExpression extends Expression {
    protected Expression _condition;
    protected Expression _left;
    protected Expression _right;
    public ConditionalExpression(Expression condition, Expression left, Expression right) {
        super(TokenType.CONDITIONAL);
        _condition = condition;
        _left      = left;
        _right     = right;
    }
    public Expression getCondition() { return _condition; }
    public void setCondition(Expression expr) { _condition = expr; }
    public Expression getLeft() { return _left; }
    public void setLeft(Expression expr) { _left = expr; }
    public Expression getRight() { return _right; }
    public void setRight(Expression expr) { _right = expr; }

    public Object evaluate(Map context) {
        Object val = _condition.evaluate(context);
        return BooleanExpression.isFalse(val) ? _right.evaluate(context) : _left.evaluate(context);
        /*
        return val == null || val == Boolean.FALSE ? _right.evaluate(context)
                                                   : _left.evaluate(context);
          */
    }

    public Object accept(Visitor visitor) {
        return visitor.visitConditionalExpression(this);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        super._inspect(level, sb);
        _condition._inspect(level+1, sb);
        _left._inspect(level+1, sb);
        _right._inspect(level+1, sb);
        return sb;
    }
}

// ================================================================================

package __PACKAGE__;
import java.util.Map;
import java.util.HashMap;

abstract public class Macro {
    protected String _name;

    public Macro(String macroname) {
        _name = macroname;
    }

    public String getName() { return _name; }
    public void setName(String name) { _name = name; }

    abstract public Expression call(Expression expr);

    static Map _instances = new HashMap();
    public static void register(Macro macro) {
        register(macro.getName(), macro);
    }
    public static void register(String name, Macro macro) {
        _instances.put(name, macro);
    }
    public static Macro getInstance(String name) {
        return (Macro)_instances.get(name);
    }
    public static boolean isRegistered(String name) {
        return _instances.containsKey(name);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

public class CheckedMacro extends Macro {
    public CheckedMacro() {
        super("C");
    }
    public Expression call(Expression expr) {
        Expression left = new StringExpression(" checked=\"checked\"");
        Expression right = new StringExpression("");
        return new ConditionalExpression(expr, left, right);
    }
    static {
        Macro.register(new CheckedMacro());
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

public class SelectedMacro extends Macro {
    public SelectedMacro() {
        super("S");
    }
    public Expression call(Expression expr) {
        Expression left = new StringExpression(" checked=\"checked\"");
        Expression right = new StringExpression("");
        return new ConditionalExpression(expr, left, right);
    }
    static {
        Macro.register(new SelectedMacro());
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

public class DisabledMacro extends Macro {
    public DisabledMacro() {
        super("D");
    }
    public Expression call(Expression expr) {
        Expression left = new StringExpression(" disabled=\"disabled\"");
        Expression right = new StringExpression("");
        return new ConditionalExpression(expr, left, right);
    }
    static {
        Macro.register(new DisabledMacro());
    }
}

// ================================================================================

package __PACKAGE__;
import java.util.Map;
import java.util.HashMap;

abstract public class Function {
    protected String _name;

    public Function(String funcname) {
        _name = funcname;
    }

    public String getName() { return _name; }
    public void setName(String name) { _name = name; }

    abstract public Object call(Map context, Expression[] arguments);

    static Map _instances = new HashMap();
    public static void register(Function function) {
        register(function.getName(), function);
    }
    public static void register(String funcname, Function function) {
        _instances.put(funcname, function);
    }

    public static Function getInstance(String funcname) {
        return (Function)_instances.get(funcname);
    }

    public static boolean isRegistered(String funcname) {
        return _instances.containsKey(funcname);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;

public class SanitizeFunction extends Function {
    public SanitizeFunction() {
        super("E");	// 'E' means 'escape'
    }

    public Object call(Map context, Expression[] arguments) {
        assert arguments.length == 1;
        Expression expr = arguments[0];
        Object val = expr.evaluate(context);
        String s = (String)val;
        s = s.replaceAll("&", "&amp;");
        s = s.replaceAll("<", "&lt;");
        s = s.replaceAll(">", "&gt;");
        s = s.replaceAll("\"", "&quot");
        return s;
    }

    static {
        Function.register(new SanitizeFunction());
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;

public class AsIsFunction extends Function {
    public AsIsFunction() {
        super("X");
    }

    public Object call(Map context, Expression[] arguments) {
        assert arguments.length == 1;
        Expression expr = arguments[0];
        return expr.evaluate(context);
    }

    static {
        Function.register(new AsIsFunction());
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;
import java.util.List;

public class ListLengthFunction extends Function {
    public ListLengthFunction() {
        super("list_length");
    }
    public Object call(Map context, Expression[] arguments) {
        assert arguments.length == 1;
        Expression expr = arguments[0];
        Object val = expr.evaluate(context);
        if (val instanceof List) {
            return new Integer(((List)val).size());
        }
        if (val.getClass().isArray()) {
            int len = ((Object[])val).length;
            return new Integer(len);
        }
        throw new EvaluationException("list_length(): argument is not a List nor an Array.");
    }
}

// ================================================================================

package __PACKAGE__;
import java.util.Map;

public class FunctionExpression extends Expression {
    private String _funcname;
    private Expression[] _arguments;
    public FunctionExpression(String funcname, Expression[] arguments) {
        super(TokenType.FUNCTION);
        _funcname = funcname;
        _arguments = arguments;
    }

    public Object evaluate(Map context) {
        Function func = Function.getInstance(_funcname);
        if (func == null) {
            //assert false;
            throw new EvaluationException("'" + _funcname + "': undefined function.");
        }
        return func.call(context, _arguments);
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
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;

public class VariableExpression extends Expression {
    private String _name;
    public VariableExpression(String name) {
        super(TokenType.VARIABLE);
        _name = name;
    }
    public String getName() { return _name; }
    public Object evaluate(Map context) {
        //Object val = context.get(_name);
        //return val != null ? val : NullExpression.instance();
        return context.get(_name);
    }

    public Object accept(Visitor visitor) {
        return visitor.visitVariableExpression(this);
    }
    public StringBuffer _inspect(int level, StringBuffer sb) {
        for (int i = 0; i < level; i++) sb.append("  ");
        sb.append(_name);
        sb.append("\n");
        return sb;
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

abstract public class LiteralExpression extends Expression {
    public LiteralExpression(int token) {
        super(token);
    }
    public Object accept(Visitor visitor) {
        return visitor.visitLiteralExpression(this);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;

public class StringExpression extends LiteralExpression {
    private String _value;
    public StringExpression(String value) {
        super(TokenType.STRING);
        _value = value;
    }
    public Object evaluate(Map context) {
        return _value;
    }
    public Object accept(Visitor visitor) {
        return visitor.visitStringExpression(this);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        for (int i = 0; i < level; i++) sb.append("  ");
        sb.append('"');
        sb.append(_value);
        sb.append('"');
        sb.append("\n");
        return sb;
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;

public class IntegerExpression extends LiteralExpression {
    private int _value;
    public IntegerExpression(int value) {
        super(TokenType.INTEGER);
        _value = value;
    }
    public Object evaluate(Map context) {
        return new Integer(_value);
    }
    public Object accept(Visitor visitor) {
        return visitor.visitIntegerExpression(this);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        for (int i = 0; i < level; i++) sb.append("  ");
        sb.append(_value);
        sb.append("\n");
        return sb;
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;

public class FloatExpression extends LiteralExpression {
    private float _value;
    public FloatExpression(float value) {
        super(TokenType.FLOAT);
        _value = value;
    }
    public Object evaluate(Map context) {
        return new Float(_value);
    }
    public Object accept(Visitor visitor) {
        return visitor.visitFloatExpression(this);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        for (int i = 0; i < level; i++) sb.append("  ");
        sb.append(_value);
        sb.append("\n");
        return sb;
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;

public class BooleanExpression extends LiteralExpression {
    private boolean _value;
    public BooleanExpression(boolean value) {
        super(value ? TokenType.TRUE : TokenType.FALSE);
        _value = value;
    }
    public Object evaluate(Map context) {
        return _value ? Boolean.TRUE : Boolean.FALSE;
    }
    public Object accept(Visitor visitor) {
        return visitor.visitBooleanExpression(this);
    }

    public static boolean isFalse(Object value) {
        //return (value == null || value.equals(Boolean.FALSE));
        return (value == null || value == (Object)Boolean.FALSE);
    }

    public static boolean isTrue(Object value) {
        //return (value != null && ! value.equals(Boolean.FALSE));
        return (value != null && value != (Object)Boolean.FALSE);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        for (int i = 0; i < level; i++) sb.append("  ");
        sb.append(_value ? "true\n" : "false\n");
        return sb;
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;

public class NullExpression extends LiteralExpression {
    public NullExpression() {
        super(TokenType.NULL);
    }
    public Object evaluate(Map context) {
        /* return Boolean.FALSE; */
        /* return Null.NULL; */
        return null;
    }
    public Object accept(Visitor visitor) {
        return visitor.visitNullExpression(this);
    }
    public StringBuffer _inspect(int level, StringBuffer sb) {
        for (int i = 0; i < level; i++) sb.append("  ");
        sb.append("null\n");
        return sb;
    }
}

// ================================================================================

package __PACKAGE__;
import java.util.Map;
import java.io.Writer;
import java.io.StringWriter;
import java.io.IOException;

abstract public class Statement extends Node {
    public Statement(int token) {
        super(token);
    }
    public Object evaluate(Map context) {
        StringWriter writer = new StringWriter();
        try {
            execute(context, writer);
        } catch (IOException ex) {
            //throw new MiscException(ex);
            ex.printStackTrace();
        }
        return writer.toString();
    }
    abstract public Object execute(Map context, Writer writer) throws IOException;

    public Object accept(Visitor visitor) {
        return visitor.visitStatement(this);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;
import java.io.Writer;
import java.io.IOException;

public class BlockStatement extends Statement {
    private Statement[] _statements;
    public BlockStatement(Statement[] statements) {
        super(TokenType.BLOCK);
        _statements = statements;
    }
    public Statement[] getStatements() { return _statements; }
    public void setStatements(Statement[] statements) { _statements = statements; }

    public Object execute(Map context, Writer writer) throws IOException {
        for (int i = 0; i < _statements.length; i++) {
            _statements[i].execute(context, writer);
        }
        return null;
    }

    public Object accept(Visitor visitor) {
        return visitor.visitBlockStatement(this);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;
import java.io.Writer;
import java.io.IOException;

public class PrintStatement extends Statement {
    private Expression[] _arguments;
    public PrintStatement(Expression[] arguments) {
        super(TokenType.PRINT);
        _arguments = arguments;
    }

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

    public Object accept(Visitor visitor) {
        return visitor.visitPrintStatement(this);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;
import java.io.Writer;

public class ExpressionStatement extends Statement {
    private Expression _expr;
    public ExpressionStatement(Expression expr) {
        super(TokenType.EXPR);
        _expr = expr;
    }

    public Object execute(Map context, Writer writer) {
        _expr.evaluate(context);
        return null;
    }

    public Object accept(Visitor visitor) {
        return visitor.visitExpressionStatement(this);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;
import java.util.List;
import java.io.Writer;
import java.io.IOException;

public class ForeachStatement extends Statement {
    private VariableExpression _loopvar;
    private Expression _list;
    private Statement _body;

    public ForeachStatement(VariableExpression loopvar, Expression list, Statement body) {
        super(TokenType.FOREACH);
        _loopvar = loopvar;
        _list    = list;
        _body    = body;
    }

    public Object execute(Map context, Writer writer) throws IOException {
        Object listval = _list.evaluate(context);
        Object[] array = null;
        if (listval instanceof List) {
            array = ((List)listval).toArray();
        } else if (listval.getClass().isArray()) {
            array = (Object[])listval;
        } else {
            throw new SemanticException("List or Array required in foreach-statement.");
        }
        String loopvar_name = _loopvar.getName();
        for (int i = 0; i < array.length; i++) {
            context.put(loopvar_name, array[i]);
            _body.execute(context, writer);
        }
        return null;
    }

    public Object accept(Visitor visitor) {
        return visitor.visitForeachStatement(this);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;
import java.io.Writer;
import java.io.IOException;

public class WhileStatement extends Statement {
    private Expression _condition;
    private Statement _body;
    public static int MaxCount = 10000;

    public WhileStatement(Expression condition, Statement body) {
        super(TokenType.WHILE);
        _condition = condition;
        _body = body;
    }

    public Object execute(Map context, Writer writer) throws IOException {
        int i = 0;
        while (BooleanExpression.isTrue(_condition.evaluate(context))) {
            if (++i > MaxCount)
                throw new ExecutionException("while-loop may be infinte.");
            _body.execute(context, writer);
        }
        return null;
    }

    public Object accept(Visitor visitor) {
        return visitor.visitWhileStatement(this);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;
import java.io.Writer;
import java.io.IOException;

public class IfStatement extends Statement {
    private Expression _condition;
    private Statement  _then_body;
    private Statement  _else_body;

    public IfStatement(Expression condition, Statement then_body, Statement else_body) {
        super(TokenType.IF);
        _condition = condition;
        _then_body = then_body;
        _else_body = else_body;
    }

    public Object execute(Map context, Writer writer) throws IOException {
        Object val = _condition.evaluate(context);
        if (val != null && !val.equals(Boolean.FALSE)) {
            _then_body.execute(context, writer);
        } else if (_else_body != null) {
            _else_body.execute(context, writer);
        }
        return null;
    }

    public Object accept(Visitor visitor) {
        return visitor.visitIfStatement(this);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;
import java.io.Writer;
import java.io.IOException;

public class ElementStatement extends Statement {
    private Statement _plogic;
    public ElementStatement(Statement plogic) {
        super(TokenType.ELEMENT);
        _plogic = plogic;
    }
    public Object execute(Map context, Writer writer) {
        return null;
    }
    public Object accept(Visitor visitor) {
        return visitor.visitElementStatement(this);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;
import java.io.Writer;
import java.io.IOException;

public class ExpandStatement extends Statement {
    private int _type;
    private String _name;
    public ExpandStatement(int type, String name) {
        super(TokenType.EXPAND);
        _type = type;
        _name = name;
    }
    public ExpandStatement(int type) {
        this(type, null);
    }

    public String getName() { return _name; }
    public int getType() { return _type; }

    public Object execute(Map context, Writer writer) {
        return null;
    }
    public Object accept(Visitor visitor) {
        return visitor.visitExpandStatement(this);
    }
}


// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;
import java.util.HashMap;

public class Scanner {
    private String _code;
    private int    _index;
    private int    _column;
    private int    _linenum;
    private String _filename;
    private char   _ch;

    private int    _token;
    private StringBuffer _value = new StringBuffer();

    public Scanner(String code, String filename) {
        reset(code);
        _filename = filename;

    }
    public Scanner(String code) {
        this(code, null);
    }
    public Scanner() {
        this(null, null);
    }

    public int getLinenum() { return _linenum; }
    public int getColumn()  { return _column; }
    public String getFilename() { return _filename; }
    public void setFilename(String filename) { _filename = filename; }
    public int getToken()   { return _token; }
    public String getValue()   { return _value.toString(); }

    private void _clearValue() {
        _value.delete(0, _value.length());
    }

    public void reset(String code, int linenum) {
        _code    = code;
        _index   = -1;
        _column  = -1;
        _linenum = linenum;
        _token   = -1;
        _clearValue();
        read();
    }

    public void reset(String code) {
        reset(code, 1);
    }

    public char read() {
        _index++;
        _column++;
        if (_index >= _code.length()) {
            _ch = '\0';
            return _ch;
        }
        _ch = _code.charAt(_index);
        if (_ch == '\n') {
            _linenum++;
            _column = -1;         // Aha!
        }
        return _ch;
    }

    protected static Map keywords;
    protected static byte[] _op_table  = new byte[Byte.MAX_VALUE];
    protected static byte[] _op_table2 = new byte[Byte.MAX_VALUE];
    static {
        keywords = new HashMap();
        keywords.put("foreach", new Integer(TokenType.FOREACH));
        keywords.put("in",      new Integer(TokenType.IN));
        keywords.put("while",   new Integer(TokenType.WHILE));
        keywords.put("if",      new Integer(TokenType.IF));
        keywords.put("else",    new Integer(TokenType.ELSE));
        keywords.put("elseif",  new Integer(TokenType.ELSEIF));
        keywords.put("true",    new Integer(TokenType.TRUE));
        keywords.put("false",   new Integer(TokenType.FALSE));
        keywords.put("null",    new Integer(TokenType.NULL));
        keywords.put("empty",   new Integer(TokenType.EMPTY));
        //
        _op_table['+'] = TokenType.ADD;
        _op_table['-'] = TokenType.SUB;
        _op_table['*'] = TokenType.MUL;
        _op_table['/'] = TokenType.DIV;
        _op_table['%'] = TokenType.MOD;
        _op_table['='] = TokenType.ASSIGN;
        _op_table['!'] = TokenType.NOT;
        _op_table['<'] = TokenType.LT;
        _op_table['>'] = TokenType.GT;
        //
        _op_table2['+'] = TokenType.ADD_TO;
        _op_table2['-'] = TokenType.SUB_TO;
        _op_table2['*'] = TokenType.MUL_TO;
        _op_table2['/'] = TokenType.DIV_TO;
        _op_table2['%'] = TokenType.MOD_TO;
        _op_table2['='] = TokenType.EQ;
        _op_table2['!'] = TokenType.NE;
        _op_table2['<'] = TokenType.LE;
        _op_table2['>'] = TokenType.GE;
    }

    public int scan() throws LexicalException {
        // ignore whitespaces
        char ch = _ch;
        while (CharacterUtil.isWhitespace(ch)) {
            ch = read();
        }

        // EOF
        if (ch == '\0')
            return _token = TokenType.EOF;

        // keyword, ture, false, null, name
        if (CharacterUtil.isAlphabet(ch)) {
            //System.out.println("*** debug: _ch = " + _ch + ", _index = " + _index);
            _clearValue();
            _value.append(ch);
            while ((ch = read()) != '\0' && CharacterUtil.isWordLetter(ch)) {
                _value.append(ch);
            }
            Integer keyword = (Integer)keywords.get(_value.toString());
            _token = keyword != null ? keyword.intValue() : TokenType.NAME;
            return _token;
        }

        // integer, float
        if (CharacterUtil.isDigit(ch)) {
            _clearValue();
            _value.append(ch);
            _token = TokenType.INTEGER;
            while (true) {
                while ((ch = read()) != '\0' && CharacterUtil.isDigit(ch)) {
                    _value.append(ch);
                }
                if (CharacterUtil.isAlphabet(ch) || ch == '_') {
                    _value.append(ch);
                    while ((ch = read()) != '\0' && CharacterUtil.isWordLetter(ch)) {
                        _value.append(ch);
                    }
                    String msg = "'" + _value.toString() + "': invalid token.";
                    throw new LexicalException(msg, getFilename(), _linenum, _column);
                }
                if (ch != '.') {
                    break;
                } else if (_token == TokenType.INTEGER) {
                    _token = TokenType.FLOAT;
                    _value.append('.');
                    continue;
                } else {
                    String msg = "'" + _value.toString() + "': invalid float.";
                    throw new LexicalException(msg, getFilename(), _linenum, _column);
                }
            }
            return _token;
        }

        // string literal
        if (ch == '\'' || ch == '"') {
            int start_linenum = _linenum;
            int start_column  = _column;
            _clearValue();
            char quote = ch;
            while ((ch = read()) != '\0' && ch != quote) {
                if (ch == '\\') {
                    switch (quote) {
                      case '\'':
                        if ((ch = read()) != '\'' && ch != '\\') _value.append('\\');
                        break;
                      case '"':
                        ch = read();
                        switch (ch) {
                          case 'n':  ch = '\n';  break;
                          case 't':  ch = '\t';  break;
                          case 'r':  ch = '\r';  break;
                        }
                        break;
                      default:
                        assert false;
                    }
                }
                _value.append(ch);
            }
            if (ch == '\0') {
                String msg = "string literal is not closed by " + (quote == '\'' ? "\"'\"." : "'\"'.");
                throw new LexicalException(msg, getFilename(), start_linenum, start_column);
            }
            read();
            return _token = TokenType.STRING;
        }

        // true, false

        // null

        // comment
        if (ch == '/') {
            ch = read();
            if (ch == '/') {   // line comment
                while ((ch = read()) != '\0' && ch != '\n')
                    ;
                if (ch == '\0')
                    return _token = TokenType.EOF;
                read();
                return scan();
            }
            if (ch == '*') {   // region comment
                int start_linenum = _linenum;
                int start_column  = _column;
                while ((ch = read()) != '\0') {
                    if (ch == '*') {
                        if ((ch = read()) == '/') {
                            read();
                            return scan();
                        }
                    }
                }
                if (ch == '\0') {
                    String msg = "'/*' is not closed by '*/'.";
                    throw new LexicalException(msg, getFilename(), start_linenum, start_column);
                }
                assert false;
            }
            if (ch == '=') {
                read();
                return _token = TokenType.DIV_TO;
            }
            return _token = TokenType.DIV;
        }

        // < <= <%...%> <?...?>
        if (ch == '<') {
            ch = read();
            if (ch == '=') {
                read();
                return _token = TokenType.LE;
            }
            if (ch == '%' || ch == '?') {
                char delim = ch;
                int start_linenum = _linenum;
                int start_column  = _column;
                _clearValue();
                ch = read();
                if (ch == '=') {
                    ch = read();
                    _token = TokenType.RAWEXPR;
                } else {
                    _token = TokenType.RAWSTMT;
                }
                while (ch != '\0') {
                    if (ch == delim) {
                        ch = read();
                        if (ch == '>') break;
                        _value.append('%');
                    }
                    _value.append(ch);
                    ch = read();
                }
                if (ch == '\0') {
                    String stag = "<" + delim + (_token == TokenType.RAWEXPR ? "=" : "");
                    String etag = "" + delim + ">";
                    String msg = "'" + stag + "' is not closed by '" + etag + "'.";
                    throw new LexicalException(msg, getFilename(), start_linenum, start_column);
                }
                read();
                return _token;
            }
            return _token = TokenType.LT;
        }

        // + - * / % = ! < >
        if (ch < 128 && _op_table[ch] != 0) {
            char ch2 = read();
            if (ch2 == '=') {
                read();
                return _token = _op_table2[ch];
            }
            return _token = _op_table[ch];
        }

        // &&, || 
        if (ch == '&' || ch == '|') {
            char ch2 = read();
            if (ch != ch2) {
                String msg = "'" + ch + "': invalid token.";
                throw new LexicalException(msg, getFilename(), _linenum, _column);
            }
            read();
            return _token = ch == '&' ? TokenType.AND : TokenType.OR;
        }

        // [ [:
        
        // ( ) ? : [ ] [:
        
        

        
        return _token;
    }

}

// --------------------------------------------------------------------------------

package __PACKAGE__;

public class CharacterUtil {

    public static boolean isWhitespace(char ch) {
        return Character.isWhitespace(ch);
    }

    public static boolean isAlphabet(char ch) {
        //return Character.isLetter(ch);
        return ('a' <= ch && ch <= 'z') || ('A' <= ch && ch <= 'Z');
    }

    public static boolean isDigit(char ch) {
        return Character.isDigit(ch);
    }

    public static boolean isWordLetter(char ch) {
        return isAlphabet(ch) || isDigit(ch) || ch == '_';
    }

}

// --------------------------------------------------------------------------------

package __PACKAGE__;

public class LexicalException extends SyntaxException {
    public LexicalException(String message, String filename, int linenum, int column) {
        super(message, filename, linenum, column);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

public class SyntaxException extends BaseException {
    private int    _linenum;
    private int    _column;
    private String _filename;

    public SyntaxException(String message, String filename, int linenum, int column) {
        super(message);
        _linenum  = linenum;
        _column   = column;
        _filename = filename;
    }

    public String toString() {
        return super.toString() + "(filename " + _filename + ", line " + _linenum + ", column " + _column + ")";
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;
import java.io.Writer;
import java.io.IOException;

public class ExpressionParser {
    private Scanner _scanner;

    public ExpressionParser(Scanner scanner) {
        _scanner = scanner;
    }

    public Expression parse_expression() {
        return null;
    }
    public Expression parse(String expr_code) throws SyntaxException {
        _scanner.reset(expr_code);
        Expression expr = parse_expression();
        if (_scanner.getToken() != TokenType.EOF) {
            throw new SyntaxException("Expression is not ended.", _scanner.getFilename(), _scanner.getLinenum(), _scanner.getColumn());
        }
        return expr;
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import junit.framework.TestCase;
import java.util.List;
import java.util.Iterator;

public class ScannerTest extends TestCase {


    public Scanner _test(String input, String expected) {
        return _test(input, expected, true);
    }
    
    public Scanner _test(String input, String expected, boolean flag_test) {
        if (! flag_test) return null;
        Scanner scanner = new Scanner(input);
        StringBuffer sbuf = new StringBuffer();
        while (scanner.scan() != TokenType.EOF) {
            sbuf.append(TokenType.tokenName(scanner.getToken()));
            sbuf.append(' ');
            String s = TokenType.inspect(scanner.getToken(), scanner.getValue());
            sbuf.append(s);
            sbuf.append("\n");
        }
        assertEquals(expected, sbuf.toString());
        return scanner;
    }

    public void testScanner0() {  // basic test
        String input = "if while foo";
        String expected = "IF :if\nWHILE :while\nNAME foo\nEOF <<EOF>>\nEOF <<EOF>>\n";
        Scanner scanner = new Scanner(input);
        StringBuffer sbuf = new StringBuffer();
        for (int i = 0; i < 5; i++) {
            scanner.scan();
            sbuf.append(TokenType.tokenName(scanner.getToken()));
            sbuf.append(' ');
            sbuf.append(TokenType.inspect(scanner.getToken(), scanner.getValue()));
            sbuf.append("\n");
        }
        String actual = sbuf.toString();
        assertEquals(expected, actual);
    }

    public void testScanner11() {  // keywords
        String input = "  if while  foreach else\nelseif\t\nin  ";
        String expected = "IF :if\nWHILE :while\nFOREACH :foreach\nELSE :else\nELSEIF :elseif\nIN :in\n";
        _test(input, expected);
        input = "true false null nil empty";
        expected = "TRUE true\nFALSE false\nNULL null\nNAME nil\nEMPTY empty\n";
        _test(input, expected);
    }

    public void testScanner12() {  // integer, float
        String input = "100 3.14";
        String expected = "INTEGER 100\nFLOAT 3.14\n";
        _test(input, expected);
        input = "100abc";
        expected = null;
        try {
            _test(input, expected);
            fail("'100abc': LexicalException expected.");
        } catch (LexicalException ex) {
            // OK
        } catch (Exception ex) {
            fail("'100abc': LexicalException expected.");
        }
        input = "3.14abc";
        expected = null;
        try {
            _test(input, expected);
            fail("'3.14abc': LexicalException expected.");
        } catch (LexicalException ex) {
            // OK
        } catch (Exception ex) {
            fail("'3.14abc': LexicalException expected.");
        }
    }

    public void testScanner13() {   // comment
        String input = "// foo\n123/* // \n*/456";
        String expected = "INTEGER 123\nINTEGER 456\n";
        _test(input, expected);
        input = "/* \n//";
        try {
            _test(input, null);
            fail("LexicalException expected.");
        } catch (LexicalException ex) {
            // OK
        } catch (Exception ex) {
            fail("LexicalException expected but " + ex.getClass().getName() + " throwed.");
        }
    }

    public void testScanner14() {   // 'string'
        String input = "'str1'";
        String expected = "STRING \"str1\"\n";
        _test(input, expected);
        input = "'\\n\\r\\t\\''";
        expected = "STRING \"\\n\\r\\t'\"\n";
        _test(input, expected);
    }

    public void testScanner15() {   // "string"
        String input = "\"str\"";
        String expected = "STRING \"str\"\n";
        _test(input, expected);
        input = "\"\\n\\r\\t\\'\\\"\"";
        expected = "STRING \"\\n\\r\\t'\\\"\"\n";
        _test(input, expected);
    }

    public void testScanner21() {  // alithmetic op
        String input = "+ - * / %";
        String expected = "ADD +\nSUB -\nMUL *\nDIV /\nMOD %\n";
        _test(input, expected);
    }
    
    public void testScanner22() {  // assignment op
        String input = "= += -= *= /= %=";
        String expected = "ASSIGN =\nADD_TO +=\nSUB_TO -=\nMUL_TO *=\nDIV_TO /=\nMOD_TO %=\n";
        _test(input, expected);
    }
    
    public void testScanner23() {  // comparable op
        String input = "== != < <= > >=";
        String expected = "EQ ==\nNE !=\nLT <\nLE <=\nGT >\nGE >=\n";
        _test(input, expected);
    }

}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import junit.framework.TestCase;
import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;

public class ExpressionTest extends TestCase {
    Map _context = new HashMap();
    Expression _expr;

    static boolean flag_exec_default = true;

    public void _testExpr(Object expected) {
        _testExpr(expected, _expr, flag_exec_default);
    }
    public void _testExpr(Object expected, boolean flag_exec) {
        _testExpr(expected, _expr, flag_exec);
    }
    public void _testExpr(Object expected, Expression actual) {
        _testExpr(expected, actual, flag_exec_default);
    }
    public void _testExpr(Object expected, Expression actual, boolean flag_exec) {
        if (flag_exec) {
            assertEquals(expected, actual.evaluate(_context));
        }
    }

    // ---

    public void testStringExpression1() {
        _expr = new StringExpression("foo");
        _testExpr("foo");
    }

    public void testIntegerExpression1() {
        _expr = new IntegerExpression(123);
        _testExpr(new Integer(123));
    }

    public void testFloatExpression1() {
        _expr = new FloatExpression(3.14159f);
        _testExpr(new Float(3.14159));
    }

    public void testTrueExpression1() {
        _expr = new BooleanExpression(true);
        _testExpr(Boolean.TRUE);
    }

    public void testFalseExpression1() {
        _expr = new BooleanExpression(false);
        _testExpr(Boolean.FALSE);
    }

    public void testVariableExpression1() {
        _expr = new VariableExpression("var1");
        _context.put("var1", new Integer(20));
        _testExpr(new Integer(20));
    }

    public void testVariableExpression2() {
        _expr = new VariableExpression("var1");
        _context.put("var1", new String("foo"));
        _testExpr("foo");
    }

    public void testVariableExpression3() {
        _expr = new VariableExpression("var1");
        _context.put("var1", Boolean.FALSE);
        _testExpr(Boolean.FALSE);
    }

    // -----

    Expression _i1 = new IntegerExpression(30);
    Expression _i2 = new IntegerExpression(13);
    public void testArithmeticExpression1() {
        _expr = new ArithmeticExpression(TokenType.ADD, _i1, _i2);
        _testExpr(new Integer(43));
        _expr = new ArithmeticExpression(TokenType.SUB, _i1, _i2);
        _testExpr(new Integer(17));
        _expr = new ArithmeticExpression(TokenType.MUL, _i1, _i2);
        _testExpr(new Integer(390));
        _expr = new ArithmeticExpression(TokenType.DIV, _i1, _i2);
        _testExpr(new Integer(2));
        _expr = new ArithmeticExpression(TokenType.MOD, _i1, _i2);
        _testExpr(new Integer(4));
    }

    Expression _f1 = new FloatExpression(3.5f);
    Expression _f2 = new FloatExpression(2.2f);
    public void testArithmeticExpression2() {
        float f1 = 3.5f;
        float f2 = 2.2f;
        _expr = new ArithmeticExpression(TokenType.ADD, _f1, _f2);
        _testExpr(new Float(f1+f2));
        _expr = new ArithmeticExpression(TokenType.SUB, _f1, _f2);
        _testExpr(new Float(f1-f2));
        _expr = new ArithmeticExpression(TokenType.MUL, _f1, _f2);
        _testExpr(new Float(f1*f2));
        _expr = new ArithmeticExpression(TokenType.DIV, _f1, _f2);
        _testExpr(new Float(f1/f2));
        _expr = new ArithmeticExpression(TokenType.MOD, _f1, _f2);
        _testExpr(new Float(f1%f2));
    }

    Expression _s1 = new StringExpression("Foo");
    Expression _s2 = new StringExpression("Bar");
    public void testConcatenationExpression1() {
        _expr = new ConcatenationExpression(TokenType.CONCAT, _s1, _s2);
        _testExpr(new String("FooBar"));
    }

    public void testAssignmentExpression1() {
        _expr = new AssignmentExpression(TokenType.ASSIGN,
                                         new VariableExpression("var1"),
                                         new StringExpression("foo"));
        _testExpr("foo");
        _expr = new AssignmentExpression(TokenType.ASSIGN,
                                         new VariableExpression("var1"),
                                         new IntegerExpression(10));
        _testExpr(new Integer(10));
        _expr = new AssignmentExpression(TokenType.ASSIGN,
                                         new VariableExpression("var1"),
                                         new FloatExpression(0.5f));
        _testExpr(new Float(0.5f));
    }

    public void testAssignmentExpression2() {
        Expression x = new VariableExpression("x");
        Expression y = new VariableExpression("y");
        Expression n = new IntegerExpression(3);
        _expr = new AssignmentExpression(TokenType.ASSIGN, x, new IntegerExpression(10));
        _testExpr(new Integer(10));
        _expr = new AssignmentExpression(TokenType.ASSIGN, y, new ArithmeticExpression(TokenType.ADD, x, n));
        _testExpr(new Integer(13));
        _expr = new AssignmentExpression(TokenType.ASSIGN, y, new ArithmeticExpression(TokenType.SUB, x, n));
        _testExpr(new Integer(7));
        _expr = new AssignmentExpression(TokenType.ASSIGN, y, new ArithmeticExpression(TokenType.MUL, x, n));
        _testExpr(new Integer(30));
        _expr = new AssignmentExpression(TokenType.ASSIGN, y, new ArithmeticExpression(TokenType.DIV, x, n));
        _testExpr(new Integer(3));
        _expr = new AssignmentExpression(TokenType.ASSIGN, y, new ArithmeticExpression(TokenType.MOD, x, n));
        _testExpr(new Integer(1));
    }

    public void testAssignmentExpression3() {
        Expression x  = new VariableExpression("x");
        Object     v  = new Integer(10);
        Expression n = new IntegerExpression(3);
        _context.put("x", v);
        _expr = new AssignmentExpression(TokenType.ADD_TO, x, n);
        _testExpr(new Integer(13));
        _context.put("x", v);
        _expr = new AssignmentExpression(TokenType.SUB_TO, x, n);
        _testExpr(new Integer(7));
        _context.put("x", v);
        _expr = new AssignmentExpression(TokenType.MUL_TO, x, n);
        _testExpr(new Integer(30));
        _context.put("x", v);
        _expr = new AssignmentExpression(TokenType.DIV_TO, x, n);
        _testExpr(new Integer(3));
        _context.put("x", v);
        _expr = new AssignmentExpression(TokenType.MOD_TO, x, n);
        _testExpr(new Integer(1));
    }

    public void testAssignmentExpression4() {
        Expression x  = new VariableExpression("x");
        Expression s1 = new StringExpression("foo");
        Expression s2 = new StringExpression("bar");
        _expr = new AssignmentExpression(TokenType.ASSIGN, x,
                    new ConcatenationExpression(TokenType.CONCAT, s1, s2));
        _testExpr(new String("foobar"));
        _expr = new AssignmentExpression(TokenType.ASSIGN, x,
                    new ConcatenationExpression(TokenType.CONCAT, x, s1));
        _testExpr(new String("foobarfoo"));
    }

    public void testAssignmentExpression5() {
        Expression x = new VariableExpression("x");
        Object     v = new String("foo");
        Expression s = new StringExpression("bar");
        _context.put("x", v);
        _expr = new AssignmentExpression(TokenType.CONCAT_TO, x, s);
        _testExpr(new String("foobar"));
    }

    public void testRelationalExpression1() {
        Expression x = new VariableExpression("x");
        Expression y = new VariableExpression("y");
        Expression z = new IntegerExpression(0);
        _context.put("x", new Integer(1));
        _context.put("y", new Integer(2));
        _expr = new RelationalExpression(TokenType.EQ, x, new IntegerExpression(1));
        _testExpr(Boolean.TRUE);
        _expr = new RelationalExpression(TokenType.EQ, x, y);
        _testExpr(Boolean.FALSE);
        _expr = new RelationalExpression(TokenType.NE, x, y);
        _testExpr(Boolean.TRUE);
        _expr = new RelationalExpression(TokenType.NE, x, new IntegerExpression(1));
        _testExpr(Boolean.FALSE);
    }

    public void testRelationalExpression2() {
        Expression x = new VariableExpression("x");
        Expression y = new VariableExpression("y");
        Expression z = new IntegerExpression(0);
        _context.put("x", new Integer(1));
        _context.put("y", new Integer(2));
        //
        _expr = new RelationalExpression(TokenType.LT, x, y);
        _testExpr(Boolean.TRUE);
        _expr = new RelationalExpression(TokenType.LT, x, new IntegerExpression(1));
        _testExpr(Boolean.FALSE);
        //
        _expr = new RelationalExpression(TokenType.GT, y, x);
        _testExpr(Boolean.TRUE);
        _expr = new RelationalExpression(TokenType.GT, x, new IntegerExpression(1));
        _testExpr(Boolean.FALSE);
        //
        _expr = new RelationalExpression(TokenType.LE, x, y);
        _testExpr(Boolean.TRUE);
        _expr = new RelationalExpression(TokenType.LE, x, new IntegerExpression(1));
        _testExpr(Boolean.TRUE);
        //
        _expr = new RelationalExpression(TokenType.GE, y, x);
        _testExpr(Boolean.TRUE);
        _expr = new RelationalExpression(TokenType.GE, x, new IntegerExpression(1));
        _testExpr(Boolean.TRUE);
    }

    public void testPostfixExpression1() {	// list[i]
        // list = [ "foo", "bar", "baz" ]
        Expression list = new VariableExpression("list");
        List arraylist = new ArrayList();
        arraylist.add("foo");
        arraylist.add("bar");
        arraylist.add("baz");
        _context.put("list", arraylist);

        // var = list[i];
        Expression i = new VariableExpression("i");
        _expr = new PostfixExpression(TokenType.ARRAY, list, i);
        _context.put("i", new Integer(0));
        _testExpr("foo");
        _context.put("i", new Integer(1));
        _testExpr("bar");
        _context.put("i", new Integer(2));
        _testExpr("baz");
    }

    public void testPostfixExpression2() {	// out of range access
        // list = []
        List arraylist = new ArrayList();
        Expression list = new VariableExpression("list");
        Expression i    = new VariableExpression("i");
        _expr = new PostfixExpression(TokenType.ARRAY, list, i);
        _context.put("list", arraylist);
        _context.put("i", new Integer(0));
        try {
            _testExpr(null);
        } catch (IndexOutOfBoundsException ex) {
            // ok
        }

        arraylist.add("foo");
        _context.put("i", new Integer(2));
        try {
            _testExpr(null);
        } catch (IndexOutOfBoundsException ex) {
            // ok
        }

        arraylist.add(null);
        _context.put("i", new Integer(1));
        _testExpr(null);
    }

    public void testPostfixExpression3() {	// list[0] == null
        List arraylist  = new ArrayList();
        Expression list = new VariableExpression("list");
        Expression i    = new VariableExpression("i");
        _expr = new PostfixExpression(TokenType.ARRAY, list, i);
        _context.put("list", arraylist);
        arraylist.add(null);
        _context.put("i", new Integer(0));
        _testExpr(null);
    }

    public void testPostfixExpression4() {	// hash['key']
        // hash[key]
        Expression hash = new VariableExpression("hash");
        Expression key  = new VariableExpression("key");
        _expr = new PostfixExpression(TokenType.ARRAY, hash, key);

        // { "a" => "AAA", 1 => "one", "two" => 2 }
        Map hashmap = new HashMap();
        hashmap.put("a", "AAA");
        hashmap.put(new Integer(1), "one");
        hashmap.put("two", new Integer(2));
        _context.put("hash", hashmap);

        // hash["a"]
        _context.put("key", "a");
        _testExpr("AAA");
        // hash[1]
        _context.put("key", new Integer(1));
        _testExpr("one");
        // hash["two"]
        _context.put("key", "two");
        _testExpr(new Integer(2));
    }

    public void testPostfixExpression5() {	// hash['key'] is null
        // hash[key]
        Expression hash = new VariableExpression("hash");
        Expression key  = new VariableExpression("key");
        _expr = new PostfixExpression(TokenType.ARRAY, hash, key);

        // { "a" => "AAA" }
        Map hashmap = new HashMap();
        hashmap.put("a", "AAA");
        _context.put("hash", hashmap);

        // hash["xxx"]
        _context.put("key", "xxx");
        _testExpr(null);
        // hash[null]
        _context.put("key", null);
        _testExpr(null);
    }

    public void testPropertyExpression1() {	// obj.property
        _expr = new PropertyExpression(new VariableExpression("t"), "name");
        _context.put("t", new Thread("thread1"));
        _testExpr("thread1");
    }

    public void testLogicalAndExpression1() {
        Expression x = new VariableExpression("x");
        Expression y = new VariableExpression("y");
        Expression z = new IntegerExpression(1);
        _context.put("x", new Integer(1));
        _context.put("y", new Integer(2));
        //
        _expr = new LogicalAndExpression(new RelationalExpression(TokenType.GE, x, z),
                                         new RelationalExpression(TokenType.GT, y, z));
        _testExpr(Boolean.TRUE);
        //
        _expr = new LogicalAndExpression(new RelationalExpression(TokenType.GT, x, z),
                                         new RelationalExpression(TokenType.GT, y, z));
        _testExpr(Boolean.FALSE);
        //
        _expr = new LogicalAndExpression(new RelationalExpression(TokenType.GT, y, z),
                                         new RelationalExpression(TokenType.GT, x, z));
        _testExpr(Boolean.FALSE);
        //
    }

    public void testLogicalOrExpression1() {
        Expression x = new VariableExpression("x");
        Expression y = new VariableExpression("y");
        Expression z = new IntegerExpression(1);
        _context.put("x", new Integer(1));
        _context.put("y", new Integer(2));
        //
        _expr = new LogicalOrExpression(new RelationalExpression(TokenType.GT, x, z),
                                         new RelationalExpression(TokenType.GT, y, z));
        _testExpr(Boolean.TRUE);
        //
        _expr = new LogicalOrExpression(new RelationalExpression(TokenType.GT, y, z),
                                         new RelationalExpression(TokenType.GT, x, z));
        _testExpr(Boolean.TRUE);
        //
        _expr = new LogicalOrExpression(new RelationalExpression(TokenType.LE, y, z),
                                         new RelationalExpression(TokenType.LT, x, z));
        _testExpr(Boolean.FALSE);
        //
    }

    public void testConditionalExpression1() {
        Expression x = new VariableExpression("x");
        Expression y = new VariableExpression("y");
        Expression z = new IntegerExpression(0);
        _context.put("x", new Integer(1));
        _context.put("y", new Integer(2));
        //
        Expression cond;
        cond = new RelationalExpression(TokenType.GT, x, y);
        _expr = new ConditionalExpression(cond, x, y);
        _testExpr(new Integer(2));
        //
        cond = new RelationalExpression(TokenType.LT, x, y);
        _expr = new AssignmentExpression(TokenType.ASSIGN, y, new ConditionalExpression(cond, x, y));
        _testExpr(new Integer(1));
    }

    // -----

    public static void main(String[] args) {
       junit.textui.TestRunner.run(ExpressionTest.class);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import junit.framework.TestCase;
import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;
import java.io.Writer;
import java.io.StringWriter;
import java.io.IOException;

public class StatementTest extends TestCase {
    private Map _context = new HashMap();
    private Statement _stmt;

    public void _testPrint(String expected) {
        _testPrint(expected, _stmt);
    }

    public void _testPrint(String expected, Statement stmt) {
        try {
            StringWriter writer = new StringWriter();
            stmt.execute(_context, writer);
            String actual = writer.toString();
            assertEquals(expected, actual);
        }
        catch (IOException ex) {
            ex.printStackTrace();
        }
    }

    public void _testInspect(String expected) {
        _testInspect(expected, _stmt);
    }

    public void _testInspect(String expected, Statement stmt) {
        assertEquals(expected, stmt._inspect());
    }

    public void testPrintStatement1() {  // literal
        Expression[] arglist = {
            new IntegerExpression(123),
            new StringExpression("foo"),
            new FloatExpression(0.4f),
            new BooleanExpression(true),
            new BooleanExpression(false),
            new NullExpression(),
        };
        Statement stmt = new PrintStatement(arglist);
        _testPrint("123foo0.4truefalse", stmt);
    }

    public void testPrintStatement2() {  // variable
        Expression[] arglist = {
            new VariableExpression("x"),
            new VariableExpression("y"),
        };
        _context.put("x", new String("foo"));
        _context.put("y", new Integer(123));
        Statement stmt = new PrintStatement(arglist);
        _testPrint("foo123", stmt);
    }

    public void testPrintStatement3() {  // null value
        Expression[] arglist = {
            new VariableExpression("x"),
            new VariableExpression("y"),
        };
        _context.put("x", new String("foo"));
        //_context.put("y", new Integer(123));
        Statement stmt = new PrintStatement(arglist);
        _testPrint("foo", stmt);
    }

    public void testPrintStatement4() {  // expression
        Expression x = new VariableExpression("x");
        Expression y = new VariableExpression("y");
        _context.put("x", new Integer(20));
        _context.put("y", new Integer(5));
        Expression[] arglist = {
            new ArithmeticExpression(TokenType.SUB,
                                     x,
                                     new ArithmeticExpression(TokenType.MUL,
                                                              new IntegerExpression(2),
                                                              y)),
            new ConcatenationExpression(TokenType.CONCAT,
                                        new StringExpression("foo"),
                                        new StringExpression("bar")),
        };
        Statement stmt = new PrintStatement(arglist);
        _testPrint("10foobar", stmt);
    }

    public void testExpressinStatement1() { // x = y = 100
        Expression expr;
        expr = new AssignmentExpression(TokenType.ASSIGN,
                                        new VariableExpression("x"),
                                        new AssignmentExpression(TokenType.ASSIGN,
                                                                 new VariableExpression("y"),
                                                                 new IntegerExpression(100)));
        Statement stmt = new ExpressionStatement(expr);
        try {
            stmt.execute(_context, null);
        } catch (IOException ex) {
            ex.printStackTrace();
        }
        assertEquals(_context.get("x"), new Integer(100));
        assertEquals(_context.get("y"), new Integer(100));
    }

    public void testBlockStatement1() { // { x = 10; x += 1; print(x); }
        Expression x = new VariableExpression("x");
        Expression v = new IntegerExpression(10);
        Expression d = new IntegerExpression(1);
        Expression expr1 = new AssignmentExpression(TokenType.ASSIGN, x, v);
        Expression expr2 = new AssignmentExpression(TokenType.ADD_TO, x, d);
        Expression[] arglist = { x };
        Statement[] stmts = {
            new ExpressionStatement(expr1),
            new ExpressionStatement(expr2),
            new PrintStatement(arglist),
        };
        Statement stmt = new BlockStatement(stmts);
        _testPrint("11", stmt);
        assertEquals(_context.get("x"), new Integer(11));
    }

    public void testForeachStatement1() {  // foreach(item in list) { print "item = ", item, "\n"; }
        // list = [ "foo", 123, "list" ]
        List list = new ArrayList();
        list.add("foo");
        list.add(new Integer(123));
        list.add("bar");
        _context.put("list", list);

        // print "item = ", item, "\n"
        Expression[] args = {
            new StringExpression("item = "),
            new VariableExpression("item"),
            new StringExpression("\n"),
        };
        Statement[] stmts = {
            new PrintStatement(args),
        };

        // foreach(...) { ... }
        Statement block = new BlockStatement(stmts);
        Statement stmt = new ForeachStatement(new VariableExpression("item"),
                                              new VariableExpression("list"),
                                              block);

        // test
        StringBuffer sb = new StringBuffer();
        sb.append("item = foo\n");
        sb.append("item = 123\n");
        sb.append("item = bar\n");
        _testPrint(sb.toString(), stmt);
    }


    public void testWhileStatement1() {  // while (...) { ... }
        // i = 5;
        Expression i = new VariableExpression("i");
        _context.put("i", new Integer(5));

        // i > 0
        Expression condition = new RelationalExpression(TokenType.GT, i, new IntegerExpression(0));

        // i -= 1; print i;
        Expression assign = new AssignmentExpression(TokenType.SUB_TO, i, new IntegerExpression(1));
        Expression[] args = { new VariableExpression("i"), new StringExpression(","), };
        Statement[] stmts = {
            new ExpressionStatement(assign),
            new PrintStatement(args),
        };

        // while (...) { ... }
        Statement block = new BlockStatement(stmts);
        Statement stmt = new WhileStatement(condition, block);

        // test
        String expected = "4,3,2,1,0,";
        _testPrint(expected, stmt);
    }

    public void testIfStatement1() {
        Expression condition1 = new RelationalExpression(TokenType.EQ,
                                                         new StringExpression("foo"),
                                                         new StringExpression("foo"));
        Expression condition2 = new RelationalExpression(TokenType.EQ,
                                                         new StringExpression("foo"),
                                                         new StringExpression("bar"));
        Expression[] args1 = { new StringExpression("Yes"), };
        Expression[] args2 = { new StringExpression("No"), };
        Statement then_body = new PrintStatement(args1);
        Statement else_body = new PrintStatement(args2);
        Statement stmt;
        stmt = new IfStatement(condition1, then_body, null);
        _testPrint("Yes", stmt);
        stmt = new IfStatement(condition2, then_body, null);
        _testPrint("", stmt);
        stmt = new IfStatement(condition1, then_body, else_body);
        _testPrint("Yes", stmt);
        stmt = new IfStatement(condition2, then_body, else_body);
        _testPrint("No", stmt);
    }

    // -----

    public static void main(String[] args) {
       junit.textui.TestRunner.run(StatementTest.class);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import junit.framework.TestCase;
import junit.framework.TestSuite;

public class KwartzTest extends TestCase {
    public static void main(String[] args) {
        TestSuite suite = new TestSuite();
        suite.addTest(new TestSuite(ExpressionTest.class));
        suite.addTest(new TestSuite(StatementTest.class));
        suite.addTest(new TestSuite(ScannerTest.class));
        junit.textui.TestRunner.run(suite);
    }
}

// ================================================================================
