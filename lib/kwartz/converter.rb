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
require 'kwartz/util'

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


    def clear_as_dummy_tag    # delete <span> tag
      @tagname = nil
      @head_space = @tail_space = nil if @head_space && @tail_space
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
    end
    attr_reader :names, :values, :spaces


    def has?(name)
      return @values.key?(name)
    end


    def [](name)
      return @values[name]
    end


    def []=(name, value)
      @names << name unless has?(name)
      @values[name] = value
      @spaces[name] = ' ' unless @spaces.key?(name)
    end


    def each
      @names.each do |name|
        yield(@spaces[name], name, @values[name])
      end
    end


    def delete(name)
      if has?(name)
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


    def initialize(stag_info, etag_info, cont_stmts, attr_info, append_exprs)
      @stag_info    = stag_info      # TagInfo
      @etag_info    = etag_info      # TagInfo
      @cont_stmts   = cont_stmts     # list of Statement
      @attr_info    = attr_info      # AttrInfo
      @append_exprs = append_exprs   # list of NativeExpression
      @logic = [ ExpandStatement.new(:elem, @name) ]
    end

    attr_accessor :stag_info, :etag_info, :cont_stmts, :attr_info, :append_exprs
    attr_reader :stag_expr, :cont_expr, :etag_expr, :elem_expr
    attr_reader :logic, :before, :after
    attr_accessor :name
    attr_accessor :applied


    def self.create(values={})
      v = values
      return self.new(v[:name], v[:stag], v[:etag], v[:cont], v[:attr], v[:append])
    end


    def apply(ruleset)
      r = ruleset
      @stag_expr = _to_native_expr(r.stag) if r.stag
      @cont_expr = _to_native_expr(r.cont) if r.cont
      @etag_expr = _to_native_expr(r.etag) if r.etag
      @elem_expr = _to_native_expr(r.elem) if r.elem
      if @cont_expr
        @cont_stmts = [ PrintStatement.new([@cont_expr]) ]
        @stag_info.tail_space = ''
        @etag_info.head_space = ''
        @etag_info.rebuild_tag_text()
      end
      r.remove.each do |aname|
        @attr_info.delete(aname)
      end if r.remove
      r.attrs.each do |aname, avalue|
        @attr_info[aname] = _to_native_expr(avalue)
      end if r.attrs
      r.append.each do |expr|
        (@append_exprs ||= []) << _to_native_expr(expr)
      end if r.append
      @tagname = r.tagname if r.tagname
      @logic  = r.logic  if r.logic
      (@before ||= []).concat(r.before) if r.before
      (@after  ||= []).concat(r.after)  if r.after
    end


    def dummy_span_tag?(tagname='span')
      return @stag_info.tagname == tagname && @attr_info.empty?  && @append_exprs.nil?
    end


    private


    def _to_native_expr(value)
      return value && value.is_a?(String) ? NativeExpression.new(value) : value
    end


  end



  ##
  ##
  ##
  module ConvertErrorHelper       # :nodoc:


    ## return ConvertError
    def convert_error(message, linenum)
      return ConvertError.new(message, @filename, linenum)
    end


  end



  ##
  ##
  ##
  module HandlerHelper
    #include ConvertErrorHelper


    ## raise error if etag_info is null
    def error_if_empty_tag(elem_info, directive_str)
      unless elem_info.etag_info
        msg = "'#{directive_str}': directive is not available with empty tag."
        raise convert_error(msg, elem_info.stag_info.linenum)
      end
    end


    def error_when_last_stmt_is_not_if(elem_info, directive_str, stmt_list)
      kind = _last_stmt_kind(stmt_list)
      unless kind == :if || kind == :elseif
        msg = "'#{directive_str}': previous statement should be 'if' or 'elsif'."
        raise convert_error(msg, elem_info.stag_info.linenum)
      end
    end


    #private


    def _last_stmt_kind(stmt_list)
      return nil if stmt_list.nil? || stmt_list.empty?
      stmt = stmt_list.last
      return nil unless stmt.is_a?(NativeStatement)
      return stmt.kind
    end


    ## create print statement from text
    def create_text_print_stmt(text)
      return PrintStatement.new([text])
      #return PritnStatement.new([TextExpression.new(text)])
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
          native_expr = expand_attr_vars_in_native_expr(avalue, attr_info)
          args << sb     # TextExpression.new(sb)
          args << native_expr
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
        append_exprs.each do |append_expr|
          native_expr = expand_attr_vars_in_native_expr(append_expr, attr_info)
          args << native_expr
        end
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
    def build_print_expr_stmt(native_expr, stag_info, etag_info, attr_info=nil)
      head_space = (stag_info || etag_info).head_space
      tail_space = (etag_info || stag_info).tail_space
      native_expr = expand_attr_vars_in_native_expr(native_expr, attr_info) if attr_info
      args = []
      args << head_space if head_space    # TextExpression.new(head_space)
      args << native_expr
      args << tail_space if tail_space    # TextExpression.new(tail_space)
      return PrintStatement.new(args)
    end


    ## expand attribute variables (such as '$(rows)' or '$(value)') and return new code
    def expand_attr_vars(code, attr_info)
      new_code = code.gsub(/\$\((\w+(?::\w+)?)\)/) do |m|
        aname = $1
        #unless attrs.key?(aname)
        #  raise "#{m}: attribute '#{aname}' expected but not found."
        #end
        avalue = attr_info[aname]
        if avalue.is_a?(NativeExpression)
          raise "#{m}: attribute value of '#{aname}' is NativeExpression object."
        end
        avalue
      end
      return new_code
    end


    ## expand attribute variables and return new NativeExpression
    def expand_attr_vars_in_native_expr(native_expr, attr_info)
      code = expand_attr_vars(native_expr.code, attr_info)
      if code != native_expr.code
        native_expr = NativeExpression.new(code, native_expr.escape)
      end
      return native_expr
    end


    ## expand attribute variables and return new NativeExpression
    def expand_attr_vars_in_native_stmt(native_stmt, attr_info)
      code = expand_attr_vars(native_stmt.code, attr_info)
      if code != native_stmt.code
        no_newline = native_stmt.no_newline
        native_stmt = NativeStatement.new(code, native_stmt.kind)
        native_stmt.no_newline = no_newline unless no_newline.nil?
      end
      return native_stmt
    end


    ## build print statement of start-tag
    def stag_stmt(elem_info)
      e = elem_info
      return build_print_stmt(e.stag_info, e.attr_info, e.append_exprs)
    end


    ## build print statemetn of end-tag
    def etag_stmt(elem_info)
      return build_print_stmt(elem_info.etag_info, nil, nil)
    end


    def add_native_code(stmt_list, code, kind)
      if code.is_a?(String)
        stmt_list << NativeStatement.new(code, kind)
      elsif code.is_a?(Array)
        stmt_list.concat(code.collect {|line| NativeStatement.new(line, kind)})
      end
    end


    def wrap_element_with_native_stmt(elem_info, stmt_list, start_code, end_code, kind=nil)
      add_native_code(stmt_list, start_code, kind)
      stmt_list << stag_stmt(elem_info)
      stmt_list.concat(elem_info.cont_stmts)
      stmt_list << etag_stmt(elem_info)
      add_native_code(stmt_list, end_code, kind)
    end


    def wrap_content_with_native_stmt(elem_info, stmt_list, start_code, end_code, kind=nil)
      stmt_list << stag_stmt(elem_info)
      add_native_code(stmt_list, start_code, kind)
      stmt_list.concat(elem_info.cont_stmts)
      add_native_code(stmt_list, end_code, kind)
      stmt_list << etag_stmt(elem_info)
    end


    def add_foreach_stmts(elem_info, stmt_list, foreach_code, endforeach_code,
                          content_only, counter, toggle, init_code, incr_code, toggle_code)
      stmt_list << stag_stmt(elem_info)               if content_only
      start_code.split(/\n/).each do |code|
        stmt_list << NativeStatement.new(code, kind)
      end if start_code
      stmt_list << stag_stmt(elem_info)               if !content_only
      stmt_list.concat(elem_info.cont_stmts)
      stmt_list << etag_stmt(elem_info)               if !content_only
      end_code.split(/\n/).each do |code|
        stmt_list << NativeStatement.new(code, kind)
      end
      stmt_list << etag_stmt(elem_info)               if content_only
    end


    def add_native_expr_with_default(elem_info, stmt_list,
                                     expr_code, flag_escape,
                                     if_code, else_code, endif_code)
      stmt_list << stag_stmt(elem_info)
      stmt_list << NativeStatement.new_without_newline(if_code, :if)
      stmt_list << PrintStatement.new([ NativeExpression.new(expr_code, flag_escape) ])
      stmt_list << NativeStatement.new_without_newline(else_code, :else)
      stmt_list.concat(elem_info.cont_stmts)
      stmt_list << NativeStatement.new_without_newline(endif_code, :else)
      stmt_list << etag_stmt(elem_info)
    end


  end



  ##
  ## (abstract) expand ExpandStatement and ElementInfo
  ##
  ## Handler class includes this module.
  ##
  module Expander
    include Assertion


    ## (abstract) get Ruleset
    def get_ruleset(selector)
      not_implemented
    end


    ## (abstract) get ElementInfo
    def get_element_info(name)
      not_implemented
    end


    ## expand ElementInfo
    def expand_element_info(elem_info, stmt_list, content_only=false)
      expand_statements(elem_info.before, stmt_list, elem_info) if elem_info.before
      stmts = content_only ? [ ExpandStatement.new(:cont) ] : elem_info.logic
      stmts.each do |stmt|
        expand_statement(stmt, stmt_list, elem_info)
      end
      expand_statements(elem_info.after, stmt_list, elem_info) if elem_info.after
    end


    ## expand list of ExpandStatement
    def expand_statements(stmts, stmt_list, elem_info)
      stmts.each do |stmt|
        expand_statement(stmt, stmt_list, elem_info)
      end
    end


    ## expand ExpandStatement
    def expand_statement(stmt, stmt_list, elem_info)

      if stmt.is_a?(NativeStatement)
        if elem_info
          native_stmt = expand_attr_vars_in_native_stmt(stmt, elem_info.attr_info)
        else
          native_stmt = stmt
        end
        stmt_list << native_stmt
        return
      end

      if ! stmt.is_a?(ExpandStatement)
        stmt_list << stmt
        return
      end

      e = elem_info

      ## remove dummy <span> tag
      if @delspan && elem_info && elem_info.dummy_span_tag?('span')
        #e.stag_info.tagname = e.etag_info.tagname = nil
        e.stag_info.clear_as_dummy_tag()
        e.etag_info.clear_as_dummy_tag()
      end

      case stmt.kind

      when :stag
        assert unless elem_info
        if e.stag_expr
          assert unless e.stag_expr.is_a?(NativeExpression)
          stmt_list << build_print_expr_stmt(e.stag_expr, e.stag_info, nil, e.attr_info)
        else
          stmt_list << build_print_stmt(e.stag_info, e.attr_info, e.append_exprs)
        end

      when :etag
        assert unless elem_info
        if e.etag_expr
          assert unless e.etag_expr.is_a?(NativeExpression)
          stmt_list << build_print_expr_stmt(e.etag_expr, nil, e.etag_info, e.attr_info)
        elsif e.etag_info    # e.etag_info is nil when <br>, <input>, <hr>, <img>, <meta>
          stmt_list << build_print_stmt(e.etag_info, nil, nil)
        end

      when :cont
        if e.cont_expr
          assert unless e.cont_expr.is_a?(NativeExpression)
          #stmt_list << PrintStatement.new([e.cont_expr])
          native_expr = expand_attr_vars_in_native_expr(e.cont_expr, e.attr_info)
          stmt_list << PrintStatement.new([native_expr])
        else
          elem_info.cont_stmts.each do |cont_stmt|
            expand_statement(cont_stmt, stmt_list, nil)
          end
        end

      when :elem
        assert unless elem_info
        if e.elem_expr
          assert unless e.elem_expr.is_a?(NativeExpression)
          stmt_list << build_print_expr_stmt(e.elem_expr, e.stag_info, e.etag_info, e.attr_info)
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
    end


  end #module



  ##
  ## directive
  ##
  class Directive


    def initialize(args={})
      @name   = args[:name]
      @arg    = args[:arg]
      @dattr  = args[:dattr]
      @str    = args[:str]
      @linenum = args[:linenum]
    end


    attr_accessor :name, :arg, :dattr, :str, :linenum


  end



  ##
  ## (abstract) handle directives
  ##
  class Handler
    include Assertion
    include ConvertErrorHelper
    include HandlerHelper
    include Expander


    def initialize(rulesets=[], properties={})
      @ruleset_table = {}
      rulesets.each { |ruleset| _register_ruleset(ruleset) }
      @elem_info_table = {}
      @delspan = properties.fetch(:delspan, Config::PROPERTY_DELSPAN)  # delete dummy <span> tag or not
      @odd     = properties.fetch(:odd,     Config::PROPERTY_ODD)      # "'odd'"
      @even    = properties.fetch(:even,    Config::PROPERTY_EVEN)     # "'even'"
    end
    attr_reader :odd, :even
    attr_accessor :filename


    def _register_ruleset(ruleset)
      ruleset.selectors.each do |selector|
        r = @ruleset_table[selector]
        @ruleset_table[selector] = r ? r.merge(ruleset) : ruleset
      end
    end
    private :_register_ruleset


    def get_ruleset(selector)  # for Expander module and Converter class
      return @ruleset_table[selector]
    end


    def get_element_info(name)  # for Expander module
      return @elem_info_table[name]
    end


    def register_element_info(name, elem_info)
      @elem_info_table[name] = elem_info
    end


    def _elem_info_table    # :nodoc:
      return @elem_info_table
    end


    def _import_element_info_from_handler(handler, names=nil) # :nodoc:
      if names
        regexp_list = names.collect { |name| Kwartz::Util.pattern_to_regexp(name) }
        handler._elem_info_table.each do |name, elem_info|
          if regexp_list.any? { |regexp| regexp =~ name }
            @elem_info_table[name] = elem_info
          end
        end
      else
        @elem_info_table.update(handler._elem_info_table)
      end
    end


    protected


    ## (abstract) directive pattern, which is used to detect directives.
    def directive_pattern
      not_implemented
      #return /\A(\w+):\s*(.*)/
    end


    ## (abstract) mapping pattern, which is used to parse 'attr' directive.
    def mapping_pattern
      not_implemented
      #return /\A'([-:\w]+)'\s+(.*)/
    end


    ## (abstract) convert universal expression string to native expression string
    def parse_expr_str(expr_str, linenum)
      not_implemented
    end


    public


    def handle_directives(directive, elem_info, stmt_list)
      e = elem_info
      linenum = elem_info.stag_info.linenum
      append_exprs = nil

      if directive.dattr == 'id'
        ## nothing
      else
        ## handle 'attr:' and 'append:' directives
        d_str = nil
        directive.str.split(/;/).each do |d_str|
          d_str.strip!
          unless d_str =~ self.directive_pattern     # ex. /\A(\w+):\s*(.*)\z/
            raise convert_error("'#{d_str}': invalid directive pattern", linenum)
          end
          d_name = $1.intern   # directive name
          d_arg  = $2 || ''    # directive arg
          case d_name
          when :attr, :Attr, :ATTR
            directive2 = Directive.new(:name=>d_name, :arg=>d_arg, :sr=>d_str)
            handle(directive2, elem_info, stmt_list)
          when :append, :Append, :APPEND
            append_exprs ||= []
            elem_info.append_exprs = append_exprs
            directive2 = Directive.new(:name=>d_name, :arg=>d_arg, :sr=>d_str)
            handle(directive2, elem_info, stmt_list)
          else
            if directive.name
              raise convert_error("'#{d_str}': not available with '#{directive.name}' directive.", linenum)
            end
            directive.name = d_name
            directive.arg  = d_arg
            directive.str  = d_str
          end #case
        end
      end

      ## remove dummy <span> tag
      if @delspan && elem_info.dummy_span_tag?('span')
        #e.stag_info.tagname = e.etag_info.tagname = nil
        e.stag_info.clear_as_dummy_tag()
        e.etag_info.clear_as_dummy_tag()
      end

      ## handle other directives
      if directive.name
        handled = handle(directive, elem_info, stmt_list)
        handled or raise convert_error("'#{directive.str}': unknown directive.", linenum)
      else   # for 'attr' and 'append' directive
        assert unless !elem_info.attr_info.empty? || !elem_info.append_exprs.empty?
        stmt_list << stag_stmt(elem_info)
        stmt_list.concat(elem_info.cont_stmts)
        stmt_list << etag_stmt(elem_info) if elem_info.etag_info   # when empty-tag
      end

    end


    ## handle directives ('stag', 'etag', 'elem', 'cont'(='value'))
    ##
    ## return true if directive name is one of 'stag', 'etag', 'elem', 'cont', and 'value',
    ## else return false.
    def handle(directive, elem_info, stmt_list)
      d_name = directive.name
      d_arg  = directive.arg
      d_str  = directive.str
      d_attr = directive.dattr
      e = elem_info
      linenum = e.stag_info.linenum

      case d_name

      when nil
        assert false

      when :dummy
        # nothing

      when :id, :mark
        unless d_arg =~ /\A([-\w]+)\z/ || d_arg =~ /\A'([-\w]+)'\z/
          raise convert_error("'#{d_str}': invalid marking name.", linenum)
        end
        name = $1
        if get_element_info(name)
          unless Config::ALLOW_DUPLICATE_ID
            previous_linenum = get_element_info(name).stag_info.linenum
            msg = "'#{d_str}': id '#{name}' is already used at line #{previous_linenum}."
            raise convert_error(msg, linenum)
          end
        end
        ruleset = get_ruleset('#' + name)
        elem_info.apply(ruleset) if ruleset
        register_element_info(name, elem_info)
        #stmt_list << ExpandStatement.new(:element, name)     # lazy expantion
        expand_element_info(elem_info, stmt_list)

      when :stag, :Stag, :STAG
        error_if_empty_tag(elem_info, d_str)
        flag_escape = d_name == :stag ? nil : (d_name == :Stag)
        expr_str = d_attr == 'id' ? parse_expr_str(d_arg, linenum) : d_arg
        expr = NativeExpression.new(expr_str, flag_escape)
        stmt_list << build_print_expr_stmt(expr, e.stag_info, nil)
        stmt_list.concat(e.cont_stmts)
        stmt_list << etag_stmt(elem_info)

      when :etag, :Etag, :ETAG
        error_if_empty_tag(elem_info, d_str)
        flag_escape = d_name == :etag ? nil : (d_name == :Etag)
        expr_str = d_attr == 'id' ? parse_expr_str(d_arg, linenum) : d_arg
        expr = NativeExpression.new(expr_str, flag_escape)
        stmt_list << stag_stmt(elem_info)
        stmt_list.concat(e.cont_stmts)
        stmt_list << build_print_expr_stmt(expr, nil, e.etag_info)

      when :elem, :Elem, :ELEM
        flag_escape = d_name == :elem ? nil : (d_name == :Elem)
        expr_str = d_attr == 'id' ? parse_expr_str(d_arg, linenum) : d_arg
        expr = NativeExpression.new(expr_str, flag_escape)
        stmt_list << build_print_expr_stmt(expr, e.stag_info, e.etag_info)

      when :cont, :Cont, :CONT, :value, :Value, :VALUE
        error_if_empty_tag(elem_info, directive.str)
        e.stag_info.tail_space = e.etag_info.head_space = nil    # delete spaces
        pargs = build_print_args(e.stag_info, e.attr_info, e.append_exprs)
        flag_escape = (d_name == :cont || d_name == :value) ? nil : (d_name == :Cont || d_name == :Value)
        expr_str = d_attr == 'id' ? parse_expr_str(d_arg, linenum) : d_arg
        pargs << NativeExpression.new(expr_str, flag_escape)
        pargs << e.etag_info.tag_text if e.etag_info.tagname
        stmt_list << PrintStatement.new(pargs)

      when :attr, :Attr, :ATTR
        unless d_arg =~ self.mapping_pattern()     # ex. /\A'([-:\w]+)'\s+(.*)\z/
          raise convert_error("'#{d_str}': invalid attr pattern.", linenum)
        end
        aname = $1;  avalue = $2
        flag_escape = d_name == :attr ? nil : (d_name == :Attr)
        expr_str = d_attr == 'id' ? parse_expr_str(avalue, linenum) : avalue
        e.attr_info[aname] = NativeExpression.new(expr_str, flag_escape)

      when :append, :Append, :APPEND
        flag_escape = d_name == :append ? nil : (d_name == :Append)
        expr_str = d_attr == 'id' ? parse_expr_str(d_arg, linenum) : d_arg
        e.append_exprs << NativeExpression.new(expr_str, flag_escape)

      when :replace_element_with_element, :replace_element_with_content,
           :replace_content_with_element, :replace_content_with_content
        arr = d_name.to_s.split(/_/)
        replace_cont = arr[1] == 'content'
        with_content = arr[3] == 'content'
        name = d_arg
        #
        error_if_empty_tag(elem_info, d_str)   if replace_cont
        stmt_list << stag_stmt(elem_info) if replace_cont
        #stmt_list << ExpandStatement.new(:element, name)
        elem_info2 = @elem_info_table[name]
        unless elem_info
          raise convert_error("'#{d_str}': element '#{name}' not found.", linenum)
        end
        expand_element_info(elem_info2, stmt_list, with_content)
        stmt_list << etag_stmt(elem_info) if replace_cont

      when :replace_element_with, :replace_content_with, :replace, :placeholder
        unless d_arg =~ /\A_?(element|content)\(["']?(\w+)["']?\)\z/
          raise convert_error("'#{d_str}': invalid #{d_name} format.", linenum)
        end
        kind = $1
        name = $2
        replace_cont = d_name == :replace_content_with || d_name == :placeholder
        with_content = kind == 'content'
        #
        error_if_empty_tag(elem_info, d_str) if replace_cont
        stmt_list << stag_stmt(elem_info) if replace_cont
        #stmt_list << ExpandStatement.new(:element, name)
        elem_info2 = @elem_info_table[name]
        unless elem_info2
          msg = "'#{d_str}': element '#{name}' not found."
          raise convert_error(msg, linenum)
        end
        expand_element_info(elem_info2, stmt_list, with_content)
        stmt_list << etag_stmt(elem_info) if replace_cont

      else
        return false
      end #case

      return true

    end


    def apply_rulesets(elem_info)
      assert unless !elem_info.applied
      elem_info.applied = true
      tagname = elem_info.stag_info.tagname
      classname = elem_info.attr_info['class']
      #idname = elem_info.name || elem_info.attr_info['id']
      ruleset = nil
      elem_info.apply(ruleset) if ruleset = get_ruleset(tagname)
      elem_info.apply(ruleset) if classname && (ruleset = get_ruleset('.'+classname))
      #elem_info.apply(ruleset) if idname && (ruleset = get_ruleset('#'+idname))
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
  ## (abstract) covnert presentation data into list of Statement.
  ##
  class Converter
    include ConvertErrorHelper


    def initialize(handler, properties={})
      @handler = handler
    end

    attr_reader :handler   #, :dattr, :input


    ## (abstract) convert string into list of Statement.
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
      @dattr = properties.fetch(:dattr, Config::PROPERTY_DATTR)    # default: 'kw:d'
    end


    ## called from convert() and initialize converter object
    def reset(input, filename)
      @scanner = StringScanner.new(input)
      @filename = filename
      @handler.filename = filename
      @rest = nil
      @linenum = 1
      @linenum_delta = 0
    end
    protected :reset


    attr_reader :rest, :linenum


    def convert(input, filename='')
      reset(input, filename)
      stmt_list = []
      _convert(stmt_list)
      ruleset = @handler.get_ruleset('#DOCUMENT')
      if ruleset
        stmt_list2 = []
        elem_info = nil
        r = ruleset
        @handler.expand_statements(r.before, stmt_list2, elem_info) if r.before
        if r.logic
          @handler.expand_statements(r.logic, stmt_list2, elem_info)
        else
          stmt_list2.concat(stmt_list)
        end
        @handler.expand_statements(r.after,  stmt_list2, elem_info) if r.after
        stmt_list = stmt_list2
      end
      return stmt_list
    end


    protected


    #FETCH_PATTERN= /([ \t]*)<(\/?)([-:_\w]+)((?:\s+[-:_\w]+="[^"]*?")*)(\s*)(\/?)>([ \t]*\r?\n?)/    #"
    @@fetch_pattern = /(.*?)((^[ \t]*)?<(\/?)([-:_\w]+)((?:\s+[-:_\w]+="[^"]*?")*)(\s*)(\/?)>([ \t]*\r?\n)?)/m    #"


    def self.fetch_pattern=(regexp)
      @@fetch_pattern = regexp
    end


    def match_ruleset(taginfo, attr_info)
      idname = attr_info['id']
      return true if idname && @handler.get_ruleset("#"+idname)
      classname = attr_info['class']
      return true if classname && @handler.get_ruleset("."+classname)
      return @handler.get_ruleset(taginfo.tagname) ? true : false
    end


    private


    def _fetch
      str = @scanner.scan(@@fetch_pattern)
      unless str
        @rest = @scanner.scan(/.*/m)
        return nil
      end
      taginfo = TagInfo.new(@scanner)
      @linenum += (@linenum_delta + taginfo.prev_text.count("\n"))
      @linenum_delta = taginfo.tag_text.count("\n")
      taginfo.linenum = @linenum
      return taginfo
    end


    def _convert(stmt_list, start_tag_info=nil)
      start_tagname = start_tag_info ? start_tag_info.tagname : nil
      start_linenum = @linenum

      ##
      while taginfo = _fetch()
        #tag_text, prev_text, head_space, is_etag, tagname, attr_str, extra_space, is_empty, tail_space = taginfo.to_a

        prev_text = taginfo.prev_text
        stmt_list << _create_text_print_stmt(prev_text) if prev_text && !prev_text.empty?

        if taginfo.is_etag?              # end tag

          if taginfo.tagname == start_tagname
            etag_info = taginfo
            return etag_info
          else
            stmt_list << _create_text_print_stmt(taginfo.tag_text)
          end

        elsif taginfo.is_empty? || skip_etag?(taginfo)    # empty tag

          attr_info = AttrInfo.new(taginfo.attr_str)
          directive = _get_directive(attr_info, taginfo)
          if directive
            stag_info  = taginfo
            etag_info  = nil
            cont_stmts = []
            elem_info = ElementInfo.new(stag_info, etag_info, cont_stmts, attr_info, nil)
            @handler.apply_rulesets(elem_info)
            @handler.handle_directives(directive, elem_info, stmt_list)
          else
            stmt_list << _create_text_print_stmt(taginfo.tag_text)
          end

        else                            # start tag

          attr_info = AttrInfo.new(taginfo.attr_str)
          directive = _get_directive(attr_info, taginfo)
          if directive
            stag_info  = taginfo
            cont_stmts = []
            etag_info  = _convert(cont_stmts, stag_info)
            elem_info = ElementInfo.new(stag_info, etag_info, cont_stmts, attr_info, nil)
            @handler.apply_rulesets(elem_info)
            @handler.handle_directives(directive, elem_info, stmt_list)
          elsif match_ruleset(taginfo, attr_info)
            stag_info = taginfo
            cont_stmts = []
            etag_info = _convert(cont_stmts, stag_info)
            elem_info = ElementInfo.new(stag_info, etag_info, cont_stmts, attr_info, nil)
            @handler.apply_rulesets(elem_info)
            @handler.expand_element_info(elem_info, stmt_list)
          elsif taginfo.tagname == start_tagname
            stag_info = taginfo
            stmt_list << _create_text_print_stmt(stag_info.tag_text)
            etag_info = _convert(stmt_list, stag_info)
            stmt_list << _create_text_print_stmt(etag_info.tag_text)
          else
            stmt_list << _create_text_print_stmt(taginfo.tag_text)
          end

        end #if

      end #while

      if start_tag_info
        raise convert_error("'<#{start_tagname}>' is not closed.", start_tag_info.linenum)
      end

      stmt_list << _create_text_print_stmt(@rest) if @rest
      nil

    end #def


    ## get directive object
    def _get_directive(attr_info, taginfo)
      ## kw:d attribute
      val = attr_info[@dattr]     # ex. @dattr == 'kw:d'
      if val && val.is_a?(String) && !val.empty?
        if val[0] == ?\  ;
          val[0,1] = ''     # delete a space
          taginfo.rebuild_tag_text(attr_info)
          #return false
        elsif val =~ @handler.directive_pattern()    # ex. /\A(\w+):\s*(.*)/
          attr_info.delete(@dattr)
          #directive = Directive.new(:name=>$1.intern, :arg=>$2, :dattr=>@dattr, :str=>val)
          directive = Directive.new(:dattr=>@dattr, :str=>val)
          return directive
        else
          raise convert_error("'#{@dattr}=\"#{val}\"': invalid directive pattern.", taginfo.linenum)
        end
      end
      ## id attribute
      val = attr_info['id']
      if val
        case val
        when /\A[-\w]+\z/
          directive = Directive.new(:name=>:mark, :arg=>val, :dattr=>'id', :str=>val)
          return directive
        #when @handler.directive_pattern()     # ex. /\A(\w+):(.*)/
        #  attr_info.delete('id')
        #  directive = Directive.new(:name=>$1.intern, :arg=>$2, :dattr=>'id', :str=>val)
        #  return directive
        when /\A(mark|dummy):([-\w]+)\z/,
             /\A(value|stag|cont|etag|elem|default):(.*)\z/i,
             /\A(replace_[a-z]+_with_[a-z]+):([-\w]+)\z/
          attr_info.delete('id')
          directive = Directive.new(:name=>$1.intern, :arg=>$2, :dattr=>'id', :str=>val)
          return directive
        end
      end
      return nil
    end


    skip_etags = Config::NO_ETAGS    #  %w[input img br hr meta link]
    #@@skip_etag_table = skip_etags.inject({}) { |table, tagname| table[tagname] = true; table }
    @@skip_etag_table = {} ; skip_etags.each { |tagname| @@skip_etag_table[tagname] = true }


    def skip_etag?(taginfo)
      return @@skip_etag_table[taginfo.tagname]
    end


    def _create_text_print_stmt(text)
      return PrintStatement.new([text])
      #return PritnStatement.new([TextExpression.new(text)])
    end


  end #class
  Converter.register_class('text', TextConverter)



end #moduel
