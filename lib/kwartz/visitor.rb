###
### copyright(c) 2005 kuwata-lab all rights reserved
###
### $Id$
###

require 'kwartz/exception'

module Kwartz
   
   module Visitor

      ## don't override the method!
      def visit(node, depth=0)
         return node.accept(self, depth)
      end
      
      ##############################
      
      def visit_expression(expr, depth=0)
         # nothing
      end
      
      def visit_unary_expression(expr, depth=0)
         expr.child.accept(self, depth+1)
      end

      def visit_empty_expression(expr, depth=0)
         expr.child.accept(self, depth+1)
      end

      def visit_binary_expression(expr, depth=0)
         expr.left.accept(self, depth+1)
         expr.right.accept(self, depth+1)
      end

      def visit_funtion_expression(expr, depth=0)
         expr.arguments.each do |arg|
            arg.accept(self, depth+1)
         end
      end

      def visit_property_expression(expr, depth=0)
         expr.object.accept(self, depth+1)
         expr.arguments.each do |arg|
            arg.accept(self, depth+1)
         end if expr.arguments
      end

      def visit_conditional_expression(expr, depth=0)
         expr.condition.accept(self, depth+1)
         expr.left.accept(self, depth+1)
         expr.right.accept(self, depth+1)
      end

      def visit_literal_expression(expr, depth=0)
         # nothing
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


      ## ----------------------------------------
      
      def visit_statement(stmt, depth=0)
         # nothing
      end
      
      def visit_print_statement(stmt, depth=0)
         stmt.arguments.each do |expr|
            expr.accept(self, depth+1)
         end
      end
      
      def visit_expr_statement(stmt, depth=0)
         stmt.expression.accept(self, depth+1)
      end
      
      def visit_block_statement(stmt, depth=0)
         stmt.statements.each do |st|
            st.accept(self, depth+1)
         end
      end
      
      def visit_if_statement(stmt, depth=0)
         stmt.condition.accept(self, depth+1)
         stmt.then_stmt.accept(self, depth+1)
         stmt.else_stmt.accept(self, depth+1)
      end
      
      def visit_foreach_statement(stmt, depth=0)
         stmt.list_expr.accept(self, depth+1)
         stmt.loopvar_expr.accept(self, depth+1)
         stmt.body_stmt.accept(self, depth+1)
      end
      
      def visit_while_statement(stmt, depth=0)
         stmt.condition.accept(self, depth+1)
         stmt.body_stmt.accept(self, depth+1)
      end
      
      def visit_expand_statement(stmt, depth=0)
         # nothing
      end
      
      def visit_rawcode_statement(stmt, depth=0)
         # nothing
      end
      
   end

end

