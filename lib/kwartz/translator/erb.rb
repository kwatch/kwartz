###
### copyright(c) 2005 kuwata-lab all rights reserved
###
### $Id$
###

require 'kwartz/translator'
require 'kwartz/translator/eruby'

module Kwartz

   class ErbTranslator < ErubyTranslator
      
      def self.lang
         return 'erb'
      end
      
      Translator.register('erb', self)
      
      @@keywords2 = {
         :eprint  => '<%=h(',
         :endeprint => ')%>',
      }

      def keyword(key)
         Kwartz::assert("key=#{key.inspect}") unless @@keywords.key?(key)
         return @@keywords2[key] || super(key)
      end

   end
end
