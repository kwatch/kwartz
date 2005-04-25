###
### copyright(c) 2005 kuwata-lab all rights reserved
###
### $Id$
### $Release$
###

require 'kwartz/translator'
require 'kwartz/visitor/deepcopy'
require 'kwartz/visitor/conditional'

module Kwartz

   class VelocityTranslator < BaseTranslator

      def self.lang
         return 'velocity'
      end

      Translator.register('velocity', self)

      def initialize(properties={})
         super(properties)
         @condfind_visitor = ConditionalExpressionFindVisitor.new
         @deepcopy_visitor = ConditionalDeepCopyVisitor.new
      end


      @@keywords = {

        ## statement prefix and postfist
        :prefix     => '',         ## statement prefix
        :postfix    => '',         ## statement postfix

        ## if-statement
        :if         => '#if(',
        :then       => ')',
        :else       => '#else',
        :elseif     => '#elseif(',
        :endif      => '#end',

        ## while-statement
        :while      => nil,
        :dowhile    => nil,
        :endwhile   => nil,

        ## foreach-statement
        :foreach    => '#foreach(',
        :in         => ' in ',
        :doforeach  => ')',
        :endforeach => '#end',

        ## expression-statement
        :expr       => '#set(',
        :endexpr    => ')',

        ## print-statement
        ##
        ## note: ':print' statement doesn't print prefix and suffix,
        ## so you should include prefix and suffix in ':print'/':endprint' keywords
        :print      => '$!{',
        :endprint   => '}',
        :eprint     => '$!esc.html(',
        :endeprint  => ')',

        ## literal
        :true        => 'true',
        :false       => 'false',
        :null        => nil,

        ## :empty and :notempty
        :empty       => nil,
        :notempty    => nil,

        ## for future use
        #:include    => 'include ',
        #:endinclude => '',

        ## arithmetic op
        '+'    => ' + ',
        '-'    => ' - ',
        '*'    => ' * ',
        '/'    => ' / ',
        '%'    => ' % ',
        '.+'   => nil,

        ## assignment op
        '='    => ' = ',
        '+='   => nil,
        '-='   => nil,
        '*='   => nil,
        '/='   => nil,
        '%='   => nil,
        '.+='  => nil,

        ## unary op
        '-.'   => '-',
        '+.'   => '+',

        ## rerational op
        '<'    => ' < ',
        '<='   => ' <= ',
        '>'    => ' > ',
        '>='   => ' >= ',
        '=='   => ' == ',
        '!='   => ' != ',

        ## logical op
        '&&'   => ' && ',
        '||'   => ' || ',
        '!'    => '! ',

        ## array & hash op
        '['    => '[',
        ']'    => ']',
        '[:'   => ".",		# or "['"
        ':]'   => "",		# or "']"

        ## property op
        '.'    => '.',

        ## other op
        '('    => '(',
        ')'    => ')',
        '?'    => ' ? ',
        ':'    => ' : ',
        ','    => ', ',

        ## escape function
        #'E('   => 'esc.html(',
        #'E)'   => ')',
      }


      def keyword(key)
         Kwartz::assert("key=#{key.inspect}") unless @@keywords.key?(key)
         return @@keywords[key]
      end


      @@velocity_func_names = {
         'list_new'      => false,
         'list_length'   => '.size()',
         'list_empty'    => true,
         'hash_new'      => false,
         'hash_length'   => '.size()',
         'hash_empty'    => true,
         'hash_keys'     => '.keySet().toArray()',
         'str_length'    => '.length()',
         'str_trim'      => '.trim()',
         'str_tolower'   => '.toLowerCase()',
         'str_toupper'   => '.toUpperCase()',
         'str_index'     => '.indexOf',
         'str_empty'     => true,
         'str_replace'   => '.replaceAll',
         'str_linebreak' => ".replaceAll('$','<br />')",
         'escape_xml'    => '$esc.xml',
         'escape_sql'    => '$esc.sql',
         'escape_url'    => true,
      }


      ##
      def visit_arithmetic_expression(expr, depth=0)
         if expr.token == '.+'
            #translate_expression(expr.left)
            #translate_expression(expr.right)
            raise TranslationError.new("'.+': Veloicty doesn't support concatenation operator.")
         else
            super(expr, depth)
         end
         return @code
      end

      ##
      def translate_function(function_name, arguments)
         funcname = @@velocity_func_names[function_name]
         case function_name
         when 'escape_xml', 'escape_sql'
            append_code(funcname)
            append_code('(')
            translate_expression(arguments[0])
            append_code(')')
         when 'escape_url'
            append_code('$link.setURI(')
            translate_expression(arguments[0])
            append_code(').toString()')
         when 'list_empty', 'hash_empty'
            translate_expression(arguments[0])
            append_code('.size()==0')
         when 'str_empty'
            #append_code('!')
            #translate_expression(arguments[0])
            translate_expression(arguments[0])
            append_code('.length()==0')
         when 'str_index', 'str_replace'
            translate_expression(arguments[0])
            append_code(funcname)
            append_code('(')
            arguments.each_with_index do |arg, i|
               append_code(', ')          if i > 1
               translate_expression(arg) if i > 0
            end
            append_code(')')
         else
            if funcname
               #assert(arguments.length==1)
               translate_expression(arguments[0])
               append_code(funcname)
            else
               msg = "#{function_name}: Veloicty doesn't support the method."
               raise TranslationError.new(msg)
            end
         end
      end


      ##
      def visit_relational_expression(expr, depth=0)
         case expr.token
         when '=='
            if expr.left.token == :null || expr.right.token == :null
               expr2 = expr.left.token == :null ? expr.right : expr.left
               translate_expression(expr2, depth)
            else
               super(expr, depth)
            end
         when '!='
            if expr.left.token == :null || expr.right.token == :null
               expr2 = expr.left.token == :null ? expr.right : expr.left
               expr3 = Kwartz::UnaryExpression.new('!', expr2)
               return translate_expression(expr3, depth)
            else
               super(expr, depth)
            end
         else
            super(expr, depth)
         end
         return @code
      end


      ## expr != empty  =>  expr && expr != ""
      ## expr == empty  =>  !expr || expr == ""
      def visit_empty_expression(expr, depth=0)
         case expr.token
         when :empty
            @code << keyword('!')
            _translate_expr(expr.child, '!')
            @code << keyword('||')
            _translate_expr(expr.child, '==')
            @code << keyword('==')
            @code << '""'
         when :notempty
            _translate_expr(expr.child, '&&')
            @code << keyword('&&')
            _translate_expr(expr.child, '!=')
            @code << keyword('!=')
            @code << '""'
         end
         return @code
      end

      ##
      alias :_visit_variable_expression :visit_variable_expression
      def visit_variable_expression(expr, depth=0)
         #@code << "<*** debug: expr.name=#{expr.name.inspect}>" if defined?($test_compile13_velocity) && $test_compile13_velocity

         @code << '$'
         return super(expr, depth)
      end

      ##
      def visit_null_expression(expr, depth=0)
         raise TranslationError.new("Velocity doesn't support 'null' literal.")
      end

      ##
      def _translate_expression_for_print(expr, flag_escape)
         case expr.token
         when :string, :number, :boolean, :null
            translate_expression(expr)
         when :variable
            @code << '$' if flag_escape
            _visit_variable_expression(expr)
         when '[]'
            _translate_expression_for_print(expr.left, flag_escape)
            @code << keyword('[')
            translate_expression(expr.right)
            @code << keyword(']')
         when '[:]'
            _translate_expression_for_print(expr.left, flag_escape)
            @code << keyword('[:')
            @code << expr.right.value
            @code << keyword(':]')
         when '.'
            _translate_expression_for_print(expr.object, flag_escape)
            @code << keyword('.')
            @code << expr.propname
         when '.()'
            _translate_expression_for_print(expr.receiver, flag_escape)
            @code << keyword('.')
            @code << expr.method_name
            @code << keyword('(')
            expr.arguments.each_with_index do |arg, i|
               @code << keyword(',') if i > 0
               translate_expression(arg)
            end
            @code << keyword(')')
         when :function
            Kwartz::assert("expr.funcname=#{expr.funcname}") if expr.funcname == 'E' || expr.funcname == 'X'
            translate_expression(expr)  # will raise an exception
         else
            raise TranslationError.new("Velocity doesn't support '#{expr.token}' operator for printing.")
         end
      end

      ##
      def visit_expr_statement(stmt, depth)
         expr = stmt.expression
         t = expr.token
         case expr.token
         when '='
            super(stmt, depth)
         when '+=', '-=', '*=', '/=', '%=', '.+='
            expr2 = normalize_assign_expr(expr)
            super(Kwartz::ExprStatement.new(expr2), depth)
         else
            raise TranslationError.new("cannot translate non-assignment statement into Velocity.")
         end
         return @code
      end

      ##
      def visit_while_statement(stmt, depth)
         raise TranslationError.new("Velocity doesn't support 'while' statement.")
      end

      ##
      def visit_block_statement(block_stmt, depth)
         block_stmt.statements.each_with_index do |stmt, i|
            stmt2 = expand_conditional_expr(stmt)
            translate_statement(stmt2, depth)
         end
         return @code
      end

      ##
      def visit_statement(stmt, depth)
         if stmt.token == :block
            visit_block_statement(stmt, depth)
         else
            stmt2 = expand_conditional_expr(stmt)
            translate_statement(stmt2, depth)
         end
         return @code
      end

      ##
      def normalize_assign_expr(expr)
         t = expr.token
         return if t == '='
         op = t == '.+=' ? '.+' : t.sub(/=$/, '')
         lhs_expr = expr.left
         rhs_expr = BinaryExpression.new(op, expr.left, expr.right)
         return BinaryExpression.new('=', lhs_expr, rhs_expr)
      end
      protected :normalize_assign_expr

      def expand_conditional_expr(stmt)
         cond_expr = stmt.accept(@condfind_visitor)
         return stmt if !cond_expr
         visitor = @deepcopy_visitor
         visitor.option = :left
         then_stmt = stmt.accept(visitor)
         visitor.option = :right
         else_stmt = stmt.accept(visitor)
         visitor.option = nil
         return IfStatement.new(cond_expr.condition, then_stmt, expand_conditional_expr(else_stmt))
      end

   end

end


if __FILE__ == $0
   require 'kwartz/parser'
   input = ARGF.read()
   properties = {}
   parser = Kwartz::Parser.new(input, properties)
   block_stmt = parser.parse_program()
   print block_stmt._inspect()
   translator = Kwartz::Translator.create('velocity', properties)
   code = translator.translate(block_stmt)
   print code
end

