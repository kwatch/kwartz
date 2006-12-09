###
### $Rev$
### $Release$
### $Copyright$
###

require 'kwartz/assert'
require 'kwartz/error'
require 'kwartz/node'
require 'abstract'



module Kwartz



  module CharacterType


    def is_whitespace(ch)
      return ch == ?\  || ch == ?\t || ch == ?\n || ch == ?\r
    end


    def is_alpha(ch)
      return (?a <= ch && ch <= ?z) || (?A <= ch && ch <= ?Z)
    end


    def is_digit(ch)
      return ?0 <= ch && ch <= ?9
    end


    def is_identchar(ch)
      return is_alpha(ch) || is_digit(ch) || ch == ?_
    end


  end



  class ParseError < BaseError


    def initialize(message, filename, linenum, column)
      super
    end


  end



  ##
  ## .[abstract] parser class for presentation logic
  ##
  class PresentationLogicParser
    include CharacterType
    include Assertion


    def initialize(properties={})
      @properties = properties
    end


    ## called from parse() and initialize parser object
    def reset(input, filename='')
      input  or raise ArgumentError.new("#{self.class.name}#reset() requires string argument.")
      @input   = input
      @filename = filename
      @linenum = 1       # 1 start
      @column  = 0       # 1 start
      @pos     = -1      # 0 start
      @max_pos = @input.length - 1
      @token   = nil
      @value   = nil
      @error   = nil
      @ch      = nil
      getch()
    end
    protected :reset


    attr_reader :linenum, :column, :pos, :token, :value, :error


    table = {}
    %w[stag cont etag elem value attrs append].each do |word|
      sym = word.intern
      table[word]            = sym
      table[word.capitalize] = sym
      table[word.upcase]     = sym
    end
    %w[remove tagname logic before after begin end global local].each do |word|
      table[word] = word.intern
    end
    PLOGIC_KEYWORDS = table


    table = {}
    %w[stag cont etag elem value attrs append].each do |word|
      table[word]            = nil       # ex. value
      table[word.capitalize] = true      # ex. Value
      table[word.upcase]     = false     # ex. VALUE
    end
    ESCAPE_FLAG_TABLE = table


    def escape?(value)
      return ESCAPE_FLAG_TABLE[value]
    end


    ## scanner

    def getch
      return @ch = nil if @pos >= @max_pos
      if @ch == ?\n
        @linenum += 1
        @column = 0
      end
      @pos += 1
      @column += 1
      @ch = @input[@pos]
      return @ch
    end


    def scan_ident
      ## identifer
      if is_identchar(@ch)
        sb = @ch.chr
        while (c = getch()) && is_identchar(c)
          sb << c.chr
        end
        @value = sb
        return @token = :ident
      end
      return nil
    end


    def scan_string_dquoted
      return nil unless @ch == ?"
      s = ''
      while (c = getch()) && c != ?"
        if c == ?\\
          c = getch()
          break unless c
          case c
          when ?n  ;  s << "\n"
          when ?t  ;  s << "\t"
          when ?r  ;  s << "\r"
          when ?b  ;  s << "\b"
          when ?\\ ;  s << "\\"
          when ?"  ;  s << '"'
          else     ;  s << c.chr
          end
        else
          s << c.chr
        end
      end
      unless c
        @error = :string_unclosed
        return @token = :error
      end
      assert unless c == ?"
      getch()
      @value = s
      return @token = :string
    end


    def scan_string
      if @ch == ?'
        return scan_string_quoted()
      elsif @ch == ?"
        return scan_string_dquoted()
      else
        return nil
      end
    end


    def scan_string_quoted
      return nil unless @ch == ?'
      s = ''
      while (c = getch()) && c != ?'
        if c == ?\\
          c = getch()
          break unless c
          case c
          when ?\\ ;  s << "\\"
          when ?'  ;  s << "'"
          else     ;  s << "\\" << c.chr
          end
        else
          s << c.chr
        end
      end
      unless c
        @error = :string_unclosed
        return @token = :error
      end
      assert unless c == ?'
      getch()
      @value = s
      return @token = :string
    end


    ## called from scan(),  return false when not hooked
    def scan_hook
      #not_implemented
    end


    ## .[abstract] detect parser-specific keywords
    ##
    ## return symbol if keyword is token, else return nil
    def keywords(keyword)
      not_implemented
    end


    ## scan token
    def scan
      ## skip whitespaces
      c = @ch
      while is_whitespace(c)
        c = getch()
      end

      ## return nil when EOF
      if c == nil
        @value = nil
        return @token = nil
      end

      ## scan hook
      ret = scan_hook()    # scan_hook() is overrided in subclass
      return ret if ret != false

      ## keyword or identifer
      if is_identchar(c)
        scan_ident()
        @token = keywords(@value) || PLOGIC_KEYWORDS[@value] || :ident
        return @token
      end

      ## "string"
      if c == ?"
        return scan_string_dquoted()
      end

      ## 'string'
      if c == ?'
        return scan_string_quoted()
      end

      ## '{'
      if c == ?{
        @value = "{"
        getch()
        return @token = :'{'
      end

      ## '}'
      if c == ?}
        @value = "}"
        getch()
        return @token = :'}'
      end

      ## ','
      if c == ?,
        @value = ","
        getch()
        return @token = :','
      end

      ##
      @value = c.chr
      @error = :invalid_char
      return @token = :error
    end


    def scan_block(skip_open_curly=false)
      unless skip_open_curly
        token = scan()
        unless token == ?{
          @error = :block_notfound
          return @token = :error
        end
      end
      start_pos = @pos
      count = 1
      while (c = getch()) != nil
        if c == ?{
          count += 1
        elsif c == ?}
          count -= 1
          break if count == 0
        end
      end
      unless c
        @error = :block_unclosed
        return @token = :error
      end
      assert unless c == ?}
      @value = @input[start_pos, @pos - start_pos]
      @token = :block
      getch()
      return @value
    end


    def scan_line
      sb = @ch.chr
      while (c = getch()) != nil && c != ?\n
        sb << c.chr
      end
      sb.chop if sb[-1] == ?\r
      getch()
      return sb
    end


    ## parser


    def parse_error(message, linenum=@linenum, column=@column)
      return ParseError.new(message, @filename, linenum, column)
    end


    ## .[abstract] parse input string and return list of ElementRuleset
    def parse(input, filename='')
      not_implemented
    end


    def _parse_block
      scan()
      unless @token == :'{'
        raise parse_error("'#{@value}': '{' expected.")
      end
      start_linenum, start_column = @linenum, @column
      t = scan_block(true)
      if t == :error
        if @error == :block_unclosed
          raise parse_error("'{': not closed by '}'.", start_linenum, start_column)
        else
          assert("@error=#{@error}")
        end
      end
      @value.sub!(/\A[ \t]*\n/, '')
      @value.sub!(/^[ \t]+\z/, '')
      return @value
    end


    @@class_table = {}


    def self.register_class(css, klass)
      @@class_table[css] = klass
    end


    def self.get_class(css)
      return @@class_table[css]
    end


  end #class



  ##
  ## ruby style presentation logic parser
  ##
  ## presentation logic example (ruby style):
  ##
  ##   # comment
  ##   element "list" {
  ##     value  @var
  ##     attrs  "class"=>@clssname, "bgcolor"=>color
  ##     append @value==item['list'] ? ' checked' : ''
  ##     logic {
  ##       @list.each { |item|
  ##         _stag
  ##         _cont
  ##         _etag
  ##       }
  ##     }
  ##   }
  ##
  class RubyStyleParser < PresentationLogicParser


    def parse(input, filename='')
      reset(input, filename)
      scan()
      nodes = []
      while @token != nil
        if @token == :element
          node = parse_element_ruleset()
        elsif @token == :document
          node = parse_document_ruleset()
        else
          raise parse_error("'#{@value}': element or document required.")
        end
        nodes << node
      end
      return nodes
    end


    protected


    def scan_hook
      ## line comment
      c = @ch
      if c == ?#
        scan_line
        return scan()
      end
      return false
    end


    def keywords(keyword)
      return RUBYSTYLE_KEYWORDS[keyword]
    end
    RUBYSTYLE_KEYWORDS = { 'BEGIN'=>:BEGIN, 'END'=>:END, 'element'=>:element, 'document'=>:document }


    def parse_document_ruleset
      assert unless @token == :document
      scan()
      unless @token == :'{'
        raise parse_error("'#{@value}': document requires '{'.")
      end
      ruleset = Ruleset.new
      while @token
        scan()
        case @token
        when :global    ;  has_space? ;  ruleset.set_global    _parse_list()
        when :local     ;  has_space? ;  ruleset.set_local     _parse_list()
        when :fixture   ;  has_space? ;  ruleset.set_fixture   _parse_block()
        when :before    ;  has_space? ;  ruleset.set_before    _parse_block()
        when :after     ;  has_space? ;  ruleset.set_after     _parse_block()
        when :'}'       ;  break
        else            ;  raise parse_error("'#{@value}': invalid token.")
        end
      end
      unless @token == :'}'
        raise parse_error("'#{@value}': document is not closed by '}'.")
      end
      scan()
      return DocumentRuleset.new(hash)
    end


    def has_space?
      unless @ch == ?\  || @ch == ?\t
        raise parse_error("'#{@value}': following spaces are required but got '#{@ch.chr}'.")
      end
    end


    def _parse_list
      line = scan_line()
      list = line.split(/,\s+/).collect {|item| item.strip}
      return list
    end


    def _parse_strs
      list = _parse_list()
      list2 = []
      list.each do |item|
        case item
        when /\A"(.*)"\z/  ; list2 << $1
        when /\A'(.*)'\z/  ; list2 << $1
        else
          raise parse_error("'#{item}': argument of 'remove' should be string.")
        end
      end
      return list2
    end


    def _parse_str
      return _parse_strs()[0]
    end


    def _parse_item
      item = scan_line()
      item.strip!
      return item
    end


    def _parse_block
      super
    end


    def _parse_tuples
      line = scan_line()
      items = line.split(/,\s+/)
      tuples = []
      items.each do |item|
        unless item =~ /(.*?)=>(.*)/
          raise parse_error("'#{item}': invalid pattern.")
        end
        key = $1;   key.strip!
        val = $2;   val.strip!
        if key =~ /\A"(.*)"\z/
          key = $1
        elsif key =~ /\A'(.*)'\z/
          key = $1
        else
          raise parse_error("'#{key}': key must be \"...\" or '...'.")   #
        end
        tuples << [key, val]
      end
      return tuples
    end


    def parse_element_ruleset
      assert unless @token == :element
      scan()
      @token == :string   or raise parse_error("'#{@value}': element name required in string.")
      name = @value
      name =~ /\A\w+\z/   or raise parse_error("'#{@value}': invalid element name.")
      scan()
      @token == :'{'      or raise parse_error("'#{@value}': '{' required.")
      ruleset = ElementRuleset.new(name)
      while true
        scan()
        flag_escape = escape?(@value)
        break unless @token
        #if @token.is_a?(Symbol) && (@ch != ?\  && @ch != ?\t)
        #  raise parse_error("'#{@value}': following spaces are required but got '#{@ch.chr}'.")
        #end
        case @token
        when :stag    ;  has_space? ;  ruleset.set_stag     _parse_item()   , flag_escape
        when :cont    ;  has_space? ;  ruleset.set_cont     _parse_item()   , flag_escape
        when :etag    ;  has_space? ;  ruleset.set_etag     _parse_item()   , flag_escape
        when :elem    ;  has_space? ;  ruleset.set_elem     _parse_item()   , flag_escape
        when :value   ;  has_space? ;  ruleset.set_value    _parse_item()   , flag_escape
        when :attrs   ;  has_space? ;  ruleset.set_attrs    _parse_tuples() , flag_escape
        when :append  ;  has_space? ;  ruleset.set_append   _parse_list()   , flag_escape
        when :remove  ;  has_space? ;  ruleset.set_remove   _parse_strs()
        when :tagname ;  has_space? ;  ruleset.set_tagname  _parse_str()
        when :logic   ;  has_space? ;  ruleset.set_logic    _parse_block()
        when :'}'     ;  break
        else          ;  raise parse_error("'#{@value}': invalid token.")
        end
      end
      assert unless token == :'}'
      scan()
      return ruleset
    end


  end #class
  PresentationLogicParser.register_class('ruby', RubyStyleParser)



  ##
  ## css style presentation logic parser
  ##
  ## example of presentation logic in css style:
  ##
  ##   /* comment */
  ##   #idname, .classname, tagname {
  ##     value:   @var;
  ##     attrs:   "class" @classname, "bgcolro" color;
  ##     append:  @value==item['list'] ? ' checked' : '';
  ##     logic:   {
  ##       @list.each { |item|
  ##         _stag
  ##         _cont
  ##         _etag
  ##       }
  ##     }
  ##   }
  ##
  class CssStyleParser < PresentationLogicParser


    def initialize(*args)
      super
      @mode = :selector           # :selector or :declaration
    end

    attr_accessor :mode


    def parse(input, filename='')
      reset(input, filename)
      scan()
      rulesets = []
      while @token == :command     # '@import'
        command = @value
        case command
        when '@import'
          imported_rulesets = parse_import_command()
          rulesets += imported_rulesets
        when '@from'
          # TODO
        when '@import_pdata'
          # TODO
        else
          raise parse_error("#{command}: unsupported command.")
        end
      end
      while @token == :selector
        selectors = parse_selectors()
        unless @token == :'{'
          raise parse_error("'#{@value}': '{' is expected.")  #'
        end
        @mode = :declaration
        _linenum, _column = @linenum, @column
        ruleset = Ruleset.new(selectors)
        parse_declaration(ruleset)
        unless @token
          raise parse_error("'#{selectors.first}': is not closed by '}'.", _linenum, _column)
        end
        @mode = :selector
        rulesets << ruleset
        scan()
      end
      unless @token == nil
        raise parse_error("'#{@value}': selector is expected.")
      end
      return rulesets
    end


    protected


    ## return false when not hooked
    def scan_hook
      ## comment
      c = @ch
      if c == ?/
        c = getch()
        if c == ?/      # line comment
          scan_line()
          getch()
          return scan()
        elsif c == ?*   # region comment
          start_linenum = @linenum
          while true
            c = getch() while c != ?*
            break if c == nil
            c = getch()
            break if c == ?/
          end
          if c == nil
            @error = :comment_unclosed
            @value = start_linenum
            return @token == :error
          end
          getch()
          return scan()
        else
          @value = '/'
          return @token = ?/
        end #if
      end #if

      ##
      if @mode == :selector
        # '#name' or '.name'
        if c == ?# || c == ?.
          start_char = c
          name = ''
          while is_identchar(c = getch()) || c == ?-
            name << c
          end
          if name.empty?
            @error = :invalid_char
            @value = start_char.chr
            return @token = :error
          end
          @value = start_char.chr + name
          return @token = :selector
        end
        # 'tagname'
        if is_identchar(c) || c == ?-
          name = c.chr
          while is_identchar(c = getch()) || c == ?- || c == ?:
            name << c
          end
          @value = name
          return @token = :selector
        end
        # '@import'
        if c == ?@
          name = ''
          while is_identchar(c = getch())
            name << c
          end
          if name.empty?
            @error = :invalid_char
            @value = '@'
            return @token = :error
          end
          @value = '@' + name
          return @token = :command
        end
      end

      return false

    end #def


    def keywords(keyword)
      return CSSSTYLE_KEYWORDS[keyword]
    end
    CSSSTYLE_KEYWORDS = { 'begin'=>:begin, 'end'=>:end }


    def has_colon?
      unless @ch == ?:
        raise parse_error("'#{@value}': ':' is required.")
      end
      getch()
    end


    def parse_selectors
      assert unless @token == :selector
      start_linenum = @linenum
      selectors = [ @value ]
      scan()
      while @token == :','
        scan()
        unless @token == :selector
          raise parse_error("'#{@value}': selector is expected (or additional comma exists).") #'
        end
        selectors << @value
        scan()
      end
      return selectors
    end


    def parse_declaration(ruleset)
      assert unless @token == :'{'
      while true
        scan()
        flag_escape = escape?(@value)
        case @token
        when nil     ;  break
        when :'}'    ;  break
        when :stag   ;  has_colon?();  ruleset.set_stag    _parse_expr() , flag_escape
        when :cont   ;  has_colon?();  ruleset.set_cont    _parse_expr() , flag_escape
        when :etag   ;  has_colon?();  ruleset.set_etag    _parse_expr() , flag_escape
        when :elem   ;  has_colon?();  ruleset.set_elem    _parse_expr() , flag_escape
        when :value  ;  has_colon?();  ruleset.set_value   _parse_expr() , flag_escape
        when :attrs  ;  has_colon?();  ruleset.set_attrs   _parse_pairs(), flag_escape
        when :append ;  has_colon?();  ruleset.set_append  _parse_exprs(), flag_escape
        when :remove ;  has_colon?();  ruleset.set_remove  _parse_strs()
        when :tagname;  has_colon?();  ruleset.set_tagname _parse_str()
        when :logic  ;  has_colon?();  ruleset.set_logic   _parse_block()
        when :before ;  has_colon?();  ruleset.set_before  _parse_block()
        when :after  ;  has_colon?();  ruleset.set_after   _parse_block()
        when :begin  ;  has_colon?();  ruleset.set_before  _parse_block()
        when :end    ;  has_colon?();  ruleset.set_after   _parse_block()
        else
          raise parse_error("'#{@value}': unexpected token.")  #'
        end
      end
      return ruleset
    end


    def parse_import_command
      c = @ch
      c = getch() while is_whitespace(c)
      t = scan_string()
      t == :string  or raise parse_error("@import: requires filename.")
      filename = @value
      if @filename && !@filename.empty?
        dir = File.dirname(@filename)
        filename = dir + '/' + filename if dir != '.'
      end
      test(?f, filename)  or raise parse_error("'#{filename}': import file not found.")
      _linenum, _column = @linenum, @column
      c = @ch
      c = getch() while is_whitespace(c)
      c == ?; or raise parse_error("';' required.")
      c = getch()
      scan()
      parser = self.class.new(@properties)
      begin
        ruleset_list = parser.parse(File.read(filename), filename)
      rescue => ex
        parse_error(ex.message, _linenum, _column)
      end
      return ruleset_list
    end


    private


    def _parse_expr
      expr = ''
      while true
        line = scan_line()
        unless line && line =~ /([,;])[ \t]*(?:\/\/.*)?$/
          raise parse_error("'#{@token}:': ';' is required.")
        end
        indicator = $1
        expr << $`
        break if indicator == ';'
        expr << ",\n"
      end
      expr.strip!
      return expr
    end


    def _parse_pairs
      hash = {}
      while true
        line = scan_line()
        unless line && line =~ /([,;])[ \t]*(\/\/.*)?$/
          raise parse_error("'#{@token}:': ';' is required.")
        end
        indicator = $1
        str = $`
        if str =~ /\A\s*"([-:\w]+)"\s+(.*)\z/
          aname = $1  ;  avalue = $2
        elsif str =~ /\A\s*'([-:\w]+)'\s+(.*)\z/
          aname = $1  ;  avalue = $2
        else
          raise parse_error("'#{@token}:': invalid mapping pattern")
        end
        hash[aname] = avalue
        break if indicator == ';'
      end
      return hash
    end


    def _parse_words
      list = []
      while true
        line = scan_line()
        unless line && line =~ /([,;])[ \t]*(\/\/.*)?$/
          raise parse_error("'#{@token}:': ';' is required.")
        end
        indicator = $1
        s = $`
        s.split(/,/).each do |word|
          word.strip!
          list << word
        end
        break if indicator == ';'
      end
      return list
    end


    def _parse_exprs
      list = []
      while true
        line = scan_line()
        unless line && line =~ /([,;])[ \t]*(\/\/.*)?$/
          raise parse_error("'#{@token}:': ';' is required.")
        end
        indicator = $1
        expr = $`
        expr.strip!
        list << expr
        break if indicator == ';'
      end
      return list
    end


    def _parse_strs
      list = []
      while true
        line = scan_line()
        unless line && line =~ /([,;])[ \t]*(\/\/.*)?$/
          raise parse_error("'#{@token}:': ';' is required.")
        end
        indicator = $1
        s = $`
        strs = s.split(/,/)
        strs.each do |str|
          str.strip!
          unless str =~ /\A'(.*)'\z/ || str =~ /\A"(.*)"\z/
            raise parse_error("'#{@token}': string list is expected.")
          end
          list << $1
        end
        break if indicator == ';'
      end
      return list
    end


    def _parse_str
      return _parse_strs()[0]
    end


    def _parse_block
      super
    end


  end #class
  PresentationLogicParser.register_class('css', CssStyleParser)



end #module
