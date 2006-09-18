###
### $Rev$
### $Release$
### $Copyright$
###


module Kwartz


  ##
  ## generate compiled code.
  ## see defun() method for usage.
  ##
  module Defun

    module_function


    ##
    ## generate compiled code
    ##
    ## ex.
    ##   args = %w[-l eruby -p ex.plogic ex.html]
    ##   eruby_src = Kwartz::Main.new(args).execute()
    ##   properties = { :trim_mode=>'>' }
    ##   code = Kwartz::Defun.defun('ex', eruby_src, 'eruby', properties)
    ##   print code
    ##
    ## command-line properties:
    ##   --module=name   : module name (default 'View')
    ##   --method=name   : method name (default 'expand_xxx')
    ##
    def defun(basename, output, lang, properties={})
      lang_code = compile_into_lang_code(output, lang, properties)
      s = build_defun_code(basename, lang_code, lang, properties)
      return s
    end


    def compile_into_lang_code(output, lang, properties)
      case lang
      when 'ruby'
        return output
      when 'eruby', 'rails'
        require 'erb'
        trim_mode = properties[:trim_mode] || (lang == 'eruby' ? 1 : '-')
        return ERB.new(output, nil, trim_mode).src
      when 'erubis'
        require 'erubis'
        return Erubis::Eruby.new(nil, properties).convert(output)
      when 'pierubis'
        require 'erubis'
        return Erubis::PI::Eruby.new(nil, properties).convert(output)
      when 'php'
        return output
      else
        raise "'#{lang}': not supported language."
      end
    end


    def build_defun_code(basename, code, lang, properties)
      case lang
      when 'ruby', 'eruby', 'rails', 'erubis', 'pierubis'
        return build_ruby_code(basename, code, properties)
      when 'php'
        return build_php_code(basename, code, properties)
      else
        raise "'#{lang}': not supported language."
      end
    end


    def build_ruby_code(basename, ruby_code, properties)
      basename = basename.gsub(/[^\w]/, '_')
      module_name = properties.key?(:module) ? properties[:module] : 'View'
      method_verb = properties[:verb] || 'expand'
      method_name = properties[:method] || "#{method_verb}_#{basename}"
      s = ''
      s << "module #{module_name}\n" if module_name
      s << "\n"
      s << "  (@@proc_table ||= {})['#{basename}'] = proc do\n"
      s << ruby_code << (!ruby_code.empty? && ruby_code[-1] != ?\n ? "\n" : '')
      s << "  end#proc\n"
      s << "\n"
      s << "  module_function\n" if module_name
      s << "  def #{method_name}(context={})\n"
      s << "    if context.is_a?(Hash)\n"
      s << "      hash = context\n"
      s << "      context = Object.new\n"
      s << "      hash.each { |key, val| context.instance_variable_set(\"@\#{key}\", val) }\n"
      s << "    end\n"
      s << "    proc_obj = @@proc_table['#{basename}']\n"
      s << "    context.instance_eval(&proc_obj)\n"
      s << "  end\n"
      s << "\n"
      s << "end\n" if module_name
      return s
    end


    def build_php_code(basename, php_code, properties)
      basename = basename.gsub(/[^\w]/, '_')
      s = <<END
<?php
function print_view_#{basename}($context) {
    explode($context);
?>#{php_code}<?php
}
function expand_view_#{basename}($context) {
    ob_start();
    print_view_#{basename}($context);
    $output = ob_get_clean();
    ob_end_clean();
    return $output;
}
?>
END
      return s
    end


  end

end
