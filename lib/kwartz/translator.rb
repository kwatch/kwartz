###
### translator.rb
###
### $Id$
###

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
         #
         if properties[:escape]
            @default_print     = :eprint
            @default_endprint  = :endeprint
         else
            @default_print     = :print
            @default_endprint  = :endprint
         end
         #
         @flag_escape = false
         @nl          = properties[:newline] || "\n"
         @indent      = properties[:indent] || '  '
         @code = ''
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


      ## abstract method
      def keyword(key)
         raise Kwartz::NotImplementedError.new("#{self.class.name}#keyword(): not implemented.")
      end


      ## abstract method
      def function_name(name)
         raise Kwartz::NotImplementedError.new("#{self.class.name}#keyword(): not implemented.")
      end


      @@priorities = {
        :variable  => 100,
        :numeric   => 100,
        :boolean   => 100,
        :string    => 100,
        :null      => 100,
        :function  => 100,
        :property  => 100,

        '[]'       =>  90,
        '{}'       =>  90,
        '[:]'      =>  90,
        '.'        =>  90,

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

        '?:'       =>  20,		## don't use '?'

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
         if t == :empty
            left  = BinaryExpression.new('==',  expr, NullExpression.new())
            right = BinaryExpression.new('==', expr, StringExpression.new(""))
            expr  = BinaryExpression.new('||',  left, right)
         elsif t == :notempty
            left  = BinaryExpression.new('!=',  expr, NullExpression.new())
            right = BinaryExpression.new('!=', expr, StringExpression.new(""))
            expr  = BinaryExpression.new('&&',  left, right)
         end
         translate_expr(expr)
         return @code
      end

      ##
      def visit_binary_expression(expr, depth=0)
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
         else
            _translate_expr(expr.left, t)
            op = keyword(t)
            @code << op
            _translate_expr(expr.right, t)
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
         if expr.arguments
            @code << keyword('(')
            sep = nil
            expr.arguments.each do |arg|
               @code << keyword(sep) if sep
               sep = ','
               translate_expression(arg)
            end
            @code << keyword(')')
         end
         return @code
      end

      ##
      def visit_funtion_expression(expr, depth=0)
         t = expr.token
         funcname = function_name(expr.funcname)
         if !funcname
            funcname = expr.funcname
         end
         @code << funcname << keyword('(')
         expr.arguments.each_with_index do |arg, i|
            @code << keyword(',') if i > 0
            translate_expression(arg)
         end
         @code << keyword(')')
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

      ## --------------------

      ##
      def visit_print_statement(stmt, depth)
         stmt.arguments.each do |expr|
            t = expr.token
            if t == :string || t == :numeric
               @code << expr.value
            else
               startkey = endkey = nil
               if expr.token == :function
                  fname = expr.funcname
                  if fname == 'E' || fname == 'X'
                     if fname == 'E'
                        startkey = :eprint
                        endkey   = :endeprint
                     else
                        startkey = :print
                        endkey   = :endprint
                     end
                     args = expr.arguments
                     if !args || args.length != 1
                        raise TranslationError.new("function #{fname}() should take only an argument.")
                     end
                     expr = args[0]
                  end
               end
               if !startkey
                  if constant_expr?(expr)
                     startkey = :print
                     endkey   = :endprint
                  else
                     startkey = @default_print
                     endkey   = @default_endprint
                  end
               end
               @code << keyword(startkey)
               translate_expression(expr)
               @code << keyword(endkey)
            end
         end
         return @code
      end


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
         @code << indent(depth)
         @code << stmt.rawcode
         @code << @nl unless stmt.rawcode[-1] == ?\n
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


      alias   :visit				:translate
      alias   :visit_expression			:translate_expression
      alias   :visit_statement			:translate_statement

   end

end
