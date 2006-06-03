###
### $Rev$
### $Release$
### $Copyright$
###

require 'kwartz/converter'
require 'kwartz/translator'



module Kwartz



  ##
  ## directive handler for eRuby
  ##
  class ErubyHandler < Handler


    ERUBY_DIRECTIVE_PATTERN = /\A(\w+)(?:[:\s]\s*(.*))?\z/

    def directive_pattern
      return ERUBY_DIRECTIVE_PATTERN
    end


    ERUBY_MAPPING_PATTERN = /\A'([-:\w]+)'\s+(.*)\z/

    def mapping_pattern
      return ERUBY_MAPPING_PATTERN
    end


    ERUBY_DIRECTIVE_FORMAT = '%s: %s'

    def directive_format
      return ERUBY_DIRECTIVE_FORMAT
    end


    def handle(handler_arg)
      ret = super
      return ret if ret

      arg = handler_arg
      d_name = arg.directive_name
      d_arg  = arg.directive_arg
      d_str  = arg.directive_str
      #stag_info = arg.stag_info
      #etag_info = arg.etag_info
      #cont_stmts = arg.cont_stmts
      stmt_list = arg.stmt_list

      case d_name

      when :for, :For, :FOR, :list, :List, :LIST
        unless d_arg =~ /\A(\w+)(?:,\s*(\w+))?\s+in\s+(.*)\z/ || d_arg =~ /\A(\w+)(?:,(\w+))?\s*[:=]\s*(.*)\z/
          raise convert_error("#'{d_str}': invalid argument.", arg.stag_info.linenum)
        end
        loopvar = $1 ;  loopval = $2 ;  looplist = $3
        is_foreach = d_name == :for || d_name == :For || d_name == :FOR
        counter = d_name == :for || d_name == :list ? nil : "#{loopvar}_ctr"
        toggle  = d_name != :FOR && d_name != :LIST ? nil : "#{loopvar}_tgl"
        code = loopval ? "#{looplist}.each do |#{loopvar}, #{loopval}|" \
                       : "for #{loopvar} in #{looplist} do"
        stmts = []
        stmts << NativeStatement.new("#{counter} = 0") if counter
        stmts << NativeStatement.new(code, :foreach)
        stmts << NativeStatement.new("  #{counter} += 1") if counter
        stmts << NativeStatement.new("  #{toggle} = #{counter}%2==0 ? #{self.even} : #{self.odd}") if toggle
        if is_foreach
          stmt_list.concat(stmts)
          stmt_list << arg.stag_stmt
          stmt_list.concat(arg.cont_stmts)
          stmt_list << arg.etag_stmt
          stmt_list << NativeStatement.new("end", :foreach)
        else
          stmt_list << arg.stag_stmt
          stmt_list.concat(stmts)
          stmt_list.concat(arg.cont_stmts)
          stmt_list << NativeStatement.new("end", :foreach)
          stmt_list << arg.etag_stmt
        end

      when :while
        arg.wrap_element_with_native_stmt("while #{d_arg} do", "end", :while)
        #stmt_list << NativeStatement.new("while #{d_arg} do", :while)
        #stmt_list << arg.stag_stmt()
        #stmt_list.concat(arg.cont_stmts)
        #stmt_list << build_print_stmt(etag_info, nil, nil)
        #stmt_list << arg.etag_stmt()

      when :loop
        arg.wrap_content_with_native_stmt("while #{d_arg} do", "end", :while)
        #stmt_list << arg.stag_stmt()
        #stmt_list << NativeStatement.new("while #{d_arg} do", :while)
        #stmt_list.concat(arg.cont_stmts)
        #stmt_list << NativeStatement.new("end", :while)
        #stmt_list << arg.etag_stmt()

      when :set
        arg.wrap_element_with_native_stmt(d_arg, nil, :set)
        #stmt_list << NativeStatement.new(d_arg, :set)
        #stmt_list << arg.stag_stmt()
        #stmt_list.concat(arg.cont_stmts)
        #stmt_list << arg.etag_stmt()

      when :if
        arg.wrap_element_with_native_stmt("if #{d_arg} then", "end", :if)
        #stmt_list << NativeStatement.new("if #{d_arg} then", :if)
        #stmt_list << arg.stag_stmt()
        #stmt_list.concat(arg.cont_stmts)
        #stmt_list << arg.etag_stmt()
        #stmt_list << NativeStatement.new("end", :if)

      when :elsif, :else
        unless !stmt_list.empty?  \
               && (st=stmt_list[-1]).is_a?(NativeStatement)  \
               && (st.kind == :if || st.kind == :elseif)
          msg = "'#{d_str}': previous statement should be 'if' or 'elsif'."
          raise convert_error(msg, arg.stag_info.linenum)
        end
        arg.stmt_list.pop    # delete 'end'
        kind = d_name == :else ? :else : :elseif
        code = d_name == :else ? "else" : "elsif #{d_arg} then"
        arg.wrap_element_with_native_stmt(code, "end", kind)
        #stmt_list << NativeStatement.new(code, kind)
        #stmt_list << arg.stag_stmt()
        #stmt_list.concat(arg.cont_stmts)
        #stmt_list << arg.etag_stmt()
        #stmt_list << NativeStatement.new("end", kind)

      when :default, :Default, :DEFAULT
        error_if_empty_tag(arg.stag_info, arg.etag_info, d_name, d_arg)
        stmt_list << arg.stag_stmt()
        stmt_list << NativeStatement.new_without_newline("if (#{d_arg}) && !(#{d_arg}).to_s.empty? then", :if)
        flag_escape = d_name == :default ? nil : (d_name == :Default)
        stmt_list << PrintStatement.new([ NativeExpression.new(d_arg, flag_escape) ])
        stmt_list << NativeStatement.new_without_newline("else", :else)
        stmt_list.concat(arg.cont_stmts)
        stmt_list << NativeStatement.new_without_newline("end", :else)
        stmt_list << arg.etag_stmt()

      else
        return false

      end #case
      return true

    end #def


  end #class
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
