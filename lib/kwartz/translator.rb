###
### copyright(c) 2005 kuwata-lab all rights reserved
###
### $Id$
### $Release$
###

require 'kwartz/config'
require 'kwartz/exception'
require 'kwartz/node'
require 'kwartz/visitor'

module Kwartz

   class TranslationError < BaseError
   end

   ## abstract class
   class Translator

      def translate_expression(expr, depth=0)
         raise NotImplementedError.new("#{self.class.name}#translate_expression() is not implemented.")
      end
      def translate_statement(stmt, depth=0)
         raise NotImplementedError.new("#{self.class.name}#translate_statement() is not implemented.")
      end
      def translate(node, depth=0)
         raise NotImplementedError.new("#{self.class.name}#translate() is not implemented.")
      end

      @@subclasses = {}
      def self.register(lang, klass)
         @@subclasses[lang] = klass
      end

      def self.translator_class(lang)
         return @@subclasses[lang]
      end

      def self.create(lang, properties)
         klass = @@subclasses[lang]
         unless klass
            raise TranslationError.new("lang '#{lang}' is not registered.")
         end
         return klass.new(properties)
      end

   end


   ## abstract class
   class BaseTranslator < Translator
      include Visitor

      def initialize(properties={})
         @properties = properties
         if !@properties.key?(:escape)
            @properties[:escape] = Kwartz::Config::ESCAPE
         end
         #
         @default_flag_escape = properties[:escape] ? true : false
         #
         @localvar_prefix  = properties[:localvar_prefix]  || Kwartz::Config::LOCALVAR_PREFIX
         @globalvar_prefix = properties[:globalvar_prefix] || Kwartz::Config::GLOBALVAR_PREFIX
         @local_vars = []
         @global_vars = []
         #
         @nl     = properties[:newline] || Kwartz::Config::NEWLINE     # "\n"
         @indent = properties[:indent]  || Kwartz::Config::INDENT      # '  '
         @code   = ''
      end
      attr_accessor :local_vars, :global_vars

      def rename?
         return @localvar_prefix != nil || @globalvar_prefix != nil
      end

      def indent(depth)
         @indent * depth
      end

      def prefix(depth)
         return @code[-1] == ?\n ? keyword(:prefix) + indent(depth) : keyword(:prefix)
      end

      def postfix(flag_add_newline=true)
         return flag_add_newline ? keyword(:postfix) + @nl : keyword(:postfix)
      end
      
      def append_code(code_str)
         @code << code_str
      end


      ## abstract method
      def keyword(key)
         raise Kwartz::NotImplementedError.new("#{self.class.name}#keyword(): not implemented.")
      end


      @@priorities = {
        :variable  => 100,
        :numeric   => 100,
        :boolean   => 100,
        :string    => 100,
        :null      => 100,
        :rawexpr   => 100,
        :function  => 100,
        :property  => 100,

        '[]'       =>  90,
        '{}'       =>  90,
        '[:]'      =>  90,
        '.'        =>  90,
        '.()'      =>  90,

        '-.'       =>  80,
        '+.'       =>  80,
        '!'        =>  80,
        :empty     =>  80,
        :notempty  =>  80,

        '*'        =>  70,
        '/'        =>  70,
        '%'        =>  70,
        '^'        =>  70,

        '+'        =>  60,
        '-'        =>  60,
        '.+'       =>  60,

        '=='       =>  50,
        '!='       =>  50,
        '<'        =>  50,
        '<='       =>  50,
        '>'        =>  50,
        '>='       =>  50,

        '&&'       =>  40,

        '||'       =>  30,

        '?:'       =>  20,

        '='        =>  10,
        '+='       =>  10,
        '-='       =>  10,
        '*='       =>  10,
        '/='       =>  10,
        '%='       =>  10,
        '^='       =>  10,
        '.+='      =>  10,
      }

      ## --------------------

      ##
      def translate(node, depth=0)
         return node.accept(self, depth)
      end

      ##
      def translate_expression(expr, depth=0)
         return expr.accept(self, depth)
      end

      ##
      def translate_statement(stmt, depth)
         return stmt.accept(self, depth)
      end

      ## --------------------

      ##
      def _translate_expr(expr, parent_token)
         if @@priorities[parent_token] > @@priorities[expr.token]
            @code << keyword('(')
            translate_expression(expr)
            @code << keyword(')')
         else
            translate_expression(expr)
         end
         return @code
      end

      ##
      def visit_unary_expression(expr, depth=0)
         t = expr.token
         op = keyword(t)
         @code << op
         _translate_expr(expr.child, t)
         return @code
      end

      ##
      def visit_empty_expression(expr, depth=0)
         t = expr.token
         child = expr.child
         if t == :empty
            left  = BinaryExpression.new('==', child, NullExpression.new())
            right = BinaryExpression.new('==', child, StringExpression.new(""))
            expr  = BinaryExpression.new('||', left, right)
         elsif t == :notempty
            left  = BinaryExpression.new('!=', child, NullExpression.new())
            right = BinaryExpression.new('!=', child, StringExpression.new(""))
            expr  = BinaryExpression.new('&&', left, right)
         end
         translate_expression(expr)
         return @code
      end

      ##
      def visit_binary_expression(expr, depth=0)
         t = expr.token
         _translate_expr(expr.left, t)
         op = keyword(t)
         Kwartz::assert("*** t = #{t.inspect}") unless op
         @code << op
         _translate_expr(expr.right, t)
         return @code
      end

      ##
      def visit_arithmetic_expression(expr, depth=0)
         return visit_binary_expression(expr, depth)
      end

      ##
      def visit_assignment_expression(expr, depth=0)
         return visit_binary_expression(expr, depth)
      end

      ##
      def visit_relational_expression(expr, depth=0)
         return visit_binary_expression(expr, depth)
      end

      ##
      def visit_logical_expression(expr, depth=0)
         return visit_binary_expression(expr, depth)
      end

      ##
      def visit_index_expression(expr, depth=0)
         t = expr.token
         case t
         when '[]'
            _translate_expr(expr.left, t)
            @code << keyword('[')
            translate_expression(expr.right)
            @code << keyword(']')
         when '[:]'
            _translate_expr(expr.left, t)
            @code << keyword('[:')
            @code << expr.right.value
            @code << keyword(':]')
         end
         return @code
      end


      ##
      def visit_property_expression(expr, depth=0)
         t = expr.token
         _translate_expr(expr.object, t)
         op = keyword(t)
         @code << op
         @code << expr.propname
         return @code
      end

      ##
      def visit_method_expression(expr, depth=0)
         t = expr.token
         _translate_expr(expr.receiver, t)
         op = keyword(t)
         @code << op
         @code << expr.method_name
         @code << keyword('(')
         expr.arguments.each_with_index do |arg, i|
            @code << keyword(',') if i > 0
            translate_expression(arg)
         end
         @code << keyword(')')
         return @code
      end

      ##
      def translate_function(function_name, argument_expressions)
         append_code(function_name)
         append_code('(')
         argument_expressions.each_with_index do |arg_expr, i|
            append_code(keyword(',')) if i > 0
            translate_expression(arg_expr)
         end
         append_code(')')
      end

      ##
      def visit_funtion_expression(expr, depth=0)
         translate_function(expr.funcname, expr.arguments)
         return @code
      end

      ##
      def visit_conditional_expression(expr, depth=0)
         t = expr.token
         _translate_expr(expr.condition, t)
         @code << keyword('?')
         _translate_expr(expr.left, t)
         @code << keyword(':')
         _translate_expr(expr.right, t)
         return @code
      end

      ##
      def visit_variable_expression(expr, depth=0)
         @code << @localvar_prefix  if @localvar_prefix  && @local_vars.include?(expr.name)
         @code << @globalvar_prefix if @globalvar_prefix && @global_vars.include?(expr.name)
         @code << expr.name
      end

      ##
      def visit_literal_expression(expr, depth=0)
         Kwartz::asset(false)
      end

      ##
      def visit_numeric_expression(expr, depth=0)
         @code << expr.value.to_s
      end

      ##
      def visit_string_expression(expr, depth=0)
         @code << Kwartz::Util.dump_str(expr.value)
      end

      ##
      def visit_boolean_expression(expr, depth=0)
         @code << keyword(expr.value ? :true : :false)
      end

      ##
      def visit_null_expression(expr, depth=0)
         @code << keyword(:null)
      end

      ##
      def visit_rawcode_expression(expr, depth=0)
         @code << expr.rawcode.strip
      end


      ## --------------------

      ##
      def visit_print_statement(stmt, depth)
         stmt.arguments.each do |expr|
            _translate_print_argument(expr)
         end
         return @code
      end

      ##
      def _translate_print_argument(expr, flag_escape=nil)
         t = expr.token
         if t == :string || t == :numeric
            @code << expr.value
            return
         end
         if flag_escape == nil
            if expr.token == :function
               fname = expr.funcname
               if fname == 'E' || fname == 'X'
                  flag_escape = fname == 'E'
                  args = expr.arguments
                  if !args || args.length != 1
                     raise TranslationError.new("function #{fname}() should take only an argument.")
                  end
                  expr = args[0]
               end
            end
            if flag_escape == nil
               flag_escape = constant_expr?(expr) ? false : @default_flag_escape
            end
         end
         Kwartz::assert(false) unless flag_escape != nil
         if expr.token == '.+'
            _translate_print_argument(expr.left)
            _translate_print_argument(expr.right)
         else
            @code << keyword(flag_escape ? :eprint    : :print)
            _translate_expression_for_print(expr, flag_escape)
            @code << keyword(flag_escape ? :endeprint : :endprint)
         end
      end
      protected :_translate_print_argument
      
      def _translate_expression_for_print(expr, flag_escape)
         return translate_expression(expr)
      end
      protected :_translate_expression_for_print

      
      ##
      def visit_expr_statement(stmt, depth)
         @code << prefix(depth)
         @code << keyword(:expr)
         translate_expression(stmt.expression)
         @code << keyword(:endexpr)
         @code << postfix()
      end

      ##
      def visit_if_statement(stmt, depth)
         @code << prefix(depth)
         @code << keyword(:if)
         translate_expression(stmt.condition)
         @code << keyword(:then)
         @code << postfix()
         translate_statement(stmt.then_stmt, depth+1)
         st = stmt
         while (st = st.else_stmt) != nil && st.token == :if
            @code << prefix(depth)
            @code << keyword(:elseif)
            translate_expression(st.condition)
            @code << keyword(:then)
            @code << postfix()
            translate_statement(st.then_stmt, depth+1)
         end
         if st != nil
            @code << prefix(depth)
            @code << keyword(:else)
            @code << postfix()
            translate_statement(st, depth+1)
         end
         @code << prefix(depth)
         @code << keyword(:endif)
         @code << postfix()
         return @code
      end

      ##
      def visit_block_statement(stmt, depth)
         stmt.statements.each do |st|
            translate_statement(st, depth)
         end
         return @code
      end

      ##
      def visit_foreach_statement(stmt, depth)
         @code << prefix(depth)
         @code << keyword(:foreach)
         translate_expression(stmt.loopvar_expr)
         @code << keyword(:in)
         translate_expression(stmt.list_expr)
         @code << keyword(:doforeach)
         @code << postfix()
         translate_statement(stmt.body_stmt, depth+1)
         @code << prefix(depth)
         @code << keyword(:endforeach)
         @code << postfix()
         return @code
      end

      ##
      def visit_while_statement(stmt, depth)
         @code << prefix(depth)
         @code << keyword(:while)
         translate_expression(stmt.condition)
         @code << keyword(:dowhile)
         @code << postfix()
         translate_statement(stmt.body_stmt, depth+1)
         @code << prefix(depth)
         @code << keyword(:endwhile)
         @code << postfix()
         return @code
      end

      ##
      def visit_macro_statement(stmt, depth)
         raise TranslationError.new("invalid statement.")
      end

      ##
      def visit_expand_statement(stmt, depth)
         raise TranslationError.new("invalid statement. (type=#{stmt.type})")
      end

      ##
      def visit_rawcode_statement(stmt, depth)
         @code << keyword(:rawcode) << stmt.rawcode << keyword(:endrawcode) << @nl
         return @code
      end



      ## --------------------

      ## utility function
      def constant_expr?(expr)
         t = expr.token
         case t
         when :string, :numeric, :boolean, :null
            return true
         when '?:'
            if constant_expr?(expr.left)
               return true
            end
            return constant_expr?(expr.right)
         end
         return false
      end


      alias   :visit		 :translate
      alias   :visit_expression	 :translate_expression
      alias   :visit_statement	 :translate_statement

   end  # class Translator

end
