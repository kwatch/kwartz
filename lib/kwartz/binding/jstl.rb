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
      @jstl_ver = properties[:jstl] || 1.2
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


    def handle(directive_name, directive_arg, directive_str, stag_info, etag_info, cont_stmts, attr_info, append_exprs, stmt_list)
      ret = super
      return ret if ret

      d_name = directive_name
      d_arg  = directive_arg
      d_str  = directive_str

      stag_stmt = build_print_stmt(stag_info, attr_info, append_exprs)
      etag_stmt = build_print_stmt(etag_info, nil, nil)

      case directive_name

      when :for, :For, :FOR, :list, :List, :LIST
        is_foreach = d_name == :for || d_name == :For || d_name == :FOR
        unless d_arg =~ /\A(\w+)\s*:\s*(.*)\z/
          raise convert_error("'#{d_str}': invalid argument.", stag_info.linenum)
        end
        loopvar = $1 ; looplist = $2
        counter = d_name == :for || d_name == :list ? nil : "#{loopvar}_ctr"
        toggle  = d_name != :FOR && d_name != :LIST ? nil : "#{loopvar}_tgl"
        status  = d_name == :for || d_name == :list ? nil : "#{loopvar}_status"
        stmt_list << stag_stmt   if !is_foreach
        sb = "<c:forEach var=\"#{loopvar}\" items=\"${#{looplist}}\""
        sb << " varStatus=\"#{status}\"" if status
        sb << ">"
        stmt_list << NativeStatement.new(sb, :foreach)
        if counter
          stmt_list << NativeStatement.new("<c:set var=\"#{counter}\" value=\"${#{status}.count}\" />")
        end
        if toggle
          if @jstl_ver < 1.2
            stmt_list << NativeStatement.new("<c:choose><c:when test=\"${#{status}.count%2==0}\">")
            stmt_list << NativeStatement.new("<c:set var=\"#{toggle}\" value=\"${self.even}\"/>")
            stmt_list << NativeStatement.new("</c:when><c:otherwise>")
            stmt_list << NativeStatement.new("<c:set var=\"#{toggle}\" value=\"${self.odd}\"/>")
            stmt_list << NativeStatement.new("</c:otherwise></c:choose>")
          else
            sb = "<c:set var=\"#{toggle}\" value=\"${#{status}.count%2==0 ? #{self.even} : #{self.odd}}\" />"
            stmt_list << NativeStatement.new(sb)
          end
        end
        stmt_list  <<  stag_stmt   if is_foreach
        stmt_list.concat(cont_stmts)
        stmt_list  <<  etag_stmt   if is_foreach
        stmt_list  <<  NativeStatement.new("</c:forEach>", :foreach)
        stmt_list  <<  etag_stmt   if !is_foreach

      when :while, :loop
        raise convert_error("'#{d_str}': jstl doesn't support '#{d_arg}' directive.", stag_info.linenum)

      when :set
        unless d_arg =~ /\A(\S+)\s*=\s*(.*)\z/
          raise convert_error("'#{d_str}': invalid argument.", stag_info.linenum)
        end
        lhs = $1;  rhs = $2
        wrap_element(stmt_list, stag_stmt, etag_stmt, cont_stmts,
                     "<c:set var=\"#{lhs}\" value=\"${#{rhs}}\" />", nil, :set)
        #code "<c:set var=\"#{lhs}\" value=\"${#{rhs}}\" />"
        #stmt_list << NativeStatement.new(code, :set)
        #stmt_list << stag_stmt
        #stmt_list.concat(cont_stmts)
        #stmt_list << etag_stmt

      when :if
        wrap_element(stmt_list, stag_stmt, etag_stmt, cont_stmts,
                     "<c:choose><c:when test=\"${#{d_arg}}\">", "</c:when></c:choose>", :if)
        #code = "<c:choose><c:when test=\"${#{d_arg}}\">"
        #stmt_list << NativeStatement.new(code, :if)
        #stmt_list << stag_stmt
        #stmt_list.concat(cont_stmts)
        #stmt_list << etag_stmt
        #stmt_list << NativeStatement.new("</c:when></c:choose>", :if)

      when :elseif, :else
        unless ! stmt_list.empty? \
               && (st=stmt_list[-1]).is_a?(NativeStatement) \
               && (st.kind == :if || st.kind == :elseif)
          msg = "'#{d_str}': previous statement should be 'if' or 'elseif'."
          raise convert_error(msg, stag_info.linenum)
        end
        stmt_list.pop    # delete '</c:when></c:choose>'
        if d_name == :else
          kind = :else
          code1 = "</c:when><c:otherwise>"
          code2 = "</c:otherwise></c:choose>"
        else
          kind = :elseif
          code1 = "</c:when><c:when test=\"${#{d_arg}}\">"
          code2 = "</c:when></c:choose>"
        end
        wrap_element(stmt_list, stag_stmt, etag_stmt, cont_stmts,
                     code1, code2, kind)
        #stmt_list << NativeStatement.new(code1, kind)
        #stmt_list << stag_stmt
        #stmt_list.concat(cont_stmts)
        #stmt_list << etag_stmt
        #stmt_list << NativeStatement.new(code2, kind)

      when :default, :Default, :DEFAULT
        error_if_empty_tag(stag_info, etag_info, d_name, d_arg)
        stmt_list << stag_stmt
        flag_escape = d_name == :default ? nil : (d_name == :Default)
        argstr = cont_stmts[0].args[0]
        code =  "<c:out value=\"${#{d_arg}}\""
        code << " escapeXml=\"#{flag_escape}\"" unless flag_escape == nil
        code << " default=#{argstr.dump} />"
        stmt_list << NativeStatement.new_without_newline(code)
        stmt_list << etag_stmt

      when :catch
        if d_arg && !d_arg.empty? && d_arg !~ /\A\w+\z/
          raise convert_error("'#{d_str}': invalid varname.", stag_info.linenum)
        end
        code = "<c:catch"
        code << " var=\"#{d_arg}\"" if d_arg && !d_arg.empty?
        code << ">"
        stmt_list << NativeStatement.new(code)
        stmt_list.concat(cont_stmts)
        stmt_list << NativeStatement.new("</c:catch>")

      when :forEach, :forTokens
        stag, etag = eval "handle_jstl_#{d_name}(#{d_arg})"
        wrap_element(stmt_list, stag_stmt, etag_stmt, cont_stmts,
                     stag, etag, nil)
        #stmt_list << NativeStatement.new(stag)
        #stmt_list << stag_stmt
        #stmt_list.concat(cont_stmts)
        #stmt_list << etag_stmt
        #stmt_list << NativeStatement.new(etag)

      when :redirect, :import, :url, :remove
        lines = eval "handle_jstl_#{d_name}(#{d_arg})"
        lines.each do |line|
          stmt_list << NativeStatement.new(line)
        end

      else
        return false

      end #case
      return true

    end #def


    protected


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
      stag, etag = _handle_jstl_tag(tagname, param_list, options)
      lines = [stag]
      i = 0
      options.each do |name, value|
        i += 1
        if value.is_a?(Symbol)
          lines << " <c:param name=\"#{name}\" value=\"${#{value}}\"/>"
        else
          #lines << " <c:param name=\"#{name}\" value=\"#{value}\"/>"
        end
      end
      if i == 0
        stag.sub!(/>\z/, '/>')
      else
        lines << etag
      end
      return lines
    end


    def _handle_jstl_tag(tagname, param_list, options)
      sb = "<c:#{tagname}"
      param_list.each do |param|
        key = nil
        if options.key?(param.intern) ; key = param.intern
        elsif options.key?(param)     ; key = param
        end
        next if key == nil
        value = options.delete(key)
        if value.is_a?(Symbol)
          sb << " #{param}=\"${#{value}}\""
        else
          sb << " #{param}=\"#{value}\""
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
      jstl_ver = properties[:jstl] || 1.2
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
