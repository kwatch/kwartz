###
### visitor.rb
###
### $Id$
###

require 'kwartz/exception'

module Kwartz
   
   module Visitor

      ## don't override the method!
      def visit(node, depth=nil)
         return node.accept(self, depth)
      end
      
      ##############################
      
      def visit_expression(expr, depth=0)
         # nothing
      end
      
      def visit_unary_expression(expr, depth=0)
         visit(expr.child, depth)
      end

      def visit_empty_expression(expr, depth=0)
         visit(expr.child, depth)
      end

      def visit_binary_expression(expr, depth=0)
         visit(expr.left, depth+1)
         visit(expr.right, depth+1)
      end

      def visit_funtion_expression(expr, depth=0)
         expr.arguments.each do |expr|
            visit(expr, depth+1)
         end
      end

      def visit_property_expression(expr, depth=0)
         visit(expr.object, depth+1)
         expr.arguments.each do |expr|
            visit(expr, depth+1)
         end if expr.arguments
      end

      def visit_conditional_expression(expr, depth=0)
         visit(expr.condition)
         visit(expr.left)
         visit(expr.right)
      end

      def visit_literal_expression(expr, depth=0)
         return visit_expression(expr, depth)
      end

      def visit_variable_expression(expr, depth=0)
         return visit_literal_expression(expr, depth)
      end

      def visit_numeric_expression(expr, depth=0)
         return visit_literal_expression(expr, depth)
      end

      def visit_string_expression(expr, depth=0)
         return visit_literal_expression(expr, depth)
      end

      def visit_boolean_expression(expr, depth=0)
         return visit_literal_expression(expr, depth)
      end

      def visit_null_expression(expr, depth=0)
         return visit_literal_expression(expr, depth)
      end


      #####################
      
      def visit_statement(stmt, depth=0)
         # nothing
      end
      
      def visit_print_statement(stmt, depth=0)
         stmt.arguments().each do |expr|
            visit(expr, depth)
         end
      end
      
      def visit_expr_statement(stmt, depth=0)
         visit(stmt.expression())
      end
      
      def visit_block_statement(stmt, depth=0)
         block_stmt = stmt
         block_stmt.statements().each do |st|
            visit(st)
         end
      end
      
      def visit_if_statement(stmt, depth=0)
         visit(stmt.condition())
         visit(stmt.then_block())
         visit(stmt.else_stmt()) if stmt.else_stmt()
      end
      
      def visit_foreach_statement(stmt, depth=0)
         visit(stmt.loopvar())
         visit(stmt.list())
         visit(stmt.body())
      end
      
      def visit_while_statement(stmt, depth=0)
         visit(stmt.condition())
         visit(stmt.body())
      end
      
      def visit_macro_statement(stmt, depth=0)
         visit(stmt.body())
      end
      
      def visit_expand_statement(stmt, depth=0)
         # nothing
      end
      
      def visit_rawcode_statement(stmt, depth=0)
         # nothing
      end
      
   end

end

