###
### visitor.rb
###
### $Id$
###

require 'kwartz/exception'

module Kwartz
   
   class Visitor

      ## don't override the method!
      def visit(node)
         return node.accept(self)
      end
      
      def visit_expression(node)
         # nothing
      end
      
      def visit_unary_expression(node)
         return visit_expression(node)
      end

      def visit_binary_expression(node)
         return visit_expression(node)
      end

      def visit_funtion_expression(node)
         return visit_expression(node)
      end

      def visit_property_expression(node)
         return visit_expression(node)
      end

      def visit_conditional_expression(node)
         return visit_expression(node)
      end

      def visit_leaf_expression(node)
         return visit_expression(node)
      end

      def visit_variable_expression(node)
         return visit_leaf_expression(node)
      end

      def visit_numeric_expression(node)
         return visit_leaf_expression(node)
      end

      def visit_string_expression(node)
         return visit_leaf_expression(node)
      end

      def visit_boolean_expression(node)
         return visit_leaf_expression(node)
      end

      def visit_null_expression(node)
         return visit_leaf_expression(node)
      end

   end

end

