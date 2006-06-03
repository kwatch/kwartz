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
  ## directive handler for ePerl
  ##
  class EperlHandler < Handler


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


    def handle(directive_name, directive_arg, directive_str, stag_info, etag_info, cont_stmts, attr_info, append_exprs, stmt_list)
      ret = super
      return ret if ret

      d_name = directive_name
      d_arg  = directive_arg
      d_str  = directive_str

      stag_stmt = build_print_stmt(stag_info, attr_info, append_exprs)
      etag_stmt = build_print_stmt(etag_info, nil, nil)

      case directive_name

      when :foreach, :Foreach, :FOREACH, :list, :List, :LIST
        is_foreach = d_name == :foreach || d_name == :Foreach || d_name == :FOREACH
        unless d_arg =~ /\A(\$\w+)(?:,\s*(\$\w+))?\s+in\s+(.*)\z/
          raise convert_error("'#{d_str}': invalid argument.", stag_info.linenum)
        end
        loopvar = $1 ;  loopval = $2 ;  looplist = $3
        counter = d_name == :foreach || d_name == :list ? nil : "#{loopvar}_ctr"
        toggle  = d_name != :FOREACH && d_name != :LIST ? nil : "#{loopvar}_tgl"
        stmt_list  <<  stag_stmt   if !is_foreach
        stmt_list  <<  NativeStatement.new("my #{counter} = 0;") if counter
        if loopval
          stmt_list << NativeStatement.new("foreach my #{loopvar} (keys #{looplist}) {", :foreach)
          stmt_list << NativeStatement.new("  my #{loopval} = #{looplist.sub(/\A%/,'$')}{#{loopvar}};")
        else
          stmt_list << NativeStatement.new("foreach my #{loopvar} (#{looplist}) {", :foreach)
        end
        stmt_list  <<  NativeStatement.new("  #{counter}++;") if counter
        stmt_list  <<  NativeStatement.new("  my #{toggle} = #{counter}%2==0 ? #{self.even} : #{self.odd};") if toggle
        stmt_list  <<  stag_stmt   if is_foreach
        stmt_list.concat(cont_stmts)
        stmt_list  <<  etag_stmt   if is_foreach
        stmt_list  <<  NativeStatement.new("}", :foreach)
        stmt_list  <<  etag_stmt   if !is_foreach

      when :while
        wrap_element(stmt_list, stag_stmt, etag_stmt, cont_stmts,
                     "while (#{d_arg}) {", "}", :while)
        #stmt_list << NativeStatement.new("while (#{d_arg}) {", :while)
        #stmt_list << stag_stmt
        #stmt_list.concat(cont_stmts)
        #stmt_list << etag_stmt
        #stmt_list << NativeStatement.new("}", :while)

      when :loop
        wrap_content(stmt_list, stag_stmt, etag_stmt, cont_stmts,
                     "while (#{d_arg}) {", "}", :while)
        #stmt_list << stag_stmt
        #stmt_list << NativeStatement.new("while (#{d_arg}) {", :while)
        #stmt_list.concat(cont_stmts)
        #stmt_list << NativeStatement.new("}", :while)
        #stmt_list << etag_stmt

      when :set
        wrap_element(stmt_list, stag_stmt, etag_stmt, cont_stmts,
                     "#{d_arg};", nil, :set)
        #stmt_list << NativeStatement.new("#{d_arg};", :set)
        #stmt_list << stag_stmt
        #stmt_list.concat(cont_stmts)
        #stmt_list << etag_stmt

      when :if
        wrap_element(stmt_list, stag_stmt, etag_stmt, cont_stmts,
                     "if (#{d_arg}) {", "}", :if)
        #stmt_list << NativeStatement.new("if (#{d_arg}) {", :if)
        #stmt_list << stag_stmt
        #stmt_list.concat(cont_stmts)
        #stmt_list << etag_stmt
        #stmt_list << NativeStatement.new("}", :if)

      when :elsif, :else
        unless !stmt_list.empty? && (st=stmt_list[-1]).is_a?(NativeStatement) && (st.kind == :if || st.kind == :elseif)
          raise convert_error("'#{d_str}': previous statement should be 'if' or 'elsif'.", stag_info.linenum)
        end
        stmt_list.pop    # delete 'end'
        kind = d_name == :else ? :else : :elseif
        code = d_name == :else ? "} else {" : "} elsif (#{d_arg}) {"
        wrap_element(stmt_list, stag_stmt, etag_stmt, cont_stmts,
                     code, "}", kind)
        #stmt_list << NativeStatement.new(code, kind)
        #stmt_list << stag_stmt
        #stmt_list.concat(cont_stmts)
        #stmt_list << etag_stmt
        #stmt_list << NativeStatement.new("}", kind)

      when :default, :Default, :DEFAULT
        error_if_empty_tag(stag_info, etag_info, d_name, d_arg)
        stmt_list << stag_stmt
        stmt_list << NativeStatement.new_without_newline("if (#{d_arg}) {", :if)
        flag_escape = d_name == :default ? nil : (d_name == :Default)
        stmt_list << PrintStatement.new([ NativeExpression.new(d_arg, flag_escape) ])
        stmt_list << NativeStatement.new_without_newline("} else {", :else)
        stmt_list.concat(cont_stmts)
        stmt_list << NativeStatement.new_without_newline("}", :else)
        stmt_list << etag_stmt

      else
        return false

      end #case
      return true

    end #def


  end #class
  Handler.register_class('eperl', EperlHandler)



  ##
  ## translator for ePerl
  ##
  class EperlTranslator < BaseTranslator


    EPERL_EMBED_PATTERNS = [
      '<? ',  ' !>',                 # statement
      '<?= ', ' !>',                 # expression
      '<?= encode_entities(', ') !>' # escaped expression
    ]


    def initialize(properties={})
      super(EPERL_EMBED_PATTERNS, properties)
    end


  end
  Translator.register_class('eperl', EperlTranslator)



end #module
