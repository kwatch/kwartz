###
### $Rev$
### $Release$
### $Copyright$
###

require 'kwartz/converter'
require 'kwartz/translator'



module Kwartz



  ##
  ## directive handler for Ruby
  ##
  class RubyHandler < Handler


    RUBY_DIRECTIVE_PATTERN = /\A(\w+)(?:[:\s]\s*(.*))?\z/

    def directive_pattern
      return RUBY_DIRECTIVE_PATTERN
    end


    RUBY_MAPPING_PATTERN = /\A'([-:\w]+)'\s+(.*)\z/

    def mapping_pattern
      return RUBY_MAPPING_PATTERN
    end


    RUBY_DIRECTIVE_FORMAT = '%s: %s'

    def directive_format
      return RUBY_DIRECTIVE_FORMAT
    end


    def handle(stmt_list, handler_arg)
      ret = super
      return ret if ret

      arg = handler_arg
      d_name = arg.directive_name
      d_arg  = arg.directive_arg
      d_str  = arg.directive_str
      #stag_info = arg.stag_info
      #etag_info = arg.etag_info
      #cont_stmts = arg.cont_stmts

      case d_name

      when :for, :For, :FOR, :list, :List, :LIST
        unless d_arg =~ /\A(\w+)(?:,\s*(\w+))?\s+in\s+(.*)\z/  \
            || d_arg =~ /\A(\w+)(?:,(\w+))?\s*[:=]\s*(.*)\z/
          raise convert_error("'#{d_str}': invalid argument.", arg.stag_info.linenum)
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
          wrap_element_with_native_stmt(stmt_list, arg, code, "end", :foreach)
        else
          wrap_content_with_native_stmt(stmt_list, arg, code, "end", :foreach)
        end

      when :while
        wrap_element_with_native_stmt(stmt_list, arg, "while #{d_arg} do", "end", :while)
        #stmt_list << NativeStatement.new("while #{d_arg} do", :while)
        #stmt_list << stag_stmt(arg)
        #stmt_list.concat(arg.cont_stmts)
        #stmt_list << etag_stmt(arg)
        #stmt_list << NativeStatement.new("end", :while)

      when :loop
        error_if_empty_tag(arg)
        wrap_content_with_native_stmt(stmt_list, arg, "while #{d_arg} do", "end", :while)
        #stmt_list << stag_stmt(arg)
        #stmt_list << NativeStatement.new("while #{d_arg} do", :while)
        #stmt_list.concat(arg.cont_stmts)
        #stmt_list << NativeStatement.new("end", :while)
        #stmt_list << etag_stmt(arg)

      when :set
        wrap_element_with_native_stmt(stmt_list, arg, d_arg, nil, :set)
        #stmt_list << NativeStatement.new(d_arg, :set)
        #stmt_list << stag_stmt(arg)
        #stmt_list.concat(arg.cont_stmts)
        #stmt_list << etag_stmt(arg)

      when :if
        wrap_element_with_native_stmt(stmt_list, arg, "if #{d_arg} then", "end", :if)
        #stmt_list << NativeStatement.new("if #{d_arg} then", :if)
        #stmt_list << stag_stmt(arg)
        #stmt_list.concat(arg.cont_stmts)
        #stmt_list << etag_stmt(arg)
        #stmt_list << NativeStatement.new("end", :if)

      when :elsif, :else
        error_when_last_stmt_is_not_if(stmt_list, arg)
        stmt_list.pop    # delete 'end'
        kind = d_name == :else ? :else : :elseif
        code = d_name == :else ? "else" : "elsif #{d_arg} then"
        wrap_element_with_native_stmt(stmt_list, arg, code, "end", kind)
        #stmt_list << NativeStatement.new(code, kind)
        #stmt_list << stag_stmt(arg)
        #stmt_list.concat(arg.cont_stmts)
        #stmt_list << etag_stmt(arg)
        #stmt_list << NativeStatement.new("end", kind)

      when :default, :Default, :DEFAULT
        error_if_empty_tag(arg)
        expr_code = d_arg
        flag_escape = d_name == :default ? nil : (d_name == :Default)
        add_native_expr_with_default(stmt_list, arg, expr_code, flag_escape,
                                     "if (#{d_arg}) && !(#{d_arg}).to_s.empty? then",
                                     "else", "end")
        #stmt_list << stag_stmt(arg)
        #stmt_list << NativeStatement.new_without_newline("if (#{d_arg}) && !(#{d_arg}).to_s.empty? then", :if)
        #flag_escape = d_name == :default ? nil : (d_name == :Default)
        #stmt_list << PrintStatement.new([ NativeExpression.new(d_arg, flag_escape) ])
        #stmt_list << NativeStatement.new_without_newline("else", :else)
        #stmt_list.concat(arg.cont_stmts)
        #stmt_list << NativeStatement.new_without_newline("end", :else)
        #stmt_list << etag_stmt(arg)

      else
        return false

      end #case
      return true

    end #def


  end #class
  Handler.register_class('ruby', RubyHandler)



  ##
  ## translator for eRuby
  ##
  class RubyTranslator < BaseTranslator


    def initialize(properties={})
      escapefunc = properties[:escapefunc] || 'ERB::Util.h'
      marks = ['', '', '_buf << (', ').to_s; ', "_buf << #{escapefunc}(", '); ']
      super(marks, properties)
      @header = '_buf = ""; '  unless @header == false
      @footer = '; _buf' + @nl   unless @footer == false
    end


    def translate_string(str)
      str.gsub!(/['\\]/, '\\\\\1')
      @sb << "_buf << '#{str}'; "
    end


#    def translate_text_expr(expr)
#      @sb << expr.text
#    end


  end #class
  Translator.register_class('ruby', RubyTranslator)



end #module
