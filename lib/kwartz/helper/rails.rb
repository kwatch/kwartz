###
### $Rev$
### $Release$
### $Copyright$
###


require 'kwartz'
require 'kwartz/binding/ruby'
require 'kwartz/binding/eruby'
require 'kwartz/binding/rails'
require 'kwartz/binding/erubis'
require 'kwartz/binding/pierubis'
require 'kwartz/util'
require 'erb'


module Kwartz

  module Helper

    ###
    ### helper class to use Kwartz in Rails
    ###
    ### How to use Kwartz in Rails:
    ###
    ### 1. add the folliwng code in your 'app/controllers/application.rb'.
    ###      --------------------
    ###      require 'kwartz/helper/rails'
    ###      ActionView::Base.register_template_handler('html', Kwartz::Helper::RailsTemplate)
    ###      #Kwartz::Helper::RailsTemplate.pdata_suffix  = '.html'
    ###      #Kwartz::Helper::RailsTemplate.plogic_suffix = '.plogic'
    ###      #Kwartz::Helper::RailsTemplate.default_properties = { :escape=>true }
    ###      #Kwartz::Helper::RailsTemplate.debug = false
    ###      --------------------
    ### 2. restart web server.
    ### 3. put template files '*.html' and '*.plogic' in 'app/views/xxx'.
    ###    layout files ('app/views/layouts/xxx.{html,plogic}') is also available.
    ###
    class RailsTemplate

      @@default_properties = { }

      def self.default_properties
        return @@default_properties
      end

      def self.default_properties=(hash)
        @@default_properties = hash
      end


      @@pdata_suffix = '.html'

      def self.pdata_suffix
        return @@pdata_suffix
      end

      def self.pdata_suffix=(suffix)
        @@pdata_suffix = suffix
      end


      @@plogic_suffix = '.plogic'

      def self.plogic_suffix
        return @@plogic_suffix
      end

      def self.plogic_suffix=(suffix)
        @@plogic_suffix = suffix
      end


      @@lang = 'rails'  # or 'eruby', 'ruby', 'erubis', 'pierubis'

      def self.lang
        return @@lang
      end

      def self.lang=(lang)
        case lang
        when 'ruby', 'eruby', 'erubis', 'pierubis'
          @@lang = lang
        else
          raise "'#{lang}': invalid language name."
        end
      end


      @@use_cache = nil

      def self.use_cache
        return @@use_cache
      end

      def self.use_cache=(flag)
        @@use_cache = flag
      end


      @@cache_table = {}

      def self.add_cache(_ruby_code, _filename)
        _proc_obj = eval "proc do #{_ruby_code} end", binding(), _filename
        @@cache_table[_filename] = _proc_obj
        return _proc_obj
      end

      def self.get_cache(filename)
        return @@cache_table[filename]
      end


      @@debug = true

      def self.debug
        return @@debug
      end

      def self.debug=(flag)
        @@debug = flag
      end


      def initialize(view)
        @view = view
      end


      def render(template, assigns)

        #$stderr.puts "*** debug: render() called."
        #
        #$stderr.puts "*** debug: instance_variables=#{instance_variables.inspect}" #=> [@views]
        #c = @view.controller
        #$stderr.puts "*** debug: @view.controller.instance_variables=#{c.instance_variables.inspect}"
        #$stderr.puts "*** debug: @view.controller.action_name=#{c.action_name.inspect}"
        #$stderr.puts "*** debug: @view.controller.render_layout_basename=#{c.render_layout_basename.inspect}"
        #$stderr.puts "*** debug: @view.controller.render_template_basename=#{c.render_template_basename.inspect}"
        #require 'pp'
        #c = @view.controller
        #$stderr.puts "*** debug: @view.controller.instance_variable_get('@template')="
        #PP.pp(c.instance_variable_get('@template'), $stderr)
        #$stderr.puts "*** debug: @view.controller.methods="
        #PP.pp((c.methods - Object.new.methods).sort, $stderr)
        #$stderr.puts "*** debug: @view.controller.class.methods="
        #PP.pp((c.class.methods - Class.methods).sort, $stderr)

        ## return if @content_for_layout is set
        template_ = @view.controller.instance_variable_get("@template")
        content_for_layout_ = template_.instance_variable_get("@content_for_layout")
        return content_for_layout_ if content_for_layout_

        ## template basename and layout basename
        c = @view.controller
        template_root = c.template_root
        #template_basename = "#{template_root}/#{c.controller_name}/#{c.action_name}"
        #layout_basename   = "#{template_root}/layouts/#{c.controller_name}"
        template_basename = "#{template_root}/#{c.render_template_basename}"
        layout_basename   = "#{template_root}/#{c.render_layout_basename}"

        ## check timestamps
        convert_flag = true
        cache_filename = template_basename + '.cache'
        if use_cache? && test(?f, cache_filename)
          filenames = [
            template_basename + @@pdata_suffix,
            template_basename + @@plogic_suffix,
            layout_basename   + @@pdata_suffix,
            layout_basename   + @@plogic_suffix,
          ]
          mtime = File.mtime(cache_filename)
          convert_flag = filenames.any? { |filename|
            test(?f, filename) && File.mtime(filename) > mtime
          }
        end

        ## convert templates into ruby code, or get cached object
        logger = @view.controller.logger
        msgstr  = "template='#{template_basename}#{@@pdata_suffix}'"    if logger
        logname = "*** #{self.class.name}"                              if logger
        if convert_flag
          logger.info "#{logname}: convert template file: #{msgstr}"    if logger
          ruby_code = convert(template, template_basename, layout_basename)
          File.open(cache_filename, 'w') { |f| f.write(ruby_code) }  # write cache
          proc_obj = self.class.add_cache(ruby_code, cache_filename)
        elsif (proc_obj = self.class.get_cache(cache_filename)).nil?
          logger.info "#{logname}: read cache file: #{msgstr}"          if logger
          ruby_code = File.read(cache_filename)
          proc_obj = self.class.add_cache(ruby_code, cache_filename)
        else
          logger.info "#{logname}: reuse cached proc object: #{msgstr}" if logger
        end

        ## use @view as context object
        @view.__send__(:evaluate_assigns)
        #or @view.instance_eval("evaluate_assigns()")
        context = @view

        ## evaluate ruby code with context object
        if assigns && !assigns.empty?
          #return _evaluate_string(ruby_code, context, assigns)
          return evaluate_proc(proc_obj, context, assigns)
        else
          #return context.instance_eval(ruby_code)
          return context.instance_eval(&proc_obj)
        end
      end


      private


      def use_cache?
        if @@use_cache.nil?
          return ENV['RAILS_ENV'] != 'development' # or == 'production'
        else
          return @@use_cache;
        end
      end


      def parse_config_file(config_filename)
        config = {}
        return config unless test(?f, config_filename)
        str = File.read(config_filename)
        ydoc = YAML.load(Kwartz::Util.untabify(str))
        template_dir = File.dirname(config_filename)
        ['import_pdata', 'import_plogic'].each do |key|
          val = ydoc[key]
          next if val.nil?
          val = [ val ] if val.is_a?(String)
          list = []
          val.each do |item|
            if item.is_a?(Hash)
              hash = {}
              item.each do |k, v| hash[k.intern] = v end
            elsif item =~ /<([\w,]*)>\z/
              filename = $`
              names = $1.split(/,/)
              hash = { :filename=>filename, :patterns=>(names.empty? ? nil : names) }
            else
              hash = { :filename=>item }
            end
            hash[:filename] = template_dir + '/' + hash[:filename] if hash[:filename]
            list << hash
          end
          config[key.intern] = list
        end
        return config
      end


      def convert(template, template_basename, layout_basename)

        ## filenames
        template_pdata_filename  = template_basename + @@pdata_suffix
        template_plogic_filename = template_basename + @@plogic_suffix
        layout_pdata_filename    = layout_basename + @@pdata_suffix
        layout_plogic_filename   = layout_basename + @@plogic_suffix

        ## config file
        config_filename = template_basename + '.cfg.yaml'
        if test(?f, config_filename)
          config = parse_config_file(config_filename)
        else
          config = {}
        end

        ## presentation logic files
        rulesets = []
        properties = @@default_properties
        parser = Kwartz::CssStyleParser.new(properties)
        config[:import_plogic].each do |hash|
          filename = hash[:filename]
          patterns = hash[:patterns]
          tmp_rulesets = parser.parse(File.read(filename), filename)
          if patterns
            regexp_list = patterns.collect { |pattern| Kwartz::Util.pattern_to_regexp(pattern) }
            tmp_rulesets = tmp_rulesets.select { |ruleset|
              regexp_list.any? { |regexp| regexp =~ ruleset.name }
            }
          end
          rulesets += tmp_rulesets
        end if config[:import_plogic]
        [layout_plogic_filename, template_plogic_filename].each do |filename|
          rulesets += parser.parse(File.read(filename), filename) if test(?f, filename)
        end

        ## converter
        handler = Kwartz::Handler.get_class(@@lang).new(rulesets, properties)
        converter = Kwartz::TextConverter.new(handler, properties)

        ## presentation data files
        pdata = template
        config[:import_pdata].each do |hash|
          filename = hash[:filename]
          patterns = hash[:patterns]
          tmp_handler   = Kwartz::Handler.get_class(@@lang).new(rulesets, properties)
          tmp_converter = Kwartz::TextConverter.new(tmp_handler, properties)
          tmp_converter.convert(File.read(filename), filename)
          handler._import_element_info_from_handler(tmp_handler, patterns)
        end if config[:import_pdata]
        if test(?f, layout_pdata_filename)
          converter.convert(pdata, template_pdata_filename)
          layout_pdata = File.read(layout_pdata_filename)
          stmts = converter.convert(layout_pdata, layout_pdata_filename)
        else
          stmts = converter.convert(pdata, template_pdata_filename)
        end

        ## translate statements into ruby code
        translator = Kwartz::Translator.get_class(@@lang).new(properties)
        code = translator.translate(stmts)

        ## write cache
        cache_filename = template_basename + '.cache'
        case @@lang
        when 'rails'
          trim_mode = ActionView::Base.erb_trim_mode
          ruby_code = ERB.new(code, nil, trim_mode).src
        when 'eruby'
          trim_mode = 1
          ruby_code = ERB.new(code, nil, trim_mode).src
        when 'ruby'
          ruby_code = code
        when 'erubis'
          require 'erubis'
          ruby_code = Erubis::Eruby.new().convert(code)
        when 'pierubis'
          require 'erubis'
          ruby_code = Erubis::PI::Eruby.new().convert(code)
        else
          internal_error
        end
        File.open(cache_filename, 'w') { |f| f.write(ruby_code) }

        ## debug code
        translator.extend(Kwartz::NoTextEnhancer)
        debug_code = translator.translate(stmts)
        debug_filename = template_basename + '.debug'
        File.open(debug_filename, 'w') { |f| f.write(debug_code) }

        return ruby_code
      end

      def _localvar_code(localvars)
        list = localvars.collect { |name| "#{name} = localvars[#{name.inspect}]\n" }
        code = list.join()
        return code
      end

      def evaluate_proc(_proc_obj, _context, _localvars)
        eval(_localvar_code(_localvars))
        _context.instance_eval(&_proc_obj)
      end


    end #class

  end #module

end #module


# override ActionController::Base::render

module ActionController #:nodoc:

  class Base  #:nodoc:

    attr_reader :render_layout_basename, :render_template_basename

    alias _render_orig render
    alias _render_file_orig render_file

    protected

    def render(options=nil, deprecated_status=nil, deprecated_layout=nil, &block) #:nodoc:
      template_with_options = options.is_a?(Hash)
      if apply_layout?(template_with_options, options)
        @render_layout_basename = pick_layout(template_with_options, options, deprecated_layout)
      end
      _render_orig(options, deprecated_status, &block)
    end

    def render_file(template_path, status=nil, use_full_path=false, locals={}) #:nodoc:
      @render_template_basename = template_path
      _render_file_orig(template_path, status, use_full_path, locals)
    end

  end

end
