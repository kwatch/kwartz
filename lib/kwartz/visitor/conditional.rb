###
### copyright(c) 2005 kuwata-lab all rights reserved
###
### $Id$
### $Release$
###

require 'kwartz/visitor'
require 'kwartz/visitor/deepcopy'
require 'kwartz/node'

module Kwartz

   ##
   class ConditionalDeepCopyVisitor < DeepCopyVisitor
      attr_accessor :option
      def visit_conditional_expression(expr, depth=0)
         if @option == :left
            @option = nil
            return expr.left.accept(self, depth)
         elsif @option == :right
            @option = nil
            return expr.right.accept(self, depth)
         else
            super(expr, depth)
         end
      end
   end

   ##
   class ConditionalExpressionFindVisitor
      include Visitor

      def visit_expression(expr, depth=0)
         # nothing
      end

      def visit_unary_expression(expr, depth=0)
         return expr.child.accept(self, depth+1)
      end

      def visit_empty_expression(expr, depth=0)
         return expr.child.accept(self, depth+1)
      end

      def visit_binary_expression(expr, depth=0)
         ret = expr.left.accept(self, depth+1)
         return ret ? ret : expr.right.accept(self, depth+1)
      end

      def visit_arithmetic_expression(expr, depth=0)
         return visit_binary_expression(expr, depth)
      end

      def visit_assignment_expression(expr, depth=0)
         return visit_binary_expression(expr, depth)
      end

      def visit_relational_expression(expr, depth=0)
         return visit_binary_expression(expr, depth)
      end

      def visit_logical_expression(expr, depth=0)
         return visit_binary_expression(expr, depth)
      end

      def visit_index_expression(expr, depth=0)
         return visit_binary_expression(expr, depth)
      end

      def visit_funtion_expression(expr, depth=0)
         expr.arguments.each do |arg|
            ret = arg.accept(self, depth+1)
            return ret if ret
         end
         return nil
      end

      def visit_property_expression(expr, depth=0)
         return expr.object.accept(self, depth+1)
      end

      def visit_method_expression(expr, depth=0)
         ret = expr.receiver.accept(self, depth+1)
         return ret if ret
         expr.arguments.each do |arg|
            ret = arg.accept(self, depth+1)
            return ret if ret
         end
         return nil
      end

      def visit_conditional_expression(expr, depth=0)
         return expr
      end

      #def visit_literal_expression(expr, depth=0)
      #   # nothing
      #end

      def visit_variable_expression(expr, depth=0)
         return nil
      end

      def visit_numeric_expression(expr, depth=0)
         return nil
      end

      def visit_string_expression(expr, depth=0)
         return nil
      end

      def visit_boolean_expression(expr, depth=0)
         return nil
      end

      def visit_null_expression(expr, depth=0)
         return nil
      end

      ## ----------------------------------------

      #def visit_statement(stmt, depth=0)
      #   # nothing
      #end

      def visit_print_statement(stmt, depth=0)
         stmt.arguments.each do |expr|
            ret = expr.accept(self, depth+1)
            return ret if ret
         end
         return nil
      end

      def visit_expr_statement(stmt, depth=0)
         return stmt.expression.accept(self, depth+1)
      end

      def visit_block_statement(stmt, depth=0)
         return nil
         #stmt.statements.each do |st|
         #   st.accept(self, depth+1)
         #end
      end

      def visit_if_statement(stmt, depth=0)
         return stmt.condition.accept(self, depth+1)
      end

      def visit_foreach_statement(stmt, depth=0)
         return stmt.list_expr.accept(self, depth+1)
      end

      def visit_while_statement(stmt, depth=0)
         return stmt.condition.accept(self, depth+1)
      end

      def visit_expand_statement(stmt, depth=0)
         return nil
      end

      def visit_rawcode_statement(stmt, depth=0)
         return nil
      end

   end

end
