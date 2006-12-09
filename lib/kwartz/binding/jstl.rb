###
### $Rev$
### $Release$
### $Copyright$
###

require 'kwartz/assert'
require 'kwartz/converter'
require 'kwartz/translator'



module Kwartz



  ##
  ## directive handler for JSTL
  ##
  class JstlHandler < Handler


    def initialize(elem_rulesets=[], properties={})
      super
      @jstl_ver = properties[:jstl] || Config::PROPERTY_JSTL
    end


    JSTL_DIRECTIVE_PATTERN = /\A(\w+)(?:\s*\(\s*(.*)\))?\z/

    def directive_pattern
      return JSTL_DIRECTIVE_PATTERN
    end


    JSTL_MAPPING_PATTERN = /\A'([-:\w]+)',\s*(.*)\z/

    def mapping_pattern
      return JSTL_MAPPING_PATTERN
    end


    JSTL_DIRECTIVE_FORMAT = '%s(%s)'

    def directive_format
      return JSTL_DIRECTIVE_FORMAT
    end


    def handle(directive, elem_info, stmt_list)
      ret = super
      return ret if ret

      d_name = directive.name
      d_arg  = directive.arg
      d_str  = directive.str
      e = elem_info

      case d_name

      when :for, :For, :FOR, :list, :List, :LIST
        is_foreach = d_name == :for || d_name == :For || d_name == :FOR
        error_if_empty_tag(elem_info, d_str) unless is_foreach
        unless d_arg =~ /\A(\w+)\s*:\s*(.*)\z/
          raise convert_error("'#{d_str}': invalid argument.", elem_info.stag_info.linenum)
        end
        loopvar = $1 ; looplist = $2
        counter = d_name == :for || d_name == :list ? nil : "#{loopvar}_ctr"
        toggle  = d_name != :FOR && d_name != :LIST ? nil : "#{loopvar}_tgl"
        status  = d_name == :for || d_name == :list ? nil : "#{loopvar}_status"
        foreach_code = "<c:forEach var=\"#{loopvar}\" items=\"${#{looplist}}\""
        foreach_code << " varStatus=\"#{status}\"" if status
        foreach_code << ">"
        code = []
        code << foreach_code
        code << "<c:set var=\"#{counter}\" value=\"${#{status}.count}\"/>" if counter
        if toggle
          if @jstl_ver < 1.2
            code << "<c:choose><c:when test=\"${#{status}.count%2==0}\">"
            code << "<c:set var=\"#{toggle}\" value=\"${self.even}\"/>"
            code << "</c:when><c:otherwise>"
            code << "<c:set var=\"#{toggle}\" value=\"${self.odd}\"/>"
            code << "</c:otherwise></c:choose>"
          else
            code << "<c:set var=\"#{toggle}\" value=\"${#{status}.count%2==0 ? #{self.even} : #{self.odd}}\"/>"
          end
        end
        end_code = "</c:forEach>"
        if is_foreach
          wrap_element_with_native_stmt(elem_info, stmt_list, code, end_code, :set)
        else
          wrap_content_with_native_stmt(elem_info, stmt_list, code, end_code, :set)
        end

      when :while, :loop
        msg = "'#{d_str}': jstl doesn't support '#{d_arg}' directive."
        raise convert_error(msg, elem_info.stag_info.linenum)

      when :set
        unless d_arg =~ /\A(\S+)\s*=\s*(.*)\z/
          raise convert_error("'#{d_str}': invalid argument.", elem_info.stag_info.linenum)
        end
        lhs = $1;  rhs = $2
        code = "<c:set var=\"#{lhs}\" value=\"${#{rhs}}\"/>"
        wrap_element_with_native_stmt(elem_info, stmt_list, code, nil, :set)
        #code = "<c:set var=\"#{lhs}\" value=\"${#{rhs}}\"/>"
        #stmt_list << NativeStatement.new(code, :set)
        #stmt_list << stag_stmt(elem_info)
        #stmt_list.concat(cont_stmts)
        #stmt_list << etag_stmt(elem_info)

      when :if
        start_code = "<c:choose><c:when test=\"${#{d_arg}}\">"
        end_code   = "</c:when></c:choose>"
        wrap_element_with_native_stmt(elem_info, stmt_list, start_code, end_code, :if)
        #stmt_list << NativeStatement.new(start_code, :if)
        #stmt_list << stag_stmt(elem_info)
        #stmt_list.concat(cont_stmts)
        #stmt_list << etag_stmt(elem_info)
        #stmt_list << NativeStatement.new(end, :if)

      when :elseif, :else
        error_when_last_stmt_is_not_if(elem_info, d_str, stmt_list)
        stmt_list.pop    # delete '</c:when></c:choose>'
        if d_name == :else
          kind = :else
          start_code = "</c:when><c:otherwise>"
          end_code   = "</c:otherwise></c:choose>"
        else
          kind = :elseif
          start_code = "</c:when><c:when test=\"${#{d_arg}}\">"
          end_code   = "</c:when></c:choose>"
        end
        wrap_element_with_native_stmt(elem_info, stmt_list, start_code, end_code, kind)
        #stmt_list << NativeStatement.new(start_code, kind)
        #stmt_list << stag_stmt
        #stmt_list.concat(cont_stmts)
        #stmt_list << etag_stmt
        #stmt_list << NativeStatement.new(end_code, kind)

      when :default, :Default, :DEFAULT
        error_if_empty_tag(elem_info, d_str)
        stmt_list << stag_stmt(elem_info)
        flag_escape = d_name == :default ? nil : (d_name == :Default)
        argstr = elem_info.cont_stmts[0].args[0]
        expr_str = directive.format == :common ? parse_expr_str(d_arg, e.stag_info.linenum) : d_arg
        code =  "<c:out value=\"${#{expr_str}}\""
        code << " escapeXml=\"#{flag_escape}\"" unless flag_escape == nil
        code << " default=\"#{argstr}\"/>"
        stmt_list << NativeStatement.new_without_newline(code)
        stmt_list << etag_stmt(elem_info)

      when :catch
        if d_arg && !d_arg.empty? && d_arg !~ /\A\w+\z/
          raise convert_error("'#{d_str}': invalid varname.", elem_info.stag_info.linenum)
        end
        code = "<c:catch"
        code << " var=\"#{d_arg}\"" if d_arg && !d_arg.empty?
        code << ">"
        stmt_list << NativeStatement.new(code)
        stmt_list.concat(elem_info.cont_stmts)
        stmt_list << NativeStatement.new("</c:catch>")

      when :forEach, :forTokens
        options = eval "{ #{d_arg} }"
        stag, etag = self.__send__ "handle_jstl_#{d_name}", options
        wrap_element_with_native_stmt(elem_info, stmt_list, stag, etag, nil)
        #stmt_list << NativeStatement.new(stag)
        #stmt_list << stag_stmt
        #stmt_list.concat(cont_stmts)
        #stmt_list << etag_stmt
        #stmt_list << NativeStatement.new(etag)

      when :redirect, :import, :url, :remove
        options = eval "{ #{d_arg} }"
        lines = self.__send__ "handle_jstl_#{d_name}", options
        lines.each do |line|
          stmt_list << NativeStatement.new(line.chomp)
        end

      else
        return false

      end #case
      return true

    end #def


    protected


    def parse_expr_str(expr_str, linenum)
      case expr_str
      when /\A(\w+)\z/             # variable
        expr = expr_str
      when /\A(\w+)\.(\w+)\z/      # object.property
        expr = expr_str
      when /\A(\w+)\[('.*?'|".*?"|:\w+)\]\z/   # hash
        key = $2[0] == ?: ? "'#{$2[1..-1]}'" : $2
        expr = "#{$1}[#{key}]"
      when /\A(\w+)\[(\w+)\]\z/    # array or hash
        expr = "#{$1}[#{$2}]"
      else
        raise convert_error("'#{expr_str}': invalid expression.", linenum)
      end
      return expr
    end


    def handle_jstl_redirect(options)
      return _handle_jstl_params('redirect', %w[url context], options)
    end


    def handle_jstl_import(options)
      return _handle_jstl_params('import', %w[url context charEncoding var scope], options)
    end


    def handle_jstl_url(options)
      return _handle_jstl_params('url', %w[value context var scope], options)
    end


    def handle_jstl_remove(options)
      return _handle_jstl_params('remove', %w[var scope], options)
    end


    def handle_jstl_forEach(options)
      param_list = %w[var items varStatus begin end step]
      return _handle_jstl_tag('forEach', param_list, options)
    end


    def handle_jstl_forTokens(options)
      param_list = %w[items delims var varStatus begin end step]
      return _handle_jstl_tag('forTokens', param_list, options)
    end


    def _handle_jstl_params(tagname, param_list, options)
      stag, etag = _handle_jstl_tag(tagname, param_list, options, true)
      i = 0
      unknown_param_names = options.keys - param_list
      lines = []
      if unknown_param_names.empty?
        lines << stag.sub(/>\z/, '/>')
      else
        lines << stag
        unknown_param_names.each do |name|
          value = options[name]
          if value.is_a?(Symbol)
            lines << " <c:param name=\"#{name}\" value=\"${#{value}}\"/>"
          else
            lines << " <c:param name=\"#{name}\" value=\"#{value}\"/>"
          end
        end
        lines << etag
      end
      return lines.join("\n")
    end


    def _handle_jstl_tag(tagname, param_list, options, ignore_unknown_option=false)
      options.each do |name, value|
        next if name.is_a?(String)
        options[name.to_s] = options.delete(name)
      end
      option_names = options.keys
      unless ignore_unknown_option
        unkown_option_names = option_names - param_list
        unless unkown_option_names.empty?
          msg = "'#{unkown_option_names[0]}': unknown option for '#{tagname}' directive."
          raise convert_error(msg, nil)   # TODO
        end
      end
      sb = "<c:#{tagname}"
      (param_list & option_names).each do |name|
        value = options[name]
        if value.is_a?(Symbol)
          sb << " #{name}=\"${#{value}}\""
        else
          sb << " #{name}=\"#{value}\""
        end
      end
      sb << ">"
      stag = sb
      etag = "</c:#{tagname}>"
      return stag, etag
    end


    def _evaluate_options(options={})
      return options
    end


  end #class
  Handler.register_class('jstl', JstlHandler)



  ##
  ## translator for php
  ##
  class JstlTranslator < BaseTranslator


    JSTL11_EMBED_PATTERNS = [
      '', '',                                       # statement
      '<c:out value="${', '}" escapeXml="false"/>', # expression
      '<c:out value="${', '}"/>'                    # escaped expression
    ]


    JSTL12_EMBED_PATTERNS = [
      '', '',                                       # statement
      '<c:out value="${', '}" escapeXml="false"/>', # expression
      '${', '}'                                     # escaped expression
    ]


    def initialize(properties={})
      jstl_ver = properties[:jstl] || Config::PROPERTY_JSTL
      super(jstl_ver < 1.2 ? JSTL11_EMBED_PATTERNS : JSTL12_EMBED_PATTERNS, properties)
      @jstl_ver = jstl_ver
      unless self.header
        sb = ''
        if charset = properties[:charset]
          sb << "<%@ page contentType=\"text/html; charset=#{charset}\" %>" << @nl
        else
          #sb << "<%@ page contentType=\"text/html\" %>" << @nl
        end
        if @jstl_ver < 1.2
          sb << '<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>' << @nl
        else
          sb << '<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>'      << @nl
          sb << '<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>' << @nl
        end
        self.header = sb
      end
    end


    def translate_native_expr(expr)
      assert unless expr.is_a?(NativeExpression)
      if expr.code =~ /\A"(.*)"\z/ || expr.code =~ /\A'(.*)'\z/
        @sb << $1
      else
        flag_escape = expr.escape?
        flag_escape = @escape if flag_escape.nil?
        if flag_escape == false
          @sb << @expr_l << expr.code << @expr_r       # ex. <c:out value="${expr}" escapeXml="false"/>
        else
          @sb << @escape_l << expr.code << @escape_r   # ex. <c:out value="${expr}"/>
        end
      end
    end


  end
  Translator.register_class('jstl', JstlTranslator)



end #module
