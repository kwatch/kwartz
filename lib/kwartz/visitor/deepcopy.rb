###
### copyright(c) 2005 kuwata-lab all rights reserved
###
### $Id$
### $Release$
###

require 'kwartz/visitor'
require 'kwartz/node'

module Kwartz

   class DeepCopyVisitor
      include Visitor

      def visit_unary_expression(expr, depth=0)
         child = expr.child.accept(self, depth+1)
         return UnaryExpression.new(expr.token, child)
      end

      def visit_empty_expression(expr, depth=0)
         child = expr.child.accept(self, depth+1)
         return EmptyExpression.new(expr.token, child)
      end

      #def visit_binary_expression(expr, depth=0)
      #   left  = expr.left.accept(self, depth+1)
      #   right = expr.right.accept(self, depth+1)
      #   return BinaryExpression.new(expr.token, left, right)
      #end

      def visit_arithmetic_expression(expr, depth=0)
         left  = expr.left.accept(self, depth+1)
         right = expr.right.accept(self, depth+1)
         return ArithmeticExpression.new(expr.token, left, right)
      end

      def visit_assignment_expression(expr, depth=0)
         left  = expr.left.accept(self, depth+1)
         right = expr.right.accept(self, depth+1)
         return AssignmentExpression.new(expr.token, left, right)
      end

      def visit_relational_expression(expr, depth=0)
         left  = expr.left.accept(self, depth+1)
         right = expr.right.accept(self, depth+1)
         return RelationalExpression.new(expr.token, left, right)
      end

      def visit_logical_expression(expr, depth=0)
         left  = expr.left.accept(self, depth+1)
         right = expr.right.accept(self, depth+1)
         return LogicalExpression.new(expr.token, left, right)
      end

      def visit_index_expression(expr, depth=0)
         left  = expr.left.accept(self, depth+1)
         right = expr.right.accept(self, depth+1)
         return IndexExpression.new(expr.token, left, right)
      end

      def visit_funtion_expression(expr, depth=0)
         args = []
         expr.arguments.each do |arg|
            args << arg.accept(self, depth+1)
         end
         return FunctionExpression.new(expr.token, args)
      end

      def visit_property_expression(expr, depth=0)
         object = expr.object.accept(self, depth+1)
         propname = expr.propname
         return PropertyExpression.new(object, propname)
      end

      def visit_method_expression(expr, depth=0)
         receiver = expr.receiver.accept(self, depth+1)
         args = nil
         args = []
         expr.arguments.each do |arg|
            args << arg.accept(self, depth+1)
         end
         return MethodExpression.new(object, args)
      end

      def visit_conditional_expression(expr, depth=0)
         condition = expr.condition.accept(self, depth+1)
         left  = expr.left.accept(self, depth+1)
         right = expr.right.accept(self, depth+1)
         return ConditionalExpression.new(condition, left, right)
      end

      def visit_variable_expression(expr, depth=0)
         return VariableExpression.new(expr.name)
      end

      #def visit_literal_expression(expr, depth=0)
      #   # nothing
      #end

      def visit_numeric_expression(expr, depth=0)
         return NumericExpression.new(expr.value)
      end

      def visit_string_expression(expr, depth=0)
         return StringExpression.new(expr.value)
      end

      def visit_boolean_expression(expr, depth=0)
         return BooleanExpression.new(expr.value)
      end

      def visit_null_expression(expr, depth=0)
         return NullExpression.new()
      end

      ## ----------------------------------------

      def visit_statement(stmt, depth=0)
         # nothing
      end

      def visit_print_statement(stmt, depth=0)
         args = []
         stmt.arguments.each do |expr|
            args << expr.accept(self, depth+1)
         end
         return PrintStatement.new(args)
      end

      def visit_expr_statement(stmt, depth=0)
         expr = stmt.expression.accept(self, depth+1)
         return ExprStatement.new(expr)
      end

      def visit_block_statement(stmt, depth=0)
         list = []
         stmt.statements.each do |st|
            list << st.accept(self, depth+1)
         end
         return BlockStatement.new(list)
      end

      def visit_if_statement(stmt, depth=0)
         condition = stmt.condition.accept(self, depth+1)
         then_stmt = stmt.then_stmt.accept(self, depth+1)
         else_stmt = stmt.else_stmt.accept(self, depth+1)
         return IfStatement.new(condition, then_stmt, else_stmt)
      end

      def visit_foreach_statement(stmt, depth=0)
         list_expr    = stmt.list_expr.accept(self, depth+1)
         loopvar_expr = stmt.loopvar_expr.accept(self, depth+1)
         body_stmt    = stmt.body_stmt.accept(self, depth+1)
         return ForeachStatement.new(loopvar_expr, list_expr, body_stmt)
      end

      def visit_while_statement(stmt, depth=0)
         condition = stmt.condition.accept(self, depth+1)
         body_stmt = stmt.body_stmt.accept(self, depth+1)
         return WhileStatement.new(condition, body_stmt)
      end

      def visit_expand_statement(stmt, depth=0)
         return ExpandStatement.new(stmt.type, stmt.name)
      end

      def visit_rawcode_statement(stmt, depth=0)
         return RawcodeStatement.new(stmt.rawcode)
      end

   end

end
