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
      
      ##############################
      
      def visit_expression(expr)
         # nothing
      end
      
      def visit_unary_expression(expr)
         visit(expr.child)
      end

      def visit_binary_expression(expr)
         visit(expr.left)
         visit(expr.right)
      end

      def visit_funtion_expression(expr)
         expr.arglist.each do |expr|
            visit(expr)
         end
      end

      def visit_property_expression(expr)
         visit(expr.object)
         expr.arglist.each do |expr|
            visit(expr)
         end if expr.arglist
      end

      def visit_conditional_expression(expr)
         visit(expr.condition)
         visit(expr.left)
         visit(expr.right)
      end

      def visit_leaf_expression(expr)
         return visit_expression(expr)
      end

      def visit_variable_expression(expr)
         return visit_leaf_expression(expr)
      end

      def visit_numeric_expression(expr)
         return visit_leaf_expression(expr)
      end

      def visit_string_expression(expr)
         return visit_leaf_expression(expr)
      end

      def visit_boolean_expression(expr)
         return visit_leaf_expression(expr)
      end

      def visit_null_expression(expr)
         return visit_leaf_expression(expr)
      end


      #####################
      
      def visit_statement(stmt)
         # nothing
      end
      
      def visit_print_statement(stmt)
         stmt.arglist().each do |expr|
            visit(expr)
         end
      end
      
      def visit_set_statement(stmt)
         visit(stmt.expr())
      end
      
      def visit_block_statement(stmt)
         block_stmt = stmt
         block_stmt.statements().each do |st|
            visit(st)
         end
      end
      
      def visit_if_statement(stmt)
         visit(stmt.condition())
         visit(stmt.then_block())
         visit(stmt.else_stmt()) if stmt.else_stmt()
      end
      
      def visit_foreach_statement(stmt)
         visit(stmt.loopvar())
         visit(stmt.list())
         visit(stmt.body())
      end
      
      def visit_while_statement(stmt)
         visit(stmt.condition())
         visit(stmt.body())
      end
      
      def visit_macro_statement(stmt)
         visit(stmt.body())
      end
      
      def visit_expand_statement(stmt)
         # nothing
      end
      
      def visit_rawcode_statement(stmt)
         # nothing
      end
      
   end

end

