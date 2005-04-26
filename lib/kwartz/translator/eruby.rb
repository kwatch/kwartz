###
### copyright(c) 2005 kuwata-lab all rights reserved
###
### $Id$
### $Release$
###

require 'kwartz/translator'

module Kwartz

   class ErubyTranslator < BaseTranslator

      def self.lang
         return 'eruby'
      end

      Translator.register('eruby', self)

      @@keywords = {

        ## statement prefix and postfist
        :prefix     => '<% ',         ## statement prefix
        :postfix    => ' %>',         ## statement postfix

        ## if-statement
        :if         => 'if ',
        :then       => ' then',
        :else       => 'else',
        :elseif     => 'elsif ',
        :endif      => 'end',

        ## while-statement
        :while      => 'while ',
        :dowhile    => ' do',
        :endwhile   => 'end',

        ## foreach-statement
        :foreach    => 'for ',
        :in         => ' in ',
        :doforeach  => ' do',
        :endforeach => 'end',

        ## expression-statement
        :expr       => '',
        :endexpr    => '',

        ## print-statement
        ##
        ## note: ':print' statement doesn't print prefix and suffix,
        ## so you should include prefix and suffix in ':print'/':endprint' keywords
        :print      => '<%= ',
        :endprint   => ' %>',
        :eprint     => '<%= CGI::escapeHTML((',
        :endeprint  => ').to_s) %>',
        
        ## rawcode-statement
        :rawcode    => '<%',
        :endrawcode => '%>',

        ## literal
        :true        => 'true',
        :false       => 'false',
        :null        => 'nil',

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
        '.+'   => ' + ',

        ## assignment op
        '='    => ' = ',
        '+='   => ' += ',
        '-='   => ' -= ',
        '*='   => ' *= ',
        '/='   => ' /= ',
        '%='   => ' %= ',
        '.+='  => ' += ',

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
        '[:'   => '[:',
        ':]'   => ']',

        ## property op
        '.'    => '.',

        ## method op
        '.()'  => '.',

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
         'list_new'    => '[]',
         'list_length' => '.length',
         'list_empty'  => '.empty?',
         'hash_new'    => '{}',
         'hash_length' => '.length',
         'hash_empty'  => '.empty?',
         'hash_keys'   => '.keys',
         'str_length'  => '.length',
         'str_trim'    => '.trim',
         'str_tolower' => '.downcase',
         'str_toupper' => '.upcase',
         'str_index'   => '.index',
         'str_empty'   => '.empty?',
         'str_replace' => '.gsub',
         'str_linebreak' => '.gsub(/\r?\n/,\'<br />\\&\')',
         'escape_xml'  => 'CGI::escapeHTML',
         'escape_sql'  => '.gsub([\'"\\\\\\0],\'\\&\')',    #"
         'escape_url'  => 'CGI::escape',
      }


      ##
      def translate_function(function_name, arguments)
         funcname = @@func_names[function_name]
         if !funcname
            return super(function_name, arguments)
         end
         case function_name
         when 'list_new', 'hash_new'
            append_code(funcname)
         when 'escape_xml', 'escape_url'
            append_code(funcname)
            append_code('(')
            translate_expression(arguments[0])
            append_code(')')
         when 'escape_sql', 'str_linebreak'
            translate_expression(arguments[0])
            append_code(funcname)
         else
            if arguments.length == 0
               append_code(funcname)
            else
               receiver = arguments[0]
               translate_expression(receiver)
               append_code(funcname)
               if arguments.length > 1
                  append_code(keyword('('))
                  arguments.each_with_index do |arg, i|
                     append_code(keyword(',')) if i > 1
                     translate_expression(arg) if i > 0
                  end
                  append_code(keyword(')'))
               end
            end
         end
      end


      ##
      def visit_empty_expression(expr, depth=0)
         if expr.token == :empty
            left  = UnaryExpression.new('!', expr.child)
            right = FunctionExpression.new('str_empty', [ expr.child ])
            expr2 = LogicalExpression.new('||', left, right)
         else
            left  = expr.child
            right = UnaryExpression.new('!', FunctionExpression.new('str_empty', [ expr.child ]))
            expr2 = LogicalExpression.new('&&', left, right)
         end
         translate_expression(expr2)
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
   translator = Kwartz::ErubyTranslator.new(properties)
   code = translator.translate(block_stmt)
   print code
end
