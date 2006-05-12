###
### $Rev$
### $Release$
### $Copyright$
###

require 'kwartz/converter'
require 'kwartz/translator'
require 'kwartz/binding/eruby'



module Kwartz



  class ErubisHandler < ErubyHandler


  end #class
  Handler.register_class('erubis', ErubisHandler)



  ##
  ## translator for Erubis
  ##
  class ErubisTranslator < BaseTranslator


    ERUBIS_EMBED_PATTERNS = [
      '<% ',    ' %>',        # statement
      '<%= ',   ' %>',        # expression
      '<%== ',  ' %>',        # escaped expression
    ]


    def initialize(properties={})
      super(ERUBIS_EMBED_PATTERNS, properties)
      @escape = true if @escape == nil
    end


    #def translate_native_expr(expr)
    #  assert unless expr.is_a?(NativeExpression)
    #  flag_escape = expr.escape?
    #  flag_escape = @escape if flag_escape == nil
    #  if flag_escape == false
    #    @sb << @expr_l << expr.code << @expr_r       # ex. <%== expr %>
    #  else
    #    @sb << @escape_l << expr.code << @escape_r   # ex. <%= expr %>
    #  end
    #end


  end
  Translator.register_class('erubis', ErubisTranslator)



end #module
