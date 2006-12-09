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
  ## [experimental] directive handler for Struts
  ##
  class StrutsHandler < JstlHandler   # :nodoc:



    def handle(directive_name, directive_arg, directive_str, elem_info, stmt_list)
      ret = super
      return ret if ret

      d_name = directive_name
      d_arg  = directive_arg
      d_str  = directive_str
      e = elem_info

      case directive_name

      when :struts
        case tag = e.stag_info.tagname
        when 'input'  ;  tag = e.attr_info['type'] || 'text'  ; e.attr_info.delete('type')
        when 'a'      ;  tag = 'link'
        when 'script' ;  tag = 'javascript'
        end
        tag == :struts   and raise convert_error("#{d_str}: unknown directive.", e.stag_info.linenum)
        return self.handle(tag.intern, d_arg, directive_str, elem_info, stmt_list)

      else
        convert_mapping = {
          'name'=>'property',
          'class'=>'cssClass'
        }
        convert_mapping.each do |html_aname, struts_aname|
          next unless e.attr_info[html_aname]
          e.attr_info[struts_aname] = e.attr_info[html_aname]
          e.attr_info.delete(html_aname)
        end
        opts = eval "_evaluate_options(#{d_arg})"
        opts.each do |name, value|
          e.attr_info[name.to_s] = value.is_a?(Symbol) ? "${#{value}}" : value
        end
        tagname = "html:#{d_name}"
        e.stag_info.tagname = tagname
        e.etag_info.tagname = tagname if e.etag_info
        e.stag_info.is_empty = true   if !e.etag_info
        stmt_list << build_print_stmt(e.stag_info, e.attr_info, e.append_exprs)
        stmt_list.concat(cont_stmts)
        stmt_list << build_print_stmt(e.etag_info, nil, nil) if e.etag_info

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
