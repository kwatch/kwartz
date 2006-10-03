require 'abstract'
require 'parser'


module Kwartz


  class SemanticError < ParseError
  end


  class Node

    def initialize(token)
      @token = token
    end
    attr_accessor :token
    attr_accessor :parent
    attr_accessor :linenum, :column, :filename


    def available_as_lhs?
      return false
    end


    def _error(message)
      linenum = column = nil
      return SemanticError.new(message, linenum, column)
    end


    def _inspect(level=0, buf='')  # :nodoc:
      not_implemented
    end


    def _inspect_value(level, buf, val)  # :nodoc:
      buf << '  ' * level << val.to_s << "\n"
    end


  end



  class Expression < Node

    def _inspect_token(level, buf)  # :nodoc:
      _inspect_value(level, buf, @token)
    end

  end



  class BinaryExpression < Expression

    def initialize(token, left, right)
      super(token)
      @left = left
      @right = right
      left.parent  = self if left
      right.parent = self if right
    end
    attr_accessor :left, :right

    def _inspect(level=0, buf='')
      _inspect_token(level, buf)
      @left._inspect(level+1, buf)  if @left
      @right._inspect(level+1, buf) if @right
      return buf
    end

  end



  ## '+', '-', '*', '/', '%', '.+'(str concat), '+.'(unary), '-.'(unary)
  class ArithmeticExpression < BinaryExpression
  end


  ## '&&', '||', '!'
  class LogicalExpression < BinaryExpression
  end


  ## '==', '!=', '<', '<=', '>', '>='
  class RelationalExpression < BinaryExpression
  end


  ## '=', '+=', '-=', '*=', '/=', '%=', '.+='
  class AssignmentExpression < BinaryExpression

    def initialize(token, left, right)
      super(token, left, right)
      unless left.available_as_lhs?
        raise _error("#{@token}: invalid left-side value.")
      end
    end

  end


  ## '[]', '[:]'
  class IndexExpression < BinaryExpression

    def available_as_lhs?
      return true
    end

  end


  ## conditional operator ('?' and ':')
  class ConditionalExpression < Expression

    def initialize(condition, left, right)
      super(:'?:')
      @condition = condition
      @left = left
      @right = right
      left.parent = right.parent = self
    end
    attr_accessor :condition, :left, :right

    def _inspect(level=0, buf='')
      _inspect_token(level, buf)
      @condition._inspect(level+1, buf)
      @left._inspect(level+1, buf)
      @right._inspect(level+1, buf)
      return buf
    end

  end


  class FuncallExpression < Expression

    def initialize(funcname, arguments)
      super(:'()')
      @funcname = funcname
      @arguments = arguments
      arguments.each do |expr| expr.parent = self end
    end
    attr_accessor :funcname, :arguments

    def _inspect(level=0, buf='')
      #_inspect_token(level, buf)
      _inspect_value(level, buf, @funcname + '()')
      @arguments.each do |expr|
        expr._inspect(level+1, buf)
      end
      return buf
    end

  end


  class MethodExpression < Expression

    def initialize(receiver, methodname, arguments)
      super(:'.()')
      @receiver = receiver
      @methodname = methodname
      @arguments = arguments
      receiver.parent = self
      arguments.each do |expr| expr.parent = self end
    end
    attr_accessor :receiver, :methodname, :arguments

    def _inspect(level=0, buf='')
      _inspect_token(level, buf)
      @receiver._inspect(level+1, buf)
      _inspect_value(level+1, buf, '.'+@methodname+'()')
      @arguments.each do |expr|
        expr._inspect(level+2, buf)
      end
      return buf
    end

  end


  class PropertyExpression < Expression

    def initialize(receiver_expr, property_name)
      super(:'.')
      @receiver = receiver_expr
      @propname = property_name
      receiver_expr.parent = self
    end
    attr_accessor :receiver, :propname

    def available_as_lhs?
      return true
    end

    def _inspect(level=0, buf='')
      _inspect_token(level, buf)
      @receiver._inspect(level+1, buf)
      _inspect_value(level+1, buf, '.'+@propname)
      return buf
    end

  end



  class Literal < Expression

    def initialize(token, value)
      super(token)
      @value = value
    end
    attr_accessor :value

    def _inspect(level=0, buf='')
      _inspect_value(level, buf, @value.inspect)
      return buf
    end

  end


  class VariableLiteral < Literal
    def initialize(varname)
      super(:VARIABLE, varname)
    end
    alias name value

    def available_as_lhs?
      return true
    end

    def _inspect(level=0, buf='')
      _inspect_value(level, buf, @value)
      return buf
    end
  end


  class StringLiteral < Literal
    def initialize(value)
      super(:STRING, value)
    end
  end


  class NumberLiteral < Literal
    # abstract
  end


  class IntegerLiteral < Literal
    def initialize(value)
      super(:INTEGER, value)
    end
  end


  class FloatLiteral < Literal
    def initialize(value)
      super(:INTEGER, value)
    end
  end


  class BooleanLiteral < Literal
    # abstract
  end


  class TrueLiteral < Literal
    def initialize(value=true)
      super(:TRUE, value)
    end
  end


  class FalseLiteral < Literal
    def initialize(value=false)
      super(:FALSE, value)
    end
  end


  class NullLiteral < Literal
    def initialize(value=nil)
      super(:NULL, value)
    end
    def _inspect(level=0, buf='')
      _inspect_value(level, buf, 'null')
      return buf
    end
  end



  class Statement < Node

    def _inspect_token(level, buf)  # :nodoc:
      _inspect_value(level, buf, @token.inspect)
    end

  end



  class ExpressionStatement < Statement

    def initialize(expression)
      super(:EXPR)
      @expression = expression
      expression.parent = self
    end
    attr_accessor :expression

    def _inspect(level=0, buf='')
      _inspect_token(level, buf)
      @expression._inspect(level+1, buf)
      return buf
    end

  end



  class PrintStatement < Statement

    def initialize(arguments)
      super(:PRINT)
      @arguments = arguments
      arguments.each do |expr| expr.parent = self end
    end
    attr_accessor :arguments

    def _inspect(level=0, buf='')
      _inspect_token(level, buf)
      @arguments.each { |expr| expr._inspect(level+1, buf) }
      return buf
    end

  end



  class IfStatement < Statement

    def initialize(condition, then_stmt, else_stmt=nil)
      super(:IF)
      @condition = condition   # expression
      @then_stmt = then_stmt   # block-stmt
      @else_stmt = else_stmt   # block-stmt, if-stmt, or nil
      condition.parent = self
      then_stmt.parent = self
      else_stmt.parent = self if else_stmt
    end
    attr_accessor :condition, :then_stmt, :else_stmt

    def _inspect(level=0, buf='')
      _inspect_token(level, buf)
      @condition._inspect(level+1, buf)
      @then_stmt._inspect(level+1, buf)
      @else_stmt._inspect(level+1, buf) if @else_stmt
      return buf
    end

  end



  class WhileStatement < Statement

    def initialize(condition_expr, body)
      super(:WHILE)
      @condition = condition_expr
      @body = body
      condition_expr.parent = body.parent = self
    end
    attr_accessor :condition, :body

    def _inspect(level=0, buf='')
      _inspect_token(level, buf)
      @condition._inspect(level+1, buf)
      @body._inspect(level+1, buf) if @body
      return buf
    end

  end



  class ForeachStatement < Statement

    def initialize(loopvar_expr, list_expr, body)
      super(:FOREACH)
      @loopvar = loopvar_expr
      @list = list_expr
      @body = body
      unless @loopvar.token == :VARIABLE
        raise _error("#{@loopvar.token}: invalid loop-variable of foreach statement.")
      end
      loopvar_expr.parent = list_expr.parent = body.parent = self
    end
    attr_accessor :loopvar, :list, :body

    def _inspect(level=0, buf='')
      _inspect_token(level, buf)
      @loopvar._inspect(level+1, buf)
      @list._inspect(level+1, buf)
      @body._inspect(level+1, buf) if @body
      return buf
    end

  end



  class BlockStatement < Statement

    def initialize(statements)
      super(:BLOCK)
      @statements = statements
      statements.each do |stmt| stmt.parent = self end
    end
    attr_accessor :statements

    def _inspect(level=0, buf='')
      _inspect_token(level, buf)
      @statements.each do |stmt|
        stmt._inspect(level+1, buf)
      end
      return buf
    end

  end



  class BreakStatement < Statement

    def initialize()
      super(:BREAK)
    end

    def _inspect(level=0, buf='')
      _inspect_token(level, buf)
    end

  end



  class ContinueStatement < Statement

    def initialize()
      super(:CONTINUE)
    end

    def _inspect(level=0, buf='')
      _inspect_token(level, buf)
    end

  end



  class NativeStatement < Statement

    def initialize(native_code)
      super(:NATIVE)
      @code = native_code
    end
    attr_accessor :code

    def _inspect(level=0, buf='')
      #_inspect_token(level, buf)
      _inspect_value(level, buf, "<% #{@code} %>")
      return buf
    end

  end



  class TagStatement < Statement
  end


  class StagStatement < TagStatement

    def initialize()
      super(:STAG)
    end

    def _inspect(level=0, buf='')
      #_inspect_token(level, buf)
      _inspect_value(level, buf, '_stag')
      return buf
    end

  end


  class EtagStatement < TagStatement

    def initialize()
      super(:ETAG)
    end

    def _inspect(level=0, buf='')
      #_inspect_token(level, buf)
      _inspect_value(level, buf, '_etag')
      return buf
    end

  end


  class ContStatement < TagStatement

    def initialize()
      super(:CONT)
    end

    def _inspect(level=0, buf='')
      #_inspect_token(level, buf)
      _inspect_value(level, buf, '_cont')
      return buf
    end

  end


  class ElemStatement < TagStatement

    def initialize()
      super(:ELEM)
    end

    def _inspect(level=0, buf='')
      #_inspect_token(level, buf)
      _inspect_value(level, buf, '_elem')
      return buf
    end

  end


  class ElementStatement < TagStatement

    def initialize(name)
      super(:ELEMENT)
      @name = name
    end

    def _inspect(level=0, buf='')
      #_inspect_token(level, buf)
      _inspect_value(level, buf, "_element(#{@name})")
      return buf
    end

  end


  class ContentStatement < TagStatement

    def initialize(name)
      super(:CONTENT)
      @name = name
    end

    def _inspect(level=0, buf='')
      #_inspect_token(level, buf)
      _inspect_value(level, buf, "_content(#{@name})")
      return buf
    end

  end



  ##########


  class Ruleset < Node

    def initialize(selectors, declarations)
      super(:RULESET)
      @selectors = selectors         # list
      @declarations = declarations   # hash
    end
    attr_reader :selectors, :declarations

    def _inspect(level=0, buf='')
      buf << @selectors.join(', ') << " {\n"
      hash = @declarations
      [:stag, :cont, :etag, :elem, :value].each do |key|
        next unless expr = hash[key]
        buf << "  #{key}:\n"
        expr._inspect(2, buf)
      end
      if hash[:attrs]
        buf <<   "  attrs:\n"
        hash[:attrs].each do |tuple|
          name, expr = tuple
          buf << "    - '#{name}'\n"
          expr._inspect(3, buf)
        end
      end
      if hash[:append]
        buf <<   "  append:\n"
        hash[:append].each do |expr|
          expr._inspect(2, buf)
        end
      end
      if hash[:remove]
        buf <<   "  remove:\n"
        hash[:remove].each do |name|
          buf << "    - '#{name}'\n"
        end
      end
      [:logic, :begin, :end].each do |key|
        next unless stmts = hash[key]
        buf <<   "  logic: {\n"
        stmts.each do |stmt|
          stmt._inspect(2, buf)
        end
        buf <<   "  }\n"
      end
      if hash[:tagname]
        buf <<   "  tagname: '#{hash[:tagname]}'\n"
      end
      buf << "}\n"
      return buf
    end

  end

  ##########


  class NodeBuilder

    def initialize(parser)
      @parser = parser
    end

    def linenum
      @parser.linenum
    end

    def column
      @parser.column
    end

    def filename
      @parser.filename
    end

    def hook(node)
      node.linenum = @parser.linenum
      node.column  = @parser.column
    end

    def build_arithmetic_expr(token, left, right)
      node = ArithmeticExpression.new(token, left, right)
      hook(node)
      return node
    end

    def build_logical_expr(token, left, right)
      node = LogicalExpression.new(token, left, right)
      hook(node)
      return node
    end

    def build_relational_expr(token, left, right)
      node = RelationalExpression.new(token, left, right)
      hook(node)
      return node
    end

    def build_assignment_expr(token, left, right)
      node = AssignmentExpression.new(token, left, right)
      hook(node)
      return node
    end

    def build_index_expr(token, left, right)
      node = IndexExpression.new(token, left, right)
      hook(node)
      return node
    end

    def build_index2_expr(token, left, keystr)
      node = IndexExpression.new(token, left, StringLiteral.new(keystr))
      hook(node)
      return node
    end

    def build_conditional_expr(condition, left, right)
      node = ConditionalExpression.new(condition, left, right)
      hook(node)
      return node
    end

    def build_funcall_expr(funcname, arguments)
      node = FuncallExpression.new(funcname, arguments)
      hook(node)
      return node
    end

    def build_method_expr(receiver, methodname, arguments)
      node = MethodExpression.new(receiver, methodname, arguments)
      hook(node)
      return node
    end

    def build_property_expr(receiver, propname)
      node = PropertyExpression.new(receiver, propname)
      hook(node)
      return node
    end


    ####

    def build_variable_literal(varname)
      node = VariableLiteral.new(varname)
      hook(node)
      return node
    end

    def build_string_literal(value)
      node = StringLiteral.new(value)
      hook(node)
      return node
    end

    def build_integer_literal(value)
      node = IntegerLiteral.new(value)
      hook(node)
      return node
    end

    def build_float_literal(value)
      node = FloatLiteral.new(value)
      hook(node)
      return node
    end

    def build_true_literal(value=true)
      node = TrueLiteral.new(value)
      hook(node)
      return node
    end

    def build_false_literal(value=false)
      node = FalseLiteral.new(value)
      hook(node)
      return node
    end

    def build_null_literal(value=nil)
      node = NullLiteral.new(value)
      hook(node)
      return node
    end

    ####

    def build_expression_stmt(expr)
      node = ExpressionStatement.new(expr)
      hook(node)
      return node
    end

    def build_print_stmt(arguments)
      node = PrintStatement.new(arguments)
      hook(node)
      return node
    end

    def build_if_stmt(condition, then_stmt, else_stmt)
      node = IfStatement.new(condition, then_stmt, else_stmt)
      hook(node)
      return node
    end

    def build_while_stmt(condition, body_stmt)
      node = WhileStatement.new(condition, body_stmt)
      hook(node)
      return node
    end

    def build_foreach_stmt(loopvar, list_expr, body_stmt)
      node = ForeachStatement.new(loopvar, list_expr, body_stmt)
      hook(node)
      return node
    end

    def build_block_stmt(statements)
      node = BlockStatement.new(statements)
      hook(node)
      return node
    end

    def build_break_stmt()
      node = BreakStatement.new()
      hook(node)
      return node
    end

    def build_continue_stmt()
      node = ContinueStatement.new()
      hook(node)
      return node
    end

    def build_native_stmt(native_code)
      node = NativeStatement.new(native_code)
      hook(node)
      return node
    end

    ###

    def build_stag_stmt()
      node = StagStatement.new()
      hook(node)
      return node
    end

    def build_etag_stmt()
      node = EtagStatement.new()
      hook(node)
      return node
    end

    def build_cont_stmt()
      node = ContStatement.new()
      hook(node)
      return node
    end

    def build_elem_stmt()
      node = ElemStatement.new()
      hook(node)
      return node
    end

    def build_element_stmt(name)
      node = ElementStatement.new(name)
      hook(node)
      return node
    end

    def build_content_stmt(name)
      node = ContentStatement.new(name)
      hook(node)
      return node
    end

    ###

    def build_ruleset(selectors, declarations)
      node = Ruleset.new(selectors, declarations)
      hook(node)
      return node
    end

    ###

    def wrap(funcname, arg, kind=nil)
      if kind.nil?
        arg = FuncallExpression.new(funcname, [arg])
      elsif kind == :list
        assert unless arg.is_a?(Array)
        arg.collect! {|expr| wrap(funcname, expr) }
      elsif kind == :pairs
        assert unless arg.is_a?(Array)
        arg.each {|pair| pair[1] = wrap(funcname, pair[1]) }
      else
        unreachable "kind=#{kind.inspect}"
      end
      return arg
    end

  end


end
