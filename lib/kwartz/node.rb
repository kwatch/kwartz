###
### copyright(c) 2005 kuwata-lab all rights reserved
###
### $Id$
### $Release$
###

##  class hierarchy:
##
##    Node
##	Expression
##	   Unary
##	   Binary
##	     Arithmetic
##	     Assignment
##	     Logical
##	     Relational
##	   Function
##	   Method
##	   Property
##	   Variable
##	   Literal
##	     Numeric
##	     String
##	     Boolean
##	     Null
##	     Rawcode
##	Statement
##	   Print
##	   Expr
##	   Block
##	   If
##	   Foreach
##	   Macro
##	   Expand
##	   Rawcode
##


require 'kwartz/exception'
require 'kwartz/utility'

module Kwartz

   ## abstract class for Expression and Statement
   class Node

      def initialize(token)
         @token = token
      end
      attr_accessor :token

      def _inspect(depth=0, s='')
         raise Kwartz::NotImplemenetedError("#{self.class.name}#accept(): not implemented yet.")
      end

      def indent(depth=0, s='')
         s << ('  ' * depth) if depth > 0
      end
      protected :indent

      def accept(visitor, depth=0)
         raise Kwartz::NotImplemenetedError("#{self.class.name}#accept(): not implemented yet.")
      end
   end


   ## abstract class
   class Expression < Node
      def _inspect(depth=0, s='')
         indent(depth, s)
         s << @token.to_s << "\n"
         return s
      end

      def accept(visitor, depth=0)
         return visitor.visit_expression(self, depth)
      end
   end


   ## token::  '-.', '+.', '!'
   class UnaryExpression < Expression
      def initialize(token, child_expr)
         super(token)
         @child = child_expr
      end
      attr_accessor :child

      def _inspect(depth=0, s='')
         super(depth, s)
         @child._inspect(depth+1, s)
         return s
      end

      def accept(visitor, depth=0)
         return visitor.visit_unary_expression(self, depth)
      end
   end


   ## token:: :empty :notempty
   class EmptyExpression < UnaryExpression
      def initialize(tkn, expr)
         super(tkn, expr)
      end

      def accept(visitor, depth=0)
         return visitor.visit_empty_expression(self, depth)
      end
   end


   ## abstract class
   class BinaryExpression < Expression
      def initialize(token, left_expr, right_expr)
         super(token)
         @left = left_expr
         @right = right_expr
      end
      attr_accessor :left, :right

      def _inspect(depth=0, s='')
         super(depth, s)
         @left._inspect(depth+1, s)
         @right._inspect(depth+1, s)
         return s
      end

      def accept(visitor, depth=0)
         return visitor.visit_binary_expression(self, depth)
      end
   end


   ## token:: '+', '-', '*', '/', '%', '.+'
   class ArithmeticExpression < BinaryExpression
      def initialize(token, left_expr, right_expr)
         super(token, left_expr, right_expr)
      end

      def accept(visitor, depth=0)
         return visitor.visit_arithmetic_expression(self, depth)
      end
   end


   ## token::  '=', '+=', '-=', '*=', '/=', '%=', '.+='
   class AssignmentExpression < BinaryExpression
      def initialize(token, left_expr, right_expr)
         super(token, left_expr, right_expr)
      end

      def accept(visitor, depth=0)
         return visitor.visit_assignment_expression(self, depth)
      end
   end

   
   ## token:: '==', '!=', '<', '<=', '>', '>='
   class RelationalExpression < BinaryExpression
      def initialize(token, left_expr, right_expr)
         super(token, left_expr, right_expr)
      end

      def accept(visitor, depth=0)
         return visitor.visit_relational_expression(self, depth)
      end
   end


   ## token:: '&&', '||'
   class LogicalExpression < BinaryExpression
      def initialize(token, left_expr, right_expr)
         super(token, left_expr, right_expr)
      end

      def accept(visitor, depth=0)
         return visitor.visit_logical_expression(self, depth)
      end
   end


   ## token:: '[]', '[:]'
   class IndexExpression < BinaryExpression
      def initialize(token, left_expr, right_expr)
         super(token, left_expr, right_expr)
      end

      def accept(visitor, depth=0)
         return visitor.visit_index_expression(self, depth)
      end
   end


   ## token:: :function
   class FunctionExpression < Expression
      def initialize(funcname, arguments=[])
         super(:function)
         @funcname = funcname
         @arguments = arguments
      end
      attr_accessor :funcname, :arguments

      def _inspect(depth=0, s='')
         indent(depth, s)
         s << @funcname << "()\n"
         @arguments.each do |expr|
            expr._inspect(depth+1, s)
         end
         return s
      end

      def accept(visitor, depth=0)
         return visitor.visit_funtion_expression(self, depth)
      end
   end


   ## token:: '.'
   class PropertyExpression < Expression
      def initialize(object_expr, propname)
         super('.')
         @object = object_expr
         @propname = propname
      end
      attr_accessor :object, :propname

      def _inspect(depth=0, s='')
         super(depth, s)
         @object._inspect(depth+1, s)
         indent(depth+1, s)
         s << @propname << "\n"
         return s
      end

      def accept(visitor, depth=0)
         return visitor.visit_property_expression(self, depth)
      end
   end


   ## token:: '.()'
   class MethodExpression < Expression
      def initialize(receiver_expr, method_name, arguments=[])
         super('.()')
         @receiver = receiver_expr
         @method_name = method_name
         @arguments = arguments
      end
      attr_accessor :receiver, :method_name, :arguments

      def _inspect(depth=0, s='')
         super(depth, s)
         @receiver._inspect(depth+1, s)
         indent(depth+1, s)
         s << @method_name << "\n"
         arguments.each do |expr|
            expr._inspect(depth+2, s)
         end
         return s
      end

      def accept(visitor, depth=0)
         return visitor.visit_method_expression(self, depth)
      end
   end


   ## token:: '?:'
   class ConditionalExpression < Expression
      def initialize(condition_expr, left_expr, right_expr)
         super('?:')
         @condition = condition_expr
         @left = left_expr
         @right = right_expr
      end
      attr_accessor :condition, :left, :right

      def _inspect(depth=0, s='')
         super(depth, s)
         @condition._inspect(depth+1, s)
         @left._inspect(depth+1, s)
         @right._inspect(depth+1, s)
         return s
      end

      def accept(visitor, depth=0)
         return visitor.visit_conditional_expression(self, depth)
      end
   end


   ## token::  :variable
   class VariableExpression < Expression
      def initialize(variable_name)
         super(:variable)
         @name = variable_name
      end
      attr_accessor :name

      def _inspect(depth=0, s='')
         indent(depth, s)
         s << @name << "\n"
         return s
      end

      def accept(visitor, depth=0)
         return visitor.visit_variable_expression(self, depth)
      end
   end



   ## ----------------------------------------


   ## abstract class
   class LiteralExpression < Expression
      def initialize(token, value)
         super(token)
         @value = value
      end
      attr_accessor :value

      def _inspect(depth=0, s='')
         indent(depth, s)
         s << @value.to_s << "\n"
         return s
      end

      def accept(visitor, depth=0)
         return visitor.visit_literal_expression(self, depth)
      end
   end


   ## token::  :numeric
   class NumericExpression < LiteralExpression
      def initialize(numeric_str)
         super(:numeric, numeric_str)
      end

      def accept(visitor, depth=0)
         return visitor.visit_numeric_expression(self, depth)
      end
   end


   ## token::  :string
   class StringExpression < LiteralExpression
      def initialize(string)
         super(:string, string)
      end

      def _inspect(depth=0, s='')
         indent(depth, s)
         s << Kwartz::Util.dump_str(value()) << "\n"
         return s
      end

      def accept(visitor, depth=0)
         return visitor.visit_string_expression(self, depth)
      end
   end


   ## token::  :ture, :false
   class BooleanExpression < LiteralExpression
      def initialize(flag)
         super(:boolean, flag)
      end

      def accept(visitor, depth=0)
         return visitor.visit_boolean_expression(self, depth)
      end
   end


   ## token::  :null
   class NullExpression < LiteralExpression
      def initialize(null=nil)
         super(:null, nil)
      end

      def _inspect(depth=0, s='')
         indent(depth, s)
         s << "null\n"
         return s
      end

      def accept(visitor, depth=0)
         return visitor.visit_null_expression(self, depth)
      end
   end


   ## token::  :rawexpr
   class RawcodeExpression < LiteralExpression
      def initialize(rawcode_str)
         super(:rawexpr, nil)
         @rawcode = rawcode_str
      end
      attr_accessor :rawcode

      def _inspect(depth=0, s='')
         indent(depth, s)
         s << "<%=#{@rawcode}%>\n"
         return s
      end

      def accept(visitor, depth=0)
         return visitor.visit_rawcode_expression(self, depth)
      end
   end


   ## ----------------------------------------

   ## abstract class for statement
   class Statement < Node
      def accept(visitor, depth=0)
         return visitor.visit_statement(self, depth)
      end

      def _inspect(depth=0, s='')
         indent(depth, s)
         s << ':' << token().id2name() << "\n"
         return s
      end
   end

   ## token::  :print
   class PrintStatement < Statement
      def initialize(arguments=[])
         super(:print)
         @arguments = arguments
      end
      attr_accessor :arguments

      def _inspect(depth=0, s='')
         super(depth, s)
         arguments.each do |expr|
            expr._inspect(depth+1, s)
         end
         return s
      end

      def accept(visitor, depth=0)
         return visitor.visit_print_statement(self, depth)
      end
   end


   ## token::  :expr
   class ExprStatement < Statement
      def initialize(expression)
         super(:expr)
         @expression = expression
      end
      attr_accessor :expression

      def _inspect(depth=0, s='')
         super(depth, s)
         @expression._inspect(depth+1, s)
         return s
      end

      def accept(visitor, depth=0)
         return visitor.visit_expr_statement(self, depth)
      end
   end


   ## token::  :block
   class BlockStatement < Statement
      def initialize(stmt_list=[])
         super(:block)
         @statements = stmt_list
      end
      attr_accessor :statements

      def _inspect(depth=0, s='')
         super(depth, s)
         @statements.each do |stmt|
            stmt._inspect(depth+1, s)
         end
         return s
      end

      def accept(visitor, depth=0)
         return visitor.visit_block_statement(self, depth)
      end

      ## ex.
      ##   macro_stmt_list = block_stmt.retrieve(:macro)
      def retrieve(stmt_token)
         return @statements.collect { |stmt| stmt.token == stmt_token }
      end
   end


   ## token::  :if
   class IfStatement < Statement
      def initialize(condition_expr, then_stmt, else_stmt=nil)
         super(:if)
         @condition  = condition_expr
         @then_stmt  = then_stmt
         @else_stmt  = else_stmt
      end
      attr_accessor :condition, :then_stmt, :else_stmt

      def _inspect(depth=0, s='')
         super(depth, s)
         @condition._inspect(depth+1, s)
         @then_stmt._inspect(depth+1, s)
         @else_stmt._inspect(depth+1, s) if @else_stmt
         return s
      end

      def accept(visitor, depth=0)
         return visitor.visit_if_statement(self, depth)
      end
   end


   ## token::  :foreach
   class ForeachStatement < Statement
      def initialize(loopvar_expr, list_expr, body_stmt)
         super(:foreach)
         @loopvar_expr = loopvar_expr
         @list_expr    = list_expr
         @body_stmt    = body_stmt
      end
      attr_accessor :loopvar_expr, :list_expr, :body_stmt

      def _inspect(depth=0, s='')
         super(depth, s)
         @loopvar_expr._inspect(depth+1, s)
         @list_expr._inspect(depth+1, s)
         @body_stmt._inspect(depth+1, s)
         return s
      end

      def accept(visitor, depth=0)
         return visitor.visit_foreach_statement(self, depth)
      end
   end


   ## token::  :while
   class WhileStatement < Statement
      def initialize(condition_expr, body_stmt)
         super(:while)
         @condition = condition_expr
         @body_stmt = body_stmt
      end
      attr_accessor :condition, :body_stmt

      def _inspect(depth=0, s='')
         super(depth, s)
         @condition._inspect(depth+1, s)
         @body_stmt._inspect(depth+1, s)
         return s
      end

      def accept(visitor, depth=0)
         return visitor.visit_while_statement(self, depth)
      end
   end


   ## token::  :macro
   class MacroStatement < Statement
      def initialize(macro_name, body_stmt)
         super(:macro)
         @macro_name = macro_name
         @body_stmt  = body_stmt
      end
      attr_accessor :macro_name, :body_stmt

      def _inspect(depth=0, s='')
         indent(depth, s)
         s << ':macro(' << @macro_name << ")\n"
         @body_stmt._inspect(depth+1, s)
         return s
      end

      def accept(visitor, depth=0)
         return visitor.visit_macro_statement(self, depth)
      end
   end


   ## token::  :expand
   class ExpandStatement < Statement
      def initialize(type, name=nil)
         super(:expand)
         @type = type		# :stag :etag :cont :element
         @name = name           # required only when :element
      end
      attr_accessor :type, :name

      def _inspect(depth=0, s='')
         indent(depth, s)
         if @type == :element
            s << '@element(' << @name << ")\n"
         else
            s << "@#{type}\n"
         end
         return s
      end

      def accept(visitor, depth=0)
         return visitor.visit_expand_statement(self, depth)
      end
   end


   ## token::  :rawcode
   class RawcodeStatement < Statement
      def initialize(rawcode_str)
         super(:rawcode)
         @rawcode = rawcode_str
      end
      attr_accessor :rawcode

      def _inspect(depth=0, s='')
         indent(depth, s)
         if @rawcode =~ /\A<[%?]/
            s << @rawcode
         elsif @rawcode[-1] == ?\n
            s << ':::' << @rawcode
         elsif @rawcode =~ /\Aphp\s/
            s << "<?#{@rawcode}?>\n"
         else
            s << "<%#{@rawcode}%>\n"
         end
         s << "\n" if s[-1] != ?\n
         return s
      end

      def accept(visitor, depth=0)
         return visitor.visit_rawcode_statement(self, depth)
      end
   end
   
   
end
