###
### copyright(c) 2005 kuwata-lab all rights reserved
###
### $Id$
###

require 'kwartz/translator'

module Kwartz

   class PhpTranslator < BaseTranslator

      def self.lang
         return 'php'
      end

      Translator.register('php', self)

      @@keywords = {

        ## statement prefix and postfist
        :prefix     => '<?php ',         ## statement prefix
        :postfix    => ' ?>',         ## statement postfix

        ## if-statement
        :if         => 'if (',
        :then       => ') {',
        :else       => '} else {',
        :elseif     => '} elseif (',
        :endif      => '}',

        ## while-statement
        :while      => 'while (',
        :dowhile    => ') {',
        :endwhile   => '}',

        ## foreach-statement
        :foreach    => 'foreach (',
        :in         => ' as ',
        :doforeach  => ') {',
        :endforeach => '}',

        ## expression-statement
        :expr       => '',
        :endexpr    => ';',

        ## print-statement
        ##
        ## note: ':print' statement doesn't print prefix and suffix,
        ## so you should include prefix and suffix in ':print'/':endprint' keywords
        :print      => '<?php echo ',
        :endprint   => '; ?>',
        :eprint     => '<?php echo htmlspecialchars(',
        :endeprint  => '); ?>',

        ## literal
        :true        => 'TRUE',
        :false       => 'FALSE',
        :null        => 'NULL',

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
        '.+'   => ' . ',

        ## assignment op
        '='    => ' = ',
        '+='   => ' += ',
        '-='   => ' -= ',
        '*='   => ' *= ',
        '/='   => ' /= ',
        '%='   => ' %= ',
        '.+='  => ' .= ',

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
        '!'    => '!',

        ## array & hash op
        '['    => '[',
        ']'    => ']',
        '[:'   => "['",
        ':]'   => "']",

        ## property op
        '.'    => '->',

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
         'str_index'   => 'strstr',
         'str_empty'   => nil,
      }


      ## should be abstract
      def function_name(name)
         return @@func_names[name]
      end


      ##
      def visit_funtion_expression(expr, depth=0)
         t = expr.token
         case expr.funcname
         when 'list_empty', 'hash_empty'
            @code << 'count('
            translate_expression(expr.arguments[0])
            @code << ')==0'
         when 'str_empty'
            translate_expression(expr.arguments[0])
         else
            super(expr, depth)
         end
         return @code
      end


      ##
      def visit_empty_expression(expr, depth=0)
         if expr.token == :empty
            expr2 = UnaryExpression.new('!', expr.child)
         else
            expr2 = expr.child
         end
         translate_expression(expr2)
         return @code
      end


      ##
      def visit_variable_expression(expr, depth=0)
         @code << '$' << expr.name
      end


      ##
      def visit_foreach_statement(stmt, depth)
         @code << prefix(depth)
         @code << keyword(:foreach)
         translate_expression(stmt.list_expr)
         @code << keyword(:in)
         translate_expression(stmt.loopvar_expr)
         @code << keyword(:doforeach)
         @code << postfix()
         translate_statement(stmt.body_stmt, depth+1)
         @code << prefix(depth)
         @code << keyword(:endforeach)
         @code << postfix()
         return @code
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
   translator = Kwartz::PhpTranslator.new(properties)
   code = translator.translate(block_stmt)
   print code
end
