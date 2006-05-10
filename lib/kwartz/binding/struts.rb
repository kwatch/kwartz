###
### $Rev$
### $Release$
### $Copyright$
###

require 'kwartz/assert'
require 'kwartz/converter'
require 'kwartz/translator'
require 'kwartz/binding/jstl'



module Kwartz



  ##
  ## directive handler for Struts
  ##
  class StrutsHandler < JstlHandler



    def handle(directive_name, directive_arg, directive_str, stag_info, etag_info, cont_stmts, attr_info, append_exprs, stmt_list)
      ret = super
      return ret if ret

      d_name = directive_name
      d_arg  = directive_arg
      d_str  = directive_str

      case directive_name

      when :struts
        case tag = stag_info.tagname
        when 'input'  ;  tag = attr_info['type'] || 'text'  ; attr_info.delete('type')
        when 'a'      ;  tag = 'link'
        when 'script' ;  tag = 'javascript'
        end
        tag == :struts   and raise convert_error("#{d_str}: unknown directive.", stag_info.linenum)
        return self.handle(tag.intern, d_arg, directive_str, stag_info, etag_info,
                           cont_stmts, attr_info, append_exprs, stmt_list)

      else
        convert_mapping = {
          'name'=>'property',
          'class'=>'cssClass'
        }
        convert_mapping.each do |html_aname, struts_aname|
          next unless attr_info[html_aname]
          attr_info[struts_aname] = attr_info[html_aname]
          attr_info.delete(html_aname)
        end
        opts = eval "_evaluate_options(#{d_arg})"
        opts.each do |name, value|
          attr_info[name.to_s] = value.is_a?(Symbol) ? "${#{value}}" : value
        end
        tagname = "html:#{d_name}"
        stag_info.tagname = tagname
        etag_info.tagname = tagname if etag_info
        stag_info.is_empty = true   if !etag_info
        stmt_list << build_print_stmt(stag_info, attr_info, append_exprs)
        stmt_list.concat(cont_stmts)
        stmt_list << build_print_stmt(etag_info, nil, nil) if etag_info

      end #case
      return true

    end #def


  end #class
  Handler.register_class('struts', StrutsHandler)



  ##
  ## translator for php
  ##
  class StrutsTranslator < JstlTranslator


    def initialize(properties={})
      super
      self.header << '<%@ taglib uri="/tags/struts-html" prefix="html" %>'   << @nl
      #self.header << '<%@ taglib uri="/tags/struts-bean" prefix="bean" %>'   << @nl
      #self.header << '<%@ taglib uri="/tags/struts-logic" prefix="logic" %>' << @nl
    end


    def translate_native_expr(expr)
      assert unless expr.is_a?(NativeExpression)
      flag_escape = expr.escape?
      flag_escape = @escape if flag_escape == nil
      if flag_escape == false
        @sb << @expr_l << expr.code << @expr_r       # ex. <c:out value="${expr}" escapeXml="false"/>
      else
        @sb << @escape_l << expr.code << @escape_r   # ex. <c:out value="${expr}"/>
      end
    end


  end
  Translator.register_class('struts', StrutsTranslator)



end #module
