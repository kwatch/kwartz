###
### node.rb
###
### $Id$
###

##  class hierarchy:
##
##  Node
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
         indent(depth, s)
         if @token.is_a?(Symbol)
            s << ':' << @token.id2name << "\n"
         else
            s << @token << "\n"
         end
         return s
      end

      def indent(depth=0, s='')
         s << ('  ' * depth) if depth > 0
      end
      protected :indent

      def accept(visitor)
         raise NotImplemenetedError("#{self.class.name}#accept(): not implemented yet.")
      end
   end


   ## abstract class
   class Expression < Node
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
         super('<fcall>')
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
         indent(depth, s)
         s << @propname << (arglist ? "()\n" : "\n")
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
         @condition = cond_expr
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
         super('<var>', variable_name)
      end

      def accept(visitor)
         return visitor.visit_variable_expression(self)
      end
   end


   ##
   class NumericExpression < LeafExpression
      def initialize(numeric_str)
         super('<num>', numeric_str)
      end

      def accept(visitor)
         return visitor.visit_numeric_expression(self)
      end
   end


   ##
   class StringExpression < LeafExpression
      def initialize(string)
         super('<str>', string)
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
         super('<bool>', value)
      end

      def accept(visitor)
         return visitor.visit_boolean_expression(self)
      end
   end


   ##
   class NullExpression < LeafExpression
      def initialize(value='null')
         super('<null>', value)
      end

      def accept(visitor)
         return visitor.visit_null_expression(self)
      end
   end


   ## ----------------------------------------

   ## abstract class for statement
   class Statement < Node
   end

   class BlockStatement < Statement
   end

end
