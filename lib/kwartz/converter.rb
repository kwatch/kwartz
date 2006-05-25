###
### $Rev$
### $Release$
### $Copyright$
###

require 'strscan'

require 'kwartz/assert'
require 'kwartz/error'
require 'kwartz/node'
require 'kwartz/config'

require 'abstract'


module Kwartz


  class ConvertError < KwartzError


    def initialize(message, filename, linenum)
      super(message)
      @filename = filename
      @linenum = linenum
    end

    attr_accessor :linenum


    def to_s
      s = super
      return "#{@filename}:#{@linenum}: #{s}"
      #return "#{s}(line #{@linenum})"
    end


  end



  class TagInfo


    def initialize(matched, linenum=nil)
      @prev_text   = matched[1]
      @tag_text    = matched[2]
      @head_space  = matched[3]
      @is_etag     = matched[4] == '/'
      @tagname     = matched[5]
      @attr_str    = matched[6]
      @extra_space = matched[7]
      @is_empty    = matched[8] == '/'
      @tail_space  = matched[9]
      @linenum = linenum
    end


    attr_accessor :prev_text, :tag_text, :head_space, :is_etag, :tagname, :attr_str, :extra_space, :is_empty, :tail_space
    attr_accessor :linenum
    alias is_etag?  is_etag
    alias is_empty? is_empty


    def tagname=(tagname)
      @tagname = tagname
      rebuild_tag_text()
      tagname
    end


    def rebuild_tag_text(attr_info=nil)
      if attr_info
        sb = ''
        attr_info.each do |space, aname, avalue|
          sb << "#{space}#{aname}=\"#{avalue}\""
        end
        @attr_str = sb
      end
      @tag_text = "#{@head_space}<#{@is_etag ? '/' : ''}#{@tagname}#{@attr_str}#{@extra_space}#{@is_empty ? '/' : ''}>#{@tail_space}"
    end


    def _inspect
      return [ @prev_text, @head_space, @is_etag, @tagname, @attr_str, @extra_space, @is_empty, @tail_space ]
    end


  end



  class AttrInfo


    def initialize(attr_str)
      @names  = []
      @values = {}
      @spaces = {}
      attr_str.scan(/(\s+)([-:_\w]+)="([^"]*?)"/) do |space, name, value|
        @names << name unless @values.key?(name)
        @values[name] = value
        @spaces[name] = space
      end
      @directive = nil
      @linenum = nil
    end
    attr_reader :names, :values, :spaces
    attr_accessor :directive, :linenum


    def [](name)
      @values[name]
    end


    def []=(name, value)
      @names << name unless @values.key?(name)
      @values[name] = value
      @spaces[name] = ' ' unless @spaces.key?(name)
    end


    def each
      @names.each do |name|
        space = @spaces[name]
        value = @values[name]
        yield(space, name, value)
      end
    end


    def delete(name)
      if @values.key?(name)
        @names.delete(name)
        @values.delete(name)
        @spaces.delete(name)
      end
    end


    def empty?
      return @names.empty?
    end


  end



  class ElementInfo


    def initialize(name, stag_info, etag_info, cont_stmts, attr_info, append_exprs)
      @name         = name           # String
      @stag_info    = stag_info      # TagInfo
      @etag_info    = etag_info      # TagInfo
      @cont_stmts   = cont_stmts     # list of Statement
      @attr_info    = attr_info      # AttrInfo
      @append_exprs = append_exprs   # list of NativeExpression
      @logic = [ ExpandStatement.new(:elem, @name) ]
      @merged = nil
    end

    attr_accessor :name, :stag_info, :etag_info, :cont_stmts, :attr_info, :append_exprs, :logic
    attr_reader :stag_expr, :cont_expr, :etag_expr, :elem_expr


    def merged?
      @merged
    end


    def self.create(values={})
      self.new(values[:name], values[:stag], values[:etag], values[:cont], values[:attr], values[:append])
    end


    def merge(elem_ruleset)
      return unless elem_ruleset.name == @name
      @merged = elem_ruleset
      @stag_expr = _to_native_expr(elem_ruleset.stag)
      @cont_expr = _to_native_expr(elem_ruleset.cont || elem_ruleset.value)
      @etag_expr = _to_native_expr(elem_ruleset.etag)
      @elem_expr = _to_native_expr(elem_ruleset.elem)
      if @cont_expr
        @cont_stmts = [ PrintStatement.new([@cont_expr]) ]
        @stag_info.tail_space = ''
        @etag_info.head_space = ''
        @etag_info.rebuild_tag_text()
      end
      elem_ruleset.remove.each do |aname|
        @attr_info.delete(aname)
      end if elem_ruleset.remove
      elem_ruleset.attrs.each do |aname, avalue|
        @attr_info[aname] = _to_native_expr(avalue)
      end if elem_ruleset.attrs
      elem_ruleset.append.each do |expr|
        (@append_exprs ||= []) << _to_native_expr(expr)
      end if elem_ruleset.append
      @tagname = elem_ruleset.tagname
      @logic = elem_ruleset.logic if elem_ruleset.logic
    end


    private


    def _to_native_expr(value)
      return value && value.is_a?(String) ? NativeExpression.new(value) : value
    end


  end



  ##
  ## helper module for Converter and Handler
  ##
  ## Handler and Converter class include this module.
  ##
  module ConverterHelper       # :nodoc:


    ## set @despan and @dattr
    def include_properties(properties)
      @dattr = properties[:dattr]   || Config::PROPERTY_DATTR    # default: 'title'
      @delspan = properties.key?(:delspan) ? properties[:delspan] : Config::PROPERTY_DELSPAN  # delete dummy <span> tag or not
    end


    ## return ConvertError
    def convert_error(message, linenum)
      return ConvertError.new(message, @filename, linenum)
    end


    ## raise errror if etag_info is null
    def error_if_empty_tag(stag_info, etag_info, d_name, d_arg)
      unless etag_info
        raise convert_error("'#{d_name}:#{d_arg}': #{d_name} directive is not available with empty tag.", stag_info.linenum)
      end
    end


    ## create print statement from text
    def create_text_print_stmt(text)
      return PrintStatement.new([text])
      #return new PritnStatement.new([TextExpression.new(text)])
    end


    ## create array of String and NativeExpression for PrintStatement
    def build_print_args(taginfo, attr_info, append_exprs)
      return [] if taginfo.tagname.nil?
      #if taginfo.tagname.nil?
      #  if (!attr_info || attr_info.empty?) && (!append_exprs || append_exprs.empty?)
      #    return []
      #  else
      #    taginfo.tagname = 'span'
      #  end
      #end
      unless attr_info || append_exprs
        return [taginfo.tag_text]
      end
      args = []
      t = taginfo
      sb = "#{t.head_space}<#{t.is_etag ? '/' : ''}#{t.tagname}"
      attr_info.each do |space, aname, avalue|
        sb << "#{space}#{aname}=\""
        if avalue.is_a?(NativeExpression)
          args << sb     # TextExpression.new(sb)
          args << avalue
          sb = ''
        else
          sb << avalue
        end
        sb << '"'
      end if attr_info
      if append_exprs && !append_exprs.empty?
        unless sb.empty?
          args << sb     # TextExpression.new(sb)
          sb = ''
        end
        args.concat(append_exprs)
      end
      sb << "#{t.extra_space}#{t.is_empty ? '/' : ''}>#{t.tail_space}"
      args << sb         # TextExpression.new(sb)
      return args
    end


    ## create PrintStatement for TagInfo
    def build_print_stmt(taginfo, attr_info, append_exprs)
      args = build_print_args(taginfo, attr_info, append_exprs)
      return PrintStatement.new(args)
    end


    ## create PrintStatement for NativeExpression
    def build_print_expr_stmt(native_expr, stag_info, etag_info)
      head_space = (stag_info || etag_info).head_space
      tail_space = (etag_info || stag_info).tail_space
      args = []
      args << head_space if head_space    # TexExpression.new(head_space)
      args << native_expr
      args << tail_space if tail_space    # TextExpression.new(tail_space)
      return PrintStatement.new(args)
    end


  end



  ##
  ## .[abstract] expand ExpandStatement and ElementInfo
  ##
  ## Handler class includes this module.
  ##
  module ElementExpander
    include Assertion


    ## .[abstract] get ElementRuleset
    def get_element_ruleset(name)
      not_implemented
    end


    ## .[abstract] get ElementInfo
    def get_element_info(name)
      not_implemented
    end


    ## expand ElementInfo
    def expand_element_info(elem_info, stmt_list, content_only=false)
      #elem_ruleset = @ruleset_table[elem_info.name]
      elem_ruleset = get_element_ruleset(elem_info.name)
      if elem_ruleset && !elem_info.merged?
        elem_info.merge(elem_ruleset)
      end
      logic = content_only ? [ ExpandStatement.new(:cont, elem_info.name) ] : elem_info.logic
      logic.each do |stmt|
        expand_statement(stmt, stmt_list, elem_info)
      end
      #if content_only
      #  stmt = ExpandStatement.new(:cont, elem_info.name)
      #  expand_statement(stmt, stmt_list, elem_info)
      #else
      #  element.logic.each do |stmt|
      #    expand_statement(stmt, stmt_list, elem_info)
      #  end
      #end
    end


    ## expand ExpandStatement
    def expand_statement(stmt, stmt_list, elem_info)

      if stmt.is_a?(ExpandStatement)
        e = elem_info

        ## delete dummy '<span>' tag
        if @delspan && e.stag_info.tagname == 'span' && e.attr_info.empty? && e.append_exprs.nil?
          e.stag_info.tagname = e.etag_info.tagname = nil
        end

        case stmt.kind

        when :stag
          assert unless elem_info
          if e.stag_expr
            assert unless e.stag_expr.is_a?(NativeExpression)
            stmt_list << build_print_expr_stmt(e.stag_expr, e.stag_info, nil)
          else
            stmt_list << build_print_stmt(e.stag_info, e.attr_info, e.append_exprs)
          end

        when :etag
          assert unless elem_info
          if e.etag_expr
            assert unless e.etag_expr.is_a?(NativeExpression)
            stmt_list << build_print_expr_stmt(e.etag_expr, nil, e.etag_info)
          elsif e.etag_info    # e.etag_info is nil when <br>, <input>, <hr>, <img>, <meta>
            stmt_list << build_print_stmt(e.etag_info, nil, nil)
          end

        when :cont
          if e.cont_expr
            assert unless e.cont_expr.is_a?(NativeExpression)
            stmt_list << PrintStatement.new([e.cont_expr])
          else
            elem_info.cont_stmts.each do |cont_stmt|
              expand_statement(cont_stmt, stmt_list, nil)
            end
          end

        when :elem
          assert unless elem_info
          if e.elem_expr
            assert unless e.elem_expr.is_a?(NativeExpression)
            stmt_list << build_print_expr_stmt(e.elem_expr, e.stag_info, e.etag_info)
          else
            stmt.kind = :stag
            expand_statement(stmt, stmt_list, elem_info)
            stmt.kind = :cont
            expand_statement(stmt, stmt_list, elem_info)
            stmt.kind = :etag
            expand_statement(stmt, stmt_list, elem_info)
            stmt.kind = :elem
          end

        when :element, :content
          content_only = stmt.kind == :content
          #elem_info = @elements[stmt.name]
          elem_info = get_element_info(stmt.name)
          unless elem_info
            raise convert_error("element '#{stmt.name}' is not found.", nil)
          end
          expand_element_info(elem_info, stmt_list, content_only)

        else
          assert
        end #case
      else
        stmt_list << stmt
      end #if
    end


  end #module



  ##
  ## .[abstract] handle directives
  ##
  class Handler
    include Assertion
    include ConverterHelper
    include ElementExpander


    def initialize(elem_rulesets=[], properties={})
      @elem_rulesets = elem_rulesets
      #@elem_ruleset_table = elem_rulesets.inject({}) { |table, ruleset| table[ruleset.name] = ruleset; table }
      @elem_ruleset_table = {} ; elem_rulesets.each { |ruleset| @elem_ruleset_table[ruleset.name] = ruleset }
      @elem_info_table = {}
      include_properties(properties)     # @delspan and @dattr
      @odd  = properties[:odd]     || Config::PROPERTY_ODD      # "'odd'"
      @even = properties[:even]    || Config::PROPERTY_EVEN     # "'even'"
      @filename = nil
    end
    attr_reader :odd, :even
    attr_accessor :converter, :filename


    def get_element_ruleset(name)  # for ElementExpander module and Converter class
      @elem_ruleset_table[name]
    end


    def get_element_info(name)  # for ElementExpander module
      @elem_info_table[name]
    end


    protected


    ## .[abstract] directive pattern, which is used to detect directives.
    def directive_pattern
      not_implemented
      #return /\A(\w+):\s*(.*)/
    end


    ## .[abstract] mapping pattern, which is used to parse 'attr' directive.
    def mapping_pattern
      not_implemented
      #return /\A'([-:\w]+)'\s+(.*)/
    end


    ## .[abstract] directive format, which is used at has_directive?() method
    def directive_format
      not_implemented
      #return '%s: %s'
    end


    public


    ## handle directives ('stag', 'etag', 'elem', 'cont'(='value'))
    ##
    ## return true if directive name is one of 'stag', 'etag', 'elem', 'cont', and 'value',
    ## else return false.
    def handle(directive_name, directive_arg, directive_str, stag_info, etag_info, cont_stmts, attr_info, append_exprs, stmt_list)
      d_name = directive_name
      d_arg  = directive_arg
      d_str  = directive_str

      case directive_name

      when nil
        assert unless !attr_info.empty? || !append_exprs.empty?
        stmt_list << build_print_stmt(stag_info, attr_info, append_exprs)
        stmt_list.concat(cont_stmts)
        stmt_list << build_print_stmt(etag_info, nil, nil) if etag_info   # when empty-tag

      when :dummy
        # nothing

      when :id, :mark
        unless directive_arg =~ /\A(\w+)\z/ || directive_arg =~ /\A'(\w+)'\z/
          raise convert_error("'#{d_str}': invalid marking name.", stag_info.linenum)
        end
        name = $1
        elem_info = ElementInfo.new(name, stag_info, etag_info, cont_stmts, attr_info, append_exprs)
        if @elem_info_table[name]
          #unless Config::ALLOW_DUPLICATE_ID
            previous_linenum = @elem_info_table[name].stag_info.linenum
            raise convert_error("'#{d_str}': id '#{name}' is already used at line #{previous_linenum}.", stag_info.linenum)
          #end
        else
          @elem_info_table[name] = elem_info
        end
        #stmt_list << ExpandStatement.new(:element, name)     # lazy expantion
        expand_element_info(elem_info, stmt_list)

      when :stag, :Stag, :STAG
        error_if_empty_tag(stag_info, etag_info, d_name, d_arg)
        flag_escape = d_name == :stag ? nil : (d_name == :Stag)
        expr = NativeExpression.new(d_arg, flag_escape)
        stmt_list << build_print_expr_stmt(expr, stag_info, nil)
        stmt_list.concat(cont_stmts)
        stmt_list << build_print_stmt(etag_info, nil, nil)

      when :etag, :Etag, :ETAG
        error_if_empty_tag(stag_info, etag_info, d_name, d_arg)
        flag_escape = d_name == :etag ? nil : (d_name == :Etag)
        expr = NativeExpression.new(d_arg, flag_escape)
        stmt_list << build_print_stmt(stag_info, attr_info, append_exprs)
        stmt_list.concat(cont_stmts)
        stmt_list << build_print_expr_stmt(expr, nil, etag_info)

      when :elem, :Elem, :ELEM
        flag_escape = d_name == :elem ? nil : (d_name == :Elem)
        expr = NativeExpression.new(d_arg, flag_escape)
        stmt_list << build_print_expr_stmt(expr, stag_info, etag_info)

      when :cont, :Cont, :CONT, :value, :Value, :VALUE
        error_if_empty_tag(stag_info, etag_info, d_name, d_arg)
        stag_info.tail_space = etag_info.head_space = nil    # delete spaces
        args = build_print_args(stag_info, attr_info, append_exprs)
        flag_escape = (d_name == :cont || d_name == :value) ? nil : (d_name == :Cont || d_name == :Value)
        args << NativeExpression.new(d_arg, flag_escape)
        #args << etag_info.tag_text
        args << etag_info.tag_text if etag_info.tagname
        stmt_list << PrintStatement.new(args)

      when :attr, :Attr, :ATTR
        unless d_arg =~ self.mapping_pattern()     # ex. /\A'([-:\w]+)'\s+(.*)\z/
          raise convert_error("'#{d_str}': invalid attr pattern.", stag_info.linenum)
        end
        aname = $1;  avalue = $2
        flag_escape = d_name == :attr ? nil : (d_name == :Attr)
        attr_info[aname] = NativeExpression.new(avalue, flag_escape)

      when :append, :Append, :APPEND
        flag_escape = d_name == :append ? nil : (d_name == :Append)
        append_exprs << NativeExpression.new(d_arg, flag_escape)

      when :replace_element_with_element, :replace_element_with_content,
           :replace_content_with_element, :replace_content_with_content
        arr = d_name.to_s.split(/_/)
        replace_cont = arr[1] == 'content'
        with_content = arr[3] == 'content'
        name = d_arg
        #
        error_if_empty_tag(stag_info, etag_info, d_name, d_arg)           if replace_cont
        stmt_list << build_print_stmt(stag_info, attr_info, append_exprs) if replace_cont
        #stmt_list << ExpandStatement.new(:element, name)
        elem_info = @elem_info_table[name]
        unless elem_info
          raise convert_error("'#{d_str}': element '#{name}' not found.", stag_info.linenum)
        end
        expand_element_info(elem_info, stmt_list, with_content)
        stmt_list << build_print_stmt(etag_info, nil, nil)                if replace_cont

      when :replace_element_with, :replace_content_with, :replace, :placeholder
        unless d_arg =~ /\A_?(element|content)\(["']?(\w+)["']?\)\z/
          raise convert_error("'#{d_str}': invalid #{d_name} format.", stag_info.linenum)
        end
        kind = $1
        name = $2
        replace_cont = d_name == :replace_content_with || d_name == :placeholder
        with_content = kind == 'content'
        #
        error_if_empty_tag(stag_info, etag_info, d_name, d_arg)           if replace_cont
        stmt_list << build_print_stmt(stag_info, attr_info, append_exprs) if replace_cont
        #stmt_list << ExpandStatement.new(:element, name)
        elem_info = @elem_info_table[name]
        unless elem_info
          raise convert_error("'#{d_str}': element '#{name}' not found.", stag_info.linenum)
        end
        expand_element_info(elem_info, stmt_list, with_content)
        stmt_list << build_print_stmt(etag_info, nil, nil)                if replace_cont
      else
        return false
      end #case

      return true

    end


    def extract(elem_name, content_only=false)
      elem_info = @elem_info_table[elem_name]
      elem_info or raise convert_error("element '#{elem_name}' not found.", nil)
      stmt_list = []
      expand_element_info(elem_info, stmt_list, content_only)
      #stmt_list << build_print_stmt(etag_info, nil, nil)
      return stmt_list
    end


    @@class_table = {}


    def self.register_class(lang, klass)
      @@class_table[lang] = klass
    end


    def self.get_class(lang)
      return @@class_table[lang]
    end


  end #class



  ##
  ## .[abstract] covnert presentation data into list of Statement.
  ##
  class Converter
    include ConverterHelper


    def initialize(handler, properties={})
      @handler = handler
      @handler.converter = self
    end

    attr_reader :handler   #, :dattr, :input


    ## .[abstract] convert string into list of Statement.
    def convert(input, filename='')
      not_implemented
    end


    @@class_table = {}


    def self.register_class(style, klass)
      @@class_table[style] = klass
    end


    def self.get_class(style)
      return @@class_table[style]
    end


  end



  ##
  ## convert presentation data (html) into a list of Statement.
  ## notice that TextConverter class hanlde html file as text format, not html format.
  ##
  class TextConverter < Converter


    def initialize(handler, properties={})
      super
      include_properties(properties)    # set @delspan and @dattr
    end


    def reset(input, filename)
      @scanner = StringScanner.new(input)
      @filename = filename
      @handler.filename = filename
      @rest = nil
      @linenum = 1
      @linenum_delta = 0
    end
    private :reset

    attr_reader :rest, :linenum


    def convert(input, filename='')
      reset(input, filename)
      stmt_list = []
      doc_ruleset = @handler.get_element_ruleset('DOCUMENT')
      stmt_list += doc_ruleset.before if doc_ruleset && doc_ruleset.before
      #stmt_list << NativeStatement.new(doc_ruleset.head.chomp, nil) if doc_ruleset && doc_ruleset.head
      _convert(stmt_list)
      stmt_list += doc_ruleset.after if doc_ruleset && doc_ruleset.after
      #stmt_list << NativeStatement.new(doc_ruleset.tail.chomp, nil) if doc_ruleset && doc_ruleset.tail
      return stmt_list
    end


    protected


    #FETCH_PATTERN= /([ \t]*)<(\/?)([-:_\w]+)((?:\s+[-:_\w]+="[^"]*?")*)(\s*)(\/?)>([ \t]*\r?\n?)/    #"
    @@fetch_pattern = /(.*?)((^[ \t]*)?<(\/?)([-:_\w]+)((?:\s+[-:_\w]+="[^"]*?")*)(\s*)(\/?)>([ \t]*\r?\n)?)/m    #"


    def self.fetch_pattern=(regexp)
      @@fetch_pattern = regexp
    end


    private


    def fetch
      str = @scanner.scan(@@fetch_pattern)
      unless str
        @rest = @scanner.scan(/.*/m)
        return nil
      end
      taginfo = TagInfo.new(@scanner)
      @linenum += (@linenum_delta + taginfo.prev_text.count("\n"))
      @linenum_delta = taginfo.tag_text.count("\n")
      taginfo.linenum = linenum
      return taginfo
    end


    def _convert(stmt_list, start_tag_info=nil, start_attr_info=nil)
      start_tagname = start_tag_info ? start_tag_info.tagname : nil
      start_linenum = @linenum

      ##
      while taginfo = fetch()
        #tag_text, prev_text, head_space, is_etag, tagname, attr_str, extra_space, is_empty, tail_space = taginfo.to_a

        prev_text = taginfo.prev_text
        stmt_list << create_text_print_stmt(prev_text) if prev_text && !prev_text.empty?

        if taginfo.is_etag?              # end tag

          if taginfo.tagname == start_tagname
            etag_info = taginfo
            return etag_info
          else
            stmt_list << create_text_print_stmt(taginfo.tag_text)
          end

        elsif taginfo.is_empty? || skip_etag?(taginfo)    # empty tag

          attr_info = AttrInfo.new(taginfo.attr_str)
          if has_directive?(attr_info, taginfo)
            stag_info  = taginfo
            etag_info  = nil
            cont_stmts = []
            handle_directive(stag_info, etag_info, cont_stmts, attr_info, stmt_list)
          else
            stmt_list << create_text_print_stmt(taginfo.tag_text)
          end

        else                            # start tag

          attr_info = AttrInfo.new(taginfo.attr_str)
          if has_directive?(attr_info, taginfo)
            stag_info  = taginfo
            cont_stmts = []
            etag_info  = _convert(cont_stmts, taginfo)
            handle_directive(stag_info, etag_info, cont_stmts, attr_info, stmt_list)
          elsif taginfo.tagname == start_tagname
            stag_info = taginfo
            stmt_list << create_text_print_stmt(stag_info.tag_text)
            etag_info = _convert(stmt_list, stag_info)
            stmt_list << create_text_print_stmt(etag_info.tag_text)
          else
            stmt_list << create_text_print_stmt(taginfo.tag_text)
          end

        end #if

      end #while

      if start_tag_info
        raise convert_error("'<#{start_tagname}>' is not closed.", start_tag_info.linenum)
      end

      stmt_list << create_text_print_stmt(@rest) if @rest
      nil

    end #def


    def handle_directive(stag_info, etag_info, cont_stmts, attr_info, stmt_list)
      directive_name = directive_arg = directive_str = nil
      append_exprs = nil

      ## handle 'attr:' and 'append:' directives
      d_str = nil
      attr_info.directive.split(/;/).each do |d_str|
        d_str.strip!
        unless d_str =~ @handler.directive_pattern     # ex. /\A(\w+):\s*(.*)\z/
          raise convert_error("'#{d_str}': invalid directive pattern", stag_info.linenum)
        end
        d_name = $1.intern   # directive name
        d_arg  = $2 || ''    # directive arg
        case d_name
        when :attr, :Attr, :ATTR
          @handler.handle(d_name, d_arg, d_str, stag_info, etag_info,
                          cont_stmts, attr_info, append_exprs, stmt_list)
        when :append, :Append, :APPEND
          append_exprs ||= []
          @handler.handle(d_name, d_arg, d_str, stag_info, etag_info,
                          cont_stmts, attr_info, append_exprs, stmt_list)
        else
          if directive_name
            raise convert_error("'#{d_str}': not available with '#{directive_name}' directive.", stag_info.linenum)
          end
          directive_name = d_name
          directive_arg  = d_arg
          directive_str  = d_str
        end #case
      end if attr_info.directive

      ## remove dummy <span> tag
      if @delspan && stag_info.tagname == 'span' && attr_info.empty?  && append_exprs.nil? && directive_name != :id
        stag_info.tagname = etag_info.tagname = nil
      end

      ## handle other directives
      ret = @handler.handle(directive_name, directive_arg, directive_str, stag_info, etag_info,
                            cont_stmts, attr_info, append_exprs, stmt_list)
      if directive_name && !ret
        raise convert_error("'#{directive_str}': unknown directive.", stag_info.linenum)
      end

    end


    ## detect whether directive is exist or not
    def has_directive?(attr_info, taginfo)
      ## title attribute
      val = attr_info[@dattr]     # ex. @dattr == 'title'
      if val && val.is_a?(String) && !val.empty?
        if val[0] == ?\  ;
          val[0,1] = ''     # delete a space
          taginfo.rebuild_tag_text(attr_info)
          #return false
        elsif val =~ @handler.directive_pattern()    # ex. /\A(\w+):\s*(.*)/
          attr_info.delete(@dattr)
          attr_info.directive = val
          return true
        else
          raise convert_error("'#{@dattr}=\"#{val}\"': invalid directive pattern.", taginfo.linenum)
        end
      end
      ## id attribute
      val = attr_info['id']
      if val
        case val
        when /\A\w+\z/
          attr_info.directive = @handler.directive_format() % ['mark', val]
          return true
        #when @handler.directive_pattern()     # ex. /\A\w+:/
        #  attr_info.delete('id')
        #  attr_info.directive = val
        #  return true
        when /\A(mark|dummy):(\w+)\z/,
             /\A(replace_(?:element|content)_with_(?:element|content)):(\w+)\z/
          attr_info.directive = @handler.directive_format() % [$1, $2]
          attr_info.delete('id')
          return true
        end
      end
      return false
    end


    skip_etags = Config::NO_ETAGS    #  %w[input img br hr meta link]
    #@@skip_etag_table = skip_etags.inject({}) { |table, tagname| table[tagname] = true; table }
    @@skip_etag_table = {} ; skip_etags.each { |tagname| @@skip_etag_table[tagname] = true }


    def skip_etag?(taginfo)
      return @@skip_etag_table[taginfo.tagname]
    end


  end #class
  Converter.register_class('text', TextConverter)



end #moduel
