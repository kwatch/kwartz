###
### node.rb
###
### $Id$
###

##  class hierarchy:
##
##    Node
##	Expression
##	   Unary
##	   Binary
##	   Function
##	   Property
##	   Leaf
##	     Variable
##	     Numeric
##	     String
##	     Boolean
##	     Null
##	Statement
##	   Print
##	   Set
##         Block
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

      def accept(visitor)
         raise Kwartz::NotImplemenetedError("#{self.class.name}#accept(): not implemented yet.")
      end
   end


   ## abstract class
   class Expression < Node
      def _inspect(depth=0, s='')
         indent(depth, s)
         s << @token << "\n"
         return s
      end
      
      def accept(visitor)
         return visitor.visit_expression(self)
      end
   end


   ##
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

      def accept(visitor)
         return visitor.visit_unary_expression(self)
      end
   end


   ##
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

      def accept(visitor)
         return visitor.visit_binary_expression(self)
      end
   end


   ##
   class FunctionExpression < Expression
      def initialize(funcname, arglist=[])
         super(:function)
         @funcname = funcname
         @arglist = arglist
      end
      attr_accessor :funcname, :arglist

      def _inspect(depth=0, s='')
         indent(depth, s)
         s << @funcname << "()\n"
         @arglist.each do |expr|
            expr._inspect(depth+1, s)
         end
         return s
      end

      def accept(visitor)
         return visitor.visit_funtion_expression(self)
      end
   end


   ##
   class PropertyExpression < Expression
      def initialize(object_expr, propname, arglist=nil)
         super('.')
         @object = object_expr
         @propname = propname
         @arglist = arglist
      end
      attr_accessor :object, :propname, :arglist

      def _inspect(depth=0, s='')
         super(depth, s)
         @object._inspect(depth+1, s)
         indent(depth+1, s)
         s << @propname << "\n"
         if arglist
            arglist.each do |expr|
               expr._inspect(depth+2, s)
            end
         end
         return s
      end

      def accept(visitor)
         return visitor.visit_property_expression(self)
      end
   end


   ##
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

      def accept(visitor)
         return visitor.visit_conditional_expression(self)
      end
   end


   ## ----------------------------------------


   ## abstract class which doesn't have child expressions
   class LeafExpression < Expression
      def initialize(token, value)
         super(token)
         @value = value
      end
      attr_accessor :value

      def _inspect(depth=0, s='')
         indent(depth, s)
         s << @value << "\n"
         return s
      end

      def accept(visitor)
         return visitor.visit_leaf_expression(self)
      end
   end


   ##
   class VariableExpression < LeafExpression
      def initialize(variable_name)
         super(:variable, variable_name)
      end

      def accept(visitor)
         return visitor.visit_variable_expression(self)
      end
   end


   ##
   class NumericExpression < LeafExpression
      def initialize(numeric_str)
         super(:numeric, numeric_str)
      end

      def accept(visitor)
         return visitor.visit_numeric_expression(self)
      end
   end


   ##
   class StringExpression < LeafExpression
      def initialize(string)
         super(:string, string)
      end

      def _inspect(depth=0, s='')
         indent(depth, s)
         s << Kwartz::Util.dump_str(value()) << "\n"
         return s
      end

      def accept(visitor)
         return visitor.visit_string_expression(self)
      end
   end


   ##
   class BooleanExpression < LeafExpression
      def initialize(value)
         super(:boolean, value)
      end

      def accept(visitor)
         return visitor.visit_boolean_expression(self)
      end
   end


   ##
   class NullExpression < LeafExpression
      def initialize(value='null')
         super(:null, value)
      end

      def accept(visitor)
         return visitor.visit_null_expression(self)
      end
   end


   ## ----------------------------------------

   ## abstract class for statement
   class Statement < Node
      def accept(visitor)
         return visitor.visit_statement(self)
      end

      def _inspect(depth=0, s='')
         indent(depth, s)
         s << ':' << token().id2name() << "\n"
         return s
      end
   end

   ##
   class PrintStatement < Statement
      def initialize(arglist=[])
         super(:print)
         @arglist = arglist
      end
      attr_accessor :arglist

      def _inspect(depth=0, s='')
         super(depth, s)
         arglist.each do |expr|
            expr._inspect(depth+1, s)
         end
         return s
      end

      def accept(visitor)
         return visitor.visit_print_statement(self)
      end
   end


   ##
   class SetStatement < Statement
      def initialize(assign_expr)
         super(:set)
         @expr = assign_expr
      end
      attr_accessor :expr

      def _inspect(depth=0, s='')
         super(depth, s)
         @expr._inspect(depth+1, s)
         return s
      end

      def accept(visitor)
         return visitor.visit_set_statement(self)
      end
   end


   ##
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

      def accept(visitor)
         return visitor.visit_block_statement(self)
      end

      ## ex.
      ##   macro_stmt_list = block_stmt.retrieve(:macro)
      def retrieve(stmt_token)
         return @statements.collect { |stmt| stmt.token == stmt_token }
      end
   end


   ##
   class IfStatement < Statement
      def initialize(condition_expr, then_block, else_stmt=nil)
         super(:if)
         @condition  = condition_expr
         @then_block = then_block
         @else_stmt  = else_stmt
      end

      def _inspect(depth=0, s='')
         super(depth, s)
         @condition._inspect(depth+1, s)
         @then_block._inspect(depth+1, s)
         @else_stmt._inspect(depth+1, s) if @else_stmt
         return s
      end

      def accept(visitor)
         return visitor.visit_if_statement(self)
      end
   end


   ##
   class ForeachStatement < Statement
      def initialize(loopvar_expr, list_expr, body_block)
         super(:foreach)
         @loopvar = loopvar_expr
         @list    = list_expr
         @body    = body_block
      end
      attr_accessor :loopvar, :list, :body

      def _inspect(depth=0, s='')
         super(depth, s)
         @loopvar._inspect(depth+1, s)
         @list._inspect(depth+1, s)
         @body._inspect(depth+1, s)
         return s
      end

      def accept(visitor)
         return visitor.visit_foreach_statement(self)
      end
   end


   ##
   class WhileStatement < Statement
      def initialize(condition_expr, body_block)
         super(:while)
         @condition = condition_expr
         @body    = body_block
      end
      attr_accessor :condition, :body

      def _inspect(depth=0, s='')
         super(depth, s)
         @condition._inspect(depth+1, s)
         @body._inspect(depth+1, s)
         return s
      end

      def accept(visitor)
         return visitor.visit_while_statement(self)
      end
   end


   ##
   class MacroStatement < Statement
      def initialize(macro_name, body_block)
         super(:macro)
         @macro_name = macro_name
         @body       = body_block
      end
      attr_accessor :macro_name, :body

      def _inspect(depth=0, s='')
         indent(depth, s)
         s << ':macro(' << @macro_name << ")\n"
         @body._inspect(depth+1, s)
         return s
      end

      def accept(visitor)
         return visitor.visit_macro_statement(self)
      end
   end


   ##
   class ExpandStatement < Statement
      def initialize(macro_name)
         super(:expand)
         @macro_name = macro_name
      end
      attr_accessor :macro_name, :body

      def _inspect(depth=0, s='')
         indent(depth, s)
         s << ':expand(' << @macro_name << ")\n"
         return s
      end

      def accept(visitor)
         return visitor.visit_expand_statement(self)
      end
   end


   ##
   class RawcodeStatement < Statement
      def initialize(rawcode_str)
         super(:rawcode)
         @rawcode = rawcode_str
      end
      attr_accessor :rawcode

      def _inspect(depth=0, s='')
         indent(depth, s)
         s << '::: ' << @rawcode
         s << "\n" if @rawcode[-1] != ?\n
         return s
      end

      def accept(visitor)
         return visitor.visit_rawcode_statement(self)
      end
   end

end
