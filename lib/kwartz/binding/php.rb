###
### $Rev$
### $Release$
### $Copyright$
###

require 'kwartz/assert'
require 'kwartz/converter'
require 'kwartz/translator'



module Kwartz



  module PhpExpressionParser


    def parse_expr_str(expr_str, linenum)
      case expr_str
      when /\A(\w+)\z/             # variable
        expr = '$' + $1
      when /\A(\w+)\.(\w+)\z/      # object.property
        expr = "$#{$1}->#{$2}"
      when /\A(\w+)\[('.*?'|".*?"|:\w+)\]\z/   # hash
        key = $2[0] == ?: ? "'#{$2[1..-1]}'" : $2
        expr = "$#{$1}[#{key}]"
      when /\A(\w+)\[(\w+)\]\z/    # array or hash
        begin
          expr = "$#{$1}[#{Integer($2)}]"
        rescue
          expr = "$#{$1}[$#{$2}]"
        end
      else
        raise convert_error("'#{expr_str}': invalid expression.", linenum)
      end
      return expr
    end


    def parse_expr_str!(expr_str)
      begin
        return parse_expr_str(expr_str, 0)
      rescue
        return expr_str
      end
    end


  end



  ##
  ## directive handler for PHP
  ##
  class PhpHandler < Handler
    include PhpExpressionParser


    PHP_DIRECTIVE_PATTERN = /\A(\w+)(?:\s*\(\s*(.*)\))?\z/

    def directive_pattern
      return PHP_DIRECTIVE_PATTERN
    end


    PHP_MAPPING_PATTERN = /\A'([-:\w]+)',\s*(.*)\z/

    def mapping_pattern
      return PHP_MAPPING_PATTERN
    end


    PHP_DIRECTIVE_FORMAT = '%s(%s)'

    def directive_format
      return PHP_DIRECTIVE_FORMAT
    end


    def handle(directive, elem_info, stmt_list)
      ret = super
      return ret if ret

      d_name = directive.name
      d_arg  = directive.arg
      d_str  = directive.str
      e = elem_info

      case d_name

      when :foreach, :Foreach, :FOREACH, :list, :List, :LIST
        is_foreach = d_name == :foreach || d_name == :Foreach || d_name == :FOREACH
        unless d_arg =~ /\A.*\s+as\s+(\$\w+)(?:\s*=>\s*\$\w+)?\z/
          raise convert_error("'#{d_str}': invalid argument.", elem_info.stag_info.linenum)
        end
        loopvar = $1
        counter = d_name == :foreach || d_name == :list ? nil : "#{loopvar}_ctr"
        toggle  = d_name != :FOREACH && d_name != :LIST ? nil : "#{loopvar}_tgl"
        code = []
        code << "#{counter} = 0;"            if counter
        code << "foreach (#{d_arg}) {"
        code << "  #{counter}++;"            if counter
        code << "  #{toggle} = #{counter}%2==0 ? #{@even} : #{@odd};" if toggle
        if is_foreach
          wrap_element_with_native_stmt(elem_info, stmt_list, code, "}", :foeach)
        else
          wrap_content_with_native_stmt(elem_info, stmt_list, code, "}", :foeach)
        end
        #stmt_list << stag_stmt(elem_info)   if !is_foreach
        #stmt_list << NativeStatement.new("#{counter} = 0;") if counter
        #stmt_list << NativeStatement.new("foreach (#{d_arg}) {", :foreach)
        #stmt_list << NativeStatement.new("  #{counter}++;") if counter
        #stmt_list << NativeStatement.new("  #{toggle} = #{counter}%2==0 ? #{self.even} : #{self.odd};") if toggle
        #stmt_list << stag_stmt(elem_info)   if is_foreach
        #stmt_list.concat(elem_info.cont_stmts)
        #stmt_list << etag_stmt(elem_info)   if is_foreach
        #stmt_list << NativeStatement.new("}", :foreach)
        #stmt_list << etag_stmt(elem_info)   if !is_foreach

      when :while
        wrap_element_with_native_stmt(elem_info, stmt_list, "while (#{d_arg}) {", "}", :while)
        #stmt_list << NativeStatement.new("while (#{d_arg}) {", :while)
        #stmt_list << stag_stmt
        #stmt_list.concat(cont_stmts)
        #stmt_list << etag_stmt
        #stmt_list << NativeStatement.new("}", :while)

      when :loop
        error_if_empty_tag(elem_info, d_str)
        wrap_content_with_native_stmt(elem_info, stmt_list, "while (#{d_arg}) {", "}", :while)
        #stmt_list << stag_stmt
        #stmt_list << NativeStatement.new("while (#{d_arg}) {", :while)
        #stmt_list.concat(cont_stmts)
        #stmt_list << NativeStatement.new("}", :while)
        #stmt_list << etag_stmt

      when :set
        wrap_element_with_native_stmt(elem_info, stmt_list, "#{d_arg};", nil, :set)
        #stmt_list << NativeStatement.new("#{d_arg};", :set)
        #stmt_list << stag_stmt
        #stmt_list.concat(cont_stmts)
        #stmt_list << etag_stmt

      when :if
        wrap_element_with_native_stmt(elem_info, stmt_list, "if (#{d_arg}) {", "}", :if)
        #stmt_list << NativeStatement.new("if (#{d_arg}) {", :if)
        #stmt_list << stag_stmt
        #stmt_list.concat(cont_stmts)
        #stmt_list << etag_stmt
        #stmt_list << NativeStatement.new("}", :if)

      when :elseif, :else
        error_when_last_stmt_is_not_if(elem_info, d_str, stmt_list)
        stmt_list.pop    # delete '}'
        kind = d_name == :else ? :else : :elseif
        code = d_name == :else ? "} else {" : "} elseif (#{d_arg}) {"
        wrap_element_with_native_stmt(elem_info, stmt_list, code, "}", kind)
        #stmt_list << NativeStatement.new(code, kind)
        #stmt_list << stag_stmt
        #stmt_list.concat(cont_stmts)
        #stmt_list << etag_stmt
        #stmt_list << NativeStatement.new("}", kind)

      when :default, :Default, :DEFAULT
        error_if_empty_tag(elem_info, d_str)
        expr_str = directive.dattr == 'id' ? parse_expr_str(d_arg, e.stag_info.linenum) : d_arg
        flag_escape = d_name == :default ? nil : (d_name == :Default)
        add_native_expr_with_default(elem_info, stmt_list, expr_str, flag_escape,
                                     "if (#{expr_str}) {", "} else {", "}")
        #stmt_list << stag_stmt(elem_info)
        #stmt_list << NativeStatement.new_without_newline("if (#{d_arg}) {", :if)
        #flag_escape = d_name == :default ? nil : (d_name == :Default)
        #stmt_list << PrintStatement.new([ NativeExpression.new(d_arg, flag_escape) ])
        #stmt_list << NativeStatement.new_without_newline("} else {", :else)
        #stmt_list.concat(elem_info.cont_stmts)
        #stmt_list << NativeStatement.new_without_newline("}", :else)
        #stmt_list << etag_stmt(elem_info)

      else
        return false

      end #case
      return true

    end #def


  end #class
  Handler.register_class('php', PhpHandler)



  ##
  ## translator for php
  ##
  class PhpTranslator < BaseTranslator
    include PhpExpressionParser


    PHP_EMBED_PATTERNS = [
      '<?php ', ' ?>',                          # statement
      '<?php echo ', '; ?>',                    # expression
      '<?php echo htmlspecialchars(', '); ?>',  # escaped expression
    ]


    def initialize(properties={})
      super(PHP_EMBED_PATTERNS, properties)
    end


    def translate_string(str)
      str.gsub!(/<\?xml/, '<<?php ?>?xml')
      super(str)
    end


  end
  Translator.register_class('php', PhpTranslator)



end #module
