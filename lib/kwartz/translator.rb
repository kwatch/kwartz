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

   class Translator

      def translate_expression(expr)
         raise NotImplementedError.new("#{self.class.name}#translate_expression() is not implemented.")
      end
      def translate_statement(stmt, depth)
         raise NotImplementedError.new("#{self.class.name}#translate_statement() is not implemented.")
      end
      def translate_element(element)
         raise NotImplementedError.new("#{self.class.name}#translate_element() is not implemented.")
      end

      def translate(node)
         raise NotImplementedError.new("#{self.class.name}#translate() is not implemented.")
      end

   end


   class BaseTranslator < Translator
      include Visitor

      def initialize(block_stmt, properties={})
         @block_stmt = block_stmt
         @properties = properties
         #
         if properties[:escape]
            @print_key     = :eprint
            @endprint_key  = :endeprint
         else
            @print_key     = :print
            @endprint_key  = :endprint
         end
         #
         @code = ''
         @flag_escape = false
         @nl = "\n"
         @indent = '  '
      end


      def add_indent(depth)
         @code << @indent * depth
      end

      def indent(depth)
         @indent * depth
      end

      def add_prefix(depth)
         flag = @code[-1] == ?\n
         @code << keyword(:prefix)
         add_indent(depth) if flag
      end

      def prefix(depth)
         return @code[-1] == ?\n ? keyword(:prefix) + indent(depth) : keyword(:prefix)
      end

      def add_postfix(flag_add_newline=true)
         @code << keyword(:postfix)
         @code << @nl if flag_add_newline
      end

      def postfix(flag_add_newline=true)
         return flag_add_newline ? keyword(:postfix) + @nl : keyword(:postfix)
      end


      @@keywords = {

        :prefix     => '<% ',         ## statement prefix
        :postfix    => ' %>',         ## statement postfix

        :if         => 'if ',
        :then       => ' then',
        :else       => 'else',
        :elseif     => 'elsif ',
        :endif      => 'end',

        :while      => 'while ',
        :dowhile    => ' do',
        :endwhile   => 'end',

        :foreach    => 'for ',
        :in         => ' in ',
        :doforeach  => ' do',
        :endforeach => 'end',

        :expr        => '',
        :endexpr     => '',

        ## ':print' statement doesn't print prefix and suffix,
        ## so you should include prefix and suffix in ':print'/':endprint' keywords
        :print      => '<%= ',
        :endprint   => ' %>',
        :eprint     => '<%= CGI::escapeHTML((',
        :endeprint  => ').to_s) %>',

        :include    => 'include ',
        :endinclude => '',

        :true        => 'true',
        :false       => 'false',
        :null        => 'nil',

        '-.'   => '-',
        '.+'   => '+',
        '.+='  => '+=',
        '.'    => '.',
        '['    => '[',
        ']'    => ']',
        '[:'   => '[:',
        ':]'   => ']',
        ','    => ', ',

        'E('   => 'CGI::escapeHTML((',
        'E)'   => ').to_s)',
      }

      ## should be abstract
      def keyword(key)
         return @@keywords[key] || key
      end


      @@func_names = {
        'list_new'    => 'array',
        'list_length' => 'count',
        'list_empty'  => nil,
        'hash_new'    => 'array',
        'hash_keys'   => 'array_keys',
        'hash_empty'  => nil,
        'str_length'  => 'strlen',
        'str_trim'    => 'trim',
        'str_tolower' => 'strtolower',
        'str_toupper' => 'strtoupper',
        'str_index'   => 'strchr',
        'str_empty'   => nil,
      }

      ## should be abstract
      def function_name(name)
         return @@func_names[name]
      end



      @@priorities = {
        :variable  => 100,
        :numeric   => 100,
        :boolean   => 100,
        :string    => 100,
        :null      => 100,

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
      def translate()
         return @block_stmt.accept(self, 0)
      end

      ##
      def translate_expression(expr, depth=0)
         return expr.accept(self, depth)
      end

      def _translate_expr(child_expr, parent_token)
         child_token = child_expr.token
         if @@priorities[parent_token] > @@priorities[child_token]
            @code << '('
            translate_expression(child_expr)
            @code << ')'
         else
            translate_expression(child_expr)
         end
         return @code
      end


      ##
      def visit_unary_expression(expr, depth=0)
         t = expr.token
         @code << keyword(t)
         _translate_expr(expr.child, t)
         return @code
      end

      ##
      def visit_binary_expression(expr, depth=0)
         t = expr.token
         op = keyword(t)
         case op
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
            @code << ' ' << op << ' '
            _translate_expr(expr.right, t)
         end
         return @code
      end

      ##
      def visit_property_expression(expr, depth=0)
         t = expr.token
         op = keyword(t)
         _translate_expr(expr.object, t)
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
         op = keyword(t)
         funcname = function_name(expr.funcname)
         if !funcname
            funcname = expr.funcname
         end
         @code << keyword('(')
         sep = nil
         expr.arguments.each do |arg|
            @code << keyword(sep) if sep
            sep = ','
            translate_expression(arg)
         end
         @code << keyword(')')
         return @code
      end

      ##
      def visit_conditional_expression(expr, depth=0)
         t = expr.token
         op = keyword(t)
         _translate_expr(expr.condition, t)
         @code << ' ' << keyword('?') << ' '
         _translate_expr(expr.left, t)
         @code << ' ' << keyword(':') << ' '
         _translate_expr(expr.right, t)
         return @code
      end

      ##
      def visit_literal_expression(expr, depth=0)
         Kwartz::asset(false)
      end

      ##
      def visit_variable_expression(expr, depth=0)
         @code << expr.name
      end

      ##
      def visit_numeric_expression(expr, depth=0)
         @code << expr.value
      end

      ##
      def visit_string_expression(expr, depth=0)
         @code << Kwartz::Util.dump_str(expr.value)
      end

      ##
      def visit_boolean_expression(expr, depth=0)
         @code << keyword(expr.value)
      end

      ##
      def visit_null_expression(expr, depth=0)
         @code << keyword(:null)
      end

      ## --------------------

      ##
      def translate_statement(stmt, depth)
         return stmt.accept(self, depth)
      end

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
                     startkey = @print_key
                     endkey   = @endprint_key
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
         add_prefix(depth)
         @code << keyword(:expr)
         translate_expression(stmt.expression)
         @code << keyword(:endexpr)
         add_postfix()
      end

      ##
      def visit_if_statement(stmt, depth)
         add_prefix(depth)
         @code << keyword(:if)
         translate_expression(stmt.condition)
         @code << keyword(:then)
         add_postfix()
         translate_statement(stmt.then_stmt, depth+1)
         st = stmt
         while (st = st.else_stmt) != nil && st.token == :if
            add_prefix(depth)
            @code << keyword(:elseif)
            translate_expression(st.condition)
            @code << keyword(:then)
            add_postfix()
            translate_statement(st.then_stmt, depth+1)
         end
         if st != nil
            add_prefix(depth)
            @code << keyword(:else)
            add_postfix()
            translate_statement(st, depth+1)
         end
         add_prefix(depth)
         @code << keyword(:endif)
         add_postfix()
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
         add_prefix(depth)
         @code << keyword(:foreach)
         translate_expression(stmt.loopvar_expr)
         @code << keyword(:in)
         translate_expression(stmt.list_expr)
         @code << keyword(:doforeach)
         add_postfix()
         translate_statement(stmt.body_stmt, depth+1)
         add_prefix(depth)
         @code << keyword(:endforeach)
         add_postfix()
         return @code
      end

      ##
      def visit_while_statement(stmt, depth)
         add_prefix(depth)
         @code << keyword(:while)
         translate_expression(stmt.condition)
         @code << keyword(:dowhile)
         add_postfix()
         translate_statement(stmt.body_stmt, depth+1)
         add_prefix(depth)
         @code << keyword(:endwhile)
         add_postfix
         return @code
      end

      ##
      def visit_macro_statement(stmt, depth)
         raise TranslationError.new("invalid statement.")
      end

      ##
      def visit_expand_statement(stmt, depth)
         raise TranslationError.new("invalid statement.")
      end

      ##
      def visit_rawcode_statement(stmt, depth)
         add_indent(depth)
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


if __FILE__ == $0
   require 'kwartz/parser'
   include Kwartz

   input = ARGF.read()
   properties = {}
   parser = Parser.new(input, properties)
   block = parser.parse()
   print block._inspect()
   translator = BaseTranslator.new(block, {}, properties)
   code = translator.translate()
   print code
end
