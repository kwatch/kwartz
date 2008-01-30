###
### $Rev$
### $Release$
### $Copyright$
###

require 'kwartz/converter'
require 'kwartz/translator'


module Kwartz


  module PerlExpressionParser


    def parse_expr_str(expr_str, linenum)
      case expr_str
      when /\A(\w+)\z/             # variable
        expr = '$'+$1
      when /\A(\w+)\.(\w+)\z/      # object.property
        expr = "$#{$1}->{#{$2}}"
      when /\A(\w+)\[(.*?'|".*?"|:\w+)\]\z/   # hash
        key = $2[0] == ?: ? "'#{$2[1..-1]}'" : $2
        expr = "$#{$1}{#{key}}"
      when /\A(\w+)\[(\w+)\]\z/    # array or hash
        begin
          expr = "$#{$1}[#{Integer($2)}]"
        rescue ArgumentError
          expr = "$#{$1}[$#{$2}]"
        end
      else
        raise convert_error("'#{expr_str}': invalid expression.", linenum)
      end
      return expr
    end


    def parse_expr_str!(expr_str)
      begin
        return parse_expr_str(expr_str, -1)
      rescue
        return expr_str
      end
    end


  end




  ##
  ## directive handler for Perl
  ##
  class PerlHandler < Handler
    include PerlExpressionParser


    PERL_DIRECTIVE_PATTERN = /\A(\w+)(?:\s*\(\s*(.*)\))?\z/

    def directive_pattern
      return PERL_DIRECTIVE_PATTERN
    end


    PERL_MAPPING_PATTERN = /\A'([-:\w]+)',\s*(.*)\z/

    def mapping_pattern
      return PERL_MAPPING_PATTERN
    end


    PERL_DIRECTIVE_FORMAT = '%s(%s)'

    def directive_format
      return PERL_DIRECTIVE_FORMAT
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
        unless d_arg =~ /\A(\w+)(?:,\s*(\w+))?\s+in\s+(.*)\z/  \
            || d_arg =~ /\A(\w+)(?:,(\w+))?\s*[:=]\s*(.*)\z/
          raise convert_error("'#{d_str}': invalid argument.", e.stag_info.linenum)
        end
        loopvar = $1 ;  loopval = $2 ;  looplist = $3
        is_foreach = d_name == :for || d_name == :For || d_name == :FOR
        counter = d_name == :for || d_name == :list ? nil : "#{loopvar}_ctr"
        toggle  = d_name != :FOR && d_name != :LIST ? nil : "#{loopvar}_tgl"
        foreach_code = loopval ? "#{looplist}.each do |#{loopvar}, #{loopval}|" \
                               : "for #{loopvar} in #{looplist} do"
        code = []
        code << "#{counter} = 0" if counter
        code << foreach_code
        code << "  #{counter} += 1" if counter
        code << "  #{toggle} = #{counter}%2==0 ? #{@even} : #{@odd}" if toggle
        if is_foreach
          wrap_element_with_native_stmt(elem_info, stmt_list, code, "end", :foreach)
        else
          wrap_content_with_native_stmt(elem_info, stmt_list, code, "end", :foreach)
        end

      when :while
        wrap_element_with_native_stmt(elem_info, stmt_list, "while #{d_arg} do", "end", :while)
        #stmt_list << NativeStatement.new("while #{d_arg} do", :while)
        #stmt_list << stag_stmt(elem_info)
        #stmt_list.concat(e.cont_stmts)
        #stmt_list << etag_stmt(elem_info)
        #stmt_list << NativeStatement.new("end", :while)

      when :loop
        error_if_empty_tag(elem_info, d_str)
        wrap_content_with_native_stmt(elem_info, stmt_list, "while #{d_arg} do", "end", :while)
        #stmt_list << stag_stmt(elem_info)
        #stmt_list << NativeStatement.new("while #{d_arg} do", :while)
        #stmt_list.concat(e.cont_stmts)
        #stmt_list << NativeStatement.new("end", :while)
        #stmt_list << etag_stmt(elem_info)

      when :set
        wrap_element_with_native_stmt(elem_info, stmt_list, d_arg, nil, :set)
        #stmt_list << NativeStatement.new(d_arg, :set)
        #stmt_list << stag_stmt(elem_info)
        #stmt_list.concat(e.cont_stmts)
        #stmt_list << etag_stmt(elem_info)

      when :if
        wrap_element_with_native_stmt(elem_info, stmt_list, "if #{d_arg} then", "end", :if)
        #stmt_list << NativeStatement.new("if #{d_arg} then", :if)
        #stmt_list << stag_stmt(elem_info)
        #stmt_list.concat(e.cont_stmts)
        #stmt_list << etag_stmt(elem_info)
        #stmt_list << NativeStatement.new("end", :if)

      when :elsif, :else
        error_when_last_stmt_is_not_if(elem_info, d_str, stmt_list)
        stmt_list.pop    # delete 'end'
        kind = d_name == :else ? :else : :elseif
        code = d_name == :else ? "else" : "elsif #{d_arg} then"
        wrap_element_with_native_stmt(elem_info, stmt_list, code, "end", kind)
        #stmt_list << NativeStatement.new(code, kind)
        #stmt_list << stag_stmt(elem_info)
        #stmt_list.concat(e.cont_stmts)
        #stmt_list << etag_stmt(elem_info)
        #stmt_list << NativeStatement.new("end", kind)

      when :default, :Default, :DEFAULT
        error_if_empty_tag(elem_info, d_str)
        expr_str = directive.dattr == 'id' ? parse_expr_str(d_arg, e.stag_info.linenum) : d_arg
        flag_escape = d_name == :default ? nil : (d_name == :Default)
        add_native_expr_with_default(elem_info, stmt_list, expr_str, flag_escape,
                                     "if (#{expr_str}) && !(#{d_arg}).to_s.empty? then",
                                     "else", "end")
        #stmt_list << stag_stmt(elem_info)
        #stmt_list << NativeStatement.new_without_newline("if (#{d_arg}) && !(#{d_arg}).to_s.empty? then", :if)
        #flag_escape = d_name == :default ? nil : (d_name == :Default)
        #stmt_list << PrintStatement.new([ NativeExpression.new(d_arg, flag_escape) ])
        #stmt_list << NativeStatement.new_without_newline("else", :else)
        #stmt_list.concat(e.cont_stmts)
        #stmt_list << NativeStatement.new_without_newline("end", :else)
        #stmt_list << etag_stmt(elem_info)

      else
        return false

      end #case
      return true

    end #def


  end #class
  Handler.register_class('perl', PerlHandler)



  ##
  ## translator for Perl
  ##
  class PerlTranslator < BaseTranslator
    include PerlExpressionParser


    def initialize(properties={})
      escapefunc = properties[:escapefunc] || 'encode_entities'
      marks = ['', '', 'push(@_buf, ', '); ', "push(@_buf, #{escapefunc}(", ')); ']
      super(marks, properties)
      @header = 'my @_buf = (); '  unless @header == false
      @footer = "join('', @_buf);" + @nl   unless @footer == false
    end


    def translate_string(str)
      return if str.nil? || str.empty?
      #str.gsub!(/['\\]/, '\\\\\&')
      #@sb << "_buf << '#{str}'; "
      str.gsub!(/[`\\]/, '\\\\\&')
      @sb << "push(@_buf, q`#{str}`); "
      #if str[-1] == ?\n
      #  str.chomp!
      #  @sb << "push(@_buf, q`#{str}`, #{@nl.inspect});" << @nl
      #else
      #  @sb << "push(@_buf, q`#{str}`); "
      #end
    end


    def translate(stmt_list)
      stmt_list2 = optimize_print_stmts(stmt_list)
      return super(stmt_list2)
    end


  end #class
  Translator.register_class('perl', PerlTranslator)



end #module
