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

   class JstlTranslator < BaseTranslator

      @@keywords = {

        ## statement prefix and postfist
        :prefix     => '',         ## statement prefix
        :postfix    => '',         ## statement postfix

        ## if-statement
        :if         => '<c:choose><c:when test="${',
        :then       => '}">',
        :else       => '</c:when><c:otherwise>',
        :elseif     => '</c:when><c:when test="${',
        :endif      => nil,        ## </c:when></c:choose> or </c:otherwise></c:choose>

        ## while-statement
        :while      => nil,
        :dowhile    => nil,
        :endwhile   => nil,

        ## foreach-statement
        :foreach    => '<c:forEach var="',
        :in         => '" items="${',
        :doforeach  => '}">',
        :endforeach => '</c:forEach>',

        ## expression-statement
        :expr       => nil,
        :endexpr    => nil,

        ## print-statement
        ##
        ## note: ':print' statement doesn't print prefix and suffix,
        ## so you should include prefix and suffix in ':print'/':endprint' keywords
        :print      => '<c:out value="${',
        :endprint   => '}" escapeXml="false"/>',
        :eprint     => '<c:out value="${',
        :endeprint  => '}"/>',

        ## literal
        :true        => 'true',
        :false       => 'false',
        :null        => 'null',

        ## :empty and :notempty
        :empty       => 'empty ',
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
        '='    => nil,
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
        '<'    => ' lt ',
        '<='   => ' le ',
        '>'    => ' gt ',
        '>='   => ' ge ',
        '=='   => ' eq ',
        '!='   => ' ne ',

        ## logical op
        '&&'   => ' and ',
        '||'   => ' or ',
        '!'    => 'not ',

        ## array & hash op
        '['    => '[',
        ']'    => ']',
        '[:'   => "['",		# or '.'
        ':]'   => "']",		# or ''

        ## property op
        '.'    => '.',

        ## method op
        '.()'  => nil,

        ## other op
        '('    => '(',
        ')'    => ')',
        '?'    => ' ? ',
        ':'    => ' : ',
        ','    => ', ',

        ## escape function
        #'E('   => 'CGI::escapeHTML((',
        #'E)'   => ').to_s)',
      }


      def keyword(key)
         Kwartz::assert("key=#{key.inspect}") unless @@keywords.key?(key)
         return @@keywords[key]
      end


      @@func_names = {
         'list_new'    => nil,
         'list_length' => 'fn:length',
         'list_empty'  => nil,
         'hash_new'    => nil,
         'hash_keys'   => nil,
         'hash_empty'  => nil,
         'str_length'  => 'fn:length',
         'str_trim'    => 'fn:trim',
         'str_tolower' => 'fn:toLowerCase',
         'str_toupper' => 'fn:toUpperCase',
         'str_index'   => 'fn:indexOf',
         'str_empty'   => nil,
      }


      ## should be abstract
      def function_name(name)
         return @@func_names[name]
      end


      ##
      def visit_funtion_expression(expr, depth=0)
         case expr.funcname
         when 'list_empty', 'hash_empty', 'str_empty'
            @code << 'fn:length('
            translate_expression(expr.arguments[0])
            @code << ')==0'
         else
            funcname = function_name(expr.funcname)
            if funcname
               return super(expr, depth)
            else
               raise TranslationError.new("#{expr.funcname}: No corresponding method.")
            end
         end
         return @code
      end

      ##
      def visit_method_expression(expr, depth=0)
         raise TranslationError.new("#{expr.method_name}(): JSTL doesn't support method-call.")
      end


      ##
      def visit_empty_expression(expr, depth=0)
         if expr.token == :notempty
            @code << keyword('!')
         end
         @code << keyword(:empty)
         translate_expression(expr.child)
      end


      ##
      def visit_string_expression(expr, depth=0)
         @code << Kwartz::Util.quote_str(expr.value)
      end


      ##
      def visit_if_statement(stmt, depth)

         if ! stmt.else_stmt

            @code << indent(depth)
            @code << '<c:if test="${'
            translate_expression(stmt.condition)
            @code << '}">'     << @nl
            translate_statement(stmt.then_stmt, depth+1)
            @code << '</c:if>' << @nl

         else

            @code << indent(depth)
            @code << keyword(:if)
            translate_expression(stmt.condition)
            @code << keyword(:then) << @nl
            translate_statement(stmt.then_stmt, depth+1)
            st = stmt
            while (st = st.else_stmt) != nil && st.token == :if
               @code << indent(depth)
               @code << keyword(:elseif)
               translate_expression(st.condition)
               @code << keyword(:then) << @nl
               translate_statement(st.then_stmt, depth+1)
            end
            if st != nil
               @code << indent(depth)
               @code << keyword(:else) << @nl
               translate_statement(st, depth+1)
               @code << indent(depth)
               @code << '</c:otherwise></c:choose>' << @nl
            else
               @code << indent(depth)
               @code << '</c:when></c:choose>' << @nl
            end

         end

      end


      ##
      def visit_while_statement(stmt, depth)
         raise TranslationError.new("JSTL doesn't support 'while' statement.")
      end


      ##
      def visit_expr_statement(stmt, depth)
         expr = stmt.expression
         t = expr.token
         case expr.token
         when '=', '+=', '-=', '*=', '/=', '%=', '.+='
            # ok
         else
            raise TranslationError.new("cannot translate non-assignment statement into JSTL.")
         end
         expr2 = normalize_assign_expr(expr)
         expr = expr2 if expr2
         @code << indent(depth) << '<c:set var="'
         case expr.left.token
         when :variable
            translate_expression(expr.left)
         when '[:]'
            translate_expression(expr.left.left)
            @code << '" property="' << expr.left.right.value.to_s
         when '[]'
            if expr.left.right.token != :string
               raise TranslationError.new("assingment into an array or an hash is not supported in JSTL.")
            end
            translate_expression(expr.left.left)
            @code << '" property="' << expr.left.right.value
         when '.'
            Kwartz::assert("expr.left.class.name = #{expr.left.class.name}") unless expr.left.is_a?(PropertyExpression)
            prop_expr = expr.left
            translate_expression(prop_expr.object)
            @code << '" property="' << prop_expr.propname
         else
            Kwartz::assert("expr.left.token == #{expr.left.token.to_s}")
         end
         rhs_token = expr.right.token
         if rhs_token == :numeric || rhs_token == :string
            @code << '" value="'
            @code << expr.right.value.to_s
            @code << '"/>' << @nl
         elsif (rhs_token == '-.' || rhs_token == '+.') && expr.right.child.token == :numeric
            @code << '" value="'
            translate_expression(expr.right)
            @code << '"/>' << @nl
         else
            @code << '" value="${'
            translate_expression(expr.right)
            @code << '}"/>' << @nl
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

   end


   class Jstl11Translator < JstlTranslator

      def self.lang
         return 'jstl11'
      end

      Translator.register('jstl11', self)
      Translator.register('jstl', self)

      def initialize(properties={})
         super(properties)
      end

      def visit_binary_expression(expr, depth=0)
         if expr.token == '.+'
            @code << 'fn:join('
            translate_expression(expr.left)
            @code << ','
            translate_expression(expr.right)
            @code << ')'
         else
            return super(expr, depth)
         end
         return @code
      end

   end


   class Jstl10Translator < JstlTranslator

      def self.lang
         return 'jstl10'
      end

      Translator.register('jstl10', self)

      def initialize(properties={})
         super(properties)
         @condfind_visitor = ConditionalExpressionFindVisitor.new
         @deepcopy_visitor = ConditionalDeepCopyVisitor.new
      end

      def visit_binary_expression(expr, depth=0)
         if expr.token == '.+'
            translate_expression(expr.left)
            @code << '}${'
            translate_expression(expr.right)
         else
            super(expr, depth)
         end
         return @code
      end

      def visit_function_expression(expr, depth=0)
         raise TranslationError.new("'#{expr.funcname}()': JSTL1.0 doesn't support function call.")
      end

      def visit_block_statement(block_stmt, depth)
         block_stmt.statements.each_with_index do |stmt, i|
            stmt2 = expand_conditional_expr(stmt)
            translate_statement(stmt2, depth)
         end
         return @code
      end

      def visit_statement(stmt, depth)
         if stmt.token == :block
            visit_block_statement(stmt, depth)
         else
            stmt2 = expand_conditional_expr(stmt)
            translate_statement(stmt2, depth)
         end
         return @code
      end

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
   translator = Kwartz::Translator.create('jstl10', properties)
   code = translator.translate(block_stmt)
   print code
end
