###
### $Rev$
### $Release$
### $Copyright$
###


require 'kwartz'
require 'kwartz/binding/eruby'
require 'kwartz/binding/ruby'
require 'kwartz/binding/php'
require 'kwartz/binding/perl'
require 'kwartz/binding/eperl'
require 'kwartz/binding/rails'
require 'kwartz/binding/jstl'
require 'kwartz/binding/struts'
require 'kwartz/binding/erubis'
require 'kwartz/binding/pierubis'
require 'kwartz/util'



module Kwartz


  ##
  ## command option error class
  ##
  class CommandOptionError < KwartzError


    def initialize(message)
      super(message)
    end


  end


  ##
  ## command option class
  ##
  ## ex.
  ##  option_table = [
  ##    [?h, :help,    nil],
  ##    [?v, :version, nil],
  ##    [?f, :file,    "filename"],
  ##  ]
  ##  properties = {}
  ##  options = CommandOption.new(option_table, properties)
  ##  filenames = options.parse_argv(ARGV)
  ##  p options.help
  ##  p options.version
  ##  p options.file
  ##
  class CommandOptions

    def initialize(option_table, properties={})
      @_option_table = option_table
      @_properties = properties
      buf = []
      optchars = {}
      option_table.each do |char, key, argname|
        buf << "def #{key}; @#{key}; end; def #{key}=(val); @#{key}=val; end\n"
      end
      instance_eval buf.join
    end

    def _find_entry(key)
      if key.is_a?(Fixnum)
        return @_option_table.find { |row| row[0] == key }
      else
        key = key.to_s.intern unless key.is_a?(Symbol)
        return @_option_table.find { |row| row[1] == key }
      end
    end
    private :_find_entry

    def [](key)
      if key.is_a?(Fixnum)
        entry = _find_entry(key)  or return
        key = entry[1]
      end
      instance_variable_get("@#{key}")
    end

    def []=(key, val)
      instance_variable_set("@#{key}", val)
    end

    def key?(key)
      return instance_variables.include?("@#{key}")
    end

    def char(key)
      entry = _find_entry(key)
      return entry && entry[0]
    end

    def chr(key)
      ch = char(key)
      return ch ? ch.chr : ''
    end

    def parse_argv(argv)
      properties = @_properties
      while !argv.empty? && argv[0][0] == ?-
        optstr = argv.shift
        optstr = optstr[1, optstr.length - 1]
        if optstr[0] == ?-           # properties
          unless optstr =~ /\A-([-\w]+)(?:=(.*))?/
            raise option_error("'-#{optstr}': invalid property pattern.")
          end
          pname = $1 ;  pvalue = $2
          case pvalue
          when nil                    ;  pvalue = true
          when /\A\d+\z/              ;  pvalue = pvalue.to_i
          when /\A\d+\.\d+\z/         ;  pvalue = pvalue.to_f
          when 'true', 'yes', 'on'    ;  pvalue = true
          when 'false', 'no', 'off'   ;  pvalue = false
          when 'nil', 'null'          ;  pvalue = nil
          when /\A'.*'\z/, /\A".*"\z/ ; pvalue = eval pvalue
          end
          properties[pname.intern] = pvalue
        else                         # command-line options
          while optstr && !optstr.empty?
            optchar = optstr[0]
            optstr = optstr[1, optstr.length - 1]
            entry = _find_entry(optchar)
            entry  or raise CommandOptionError.new("-#{optchar.chr}: unknown option.")
            char, key, argname = entry
            case argname
            when nil, false
              instance_variable_set("@#{key}", true)
            when String
              arg = optstr
              arg = argv.shift unless arg && !arg.empty?
              arg  or raise CommandOptionError.new("-#{optchar.chr}: #{argname} required.")
              instance_variable_set("@#{key}", arg)
              optstr = ''
            when true
              arg = optstr
              arg = true unless arg && !arg.empty?
              instance_variable_set("@#{key}", arg)
              optstr = ''
            else
              raise "** internal error **"
            end
          end #while
        end #if
      end #while
      filenames = argv
      return filenames
    end #def

  end #class


  ##
  ## main command
  ##
  ## ex.
  ##  Kwartz::Main.add_handler('mylang', MyLangDirectiveHandler, MyLangTranslator)
  ##  Kwartz::Main.main(ARGV)
  ##
  class Main


    def initialize(argv=ARGV)
      @argv = argv
      @command = File.basename($0)
    end


    def self.main(argv=ARGV)
      status = 0
      begin
        main = Kwartz::Main.new(argv)
        output = main.execute()
        print output unless output == nil
      rescue Kwartz::KwartzError => ex
        raise ex if $DEBUG
        $stderr.puts ex.to_s
        status = 1
      end
      exit status
    end


    @@option_table = [
      [ ?h, :help,         nil ],
      [ ?v, :version,      nil ],
      [ ?e, :escape,       nil ],
      [ ?D, :debug,        nil ],
      [ ?t, :untabify,     nil ],
      [ ?S, :intern,       nil ],
      [ ?N, :notext,       nil ],
      [ ?l, :lang,         'lang name' ],
      [ ?k, :kanji,        'kanji code' ],
      [ ?a, :action,       'action name' ],
      [ ?r, :requires,     'library name' ],
      [ ?p, :plogics,      'file name' ],
      [ ?P, :pstyle,       'parser style' ],
      [ ?x, :extract_cont, 'element id' ],
      [ ?X, :extract_elem, 'element id' ],
      [ ?i, :imports,      'file name' ],
      [ ?L, :layout,       'file name' ],
      [ ?f, :yamlfile,     'yaml file' ],
    ]


    def execute(argv=@argv)

      ## parse command-line options
      options = CommandOptions.new(@@option_table, properties = {})
      pdata_filenames = options.parse_argv(argv)
      options.help = true if properties[:help]

      ## help
      if options.help || options.version
        puts version() if options.version
        puts help()    if options.help
        return nil
      end

      ## check filenames
      if pdata_filenames.empty?
        raise option_error("filename of presentation data is required.")
      end
      pdata_filenames.each do |filename|
        test(?f, filename)  or raise option_error("#{filename}: file not found.")
      end

      ## options
      $KCODE = options.kanji if options.kanji
      $DEBUG = options.debug if options.debug

      ## parse class, hander class, translator class
      style = options.pstyle || 'css'
      unless parser_class = PresentationLogicParser.get_class(style)
        s = "-#{options.chr(:pstyle)} #{style}"
        raise option_error("#{s}: unknown style name (parser class not registered).")
      end
      lang = options.lang || Config::PROPERTY_LANG      # 'eruby'
      unless handler_class = Handler.get_class(lang)
        s = "-#{options.chr(:lang)} #{lang}"
        raise option_error("#{s}: unknown lang name (handler class not registered).")
      end
      unless translator_class = Translator.get_class(lang)
        s = "-#{options.chr(:lang)} #{lang}"
        raise option_error("#{s}: unknown lang name (translator class not registered).")
      end

      ## require libraries
      if options.requires
        libraries = options.requires
        libraries.split(/,/).each do |library|
          library.strip!
          require library
        end
      end

      ## parse presentation logic file
      ruleset_list = []
      if options.plogics
        parser = parser_class.new(properties)
        options.plogics.split(/,/).each do |filename|
          filename.strip!
          if test(?f, filename)
            # ok
          elsif test(?f, filename + '.plogic')
            filename += '.plogic'
          else
            s = "-#{options.chr(:plogics)} #{filename}[.plogic]"
            raise option_error("#{s}: file not found.")
          end
          plogic = File.read(filename)
          ruleset_list += parser.parse(plogic, filename)
        end
      end

      ## properties
      properties[:escape] = true if options.escape && !properties.key?(:escape)

      ## create converter
      handler = handler_class.new(ruleset_list, properties)
      converter = TextConverter.new(handler, properties)

      ## import-files and layout-file
      import_filenames = []
      if options[?i]
        (import_filenames = options.imports.split(/,/)).each do |filename|
          unless test(?f, filename)
            s = "-#{options.chr(:imports)}"
            raise option_error("#{s} #{filename}: file not found.")
          end
        end
      end
      if options.layout
        unless test(?f, options.layout)
          s = "-#{options.chr(:layout)}"
          raise option_error("#{s} #{options.layout}: file not found.")
        end
        import_filenames += pdata_filenames
        pdata_filenames = [options.layout]
      end
      import_filenames.each do |filename|
        pdata = File.read(filename)
        converter.convert(pdata, filename)
      end

      ## convert presentation data file
      stmt_list = []
      pdata = nil
      pdata_filenames.each do |filename|
        test(?f, filename)  or raise option_error("#{filename}: file not found.")
        pdata = File.read(filename)
        #handler = handler_class.new(ruleset_list)
        #converter = TextConverter.new(handler, properties)
        list = converter.convert(pdata, filename)
        stmt_list.concat(list)
      end

      ## extract element or content
      elem_id = options.extract_cont || options.extract_elem
      if elem_id
        content_only = options.extract_cont ? true : false
        stmt_list = handler.extract(elem_id, content_only)
      end

      ## translate statements into target code(eRuby, PHP, JSP)
      if pdata[pdata.index(?\n) - 1] == ?\r
        properties[:nl] ||= "\r\n"
      end
      translator = translator_class.new(properties)
      if options.notext
        translator.extend(Kwartz::NoTextEnhancer)
      end
      output = translator.translate(stmt_list)

      ## action
      if options.action
        case options.action
        when 'compile'
          # nothing
        when 'defun'
          basename = File.basename(pdata_filenames.first).sub(/\.\w+/, '')
          output = Kwartz::Defun.defun(basename, output, lang, properties)
        else
          option_error("-#{options.chr(:action)} #{options.aciton}: invalid action.")
        end
      end

      ## load YAML file and evaluate eRuby script
      if options.yamlfile
        eruby_script = output
        if lang == 'eruby' || lang == 'rails'
          require 'erb'
          trim_mode = properties.key?(:trim) ? properties[:trim] : 1
          src = ERB.new(eruby_script, $SAFE, trim_mode).src
          mod = ERB::Util
        elsif lang == 'erubis'
          require 'erubis'
          src = Erubis::Eruby.new(eruby_script).src
          mod = Erubis::XmlHelper
        else
          s1 = "-#{options.chr(:yamlfile)}"
          s2 = "-#{options.chr(:lang)} #{lang}"
          option_error("#{s1}: not available with '#{s2}'.")
        end
        unless test(?f, options.yamlfile)
          s = "-#{options.chr(:yamlfile)} #{options.yamlfile}"
          raise option_error("#{s}: file not found.")
        end
        str = File.read(options.yamlfile)
        str = Kwartz::Util.untabify(str) if options.untabify
        require 'yaml'
        ydoc = YAML.load(str)
        unless ydoc.is_a?(Hash)
          s = "-#{options.chr(:yamlfile)} #{options.yamlfile}"
          raise option_error("#{s}: not a mapping.")
        end
        Kwartz::Util.intern_hash_keys(ydoc) if options.intern
        context = Object.new
        ydoc.each do |key, val|
          context.instance_variable_set("@#{key}", val)
        end
        context.extend(mod)    # ERB::Util or Erubis::XmlHelper
        output = context.instance_eval(src)
      end

      return output

    end


    private


    def help
      sb = []
      sb << "kwartz - a template system which realized 'Independence of Presentation Logic'\n"
      sb << "Usage: #{@command} [..options..] [-p plogic] file.html [file2.html ...]\n"
      sb << "  -h, --help     : help\n"
      sb << "  -v             : version\n"
      #sb << "  -D             : debug mode\n"
      sb << "  -e             : alias of '--escape=true'\n"
      sb << "  -l lang        : eruby/ruby/rails/php/jstl/eperl/erubis/pierubis (default 'eruby')\n"
      sb << "  -k kanji       : euc/sjis/utf8 (default nil)\n"
      sb << "  -a action      : compile/defun (default 'compile')\n"
      sb << "  -r library,... : require libraries\n"
      sb << "  -p plogic,...  : presentation logic files\n"
      sb << "  -i pdata,...   : import presentation data files\n"
      sb << "  -L layoutfile  : layout file ('-L f1 f2' is equivalent to '-i f2 f1')\n"
      sb << "  -x elem-id     : extract content of element marked by elem-id\n"
      sb << "  -X elem-id     : extract element marked by elem-id\n"
      sb << "  -f yamlfile    : YAML file for context values\n"
      sb << "  -t             : expand tab character in YAML file\n"
      sb << "  -S             : convert mapping key from string to symbol in YAML file\n"
      sb << "  -N             : print only program code (text is ignored)\n"
      #sb << "  -P style       : style of presentation logic (css/ruby/yaml)\n"
      sb << "  --dattr=str    : directive attribute name\n"
      sb << "  --odd=value    : odd value for FOREACH/LOOP directive (default \"'odd'\")\n"
      sb << "  --even=value   : even value for FOREACH/LOOP directive (default \"'even'\")\n"
      sb << "  --header=str   : header text\n"
      sb << "  --footer=str   : footer text\n"
      sb << "  --delspan={true|false} : delete dummy span tag (default false)\n"
      sb << "  --escape={true|false}  : escape (sanitize) (default false)\n"
      sb << "  --jstl={1.2|1.1}       : JSTL version (default 1.2)\n"
      sb << "  --charset=charset      : character set for JSTL (default none)\n"
      return sb.join
    end


    def version
      return RELEASE
    end


    def option_error(message)
      return CommandOptionError.new(message)
    end


  end #class



end #module



if $0 == __FILE__

  Kwartz::Main.main(ARGV)

end
