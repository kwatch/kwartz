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
         'hash_keys'   => '.keys',
         'hash_empty'  => '.empty?',
         'str_length'  => '.length',
         'str_trim'    => '.trim',
         'str_tolower' => '.downcase',
         'str_toupper' => '.upcase',
         'str_index'   => '.index',
         'str_empty'   => '.empty?',
      }

      
      ## should be abstract
      def function_name(name)
         return @@func_names[name]
      end

      
      ##
      def visit_funtion_expression(expr, depth=0)
         t = expr.token
         funcname = function_name(expr.funcname)
         if !funcname
            return super(expr, depth)
         end

         arglen = expr.arguments.length
         if arglen == 0
            @code << funcname
         else
            receiver = expr.arguments[0]
            translate_expression(receiver)
            @code << funcname
            if arglen > 1
               @code << keyword('(')
               expr.arguments.each_with_index do |arg, i|
                  @code << keyword(',')     if i > 1
                  translate_expression(arg) if i > 0
               end
               @code << keyword(')')
            end
         end
         
         return @code
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
