###
### $Rev$
### $Release$
### $Copyright$
###

require 'kwartz/converter'
require 'kwartz/translator'



module Kwartz



  ##
  ## directive handler for ERB
  ##
  class ErbHandler < Handler


    ERB_DIRECTIVE_PATTERN = /\A(\w+)(?:[:\s]\s*(.*))?\z/

    def directive_pattern
      return ERB_DIRECTIVE_PATTERN
    end


    ERB_MAPPING_PATTERN = /\A'([-:\w]+)'\s+(.*)\z/

    def mapping_pattern
      return ERB_MAPPING_PATTERN
    end


    ERB_MARKING_FORMAT = 'id: %s'

    def marking_format
      return ERB_MARKING_FORMAT
    end


    def handle(directive_name, directive_arg, directive_str, stag_info, etag_info, cont_stmts, attr_info, append_exprs, stmt_list)
      ret = super
      return ret if ret

      d_name = directive_name
      d_arg  = directive_arg
      d_str  = directive_str

      case directive_name

      when :for, :For, :FOR, :list, :List, :LIST
        unless d_arg =~ /\A(\w+)(?:,\s*(\w+))?\s+in\s+(.*)\z/ || d_arg =~ /\A(\w+)(?:,(\w+))?\s*[:=]\s*(.*)\z/
          raise convert_error("#'{d_str}': invalid argument.", stag_info.linenum)
        end
        loopvar = $1 ;  loopval = $2 ;  looplist = $3
        is_foreach = d_name == :for || d_name == :For || d_name == :FOR
        counter = d_name == :for || d_name == :list ? nil : "#{loopvar}_ctr"
        toggle  = d_name != :FOR && d_name != :LIST ? nil : "#{loopvar}_tgl"
        stmt_list  <<  build_print_stmt(stag_info, attr_info, append_exprs)   if !is_foreach
        stmt_list  <<  NativeStatement.new("#{counter} = 0") if counter
        if loopval
          stmt_list << NativeStatement.new("#{looplist}.each do |#{loopvar}, #{loopval}|", :foreach)
        else
          stmt_list << NativeStatement.new("for #{loopvar} in #{looplist} do", :foreach)
        end
        stmt_list  <<  NativeStatement.new("  #{counter} += 1") if counter
        stmt_list  <<  NativeStatement.new("  #{toggle} = #{counter}%2==0 ? #{self.even} : #{self.odd}") if toggle
        stmt_list  <<  build_print_stmt(stag_info, attr_info, append_exprs)   if is_foreach
        stmt_list.concat(cont_stmts)
        stmt_list  <<  build_print_stmt(etag_info, nil, nil)                  if is_foreach
        stmt_list  <<  NativeStatement.new("end", :foreach)
        stmt_list  <<  build_print_stmt(etag_info, nil, nil)                  if !is_foreach

      when :while, :loop
        is_while = d_name == :while
        stmt_list << build_print_stmt(stag_info, attr_info, append_exprs)   if !is_while
        stmt_list << NativeStatement.new("while #{d_arg} do", :while)
        stmt_list << build_print_stmt(stag_info, attr_info, append_exprs)   if is_while
        stmt_list.concat(cont_stmts)
        stmt_list << build_print_stmt(etag_info, nil, nil)                  if is_while
        stmt_list << NativeStatement.new("end", :while)
        stmt_list << build_print_stmt(etag_info, nil, nil)                  if !is_while

      when :set
        stmt_list << NativeStatement.new(d_arg, :set)
        stmt_list << build_print_stmt(stag_info, attr_info, append_exprs)
        stmt_list.concat(cont_stmts)
        stmt_list << build_print_stmt(etag_info, nil, nil)

      when :if
        stmt_list << NativeStatement.new("if #{d_arg} then", :if)
        stmt_list << build_print_stmt(stag_info, attr_info, append_exprs)
        stmt_list.concat(cont_stmts)
        stmt_list << build_print_stmt(etag_info, nil, nil)
        stmt_list << NativeStatement.new("end", :if)

      when :elsif, :else
        unless !stmt_list.empty? && (st=stmt_list[-1]).is_a?(NativeStatement) && (st.kind == :if || st.kind == :elseif)
          raise convert_error("'#{d_str}': previous statement should be 'if' or 'elsif'.", stag_info.linenum)
        end
        stmt_list.pop    # delete 'end'
        if d_name == :else
          kind = :else
          stmt_list << NativeStatement.new("else", :else)
        else
          kind = :elseif
          stmt_list << NativeStatement.new("elsif #{d_arg} then", :elseif)
        end
        stmt_list << build_print_stmt(stag_info, attr_info, append_exprs)
        stmt_list.concat(cont_stmts)
        stmt_list << build_print_stmt(etag_info, nil, nil)
        stmt_list << NativeStatement.new("end", kind)

      when :default, :Default, :DEFAULT
        error_if_empty_tag(stag_info, etag_info, d_name, d_arg)
        stmt_list << build_print_stmt(stag_info, attr_info, append_exprs)
        stmt_list << NativeStatement.new_without_newline("if #{d_arg} && #{d_arg}.empty? then", :if)
        flag_escape = d_name == :default ? nil : (d_name == :Default)
        stmt_list << PrintStatement.new([ NativeExpression.new(d_arg, flag_escape) ])
        stmt_list << NativeStatement.new_without_newline("else", :else)
        stmt_list.concat(cont_stmts)
        stmt_list << NativeStatement.new_without_newline("end", :else)
        stmt_list << build_print_stmt(etag_info, nil, nil)

      else
        return false

      end #case
      return true

    end #def


  end #class
  Handler.register_class('erb', ErbHandler)



  ##
  ## translator for ERB
  ##
  class ErbTranslator < BaseTranslator


    ERB_EMBED_PATTERNS = [
      '<% ',    ' %>',        # statement
      '<%= ',   ' %>',        # expression
      '<%=h ',  ' %>',        # escaped expression
    ]


    def initialize(properties={})
      super(ERB_EMBED_PATTERNS, properties)
    end


  end #class
  Translator.register_class('erb', ErbTranslator)



end #module
