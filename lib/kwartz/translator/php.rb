###
### copyright(c) 2005 kuwata-lab all rights reserved
###
### $Id$
### $Release$
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

        ## method op
        '.()'  => '->',

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


      @@php_func_names = {
         'list_new'      => 'array',
         'list_length'   => 'count',
         'list_empty'    => 'count',
         'hash_new'      => 'array',
         'hash_length'   => 'count',
         'hash_empty'    => 'count',
         'hash_keys'     => 'array_keys',
         'str_length'    => 'strlen',
         'str_trim'      => 'trim',
         'str_tolower'   => 'strtolower',
         'str_toupper'   => 'strtoupper',
         'str_index'     => 'strstr',
         'str_empty'     => 'strlen',
         'str_replace'   => 'str_replace',
         'str_linebreak' => 'nl2br',
         'escape_xml'    => 'htmlspecialchars',
         'escape_sql'    => 'addslashes',
         'escape_url'    => 'urlencode',
      }


      ##
      def translate_function(function_name, arguments)
         funcname = @@php_func_names[function_name]
         case function_name
         when 'list_empty', 'hash_empty', 'str_empty'
            append_code(funcname)
            append_code('(')
            translate_expression(arguments[0])
            append_code(')==0')
         when 'str_replace'
            fname = @@php_func_names[function_name]
            args = [ arguments[1], arguments[2], arguments[0] ]
            super(fname, args)
         else
            fname = @@php_func_names[function_name] || function_name
            return super(fname, arguments)
         end
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
         #@code << '$' << expr.name
         @code << '$'
         super(expr, depth)
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
