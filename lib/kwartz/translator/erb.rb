###
### copyright(c) 2005 kuwata-lab all rights reserved
###
### $Id$
### $Release$
###

require 'kwartz/translator'
require 'kwartz/translator/eruby'

module Kwartz

   class ErbTranslator < ErubyTranslator

      def self.lang
         return 'erb'
      end

      Translator.register('erb', self)

      @@erb_keywords = {
         :eprint  => '<%=h(',
         :endeprint => ')%>',
      }

      def keyword(key)
         #Kwartz::assert("key=#{key.inspect}") unless @@eruby_keywords.key?(key)
         return @@erb_keywords[key] || super(key)
      end

      @@erb_func_names = {
         'escape_xml' => 'html_escape',
         'escape_url' => 'url_encode',
      }

      def translate_function(function_name, arguments)
         func = @@erb_func_names[function_name]
         unless func
            super(function_name, arguments, code)
            return
         end
         append_code(func)
         append_code('(')
         expr = arguments[0]
         translate_expression(expr)
         append_code(')')
         return
      end
      
   end
end
