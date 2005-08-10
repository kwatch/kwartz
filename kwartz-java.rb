#/usr/bin/ruby

###
### usage: ruby kwartz-java.java
###
### $Rev$
###

SRC_ROOT   = 'src/java'
TEST_ROOT  = 'src/test'
PACKAGE = 'com.kuwata_lab.kwartz'

require 'fileutils'
FileUtils.mkdir_p(SRC_ROOT)  unless test(?d, SRC_ROOT)
FileUtils.mkdir_p(TEST_ROOT) unless test(?d, TEST_ROOT)

def expand_heredoc(str)
   flag = false
   s = ""
   terminator = nil
   head = tail = word = indent = nil
   heredoc = nil
   lines = nil
   str.each_line do |line|
      if line =~ /<<<?'(\w+)'/
         head, word, tail = $`, $1, $'                     #'
         terminator = Regexp.compile("^(\\s*)#{word}$")
         flag = true
         indent = " " * head.length
         s << head << '""' << "\n"
         lines = []
      elsif line =~ terminator
         flag = false
         space = $1
         lines.each do |line|
            line.gsub!(/^#{space}/, '')  if space && !space.empty?
            line.gsub!(/\\/, '\\\\\\\\')
            line.gsub!(/\"/, '\\\\"')
            line.gsub!(/\n/, '\\\\n')
            line.gsub!(/\r/, '\\\\r')
            line.gsub!(/\t/, '\\\\t')
            s << "#{indent}+ \"#{line}\"\n"
         end
         s << indent << tail
      else
         if flag
            lines << line
         else
            s << line
         end
      end
   end
   return s
end


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
        if line =~ /\A(public|protected|private|class|abstract)\s+.*?([A-Z]\w+).*\{/
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

      if klass =~ /Test$/
         code = expand_heredoc(code)
      end

      filename = "#{path}/#{klass}.java"
      File.open(filename, 'w') do |f|
         f.write(header.gsub(/__CLASS__/, klass).gsub(/__PACKAGE__/, PACKAGE))
         f.write(code.gsub(/__PACKAGE__/, PACKAGE))
      end
   end
end




###
###
###

properties = <<'END'
##
## $Release$
##
## $Copyright$
##

kwartz.escape            = false
kwartz.newline           = \n
kwartz.indent            = '  '
kwartz.localvar_prefix   = _
kwartz.globalvar_prefix  = _
kwartz.lang              =
kwartz.odd               = 'odd'
kwartz.even              = 'even'
kwartz.dattr             = kw:d
kwartz.noend             = input, br, meta, img, hr
kwartz.defun.class       =
kwartz.defun.function    =
kwartz.charset           =
#kwartz.embed_pattern     =
kwartz.incdir            = .
##
kwartz.macro.C                = com.kuwata_lab.kwartz.CheckedMacro
kwartz.macro.S                = com.kuwata_lab.kwartz.SelectedMacro
kwartz.macro.D                = com.kuwata_lab.kwartz.DisabledMacro
##
kwartz.function.E             = com.kuwata_lab.kwartz.EscapeXmlFunction
kwartz.function.X             = com.kuwata_lab.kwartz.AsIsFunction
kwartz.function.escape_xml    = com.kuwata_lab.kwartz.EscapeXmlFunction
kwartz.function.escape_url    = com.kuwata_lab.kwartz.EscapeUrlFunction
kwartz.function.escape_sql    = com.kuwata_lab.kwartz.EscapeSqlFunction
kwartz.function.str_length    = com.kuwata_lab.kwartz.StringLengthFunction
kwartz.function.str_index     = com.kuwata_lab.kwartz.StringIndexFunction
kwartz.function.str_linebreak = com.kuwata_lab.kwartz.StringLinebreakFunction
kwartz.function.str_replace   = com.kuwata_lab.kwartz.StringReplaceFunction
kwartz.function.str_tolower   = com.kuwata_lab.kwartz.StringToLowerFunction
kwartz.function.str_toupper   = com.kuwata_lab.kwartz.StringToUpperFunction
kwartz.function.str_trim      = com.kuwata_lab.kwartz.StringTrimFunction
kwartz.function.str_empty     = com.kuwata_lab.kwartz.StringEmptyFunction
kwartz.function.list_new      = com.kuwata_lab.kwartz.ListNewFunction
kwartz.function.list_length   = com.kuwata_lab.kwartz.ListLengthFunction
kwartz.function.list_empty    = com.kuwata_lab.kwartz.ListEmptyFunction
kwartz.function.list_add      = com.kuwata_lab.kwartz.ListAddFunction
kwartz.function.hash_new      = com.kuwata_lab.kwartz.HashNewFunction
kwartz.function.hash_length   = com.kuwata_lab.kwartz.HashLengthFunction
kwartz.function.hash_empty    = com.kuwata_lab.kwartz.HashEmptyFunction
kwartz.function.hash_keys     = com.kuwata_lab.kwartz.HashKeysFunction
END

path = SRC_ROOT + '/' + PACKAGE.gsub(/\./, '/')
filename = "#{path}/kwartz.properties"
File.open(filename, 'w') { |f| f.write(properties) }



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
DOUBLE		<<double>>
VARIABLE	<<variable>>
TRUE		true
FALSE		false
NULL		null
NAME		<<name>>

// empty, not empty
EMPTY		empty
NOTEMPTY	notempty

// array, hash
ARRAY		[]
HASH		[:]
L_BRACKET	[
R_BRACKET	]
L_BRACKETCOLON	[:

// function, method, property
FUNCTION	<<function>>
METHOD		.()
PROPERTY	.

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

// unary op
PLUS		+.
MINUS		-.

// statement
BLOCK		:block
PRINT		:print
EXPR		:expr
FOREACH		:foreach
IN		:in
WHILE		:while
IF		:if
ELSEIF		:elseif
ELSE		:else
EMPTYSTMT	:empty_stmt

// symbols
COLON		:
SEMICOLON	;
L_PAREN		(
R_PAREN		)
L_CURLY		{
R_CURLY		}
CONDITIONAL	?:
PERIOD		.
COMMA		,

// expand
EXPAND		@
//STAG		@stag
//ETAG		@etag
//CONT		@cont
//ELEMENT		@element
//CONTENT		@content

// raw expression and raw statement
RAWEXPR		<%= %>
RAWSTMT		<% %>

// element
SHARP		#
ENTRY		#
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
          case TokenType.DOUBLE:
            return value;
          case TokenType.VARIABLE:
            return value;
          case TokenType.NAME:
            return value;
          case TokenType.RAWEXPR:
            return "<" + "%=" + value + "%" + ">";
          case TokenType.RAWSTMT:
            return "<" + "%" + value + "%" + ">";
          case TokenType.EXPAND:
            return "@" + value;
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
              case '\\':  sb.append("\\\\");  break;
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
 *  @copyright $Copyright$
 *  @release $Release$
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

import java.io.InputStream;
import java.io.FileInputStream;
import java.io.Reader;
import java.io.InputStreamReader;
import java.io.IOException;

public class Utility {
    public static String capitalize(String str) {
        return Character.toUpperCase(str.charAt(0)) + str.substring(1);
    }

    public static String inspectString(String s) {
        return inspectString(s, false);
    }

    public static String inspectString(String s, boolean flag_escape_only) {
        if (s == null) return null;
        StringBuffer sb = new StringBuffer();
        if (! flag_escape_only) sb.append('"');
        for (int i = 0; i < s.length(); i++) {
            char ch = s.charAt(i);
            switch (ch) {
              case '\n':  sb.append("\\n");   break;
              case '\r':  sb.append("\\r");   break;
              case '\t':  sb.append("\\t");   break;
              case '\\':  sb.append("\\\\");  break;
              case '"':   sb.append("\\\"");  break;
              default:
                sb.append(ch);
            }
        }
        if (! flag_escape_only) sb.append('"');
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


    public static String readFile(String filename) throws IOException {
        String charset = System.getProperty("file.encoding");
        return Utility.readFile(filename, charset);
    }

    public static String readFile(String filename, String charset) throws IOException {
        if (filename == null)
            return null;
        if (charset == null) {
            charset = System.getProperty("file.encoding");
        }
        InputStream stream = null;
        Reader reader = null;
        try {
            stream = new FileInputStream(filename);
            reader = new InputStreamReader(stream, charset);
            char[] cbuf = new char[512];
            StringBuffer sb = new StringBuffer();
            int len;
            while ((len = reader.read(cbuf, 0, cbuf.length)) >= 0) {
                sb.append(cbuf, 0, len);
            }
            return sb.toString();
        } finally {
            if (reader != null) reader.close();
            if (stream != null) stream.close();
        }
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
    abstract public Object accept(NodeVisitor visitor);

    public StringBuffer _inspect(int level, StringBuffer sb) {
        for (int i = 0; i < level; i++) sb.append("  ");
        sb.append(TokenType.tokenText(_token));
        sb.append("\n");
        return sb;
    }
    public StringBuffer _inspect() {
        return _inspect(0, new StringBuffer());
    }
}

// ================================================================================

package __PACKAGE__;

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

//--------------------------------------------------------------------------------

//package __PACKAGE__;
//
//public class BaseExpressionVisitor implements ExpressionVisitor {
////    public final Object visit(Expression expr) {
////        return expr.accept(this);
////    }
//    //
//    public Object visitExpression(Expression expr) {
//        return expr.accept(this);
//    }
//    //
//    public Object visitUnaryExpression(UnaryExpression expr)                 { return visitExpression(expr); }
//    public Object visitBinaryExpression(BinaryExpression expr)               { return visitExpression(expr); }
//    public Object visitArithmeticExpression(ArithmeticExpression expr)       { return visitExpression(expr); }
//    public Object visitConcatenationExpression(ConcatenationExpression expr) { return visitExpression(expr); }
//    public Object visitRelationalExpression(RelationalExpression expr)       { return visitExpression(expr); }
//    public Object visitAssignmentExpression(AssignmentExpression expr)       { return visitExpression(expr); }
//    public Object visitIndexExpression(IndexExpression expr)                 { return visitExpression(expr); }
//    public Object visitPropertyExpression(PropertyExpression expr)           { return visitExpression(expr); }
//    public Object visitMethodExpression(MethodExpression expr)               { return visitExpression(expr); }
//    public Object visitLogicalAndExpression(LogicalAndExpression expr)       { return visitExpression(expr); }
//    public Object visitLogicalOrExpression(LogicalOrExpression expr)         { return visitExpression(expr); }
//    public Object visitConditionalExpression(ConditionalExpression expr)     { return visitExpression(expr); }
//    public Object visitEmptyExpression(EmptyExpression expr)                 { return visitExpression(expr); }
//    public Object visitFunctionExpression(FunctionExpression expr)           { return visitExpression(expr); }
//    //
//    public Object visitLiteralExpression(LiteralExpression expr)             { return visitExpression(expr); }
//    public Object visitStringExpression(StringExpression expr)               { return visitExpression(expr); }
//    public Object visitIntegerExpression(IntegerExpression expr)             { return visitExpression(expr); }
//    public Object visitDoubleExpression(DoubleExpression expr)               { return visitExpression(expr); }
//    public Object visitVariableExpression(VariableExpression expr)           { return visitExpression(expr); }
//    public Object visitBooleanExpression(BooleanExpression expr)             { return visitExpression(expr); }
//    public Object visitNullExpression(NullExpression expr)                   { return visitExpression(expr); }
//    public Object visitRawcodeExpression(RawcodeExpression expr)             { return visitExpression(expr); }
//    //
//}

// --------------------------------------------------------------------------------

package __PACKAGE__;

public interface StatementVisitor {
//    public final Object visit(Node node);
    //
    public Object visitStatement(Statement stmt);
    //
    public Object visitBlockStatement(BlockStatement stmt)                   ;
    public Object visitPrintStatement(PrintStatement stmt)                   ;
    public Object visitExpressionStatement(ExpressionStatement stmt)         ;
    public Object visitForeachStatement(ForeachStatement stmt)               ;
    public Object visitWhileStatement(WhileStatement stmt)                   ;
    public Object visitIfStatement(IfStatement stmt)                         ;
    public Object visitElementStatement(ElementStatement stmt)               ;
    public Object visitExpandStatement(ExpandStatement stmt)                 ;
    public Object visitRawcodeStatement(RawcodeStatement stmt)               ;
    public Object visitEmptyStatement(EmptyStatement stmt)                   ;
}

// --------------------------------------------------------------------------------

//package __PACKAGE__;
//
//public class BaseStatementVisitor implements StatementVisitor {
////    public final Object visit(Node node) {
////        return node.accept(this);
////    }
//
//    //
//    public Object visitStatement(Statement stmt)   {
//        return stmt.accept(this);
//    }
//    //
//    public Object visitBlockStatement(BlockStatement stmt)                   { return visitStatement(stmt); }
//    public Object visitPrintStatement(PrintStatement stmt)                   { return visitStatement(stmt); }
//    public Object visitExpressionStatement(ExpressionStatement stmt)         { return visitStatement(stmt); }
//    public Object visitForeachStatement(ForeachStatement stmt)               { return visitStatement(stmt); }
//    public Object visitWhileStatement(WhileStatement stmt)                   { return visitStatement(stmt); }
//    public Object visitIfStatement(IfStatement stmt)                         { return visitStatement(stmt); }
//    public Object visitElementStatement(ElementStatement stmt)               { return visitStatement(stmt); }
//    public Object visitExpandStatement(ExpandStatement stmt)                 { return visitStatement(stmt); }
//    public Object visitRawcodeStatement(RawcodeStatement stmt)               { return visitStatement(stmt); }
//    public Object visitEmptyStatement(EmptyStatement stmt)                   { return visitStatement(stmt); }
//}

// --------------------------------------------------------------------------------

package __PACKAGE__;

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

// ================================================================================

package __PACKAGE__;

abstract public class Expression extends Node {
    public Expression(int token) {
        super(token);
    }

    public Object accept(NodeVisitor visitor) {
        return visitor.visitExpression(this);
    }
    public Object accept(ExpressionVisitor visitor) {
        if (1 == 1) throw new BaseException("*** debug ***");
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
    public Object accept(ExpressionVisitor visitor) {
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

public class UnaryExpression extends Expression {
    protected Expression _factor;

    public UnaryExpression(int token, Expression factor) {
        super(token);
        _factor = factor;
    }

    public Expression getFactor() { return _factor; }

    /*
    public Object evaluate(Map context, Visitor executer) {
        executer.executeUnaryExpression(context, _factor);
    }
     */

    public Object accept(ExpressionVisitor visitor) {
        return visitor.visitUnaryExpression(this);
    }

    public Object evaluate(Map context) {
        Object val = _factor.evaluate(context);
        switch (_token) {
          case TokenType.PLUS:
            if (val instanceof Integer || val instanceof Double) {
                return val;
            } else {
                throw new EvaluationException("unary plus operator should be used with number.");
            }
          case TokenType.MINUS:
            if (val instanceof Integer) {
                return new Integer(((Integer)val).intValue() * -1);
            } else if (val instanceof Double) {
                return new Double(((Double)val).doubleValue() * -1);
            } else {
                throw new EvaluationException("unary plus operator should be used with number.");
            }
          case TokenType.NOT:
            if (val == Boolean.TRUE) {
                return Boolean.FALSE;
            } else if (val == Boolean.FALSE) {
                return Boolean.TRUE;
            } else {
                throw new EvaluationException("unary not operator should be used with boolean.");
            }
        }
        assert false;
        return null;
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        super._inspect(level, sb);
        _factor._inspect(level+1, sb);
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
        if (lvalue == null)
            throw new EvaluationException("lvalue of '" + TokenType.inspect(_token) + "' is null.");
        if (! (lvalue instanceof Integer || lvalue instanceof Double) )
            throw new EvaluationException("required integer or double but got " + lvalue.getClass().getName() + ".");
        Object rvalue = _right.evaluate(context);
        if (rvalue == null)
            throw new EvaluationException("rvalue of '" + TokenType.inspect(_token) + "' is null.");
        if (! (rvalue instanceof Integer || rvalue instanceof Double) )
            throw new EvaluationException("required integer or double but got " + rvalue.getClass().getName() + ".");
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
            double l = lval.doubleValue();
            double r = rval.doubleValue();
            double v = 0;
            switch (_token) {
              case TokenType.ADD:  v = l + r;  break;
              case TokenType.SUB:  v = l - r;  break;
              case TokenType.MUL:  v = l * r;  break;
              case TokenType.DIV:  v = l / r;  break;
              case TokenType.MOD:  v = l % r;  break;
              default:
                assert false;
            }
            return new Double(v);
        }
        //return null;
    }

    public Object accept(ExpressionVisitor visitor) {
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

    public Object accept(ExpressionVisitor visitor) {
        return visitor.visitConcatenationExpression(this);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.List;
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
            Expression expr = ((IndexExpression)_left).getLeft();
            Object obj = expr.evaluate(context);
            expr = ((IndexExpression)_left).getRight();
            Object idx = expr.evaluate(context);
            if (obj instanceof Map) {
                ((Map)obj).put(idx, rvalue);
            } else if (obj instanceof List) {
                if (! (idx instanceof Integer))
                    throw new EvaluationException("index of List object is not an integer.");
                ((List)obj).add(((Integer)idx).intValue(), rvalue);
            } else if (obj.getClass().isArray()) {
                if (! (idx instanceof Integer))
                    throw new EvaluationException("index of array is not an integer.");
                ((Object[])obj)[((Integer)idx).intValue()] = rvalue;
            } else {
                throw new EvaluationException("invalid '[]' operator for non-list,map,nor array.");
            }
            break;
          case TokenType.HASH:
            expr = ((IndexExpression)_left).getLeft();
            obj = expr.evaluate(context);
            expr = ((IndexExpression)_left).getRight();
            idx = expr.evaluate(context);
            if (obj instanceof Map) {
                ((Map)obj).put(idx, rvalue);
            } else {
                throw new EvaluationException("invalid '[:]' operator for non-map object.");
            }
            break;
          default:
            // error
            //throw new SemanticException("invalid assignment: left-value should be varaible, array or hash.");
            throw new EvaluationException("invalid assignment: left-value should be varaible, array or hash.");
        }
        return rvalue;
    }

    public Object accept(ExpressionVisitor visitor) {
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
        //if (lvalue == null)
        //    throw new EvaluationException("lvalue of '" + TokenType.inspect(_token) + "' is null.");
        Object rvalue = _right.evaluate(context);
        //if (rvalue == null)
        //    throw new EvaluationException("rvalue of '" + TokenType.inspect(_token) + "' is null.");
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
        else if (   (lvalue instanceof Integer || lvalue instanceof Double)
                 && (rvalue instanceof Integer || rvalue instanceof Double)) {
            double lval = ((Number)lvalue).doubleValue();
            double rval = ((Number)rvalue).doubleValue();
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
        else if (lvalue == null || rvalue == null) {
            switch (_token) {
              case TokenType.EQ:
                return (lvalue == null && rvalue == null) ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.NE:
                return (lvalue == null && rvalue == null) ? Boolean.FALSE : Boolean.TRUE;
              case TokenType.LT:
              case TokenType.GT:
              case TokenType.LE:
              case TokenType.GE:
                String msg = (lvalue == null ? "lvalue" : "rvalue") + TokenType.inspect(_token) + " is null.";
                throw new EvaluationException(msg);
              default:
                assert false;
            }
        }
        else if ( (_token == TokenType.EQ || _token == TokenType.NE) && (lvalue == null || rvalue == null) ) {
            switch (_token) {
              case TokenType.EQ:
                return (lvalue == null && rvalue == null) ? Boolean.TRUE : Boolean.FALSE;
              case TokenType.NE:
                return (lvalue == null && rvalue == null) ? Boolean.FALSE : Boolean.TRUE;
              default:
                assert false;
            }
        }
        else if (   (lvalue instanceof String || lvalue instanceof Integer || lvalue instanceof Double)
                 && (rvalue instanceof String || rvalue instanceof Integer || rvalue instanceof Double)) {
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
            if (! (lvalue instanceof String || lvalue instanceof Integer || lvalue instanceof Double)) {
                throw new EvaluationException("cannot compare a '" + lvalue.getClass().getName() + "' object.");
            }
            if (! (rvalue instanceof String || rvalue instanceof Integer || rvalue instanceof Double)) {
                throw new EvaluationException("cannot compare a '" + rvalue.getClass().getName() + "' object.");
            }
            assert false;
        }
        return null;
    }

    public Object accept(ExpressionVisitor visitor) {
        return visitor.visitRelationalExpression(this);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;
import java.util.List;

public class IndexExpression extends BinaryExpression {
    public IndexExpression(int token, Expression left, Expression right) {
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
    public Object accept(ExpressionVisitor visitor) {
        return visitor.visitIndexExpression(this);
    }

}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;
import java.util.List;
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

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;
import java.util.List;
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
    public Object accept(ExpressionVisitor visitor) {
        return visitor.visitLogicalAndExpression(this);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;

public class LogicalOrExpression extends BinaryExpression {
    public LogicalOrExpression(Expression left, Expression right) {
        super(TokenType.OR, left, right);
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
    public Object accept(ExpressionVisitor visitor) {
        return visitor.visitLogicalOrExpression(this);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;

public class EmptyExpression extends Expression {
    protected Expression _arithmetic;
    public EmptyExpression(int token, Expression arithmetic) {
        super(token);
        _arithmetic = arithmetic;
    }
    public Expression getArithmetic() { return _arithmetic; }
    public void setArithmetic(Expression arithmetic) { _arithmetic = arithmetic; }

    public Object evaluate(Map context) {
        Object val = _arithmetic.evaluate(context);
        if (_token == TokenType.EMPTY) {
            if (val == null) return Boolean.TRUE;
            if (val instanceof String && val.equals("")) return Boolean.TRUE;
            return Boolean.FALSE;
        } else if (_token == TokenType.NOTEMPTY) {
            if (val == null) return Boolean.FALSE;
            if (val instanceof String && val.equals("")) return Boolean.FALSE;
            return Boolean.TRUE;
        }
        assert false;
        return null;
    }

    public Object accept(ExpressionVisitor visitor) {
        return visitor.visitEmptyExpression(this);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        super._inspect(level, sb);
        _arithmetic._inspect(level+1, sb);
        return sb;
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

    public Object accept(ExpressionVisitor visitor) {
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

    //public Macro(String macroname) {
    //    _name = macroname;
    //}

    public String getName() { return _name; }
    public void setName(String name) { _name = name; }

    abstract public int arity();
    abstract public Expression expand(Expression[] args);

    static Map __instances = new HashMap();
    public static Map instances() { return __instances; }
    public static void register(String name, Macro macro) {
        __instances.put(name, macro);
        macro.setName(name);
    }
    public static Macro getInstance(String name) {
        return (Macro)__instances.get(name);
    }
    public static boolean isRegistered(String name) {
        return __instances.containsKey(name);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

abstract public class FormMacro extends Macro {
    public int arity() { return 1; }

    public Expression expand(Expression[] args) {
        assert args.length == arity();
        Expression left = new StringExpression(getValue());
        Expression right = new StringExpression("");
        return new ConditionalExpression(args[0], left, right);
    }

    abstract protected String getValue();
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

public class CheckedMacro extends FormMacro {
    protected String getValue() { return " checked=\"checked\""; }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

public class SelectedMacro extends FormMacro {
    protected String getValue() { return " selected=\"selected\""; }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

public class DisabledMacro extends FormMacro {
    protected String getValue() { return " disabled=\"disabled\""; }
}

// ================================================================================

package __PACKAGE__;
import java.util.Map;
import java.util.HashMap;

abstract public class Function {
    protected String _name;

    //public Function(String funcname) {
    //    _name = funcname;
    //}

    public String getName() { return _name; }
    public void setName(String name) { _name = name; }

    abstract public Object call(Map context, Expression[] arguments);

    abstract public int arity();

    static Map __instances = new HashMap();
    static Map instances() { return __instances; }
    public static void register(String funcname, Function function) {
        __instances.put(funcname, function);
        function.setName(funcname);
    }
    public static Function getInstance(String funcname) {
        return (Function)__instances.get(funcname);
    }
    public static boolean isRegistered(String funcname) {
        return __instances.containsKey(funcname);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;
import java.util.ArrayList;

public class ListNewFunction extends Function {
    public int arity() { return 0; }

    public Object call(Map context, Expression[] arguments) {
        return new ArrayList();
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;
import java.util.List;

abstract public class ListFunction extends Function {
    public int arity() { return 1; }

    public Object call(Map context, Expression[] arguments) {
        assert arguments.length == 1;
        Object list = arguments[0].evaluate(context);
        if (list == null)  throw new EvaluationException(getName() + "(): argument is null.");
        if (list instanceof List) {
            return perform((List)list);
        }
        if (list.getClass().isArray()) {
            return perform((Object[])list);
        }
        throw new EvaluationException(getName() + "(): argument is not a List nor an Array.");
    }

    abstract protected Object perform(List list);
    abstract protected Object perform(Object[] list);
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.List;

public class ListLengthFunction extends ListFunction {
    protected Object perform(List list) {
        return new Integer(list.size());
    }
    protected Object perform(Object[] list) {
        return new Integer(list.length);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.List;

public class ListEmptyFunction extends ListFunction {
    protected Object perform(List list) {
        return list.size() == 0 ? Boolean.TRUE : Boolean.FALSE;
    }
    protected Object perform(Object[] list) {
        return list.length == 0 ? Boolean.TRUE : Boolean.FALSE;
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;
import java.util.List;

abstract public class ListFunction2 extends Function {
    public int arity() { return 2; }

    public Object call(Map context, Expression[] arguments) {
        assert arguments.length == 2;
        Object list = arguments[0].evaluate(context);
        if (list == null)  throw new EvaluationException(getName() + "(): argument is null.");
        Object val = arguments[1].evaluate(context);
        if (list instanceof List) {
            return perform((List)list, val);
        }
        if (list.getClass().isArray()) {
            return perform((Object[])list, val);
        }
        throw new EvaluationException(getName() + "(): argument is not a List nor an Array.");
    }

    abstract protected Object perform(List list, Object val);
    abstract protected Object perform(Object[] list, Object val);
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.List;

public class ListAddFunction extends ListFunction2 {
    protected Object perform(List list, Object val) {
        list.add(val);
        return list;
    }
    protected Object perform(Object[] list, Object val) {
        throw new EvaluationException(getName() + "(): cannot add value to an array.");
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;
import java.util.HashMap;

public class HashNewFunction extends Function {
    public int arity() { return 0; }

    public Object call(Map context, Expression[] arguments) {
        assert arguments.length == 0;
        return new HashMap();
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;

abstract public class HashFunction extends Function {
    public int arity() { return 1; }

    public Object call(Map context, Expression[] arguments) {
        assert arguments.length == 1;
        Object hash = arguments[0].evaluate(context);
        if (hash == null)  throw new EvaluationException(getName() + "(): argument is null.");
        if (hash instanceof Map) {
            return perform((Map)hash);
        }
        throw new EvaluationException(getName() + "(): argument is not a Map.");
    }

    abstract protected Object perform(Map hash);
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;

public class HashLengthFunction extends HashFunction {
    protected Object perform(Map hash) {
        return new Integer(hash.size());
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;

public class HashEmptyFunction extends HashFunction {
    protected Object perform(Map hash) {
        return hash.size() == 0 ? Boolean.TRUE : Boolean.FALSE;
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;
import java.util.ArrayList;

public class HashKeysFunction extends HashFunction {
    protected Object perform(Map hash) {
        return new ArrayList(hash.keySet());
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;

abstract public class StringFunction extends Function {
    public int arity() { return 1; }

    public Object call(Map context, Expression[] arguments) {
        assert arguments.length == 1;
        Object str = arguments[0].evaluate(context);
        if (str == null)
            throw new EvaluationException(getName() + "(): argument is null.");
        return perform(str.toString());
    }

    abstract protected Object perform(String str);
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

public class StringLengthFunction extends StringFunction {
    protected Object perform(String str) {
        return new Integer(str.length());
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;

public class StringEmptyFunction extends StringFunction {
    protected Object perform(String str) {
        return str.length() == 0 ? Boolean.TRUE : Boolean.FALSE;
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

public class StringToLowerFunction extends StringFunction {
    protected Object perform(String str) {
        return str.toLowerCase();
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

public class StringToUpperFunction extends StringFunction {
    protected Object perform(String str) {
        return str.toUpperCase();
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

public class StringTrimFunction extends StringFunction {
    protected Object perform(String str) {
        return str.trim();
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

public class StringLinebreakFunction extends StringFunction {
    protected Object perform(String str) {
        return str.replaceAll("\\r?\\n", "<br />\\0");
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;

abstract public class StringFunction2 extends Function {
    public int arity() { return 2; }

    public Object call(Map context, Expression[] arguments) {
        assert arguments.length == 2;
        Object str1 = arguments[0].evaluate(context);
        if (str1 == null)
            throw new EvaluationException(getName() + "(): first argument is null.");
        Object str2 = arguments[1].evaluate(context);
        if (str2 == null)
            throw new EvaluationException(getName() + "(): second argument is null.");
        return perform(str1.toString(), str2.toString());
    }

    abstract protected Object perform(String str1, String str2);
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

public class StringIndexFunction extends StringFunction2 {
    public Object perform(String str1, String str2) {
        int index = str1.indexOf(str2);
        return new Integer(index);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;

abstract public class StringFunctionN extends Function {
    //public int arity() { return N; }

    public Object call(Map context, Expression[] arguments) {
        int len = arity();
        if (len != arguments.length)
            throw new EvaluationException(getName() + "(): number of arguments is expected " + len + " but got " + arguments.length + ".");
        String[] vals = new String[len];
        for (int i = 0; i < len; i++) {
            Expression expr = arguments[0];
            Object val = expr.evaluate(context);
            if (val == null)
                throw new EvaluationException(getName() + "(): argument" + i + " is null.");
            if (! (val instanceof String))
                throw new EvaluationException(getName() + "(): argument" + i + " is not a string.");
            vals[i] = (String)val;
        }
        return perform(vals);
    }

    abstract protected Object perform(String[] args);
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

public class StringReplaceFunction extends StringFunctionN {
    public int arity() { return 3; }

    protected Object perform(String[] args) {
        assert args.length == arity();
        return args[0].replaceAll(args[1], args[2]);
        //return args[0].replaceFirst(args[1], args[2]);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;

abstract public class EscapeFunction extends Function {
    public int arity() { return 1; }

    public Object call(Map context, Expression[] arguments) {
        assert arguments.length == 1;
        Expression expr = arguments[0];
        Object val = expr.evaluate(context);
        return perform(val);
    }

    abstract protected Object perform(Object arg);
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

public class EscapeXmlFunction extends EscapeFunction {
    protected Object perform(Object arg) {
        //if (arg == null) return null;   // or return "";
        //String s = arg.toString();
        //s = s.replaceAll("&",  "&amp;");
        //s = s.replaceAll("<",  "&lt;");
        //s = s.replaceAll(">",  "&gt;");
        //s = s.replaceAll("\"", "&quot;");
        //return s;
        // ----------
        if (arg == null) return null;   // or return "";
        String s = arg.toString();
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < s.length(); i++) {
            char ch = s.charAt(i);
            switch (ch) {
              case '<':   sb.append("&lt;");    break;
              case '>':   sb.append("&gt;");    break;
              case '&':   sb.append("&amp;");   break;
              case '"':   sb.append("&quot;");  break;
              default:    sb.append(ch);
            }
        }
        return sb.toString();
        // ----------
        //if (arg == null) return null;  // or return "";
        //String s = arg.toString();
        //StringBuffer sb = null;
        //for (int i = 0; i < s.length(); i++) {
        //    char ch = s.charAt(i);
        //    String escaped;
        //    switch (ch) {
        //      case '<':   escaped = "&lt;";   break;
        //      case '>':   escaped = "&gt;";   break;
        //      case '&':   escaped = "&amp";   break;
        //      case '"':   escaped = "&quot";  break;
        //      default:    escaped = null;
        //    }
        //    if (escaped == null) {
        //        if (sb != null) sb.append(ch);
        //    } else {
        //        if (sb == null) {
        //            sb = new StringBuffer();
        //            sb.append(s.substring(0, i));
        //        }
        //        sb.append(escaped);
        //    }
        //}
        //return sb == null ? s : sb.toString();
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

public class AsIsFunction extends EscapeFunction {
    protected Object perform(Object arg) {
        return arg;
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.net.URLEncoder;

public class EscapeUrlFunction extends EscapeFunction {
    protected Object perform(Object arg) {
        if (arg == null) return null;
        String s = arg.toString();
        return URLEncoder.encode(s);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

public class EscapeSqlFunction extends EscapeFunction {
    protected Object perform(Object arg) {
        if (arg == null) return null;
        String s = arg.toString();
        s = s.replaceAll("\\\\", "\\\\\\\\");
        s = s.replaceAll("'", "\\\\'");
        s = s.replaceAll("\"", "\\\\\"");
        return s;
    }
}

// ================================================================================

package __PACKAGE__;
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
        if (! context.containsKey(_name))
            throw new EvaluationException("variable `" + _name + "' is not initalized.");
        return context.get(_name);
    }

    public Object accept(ExpressionVisitor visitor) {
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
    public Object accept(ExpressionVisitor visitor) {
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
    public String getValue() { return _value; }

    public Object evaluate(Map context) {
        return _value;
    }
    public Object accept(ExpressionVisitor visitor) {
        return visitor.visitStringExpression(this);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        for (int i = 0; i < level; i++) sb.append("  ");
        sb.append('"');
        for (int i = 0; i < _value.length(); i++) {
            char ch = _value.charAt(i);
            switch (ch) {
              case '\n':  sb.append("\\n"); break;
              case '\r':  sb.append("\\r"); break;
              case '\t':  sb.append("\\t"); break;
              case '\\':  sb.append("\\\\");  break;
              case '"':   sb.append("\\\"");  break;
              default:    sb.append(ch);
            }
        }
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
    public Object accept(ExpressionVisitor visitor) {
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

public class DoubleExpression extends LiteralExpression {
    private double _value;
    public DoubleExpression(double value) {
        super(TokenType.DOUBLE);
        _value = value;
    }
    public Object evaluate(Map context) {
        return new Double(_value);
    }
    public Object accept(ExpressionVisitor visitor) {
        return visitor.visitDoubleExpression(this);
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
    public Object accept(ExpressionVisitor visitor) {
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
    public Object accept(ExpressionVisitor visitor) {
        return visitor.visitNullExpression(this);
    }
    public StringBuffer _inspect(int level, StringBuffer sb) {
        for (int i = 0; i < level; i++) sb.append("  ");
        sb.append("null\n");
        return sb;
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;

public class RawcodeExpression extends LiteralExpression {
    String _rawcode;
    public RawcodeExpression(String rawcode) {
        super(TokenType.RAWEXPR);
        _rawcode = rawcode;
    }
    public String getRawcode() { return _rawcode; }
    public void setRawcode(String rawcode) { _rawcode = rawcode; }

    public Object evaluate(Map context) {
        throw new EvaluationException("cannot evaluate rawcode expression");
        //return null;
    }
    public Object accept(ExpressionVisitor visitor) {
        return visitor.visitRawcodeExpression(this);
    }
    public StringBuffer _inspect(int level, StringBuffer sb) {
        for (int i = 0; i < level; i++) sb.append("  ");
        sb.append("<" + "%=" + _rawcode + "%" + ">");
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

    public Object accept(NodeVisitor visitor) {
        return accept((StatementVisitor)visitor);
    }

    abstract public Object accept(StatementVisitor visitor);

    abstract public Statement accept(Expander expander, Element elem);
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.List;
import java.util.Map;
import java.io.Writer;
import java.io.IOException;

public class BlockStatement extends Statement {
    private Statement[] _statements;
    public BlockStatement(Statement[] statements) {
        super(TokenType.BLOCK);
        _statements = statements;
    }
    public BlockStatement(List statementList) {
        super(TokenType.BLOCK);
        _statements = new Statement[statementList.size()];
        statementList.toArray(_statements);
    }
    public Statement[] getStatements() { return _statements; }
    public void setStatements(Statement[] statements) { _statements = statements; }

    public Object execute(Map context, Writer writer) throws IOException {
        for (int i = 0; i < _statements.length; i++) {
            _statements[i].execute(context, writer);
        }
        return null;
    }

    public Object accept(StatementVisitor visitor) {
        return visitor.visitBlockStatement(this);
    }

    public Statement accept(Expander expander, Element elem) {
        return expander.expand(this, elem);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        for (int i = 0; i < level; i++) sb.append("  ");
        sb.append(":block\n");
        for (int i = 0; i < _statements.length; i++) {
            _statements[i]._inspect(level + 1, sb);
        }
        return sb;
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

import java.util.List;
import java.util.Map;
import java.io.Writer;
import java.io.IOException;

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

    public Object accept(StatementVisitor visitor) {
        return visitor.visitExpressionStatement(this);
    }

    public Statement accept(Expander expander, Element elem) {
        return expander.expand(this, elem);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        super._inspect(level, sb);
        _expr._inspect(level+1, sb);
        return sb;
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

    public Statement getBodyStatement() { return _body; }
    public void setBodyStatement(Statement stmt) { _body = stmt; }

    public Object execute(Map context, Writer writer) throws IOException {
        Object listval = _list.evaluate(context);
        Object[] array = null;
        if (listval instanceof List) {
            array = ((List)listval).toArray();
        } else if (listval.getClass().isArray()) {
            array = (Object[])listval;
        } else {
            //throw new SemanticException("List or Array required in foreach-statement.");
            throw new EvaluationException("List or Array required in foreach-statement.");
        }
        String loopvar_name = _loopvar.getName();
        for (int i = 0; i < array.length; i++) {
            context.put(loopvar_name, array[i]);
            _body.execute(context, writer);
        }
        return null;
    }

    public Object accept(StatementVisitor visitor) {
        return visitor.visitForeachStatement(this);
    }

    public Statement accept(Expander expander, Element elem) {
        return expander.expand(this, elem);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        super._inspect(level, sb);
        _loopvar._inspect(level+1, sb);
        _list._inspect(level+1, sb);
        _body._inspect(level+1, sb);
        return sb;
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

    public Statement getBodyStatement() { return _body; }
    public void setBodyStatement(Statement stmt) { _body = stmt; }

    public Object execute(Map context, Writer writer) throws IOException {
        int i = 0;
        while (BooleanExpression.isTrue(_condition.evaluate(context))) {
            if (++i > MaxCount)
                throw new ExecutionException("while-loop may be infinte.");
            _body.execute(context, writer);
        }
        return null;
    }

    public Object accept(StatementVisitor visitor) {
        return visitor.visitWhileStatement(this);
    }

    public Statement accept(Expander expander, Element elem) {
        return expander.expand(this, elem);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        super._inspect(level, sb);
        _condition._inspect(level+1, sb);
        _body._inspect(level+1, sb);
        return sb;
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

    public Expression getCondition() { return _condition; }
    public Statement getThenStatement() { return _then_body; }
    public void setThenStatement(Statement stmt) { _then_body = stmt; }
    public Statement getElseStatement() { return _else_body; }
    public void setElseStatement(Statement stmt) { _else_body = stmt; }

    public Object execute(Map context, Writer writer) throws IOException {
        Object val = _condition.evaluate(context);
        if (val != null && !val.equals(Boolean.FALSE)) {
            _then_body.execute(context, writer);
        } else if (_else_body != null) {
            _else_body.execute(context, writer);
        }
        return null;
    }

    public Object accept(StatementVisitor visitor) {
        return visitor.visitIfStatement(this);
    }

    public Statement accept(Expander expander, Element elem) {
        return expander.expand(this, elem);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        super._inspect(level, sb);
        _condition._inspect(level+1, sb);
        _then_body._inspect(level+1, sb);
        if (_else_body != null)
            _else_body._inspect(level+1, sb);
        return sb;
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

import java.util.Map;
import java.io.Writer;

public class ElementStatement extends Statement {
    private Statement _plogic;
    public ElementStatement(Statement plogic) {
        super(TokenType.ENTRY);
        _plogic = plogic;
    }
    public Object execute(Map context, Writer writer) {
        return null;
    }
    public Object accept(StatementVisitor visitor) {
        return visitor.visitElementStatement(this);
    }

    public Statement accept(Expander expander, Element elem) {
        return expander.expand(this, elem);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        super._inspect(level, sb);
        _plogic._inspect(level+1, sb);
        return sb;
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

import java.util.Map;
import java.io.Writer;

public class ExpandStatement extends Statement {

    public static final int STAG    = 1;
    public static final int CONT    = 2;
    public static final int ETAG    = 3;
    public static final int ELEMENT = 4;
    public static final int CONTENT = 5;

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
    public Object accept(StatementVisitor visitor) {
        return visitor.visitExpandStatement(this);
    }

    public Statement accept(Expander expander, Element elem) {
        return expander.expand(this, elem);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        for (int i = 0; i < level; i++) sb.append("  ");
        switch (_type) {
          case ExpandStatement.STAG:
            sb.append("@stag"); break;
          case ExpandStatement.ETAG:
            sb.append("@etag"); break;
          case ExpandStatement.CONT:
            sb.append("@cont"); break;
          case ExpandStatement.ELEMENT:
            sb.append("@element(" + _name + ")");  break;
          case ExpandStatement.CONTENT:
            sb.append("@content(" + _name + ")");  break;
          default:
            assert false;
        }
        sb.append("\n");
        return sb;
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;
import java.io.Writer;

public class RawcodeStatement extends Statement {
    private String _rawcode;
    public RawcodeStatement(String rawcode) {
        super(TokenType.RAWSTMT);
        _rawcode = rawcode;
    }

    public String getRawcode() { return _rawcode; }
    public void setRawcode(String rawcode) { _rawcode = rawcode; }

    public Object execute(Map context, Writer writer) {
        throw new EvaluationException("cannot evaluate rawcode statement.");
        //return null;
    }
    public Object accept(StatementVisitor visitor) {
        return visitor.visitRawcodeStatement(this);
    }

    public Statement accept(Expander expander, Element elem) {
        return expander.expand(this, elem);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        for (int i = 0; i < level; i++) sb.append("  ");
        sb.append("<" + "%=" + _rawcode + "%" + ">");
        return sb;
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;
import java.io.Writer;

public class EmptyStatement extends Statement {
    public EmptyStatement() {
        super(TokenType.EMPTYSTMT);
    }

    public Object execute(Map context, Writer writer) {
        return null;
    }
    public Object accept(StatementVisitor visitor) {
        return visitor.visitEmptyStatement(this);
    }

    public Statement accept(Expander expander, Element elem) {
        return expander.expand(this, elem);
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        return super._inspect(level, sb);
    }
}

// ================================================================================

package __PACKAGE__;
import java.util.Map;
import java.util.HashMap;
import java.util.Properties;

public class Scanner {
    private String _code;
    private int    _index;
    private int    _column;
    private int    _linenum;
    private String _filename;
    private char   _ch;
    private Properties _props;

    private int    _token;
    private StringBuffer _value = new StringBuffer();


    public Scanner() {
        this("", null, new Properties(Configuration.defaults));
    }
    public Scanner(Properties props) {
        this("", null, props);
    }
    public Scanner(String code) {
        this(code, null, new Properties(Configuration.defaults));
    }
    public Scanner(String code, Properties props) {
        this(code, null, props);
    }
    public Scanner(String code, String filename) {
        this(code, filename, new Properties(Configuration.defaults));
    }
    public Scanner(String code, String filename, Properties props) {
        _props = props;
        reset(code);
        _filename = filename;
    }

    public Properties getProperties() { return _props; }
    public String getProperty(String key) { return _props.getProperty(key); }
    //public String setProperty(String key, String value) { _props.setProperty(key, value); }

    public int getLinenum() { return _linenum; }
    public int getColumn()  { return _column; }
    public String getFilename() { return _filename; }
    public void setFilename(String filename) { _filename = filename; }
    public int getToken()   { return _token; }
    public String getValue()   { return _value.toString(); }
    //public String getCode() { return _code; }

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
    protected static byte[] _op_table1  = new byte[Byte.MAX_VALUE];
    protected static byte[] _op_table2 = new byte[Byte.MAX_VALUE];
    protected static byte[] _op_table3 = new byte[Byte.MAX_VALUE];
    static {
        keywords = new HashMap();
        keywords.put("print",   new Integer(TokenType.PRINT));
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
        _op_table1['+'] = TokenType.ADD;
        _op_table1['-'] = TokenType.SUB;
        _op_table1['*'] = TokenType.MUL;
        _op_table1['/'] = TokenType.DIV;
        _op_table1['%'] = TokenType.MOD;
        _op_table1['='] = TokenType.ASSIGN;
        _op_table1['!'] = TokenType.NOT;
        _op_table1['<'] = TokenType.LT;
        _op_table1['>'] = TokenType.GT;
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
        //
        _op_table3['('] = TokenType.L_PAREN;
        _op_table3[')'] = TokenType.R_PAREN;
        _op_table3['{'] = TokenType.L_CURLY;
        _op_table3['}'] = TokenType.R_CURLY;
        _op_table3[']'] = TokenType.R_BRACKET;
        _op_table3['?'] = TokenType.CONDITIONAL;
        _op_table3[':'] = TokenType.COLON;
        _op_table3[';'] = TokenType.SEMICOLON;
        _op_table3[','] = TokenType.COMMA;
        _op_table3['#'] = TokenType.SHARP;
    }

    public int scan() throws LexicalException {
        String msg;
        char ch, ch2;
        int start_linenum, start_column;

        // ignore whitespaces
        ch = _ch;
        while (CharacterUtil.isWhitespace(ch)) {
            ch = read();
        }

        // EOF
        if (ch == '\0')
            return _token = TokenType.EOF;

        // keyword, ture, false, null, name
        if (CharacterUtil.isAlphabet(ch)) {
            _clearValue();
            _value.append(ch);
            while ((ch = read()) != '\0' && CharacterUtil.isWordLetter(ch)) {
                _value.append(ch);
            }
            Integer keyword = (Integer)keywords.get(_value.toString());
            _token = keyword != null ? keyword.intValue() : TokenType.NAME;
            return _token;
        }

        // integer, double
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
                    msg = "'" + _value.toString() + "': invalid token.";
                    throw new LexicalException(msg, getFilename(), _linenum, _column);
                }
                if (ch != '.') {
                    break;
                } else if (_token == TokenType.INTEGER) {
                    _token = TokenType.DOUBLE;
                    _value.append('.');
                    continue;
                } else {
                    msg = "'" + _value.toString() + "': invalid double.";
                    throw new LexicalException(msg, getFilename(), _linenum, _column);
                }
            }
            return _token;
        }

        // string literal
        if (ch == '\'' || ch == '"') {
            start_linenum = _linenum;
            start_column  = _column;
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
                msg = "string literal is not closed by " + (quote == '\'' ? "\"'\"." : "'\"'.");
                throw new LexicalException(msg, getFilename(), start_linenum, start_column);
            }
            read();
            return _token = TokenType.STRING;
        }

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
                start_linenum = _linenum;
                start_column  = _column;
                while ((ch = read()) != '\0') {
                    if (ch == '*') {
                        if ((ch = read()) == '/') {
                            read();
                            return scan();
                        }
                    }
                }
                if (ch == '\0') {
                    msg = "'/*' is not closed by '*/'.";
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
                start_linenum = _linenum;
                start_column  = _column;
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
                    msg = "'" + stag + "' is not closed by '" + etag + "'.";
                    throw new LexicalException(msg, getFilename(), start_linenum, start_column);
                }
                read();
                return _token;
            }
            return _token = TokenType.LT;
        }

        // + - * / % = ! < >
        if (ch < 128 && _op_table1[ch] != 0) {
            ch2 = read();
            if (ch2 == '=') {
                read();
                return _token = _op_table2[ch];
            }
            return _token = _op_table1[ch];
        }

        // &&, ||
        if (ch == '&' || ch == '|') {
            ch2 = read();
            if (ch != ch2) {
                msg = "'" + ch + "': invalid token.";
                throw new LexicalException(msg, getFilename(), _linenum, _column);
            }
            read();
            return _token = ch == '&' ? TokenType.AND : TokenType.OR;
        }

        // [ [:
        if (ch == '[') {
            ch = read();
            if (ch == ':') {
                read();
                return _token = TokenType.L_BRACKETCOLON;
            }
            return _token = TokenType.L_BRACKET;
        }

        // @
        if (ch == '@') {
            _clearValue();
            while ((ch = read()) != '\0' && CharacterUtil.isWordLetter(ch)) {
                _value.append(ch);
            }
            return _token = TokenType.EXPAND;
        }

        // .
        if (ch == '.') {
            if ((ch = read()) != '+') return _token = TokenType.PERIOD;
            if ((ch = read()) != '=') return _token = TokenType.CONCAT;
            read();
            return _token = TokenType.CONCAT_TO;
        }
        //if (ch == '.') {
        //    ch = read();
        //    if (ch == '+') {
        //        ch = read();
        //        if (ch == '=') {
        //            read();
        //            return _token = TokenType.CONCAT_TO;
        //        }
        //        return _token = TokenType.CONCAT;
        //    }
        //    return _token = TokenType.PERIOD;
        //}


        // ( ) ] : ? ; , #
        if (ch < Byte.MAX_VALUE && _op_table3[ch] != 0) {
            read();
            return _token = _op_table3[ch];
        }

        msg = "'" + ch + "': invalid character.";
        throw new LexicalException(msg, getFilename(), _linenum, _column);
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

public class ParseException extends BaseException {
    private int    _linenum;
    private int    _column;
    private String _filename;

    public ParseException(String message, String filename, int linenum, int column) {
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

public class SyntaxException extends ParseException {
    public SyntaxException(String message, String filename, int linenum, int column) {
        super(message, filename, linenum, column);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

public class SemanticException extends ParseException {
    public SemanticException(String message, String filename, int linenum, int column) {
        super(message, filename, linenum, column);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

import java.util.Properties;

abstract public class Parser {
    protected Scanner _scanner;
    protected Properties _props;

    public Parser() {
        this(new Scanner());
    }

    public Parser(Properties props) {
        this(new Scanner(props), props);
    }

    public Parser(Scanner scanner) {
        this(scanner, scanner.getProperties());
    }

    public Parser(Scanner scanner, Properties props) {
        _scanner = scanner;
        _props   = props;
    }

    public Scanner getScanner() { return _scanner; }

    public Properties getProperties() { return _props; }
    public String getProperty(String key) { return _props.getProperty(key); }
    //public String setProperty(String key, String value) { _props.setProperty(key, value); }

    public int getToken() {
        return _scanner.getToken();
    }
    public String getValue() {
        return _scanner.getValue();
    }
    public int getLinenum() {
        return _scanner.getLinenum();
    }
    public int getColumn() {
        return _scanner.getColumn();
    }
    public int scan() {
        return _scanner.scan();
    }

    public String getFilename() {
        return _scanner.getFilename();
    }
    public void setFilename(String filename) {
        _scanner.setFilename(filename);
    }

    public void reset(String input, int linenum) {
        _scanner.reset(input, linenum);
        _scanner.scan();
    }


    //abstract public Node parse(String code) throws SyntaxExpression;


    public void syntaxError(String msg) {
        throw new SyntaxException(msg, getFilename(), getLinenum(), getColumn());
    }

    public void semanticError(String msg) {
        throw new SemanticException(msg, getFilename(), getLinenum(), getColumn());
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.List;
import java.util.ArrayList;
import java.util.Properties;

public class ExpressionParser extends Parser {

    public ExpressionParser() {
        this(new Scanner());
    }
    public ExpressionParser(Properties props) {
        this(new Scanner(props));
    }
    public ExpressionParser(Scanner scanner) {
        this(scanner, scanner.getProperties());
    }
    public ExpressionParser(Scanner scanner, Properties props) {
        this(scanner, props, true);
    }
    public ExpressionParser(Scanner scanner, Properties props, boolean flagInit) {
        super(scanner, props);
        if (flagInit) _scanner.scan();
    }


    /*
     * BNF:
     *  arguments    ::=  expression | arguments ',' expression | e
     *               ::=  [ expression { ',' expression } ]
     */
    public Expression[] parseArguments() {
        if (getToken() == TokenType.R_PAREN) {
            Expression[] args = {};
            return args;
        }
        List list = new ArrayList();
        Expression expr = parseExpression();
        list.add(expr);
        while (getToken() == TokenType.COMMA) {
            scan();
            expr = parseExpression();
            list.add(expr);
        }
        Expression[] args = new Expression[list.size()];
        list.toArray(args);
        return args;
    }

    /*
     *
     * BNF:
     *  item         ::=  variable | function '(' arguments ')' | '(' expression ')'
     */
    public Expression parseItem() {
        int t = getToken();
        if (t == TokenType.NAME) {
            String name = getValue();
            t = scan();
            if (t != TokenType.L_PAREN)
                return new VariableExpression(name);
            scan();
            Expression[] args = parseArguments();
            if (getToken() != TokenType.R_PAREN)
                syntaxError("missing ')' of function '" + name + "().");
            scan();
            Macro macro = Macro.getInstance(name);
            if (macro != null) {
                if (macro.arity() != args.length)
                    semanticError(name + "(): number of arguments should be " + macro.arity() + " but got " + args.length + " argument(s).");
                return macro.expand(args);
            }
            Function function = Function.getInstance(name);
            if (function != null) {
                if (function.arity() != args.length)
                    semanticError(name + "(): number of arguments should be " + function.arity() + " but got " + args.length + " argument(s).");
                return new FunctionExpression(name, args, function);
            }
            // unregistered function
            return new FunctionExpression(name, args, null);
        }
        else if (t == TokenType.L_PAREN) {
            scan();
            Expression expr = parseExpression();
            if (getToken() != TokenType.R_PAREN)
                syntaxError("')' expected ('(' is not closed by ')').");
            scan();
            return expr;
        }
        assert false;
        return null;
    }

    /*
     *  BNF:
     *    literal      ::=  numeric | string | 'true' | 'false' | 'null' | 'empty' | rawcode-expr
     */
    public Expression parseLiteral() {
        int t = getToken();
        String val;
        switch (t) {
          case TokenType.INTEGER:
            val = getValue();
            scan();
            return new IntegerExpression(Integer.parseInt(val));
          case TokenType.DOUBLE:
            val = getValue();
            scan();
            return new DoubleExpression(Double.parseDouble(val));
          case TokenType.STRING:
            val = getValue();
            scan();
            return new StringExpression(val);
          case TokenType.TRUE:
          case TokenType.FALSE:
            scan();
            return new BooleanExpression(t == TokenType.TRUE);
          case TokenType.NULL:
            scan();
            return new NullExpression();
          case TokenType.EMPTY:
            syntaxError("'empty' is allowed only in right-side of '==' or '!='.");
            return null;
          case TokenType.RAWEXPR:
            val = getValue();
            scan();
            return new RawcodeExpression(val);
          default:
            assert false;
            return null;
        }
    }


    /*
     *  BNF:
     *   factor       ::=  literal | item | factor '[' expression ']' | factor '[:' name ']'
     *                  |  factor '.' property | factor '.' method '(' [ arguments ] ')'
     */
    public Expression parseFactor() {
        int t = getToken();
        Expression expr;
        switch (t) {
          case TokenType.INTEGER:
          case TokenType.DOUBLE:
          case TokenType.STRING:
          case TokenType.TRUE:
          case TokenType.FALSE:
          case TokenType.NULL:
          case TokenType.EMPTY:
          case TokenType.RAWEXPR:
            expr = parseLiteral();
            return expr;

          case TokenType.NAME:
          case TokenType.L_PAREN:
            expr = parseItem();
            while (true) {
                t = getToken();
                if (t == TokenType.L_BRACKET) {
                    scan();
                    Expression expr2 = parseExpression();
                    if (getToken() != TokenType.R_BRACKET)
                        syntaxError("']' expected ('[' is not closed by ']').");
                    scan();
                    expr = new IndexExpression(TokenType.ARRAY, expr, expr2);
                }
                else if (t == TokenType.L_BRACKETCOLON) {
                    scan();
                    if (getToken() != TokenType.NAME)
                        syntaxError("'[:' requires a word following.");
                    String word = getValue();
                    scan();
                    if (getToken() != TokenType.R_BRACKET)
                        syntaxError("'[:' is not closed by ']'.");
                    scan();
                    expr = new IndexExpression(TokenType.HASH, expr, new StringExpression(word));
                }
                else if (t == TokenType.PERIOD) {
                    scan();
                    if (getToken() != TokenType.NAME)
                        syntaxError("'.' requires a property or method name following.");
                    String name = getValue();
                    scan();
                    if (getToken() == TokenType.L_PAREN) {
                        scan();
                        Expression[] args = parseArguments();
                        if (getToken() != TokenType.R_PAREN)
                            syntaxError("method '" + name + "(' is not closed by ')'.");
                        scan();
                        expr = new MethodExpression(expr, name, args);
                    } else {
                        expr = new PropertyExpression(expr, name);
                    }
                }
                else {
                    break;  // escape 'while(true)' loop
                }
            }
            return expr;

          default:
            syntaxError("'" + TokenType.tokenText(t) + "': unexpected token.");
            return null;
        }
    }


    /*
     * BNF:
     *  unary        ::=  factor | '+' factor | '-' factor | '!' factor
     *               ::=  [ '+' | '-' | '!' ] factor
     */
    public Expression parseUnary() {
        int t = getToken();
        int unary_t = 0;
        Expression expr;
        if      (t == TokenType.ADD) unary_t = TokenType.PLUS;
        else if (t == TokenType.SUB) unary_t = TokenType.MINUS;
        else if (t == TokenType.NOT) unary_t = TokenType.NOT;
        if (unary_t > 0) {
            scan();
            Expression factor = parseFactor();
            expr = new UnaryExpression(unary_t, factor);
        } else {
            expr = parseFactor();
        }
        return expr;
    }


    /*
     *  BNF:
     *    term         ::=  unary | term * factor | term '/' factor | term '%' factor
     *                 ::=  unary { ('*' | '/' | '%') factor }
     */
    public Expression parseTerm() {
        Expression expr = parseUnary();
        int t;
        while ((t = getToken()) == TokenType.MUL || t == TokenType.DIV || t == TokenType.MOD) {
            scan();
            Expression expr2 = parseFactor();
            expr = new ArithmeticExpression(t, expr, expr2);
        }
        return expr;
    }


    /*
     * BNF:
     *   arith        ::=  term | arith '+' term | arith '-' term | arith '.+' term
     *                ::=  term { ('+' | '-' | '.+') term }
     */
    public Expression parseArithmetic() {
        Expression expr = parseTerm();
        int t;
        while ((t = getToken()) == TokenType.ADD || t == TokenType.SUB || t == TokenType.CONCAT) {
            scan();
            Expression expr2 = parseTerm();
            if (t == TokenType.CONCAT)
                expr = new ConcatenationExpression(t, expr, expr2);
            else
                expr = new ArithmeticExpression(t, expr, expr2);
        }
        return expr;
    }


    /*
     *  BNF:
     *    relational-op   ::=  '==' |  '!=' |  '>' |  '>=' |  '<' |  '<='
     *    relational      ::=  arith | arith relational-op arith | arith '==' 'empty' | arith '!=' 'empty'
     *                    ::=  arith [ relational-op arith ] | arith ('==' | '!=') 'empty'
     */
    public Expression parseRelational() {
        Expression expr = parseArithmetic();
        int t;
        while ((t = getToken()) == TokenType.EQ || t == TokenType.NE
               || t == TokenType.GT || t == TokenType.GE
               || t == TokenType.LT || t == TokenType.LE) {
            scan();
            if (getToken() == TokenType.EMPTY || (getToken() == TokenType.NAME && getValue().equals("empty"))) {
                if (t == TokenType.EQ) {
                    scan();
                    expr = new EmptyExpression(TokenType.EMPTY, expr);
                } else if (t == TokenType.NE) {
                    scan();
                    expr = new EmptyExpression(TokenType.NOTEMPTY, expr);
                } else {
                    syntaxError("'empty' is allowed only at the right-side of '==' or '!='.");
                }
            }
            else {
                Expression expr2 = parseArithmetic();
                expr = new RelationalExpression(t, expr, expr2);
            }
        }
        return expr;
    }


    /*
     *  BNF:
     *    logical-and  ::=  relational | logical-and '&&' relational
     *                 ::=  relational { '&&' relational }
     */
    public Expression parseLogicalAnd() {
        Expression expr = parseRelational();
        int t;
        while ((t = getToken()) == TokenType.AND) {
            scan();
            Expression expr2 = parseRelational();
            expr = new LogicalAndExpression(expr, expr2);
        }
        return expr;
    }


    /*
     * BNF:
     *  logical-or   ::=  logical-and | logical-or '||' logical-and
     *               ::=  logical-and { '||' logical-and }
     */
    public Expression parseLogicalOr() {
        Expression expr = parseLogicalAnd();
        int t;
        while ((t = getToken()) == TokenType.OR) {
            scan();
            Expression expr2 = parseLogicalAnd();
            expr = new LogicalOrExpression(expr, expr2);
        }
        return expr;
    }


    /*
     *  BNF:
     *    conditional  ::=  logical-or | logical-or '?' expression ':' conditional
     *                 ::=  logical-or [ '?' expression ':' conditional ]
     */
    public Expression parseConditional() {
        Expression expr = parseLogicalOr();
        int t;
        if ((t = getToken()) == TokenType.CONDITIONAL) {
            scan();
            Expression expr2 = parseExpression();
            if (getToken() != TokenType.COLON)
                syntaxError("':' expected ('?' requires ':').");
            scan();
            Expression expr3 = parseConditional();
            expr = new ConditionalExpression(expr, expr2, expr3);
        }
        return expr;
    }


    /*
     *  BNF:
     *    assign-op    ::=  '=' | '+=' | '-=' | '*=' | '/=' | '%=' | '.+='
     *    assignment   ::=  conditional | assign-op assignment
     */
    public Expression parseAssignment() {
        Expression expr = parseConditional();
        int op = getToken();
        if (    op == TokenType.ASSIGN || op == TokenType.ADD_TO ||  op == TokenType.SUB_TO
            ||  op == TokenType.MUL_TO || op == TokenType.DIV_TO ||  op == TokenType.MOD_TO
            ||  op == TokenType.CONCAT_TO) {
            if (! isLhs(expr))
                semanticError("invalid assignment.");
            scan();
            Expression expr2 = parseAssignment();
            expr = new AssignmentExpression(op, expr, expr2);
        }
        return expr;
    }

    protected boolean isLhs(Expression expr) {
        switch (expr.getToken()) {
          case TokenType.VARIABLE:
          case TokenType.ARRAY:
          case TokenType.HASH:
          case TokenType.PROPERTY:
            return true;
          default:
            return false;
        }
    }


    /*
     *  BNF:
     *    expression   ::=  assignment
     */
    public Expression parseExpression() {
        return parseAssignment();
    }


    /*
     *
     */
    public Expression parse(String expr_code) {
        _scanner.reset(expr_code);
        _scanner.scan();
        Expression expr = parseExpression();
        if (_scanner.getToken() != TokenType.EOF) {
            syntaxError("Expression is not ended.");
        }
        return expr;
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.Properties;

public class StatementParser extends Parser {
    private ExpressionParser _exprParser;

    public StatementParser() {
        this(new Scanner());
    }
    public StatementParser(Properties props) {
        this(new Scanner(props));
    }
    public StatementParser(Scanner scanner) {
        this(scanner, scanner.getProperties());
    }
    public StatementParser(Scanner scanner, Properties props) {
        this(scanner, props, true);
    }
    public StatementParser(Scanner scanner, Properties props, boolean flagInit) {
        super(scanner, props);
        _exprParser = new ExpressionParser(scanner, props, false);
        if (flagInit) _scanner.scan();
    }

    public ExpressionParser getExpressionParser() { return _exprParser; }



    /*
     *  BNF:
     *
     */
    public Statement parseStatement() {
        int t = getToken();
        Statement stmt = null;
        switch (t) {
          //case TokenType.R_CURLY:
          //  stmt = null;
          //  break;
          case TokenType.L_CURLY:
            stmt = parseBlockStatement();
            break;
          case TokenType.PRINT:
            stmt = parsePrintStatement();
            break;
          case TokenType.NAME:
          case TokenType.L_PAREN:
            stmt = parseExpressionStatement();
            break;
          case TokenType.IF:
            stmt = parseIfStatement();
            break;
          case TokenType.FOREACH:
          //case TokenType.FOR:
            stmt = parseForeachStatement();
            break;
          case TokenType.WHILE:
            stmt = parseWhileStatement();
            break;
          case TokenType.EXPAND:
            stmt = parseExpandStatement();
            break;
          case TokenType.SHARP:
            stmt = parseElementStatement();
            break;
          case TokenType.RAWSTMT:
            stmt = parseRawcodeStatement();
            break;
          case TokenType.SEMICOLON:
            stmt = parseEmptyStatement();
            break;
          default:
            syntaxError("statement expected but got '" + getToken() + "'.");
        }
        return stmt;
    }


    /*
     * BNF:
     *  stmt-list    ::=  statement | stmt-list statement
     *               ::=  statement { statement }
     *  block-stmt   ::=  '{' '}' | '{' stmt-list '}'
     */
    public Statement parseBlockStatement() {
        assert getToken() == TokenType.L_CURLY;
        int start_linenum = getLinenum();
        scan();
        Statement[] stmts = parseStatementList();
        if (getToken() != TokenType.R_CURLY)
            syntaxError("block-statement(starts at line " + start_linenum + ") requires '}'.");
        scan();
        return new BlockStatement(stmts);
    }

    public Statement[] parseStatementList() {
        List list = new ArrayList();
        Statement stmt;
        while (getToken() != TokenType.EOF) {
            if (getToken() == TokenType.R_CURLY)
                break;
            stmt = parseStatement();
            list.add(stmt);
            //if (! (stmt instanceof EmptyStatement)) {
            //    list.add(stmt);
            //}
        }
        Statement[] stmts = new Statement[list.size()];
        list.toArray(stmts);
        return stmts;
    }


    /*
     *  BNF:
     *    print-stmt   ::=  'print' '(' arguments ')' ';'
     */
    public Statement parsePrintStatement() {
        assert getToken() == TokenType.PRINT;
        int t = scan();
        if (t != TokenType.L_PAREN)
            syntaxError("print-statement requires '('.");
        t = scan();
        Expression[] args = _exprParser.parseArguments();
        if (getToken() != TokenType.R_PAREN)
            syntaxError("print-statement requires ')'.");
        t = scan();
        if (t != TokenType.SEMICOLON)
            syntaxError("print-statement requires ';'.");
        scan();
        return new PrintStatement(args);
    }

    /*
     *  BNF:
     *
     */
    public Statement parseExpressionStatement() {
        //assert getToken() == TokenType.NAME || getToken() == TokenType.L_PAREN;
        Expression expr = _exprParser.parseExpression();
        if (getToken() != TokenType.SEMICOLON)
            syntaxError("expression-statement requires ';'.");
        scan();
        return new ExpressionStatement(expr);
    }


    /*
     *  BNF:
     *    if-stmt     ::=  'if' '(' expression ')' statement
     *                   | 'if' '(' expression ')' statement elseif-part
     *                   | 'if' '(' expression ')' statement elseif-part 'else' statement
     *                ::=  'if' '(' expression ')' statement
     *                      { 'elseif' '(' expression ')' statement }
     *                      [ 'else' statement ]
     */
    public Statement parseIfStatement() {
        assert getToken() != TokenType.IF || getToken() != TokenType.ELSEIF;
        String word = getToken() == TokenType.IF ? "if" : "elseif";
        int t = scan();
        if (t != TokenType.L_PAREN)
            syntaxError(word + "-statement requires '('.");
        scan();
        Expression condition = _exprParser.parseExpression();
        if (getToken() != TokenType.R_PAREN)
            syntaxError(word + "-statement requires ')'.");
        scan();
        Statement thenBody = parseStatement();
        Statement elseBody = null;
        if (getToken() == TokenType.ELSEIF) {
            elseBody = parseIfStatement();
        } else if (getToken() == TokenType.ELSE) {
            scan();
            elseBody = parseStatement();
        }
        return new IfStatement(condition, thenBody, elseBody);
    }


    /*
     *  BNF:
     *    foreach-stmt ::=  'foreach' '(' variable 'in' expression ')' statement
     */
    public Statement parseForeachStatement() {
        assert getToken() == TokenType.FOREACH;
        int t = scan();
        if (t != TokenType.L_PAREN)
            syntaxError("foreach-statement requires '('.");
        t = scan();
        if (t != TokenType.NAME)
            syntaxError("foreach-statement requires loop-variable but got '" + TokenType.inspect(getToken(), getValue()) + "'.");
        String varname = getValue();
        VariableExpression loopvar = new VariableExpression(varname);
        t = scan();
        if (t != TokenType.IN && t != TokenType.ASSIGN)
            syntaxError("foreach-statement requires loop-variable but got '" + TokenType.inspect(getToken(), getValue()) + "'.");
        scan();
        Expression list = _exprParser.parseExpression();
        if (getToken() != TokenType.R_PAREN)
            syntaxError("foreach-statement requires ')'.");
        scan();
        Statement body = parseStatement();
        return new ForeachStatement(loopvar, list, body);
    }


    /*
     *  BNF:
     *    while-stmt   ::=  'while' '(' expression ')' statement
     */
    public Statement parseWhileStatement() {
        assert getToken() == TokenType.WHILE;
        scan();
        if (getToken() != TokenType.L_PAREN)
            syntaxError("while-statement requires '('");
        scan();
        Expression condition = _exprParser.parseExpression();
        if (getToken() != TokenType.R_PAREN)
            syntaxError("while-statement requires ')'");
        scan();
        Statement body = parseStatement();
        return new WhileStatement(condition, body);
    }


    /*
     *  BNF:
     *
     */
    public Statement parseExpandStatement() {
        assert getToken() == TokenType.EXPAND;
        String marking = null;
        String typeStr = getValue();
        Integer typeObj = (Integer)_expandTypes.get(typeStr);
        if (typeObj == null)
            syntaxError("'@" + typeStr + "': invalid expand statement.");
        int type = typeObj.intValue();
        if (type == ExpandStatement.CONTENT || type == ExpandStatement.ELEMENT) {
            scan();
            if (getToken() != TokenType.L_PAREN)
                syntaxError("`@" + typeStr + "' requires '('.");
            scan();
            if (getToken() != TokenType.NAME)
                syntaxError("`@" + typeStr + "()' requires a marking name.");
            marking = getValue();
            scan();
            if (getToken() != TokenType.R_PAREN)
                syntaxError("`@" + typeStr + "' requires ')'.");
        }
        scan();
        if (getToken() != TokenType.SEMICOLON)
            syntaxError("`@" + typeStr + "()' requires ';'.");
        scan();
        return new ExpandStatement(type, marking);
    }

    private static final Map _expandTypes = new HashMap();
    static {
        _expandTypes.put("stag",    new Integer(ExpandStatement.STAG));
        _expandTypes.put("cont",    new Integer(ExpandStatement.CONT));
        _expandTypes.put("etag",    new Integer(ExpandStatement.ETAG));
        _expandTypes.put("content", new Integer(ExpandStatement.CONTENT));
        _expandTypes.put("element", new Integer(ExpandStatement.ELEMENT));
    }


    /*
     *  BNF:
     *
     */
    public Statement parseElementStatement() {
        return null;
    }


    /*
     *  BNF:
     *
     */
    public Statement parseRawcodeStatement() {
        assert getToken() == TokenType.RAWSTMT;
        String rawcode = getValue();
        scan();
        return new RawcodeStatement(rawcode);
    }


    /*
     *  BNF:
     *
     */
    public Statement parseEmptyStatement() {
        assert getToken() == TokenType.SEMICOLON;
        scan();
        return new EmptyStatement();
    }


    /*
     *
     */
    public BlockStatement parse(String input) {
        return parse(input, 1);
    }
    public BlockStatement parse(String input, int baselinenum) {
        _scanner.reset(input, baselinenum);
        _scanner.scan();
        Statement[] stmts = parseStatementList();
        if (getToken() != TokenType.EOF)
            syntaxError("EOF expected but '" + TokenType.inspect(getToken(), getValue()) + "'.");
        return new BlockStatement(stmts);
    }

}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.Map;
import java.util.Properties;
import java.io.Writer;
import java.io.PrintWriter;

public class Interpreter {
    private StatementParser _parser;
    private Statement _stmt = null;
    private Properties _props;

    public Interpreter() {
        _parser = new StatementParser();
        _props = _parser.getProperties();
    }

    public Interpreter(Properties props) {
        _props = props;
        _parser = new StatementParser(_props);
    }

    public Statement compile(String code) {
        _stmt = _parser.parse(code);
        return _stmt;
    }

    public Object execute(Map context) throws java.io.IOException  {
        return execute(context, new PrintWriter(System.out));
    }

    public Object execute(Map context, Writer writer) throws java.io.IOException {
        if (_stmt == null) return null;
        return _stmt.execute(context, writer);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.Iterator;

public class Element {
    private String _name;
    private Tag    _stag;
    private Tag    _etag;
    private List   _cont;           // list of Statement
    private PresentationDeclaration _decl;
    private BlockStatement _plogic;

    public Element(String name, Tag stag, Tag etag, List cont) {
        _name = name;
        _stag = stag;
        _etag = etag;
        _cont = cont;
    }

    public Tag getStag() { return _stag; }
    public Tag getEtag() { return _etag; }
    public List getCont() { return _cont; }
    public String getName() { return _name; }

    public static Map createElementTable(List elementList) {
        return addElementList(new HashMap(), elementList);
    }

    public static Map addElementList(Map elementTable, List elementList) {
        for (Iterator it = elementList.iterator(); it.hasNext(); ) {
            Element elem = (Element)it.next();
            elementTable.put(elem.getName(), elem);
        }
        return elementTable;
    }

    public static void mergeDeclarationList(Map elementTable, List declList) {
        // merge declarations
        if (elementTable == null) return;
        if (declList == null) return;
        for (Iterator it = declList.iterator(); it.hasNext(); ) {
            PresentationDeclaration decl = (PresentationDeclaration)it.next();
            for (int i = 0; i < decl.names.length; i++) {
                String name = decl.names[i];
                Element elem = (Element)elementTable.get(name);
                if (elem != null)  elem.setDeclaration(decl);
            }
        }
    }



    public PresentationDeclaration getDeclaration() {
        return _decl;
    }

    public void setDeclaration(PresentationDeclaration decl) {
        _decl = decl;
        if (decl.value != null) {
            Expression[] args = { decl.value };
            PrintStatement stmt = new PrintStatement(args);
            _cont = new ArrayList();
            _cont.add(stmt);
        }
        if (decl.tagname != null) {
            // TBI
            if (decl.tagname.getToken() == TokenType.STRING) {
                String tagname = ((StringExpression)decl.tagname).getValue();
                _stag.tagname = tagname;
                _etag.tagname = tagname;
            }
        }
        if (decl.remove != null) {
            if (_stag.attrs != null) {
                for (int i = _stag.attrs.size() - 1; i >= 0; i--) {
                    Attr attr = (Attr)_stag.attrs.get(i);
                    Object aname = attr.name;
                    if (decl.remove.contains(aname))
                       _stag.attrs.remove(i);
                }
            }
        }
        if (decl.attrs != null) {
            if (_stag.attrs == null) _stag.attrs = new ArrayList();
            for (Iterator it = decl.attrs.keySet().iterator(); it.hasNext(); ) {
                String aname = (String)it.next();
                Object expr  = decl.attrs.get(aname);
                int i;
                int len = _stag.attrs.size();
                for (i = 0; i < len; i++) {
                    Attr attr = (Attr)_stag.attrs.get(i);
                    if (aname.equals(attr.name)) {
                        attr.value = expr;
                        break;
                    }
                }
                if (i >= len) {
                    Attr attr = new Attr(" ", aname, expr);
                    _stag.attrs.add(attr);
                }
            }
            //for (int i = _stag.attrs.size() -1; i >= 0; i--) {
            //    Attr attr = (Attr)_stag.attrs.get(i);
            //    String aname = attr.name;
            //    Object expr = decl.attrs.get(aname);
            //    if (expr != null)  attr.value = expr;
            //}
        }
        if (decl.append != null) {
            if (_stag.append_exprs == null)
                _stag.append_exprs = decl.append;
            else
                _stag.append_exprs.addAll(decl.append);
        }
        if (decl.plogic != null) {
            _plogic = decl.plogic;
        }
    }

    public BlockStatement getPresentationLogic() {
        if (_plogic == null) {
            Statement[] stmts = {
                new ExpandStatement(ExpandStatement.STAG),
                new ExpandStatement(ExpandStatement.CONT),
                new ExpandStatement(ExpandStatement.ETAG),
            };
            _plogic = new BlockStatement(stmts);
        }
        return _plogic;
    }


    public Statement[] getContentStatements() {
        Statement[] stmts = new Statement[_cont.size()];
        _cont.toArray(stmts);
        return stmts;
    }


    public StringBuffer _inspect() {
        return _inspect(0, new StringBuffer());
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        for (int i = 0; i < level; i++) sb.append("  ");
        sb.append("Element(");
        sb.append(_name);
        sb.append(")\n");
        for (Iterator it = _cont.iterator(); it.hasNext(); ) {
            Statement stmt = (Statement)it.next();
            stmt._inspect(level + 1, sb);
        }
        return sb;
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

import java.util.List;
import java.util.ArrayList;
import java.util.Properties;

public class Optimizer implements StatementVisitor {   // statement visitor

    private Properties _props;

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

// --------------------------------------------------------------------------------

package __PACKAGE__;

public interface Expander {

    public Statement expand(Statement           stmt, Element elem);
    public Statement expand(PrintStatement      stmt, Element elem);
    public Statement expand(ExpressionStatement stmt, Element elem);
    public Statement expand(ForeachStatement    stmt, Element elem);
    public Statement expand(WhileStatement      stmt, Element elem);
    public Statement expand(IfStatement         stmt, Element elem);
    public Statement expand(BlockStatement      stmt, Element elem);
    public Statement expand(ExpandStatement     stmt, Element elem);
    public Statement expand(ElementStatement    stmt, Element elem);
    public Statement expand(RawcodeStatement    stmt, Element elem);
    public Statement expand(EmptyStatement      stmt, Element elem);

}

// --------------------------------------------------------------------------------

package __PACKAGE__;

import java.util.Map;
import java.util.Properties;

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
        ExpandStatement expandStmt;
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

// --------------------------------------------------------------------------------

//package __PACKAGE__;
//
//import java.util.Map;
//
//public class Expander {
//
//    private Map _elementTable;
//    private TagHelper _helper = new TagHelper();
//
//    public Expander(Map elementTable) {
//        _elementTable = elementTable;
//    }
//
//    public Statement expand(Statement stmt, Element elem) {
//        Statement st;
//        Statement[] stmts;
//
//        switch (stmt.getToken()) {
//          case TokenType.PRINT:
//          case TokenType.EXPR:
//          case TokenType.RAWSTMT:
//            return null;
//
//          case TokenType.BLOCK:
//            stmts = ((BlockStatement)stmt).getStatements();
//            for (int i = 0; i < stmts.length; i++) {
//                st = expand(stmts[i], elem);
//                if (st != null) stmts[i] = st;
//            }
//            return null;
//
//          case TokenType.FOREACH:
//            st = expand(((ForeachStatement)stmt).getBodyStatement(), elem);
//            if (st != null) ((ForeachStatement)stmt).setBodyStatement(st);
//            return null;
//
//          case TokenType.WHILE:
//            st = expand(((WhileStatement)stmt).getBodyStatement(), elem);
//            if (st != null) ((WhileStatement)stmt).setBodyStatement(st);
//            return null;
//
//          case TokenType.IF:
//            IfStatement ifStmt = (IfStatement)stmt;
//            st = expand(ifStmt.getThenStatement(), elem);
//            if (st != null) ifStmt.setThenStatement(st);
//            if (ifStmt.getElseStatement() != null) {
//                st = expand(ifStmt.getElseStatement(), elem);
//                if (st != null) ifStmt.setElseStatement(st);
//            }
//            return null;
//
//          case TokenType.EXPAND:
//            ExpandStatement expandStmt;
//            int type = ((ExpandStatement)stmt).getType();
//            if (type  == ExpandStatement.STAG) {
//                st = _helper.buildPrintStatement(elem.getStag());
//            }
//            else if (type == ExpandStatement.ETAG) {
//                if (elem.getEtag() == null)
//                    st = new PrintStatement(new Expression[] {});
//                else
//                    st = _helper.buildPrintStatement(elem.getEtag());
//            }
//            else if (type == ExpandStatement.CONT) {
//                stmts = elem.getContentStatements();
//                st = stmts.length == 1 ? stmts[0] : new BlockStatement(stmts);
//                Statement st2 = expand(st, null);
//                if (st2 != null) st = st2;
//            }
//            else if (type == ExpandStatement.CONTENT) {
//                String name = ((ExpandStatement)stmt).getName();
//                Element elem2 = (Element)_elementTable.get(name);
//                if (elem2 == null) {
//                    throw new ExpantionException("'@content('" + name + ")': element not found.");
//                }
//                stmts = elem2.getContentStatements();
//                st = stmts.length == 1 ? stmts[0] : new BlockStatement(stmts);
//                Statement st2 = expand(st, null);
//                if (st2 != null) st = st2;
//            }
//            else if (type == ExpandStatement.ELEMENT) {
//                String name = ((ExpandStatement)stmt).getName();
//                Element elem2 = (Element)_elementTable.get(name);
//                if (elem2 == null) {
//                    throw new ExpantionException("'@element('" + name + ")': element not found.");
//                }
//                st = elem2.getPresentationLogic(); //block statment
//                expand(st, elem2);
//            }
//            else {
//                assert false;
//                st = null;
//            }
//            return st;
//        }
//        return null;
//    }
//
//}

// --------------------------------------------------------------------------------

package __PACKAGE__;

public class ExpantionException extends BaseException {
    public ExpantionException(String message) {
        super(message);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.List;

class Attr {
    String space;
    String name;
    Object value;        // Expression or String

    Attr(String space, String name, Object value) {
        this.space = space;
        this.name  = name;
        this.value = value;
    }

    /*
    String space() { return space; }
    String name()  { return name;  }
    Object value() { return value; }
     */
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import java.util.List;

public class Tag {
    public String tag_str;
    public String before_text;
    public String before_space;
    public String tagname;
    public String attr_str;
    public String extra_space;
    public String after_space;
    public boolean is_etag;
    public boolean is_empty;
    public boolean is_begline;
    public boolean is_endline;
    public int start_pos;
    public int end_pos;
    public int linenum;

    //
    public String directive_name;
    public String directive_arg;
    public List attrs;              // list of Attr
    public List append_exprs;

    public String _inspect() {
        StringBuffer sb = new StringBuffer();
        if (tag_str != null) {
            sb.append("tag_str      = " + Utility.inspectString(tag_str)       + "\n");
            sb.append("before_text  = " + Utility.inspectString(before_text)   + "\n");
            sb.append("before_space = " + Utility.inspectString(before_space)  + "\n");
            sb.append("tagname      = " + Utility.inspectString(tagname)       + "\n");
            sb.append("attr_str     = " + Utility.inspectString(attr_str)      + "\n");
            sb.append("extra_space  = " + Utility.inspectString(extra_space)   + "\n");
            sb.append("after_space  = " + Utility.inspectString(after_space)   + "\n");
            sb.append("is_etag      = " + is_etag       + "\n");
            sb.append("is_empty     = " + is_empty      + "\n");
            sb.append("is_begline   = " + is_begline    + "\n");
            sb.append("is_endline   = " + is_endline    + "\n");
            sb.append("start_pos    = " + start_pos     + "\n");
            sb.append("end_pos      = " + end_pos       + "\n");
            sb.append("linenum      = " + linenum       + "\n");
        } else {
            sb.append("before_text  = " + Utility.inspectString(before_text)   + "\n");
            sb.append("linenum      = " + linenum       + "\n");
        }
        return sb.toString();
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

import java.util.List;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.util.Properties;

public class TagHelper {
    private StatementParser  _stmtParser;
    private ExpressionParser _exprParser;
    private Properties _props;


    public TagHelper() {
        this(new Properties(Configuration.defaults));
    }

    public TagHelper(Properties props) {
        _props = props;
        _stmtParser = new StatementParser();
        _exprParser = _stmtParser.getExpressionParser();
    }


    public String getFilename() {
        return _stmtParser.getFilename();
        //return _exprParser.getFilename();
    }


    public void setFilename(String filename) {
        _stmtParser.setFilename(filename);
        //_exprParser.setFilename(filename);
    }


    public Expression parseExpression(String str, int linenum) {
        _exprParser.reset(str, linenum);
        Expression expr = _exprParser.parseExpression();
        if (_exprParser.getToken() != TokenType.EOF) {
            String msg = "'" + str + "': invalid expression.";
            throw new ConvertionException(msg, _exprParser.getFilename(), linenum);
        }
        return expr;
    }


    public Statement parseExpressionStatement(String str, int linenum) {
        _stmtParser.reset(str, linenum);
        Statement stmt = _stmtParser.parseExpressionStatement();
        //assert _stmtParser.getToken() == TokenType.EOF;
        if (_stmtParser.getToken() != TokenType.EOF) {
            String msg = "'" + str + "': invalid expression statement.";
            throw new ConvertionException(msg, _stmtParser.getFilename(), linenum);
        }
        return stmt;
    }


    public PrintStatement createTagPrintStatement(Tag tag, boolean tagDelete) {
        PrintStatement stmt;
        if (tagDelete) {
            String s = tag.is_begline && tag.is_endline ? "" : tag.before_space + tag.after_space;
            Expression[] args = { new StringExpression(s) };
            stmt = new PrintStatement(args);
        } else {
            stmt = buildPrintStatement(tag);
        }
        return stmt;
    }



    public PrintStatement createPrintStatement(String str, int linenum) {
        Expression[] args = expandEmbeddedExpression(str, linenum);
        return new PrintStatement(args);
    }


    public static final String EMBED_PATTERN = "@\\{(.*?)\\}@";

    public Expression[] expandEmbeddedExpression(String str, int linenum) {
        final Pattern embedPattern = Pattern.compile(EMBED_PATTERN);
        List list = null;
        int index = 0;
        Matcher m = embedPattern.matcher(str);
        while (m.find()) {
            if (list == null) list = new ArrayList();
            String front = str.substring(index, m.start());
            if (front != null && front.length() > 0) {
                list.add(new StringExpression(front));
                for (int i = 0; i < front.length(); i++) {
                    if (str.charAt(i) == '\n') linenum++;
                }
            }
            if (m.group(1).length() > 1) {
                list.add(parseExpression(m.group(1), linenum));
            }
            index = m.end();
        }
        Expression[] exprs;
        if (list != null) {
            String s = str.substring(index);
            if (s != null && s.length() > 0) list.add(new StringExpression(s));
            exprs = new Expression[list.size()];
            list.toArray(exprs);
        } else {
            exprs = new Expression[1];
            exprs[0] = new StringExpression(str);
        }
        return exprs;
    }


    public PrintStatement buildPrintStatement(Tag tag) {
        StringBuffer sb = new StringBuffer();
        sb.append(tag.before_space);
        sb.append(tag.is_etag ? "</" : "<");
        sb.append(tag.tagname);
        List list = new ArrayList();
        if (tag.attrs != null) {
            for (Iterator it = tag.attrs.iterator(); it.hasNext(); ) {
                Attr a = (Attr)it.next();
                String aspace = a.space;
                String aname  = a.name;
                Object avalue = a.value;
                sb.append(aspace);
                sb.append(aname);
                sb.append("=\"");
                if (avalue instanceof Expression) {
                    list.add(new StringExpression(sb.toString()));
                    sb.delete(0, sb.length());  // clear
                    list.add(avalue);
                } else {
                    assert avalue instanceof String;
                    String str = (String)avalue;
                    if (str.indexOf('@') < 0) {         // ATTR_PATTERN
                        sb.append(str);
                    } else {
                        Expression[] exprs = expandEmbeddedExpression(str, tag.linenum);
                        for (int i = 0; i < exprs.length; i++) {
                            if (exprs[i].getToken() == TokenType.STRING) {
                                sb.append(((StringExpression)exprs[i]).getValue());
                            } else {
                                list.add(new StringExpression(sb.toString()));
                                sb.delete(0, sb.length());  // clear
                                list.add(exprs[i]);
                            }
                        }
                    }
                }
                sb.append("\"");
            }
        }
        //
        if (tag.append_exprs != null) {
            list.add(new StringExpression(sb.toString()));
            list.addAll(tag.append_exprs);
            sb.delete(0, sb.length());  // clear
        }
        sb.append(tag.extra_space);
        sb.append(tag.is_empty ? "/>" : ">");
        sb.append(tag.after_space);
        list.add(new StringExpression(sb.toString()));
        //
        Expression[] args = new Expression[list.size()];
        list.toArray(args);
        return new PrintStatement(args);
    }

}

// --------------------------------------------------------------------------------

package __PACKAGE__;

import java.util.List;
import java.util.Iterator;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.util.Properties;
import java.io.FileReader;
import java.io.FileNotFoundException;
import java.io.UnsupportedEncodingException;
import java.io.IOException;

public class DirectiveHandler {
    private DefaultConverter _converter;
    private TagHelper _helper;
    private Properties _props;
    private String _even;
    private String _odd;

    public DirectiveHandler(DefaultConverter converter, Properties props) {
        _converter  = converter;
        _helper     = new TagHelper();
        _props      = props;
        _even       = _props.getProperty("kwartz.even");
        _odd        = _props.getProperty("kwartz.odd");
    }

    public void handleMarkDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        assert stag.directive_name.equals("mark");
        String marking = stag.directive_arg;
        if (stag.attrs != null) {
            for (Iterator it = stag.attrs.iterator(); it.hasNext(); ) {
                Attr attr = (Attr)it.next();
                String avalue = (String)attr.value;
                Expression[] exprs = _helper.expandEmbeddedExpression(avalue, stag.linenum);
                //Expression[] exprs = _converter.expandEmbeddedExpression(avalue, stag.linenum);
                Expression expr;
                if (exprs.length == 0) {
                    expr = new StringExpression("");
                } else {
                    expr = exprs[0];
                    for (int i = 1; i < exprs.length; i++) {
                        expr = new ConcatenationExpression(expr, exprs[i]);
                    }
                }
                attr.value = expr;
            }
        }
        _converter.addElement(new Element(marking, stag, etag, bodyStmtList));
        stmtList.add(new ExpandStatement(ExpandStatement.ELEMENT, marking));
    }


    public void handleValueDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        if (etag == null) {
            String msg = "directive '" + stag.directive_name + "' cannot use with empty tag.";
            throw new ConvertionException(msg, _converter.getFilename(), stag.linenum);
        }
        Expression expr = _helper.parseExpression(stag.directive_arg, stag.linenum);
        if (stag.directive_name.equals("Value")) {
            expr = new FunctionExpression("E", new Expression[] { expr });
        } else if (stag.directive_name.equals("VALUE")) {
            expr = new FunctionExpression("X", new Expression[] { expr });
        }
        PrintStatement stmt = new PrintStatement(new Expression[] { expr });
        stmtList.add(bodyStmtList.get(0));                        // first statement
        stmtList.add(stmt);
        stmtList.add(bodyStmtList.get(bodyStmtList.size() - 1));  // last statement
    }


    public void handleForeachDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        Pattern pat = Pattern.compile("\\A(\\w+)\\s*[:=]\\s*(.*)");
        Matcher m = pat.matcher(stag.directive_arg);
        if (! m.find()) {
            String msg = "'" + stag.directive_name + ":" + stag.directive_arg + "': invalid directive argument.";
            throw new ConvertionException(msg, _converter.getFilename(), stag.linenum);
        }
        String varname = m.group(1);
        String liststr = m.group(2);
        VariableExpression varexpr = new VariableExpression(varname);
        Expression listexpr = _helper.parseExpression(liststr, stag.linenum);
        String counter = !stag.directive_name.equals("foreach") ? varname + "_ctr" : null;
        String toggle  =  stag.directive_name.equals("FOREACH") ? varname + "_tgl" : null;
        //
        if (counter != null) {
            stmtList.add(_helper.parseExpressionStatement(counter + " = 0;", -1));
            bodyStmtList.add(0, _helper.parseExpressionStatement(counter + " += 1;", -1));
        }
        if (toggle != null) {
            String s = toggle + " = " + counter + " % 2 == 0 ? " + _even + " : " + _odd + ";";
            bodyStmtList.add(1, _helper.parseExpressionStatement(s, -1));
        }
        stmtList.add(new ForeachStatement(varexpr, listexpr, new BlockStatement(bodyStmtList)));
    }


    public void handleListDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        if (etag == null) {
            String msg = "directive '" + stag.directive_name + "' cannot use with empty tag.";
            throw new ConvertionException(msg, _converter.getFilename(), stag.linenum);
        }
        Pattern pat = Pattern.compile("\\A(\\w+)\\s*[:=]\\s*(.*)");
        Matcher m = pat.matcher(stag.directive_arg);
        if (! m.find()) {
            String msg = "'" + stag.directive_name + ":" + stag.directive_arg + "': invalid directive argument.";
            throw new ConvertionException(msg, _converter.getFilename(), stag.linenum);
        }
        String varname = m.group(1);
        String liststr = m.group(2);
        VariableExpression varexpr = new VariableExpression(varname);
        Expression listexpr = _helper.parseExpression(liststr, stag.linenum);
        String counter = !stag.directive_name.equals("list") ? varname + "_ctr" : null;
        String toggle  =  stag.directive_name.equals("LIST") ? varname + "_tgl" : null;
        //
        Object firstStmt = bodyStmtList.remove(0);
        Object lastStmt  = bodyStmtList.remove(bodyStmtList.size() - 1);
        stmtList.add(firstStmt);
        if (counter != null) {
            stmtList.add(_helper.parseExpressionStatement(counter + " = 0;", -1));
            bodyStmtList.add(0, _helper.parseExpressionStatement(counter + " += 1;", -1));
        }
        if (toggle != null) {
            String s = toggle + " = " + counter + " % 2 == 0 ? " + _even + " : " + _odd + ";";
            bodyStmtList.add(1, _helper.parseExpressionStatement(s, -1));
        }
        stmtList.add(new ForeachStatement(varexpr, listexpr, new BlockStatement(bodyStmtList)));
        stmtList.add(lastStmt);
    }


    public void handleWhileDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        Expression condition = _helper.parseExpression(stag.directive_arg, stag.linenum);
        stmtList.add(new WhileStatement(condition, new BlockStatement(bodyStmtList)));
    }


    public void handleLoopDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        Expression condition = _helper.parseExpression(stag.directive_arg, stag.linenum);
        if (etag == null) {
            String msg = "directive '" + stag.directive_name + "' cannot use with empty tag.";
            throw new ConvertionException(msg, _converter.getFilename(), stag.linenum);
        }
        Object firstStmt = bodyStmtList.remove(0);
        Object lastStmt  = bodyStmtList.remove(bodyStmtList.size() - 1);
        stmtList.add(firstStmt);
        stmtList.add(new WhileStatement(condition, new BlockStatement(bodyStmtList)));
        stmtList.add(lastStmt);
    }


    public void handleIfDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        Expression condition = _helper.parseExpression(stag.directive_arg, stag.linenum);
        stmtList.add(new IfStatement(condition, new BlockStatement(bodyStmtList), null));
    }


    public void handleElseifDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        Expression condition = _helper.parseExpression(stag.directive_arg, stag.linenum);
        Statement stmt = (Statement)stmtList.get(stmtList.size() - 1);
        while (stmt.getToken() == TokenType.IF && ((IfStatement)stmt).getElseStatement() != null) {
            stmt = ((IfStatement)stmt).getElseStatement();
        }
        if (stmt.getToken() != TokenType.IF) {
            String msg = "elseif-directive must be at just after the if-statement or elseif-statement.";
            throw new ConvertionException(msg, _converter.getFilename(), stag.linenum);
        }
        ((IfStatement)stmt).setElseStatement(new IfStatement(condition, new BlockStatement(bodyStmtList), null));
    }


    public void handleElseDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        Statement stmt = (Statement)stmtList.get(stmtList.size() - 1);
        while (stmt.getToken() == TokenType.IF && ((IfStatement)stmt).getElseStatement() != null) {
            stmt = ((IfStatement)stmt).getElseStatement();
        }
        if (stmt.getToken() != TokenType.IF) {
            String msg = "else-directive must be at just after the if-statement or elseif-statement.";
            throw new ConvertionException(msg, _converter.getFilename(), stag.linenum);
        }
        ((IfStatement)stmt).setElseStatement(new BlockStatement(bodyStmtList));
    }


    public void handleSetDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        Expression expr = _helper.parseExpression(stag.directive_arg, stag.linenum);
        stmtList.add(new ExpressionStatement(expr));
        stmtList.addAll(bodyStmtList);
    }


    public void handleDummyDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        // nothing
    }


    public void handleReplaceDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        _handleReplaceDirective(false, stmtList, stag, etag, bodyStmtList);
    }


    public void handlePlaceholderDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        _handleReplaceDirective(true,  stmtList, stag, etag, bodyStmtList);
    }


    private void _handleReplaceDirective(boolean inner, List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        Pattern pat = Pattern.compile("\\A(\\w+)(?::(content|element))?\\z");
        Matcher m = pat.matcher(stag.directive_arg);
        if (! m.find()) {
            String msg = "'" + stag.directive_name + ":" + stag.directive_arg + "': invalid directive.";
            throw new ConvertionException(msg, _converter.getFilename(), stag.linenum);
        }
        String name = m.group(1);
        int type = m.group(2) != null && m.group(2).equals("content") ? ExpandStatement.CONTENT : ExpandStatement.ELEMENT;
        if (inner) {
            if (etag == null) {
                String msg = "directive '" + stag.directive_name + "' cannot use with empty tag.";
                throw new ConvertionException(msg, _converter.getFilename(), stag.linenum);
            }
            Object firstStmt = bodyStmtList.remove(0);
            Object lastStmt  = bodyStmtList.remove(bodyStmtList.size() - 1);
            stmtList.add(firstStmt);
            stmtList.add(new ExpandStatement(type, name));
            stmtList.add(lastStmt);
        } else {
            stmtList.add(new ExpandStatement(type, name));
        }
    }


    public void handleIncludeDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        String basename = stag.directive_arg;
        char firstChar = basename.charAt(0);
        char lastChar  = basename.charAt(basename.length() - 1);
        if (firstChar == '"' && lastChar == '"' || firstChar == '\'' && lastChar == '\'') {
            basename = basename.substring(1, basename.length() - 1);
        }

        // TBI: pathlist
        //    pathlist = @properties[:incdirs] || Kwartz::Config::INCDIRS || ['.']
        //    filename = nil
        //    pathlist.each do |path|
        //       filename = path + '/' + basename
        //       break if test(?f, filename)
        //       filename = nil
        //    end
        String filename = null;
        filename = basename;
        if (filename == null) {
            String msg = "'" + stag.directive_name + ":" + stag.directive_arg + "': include file not found.";
            throw new ConvertionException(msg, _converter.getFilename(), stag.linenum);
        }

        StringBuffer sb = new StringBuffer();
        char[] buf = new char[512];
        FileReader reader = null;
        try {
            reader = new FileReader(filename);
            while (reader.read(buf) >= 0) {
                sb.append(buf);
            }
        } catch (FileNotFoundException ex) {
            throw new ConvertionException(ex.toString(), _converter.getFilename(), stag.linenum);
        } catch (UnsupportedEncodingException ex) {
            throw new ConvertionException(ex.toString(), _converter.getFilename(), stag.linenum);
        } catch (IOException ex) {
            throw new ConvertionException(ex.toString(), _converter.getFilename(), stag.linenum);
        } finally {
            if (reader != null)
              try {
                  reader.close();
              } catch (IOException ignore) { }
        }

        Converter converter = null;
        try {
            converter = (Converter)_converter.getClass().newInstance();
        } catch (IllegalAccessException ex) {
            throw new ConvertionException(ex.toString(), _converter.getFilename(), stag.linenum);
        } catch (InstantiationException ex) {
            throw new ConvertionException(ex.toString(), _converter.getFilename(), stag.linenum);
        }
        converter.setFilename(filename);
        // TBI
        //converter.setPropertyies(_converter.getProperties());
        Statement[] stmts = converter.convert(sb.toString());

        if (stag.directive_name.equals("INCLUDE"))
            stmtList.addAll(bodyStmtList);
        for (int i = 0; i < stmts.length; i++)
            stmtList.add(stmts[i]);
        if (stag.directive_name.equals("Include"))
            stmtList.addAll(bodyStmtList);
        List elements = converter.getElementList();
        for (Iterator it = elements.iterator(); it.hasNext(); ) {
            Element element = (Element)it.next();
            _converter.addElement(element);
        }
    }

}

// --------------------------------------------------------------------------------

package __PACKAGE__;

import java.util.Properties;

public class ConvertionException extends BaseException {
    private String _filename;
    private int _linenum;

    public ConvertionException(String message, String filename, int linenum) {
        super(message);
        _filename = filename;
        _linenum  = linenum;
    }

    public String toString() {
        return super.toString() + "(filename " + _filename + ", line " + _linenum + ")";
    }

}

// --------------------------------------------------------------------------------

package __PACKAGE__;

import java.util.List;

public interface Converter {
    public Statement[] convert(String pdata);

    public String getFilename();
    public void setFilename(String filename);

    public List getElementList();
    public void addElement(Element element);

    public Expression[] expandEmbeddedExpression(String pdata, int linenum);

    //public void setProperty(String key, String value);
    //public String getProperty(String key);
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Properties;

public class DefaultConverter implements Converter {

    private String _pdata;
    private String _filename;
    private Map _properties = new HashMap();
    private int    _remained_linenum;
    private String _remained_text;
    private List _elementList = new ArrayList();
    private Map _handlerTable = new HashMap();
    private DirectiveHandler _handler;
    private TagHelper _helper;
    private Properties _props;
    private Map _noendTags = null;


    public DefaultConverter() {
        this(new Properties(Configuration.defaults));
    }

    public DefaultConverter(Properties props) {
        _props = props;
        _helper = new TagHelper(_props);
        _handler = new DirectiveHandler(this, _props);
        _registerHandlers(_handlerTable);
        //
        _noendTags = new HashMap();
        String noend = _props.getProperty("kwartz.noend");
        if (noend != null) {
            String[] tagnames = noend.split(",");
            for (int i = 0; i < tagnames.length; i++) {
                String tagname = tagnames[i].trim();
                if (tagname.length() > 0)
                  _noendTags.put(tagname, Boolean.TRUE);
            }
        }
    }

    //public String getProperty(String key) { _props.getProperty(key); }
    //public void setProperty(String key, String value) { _props.setProperty(key, value); }


    private boolean _isNoend(String tagname) {
        return _noendTags.containsKey(tagname);
    }


    public List getElementList() { return _elementList; }
    public void addElement(Element element) {
        _elementList.add(element);
    }

    public String getFilename() { return _filename; }
    public void setFilename(String filename) { _filename = filename; _helper.setFilename(filename); }

    protected static final String TAG_PATTERN = "([ \t]*)<(/?)([-:_\\w]+)((?:\\s+[-:_\\w]+=\"[^\"]*?\")*)(\\s*)(/?)>([ \t]*\r?\n?)";

    public List fetchAll(String pdata) {
        final Pattern tagPattern = Pattern.compile(TAG_PATTERN);
        _pdata = pdata;
        int index = 0;
        int linenum = 1;
        char lastchar = '\0';
        Matcher m = tagPattern.matcher(pdata);
        List list = new ArrayList();
        Tag data;
        while (m.find()) {
            data = new Tag();
            data.tag_str      = m.group(0);
            data.before_space = m.group(1);
            data.is_etag      = "/".equals(m.group(2));
            data.tagname      = m.group(3);
            data.attr_str     = m.group(4);
            data.extra_space  = m.group(5);
            data.is_empty     = "/".equals(m.group(6));
            data.after_space  = m.group(7);
            data.start_pos    = m.start();
            data.end_pos      = m.end();
            data.before_text  = pdata.substring(index, m.start());
            list.add(data);
            index = m.end();

            // linenum
            String before_text = data.before_text;
            int len = before_text.length();
            for (int i = 0; i < len; i++) {
                if (before_text.charAt(i) == '\n') linenum += 1;
            }
            data.linenum  = linenum;
            String tag_str = data.tag_str;
            len = tag_str.length();
            for (int i = 0; i < len; i++) {
                if (tag_str.charAt(i) == '\n') linenum += 1;
            }

            // is_begline, is_endline
            if (before_text.length() > 0) {
                data.is_begline = before_text.charAt(before_text.length() - 1) == '\n';
            } else {
                data.is_begline = lastchar == '\n' || lastchar == '\0';
            }
            lastchar = tag_str.charAt(tag_str.length() - 1);
            data.is_endline = lastchar == '\n';
        }

        // remained text
        _remained_linenum = linenum;
        _remained_text    = pdata.substring(index);

        return list;
    }


    public static void main(String[] args) {
        try {
            java.io.Writer writer = new java.io.OutputStreamWriter(System.out);
            StringBuffer sb = new StringBuffer();
            for (int i = 0; i < args.length; i++) {
                java.io.InputStream input = new java.io.FileInputStream(args[i]);
                java.io.Reader reader = new java.io.InputStreamReader(input);
                int ch;
                while ((ch = reader.read()) > 0) {
                    sb.append((char)ch);
                }
            }
            DefaultConverter converter = new DefaultConverter();
            List list = converter.fetchAll(sb.toString());
            for (Iterator it = list.iterator(); it.hasNext(); ) {
                Tag data = (Tag)it.next();
                System.out.println(data._inspect());
            }
        } catch (java.io.UnsupportedEncodingException ex) {
            ex.printStackTrace();
        } catch (java.io.IOException ex) {
            ex.printStackTrace();
        }
    }


    public Statement[] convert(String pdata) {
        final Pattern newlinePattern = Pattern.compile("\\r?\\n");
        if (! _properties.containsKey("newline")) {
            Matcher m = newlinePattern.matcher(pdata);
            if (m.find())  _properties.put("newline", m.group(0));
        }
        List datalist = fetchAll(pdata);
        Iterator it = datalist.iterator();
        List stmtList = new ArrayList();
        _convert(it, stmtList, null);
        if (_remained_text != null && _remained_text.length() > 0)
            stmtList.add(_helper.createPrintStatement(_remained_text, _remained_linenum));
        //return new BlockStatement.new(stmts);
        Statement[] stmts = new Statement[stmtList.size()];
        stmtList.toArray(stmts);
        return stmts;
    }


    private Expression _parseExpression(String str, int linenum) {
        return _helper.parseExpression(str, linenum);
    }


    private void _handleDirective(List stmtList, Tag stag, Tag etag, List bodyStmtList) {
        DirectiveHandlerIF handler = (DirectiveHandlerIF)_handlerTable.get(stag.directive_name);
        if (handler == null) {
            String msg = "'" + stag.directive_name + "': invalid directive name.";
            throw new ConvertionException(msg, _filename, stag.linenum);
        }
        handler.handle(stmtList, stag, etag, bodyStmtList);
    }


    private interface DirectiveHandlerIF {
        public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList);
    }

    private void _registerHandlers(Map handlerTable) {
        // mark
        handlerTable.put("mark", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleMarkDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        // value, Value, VALUE
        handlerTable.put("value", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleValueDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        handlerTable.put("Value", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleValueDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        handlerTable.put("VALUE", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleValueDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        // foreach, Foreach, FOREACH
        handlerTable.put("foreach", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleForeachDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        handlerTable.put("Foreach", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleForeachDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        handlerTable.put("FOREACH", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleForeachDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        // list, List, LIST
        handlerTable.put("list", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleListDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        handlerTable.put("List", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleListDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        handlerTable.put("LIST", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleListDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        // while, loop
        handlerTable.put("while", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleWhileDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        handlerTable.put("loop", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleLoopDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        // if, elseif, else
        handlerTable.put("if", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleIfDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        handlerTable.put("elseif", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleElseifDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        handlerTable.put("else", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleElseDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        // set
        handlerTable.put("set", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleSetDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        // dummy
        handlerTable.put("dummy", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleDummyDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        // replace, placeholder
        handlerTable.put("replace", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handleReplaceDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        handlerTable.put("placeholder", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handlePlaceholderDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        // include, Include, INCLUDE
        handlerTable.put("include", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handlePlaceholderDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        handlerTable.put("Include", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handlePlaceholderDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
        handlerTable.put("INCLUDE", new DirectiveHandlerIF() {
            public void handle(List stmtlist, Tag stag, Tag etag, List bodyStmtList) {
                DefaultConverter.this._handler.handlePlaceholderDirective(stmtlist, stag, etag, bodyStmtList);
            }
        });
    }


    private static final String ATTR_PATTERN = "(\\s*)([-:_\\w]+)=\"(.*?)\"";
    private static final String WORD_PATTERN = "\\A[-_\\w]+\\z";

    private void _parseAttributes(Tag tag) {
        final Pattern attrPattern = Pattern.compile(ATTR_PATTERN);
        Matcher m = attrPattern.matcher(tag.attr_str);
        Attr id_attr = null;
        Attr kd_attr = null;
        while (m.find()) {
            String aspace  = m.group(1);
            String aname   = m.group(2);
            String avalue  = m.group(3);
            if (tag.attrs == null) tag.attrs = new ArrayList();
            Attr attr = new Attr(aspace, aname, avalue);
            tag.attrs.add(attr);
            if (aname.equals("id")) id_attr = attr;
            else if (aname.equals("kw:d")) kd_attr = attr;
        }
        if (id_attr != null) {
            String id_value = (String)id_attr.value;
            _parseIdAttribute(id_value, tag);   // set tag.directive_name and tag.directive_arg
            final Pattern word_pat = Pattern.compile(WORD_PATTERN);
            if (! word_pat.matcher(id_value).find()) {
                tag.attrs.remove(id_attr);
            }
        }
        if (kd_attr != null) {
            String kd_value = (String)kd_attr.value;
            _parseKdAttribute(kd_value, tag);   // set tag.directive_name and tag.directive_arg
            tag.attrs.remove(kd_attr);
        }
    }

    private void _parseIdAttribute(String avalue, Tag tag) {
        final Pattern pat = Pattern.compile("\\A[-_\\w]+\\z");
        if (! pat.matcher(avalue).find()) {
            _parseKdAttribute(avalue, tag);
        } else if (avalue.indexOf('-') < 0) {  // is it need?
            tag.directive_name = "mark";
            tag.directive_arg  = avalue;
        }
    }

    private void _parseKdAttribute(String kdstr, Tag tag) {
        String directive_name = null;
        String directive_arg  = null;
        String[] directives = kdstr.split(";");
        final Pattern pat = Pattern.compile("\\A\\s*(\\w+):(.*)\\z");
        for (int i = 0; i < directives.length; i++) {
            Matcher m = pat.matcher(directives[i]);
            if (! m.find())
                throw new ConvertionException("'" + directives[i] + "': invalid directive.", _filename, tag.linenum);
            String dname = m.group(1);   // directive name
            String darg  = m.group(2);   // directive arg
            if (dname.equals("attr") || dname.equals("Attr") || dname.equals("ATTR")) {
                final Pattern p2 = Pattern.compile("\\A([-_\\w]+(?::[-_\\w]+)?)[:=](.*)\\z");
                Matcher m2 = p2.matcher(darg);
                if (! m2.find())
                    throw new ConvertionException("'" + directives[i] + "': invalid attr directive.", _filename, tag.linenum);
                String aname  = m2.group(1);
                String avalue = m2.group(2);
                String s;
                if      (dname.equals("attr"))   s = avalue;
                else if (dname.equals("Attr"))   s = "E(" + avalue + ")";
                else                             s = "X(" + avalue + ")";
                Expression expr = _helper.parseExpression(s, tag.linenum);
                Attr attr = null;
                if (tag.attrs == null) {
                    tag.attrs = new ArrayList();
                    attr = new Attr(" ", aname, expr);
                    tag.attrs.add(attr);
                } else {
                    for (int j = 0; j < tag.attrs.size(); j++) {
                        Attr attr2 = (Attr)tag.attrs.get(j);
                        if (aname.equals(attr2.name)) {
                            attr = attr2;
                            break;
                        }
                    }
                    if (attr == null) {
                        attr = new Attr(" ", aname, expr);
                        tag.attrs.add(attr);
                    } else {
                        attr.value = expr;
                    }
                }
            }
            else if (dname.equals("append") || dname.equals("Append") || dname.equals("APPEND")) {
                String s;
                if      (dname.equals("append")) s = darg;
                else if (dname.equals("Append")) s = "E(" + darg + ")";
                else                             s = "X(" + darg + ")";
                Expression expr = _helper.parseExpression(s, tag.linenum);
                if (tag.append_exprs == null) tag.append_exprs = new ArrayList();
                tag.append_exprs.add(expr);
            }
            else {
                if (! _handlerTable.containsKey(dname))
                    throw new ConvertionException("'" + dname + "': invalid directive name.", _filename, tag.linenum);
                if (directive_name != null) {
                    String msg = "directive '" + directive_name + "' and '" + dname + "': cannot specify two or more directives in an element.";
                    throw new ConvertionException(msg, _filename, tag.linenum);
                }
                directive_name = dname;
                directive_arg  = darg;
            }
        }
        tag.directive_name = directive_name;
        tag.directive_arg  = directive_arg;
    }


    public Expression[] expandEmbeddedExpression(String str, int linenum) {
        return _helper.expandEmbeddedExpression(str, linenum);
    }


    private Tag _convert(Iterator it, List stmtList, Tag startTag) {
        while (it.hasNext()) {
            Tag tag = (Tag)it.next();
            if (tag.before_text.length() > 0) {
                stmtList.add(_helper.createPrintStatement(tag.before_text, tag.linenum));
            }
            assert tag.tagname != null;
            if (tag.is_etag) {                                          // end-tag
                if (startTag != null && tag.tagname.equals(startTag.tagname)) {
                    return tag;   // return Tag of end-tag
                } else {
                    stmtList.add(_helper.createPrintStatement(tag.tag_str, tag.linenum));
                }
            }
            else if (tag.is_empty || _isNoend(tag.tagname)) {          // empty-tag
                _parseAttributes(tag);
                if (tag.directive_name == null) {
                    stmtList.add(_helper.buildPrintStatement(tag));
                } else {
                    List bodyStmtList = new ArrayList();
                    if (tag.directive_name.equals("mark")) {
                        // nothing
                    } else {
                        boolean tagDelete = tag.tagname.equals("span") && (tag.attrs == null || tag.attrs.size() == 0);
                        bodyStmtList.add(_helper.createTagPrintStatement(tag, tagDelete));
                    }
                    Tag stag = tag;
                    Tag etag = null;
                    _handleDirective(stmtList, stag, etag, bodyStmtList);
                }
            }
            else {                                                       // start-tag
                _parseAttributes(tag);
                boolean hasDirective = tag.directive_name != null;
                List bodyStmtList;
                if (hasDirective) {
                    bodyStmtList = new ArrayList();
                } else if (startTag != null && tag.tagname.equals(startTag.tagname)) {
                    bodyStmtList = stmtList;
                } else {
                    stmtList.add(_helper.buildPrintStatement(tag));
                    continue;
                }
                // handle stag
                Tag stag = tag;
                boolean tagSkip = hasDirective && tag.directive_name.equals("mark");
                boolean tagDelete = false;
                if (! tagSkip) {
                    tagDelete = stag.tagname.equals("span") && (stag.attrs == null || stag.attrs.size() == 0);
                    bodyStmtList.add(_helper.createTagPrintStatement(stag, tagDelete));
                }
                // handle content
                Tag etag = _convert(it, bodyStmtList, stag);
                // handle etag
                if (! tagSkip) {
                    bodyStmtList.add(_helper.createTagPrintStatement(etag, tagDelete));
                }
                // handle directive
                if (hasDirective) {
                    _handleDirective(stmtList, stag, etag, bodyStmtList);
                }
            }
        }  // end of while
        //
        if (startTag != null)
            throw new ConvertionException("'<" + startTag.tagname + ">' is not closed by end-tag.", _filename, startTag.linenum);
        return null;
    }

}

// --------------------------------------------------------------------------------

package __PACKAGE__;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.Iterator;

public class PresentationDeclaration {
    public String[]       names;
    public Expression     tagname;
    public List           remove;
    public Map            attrs;
    public List           append;
    public Expression     value;
    public BlockStatement plogic;

    public PresentationDeclaration() {
        this(null);
    }

    public PresentationDeclaration(String[] names) {
        this.names = names;
        remove = new ArrayList();
        attrs  = new HashMap();
        append = new ArrayList();
        //Statement[] stmts = {
        //    new ExpandStatement(ExpandStatement.STAG),
        //    new ExpandStatement(ExpandStatement.CONT),
        //    new ExpandStatement(ExpandStatement.ETAG),
        //};
        //plogic = new BlockStatement(stmts);
    }

    public StringBuffer _inspect() {
        return _inspect(0, new StringBuffer());
    }

    public StringBuffer _inspect(int level, StringBuffer sb) {
        if (names != null) {
            for (int i = 0; i < names.length; i++) {
                if (i > 0) sb.append(", ");
                sb.append("#" + names[i]);
            }
            sb.append(" ");
        }
        sb.append("{\n");
        if (tagname != null) {
            sb.append("  tagname:\n");
            tagname._inspect(2, sb);
        }
        if (remove != null && remove.size() > 0) {
            sb.append("  remove:\n");
            for (int i = 0; i < remove.size(); i++) {
                String aname = (String)remove.get(i);
                sb.append("    " + Utility.inspectString(aname) + "\n");
            }
        }
        if (attrs != null && attrs.size() > 0) {
            sb.append("  attrs:\n");
            for (Iterator it = attrs.keySet().iterator(); it.hasNext(); ) {
                String aname = (String)it.next();
                Expression expr = (Expression)attrs.get(aname);
                sb.append("    " + Utility.inspectString(aname) + "\n");
                expr._inspect(2, sb);
            }
        }
        if (append != null && append.size() > 0) {
            sb.append("  append:\n");
            for (int i = 0; i < append.size(); i++) {
                Expression expr = (Expression)append.get(i);
                expr._inspect(2, sb);
            }
        }
        if (value != null) {
            sb.append("  value:\n");
            value._inspect(2, sb);
        }
        if (plogic != null) {
            sb.append("  plogic:\n");
            plogic._inspect(2, sb);
        }
        sb.append("}\n");
        return sb;
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.Properties;

public class DeclarationParser extends Parser {

    private StatementParser  _stmtParser;
    private ExpressionParser _exprParser;

    public DeclarationParser() {
        this(new Scanner());
    }

    public DeclarationParser(Properties props) {
        this(new Scanner(props));
    }

    public DeclarationParser(Scanner scanner) {
        this(scanner, scanner.getProperties());
    }
    public DeclarationParser(Scanner scanner, Properties props) {
        this(scanner, props, true);
    }
    public DeclarationParser(Scanner scanner, Properties props, boolean flagInit) {
        super(scanner, props);
        _stmtParser = new StatementParser(scanner, props, false);
        _exprParser = _stmtParser.getExpressionParser();
        if (flagInit) _scanner.scan();
    }

    public StatementParser getStatementParser()   { return _stmtParser; }
    public ExpressionParser getExpressionParser() { return _exprParser; }

    public Properties getProperties() { return _props; }
    public String getProperty(String key) { return _props.getProperty(key); }
    //public String setProperty(String key, String value) { _props.setProperty(key, value); }


    public String getFilename() { return _stmtParser.getFilename(); }
    public void setFilename(String filename) { _stmtParser.setFilename(filename); }

    public List parse(String input) {
        _scanner.reset(input, 1);
        scan();
        List decls = parsePresentationDeclarations();
        if (getToken() != TokenType.EOF) {
            syntaxError("'" + TokenType.inspect(getToken(), getValue()) + "': unexpected token.");
        }
        return decls;
    }

    public List parsePresentationDeclarations() {
        List decls = new ArrayList();
        while (getToken() == TokenType.SHARP) {
            PresentationDeclaration decl = parsePresentationDeclaration();
            decls.add(decl);
        }
        return decls;
    }

    public PresentationDeclaration parsePresentationDeclaration() {
        assert getToken() == TokenType.SHARP;
        String name;
        List nameList = new ArrayList();
        int i = 0;
        while (true) {
            i += 1;
            if (getToken() != TokenType.SHARP)
                syntaxError("'#' required.");
            scan();
            if (getToken() != TokenType.NAME)
                syntaxError("'#': marking name required.");
            name = getValue();
            nameList.add(name);
            scan();
            if (getToken() != TokenType.COMMA) break;
            scan();
        }
        if (getToken() != TokenType.L_CURLY)
            syntaxError("presentation declaration '#" + name + "' requires '{'.");
        scan();
        PresentationDeclaration decl = parseDeclarationParts();
        String[] names = new String[nameList.size()];
        nameList.toArray(names);
        decl.names = names;
        if (getToken() != TokenType.R_CURLY)
            syntaxError("presentation declaration '#" + name + "' is not closed by '}'."
                        + "(token=" + TokenType.inspect(getToken(),getValue()) + ")");
        scan();
        return decl;
    }

    public static final Object PART_TAGNAME = "tagname";
    public static final Object PART_REMOVE  = "remove";
    public static final Object PART_ATTRS   = "attrs";
    public static final Object PART_APPEND  = "append";
    public static final Object PART_VALUE   = "value";
    public static final Object PART_PLOGIC  = "plogic";

    public static final Map _parts = new HashMap();
    static {
        _parts.put("tagname", PART_TAGNAME);
        _parts.put("remove",  PART_REMOVE);
        _parts.put("attrs",   PART_ATTRS);
        _parts.put("append",  PART_APPEND);
        _parts.put("value",   PART_VALUE);
        _parts.put("plogic",  PART_PLOGIC);
    }

    public PresentationDeclaration parseDeclarationParts() {
        PresentationDeclaration decl = new PresentationDeclaration();
        while (getToken() == TokenType.NAME) {
            Object part = _parts.get(getValue());
            if (part == null)
                syntaxError("part name required but got '" + getValue() + "'.");
            scan();
            if (getToken() != TokenType.COLON)
                syntaxError("'" + part + "' part requires ':'.");
            scan();
            if (false) /* nothing */ ;
            else if (part == PART_TAGNAME) parseTagnamePart(decl);
            else if (part == PART_REMOVE)  parseRemovePart(decl);
            else if (part == PART_ATTRS)   parseAttrsPart(decl);
            else if (part == PART_APPEND)  parseAppendPart(decl);
            else if (part == PART_VALUE)   parseValuePart(decl);
            else if (part == PART_PLOGIC)  parsePlogicPart(decl);
            else
              assert false;
        }
        return decl;
    }

    private void parseTagnamePart(PresentationDeclaration decl) {
        Expression expr = _exprParser.parseExpression();
        if (getToken() != TokenType.SEMICOLON)
          syntaxError("tagname part requires ';'.");
        scan();
        decl.tagname = expr;
    }

    private void parseRemovePart(PresentationDeclaration decl) {
        while (true) {
            Expression expr = _exprParser.parseExpression();
            if (expr.getToken() != TokenType.STRING)
              syntaxError("remove part requires attribute name.");
            String aname = ((StringExpression)expr).getValue();
            decl.remove.add(aname);
            if (getToken() != TokenType.COMMA) break;
            scan();
        }
        if (getToken() != TokenType.SEMICOLON)
          syntaxError("remove part requires ';'.");
        scan();
    }

    private void parseAttrsPart(PresentationDeclaration decl) {
        while (true) {
            Expression expr = _exprParser.parseExpression();
            if (expr.getToken() != TokenType.STRING)
              syntaxError("attrs part requires attribute name.");
            String aname = ((StringExpression)expr).getValue();
            expr = _exprParser.parseExpression();
            decl.attrs.put(aname, expr);
            if (getToken() != TokenType.COMMA) break;
            scan();
        }
        if (getToken() != TokenType.SEMICOLON)
          syntaxError("attrs part requires ';'.");
        scan();
    }

    private void parseAppendPart(PresentationDeclaration decl) {
        while (true) {
            Expression expr = _exprParser.parseExpression();
            decl.append.add(expr);
            if (getToken() != TokenType.COMMA) break;
            scan();
        }
        if (getToken() != TokenType.SEMICOLON)
          syntaxError("append part requires ';'.");
        scan();
    }

    private void parseValuePart(PresentationDeclaration decl) {
        Expression expr = _exprParser.parseExpression();
        decl.value = expr;
        if (getToken() != TokenType.SEMICOLON)
          syntaxError("value part requires ';'.");
        scan();
    }

    private void parsePlogicPart(PresentationDeclaration decl) {
        if (getToken() != TokenType.L_CURLY)
          syntaxError("plogic part requires '{'.");
        BlockStatement stmt = (BlockStatement)_stmtParser.parseBlockStatement();
        decl.plogic = stmt;
    }

}

// --------------------------------------------------------------------------------

package __PACKAGE__;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.io.Writer;
import java.io.StringWriter;
import java.io.IOException;

public class Template {

    private BlockStatement _blockStmt;
    private List _pdataFilenameList = null;
    private List _plogicFilenameList = null;
    private List _elemdefFilenameList = null;

    public Template(BlockStatement blockStmt) {
        _blockStmt = blockStmt;
    }

    public BlockStatement getBlockStatement() { return _blockStmt; }

    public String execute(Map context) throws IOException {
        StringWriter writer = null;
        try {
            writer = new StringWriter();
            _blockStmt.execute(context, writer);
            String s = writer.toString();
            return s;
        } finally {
            if (writer != null) writer.close();
        }
    }

    public void execute(Map context, Writer writer) throws IOException {
        _blockStmt.execute(context, writer);
    }

    public void addPresentationDataFilename(String filename) {
        if (_pdataFilenameList == null)
            _pdataFilenameList = new ArrayList();
        _pdataFilenameList.add(filename);
    }

    public void addPresentationLogicFilename(String filename) {
        if (_plogicFilenameList == null)
            _plogicFilenameList = new ArrayList();
        _plogicFilenameList.add(filename);
    }

    public void addElementDefinitionFilename(String filename) {
        if (_elemdefFilenameList == null)
            _elemdefFilenameList = new ArrayList();
        _elemdefFilenameList.add(filename);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

//public interface Compiler {
//    public Template compileString(String pdata, String plogic);
//    public Template compileString(String pdata, String plogic, String pdataFilename, String plogicFilename);
//    public Template compileFile(String pdataFilename, String plogicFilename) throws IOException;
//    public Template compileFile(String pdataFilename, String plogicFilename, String charset) throws IOException;
//    public void addPresentationLogic(String plogic);
//    public void addPresentationLogic(String plogic, String filename);
//    public void addPresentationData(String pdata);
//    public void addPresentationData(String pdata, String filename);
//    public Template getTemplate();
//
//}

import java.io.IOException;

abstract public class Compiler {

    abstract public Template compileString(String pdata, String plogic, String elemdecl,
                                           String pdataFilename, String plogicFilename, String elemdeclFilename);
    public Template compileString(String pdata, String plogic, String pdataFilename, String plogicFilename) {
        return compileString(pdata, plogic, null, pdataFilename, plogicFilename, null);
    }
    public Template compileString(String pdata, String plogic, String elemdecl) {
        return compileString(pdata, plogic, elemdecl, null, null, null);
    }
    public Template compileString(String pdata, String plogic) {
        return compileString(pdata, plogic, null, null, null, null);
    }

    public Template compileFile(String pdataFilename, String plogicFilename, String elemdeclFilename, String charset) throws IOException {
        // read files
        String pdata    = Utility.readFile(pdataFilename, charset);
        String plogic   = Utility.readFile(plogicFilename, charset);
        String elemdecl = Utility.readFile(elemdeclFilename, charset);
        return compileString(pdata, plogic, elemdecl, pdataFilename, plogicFilename, elemdeclFilename);
    }
    public Template compileFile(String pdataFilename, String plogicFilename, String charset) throws IOException {
        return compileFile(pdataFilename, plogicFilename, null, charset);
    }
    public Template compileFile(String pdataFilename, String plogicFilename) throws IOException {
        String charset = System.getProperty("file.encoding");
        return compileFile(pdataFilename, plogicFilename, null, charset);
    }

    abstract public void addPresentationLogic(String plogic, String filename);
    public void addPresentationLogic(String plogic) {
        addPresentationLogic(plogic, null);
    }
    public void addPresentationLogicFile(String filename, String charset) throws IOException {
        String plogic = Utility.readFile(filename, charset);
        addPresentationLogic(plogic, filename);
    }

    abstract public void addPresentationData(String pdata, String filename);
    public void addPresentationData(String pdata) {
        addPresentationData(pdata, null);
    }
    public void addPresentationDataFile(String filename, String charset) throws IOException {
        String pdata = Utility.readFile(filename, charset);
        addPresentationData(pdata, null);
    }

    abstract public void addElementDefinition(String elemdef, String filename);
    public void addElementDefinition(String elemdef) {
        addElementDefinition(elemdef, null);
    }
    public void addElementDefinitionFile(String filename, String charset) throws IOException {
        String elemdef = Utility.readFile(filename, charset);
        addElementDefinition(elemdef, filename);
    }

    abstract public Template getTemplate();

}

// --------------------------------------------------------------------------------

package __PACKAGE__;

import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.Properties;
import java.io.IOException;

public class DefaultCompiler extends Compiler {
    private ExpressionParser  _exprParser;
    private StatementParser   _stmtParser;
    private DeclarationParser _declParser;
    private Converter         _converter;
    private List              _stmtList  = new ArrayList();
    private List              _declList  = new ArrayList();
    private Map               _elemTable = new HashMap();
    private BlockStatement    _pdataBlock;
    private Properties        _props;

    public DefaultCompiler() {
        this(new Properties(Configuration.defaults));
    }
    public DefaultCompiler(Properties props) {
        _props = props;
        _converter  = new DefaultConverter(_props);
        _declParser = new DeclarationParser(_props);
        _stmtParser = _declParser.getStatementParser();
        _exprParser = _stmtParser.getExpressionParser();
    }


    public Template compileString(String pdata, String plogic, String elemdecl, String pdataFilename, String plogicFilename, String elemdeclFilename) {
        // convert elemdecl
        List elemList = null;
        Map elementTable = null;
        if (elemdecl != null) {
            _converter.setFilename(elemdeclFilename);
            _converter.convert(elemdecl);
            elemList = _converter.getElementList();
            elementTable = Element.createElementTable(elemList);
        }

        // convert pdata
        Statement[] stmts = null;
        if (pdata != null) {
            _converter.setFilename(pdataFilename);
            stmts = _converter.convert(pdata);
            elemList = _converter.getElementList();
            if (elementTable == null)
                elementTable = Element.createElementTable(elemList);
            else
                Element.addElementList(elementTable, elemList);
        }

        // parse plogic
        if (plogic != null) {
            _declParser.setFilename(plogicFilename);
            List declList = _declParser.parse(plogic);
            Element.mergeDeclarationList(elementTable, declList);
        }

        // create block statement
        BlockStatement blockStmt = new BlockStatement(stmts);

        // expand
        Expander expander = new DefaultExpander(elementTable, _props);
        expander.expand(blockStmt, null);

        // return template
        return new Template(blockStmt);
    }


    public void addPresentationLogic(String plogic, String filename) {
        _declParser.setFilename(filename);
        List declList = _declParser.parse(plogic);
        _declList.addAll(declList);
    }

    public void addPresentationData(String pdata, String filename) {
        _addPresentationData(pdata, filename, true);
    }

    public void addElementDefinition(String pdata, String filename) {
        _addPresentationData(pdata, filename, false);
    }

    private void _addPresentationData(String pdata, String filename, boolean addStatement) {
        _converter.setFilename(filename);
        Statement[] stmts = _converter.convert(pdata);
        if (addStatement)
            for (int i = 0; i < stmts.length; i++)
                _stmtList.add(stmts[i]);
        List elemList = _converter.getElementList();
        Element.addElementList(_elemTable, elemList);
    }

    public Template getTemplate() {
        // merge element table and declaration list
        Element.mergeDeclarationList(_elemTable, _declList);
        // create block statement
        BlockStatement blockStmt = new BlockStatement(_stmtList);
        // expand @stag, @cont, and @etag
        Expander expander = new DefaultExpander(_elemTable);
        expander.expand(blockStmt, null);
        // return template
        return new Template(blockStmt);
    }

}

// --------------------------------------------------------------------------------

package __PACKAGE__;

import java.util.Map;
import java.util.HashMap;
import java.util.Properties;
import java.util.Enumeration;
import java.util.Iterator;
import java.io.InputStream;
import java.io.IOException;

public class Configuration {

    public static Properties defaults = new Properties();
    //public static Map functions = new HashMap();

    static {
        Configuration.initProperties();
        Configuration.registerMacros(defaults);
        Configuration.registerFunctions(defaults);
    }

    private static void initProperties() {
        // default properties
        InputStream stream = null;
        try {
            String filename = "kwartz.properties";
            stream = Configuration.class.getResourceAsStream(filename);
            defaults.load(stream);
        }
        catch (IOException ex) {
            ex.printStackTrace();    // logging
        }
        finally {
            if (stream != null) {
                try {
                    stream.close();
                } catch (IOException ex) {
                    ex.printStackTrace();  // logging
                }
            }
        }
    }

    static void registerMacros(Properties props) {
        registerObjects(props, Macro.instances(), "kwartz.macro.", true);
    }
    static void registerFunctions(Properties props) {
        registerObjects(props, Function.instances(), "kwartz.function.", true);
    }

    private static void registerObjects(Properties props, Map map, String prefix, boolean flagOverride) {  // move to Function class?
        for (Enumeration en = props.propertyNames(); en.hasMoreElements(); ) {
            String pname = (String)en.nextElement();
            if (pname.startsWith(prefix)) {  // "kwartz.macro." or "kwartz.function."
                String name  = pname.substring(prefix.length());
                if (!flagOverride && map.get(name) != null)
                    continue;
                String classname = (String)props.getProperty(pname);
                try {
                    Object obj = Class.forName(classname).newInstance();  // Macro or Function
                    map.put(name, obj);
                } catch (ClassNotFoundException ex) {
                    ex.printStackTrace();		// logging
                } catch (IllegalAccessException ex) {
                    ex.printStackTrace();		// logging
                } catch (InstantiationException ex) {
                    ex.printStackTrace();		// logging
                }
            }
        }
    }

}

// --------------------------------------------------------------------------------

package __PACKAGE__;

import java.util.Map;
import java.util.HashMap;
import java.util.Properties;
import java.util.Enumeration;
import java.io.IOException;

public class Kwartz {

    private Map _cache;
    private Properties _props;
    //private Map _functions;

    public Kwartz() {
        this(null);
    }
    public Kwartz(Properties props) {
        _cache     = new HashMap();  // or new WeakHashMap();
        _props     = new Properties(Configuration.defaults);
        //_functions = new HashMap(Configuration.functions);
        if (props != null) {
            for (Enumeration en = props.propertyNames(); en.hasMoreElements(); ) {
                String pname = (String)en.nextElement();
                String pvalue = props.getProperty(pname);
                _props.setProperty(pname, pvalue);
            }
            Configuration.registerMacros(props);
            Configuration.registerFunctions(props);
        }
    }

    public Properties getProperties() { return _props; }
    public String getProperty(String key) { return _props.getProperty(key); }
    //public String setProperty(String key, String value) { _props.setProperty(key, value); }


    public Template getTemplate(Object key, String pdataFilename, String plogicFilename, String elemdeclFilename, String charset) throws IOException {
        Template template = (Template)_cache.get(key);
        if (template == null) {
            synchronized(_cache) {
                if (template == null) {
                    template = compileFile(pdataFilename, plogicFilename, elemdeclFilename, charset);
                    addTemplate(key, template);
                }
            }
        }
        return template;
    }

    public Template compileFile(String pdataFilename, String plogicFilename, String elemdeclFilename, String charset) throws IOException {
        Compiler compiler = new DefaultCompiler(_props);
        Template template = compiler.compileFile(pdataFilename, plogicFilename, elemdeclFilename, charset);
        Optimizer optimizer = new Optimizer(_props);
        optimizer.optimize(template.getBlockStatement());
        return template;
    }

    public Template compileString(String pdata, String plogic, String elemdecl, String charset) throws IOException {
        Compiler compiler = new DefaultCompiler(_props);
        Template template = compiler.compileString(pdata, plogic, elemdecl, charset);
        Optimizer optimizer = new Optimizer(_props);
        optimizer.optimize(template.getBlockStatement());
        return template;
    }


    public Template getTemplate(Object key) {
        return (Template)_cache.get(key);
    }

    public void addTemplate(Object key, Template template) {
        _cache.put(key, template);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;

import java.util.HashMap;

public class Context extends HashMap {
    public void putAll(Object[][] tuples) {
        for (int i = 0; i < tuples.length; i++) {
            Object[] tuple = tuples[i];
            Object key   = tuple[0];
            Object value = tuple[1];
            this.put(key, value);
        }
    }
}

// --------------------------------------------------------------------------------
package __PACKAGE__;
import junit.framework.TestCase;
import java.util.*;
import java.io.*;

public class KwartzClassTest extends TestCase {

    private String _pdata = null;
    private String _plogic = null;
    private String _elemdef = null;
    private Context _context = new Context();
    private Properties _props = new Properties();
    private String _expected = null;
    

    private static final String PREFIX = ".KwartzClassTest";
    private static final String CHARSET = System.getProperty("file.encoding");

    public void _test(String basename) {
        String pdataFilename   = _pdata   == null ? null : PREFIX + basename + ".html";
        String plogicFilename  = _plogic  == null ? null : PREFIX + basename + ".plogic";
        String elemdefFilename = _elemdef == null ? null : PREFIX + basename + ".elem.html";

        try {
            _createFile(pdataFilename, _pdata);
            _createFile(plogicFilename, _plogic);
            _createFile(elemdefFilename, _elemdef);
            Kwartz kwartz = new Kwartz(_props);
            String cacheKey = basename;
            Template template = kwartz.getTemplate(cacheKey, pdataFilename, plogicFilename, elemdefFilename, CHARSET);
            //System.err.println("*** debug: template=" + template.getBlockStatement()._inspect() + ".");
            StringWriter writer = new StringWriter();
            template.execute(_context, writer);
            String actual = writer.toString();
            writer.close();
            assertEquals(_expected, actual);
        }
        catch (IOException ex) {
            //ex.printStackTrace();
            fail(ex.getMessage());
        }
        finally {
            _deleteFile(pdataFilename);
            _deleteFile(plogicFilename);
            if (_elemdef != null) _deleteFile(elemdefFilename);
        }
    }

    private void _createFile(String filename, String content) throws IOException {
        if (content == null) return;
        OutputStream output = new FileOutputStream(filename);
        Writer writer = new OutputStreamWriter(output, CHARSET);
        writer.write(content);
        writer.flush();
    }

    private void _deleteFile(String filename) {
        File file = new File(filename);
        file.delete();
    }


    public void testGetTemplate1() {   // kwartz properties for Kwartz()
        _pdata = <<'END';
                <html>
                 <body>
                  <table id="LIST:item=list">
                   <tr id="mark:list">
                    <td><a href="#" id="mark:item">foo</a></td><td>@{item}@</td>
                   </tr>
                  </table>
                 </body>
                </html>
                END
        _plogic = <<'END';
                #list {
                  attrs:  "bgcolor" item_tgl;
                  //attrs: "bgcolor" color;
                  //plogic: {
                  //  i = 0;
                  //  foreach (item in list) {
                  //    i += 1;
                  //    color = i % 2 == 0 ? "#FFCCCC" : "#CCCCFF";
                  //    @stag;
                  //    @cont;
                  //    @etag;
                  //  }
                  //}
                }
                #item {
                  value: X(item);
                  attrs: "href" E("?id=" .+ item .+ "&page=_top");
                }
                END
        _expected = <<'END';
                <html>
                 <body>
                  <table>
                   <tr bgcolor="#CCCCFF">
                    <td><a href="?id=foo&amp;page=_top">foo</a></td><td>foo</td>
                   </tr>
                   <tr bgcolor="#FFCCCC">
                    <td><a href="?id=&lt;b&gt;bar&lt;/b&gt;&amp;page=_top"><b>bar</b></a></td><td>&lt;b&gt;bar&lt;/b&gt;</td>
                   </tr>
                  </table>
                 </body>
                </html>
                END
        _context.put("list", new String[] { "foo", "<b>bar</b>" });
        _props.setProperty("kwartz.escape", "true");         // kwartz.escape
        _props.setProperty("kwartz.even", "'#FFCCCC'");      // kwartz.even
        _props.setProperty("kwartz.odd",  "'#CCCCFF'");      // kwartz.odd
        _test("1");
    }
}

// --------------------------------------------------------------------------------
package __PACKAGE__;
import junit.framework.TestCase;
import java.util.*;
import java.io.*;

public class CompilerTest extends TestCase {
    String _plogic;
    String _pdata;
    String _expected;
    Map    _context = new HashMap();
    Properties _props = new Properties(Configuration.defaults);

    private void _test() throws Exception {
        _test(false);
    }

    private void _test(boolean flagPrint) throws Exception {
        Compiler compiler = new DefaultCompiler(_props);
        //compiler.addPresentationLogic(_plogic);
        //compiler.addPresentationData(_pdata);
        //BlockStatement stmt = compiler.getBlockStatement();
        Template template = compiler.compileString(_pdata, _plogic);
        Writer writer = new StringWriter();
        template.execute(_context, writer);
        String actual = writer.toString();
        writer.close();
        if (flagPrint)
            System.out.println(actual);
        else
            assertEquals(_expected, actual);
    }

    public void testCompile01() throws Exception {
        _pdata = <<'END';
            Hello <strong id="mark:user">World</strong>!
            END
        _plogic = <<'END';
            #user {
              value: user;
            }
            END
        _expected = <<'END';
            Hello <strong>Kwartz</strong>!
            END
        _context.put("user", "Kwartz");
        _test();
    }

    public void testCompile02() throws Exception {
        _pdata = <<'END';
            <ul id="mark:list">
              <li>@{item}@</li>
            </ul>
            END
        _plogic = <<'END';
            #list {
                plogic: {
                    foreach (item in list) {
                        @stag;  // start tag
                        @cont;  // content
                        @etag;  // end tag
                    }
                }
            }
            END
        _expected = <<'END';
            <ul>
              <li>foo</li>
            </ul>
            <ul>
              <li>bar</li>
            </ul>
            <ul>
              <li>baz</li>
            </ul>
            END
        List list = java.util.Arrays.asList(new Object[] { "foo", "bar", "baz", });
        _context.put("list", list);
        _test();
    }


    public void testCompile03() throws Exception {
        _pdata = <<'END';
            <table id="table">
              <tr class="odd" style="color:red" id="mark:list">
                <td id="mark:name" style="font-weight:bold">foo</td>
                <td><a href="..." id="mark:mail">foo@mail.org</a></td>
              </tr>
              <tr class="even" id="mark:dummy">
                <td>bar</td>
                <td>bar@mail.net</td>
              </tr>
            </table>
            END
        _plogic = <<'END';
            #table {
                tagname:  "html:table";
                append:   flag ? ' align="center"' : '';
            }
            #list {
                attrs:  "class" klass;
                remove: "style", "width";
                plogic: {
                    i = 0;
                    foreach (item in list) {
                        i += 1;
                        klass = i % 2 == 0 ? 'even' : 'odd';
                        @stag;
                        @cont;
                        @etag;
                    }
                }
            }
            #name {
              value: item.name;
            }
            #mail {
              value:  item.email;
              attrs:  "href" "mailto:" .+ item.email;
            }
            #dummy {
              plogic: { }
            }
            END
        _expected = <<'END';
            <html:table id="table" align="center">
              <tr class="odd">
                <td style="font-weight:bold">Foo</td>
                <td><a href="mailto:foo@foo.org">foo@foo.org</a></td>
              </tr>
              <tr class="even">
                <td style="font-weight:bold">Bar</td>
                <td><a href="mailto:bar@bar.org">bar@bar.org</a></td>
              </tr>
              <tr class="odd">
                <td style="font-weight:bold">Baz</td>
                <td><a href="mailto:baz@baz.org">baz@baz.org</a></td>
              </tr>
            </html:table>
            END
        List list = java.util.Arrays.asList(new Object[] {
            new CompilerTest.User("Foo", "foo@foo.org"),
            new CompilerTest.User("Bar", "bar@bar.org"),
            new CompilerTest.User("Baz", "baz@baz.org"),
        });
        _context.put("list", list);
        _context.put("flag", Boolean.TRUE);
        _test();
    }

    public static class User {
        private String name;
        private String email;
        public User(String name, String email) {
            this.name = name;
            this.email = email;
        }
        public String getName() { return name; }
        public String getEmail() { return email; }
    }


    public void testCompile05() throws Exception {  // escape
        _pdata = <<'END';
            <a href="#" id="mark:name">foo</a>
            <b id="value:str">foo</b><b id="value:E(str)">foo</b><b id="value:X(str)">foo</b>
            <i id="value:str">foo</i><i id="Value:str">foo</i><i id="VALUE:str">foo</i>
            END
        _plogic = <<'END';
            #name {
               value:  user;
               attrs:  "href" email;
            }
            END
        _props.setProperty("kwartz.escape", "true");
        _expected = <<'END';
            <a href="ab@mail.com?a=1&amp;b=2">&lt;em&gt;A&amp;B&lt;/em&gt;</a>
            <b>&lt;em&gt;A&amp;B&lt;/em&gt;</b><b>&lt;em&gt;A&amp;B&lt;/em&gt;</b><b><em>A&B</em></b>
            <i>&lt;em&gt;A&amp;B&lt;/em&gt;</i><i>&lt;em&gt;A&amp;B&lt;/em&gt;</i><i><em>A&B</em></i>
            END
        _context.put("user",   "<em>A&B</em>");
        _context.put("email",  "ab@mail.com?a=1&b=2");
        _context.put("str",    "<em>A&B</em>");
        _test();
    }


/*
    public void testCompileXX() throws Exception {
        _plogic = <<'END';
            END
        _pdata = <<'END';
            END
        _expected = <<'END';
            END
        List list = java.util.Arrays.asList(new Object[] { "foo", "bar", "baz", });
        _context.put("list", list);
        _test();
    }
*/

}

// --------------------------------------------------------------------------------

package __PACKAGE__;

public class CommandOptionException extends BaseException {
    public CommandOptionException(String message) {
        super(message);
    }
}

// --------------------------------------------------------------------------------
package __PACKAGE__;

import java.util.List;
import java.util.ArrayList;

public class Main implements Runnable {
    private String[]  _args;
    private List      _plogicFilenameList = new ArrayList();
    private String    _action = "compile";

    public Main(String[] args) {
        _args = args;
    }

    public void run() {
        int i = 0;
        for (i = 0; i < _args.length && _args[i].charAt(0) == '-'; i++) {
            String optstr = _args[i];
            if (optstr.equals("-p")) {  // presentation logic filenames
                i++;
                if (i >= _args.length)
                    throw new CommandOptionException("-p: presentation logic filename required.");
                String[] filenames = _args[i].split(",");
                for (int j = 0; j < filenames.length; j++) {
                    _plogicFilenameList.add(filenames[i]);
                }
            }
            else if (optstr.equals("-a")) {
                i++;
                if (i >= _args.length)
                    throw new CommandOptionException("-a: action name required.");
                _action = _args[i];
            }
            else {
                throw new CommandOptionException(optstr + ": invalid command-line option.");
            }
        }
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import junit.framework.TestCase;
import java.util.*;

public class OptimizerTest extends TestCase {

    String _pdata;
    String _plogic;
    String _compiled;
    String _optimized;

    private void _test() {
        _test(false);
    }

    private void _test(boolean flagPrint) {
        // parse plogic
        DeclarationParser declParser = new DeclarationParser();
        List declList = declParser.parse(_plogic);

        // parse pdata
        Converter converter = new DefaultConverter();
        Statement[] stmts = converter.convert(_pdata);

        // create block statement
        BlockStatement blockStmt = new BlockStatement(stmts);

        // create element table
        List elemList = converter.getElementList();
        Map elementTable = Element.createElementTable(elemList);

        // merge declarations
        Element.mergeDeclarationList(elementTable, declList);

        // expand
        Expander expander = new DefaultExpander(elementTable);
        expander.expand(blockStmt, null);
        //if (flagPrint) System.out.println(blockStmt._inspect().toString());

        // optimize
        Optimizer optimizer = new Optimizer();
        optimizer.optimize(blockStmt);

        // assert
        String actual = blockStmt._inspect().toString();
        if (flagPrint) {
            System.out.println(actual);
        } else {
            assertEquals(_optimized, actual);
        }
    }


    public void testOptimizer01() {
        _pdata = <<'END';
            Hello <strong id="mark:user">World</strong>!
            END
        _plogic = <<'END';
            #user {
              value: user;
            }
            END
        _compiled = <<'END';
            :block
              :print
                "Hello"
              :block
                :print
                  " <strong"
                  ">"
                :print
                  user
                :print
                  "</strong>"
              :print
                "!\n"
            END
        _optimized = <<'END';
            :block
              :print
                "Hello <strong>"
                user
                "</strong>!\n"
            END
        _test();
    }


    public void testOptimizer02() {
        _pdata = <<'END';
            <ul id="mark:list">
              <li>@{item}@</li>
            </ul>
            END
        _plogic = <<'END';
            #list {
                plogic: {
                    foreach (item in list) {
                        @stag;  // start tag
                        @cont;  // content
                        @etag;  // end tag
                    }
                }
            }
            END
        _compiled = <<'END';
            :block
              :block
                :foreach
                  item
                  list
                  :block
                    :print
                      "<ul"
                      ">\n"
                    :block
                      :print
                        "  <li>"
                      :print
                        item
                      :print
                        "</li>\n"
                    :print
                      "</ul>\n"
            END
        _optimized = <<'END';
            :block
              :foreach
                item
                list
                :block
                  :print
                    "<ul>\n  <li>"
                    item
                    "</li>\n</ul>\n"
            END
        _test();

        _plogic = <<'END';
            #list {
                plogic: {
                    @stag;  // start tag
                    foreach (item in list) {
                        @cont;  // content
                    }
                    @etag;  // end tag
                }
            }
            END
        _compiled = <<'END';
            :block
              :block
                :print
                  "<ul"
                  ">\n"
                :foreach
                  item
                  list
                  :block
                    :block
                      :print
                        "  <li>"
                      :print
                        item
                      :print
                        "</li>\n"
                :print
                  "</ul>\n"
            END
        _optimized = <<'END';
            :block
              :print
                "<ul>\n"
              :foreach
                item
                list
                :block
                  :print
                    "  <li>"
                    item
                    "</li>\n"
              :print
                "</ul>\n"
            END
        _test();
    }

    public void testOptimizer03() {
        _pdata = <<'END';
            <table id="table">
              <tr class="odd" style="color:red" id="mark:list">
                <td id="mark:name" style="font-weight:bold">foo</td>
                <td><a href="..." id="mark:mail">foo@mail.org</a></td>
              </tr>
              <tr class="even" id="mark:dummy">
                <td>bar</td>
                <td>bar@mail.net</td>
              </tr>
            </table>
            END
        _plogic = <<'END';
            #table {
                tagname:  "html:table";
                append:   flag ? ' align="center"' : '';
            }
            #list {
                attrs:  "class" klass;
                remove: "style", "width";
                plogic: {
                    i = 0;
                    foreach (item in list) {
                        i += 1;
                        klass = i % 2 == 0 ? 'even' : 'odd';
                        @stag;
                        @cont;
                        @etag;
                    }
                }
            }
            #name {
              value: item.name;
            }
            #mail {
              value:  item.email;
              attrs:  "href" "mailto:" .+ item.email;
            }
            #dummy {
              plogic: { }
            }
            END
        _compiled = <<'END';
            :block
              :block
                :print
                  "<html:table id=\""
                  "table"
                  "\""
                  ?:
                    flag
                    " align=\"center\""
                    ""
                  ">\n"
                :block
                  :block
                    :expr
                      =
                        i
                        0
                    :foreach
                      item
                      list
                      :block
                        :expr
                          +=
                            i
                            1
                        :expr
                          =
                            klass
                            ?:
                              ==
                                %
                                  i
                                  2
                                0
                              "even"
                              "odd"
                        :print
                          "  <tr class=\""
                          klass
                          "\""
                          ">\n"
                        :block
                          :block
                            :print
                              "    <td style=\""
                              "font-weight:bold"
                              "\""
                              ">"
                            :print
                              .
                                item
                                name
                            :print
                              "</td>\n"
                          :print
                            "    <td>"
                          :block
                            :print
                              "<a href=\""
                              .+
                                "mailto:"
                                .
                                  item
                                  email
                              "\""
                              ">"
                            :print
                              .
                                item
                                email
                            :print
                              "</a>"
                          :print
                            "</td>\n"
                        :print
                          "  </tr>\n"
                  :block
                :print
                  "</html:table>\n"
            END
        _optimized = <<'END';
            :block
              :print
                "<html:table id=\"table\""
                ?:
                  flag
                  " align=\"center\""
                  ""
                ">\n"
              :expr
                =
                  i
                  0
              :foreach
                item
                list
                :block
                  :expr
                    +=
                      i
                      1
                  :expr
                    =
                      klass
                      ?:
                        ==
                          %
                            i
                            2
                          0
                        "even"
                        "odd"
                  :print
                    "  <tr class=\""
                    klass
                    "\">\n    <td style=\"font-weight:bold\">"
                    .
                      item
                      name
                    "</td>\n    <td><a href=\""
                    .+
                      "mailto:"
                      .
                        item
                        email
                    "\">"
                    .
                      item
                      email
                    "</a></td>\n  </tr>\n"
              :print
                "</html:table>\n"
            END
        _test();
    }


    public void testOptimizer04() {  // add attributes
        _pdata = <<'END';
            <img title="example image" src="dummy.png" id="mark:image">
            END
        _plogic = <<'END';
            #image {
                attrs:  "src"  image_url, "class" klass;
            }
            END
        _compiled = <<'END';
            :block
              :block
                :print
                  "<img title=\""
                  "example image"
                  "\" src=\""
                  image_url
                  "\" class=\""
                  klass
                  "\""
                  ">\n"
                :block
                :print
            END
        _optimized = <<'END';
            :block
              :print
                "<img title=\"example image\" src=\""
                image_url
                "\" class=\""
                klass
                "\">\n"
            END
        _test();
    }


}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import junit.framework.TestCase;
import java.util.*;

public class ExpanderTest extends TestCase {
    String _pdata;
    String _plogic;
    String _expected;
    Properties _props = new Properties(Configuration.defaults);

    private void _test() {
        _test(false);
    }

    private void _test(boolean flagPrint) {
        // parse plogic
        DeclarationParser declParser = new DeclarationParser(_props);
        List declList = declParser.parse(_plogic);

        // parse pdata
        Converter converter = new DefaultConverter(_props);
        Statement[] stmts = converter.convert(_pdata);

        // create block statement
        BlockStatement blockStmt = new BlockStatement(stmts);

        // create element table
        List elemList = converter.getElementList();
        Map elementTable = Element.createElementTable(elemList);

        // merge declarations
        Element.mergeDeclarationList(elementTable, declList);

        // expand
        Expander expander = new DefaultExpander(elementTable, _props);
        expander.expand(blockStmt, null);

        // assert
        String actual = blockStmt._inspect().toString();
        if (flagPrint) {
            System.out.println("*** debug: kwartz.escape = " + _props.getProperty("kwartz.escape"));
            System.out.println(actual);
        } else {
            assertEquals(_expected, actual);
        }
    }

    public void testExpand01() {
        _pdata = <<'END';
            Hello <strong id="mark:user">World</strong>!
            END
        _plogic = <<'END';
            #user {
              value: user;
            }
            END
        _expected = <<'END';
            :block
              :print
                "Hello"
              :block
                :print
                  " <strong"
                  ">"
                :print
                  user
                :print
                  "</strong>"
              :print
                "!\n"
            END
        _test();
    }


    public void testExpand02() {
        _pdata = <<'END';
            <ul id="mark:list">
              <li>@{item}@</li>
            </ul>
            END
        _plogic = <<'END';
            #list {
                plogic: {
                    foreach (item in list) {
                        @stag;  // start tag
                        @cont;  // content
                        @etag;  // end tag
                    }
                }
            }
            END
        _expected = <<'END';
            :block
              :block
                :foreach
                  item
                  list
                  :block
                    :print
                      "<ul"
                      ">\n"
                    :block
                      :print
                        "  <li>"
                      :print
                        item
                      :print
                        "</li>\n"
                    :print
                      "</ul>\n"
            END
        _test();

        _plogic = <<'END';
            #list {
                plogic: {
                    @stag;  // start tag
                    foreach (item in list) {
                        @cont;  // content
                    }
                    @etag;  // end tag
                }
            }
            END
        _expected = <<'END';
            :block
              :block
                :print
                  "<ul"
                  ">\n"
                :foreach
                  item
                  list
                  :block
                    :block
                      :print
                        "  <li>"
                      :print
                        item
                      :print
                        "</li>\n"
                :print
                  "</ul>\n"
            END
        _test();
    }


    public void testExpand03() {
        _pdata = <<'END';
            <table id="table">
              <tr class="odd" style="color:red" id="mark:list">
                <td id="mark:name" style="font-weight:bold">foo</td>
                <td><a href="..." id="mark:mail">foo@mail.org</a></td>
              </tr>
              <tr class="even" id="mark:dummy">
                <td>bar</td>
                <td>bar@mail.net</td>
              </tr>
            </table>
            END
        _plogic = <<'END';
            #table {
                tagname:  "html:table";
                append:   flag ? ' align="center"' : '';
            }
            #list {
                attrs:  "class" klass;
                remove: "style", "width";
                plogic: {
                    i = 0;
                    foreach (item in list) {
                        i += 1;
                        klass = i % 2 == 0 ? 'even' : 'odd';
                        @stag;
                        @cont;
                        @etag;
                    }
                }
            }
            #name {
              value: item.name;
            }
            #mail {
              value:  item.email;
              attrs:  "href" "mailto:" .+ item.email;
            }
            #dummy {
              plogic: { }
            }
            END
        _expected = <<'END';
            :block
              :block
                :print
                  "<html:table id=\""
                  "table"
                  "\""
                  ?:
                    flag
                    " align=\"center\""
                    ""
                  ">\n"
                :block
                  :block
                    :expr
                      =
                        i
                        0
                    :foreach
                      item
                      list
                      :block
                        :expr
                          +=
                            i
                            1
                        :expr
                          =
                            klass
                            ?:
                              ==
                                %
                                  i
                                  2
                                0
                              "even"
                              "odd"
                        :print
                          "  <tr class=\""
                          klass
                          "\""
                          ">\n"
                        :block
                          :block
                            :print
                              "    <td style=\""
                              "font-weight:bold"
                              "\""
                              ">"
                            :print
                              .
                                item
                                name
                            :print
                              "</td>\n"
                          :print
                            "    <td>"
                          :block
                            :print
                              "<a href=\""
                              .+
                                "mailto:"
                                .
                                  item
                                  email
                              "\""
                              ">"
                            :print
                              .
                                item
                                email
                            :print
                              "</a>"
                          :print
                            "</td>\n"
                        :print
                          "  </tr>\n"
                  :block
                :print
                  "</html:table>\n"
            END
        _test();
    }


    public void testExpand04() {  // add attributes
        _pdata = <<'END';
            <img title="example image" src="dummy.png" id="mark:image">
            END
        _plogic = <<'END';
            #image {
                attrs:  "src"  image_url, "class" klass;
            }
            END
        _expected = <<'END';
            :block
              :block
                :print
                  "<img title=\""
                  "example image"
                  "\" src=\""
                  image_url
                  "\" class=\""
                  klass
                  "\""
                  ">\n"
                :block
                :print
            END
        _test();
    }


    public void testExpand11() {  // escape
        _pdata = <<'END';
            <td id="mark:name">foo</td><td>@{email}@</td>
            END
        _plogic = <<'END';
            #name {  value:  name; }
            END
        _props.setProperty("kwartz.escape", "true");
        _expected = <<'END';
            :block
              :block
                :print
                  "<td"
                  ">"
                :print
                  E()
                    name
                :print
                  "</td>"
              :print
                "<td>"
              :print
                E()
                  email
              :print
                "</td>\n"
            END
        _test();
    }


    public void testExpand12() {  // escape with E() and X()
        _pdata = <<'END';
            <td id="Value:name">foo</td><td>@{X(email)}@</td>
            END
        _plogic = <<'END';
            END
        _props.setProperty("kwartz.escape", "true");
        _expected = <<'END';
            :block
              :print
                "<td>"
              :print
                E()
                  name
              :print
                "</td>"
              :print
                "<td>"
              :print
                X()
                  email
              :print
                "</td>\n"
            END
        _test();
    }


/*
    public void testExpandXX() {
        _pdata = <<'END';
            END
        _plogic = <<'END';
            END
        _expected = <<'END';
            END
        _test();
    }
*/

}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import junit.framework.TestCase;
import java.util.*;

public class TagHelperTest extends TestCase {

    private String _input;
    private String _expected;
    private String _actual;
    private TagHelper _helper = new TagHelper();

    public void testConverter01() throws Exception {   // _parseExpression()
        _input    = "x+y*z";
        _expected = <<'END';
            +
              x
              *
                y
                z
            END
        Expression expr = _helper.parseExpression(_input, 1);
        _actual = expr._inspect().toString();
        assertEquals(_expected, _actual);
    }

    public void testConverter02() throws Exception {  // _parseExpression()
        _input    = "x+y*z 100";
        _expected = "";
        try {
            Expression expr = _helper.parseExpression(_input, 1);
            fail("ConversionException expected but nothing happened.");
        } catch (ConvertionException ex) {
            // OK
        }
    }

    public void testConvert03() throws Exception {  // expandEmbeddedExpression()
        _input    = <<'END';
             <span id="@{user.id}@">Hello @{user[:name]}@!</span>
             END
        Expression[] exprs = _helper.expandEmbeddedExpression(_input, 1);
        assertEquals(5, exprs.length);
        assertEquals(StringExpression.class, exprs[0].getClass());
        assertEquals("<span id=\"", ((StringExpression)exprs[0]).getValue());
        assertEquals(PropertyExpression.class, exprs[1].getClass());
        assertEquals(StringExpression.class, exprs[2].getClass());
        assertEquals("\">Hello ", ((StringExpression)exprs[2]).getValue());
        assertEquals(IndexExpression.class, exprs[3].getClass());
        assertEquals(StringExpression.class, exprs[4].getClass());
        assertEquals("!</span>\n", ((StringExpression)exprs[4]).getValue());
        //
        _input    = "foo@{var}@";
        exprs = _helper.expandEmbeddedExpression(_input, 1);
        assertEquals(2, exprs.length);
        //
        _input    = "@{var}@foo";
        exprs = _helper.expandEmbeddedExpression(_input, 1);
        assertEquals(2, exprs.length);
        //
        _input    = <<'END';
             <body>
              <span id="@{user.id}@">Hello @{user[:name].+}@!</span>
             </body>
             END
        try {
            exprs = _helper.expandEmbeddedExpression(_input, 1);
            fail("SyntaxException expected but not happened.");
        } catch (SyntaxException ex) {
            // OK
        }
    }

}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import junit.framework.TestCase;
import java.util.*;

public class ConverterTest extends TestCase {

    public void _testFetchAll(String input, String expected) {
        DefaultConverter converter = new DefaultConverter();
        List list = converter.fetchAll(input);
        StringBuffer actual = new StringBuffer();
        for (Iterator it = list.iterator(); it.hasNext(); ) {
            Tag tag = (Tag)it.next();
            actual.append(tag._inspect().toString());
            actual.append("\n");
        }
        assertEquals(expected, actual.toString());
    }

    public void testFetchAll1() {
        String input = <<'END';
<html lang="ja">
  <body>
    <h1 style="color: #fffff">title</h1>
  </body>
</html>
END
        String expected = <<'END';
tag_str      = "<html lang=\"ja\">\n"
before_text  = ""
before_space = ""
tagname      = "html"
attr_str     = " lang=\"ja\""
extra_space  = ""
after_space  = "\n"
is_etag      = false
is_empty     = false
is_begline   = true
is_endline   = true
start_pos    = 0
end_pos      = 17
linenum      = 1

tag_str      = "  <body>\n"
before_text  = ""
before_space = "  "
tagname      = "body"
attr_str     = ""
extra_space  = ""
after_space  = "\n"
is_etag      = false
is_empty     = false
is_begline   = true
is_endline   = true
start_pos    = 17
end_pos      = 26
linenum      = 2

tag_str      = "    <h1 style=\"color: #fffff\">"
before_text  = ""
before_space = "    "
tagname      = "h1"
attr_str     = " style=\"color: #fffff\""
extra_space  = ""
after_space  = ""
is_etag      = false
is_empty     = false
is_begline   = true
is_endline   = false
start_pos    = 26
end_pos      = 56
linenum      = 3

tag_str      = "</h1>\n"
before_text  = "title"
before_space = ""
tagname      = "h1"
attr_str     = ""
extra_space  = ""
after_space  = "\n"
is_etag      = true
is_empty     = false
is_begline   = false
is_endline   = true
start_pos    = 61
end_pos      = 67
linenum      = 3

tag_str      = "  </body>\n"
before_text  = ""
before_space = "  "
tagname      = "body"
attr_str     = ""
extra_space  = ""
after_space  = "\n"
is_etag      = true
is_empty     = false
is_begline   = true
is_endline   = true
start_pos    = 67
end_pos      = 77
linenum      = 4

tag_str      = "</html>\n"
before_text  = ""
before_space = ""
tagname      = "html"
attr_str     = ""
extra_space  = ""
after_space  = "\n"
is_etag      = true
is_empty     = false
is_begline   = true
is_endline   = true
start_pos    = 77
end_pos      = 85
linenum      = 5

END
        _testFetchAll(input, expected);
    }



    // --------------------

    Class     _klass;
    String    _method;
    Class[]   _argtypes;
    Object    _receiver;
    Object[]  _args;
    Object    _result;
    String    _input;
    String    _expected;
    String    _actual;

    public void _test() throws Exception {
        java.lang.reflect.Method m = _klass.getDeclaredMethod(_method, _argtypes);
        m.setAccessible(true);
        if (_receiver == null) _receiver = _klass.newInstance();
        _result = m.invoke(_receiver, _args);
        if (_result instanceof Expression) {
            _actual = ((Expression)_result)._inspect().toString();
        }
        if (_expected != null) assertEquals(_expected, _actual);
    }


    public void testAttribute01() throws Exception {  // _parseKdAttribute()
        String pdata = <<'END';
            <div id="foo" class="klass" kw:d="value:val">
            text
            </div>
            END
        DefaultConverter converter = new DefaultConverter();
        List taglist = converter.fetchAll(pdata);
        Tag tag = (Tag)taglist.get(0);
        //
        _expected = null;
        _klass    = DefaultConverter.class;
        _method   = "_parseKdAttribute";
        _argtypes = new Class[] {String.class, Tag.class};
        //
        _input    = "mark:bar";                   // valid directive
        _args     = new Object[] {_input, tag};
        _test();
        assertEquals("mark", tag.directive_name);
        assertEquals("bar",  tag.directive_arg);
        //
        _input    = "Mark:bar";                   // invalid directive
        _args     = new Object[] {_input, tag};
        try {
            _test();
            fail("ConversionException expected but nothing happened.");
        } catch (java.lang.reflect.InvocationTargetException ex) {
            if (! (ex.getCause() instanceof ConvertionException)) {
                fail("ConversionException expected but got " + ex.toString());
                throw ex;
            }
        }
        //
        Object[] tuples = {
            new String[] { "  mark",        "bar" },
            new String[] { "value",       "var+1" },
            new String[] { "Value",       "var+2" },
            new String[] { "VALUE",       "var+3" },
            new String[] { "foreach",     "item=list" },
            new String[] { "Foreach",     "item=list" },
            new String[] { "FOREACH",     "item=list" },
            new String[] { "list",        "item=list" },
            new String[] { "List",        "item=list" },
            new String[] { "LIST",        "item=list" },
            new String[] { "while",       "i>0" },
            new String[] { "list",        "i<0" },
            new String[] { "set",         "var=value" },
            new String[] { "if",          "error!=null" },
            new String[] { "elseif",      "warning!=null" },
            new String[] { "else",        "" },
            new String[] { "dummy",       "d1" },
            new String[] { "replace",     "elem1" },
            new String[] { "placeholder", "elem2" },
            new String[] { "include",     "'filename'" },
        };
        for (int i = 0; i < tuples.length; i++) {
            String[] tuple = (String[])tuples[i];
            String dname = tuple[0];
            String darg  = tuple[1];
            _input    = dname + ":" + darg;
            _args     = new Object[] {_input, tag};
            _test();
            assertEquals(dname.trim(), tag.directive_name);
            assertEquals(darg,  tag.directive_arg);
        }
    }


    public void testAttribute02() throws Exception {  // _parseKdAttribute()
        String pdata = <<'END';
            <div id="foo" class="klass" kw:d="value:val">
            END
        DefaultConverter converter = new DefaultConverter();
        List taglist = converter.fetchAll(pdata);
        Tag tag = (Tag)taglist.get(0);
        //
        _expected = null;
        _klass    = DefaultConverter.class;
        _method   = "_parseKdAttribute";
        _argtypes = new Class[] {String.class, Tag.class};
        //
        _input    = "attr:class:klass";
        _args     = new Object[] {_input, tag};
        _test();
        assertEquals(null, tag.directive_name);
        assertEquals(null, tag.directive_arg);
        assertTrue(tag.attrs != null);
        assertEquals(1, tag.attrs.size());
        Attr attr = (Attr)tag.attrs.get(0);
        assertEquals("class", attr.name);
        assertEquals(VariableExpression.class, attr.value.getClass());
        //
        _input    = "Attr:class:klass";
        _args     = new Object[] {_input, tag};
        _test();
        attr = (Attr)tag.attrs.get(0);
        assertEquals(FunctionExpression.class, attr.value.getClass());
        assertEquals("E", ((FunctionExpression)attr.value).getFunctionName());
        //
        _input    = "ATTR:class:klass";
        _args     = new Object[] {_input, tag};
        _test();
        attr = (Attr)tag.attrs.get(0);
        assertEquals(FunctionExpression.class, attr.value.getClass());
        assertEquals("X", ((FunctionExpression)attr.value).getFunctionName());
        //
        _input    = "append:' checked'";
        _args     = new Object[] {_input, tag};
        _test();
        assertEquals(null, tag.directive_name);
        assertEquals(null, tag.directive_arg);
        assertTrue(tag.append_exprs != null);
        assertEquals(1, tag.append_exprs.size());
        Object expr = tag.append_exprs.get(0);
        assertEquals(StringExpression.class, expr.getClass());
        //
        _input    = "Append:' selected'";
        _args     = new Object[] {_input, tag};
        _test();
        assertEquals(2, tag.append_exprs.size());
        expr = tag.append_exprs.get(1);
        assertEquals(FunctionExpression.class, expr.getClass());
        assertEquals("E", ((FunctionExpression)expr).getFunctionName());
        //
        _input    = "APPEND:' DELETED'";
        _args     = new Object[] {_input, tag};
        _test();
        assertEquals(3, tag.append_exprs.size());
        expr = tag.append_exprs.get(2);
        assertEquals(FunctionExpression.class, expr.getClass());
        assertEquals("X", ((FunctionExpression)expr).getFunctionName());
        //
    }

    public void testAttribute03() throws Exception {  // _parseKdAttribute()
        String pdata = <<'END';
            <div id="foo" class="klass" kw:d="value:val">
            END
        DefaultConverter converter = new DefaultConverter();
        List taglist = converter.fetchAll(pdata);
        Tag tag = (Tag)taglist.get(0);
        //
        _expected = null;
        _klass    = DefaultConverter.class;
        _method   = "_parseKdAttribute";
        _argtypes = new Class[] {String.class, Tag.class};
        //
        _input    = "attr:class:klass; append:' checked'; mark:foo[:key]";
        _args     = new Object[] {_input, tag};
        _test();
        assertEquals("mark", tag.directive_name);
        assertEquals("foo[:key]", tag.directive_arg);
        assertTrue(tag.attrs != null);
        assertEquals(1, tag.attrs.size());
        Attr attr = (Attr)tag.attrs.get(0);
        assertEquals("class", attr.name);
        assertEquals(VariableExpression.class, attr.value.getClass());
        assertTrue(tag.append_exprs != null);
        assertEquals(1, tag.append_exprs.size());
        Object expr = tag.append_exprs.get(0);
        assertEquals(StringExpression.class, expr.getClass());
    }

    public void testAttribute04() throws Exception { // _parseAttributes() {
        _expected = null;
        _klass    = DefaultConverter.class;
        _method   = "_parseAttributes";
        _argtypes = new Class[] {Tag.class};
        //
        Tag tag = new Tag();
        tag.attr_str = " class=\"even\" bgcolor=\"#FFCCCC\" xml:ns=\"foo\"";
        _args     = new Object[] {tag};
        _test();
        //
        assertTrue(tag.attrs != null);
        assertEquals(3, tag.attrs.size());
        Attr attr = (Attr)tag.attrs.get(0);
        assertEquals("class", attr.name);
        assertEquals("even",  attr.value);
        attr = (Attr)tag.attrs.get(1);
        assertEquals("bgcolor", attr.name);
        assertEquals("#FFCCCC",  attr.value);
        attr = (Attr)tag.attrs.get(2);
        assertEquals("xml:ns", attr.name);
        assertEquals("foo",  attr.value);
    }

    public void testAttribute05() throws Exception { // _parseAttributes() {
        _expected = null;
        _klass    = DefaultConverter.class;
        _method   = "_parseAttributes";
        _argtypes = new Class[] {Tag.class};
        //
        Tag tag = new Tag();
        tag.attr_str = " class=\"even\" bgcolor=\"#FFCCCC\" id=\"foo\"";
        _args     = new Object[] {tag};
        _test();
        //
        assertEquals("mark", tag.directive_name);
        assertEquals("foo", tag.directive_arg);
        assertEquals(3, tag.attrs.size());
        Attr attr = (Attr)tag.attrs.get(2);
        assertEquals("id", attr.name);
        assertEquals("foo",  attr.value);
        //
        tag = new Tag();
        tag.attr_str = " class=\"even\"  bgcolor=\"#FFCCCC\" id=\"mark:foo\" ";
        _args     = new Object[] {tag};
        _test();
        //
        assertEquals("mark", tag.directive_name);
        assertEquals("foo", tag.directive_arg);
        assertEquals(2, tag.attrs.size());
        attr = (Attr)tag.attrs.get(0);
        assertEquals("class", attr.name);
        attr = (Attr)tag.attrs.get(1);
        assertEquals("bgcolor", attr.name);
        //
        tag = new Tag();
        tag.attr_str = " class=\"even\" id=\"foo\" id=\"value:var\"";
        _args     = new Object[] {tag};
        _test();
        //
        assertEquals("value", tag.directive_name);
        assertEquals("var", tag.directive_arg);
        assertEquals(2, tag.attrs.size());
        attr = (Attr)tag.attrs.get(1);
        assertEquals("id", attr.name);
        assertEquals("foo",  attr.value);
    }


    public void testAttribute06() throws Exception { // _parseAttributes() {
        _expected = null;
        _klass    = DefaultConverter.class;
        _method   = "_parseAttributes";
        _argtypes = new Class[] {Tag.class};
        //
        Tag tag = new Tag();
        tag.attr_str = " class=\"even\" bgcolor=\"#FFCCCC\" kw:d=\"mark:foo\"";
        _args     = new Object[] {tag};
        _test();
        //
        assertEquals("mark", tag.directive_name);
        assertEquals("foo", tag.directive_arg);
        assertEquals(2, tag.attrs.size());
        //
        tag = new Tag();
        tag.attr_str = " id=\"foo\" bgcolor=\"#FFCCCC\" kw:d=\"value:var\"";
        _args     = new Object[] {tag};
        _test();
        //
        assertEquals("value", tag.directive_name);
        assertEquals("var", tag.directive_arg);
        assertEquals(2, tag.attrs.size());
        //
    }

    public void testAttribute07() throws Exception { // _parseAttributes() {
        _expected = null;
        _klass    = DefaultConverter.class;
        _method   = "_parseAttributes";
        _argtypes = new Class[] {Tag.class};
        //
        Tag tag = new Tag();
        tag.attr_str = "id=\"foo\" bgcolor=\"#FFCCCC\""
                     + " kw:d=\"mark:bar;attr:id:xid;attr:class:klass;append:flag?' checked':''\"";
        _args     = new Object[] {tag};
        _test();
        //
        assertEquals("mark", tag.directive_name);
        assertEquals("bar", tag.directive_arg);
        assertEquals(3, tag.attrs.size());
        Attr attr = (Attr)tag.attrs.get(0);
        assertEquals("id", attr.name);
        assertEquals(VariableExpression.class, attr.value.getClass());
        attr = (Attr)tag.attrs.get(1);
        assertEquals("bgcolor", attr.name);
        assertEquals(String.class, attr.value.getClass());
        attr = (Attr)tag.attrs.get(2);
        assertEquals("class", attr.name);
        assertEquals(VariableExpression.class, attr.value.getClass());
        assertTrue(tag.append_exprs != null);
        assertEquals(ConditionalExpression.class, tag.append_exprs.get(0).getClass());
    }


    private void _testConverter() {
        _testConverter(false);
    }
    private void _testConverter(boolean flag_print) {
        Converter converter = new DefaultConverter();
        Statement[] stmts = converter.convert(_input);
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < stmts.length; i++) {
            sb.append(stmts[i]._inspect().toString());
        }
        String actual = sb.toString();
        if (flag_print) {
            System.out.println("*** actual=|" + actual + "|\n");
        } else {
            assertEquals(_expected, actual);
        }
    }

    public void testConverter21() {  // normal text
        _input = <<'END';
            <span>Hello World</span>
            END
        _expected = <<'END';
            :print
              "<span>"
            :print
              "Hello World"
            :print
              "</span>\n"
            END
        _testConverter();
    }


    public void testConverter22() {  // Helo @{user}@
        _input = <<'END';
             <span>Hello @{user}@</span>
            END
        _expected = <<'END';
            :print
              " <span>"
            :print
              "Hello "
              user
            :print
              "</span>\n"
            END
        _testConverter();
    }


    public void testConverter23() {  // color="@{color}@"
        _input = <<'END';
             <span color="@{color}@">Hello World</span>
            END
        _expected = <<'END';
            :print
              " <span color=\""
              color
              "\">"
            :print
              "Hello World"
            :print
              "</span>\n"
            END
        _testConverter(false);
    }


    public void testConverter24() {  // keep spaces
        _input = <<'END';
             <div  align="center"   bgcolor="#FFFFFF" >
                <span style="color:red">CAUTION!</span>
                <br  />
             </div>
            END
        _expected = <<'END';
            :print
              " <div  align=\"center\"   bgcolor=\"#FFFFFF\" >\n"
            :print
              "    <span style=\"color:red\">"
            :print
              "CAUTION!"
            :print
              "</span>\n"
            :print
              "    <br  />\n"
            :print
              " </div>\n"
            END
        _testConverter();
    }


    public void testDirective11() {   // id="foo"
        _input = <<'END';
            <div>
             <span id="foo">bar</span>
            </div>
            END
        _expected = <<'END';
            :print
              "<div>\n"
            @element(foo)
            :print
              "</div>\n"
            END
        _testConverter();
    }

    public void testDirective12() {   // id="mark:foo"
        _input = <<'END';
            <div>
             <span id="mark:foo">bar</span>
            </div>
            END
        _expected = <<'END';
            :print
              "<div>\n"
            @element(foo)
            :print
              "</div>\n"
            END
        _testConverter();
    }

    public void testDirective13() {    // kw:d="mark:foo"
        _input = <<'END';
            <div>
              <span id="mark:bar" class="klass" kw:d="mark:foo">bar</span>
            </div>
            END
        _expected = <<'END';
            :print
              "<div>\n"
            @element(foo)
            :print
              "</div>\n"
            END
        _testConverter();
    }

    public void testDirective21() {    // id="value:var"
        _input = <<'END';
            <li id="value:user.name">foo</li>
            END
        _expected = <<'END';
            :print
              "<li>"
            :print
              .
                user
                name
            :print
              "</li>\n"
            END
        _testConverter();
    }


    public void testDirective22() {    // id="Value:var"
        _input = <<'END';
            <li id="Value:user.name">foo</li>
            END
        _expected = <<'END';
            :print
              "<li>"
            :print
              E()
                .
                  user
                  name
            :print
              "</li>\n"
            END
        _testConverter();
    }


    public void testDirective23() {    // id="Value:var"
        _input = <<'END';
            <li id="VALUE:user.name">foo</li>
            END
        _expected = <<'END';
            :print
              "<li>"
            :print
              X()
                .
                  user
                  name
            :print
              "</li>\n"
            END
        _testConverter();
    }


    public void testDirective31() {    // id="foreach:item=list"
        _input = <<'END';
            <ul id="foreach:item=list">
              <li>@{item}@</li>
            </ul>
            END
        _expected = <<'END';
            :foreach
              item
              list
              :block
                :print
                  "<ul>\n"
                :print
                  "  <li>"
                :print
                  item
                :print
                  "</li>\n"
                :print
                  "</ul>\n"
            END
        _testConverter();
    }


    public void testDirective32() {    // id="Foreach:item=list"
        _input = <<'END';
            <ul id="Foreach:item=list">
              <li>@{item}@</li>
            </ul>
            END
        _expected = <<'END';
            :expr
              =
                item_ctr
                0
            :foreach
              item
              list
              :block
                :expr
                  +=
                    item_ctr
                    1
                :print
                  "<ul>\n"
                :print
                  "  <li>"
                :print
                  item
                :print
                  "</li>\n"
                :print
                  "</ul>\n"
            END
        _testConverter();
    }


    public void testDirective33() {    // id="FOREACH:item=list"
        _input = <<'END';
            <ul id="FOREACH:item=list">
              <li>@{item}@</li>
            </ul>
            END
        _expected = <<'END';
            :expr
              =
                item_ctr
                0
            :foreach
              item
              list
              :block
                :expr
                  +=
                    item_ctr
                    1
                :expr
                  =
                    item_tgl
                    ?:
                      ==
                        %
                          item_ctr
                          2
                        0
                      "even"
                      "odd"
                :print
                  "<ul>\n"
                :print
                  "  <li>"
                :print
                  item
                :print
                  "</li>\n"
                :print
                  "</ul>\n"
            END
        _testConverter();
    }



    public void testDirective34() {    // id="list:item=list"
        _input = <<'END';
            <ul id="list:item=list">
              <li>@{item}@</li>
            </ul>
            END
        _expected = <<'END';
            :print
              "<ul>\n"
            :foreach
              item
              list
              :block
                :print
                  "  <li>"
                :print
                  item
                :print
                  "</li>\n"
            :print
              "</ul>\n"
            END
        _testConverter();
    }


    public void testDirective35() {    // id="List:item=list"
        _input = <<'END';
            <ul id="List:item=list">
              <li>@{item}@</li>
            </ul>
            END
        _expected = <<'END';
            :print
              "<ul>\n"
            :expr
              =
                item_ctr
                0
            :foreach
              item
              list
              :block
                :expr
                  +=
                    item_ctr
                    1
                :print
                  "  <li>"
                :print
                  item
                :print
                  "</li>\n"
            :print
              "</ul>\n"
            END
        _testConverter();
    }


    public void testDirective36() {    // id="LIST:item=list"
        _input = <<'END';
            <ul id="LIST:item=list">
              <li>@{item}@</li>
            </ul>
            END
        _expected = <<'END';
            :print
              "<ul>\n"
            :expr
              =
                item_ctr
                0
            :foreach
              item
              list
              :block
                :expr
                  +=
                    item_ctr
                    1
                :expr
                  =
                    item_tgl
                    ?:
                      ==
                        %
                          item_ctr
                          2
                        0
                      "even"
                      "odd"
                :print
                  "  <li>"
                :print
                  item
                :print
                  "</li>\n"
            :print
              "</ul>\n"
            END
        _testConverter();
    }


    public void testDirective41() {  // while:row=sth.fetch()
        _input = <<'END';
            <ul id="while:row=sth.fetch()">
              <li>@{row[0]}@</li>
            </ul>
            END
        _expected = <<'END';
            :while
              =
                row
                .()
                  sth
                  fetch()
              :block
                :print
                  "<ul>\n"
                :print
                  "  <li>"
                :print
                  []
                    row
                    0
                :print
                  "</li>\n"
                :print
                  "</ul>\n"
            END
        _testConverter();
    }


    public void testDirective42() {  // loop:row=sth.fetch()
        _input = <<'END';
            <ul id="loop:row=sth.fetch()">
              <li>@{row[0]}@</li>
            </ul>
            END
        _expected = <<'END';
            :print
              "<ul>\n"
            :while
              =
                row
                .()
                  sth
                  fetch()
              :block
                :print
                  "  <li>"
                :print
                  []
                    row
                    0
                :print
                  "</li>\n"
            :print
              "</ul>\n"
            END
        _testConverter();
    }


    public void testDirective51() {  // if:error!=null
        _input = <<'END';
            <font color="red" id="if:error!=null">
              ERROR!
            </font>
            END
        _expected = <<'END';
            :if
              !=
                error
                null
              :block
                :print
                  "<font color=\"red\">\n"
                :print
                  "  ERROR!\n"
                :print
                  "</font>\n"
            END
        _testConverter();
    }


    public void testDirective52() {  // elseif:warning!=null
        _input = <<'END';
            <font color="red" id="if:error!=empty">
              ERROR!
            </font>
            <font color="blue" id="elseif:warning!=null">
              WARNING
            </font>
            END
        _expected = <<'END';
            :if
              notempty
                error
              :block
                :print
                  "<font color=\"red\">\n"
                :print
                  "  ERROR!\n"
                :print
                  "</font>\n"
              :if
                !=
                  warning
                  null
                :block
                  :print
                    "<font color=\"blue\">\n"
                  :print
                    "  WARNING\n"
                  :print
                    "</font>\n"
            END
        _testConverter();
    }

    public void testDirective53() {  // else:
        _input = <<'END';
            <font color="red" id="if:error!=empty">
              ERROR!
            </font>
            <font color="blue" id="elseif:warning!=null">
              WARNING
            </font>
            <font color="black" id="else:">
              Welcome
            </font>
            END
        _expected = <<'END';
            :if
              notempty
                error
              :block
                :print
                  "<font color=\"red\">\n"
                :print
                  "  ERROR!\n"
                :print
                  "</font>\n"
              :if
                !=
                  warning
                  null
                :block
                  :print
                    "<font color=\"blue\">\n"
                  :print
                    "  WARNING\n"
                  :print
                    "</font>\n"
                :block
                  :print
                    "<font color=\"black\">\n"
                  :print
                    "  Welcome\n"
                  :print
                    "</font>\n"
            END
        _testConverter();
    }

    public void testDirective54() {  // several elseif:
        _input = <<'END';
            <div>
              <font color="red" id="if:error!=empty">ERROR!</font>
              <font color="blue" id="elseif:warning!=empty">WARNING</font>
              <font color="green" id="elseif:notify!=empty">NOTIFICATION</font>
              <font color="black" id="else:">Welcome</font>
            </div>
            END
        _expected = <<'END';
            :print
              "<div>\n"
            :if
              notempty
                error
              :block
                :print
                  "  <font color=\"red\">"
                :print
                  "ERROR!"
                :print
                  "</font>\n"
              :if
                notempty
                  warning
                :block
                  :print
                    "  <font color=\"blue\">"
                  :print
                    "WARNING"
                  :print
                    "</font>\n"
                :if
                  notempty
                    notify
                  :block
                    :print
                      "  <font color=\"green\">"
                    :print
                      "NOTIFICATION"
                    :print
                      "</font>\n"
                  :block
                    :print
                      "  <font color=\"black\">"
                    :print
                      "Welcome"
                    :print
                      "</font>\n"
            :print
              "</div>\n"
            END
        _testConverter(false);
    }


    public void testDirective55() {  // invalid if-else
        _input = <<'END';
            <div>
              <font color="red" id="if:error!=empty">
                ERROR!
              </font>

              <font color="blue" id="elseif:warning!=empty">
                WARNING
              </font>
            </div>
            END
        _expected = "";
        try {
          _testConverter(false);
          fail("ConvertionException expected but nothing happened.");
        } catch (ConvertionException ex) {
            // OK
        }
    }


    public void testDirective61() {  // replace:elem1
        _input = <<'END';
            <h1 id="mark:title">...title...</h1>
            text
            <div id="replace:title">foo</div>
            END
        _expected = <<'END';
            @element(title)
            :print
              "text\n"
            @element(title)
            END
        _testConverter(false);
    }


    public void testDirective62() {  // replace:elem1:element
        _input = <<'END';
            <h1 id="mark:title">...title...</h1>
            text
            <div id="replace:title:element">foo</div>
            END
        _expected = <<'END';
            @element(title)
            :print
              "text\n"
            @element(title)
            END
        _testConverter(false);
    }


    public void testDirective63() {  // replace:elem1:content
        _input = <<'END';
            <h1 id="mark:title">...title...</h1>
            text
            <div id="replace:title:content">foo</div>
            END
        _expected = <<'END';
            @element(title)
            :print
              "text\n"
            @content(title)
            END
        _testConverter(false);
    }


    public void testDirective64() {  // placeholder:elem1
        _input = <<'END';
            <h1 id="mark:title">...title...</h1>
            text
            <div id="placeholder:title">foo</div>
            END
        _expected = <<'END';
            @element(title)
            :print
              "text\n"
            :print
              "<div>"
            @element(title)
            :print
              "</div>\n"
            END
        _testConverter(false);
    }


    public void testDirective65() {  // placeholder:elem1:element
        _input = <<'END';
            <h1 id="mark:title">...title...</h1>
            text
            <div id="placeholder:title:element">foo</div>
            END
        _expected = <<'END';
            @element(title)
            :print
              "text\n"
            :print
              "<div>"
            @element(title)
            :print
              "</div>\n"
            END
        _testConverter(false);
    }


    public void testDirective66() {  // placeholder:elem1:content
        _input = <<'END';
            <h1 id="mark:title">...title...</h1>
            text
            <div id="placeholder:title:content">foo</div>
            END
        _expected = <<'END';
            @element(title)
            :print
              "text\n"
            :print
              "<div>"
            @content(title)
            :print
              "</div>\n"
            END
        _testConverter(false);
    }


    public void testDirective71() {  // set:var=value
        _input = <<'END';
            <tr bgcolor="@{color}@" id="set:color=i%2==0?'#FFCCCC':'#CCCCFF'">
              <td>item=@{item}@</td>
            </tr>
            END
        _expected = <<'END';
            :expr
              =
                color
                ?:
                  ==
                    %
                      i
                      2
                    0
                  "#FFCCCC"
                  "#CCCCFF"
            :print
              "<tr bgcolor=\""
              color
              "\">\n"
            :print
              "  <td>"
            :print
              "item="
              item
            :print
              "</td>\n"
            :print
              "</tr>\n"
            END
        _testConverter();
    }


    public void testDirective72() {  // dummy:d1
        _input = <<'END';
            <tr>
              <td>foo</td>
            </tr>
            <tr id="dummy:d1">
              <td>foo</td>
            </tr>
            END
        _expected = <<'END';
            :print
              "<tr>\n"
            :print
              "  <td>"
            :print
              "foo"
            :print
              "</td>\n"
            :print
              "</tr>\n"
            END
        _testConverter();
    }


    public void testDirective73() {  // include:'filename'
        //_input = <<'END';
        //    END
        //_expected = <<'END';
        //    END
        //_testConverter();
    }

    public void testDirective81() {  // attr:bgcolor:color
        _input = <<'END';
            <div  bgcolor="red"   style="color:red"
                 id="attr:bgcolor=color;attr:ns:class:item[:klass];value:val" title="">foo</div>
            END
        _expected = <<'END';
            :print
              "<div  bgcolor=\""
              color
              "\"   style=\"color:red\" title=\"\" ns:class=\""
              [:]
                item
                "klass"
              "\">"
            :print
              val
            :print
              "</div>\n"
            END
        _testConverter();
        //
    }

    public void testDirective82() {  // Attr: and ATTR:
        _input = <<'END';
            <div  bgcolor="red"   style="color:red"
                 id="Attr:bgcolor=color;ATTR:ns:class:item[:klass];value:val" title="">foo</div>
            END
        _expected = <<'END';
            :print
              "<div  bgcolor=\""
              E()
                color
              "\"   style=\"color:red\" title=\"\" ns:class=\""
              X()
                [:]
                  item
                  "klass"
              "\">"
            :print
              val
            :print
              "</div>\n"
            END
        _testConverter();
        //
    }


    public void testDirective83() {  // attr directive with empty tag
        _input = <<'END';
            <div  bgcolor="red"   style="color:red"
                 id="Attr:bgcolor=color;ATTR:ns:class:item[:klass]" title="" />
            END
        _expected = <<'END';
            :print
              "<div  bgcolor=\""
              E()
                color
              "\"   style=\"color:red\" title=\"\" ns:class=\""
              X()
                [:]
                  item
                  "klass"
              "\" />\n"
            END
        _testConverter();
        //
    }


    public void testDirective84() {  // append, Append, APPEND
        _input = <<'END';
            <input type="checkbox" id="foo" kw:d="append:flag?' checked':'';Append:flag?' selected':'';APPEND:flag?' disabled':''" />
            END
        _expected = <<'END';
            :print
              "<input type=\"checkbox\" id=\"foo\""
              ?:
                flag
                " checked"
                ""
              E()
                ?:
                  flag
                  " selected"
                  ""
              X()
                ?:
                  flag
                  " disabled"
                  ""
              " />\n"
            END
        _testConverter();
        //
    }



    // --------------------

    public static void main(String[] args) {
       junit.textui.TestRunner.run(ConverterTest.class);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import junit.framework.TestCase;

public class StatementParserTest extends TestCase {

    String _input, _expected;

    public Parser _test(String method) {
        return _test(method, null);
    }
    public Parser _test(String method, Class klass) {
        Scanner scanner = new Scanner(_input);
        StatementParser parser = new StatementParser(scanner);
        Statement stmt = null;
        Statement[] stmts = null;
        if (method.equals("parsePrintStatement")) {
            stmt = parser.parsePrintStatement();
        } else if (method.equals("parseExpressionStatement")) {
            stmt = parser.parseExpressionStatement();
        } else if (method.equals("parseIfStatement")) {
            stmt = parser.parseIfStatement();
        } else if (method.equals("parseForeachStatement")) {
            stmt = parser.parseForeachStatement();
        } else if (method.equals("parseWhileStatement")) {
            stmt = parser.parseWhileStatement();
        } else if (method.equals("parseExpandStatement")) {
            stmt = parser.parseExpandStatement();
        } else if (method.equals("parseElementStatement")) {
            stmt = parser.parseElementStatement();
        } else if (method.equals("parseRawcodeStatement")) {
            stmt = parser.parseRawcodeStatement();
        } else if (method.equals("parseBlockStatement")) {
            stmt = parser.parseBlockStatement();
        } else if (method.equals("parseStatementList")) {
            stmts = parser.parseStatementList();
        } else {
            fail("*** invalid method name ***");
        }

        //Scanner scanner = parser.getScanner();
        if (scanner.getToken() != TokenType.EOF)
            fail("TokenType.EOF expected but got " + TokenType.inspect(scanner.getToken(), scanner.getValue()));

        if (klass != null) {
            assertEquals(klass, stmt.getClass());
        }
        if (stmt != null) {
            StringBuffer actual = stmt._inspect();
            assertEquals(_expected, actual.toString());
        } else if (stmts != null) {
            StringBuffer sb = new StringBuffer();
            for (int i = 0; i < stmts.length; i++) {
                stmts[i]._inspect(0, sb);
            }
            assertEquals(_expected, sb.toString());
        } else {
            assert false;
        }
        return parser;
    }


    public void testParseBlockStatement1() {
        _input = "{ print(foo); print(bar); print(baz); }";
        _expected = ":block\n  :print\n    foo\n  :print\n    bar\n  :print\n    baz\n";
        _test("parseBlockStatement", BlockStatement.class);
    }

    public void testParseBlockStatement2() {
        _input = "{ i=0; i+=1; ; }";
        _expected = <<'END';
                :block
                  :expr
                    =
                      i
                      0
                  :expr
                    +=
                      i
                      1
                  :empty_stmt
                END
        _test("parseBlockStatement", BlockStatement.class);
    }


    public void testParsePrintStatement1() { // print('foo');
        _input = "print('foo');";
        _expected = <<'END';
                :print
                  "foo"
                END
        _test("parsePrintStatement", PrintStatement.class);
    }
    public void testParsePrintStatement2() { // print(a, 'foo'.+b, 100);
        _input = "print(a, 'foo'.+b, 100);";
        _expected = <<'END';
                :print
                  a
                  .+
                    "foo"
                    b
                  100
                END
        _test("parsePrintStatement", PrintStatement.class);
    }

    public void testParseExpressionStatement1() { // x = 100;
        _input = "x = 100;";
        _expected = <<'END';
                :expr
                  =
                    x
                    100
                END
        _test("parseExpressionStatement", ExpressionStatement.class);
    }

    public void testParseExpressionStatement2() { // x[i][j] = i > j ? 0 : 1;
        _input = "x[i][j] = i > j ? 0 : 1;";
        _expected = <<'END';
                :expr
                  =
                    []
                      []
                        x
                        i
                      j
                    ?:
                      >
                        i
                        j
                      0
                      1
                END
        _test("parseExpressionStatement", ExpressionStatement.class);
    }


    public void testParseForeachStatement1() {
        _input = "foreach(item in list) { print(item); }";
        _expected = <<'END';
                :foreach
                  item
                  list
                  :block
                    :print
                      item
                END
        _test("parseForeachStatement", ForeachStatement.class);
    }

    public void testParseForeachStatement2() {
        _input = "foreach(item in list) print(item);";
        _expected = <<'END';
                :foreach
                  item
                  list
                  :print
                    item
                END
        _test("parseForeachStatement", ForeachStatement.class);
    }


    public void testParseIfStatement1() {
        _input = "if (flag) print(flag);";
        _expected = <<'END';
                :if
                  flag
                  :print
                    flag
                END
        _test("parseIfStatement", IfStatement.class);
    }

    public void testParseIfStatement2() {
        _input = "if (flag) print(true); else print(false);";
        _expected = <<'END';
                :if
                  flag
                  :print
                    true
                  :print
                    false
                END
        _test("parseIfStatement", IfStatement.class);
    }

    public void testParseIfStatement3() {
        _input = "if (flag1) print(aaa); else if (flag2) print(bbb); elseif(flag3) print(ccc); else print(ddd);";
        _expected = <<'END';
                :if
                  flag1
                  :print
                    aaa
                  :if
                    flag2
                    :print
                      bbb
                    :if
                      flag3
                      :print
                        ccc
                      :print
                        ddd
                END
        _test("parseIfStatement", IfStatement.class);
    }


    public void testParseWhileStatement1() {
        _input = "while (i < max) i += 1;";
        _expected = <<'END';
                :while
                  <
                    i
                    max
                  :expr
                    +=
                      i
                      1
                END
        _test("parseWhileStatement", WhileStatement.class);
    }


    public void testParseExpandStatement1() {
        _input = "@stag;";
        _expected = "@stag\n";
        _test("parseExpandStatement", ExpandStatement.class);
        _input = "@cont;";
        _expected = "@cont\n";
        _test("parseExpandStatement", ExpandStatement.class);
        _input = "@etag;";
        _expected = "@etag\n";
        _test("parseExpandStatement", ExpandStatement.class);
        _input = "@content(foo);";
        _expected = "@content(foo)\n";
        _test("parseExpandStatement", ExpandStatement.class);
        _input = "@element(foo);";
        _expected = "@element(foo)\n";
        _test("parseExpandStatement", ExpandStatement.class);
    }


    public void testParseExpandStatement2() {
        _input = "@foo;";
        _expected = "";
        try {
            _test("parseExpandStatement", ExpandStatement.class);
            fail("SyntaxException expected but not happened.");
        } catch (SyntaxException ex) {
            // OK
        }
    }


    public void testParseStatementList1() {
        _input = <<'END';
                print("<table>\n");
                i = 0;
                foreach(item in list) {
                  i += 1;
                  color = i % 2 == 0 ? '#FFCCCC' : '#CCCCFF';
                  print("<tr bgcolor=\"", color, "\">\n");
                  print("<td>", item, "</td>\n");
                  print("</tr>\n");
                }
                print("</table>\n");
                END
        _expected = <<'END';
                :print
                  "<table>\n"
                :expr
                  =
                    i
                    0
                :foreach
                  item
                  list
                  :block
                    :expr
                      +=
                        i
                        1
                    :expr
                      =
                        color
                        ?:
                          ==
                            %
                              i
                              2
                            0
                          "#FFCCCC"
                          "#CCCCFF"
                    :print
                      "<tr bgcolor=\""
                      color
                      "\">\n"
                    :print
                      "<td>"
                      item
                      "</td>\n"
                    :print
                      "</tr>\n"
                :print
                  "</table>\n"
                END
        _test("parseStatementList");
    }


    // -----

    public static void main(String[] args) {
       junit.textui.TestRunner.run(StatementParserTest.class);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import junit.framework.TestCase;
import java.util.*;

public class DeclarationParserTest extends TestCase {
    private String _input;
    private String _expected;

    private void _test() {
        _test(false);
    }

    private void _test(boolean flagPrint) {
        DeclarationParser parser = new DeclarationParser();
        List decls = parser.parse(_input);
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < decls.size(); i++) {
            PresentationDeclaration decl = (PresentationDeclaration)decls.get(i);
            decl._inspect(0, sb);
        }
        String actual = sb.toString();
        if (flagPrint)
            System.out.println(actual);
        else
            assertEquals(_expected, actual);
    }

    public void testValuePart1() {
        _input = <<'END';
        #foo {
            value: expr;
        }
        END
        _expected = <<'END';
        #foo {
          value:
            expr
        }
        END
        _test();
    }

    public void testAttrsPart1() {
        _input = <<'END';
        #foo {
           attrs: "id" xid, "href" "mailto:" .+ email;
        }
        END
        _expected = <<'END';
        #foo {
          attrs:
            "href"
            .+
              "mailto:"
              email
            "id"
            xid
        }
        END
        _test();
    }

    public void testRemovePart1() {
        _input = <<'END';
        #foo {
            remove: "checked", "id", "c:flag";
        }
        END
        _expected = <<'END';
        #foo {
          remove:
            "checked"
            "id"
            "c:flag"
        }
        END
        _test();
    }

    public void testAppendPart1() {
        _input = <<'END';
        #foo {
            append: flag1 ? ' checked="checked"' : '', flag2 ? ' selected="selected"' : '';
        }
        END
        _expected = <<'END';
        #foo {
          append:
            ?:
              flag1
              " checked=\"checked\""
              ""
            ?:
              flag2
              " selected=\"selected\""
              ""
        }
        END
        _test();
    }

    public void testTagnamePart1() {
        _input = <<'END';
        #foo {
            tagname  :  "html:html";
        }
        END
        _expected = <<'END';
        #foo {
          tagname:
            "html:html"
        }
        END
        _test();
    }

    public void testPlogicPart1() {
        _input = <<'END';
        #foo {
            plogic : {
                foreach (item in list) {
                    @stag;
                    @cont;
                    @etag;
                }
            }
        }
        END
        _expected = <<'END';
        #foo {
          plogic:
            :block
              :foreach
                item
                list
                :block
                  @stag
                  @cont
                  @etag
        }
        END
        _test();
    }


    public void testParseDeclaration1() {
        _input = <<'END';
            #user_list {
                    attrs:   "bgcolor" color;   // set bgcolor attribute value
                    remove:  "id";              // remove id attribute
                    plogic:  {
                        i = 0;
                        foreach (user in user_list) {
                            i += 1;
                            color = i%2==0 ? '#CCCCFF' : '#FFCCCC';
                            @stag;              // start tag
                            @cont;              // content
                            @etag;              // end tag
                        }
                    }
            }

            #name {
                    value:   user['name'];      // replace content by expression value
                    remove:  "id";              // remove id attribute
            }

            #email {
                    value:   user['email'];     // replace content by expression value
                    remove:  "id";              // remove id attribute
                    attrs:   "href" 'mailto:' .+ user['email'];    // set href attribute value
            }

            #dummy {
                    plogic: { }                 // remove an element
            }
            END
        _expected = <<'END';
            #user_list {
              remove:
                "id"
              attrs:
                "bgcolor"
                color
              plogic:
                :block
                  :expr
                    =
                      i
                      0
                  :foreach
                    user
                    user_list
                    :block
                      :expr
                        +=
                          i
                          1
                      :expr
                        =
                          color
                          ?:
                            ==
                              %
                                i
                                2
                              0
                            "#CCCCFF"
                            "#FFCCCC"
                      @stag
                      @cont
                      @etag
            }
            #name {
              remove:
                "id"
              value:
                []
                  user
                  "name"
            }
            #email {
              remove:
                "id"
              attrs:
                "href"
                .+
                  "mailto:"
                  []
                    user
                    "email"
              value:
                []
                  user
                  "email"
            }
            #dummy {
              plogic:
                :block
            }
            END
        _test();
    }

}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import junit.framework.TestCase;

public class ExpressionParserTest extends TestCase {

    String _input;
    String _expected;

    public ExpressionParser _test(String method) {
        return _test(method, null);
    }

    public ExpressionParser _test(String method, Class klass) {
        Scanner scanner = new Scanner(_input);
        ExpressionParser parser = new ExpressionParser(scanner);
        Expression expr = null;
        if (method.equals("parseLiteral")) {
            expr = parser.parseLiteral();
        } else if (method.equals("parseItem")) {
            expr = parser.parseItem();
        } else if (method.equals("parseFactor")) {
            expr = parser.parseFactor();
        } else if (method.equals("parseUnary")) {
            expr = parser.parseUnary();
        } else if (method.equals("parseTerm")) {
            expr = parser.parseTerm();
        } else if (method.equals("parseArithmetic")) {
            expr = parser.parseArithmetic();
        } else if (method.equals("parseRelational")) {
            expr = parser.parseRelational();
        } else if (method.equals("parseLogicalAnd")) {
            expr = parser.parseLogicalAnd();
        } else if (method.equals("parseLogicalOr")) {
            expr = parser.parseLogicalOr();
        } else if (method.equals("parseConditional")) {
            expr = parser.parseConditional();
        } else if (method.equals("parseAssignment")) {
            expr = parser.parseAssignment();
        } else if (method.equals("parseExpression")) {
            expr = parser.parseExpression();
        } else {
            fail("*** invalid method name ***");
        }
        if (expr == null) fail("*** expr is null ***");
        if (klass != null) {
            assertEquals(klass, expr.getClass());
        }
        StringBuffer actual = expr._inspect();
        assertEquals(_expected, actual.toString());
        assertTrue("*** EOF expected ***", scanner.getToken() == TokenType.EOF);
        return parser;
    }

    public void testParseLiteral1() {  // integer
        _input = "100";
        _expected = "100\n";
        _test("parseLiteral", IntegerExpression.class);
    }
    public void testParseLiteral2() {  // double
        _input = "3.14";
        _expected = "3.14\n";
        _test("parseLiteral", DoubleExpression.class);
    }
    public void testParseLiteral3() {  // 'string'
        _input = "'foo'";
        _expected = "\"foo\"\n";
        _test("parseLiteral", StringExpression.class);
        _input = "'\\n\\r\\t\\\\ \\''";              // '\n\r\t\\\\ \''
        _expected = "\"\\\\n\\\\r\\\\t\\\\ '\"\n";   // "\\n\\r\\t\\ '"
        _test("parseLiteral", StringExpression.class);
    }
    public void testParseLiteral4() {  // "string"
        _input = "\"foo\"";
        _expected = "\"foo\"\n";
        _test("parseLiteral", StringExpression.class);
        _input = "\"\\n\\r\\t \\\\ \\\" \"";        // "\n\r\t \\ \" "
        _expected = "\"\\n\\r\\t \\\\ \\\" \"\n";   // "\n\r\t \\ \" "
        _test("parseLiteral", StringExpression.class);
    }
    public void testParseLiteral5() {  // true, false
        _input = "true";
        _expected = "true\n";
        _test("parseLiteral", BooleanExpression.class);
        _input = "false";
        _expected = "false\n";
        _test("parseLiteral", BooleanExpression.class);
    }
    public void testParseLiteral6() {  // null
        _input = "null";
        _expected = "null\n";
        _test("parseLiteral", NullExpression.class);
    }


    public void testParseItem1() {  // variable
        _input = "foo";
        _expected = "foo\n";
        _test("parseItem", VariableExpression.class);
    }
    public void testParseItem2() {  // function()
        _input = "foo()";
        _expected = "foo()\n";
        _test("parseItem", FunctionExpression.class);
    }
    public void testParseItem3() {  // function(100, 'va', arg)
        _input = "foo(100, 'val', arg)";
        _expected = <<'END';
                foo()
                  100
                  "val"
                  arg
                END
        _test("parseItem", FunctionExpression.class);
    }
    public void testParseItem4() {  // (expr)
        _input = "(a+b)";
        _expected = <<'END';
                +
                  a
                  b
                END
        _test("parseItem", ArithmeticExpression.class);
    }
    public void testParseItem5() { // macro C(), S(), D()
        _input = "C(flag)";
        _expected = <<<'END';
            ?:
              flag
              " checked=\"checked\""
              ""
            END
        _test("parseItem", ConditionalExpression.class);
        _input = "S(gender=='M')";
        _expected = <<<'END';
            ?:
              ==
                gender
                "M"
              " selected=\"selected\""
              ""
            END
        _test("parseItem", ConditionalExpression.class);
        _input = "D(error!=null)";
        _expected = <<<'END';
            ?:
              !=
                error
                null
              " disabled=\"disabled\""
              ""
            END
        _test("parseItem", ConditionalExpression.class);
    }
    public void testParseItem6() { // arity of macros
        _input = "C(arg1, arg2)";
        _expected = "";
        try {
            _test("parseItem", ConditionalExpression.class);
            fail("SemanticError expected but not throwed.");
        } catch (SemanticException ex) {
            // OK
        }
    }

    public void testParseFactor1() {  // array
        _input = "a[10]";
        _expected = <<'END';;
                []
                  a
                  10
                END
        _test("parseFactor", IndexExpression.class);
        _input = "a[i+1]";
        _expected = "[]\n  a\n  +\n    i\n    1\n";
        _test("parseFactor", IndexExpression.class);
    }
    public void testParseFactor2() {  // hash
        _input = "a[:foo]";
        _expected = <<'END';
                [:]
                  a
                  "foo"
                END
        _test("parseFactor", IndexExpression.class);
    }
    public void testParseFactor3() {  // property
        _input = "obj.prop1";
        _expected = <<'END';
                .
                  obj
                  prop1
                END
        _test("parseFactor", PropertyExpression.class);
    }
    public void testParseFactor4() {  // method
        _input = "obj.method1(arg1,arg2)";
        _expected = <<'END';
                .()
                  obj
                  method1()
                    arg1
                    arg2
                END
        _test("parseFactor", MethodExpression.class);
    }
    public void testParseFactor5() {  // nested array,hash
        _input = "a[i][:j][k]";
        _expected = <<'END';
                []
                  [:]
                    []
                      a
                      i
                    "j"
                  k
                END
        _test("parseFactor", IndexExpression.class);
        _input = "foo.bar.baz()";
        _expected = <<'END';
                .()
                  .
                    foo
                    bar
                  baz()
                END
        _test("parseFactor", MethodExpression.class);
    }

    public void testParseFactor6() {  // invalid array
        _input = "a[10;";
        _expected = null;
        try {
            _test("parseFactor", IndexExpression.class);
        } catch (SyntaxException ex) {
            // OK
        }
    }
    public void testParseFactor7() {
        _input = "a[:+]";
        _expected = null;
        try {
            _test("parseFactor", IndexExpression.class);
        } catch (SyntaxException ex) {
            // OK
        }
        _input = "a[:foo-bar]";
        _expected = null;
        try {
            _test("parseFactor", IndexExpression.class);
        } catch (SyntaxException ex) {
            // OK
        }
    }


    public void testParseUnary1() {  // -1, +a, !false
        _input = "-1";
        _expected = <<'END';
                -.
                  1
                END
        _test("parseUnary", UnaryExpression.class);
        _input = "+a";
        _expected = <<'END';
                +.
                  a
                END
        _test("parseUnary", UnaryExpression.class);
        _input = "!false";
        _expected = <<'END';
                !
                  false
                END
        _test("parseUnary", UnaryExpression.class);
    }

    public void testParseUnary2() { // - - 1
        _input = "- -1";
        _expected = null;
        try {
            _test("parseUnary");
        } catch (SyntaxException ex) {
            // OK
        }
    }

    public void testParseTerm1() {  // term
        _input = "-x*y";
        _expected = <<'END';
                *
                  -.
                    x
                  y
                END
        _test("parseTerm", ArithmeticExpression.class);
        _input = "a*b/c%d";
        _expected = <<'END';
                %
                  /
                    *
                      a
                      b
                    c
                  d
                END
        _test("parseTerm", ArithmeticExpression.class);
    }

    public void testParseArithmetic1() {  // arithmetic
        _input = "-a + b .+ c - d";
        _expected = <<'END';
                -
                  .+
                    +
                      -.
                        a
                      b
                    c
                  d
                END
        _test("parseArithmetic", ArithmeticExpression.class);
    }

    public void testParseArithmetic2() {  // arithmetic
        _input = "-a*b + -c/d";
        _expected = <<'END';
                +
                  *
                    -.
                      a
                    b
                  /
                    -.
                      c
                    d
                END
        _test("parseArithmetic", ArithmeticExpression.class);
    }

    public void testParseConcatenation1() {  // arithmetic
        _input = "'dir/' .+ base .+ '.txt'";
        _expected = <<'END';
            .+
              .+
                "dir/"
                base
              ".txt"
            END
        _test("parseArithmetic", ConcatenationExpression.class);
    }


    public void testParseRelational1() {
        _input = "a==b";
        _expected = <<'END';
                ==
                  a
                  b
                END
        _test("parseRelational", RelationalExpression.class);
        _input = "a!=b";
        _expected = <<'END';
                !=
                  a
                  b
                END
        _test("parseRelational", RelationalExpression.class);
        _input = "a<b";
        _expected = <<'END';
                <
                  a
                  b
                END
        _test("parseRelational", RelationalExpression.class);
        _input = "a<=b";
        _expected = <<'END';
                <=
                  a
                  b
                END
        _test("parseRelational", RelationalExpression.class);
        _input = "a>b";
        _expected = <<'END';
                >
                  a
                  b
                END
        _test("parseRelational", RelationalExpression.class);
        _input = "a>=b";
        _expected = <<'END';
                >=
                  a
                  b
                END
    }


    public void testParseLogicalAnd1() {  // a && b
        _input = "a && b";
        _expected = <<'END';
                &&
                  a
                  b
                END
        _test("parseLogicalAnd", LogicalAndExpression.class);
        _input = "0<x&&x<100&&cond1&&cond2";
        _expected = <<'END';
                &&
                  &&
                    &&
                      <
                        0
                        x
                      <
                        x
                        100
                    cond1
                  cond2
                END
        _test("parseLogicalAnd", LogicalAndExpression.class);
    }

    public void testParseLogicalOr1() {   // a || b
        _input = "a||b";
        _expected = "||\n  a\n  b\n";
        _test("parseLogicalOr", LogicalOrExpression.class);
        _input = "0<x||x<100||cond1||cond2";
        _expected = <<'END';
                ||
                  ||
                    ||
                      <
                        0
                        x
                      <
                        x
                        100
                    cond1
                  cond2
                END
        _test("parseLogicalOr", LogicalOrExpression.class);
        _input = "a&&b || c&&d || e&&f";
        _expected = <<'END';
                ||
                  ||
                    &&
                      a
                      b
                    &&
                      c
                      d
                  &&
                    e
                    f
                END
        _test("parseLogicalOr", LogicalOrExpression.class);
    }

    public void testParseConditional1() {
        _input = "a ? b : c";
        _expected = <<'END';
                ?:
                  a
                  b
                  c
                END
        _test("parseConditional", ConditionalExpression.class);
    }

    public void testParseAssignment1() {
        _input = "a = b";
        _expected = <<'END';
                =
                  a
                  b
                END
        _test("parseAssignment", AssignmentExpression.class);
        _input = "a = 1+f(2)";
        _expected = <<'END';
                =
                  a
                  +
                    1
                    f()
                      2
                END
        _test("parseAssignment", AssignmentExpression.class);
    }

    public void testParseAssignment2() {
        _input = "a[i] = b";
        _expected = <<'END';
                =
                  []
                    a
                    i
                  b
                END
        _test("parseAssignment", AssignmentExpression.class);
    }


    public void testParseExpression1() {
        _input = "color = i % 2 == 0 ? '#FFCCCC' : '#CCCCFF'";
        _expected = <<'END';
                =
                  color
                  ?:
                    ==
                      %
                        i
                        2
                      0
                    "#FFCCCC"
                    "#CCCCFF"
                END
        _test("parseExpression", AssignmentExpression.class);
    }


    // -----

    public static void main(String[] args) {
       junit.textui.TestRunner.run(ExpressionParserTest.class);
    }

}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import junit.framework.TestCase;

public class ScannerTest extends TestCase {

    private String _input;
    private String _expected;

    public Scanner _test() {
        return _test(true);
    }

    public Scanner _test(boolean flag_test) {
        if (! flag_test) return null;
        Scanner scanner = new Scanner(_input);
        StringBuffer sbuf = new StringBuffer();
        while (scanner.scan() != TokenType.EOF) {
            sbuf.append(TokenType.tokenName(scanner.getToken()));
            sbuf.append(' ');
            String s = TokenType.inspect(scanner.getToken(), scanner.getValue());
            sbuf.append(s);
            sbuf.append("\n");
        }
        String actual = sbuf.toString();
        assertEquals(_expected, actual);
        return scanner;
    }

    public void testScanner0() {  // basic test
        _input = "if while foo";
        _expected = "IF :if\nWHILE :while\nNAME foo\nEOF <<EOF>>\nEOF <<EOF>>\n";
        Scanner scanner = new Scanner(_input);
        StringBuffer sbuf = new StringBuffer();
        for (int i = 0; i < 5; i++) {
            scanner.scan();
            sbuf.append(TokenType.tokenName(scanner.getToken()));
            sbuf.append(' ');
            sbuf.append(TokenType.inspect(scanner.getToken(), scanner.getValue()));
            sbuf.append("\n");
        }
        String actual = sbuf.toString();
        assertEquals(_expected, actual);
    }

    public void testScanner11() {  // keywords
        _input = "  if while  foreach else\nelseif\t\nin  ";
        _expected = "IF :if\nWHILE :while\nFOREACH :foreach\nELSE :else\nELSEIF :elseif\nIN :in\n";
        _test();
        _input = "true false null nil empty";
        _expected = "TRUE true\nFALSE false\nNULL null\nNAME nil\nEMPTY empty\n";
        _test();
    }

    public void testScanner12() {  // integer, double
        _input = "100 3.14";
        _expected = "INTEGER 100\nDOUBLE 3.14\n";
        _test();
        _input = "100abc";
        _expected = null;
        try {
            _test();
            fail("'100abc': LexicalException expected.");
        } catch (LexicalException ex) {
            // OK
        } catch (Exception ex) {
            fail("'100abc': LexicalException expected.");
        }
        _input = "3.14abc";
        _expected = null;
        try {
            _test();
            fail("'3.14abc': LexicalException expected.");
        } catch (LexicalException ex) {
            // OK
        } catch (Exception ex) {
            fail("'3.14abc': LexicalException expected.");
        }
    }

    public void testScanner13() {  // comment
        _input = "// foo\n123/* // \n*/456";
        _expected = "INTEGER 123\nINTEGER 456\n";
        _test();
        _input = "/* \n//";
        _expected = null;
        try {
            _test();
            fail("LexicalException expected.");
        } catch (LexicalException ex) {
            // OK
        } catch (Exception ex) {
            fail("LexicalException expected but " + ex.getClass().getName() + " throwed.");
        }
    }

    public void testScanner14() {  // 'string'
        _input = "'str1'";
        _expected = "STRING \"str1\"\n";
        _test();
        _input = "'\n\r\t\\ \\''";
        _expected = "STRING \"\\n\\r\\t\\\\ '\"\n";
        _test();
    }

    public void testScanner15() {  // "string"
        _input = "\"str\"";
        _expected = "STRING \"str\"\n";
        _test();
        _input = "\"\\n\\r\\t\\'\\\"\"";
        _expected = "STRING \"\\n\\r\\t'\\\"\"\n";
        _test();
    }

    public void testScanner21() {  // alithmetic op
        _input = "+ - * / % .+";
        _expected = "ADD +\nSUB -\nMUL *\nDIV /\nMOD %\nCONCAT .+\n";
        _test();
    }

    public void testScanner22() {  // assignment op
        _input = "= += -= *= /= %= .+=";
        _expected = "ASSIGN =\nADD_TO +=\nSUB_TO -=\nMUL_TO *=\nDIV_TO /=\nMOD_TO %=\nCONCAT_TO .+=\n";
        _test();
    }

    public void testScanner23() {  // comparable op
        _input = "== != < <= > >=";
        _expected = "EQ ==\nNE !=\nLT <\nLE <=\nGT >\nGE >=\n";
        _test();
    }

    public void testScanner24() {  // logical op
        _input = "! && ||";
        _expected = "NOT !\nAND &&\nOR ||\n";
        _test();
    }

    public void testScanner25() {  // symbols
        _input = "[][::;?.,#";
        _expected = "L_BRACKET [\nR_BRACKET ]\nL_BRACKETCOLON [:\nCOLON :\n"
                         + "SEMICOLON ;\nCONDITIONAL ?:\nPERIOD .\nCOMMA ,\nSHARP #\n";
        _test();
    }

    public void testScanner26() {  // expand
        _input = "@stag";
        _expected = "EXPAND @stag\n";
        _test();
    }

    public void testScanner31() {  // raw expr
        _input = "s=" + "<" + "%= $foo %" + ">;";
        _expected = "NAME s\nASSIGN =\nRAWEXPR <" + "%= $foo %" + ">\nSEMICOLON ;\n";
        _test();
    }

    public void testScanner32() {  // raw stmt
        _input = "<" + "% $foo %" + ">";
        _expected = "RAWSTMT <" + "% $foo %" + ">\n";
        _test();
    }

    public void testScanner41() {  // invalid char
        _expected = null;
        try {
            _input = "~";
            _test();
            fail("LexicalException expected (ch = '~').");
        } catch (LexicalException ex) {
            // OK
        }
        try {
            _input = "^";
            _test();
            fail("LexicalException expected (ch = '~').");
        } catch (LexicalException ex) {
            // OK
        }
        try {
            _input = "$";
            _test();
            fail("LexicalException expected (ch = '~').");
        } catch (LexicalException ex) {
            // OK
        }
    }

    // -----

    public static void main(String[] args) {
       junit.textui.TestRunner.run(ScannerTest.class);
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

    public void testDoubleExpression1() {
        _expr = new DoubleExpression(3.14159);
        _testExpr(new Double(3.14159));
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

    Expression _f1 = new DoubleExpression(3.5);
    Expression _f2 = new DoubleExpression(2.2);
    public void testArithmeticExpression2() {
        double f1 = 3.5;
        double f2 = 2.2;
        _expr = new ArithmeticExpression(TokenType.ADD, _f1, _f2);
        _testExpr(new Double(f1+f2));
        _expr = new ArithmeticExpression(TokenType.SUB, _f1, _f2);
        _testExpr(new Double(f1-f2));
        _expr = new ArithmeticExpression(TokenType.MUL, _f1, _f2);
        _testExpr(new Double(f1*f2));
        _expr = new ArithmeticExpression(TokenType.DIV, _f1, _f2);
        _testExpr(new Double(f1/f2));
        _expr = new ArithmeticExpression(TokenType.MOD, _f1, _f2);
        _testExpr(new Double(f1%f2));
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
                                         new DoubleExpression(0.5f));
        _testExpr(new Double(0.5f));
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

    public void testIndexExpression1() {	// list[i]
        // list = [ "foo", "bar", "baz" ]
        Expression list = new VariableExpression("list");
        List arraylist = new ArrayList();
        arraylist.add("foo");
        arraylist.add("bar");
        arraylist.add("baz");
        _context.put("list", arraylist);

        // var = list[i];
        Expression i = new VariableExpression("i");
        _expr = new IndexExpression(TokenType.ARRAY, list, i);
        _context.put("i", new Integer(0));
        _testExpr("foo");
        _context.put("i", new Integer(1));
        _testExpr("bar");
        _context.put("i", new Integer(2));
        _testExpr("baz");
    }

    public void testIndexExpression2() {	// out of range access
        // list = []
        List arraylist = new ArrayList();
        Expression list = new VariableExpression("list");
        Expression i    = new VariableExpression("i");
        _expr = new IndexExpression(TokenType.ARRAY, list, i);
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

    public void testIndexExpression3() {	// list[0] == null
        List arraylist  = new ArrayList();
        Expression list = new VariableExpression("list");
        Expression i    = new VariableExpression("i");
        _expr = new IndexExpression(TokenType.ARRAY, list, i);
        _context.put("list", arraylist);
        arraylist.add(null);
        _context.put("i", new Integer(0));
        _testExpr(null);
    }

    public void testIndexExpression4() {	// hash['key']
        // hash[key]
        Expression hash = new VariableExpression("hash");
        Expression key  = new VariableExpression("key");
        _expr = new IndexExpression(TokenType.ARRAY, hash, key);

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

    public void testIndexExpression5() {	// hash['key'] is null
        // hash[key]
        Expression hash = new VariableExpression("hash");
        Expression key  = new VariableExpression("key");
        _expr = new IndexExpression(TokenType.ARRAY, hash, key);

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
    private String _expected = null;

    public void _testPrint() {
        try {
            StringWriter writer = new StringWriter();
            _stmt.execute(_context, writer);
            String actual = writer.toString();
            assertEquals(_expected, actual);
        }
        catch (IOException ex) {
            ex.printStackTrace();
        }
    }

    public void _testInspect() {
        assertEquals(_expected, _stmt._inspect());
    }

    public void testPrintStatement1() {  // literal
        Expression[] arglist = {
            new IntegerExpression(123),
            new StringExpression("foo"),
            new DoubleExpression(0.4),
            new BooleanExpression(true),
            new BooleanExpression(false),
            new NullExpression(),
        };
        _stmt = new PrintStatement(arglist);
        _expected = "123foo0.4truefalse";
        _testPrint();
    }

    public void testPrintStatement2() {  // variable
        Expression[] arglist = {
            new VariableExpression("x"),
            new VariableExpression("y"),
        };
        _context.put("x", new String("foo"));
        _context.put("y", new Integer(123));
        _stmt = new PrintStatement(arglist);
        _expected = "foo123";
        _testPrint();
    }

    public void testPrintStatement3() {  // null value
        Expression[] arglist = {
            new VariableExpression("x"),
            new VariableExpression("y"),
        };
        _context.put("x", new String("foo"));
        //_context.put("y", new Integer(123));
        _stmt = new PrintStatement(arglist);
        _expected = "foo";
        try {
            _testPrint();
            fail("EvaluationException expected but not happened.");
        } catch (EvaluationException ex) {
            // OK
        }
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
        _stmt = new PrintStatement(arglist);
        _expected = "10foobar";
        _testPrint();
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
        _stmt = new BlockStatement(stmts);
        _expected = "11";
        _testPrint();
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
        _stmt = new ForeachStatement(new VariableExpression("item"),
                                     new VariableExpression("list"),
                                     block);

        // test
        _expected = <<'END';
                item = foo
                item = 123
                item = bar
                END
        _testPrint();
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
        _stmt = new WhileStatement(condition, block);

        // test
        _expected = "4,3,2,1,0,";
        _testPrint();
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
        _stmt = new IfStatement(condition1, then_body, null);
        _expected = "Yes";
        _testPrint();
        _stmt = new IfStatement(condition2, then_body, null);
        _expected = "";
        _testPrint();
        _stmt = new IfStatement(condition1, then_body, else_body);
        _expected = "Yes";
        _testPrint();
        _stmt = new IfStatement(condition2, then_body, else_body);
        _expected = "No";
        _testPrint();
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

import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;

public class InterpreterTest extends TestCase {
    String _input;
    String _expected;
    Map _context = new HashMap();

    public void _test() {
        Interpreter interpreter = new Interpreter();
        interpreter.compile(_input);
        try {
            java.io.StringWriter writer = new java.io.StringWriter();
            interpreter.execute(_context, writer);
            String actual = writer.toString();
            assertEquals(_expected, actual);
        } catch (java.io.IOException ex) {
            ex.printStackTrace();
        }
        //StatementParser parser = new StatementParser();
        //BlockStatement block = parser.parse(_input);
        //try {
        //    java.io.StringWriter writer = new java.io.StringWriter();
        //    block.execute(_context, writer);
        //    String actual = writer.toString();
        //    assertEquals(_expected, actual);
        //}
        //catch (java.io.IOException ex) {
        //    ex.printStackTrace();
        //}
    }


    public void testInterpreter1() {    // hello world
        _input = <<'END';
            print("Hello ", user, "!\n");
            END
        _expected = <<'END';
            Hello World!
            END
        _context.put("user", "World");
        _test();
    }

    public void testInterpreter2() {    // euclidean algorithm
        _input = <<'END';
            // Euclidean algorithm
            x = a;  y = b;
            while (y > 0) {
                if (x < y) {
                    tmp = y - x;
                    y = x;
                    x = tmp;
                } else {
                    tmp = x - y;
                    x = y;
                    y = tmp;
                }
            }
            print("GCD(", a, ",", b, ") == ", x, "\n");
            print("(x,y) == (", x, ",", y, ")\n");
            END
        _expected = <<'END';
            GCD(589,775) == 31
            (x,y) == (31,0)
            END
        _context.put("a", new Integer(589));
        _context.put("b", new Integer(775));
        _test();
    }

    public void testInterpreter3() {   // bordered table
        _input = <<'END';
            print("<table>\n");
            i = 0;
            foreach(item in list) {
              i += 1;
              color = i % 2 == 0 ? '#FFCCCC' : '#CCCCFF';
              print('  <tr bgcolor="', color, "\">\n");
              print("    <td>", item[:name], "</td><td>", item[:mail], "</td>\n");
              print("  </tr>\n");
            }
            print("</table>\n");
            END
        _expected = <<'END';
            <table>
              <tr bgcolor="#CCCCFF">
                <td>foo</td><td>foo@mail.com</td>
              </tr>
              <tr bgcolor="#FFCCCC">
                <td>bar</td><td>bar@mail.org</td>
              </tr>
              <tr bgcolor="#CCCCFF">
                <td>baz</td><td>baz@mail.net</td>
              </tr>
            </table>
            END
        //
        List list = new ArrayList();
        //
        Map item1 = new HashMap();
        item1.put("name", "foo");  item1.put("mail", "foo@mail.com");
        list.add(item1);
        //
        Map item2 = new HashMap();
        item2.put("name", "bar");  item2.put("mail", "bar@mail.org");
        list.add(item2);
        //
        Map item3 = new HashMap();
        item3.put("name", "baz");  item3.put("mail", "baz@mail.net");
        list.add(item3);
        //
        _context.put("list", list);
        _test();
    }


    // -----

    public static void main(String[] args) {
       junit.textui.TestRunner.run(InterpreterTest.class);
    }
}

// --------------------------------------------------------------------------------

package __PACKAGE__;
import junit.framework.TestCase;
import junit.framework.TestSuite;

import java.util.*;
import java.io.*;

public class FunctionTest extends TestCase {
    String _input;
    String _expected;
    Map _context = new Context();

    public void _test() throws Exception {
        _test(false);
    }
    public void _test(boolean flagPrint) throws Exception {
        StatementParser parser = new StatementParser();
        BlockStatement stmt = parser.parse(_input);
        StringWriter writer = new StringWriter();
        stmt.execute(_context, writer);
        String actual = writer.toString();
        writer.close();
        if (flagPrint)
            System.out.println(actual);
        else
            assertEquals(_expected, actual);
    }

    public void testEscapeFunction1() throws Exception {
        _input = <<'END';
            s = "<em>\"A&B\"</em>\n";
            print(E(s));
            print(X(s));
            print(escape_xml(s));
            print(escape_url('http://localhost/~user/index?arg=<tag attr="foo">'), "\n");
            print(escape_sql("'quote'" .+ '"doublequote"' .+ '\\escape'), "\n");
            END
        _expected = <<'END';
            &lt;em&gt;&quot;A&amp;B&quot;&lt;/em&gt;
            <em>"A&B"</em>
            &lt;em&gt;&quot;A&amp;B&quot;&lt;/em&gt;
            http%3A%2F%2Flocalhost%2F%7Euser%2Findex%3Farg%3D%3Ctag+attr%3D%22foo%22%3E
            \'quote\'\"doublequote\"\\escape
            END
        _test();
    }

    public void testStringFunction1() throws Exception {
        _input = <<'END';
            s = " abc DEF";
            print(str_length(s), "\n");
            print(str_tolower(s), "\n");
            print(str_toupper(s), "\n");
            print(str_trim(s), "\n");
            print(str_empty(s) ? "empty" : "not empty", "\n");
            print(str_empty("") ? "empty" : "not empty", "\n");
            END
        _expected = <<'END';
            8
             abc def
             ABC DEF
            abc DEF
            not empty
            empty
            END
        _test();
    }

    public void testListFunction1() throws Exception {
        _input = <<'END';
            list = list_new();
            print(list_length(list), "\n");
            print(list_empty(list) ? "empty" : "not empty", "\n");
            list[0] = "a";
            print(list[0], "\n");
            list_add(list, 123);
            print(list[1], "\n");
            print(list_empty(list) ? "empty" : "not empty", "\n");
            END
        _expected = <<'END';
            0
            empty
            a
            123
            not empty
            END
        _test();
    }

    public void testHashFunction1() throws Exception {
        _input = <<'END';
            hash = hash_new();
            print(hash_length(hash), "\n");
            print(hash_empty(hash) ? "empty" : "not empty", "\n");
            hash['foo'] = "FOO";
            print(hash['foo'], "\n");
            hash[:bar]  = "BAR";
            print(hash[:bar], "\n");
            list = hash_keys(hash);
            print(list_length(list), "\n");
            print("<", hash['null'], ">\n");
            print(hash_length(hash), "\n");
            print(hash_empty(hash) ? "empty" : "not empty", "\n");
            END
        _expected = <<'END';
            0
            empty
            FOO
            BAR
            2
            <>
            2
            not empty
            END
        _test();
    }

    // -----

    public static void main(String[] args) {
       junit.textui.TestRunner.run(FunctionTest.class);
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
        suite.addTest(new TestSuite(ExpressionParserTest.class));
        suite.addTest(new TestSuite(StatementParserTest.class));
        suite.addTest(new TestSuite(InterpreterTest.class));
        suite.addTest(new TestSuite(ConverterTest.class));
        suite.addTest(new TestSuite(TagHelperTest.class));
        suite.addTest(new TestSuite(DeclarationParserTest.class));
        suite.addTest(new TestSuite(ExpanderTest.class));
        suite.addTest(new TestSuite(CompilerTest.class));
        suite.addTest(new TestSuite(OptimizerTest.class));
        suite.addTest(new TestSuite(FunctionTest.class));
        suite.addTest(new TestSuite(KwartzClassTest.class));
        junit.textui.TestRunner.run(suite);
    }
}

// ================================================================================
