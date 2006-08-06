###
### $Rev$
### $Release$
### $Copyright$
###

require 'kwartz/converter'
require 'kwartz/translator'
require 'kwartz/binding/ruby'



module Kwartz



  ##
  ## directive handler for eRuby
  ##
  class ErubyHandler < RubyHandler
  end
  Handler.register_class('eruby', ErubyHandler)



  ##
  ## translator for eRuby
  ##
  class ErubyTranslator < BaseTranslator


    ERUBY_EMBED_PATTERNS = [
      '<% ',    ' %>',        # statement
      '<%= ',   ' %>',        # expression
      '<%=h ',  ' %>',        # escaped expression
    ]


    def initialize(properties={})
      super(ERUBY_EMBED_PATTERNS, properties)
    end


  end #class
  Translator.register_class('eruby', ErubyTranslator)



end #module
