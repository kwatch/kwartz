require 'abstract'
require 'parser'


module Kwartz


  class SemanticError < ParseError
  end


  class Node

    def initialize(token, linenum, column)
      @token = token
      @linenum = linenum
      @column = column
    end
    attr_accessor :token
    attr_accessor :parent
    attr_accessor :linenum, :column, :filename


    def available_as_lhs?
      return false
    end


    def _error(message, linenum, column)
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

    def initialize(token, left, right, linenum, column)
      super(token, linenum, column)
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

    def initialize(token, left, right, linenum, column)
      super(token, left, right, linenum, column)
      unless left.available_as_lhs?
        raise _error("#{@token}: invalid left-side value.", linenum, column)
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

    def initialize(condition, left, right, linenum, column)
      super(:'?:', linenum, column)
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

    def initialize(funcname, arguments, linenum, column)
      super(:'()', linenum, column)
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

    def initialize(receiver, methodname, arguments, linenum, column)
      super(:'.()', linenum, column)
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

    def initialize(receiver_expr, property_name, linenum, column)
      super(:'.', linenum, column)
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

    def initialize(token, value, linenum, column)
      super(token, linenum, column)
      @value = value
    end
    attr_accessor :value

    def _inspect(level=0, buf='')
      _inspect_value(level, buf, @value.inspect)
      return buf
    end

  end


  class VariableLiteral < Literal
    def initialize(varname, linenum, column)
      super(:VARIABLE, varname, linenum, column)
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
    def initialize(value, linenum, column)
      super(:STRING, value, linenum, column)
    end
  end


  class NumberLiteral < Literal
    # abstract
  end


  class IntegerLiteral < Literal
    def initialize(value, linenum, column)
      super(:INTEGER, value, linenum, column)
    end
  end


  class FloatLiteral < Literal
    def initialize(value, linenum, column)
      super(:INTEGER, value, linenum, column)
    end
  end


  class BooleanLiteral < Literal
    # abstract
  end


  class TrueLiteral < Literal
    def initialize(value, linenum, column)
      super(:TRUE, value, linenum, column)
    end
  end


  class FalseLiteral < Literal
    def initialize(value, linenum, column)
      super(:FALSE, value, linenum, column)
    end
  end


  class NullLiteral < Literal
    def initialize(value, linenum, column)
      super(:NULL, value, linenum, column)
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

    def initialize(expression, linenum, column)
      super(:EXPR, linenum, column)
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

    def initialize(arguments, linenum, column)
      super(:PRINT, linenum, column)
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

    def initialize(condition, then_stmt, else_stmt, linenum, column)
      super(:IF, linenum, column)
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

    def initialize(condition_expr, body, linenum, column)
      super(:WHILE, linenum, column)
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

    def initialize(loopvar_expr, list_expr, body, linenum, column)
      super(:FOREACH, linenum, column)
      @loopvar = loopvar_expr
      @list = list_expr
      @body = body
      unless @loopvar.token == :VARIABLE
        raise _error("#{@loopvar.token}: invalid loop-variable of foreach statement.", @loopvar.linenum, @loopvar.column)
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

    def initialize(statements, linenum, column)
      super(:BLOCK, linenum, column)
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

    def initialize(linenum, column)
      super(:BREAK, linenum, column)
    end

    def _inspect(level=0, buf='')
      _inspect_token(level, buf)
    end

  end



  class ContinueStatement < Statement

    def initialize(linenum, column)
      super(:CONTINUE, linenum, column)
    end

    def _inspect(level=0, buf='')
      _inspect_token(level, buf)
    end

  end



  class NativeStatement < Statement

    def initialize(native_code, linenum, column)
      super(:NATIVE, linenum, column)
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

    def initialize(linenum, column)
      super(:STAG, linenum, column)
    end

    def _inspect(level=0, buf='')
      #_inspect_token(level, buf)
      _inspect_value(level, buf, '_stag')
      return buf
    end

  end


  class EtagStatement < TagStatement

    def initialize(linenum, column)
      super(:ETAG, linenum, column)
    end

    def _inspect(level=0, buf='')
      #_inspect_token(level, buf)
      _inspect_value(level, buf, '_etag')
      return buf
    end

  end


  class ContStatement < TagStatement

    def initialize(linenum, column)
      super(:CONT, linenum, column)
    end

    def _inspect(level=0, buf='')
      #_inspect_token(level, buf)
      _inspect_value(level, buf, '_cont')
      return buf
    end

  end


  class ElemStatement < TagStatement

    def initialize(linenum, column)
      super(:ELEM, linenum, column)
    end

    def _inspect(level=0, buf='')
      #_inspect_token(level, buf)
      _inspect_value(level, buf, '_elem')
      return buf
    end

  end


  class ElementStatement < TagStatement

    def initialize(name, linenum, column)
      super(:ELEMENT, linenum, column)
      @name = name
    end

    def _inspect(level=0, buf='')
      #_inspect_token(level, buf)
      _inspect_value(level, buf, "_element(#{@name})")
      return buf
    end

  end


  class ContentStatement < TagStatement

    def initialize(name, linenum, column)
      super(:CONTENT, linenum, column)
      @name = name
    end

    def _inspect(level=0, buf='')
      #_inspect_token(level, buf)
      _inspect_value(level, buf, "_content(#{@name})")
      return buf
    end

  end



  ##########


  class Declaration < Node

    def initialize(token, propname, argument, linenum, column)
      super(token, linenum, column)
      @propname = propname
      @argument = argument
    end
    attr_accessor :propname, :argument

    def _inspect(level=0, buf='')
      case @token
      when :P_APPEND
        _inspect_value(level, buf, @propname+':')
        @argument.each do |expr| expr._inspect(level+1, buf) end
      when :P_ATTRS
        _inspect_value(level, buf, @propname+':')
        hash = @argument
        hash.keys.sort.each do |name|
          expr = hash[name]
          _inspect_value(level+1, buf, "- '#{name}'")
          expr._inspect(level+2, buf)
        end
      when :P_LOGIC
        _inspect_value(level, buf, @propname+': {')
        @argument.each do |stmt| stmt._inspect(level+1, buf) end
        _inspect_value(level, buf, '}')
      when :P_REMOVE
        _inspect_value(level, buf, @propname+':')
        @argument.each do |name|
          _inspect_value(level+1, buf, "- '#{name}'")
        end
      when :P_TAGNAME
        _inspect_value(level, buf, @propname+": '#{@argument}'")
      else
        _inspect_value(level, buf, @propname+':')
        @argument._inspect(level+1, buf)
      end
      return buf
    end

  end


  class Selector < Node

    def initialize(value, linenum, column)
      super(:SELECTOR, linenum, column)
      @value = value
    end
    attr_reader :value

  end


  class Ruleset < Node

    def initialize(selectors, declarations, linenum, column)
      super(:RULESET, linenum, column)
      @selectors = selectors         # list
      @declarations = declarations   # hash of Declaration
    end
    attr_reader :selectors, :declarations

    def _inspect(level=0, buf='')
      buf << @selectors.collect{|sel| sel.value}.join(', ') << " {\n"
      keys = [:stag, :cont, :etag, :elem, :value, :attrs,
              :append, :remove, :tagname, :logic, :begin, :end]
      keys.each do |key|
        decl = @declarations[key]
        decl._inspect(level+1, buf) if decl
      end
      buf << "}\n"
      return buf
    end

  end


  ##########


  class NodeBuilder

    def hook(node)
    end

    def build_arithmetic_expr(tuple, left, right)
      #token_id, token_val, start_linenum, start_column, end_linenum, end_column = tuple
      node = ArithmeticExpression.new(tuple[0].intern, left, right, tuple[2], tuple[3])
      hook(node)
      return node
    end

    def build_unary_expr(tuple, left, right)  # unary '-' or '+' operator
      #token_id, token_val, start_linenum, start_column, end_linenum, end_column = tuple
      node = ArithmeticExpression.new((tuple[0]+'.').intern, left, nil, tuple[2], tuple[3])
      hook(node)
      return node
    end

    def build_logical_expr(tuple, left, right)
      #token_id, token_val, start_linenum, start_column, end_linenum, end_column = tuple
      node = LogicalExpression.new(tuple[0].intern, left, right, tuple[2], tuple[3])
      hook(node)
      return node
    end

    def build_relational_expr(tuple, left, right)
      #token_id, token_val, start_linenum, start_column, end_linenum, end_column = tuple
      node = RelationalExpression.new(tuple[0].intern, left, right, tuple[2], tuple[3])
      hook(node)
      return node
    end

    def build_assignment_expr(tuple, left, right)
      #token_id, token_val, start_linenum, start_column, end_linenum, end_column = tuple
      node = AssignmentExpression.new(tuple[0].intern, left, right, tuple[2], tuple[3])
      hook(node)
      return node
    end

    def build_index_expr(tuple, left, right)
      #token_id, token_val, start_linenum, start_column, end_linenum, end_column = tuple
      node = IndexExpression.new(:'[]', left, right, tuple[2], tuple[3])
      hook(node)
      return node
    end

    def build_index2_expr(tuple, left, right)
      #token_id, token_val, start_linenum, start_column, end_linenum, end_column = tuple
      node = IndexExpression.new(:'[:]', left, right, tuple[2], tuple[3])
      hook(node)
      return node
    end

    def build_conditional_expr(tuple, condition, left, right)
      #token_id, token_val, start_linenum, start_column, end_linenum, end_column = tuple
      node = ConditionalExpression.new(condition, left, right, tuple[2], tuple[3])
      hook(node)
      return node
    end

    def build_funcall_expr(tuple, arguments)
      #token_id, token_val, start_linenum, start_column, end_linenum, end_column = tuple
      funcname = tuple[1]
      node = FuncallExpression.new(funcname, arguments, tuple[2], tuple[3])
      hook(node)
      return node
    end

    def build_method_expr(tuple, receiver, methodname, arguments)
      #token_id, token_val, start_linenum, start_column, end_linenum, end_column = tuple
      node = MethodExpression.new(receiver, methodname, arguments, tuple[2], tuple[3])
      hook(node)
      return node
    end

    def build_property_expr(tuple, receiver, propname)
      #token_id, token_val, start_linenum, start_column, end_linenum, end_column = tuple
      node = PropertyExpression.new(receiver, propname, tuple[2], tuple[3])
      hook(node)
      return node
    end

    ####

    def build_variable_literal(tuple)
      #token_id, token_val, start_linenum, start_column, end_linenum, end_column = tuple
      varname = tuple[1]
      node = VariableLiteral.new(varname, tuple[2], tuple[3])
      hook(node)
      return node
    end

    def build_string_literal(tuple)
      #token_id, token_val, start_linenum, start_column, end_linenum, end_column = tuple
      strval = tuple[1]
      node = StringLiteral.new(strval, tuple[2], tuple[3])
      hook(node)
      return node
    end

    def build_integer_literal(tuple)
      #token_id, token_val, start_linenum, start_column, end_linenum, end_column = tuple
      intval = tuple[1].to_i
      node = IntegerLiteral.new(intval, tuple[2], tuple[3])
      hook(node)
      return node
    end

    def build_float_literal(tuple)
      #token_id, token_val, start_linenum, start_column, end_linenum, end_column = tuple
      floatval = tuple[1].to_f
      node = FloatLiteral.new(floatval, tuple[2], tuple[3])
      hook(node)
      return node
    end

    def build_true_literal(tuple)
      #token_id, token_val, start_linenum, start_column, end_linenum, end_column = tuple
      node = TrueLiteral.new(true, tuple[2], tuple[3])
      hook(node)
      return node
    end

    def build_false_literal(tuple)
      #token_id, token_val, start_linenum, start_column, end_linenum, end_column = tuple
      node = FalseLiteral.new(false, tuple[2], tuple[3])
      hook(node)
      return node
    end

    def build_null_literal(tuple)
      #token_id, token_val, start_linenum, start_column, end_linenum, end_column = tuple
      node = NullLiteral.new(nil, tuple[2], tuple[3])
      hook(node)
      return node
    end

    ####

    def build_expression_stmt(tuple, expr)
      node = ExpressionStatement.new(expr, tuple[2], tuple[3])
      hook(node)
      return node
    end

    def build_print_stmt(tuple, arguments)
      node = PrintStatement.new(arguments, tuple[2], tuple[3])
      hook(node)
      return node
    end

    def build_if_stmt(tuple, condition, then_stmt, else_stmt)
      node = IfStatement.new(condition, then_stmt, else_stmt, tuple[2], tuple[3])
      hook(node)
      return node
    end

    def build_while_stmt(tuple, condition, body_stmt)
      node = WhileStatement.new(condition, body_stmt, tuple[2], tuple[3])
      hook(node)
      return node
    end

    def build_foreach_stmt(tuple, loopvar, list_expr, body_stmt)
      node = ForeachStatement.new(loopvar, list_expr, body_stmt, tuple[2], tuple[3])
      hook(node)
      return node
    end

    def build_block_stmt(tuple, statements)
      node = BlockStatement.new(statements, tuple[2], tuple[3])
      hook(node)
      return node
    end

    def build_break_stmt(tuple)
      node = BreakStatement.new(tuple[2], tuple[3])
      hook(node)
      return node
    end

    def build_continue_stmt(tuple)
      node = ContinueStatement.new(tuple[2], tuple[3])
      hook(node)
      return node
    end

    def build_native_stmt(tuple, native_code)
      node = NativeStatement.new(native_code, tuple[2], tuple[3])
      hook(node)
      return node
    end

    ###

    def build_stag_stmt(tuple)
      node = StagStatement.new(tuple[2], tuple[3])
      hook(node)
      return node
    end

    def build_etag_stmt(tuple)
      node = EtagStatement.new(tuple[2], tuple[3])
      hook(node)
      return node
    end

    def build_cont_stmt(tuple)
      node = ContStatement.new(tuple[2], tuple[3])
      hook(node)
      return node
    end

    def build_elem_stmt(tuple)
      node = ElemStatement.new(tuple[2], tuple[3])
      hook(node)
      return node
    end

    def build_element_stmt(tuple, name)
      node = ElementStatement.new(name, tuple[2], tuple[3])
      hook(node)
      return node
    end

    def build_content_stmt(tuple, name)
      node = ContentStatement.new(name, tuple[2], tuple[3])
      hook(node)
      return node
    end

    ###

    @@escape_flag_table = hash = {}
    %w[stag cont etag elem value attrs append].each do |w|
      hash[w]            = nil     # default (according to config file)
      hash[w.capitalize] = true    # escape
      hash[w.upcase]     = false   # not escape
    end

    def build_declaration(tuple, arg)
      token_id, propname, linenum, column = tuple
      flag_escape = @@escape_flag_table[propname]
      arg = wrap(flag_escape ? 'E' : 'X', arg) unless flag_escape.nil?
      node = Declaration.new(token_id, propname, arg, linenum, column)
      hook(node)
      return node
    end

    def build_selector(tuple)
      token_id, token_val, linenum, column = tuple
      node = Selector.new(token_val, linenum, column)
      hook(node)
      return node
    end

    def build_ruleset(tuple, selectors, declarations)
      decl_table = {}
      declarations.each do |decl|
        key = decl.token.to_s[2..-1].downcase   # :P_VALUE => "value"
        decl_table[key.intern] = decl
      end
      sel = selectors.first
      node = Ruleset.new(selectors, decl_table, sel.linenum, sel.column)
      #node = Ruleset.new(selectors, decl_table, tuple[2], tuple[3])
      hook(node)
      return node
    end

    ###

    def wrap(funcname, arg)
      if arg.is_a?(Array)
        arg.collect! {|expr| wrap(funcname, expr) }
      elsif arg.is_a?(Hash)
        arg.each {|name, expr| arg[name] = wrap(funcname, expr) }
      else
        arg = FuncallExpression.new(funcname, [arg], arg.linenum, arg.column)
      end
      return arg
    end

  end


end
