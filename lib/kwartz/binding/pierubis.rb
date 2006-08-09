###
### $Rev$
### $Release$
### $Copyright$
###

require 'kwartz/converter'
require 'kwartz/translator'
require 'kwartz/binding/ruby'



module Kwartz



  class PIErubisHandler < RubyHandler
  end
  Handler.register_class('pierubis', PIErubisHandler)



  ##
  ## translator for Erubis
  ##
  class PIErubisTranslator < BaseTranslator


    PIERUBIS_EMBED_PATTERNS = [
      '<?rb ', ' ?>',      # statement
      '$!{',   '}',        # expression
      '${',    '}',        # escaped expression
    ]


    def initialize(properties={})
      super(PIERUBIS_EMBED_PATTERNS, properties)
      #@escape = true if @escape == nil
    end


    def translate_native_expr(expr)
      assert unless expr.is_a?(NativeExpression)
      if expr.code.include?(?})
        @expr_l, @expr_r, @escape_l, @escape_r = '<%=', '%>', '<%==', '%>'
      else
        @expr_l, @expr_r, @escape_l, @escape_r = '$!{', '}', '${', '}'
      end
      super(expr)
    end


  end
  Translator.register_class('pierubis', PIErubisTranslator)



end #module
