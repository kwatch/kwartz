####
#### $Rev$
#### $Release$
#### $Copyright$
####

require 'abstract'


module Kwartz



  ##
  ## .[abstract] abstract class for Expression and Statement
  ##
  class Node


    ##
    ## .[abstract] accept visitor
    ##
    def accept(translator)
      not_implemented
    end


  end



  ##
  ## .[abstract] expression
  ##
  class Expression < Node
  end



  ##
  ## represents expression in target language code
  ##
  class NativeExpression < Expression


    def initialize(code, escape=nil)
      @code = code
      @escape = escape unless escape == nil
    end
    attr_reader :code
    attr_accessor :escape

    alias escape? escape


    def _inspect(indent=0)
      return @code
    end


    def accept(translator)
      translator.translate_native_expr(self)
    end


  end


#--
#  ##
#  ## represents normal text
#  ##
#  class TextExpression < Expression
#
#
#    def initialize(text)
#      @text = text
#    end
#
#
#    attr_accessor :text
#
#
#    def _inspect(indent=0)
#      return @text
#    end
#
#
#    def accept(translator)
#      translator.translate_text_expr(self)
#    end
#
#
#  end
#++


  ##
  ## .[abstract] statement class
  ##
  class Statement < Node
  end



  ##
  ## represents statement in target language code
  ##
  class NativeStatement < Statement


    def initialize(code, kind=nil)
      @code = code
      @kind = kind
    end
    attr_reader :code, :kind
    attr_accessor :no_newline


    def self.new_without_newline(code, kind=nil)
      stmt = self.new(code, kind)
      stmt.no_newline = true
      return stmt
    end


    def _inspect(indent=0)
      return "<%#{@code}%>\n"
    end


    def accept(translator)
      translator.translate_native_stmt(self)
    end


  end



  ##
  ## represents _stag, _cont, _etag, _elem, _element(name), and _content(name)
  ##
  class ExpandStatement < Statement


    def initialize(kind, name=nil)
      @kind = kind    # symbol
      @name = name    # string
    end
    attr_accessor :kind
    attr_reader :name


    def _inspect(indent=0)
      if @kind == :element || @kind == :content
        return "_#{@kind}(#{@name})\n"
      else
        return "_#{@kind}\n"
      end
    end


    def accept(translator)
      assert
    end


  end



  ##
  ## represents print statement for String and NativeExpression
  ##
  class PrintStatement < Statement


    def initialize(args)
      @args = args    # array
    end
    attr_reader :args


    def _inspect(indent=0)
      list = @args.collect { |arg|
        arg.is_a?(NativeExpression) ? "<%=#{arg.code}%>" : arg.inspect
      }
      return "print(" + list.join(', ') + ")\n"
    end


    def accept(translator)
      translator.translate_print_stmt(self)
    end


  end



  ##
  ## ruleset in presentation logic file
  ##
  class Ruleset


    def initialize(selectors)
      @selectors = selectors      # list of string ('#id', '.class', or 'tagname')
    end
    attr_accessor :selectors
    attr_accessor :stag, :cont, :etag, :elem   # NativeExpression
    attr_accessor :attrs     # Hash(key: attribute name, value: NativeExpression)
    attr_accessor :append    # list of NativeExpression
    attr_accessor :remove    # list of attribute name
    attr_accessor :tagname   # string
    attr_accessor :logic, :before, :after   # block statement


    def set_stag(str, flag_escape=nil)
      @stag = NativeExpression.new(str, flag_escape)
    end


    def set_cont(str, flag_escape=nil)
      @cont = NativeExpression.new(str, flag_escape)
    end


    def set_etag(str, flag_escape=nil)
      @etag = NativeExpression.new(str, flag_escape)
    end


    def set_elem(str, flag_escape=nil)
      @elem = NativeExpression.new(str, flag_escape)
    end


    def set_value(str, flag_escape=nil)
      set_cont(str, flag_escape)
    end


    def set_attrs(hash, flag_escape=nil)
      hash.each do |aname, expr_str|
        next if !expr_str || expr_str.empty?
        @attrs ||= {}
        @attrs[aname] = NativeExpression.new(expr_str, flag_escape)
      end if hash
    end


    def set_append(list, flag_escape=nil)
      list.each do |expr_str|
        next if !expr_str || expr_str.empty?
        @append ||= []
        @append << NativeExpression.new(expr_str, flag_escape)
      end
    end


    def set_remove(list)
      @remove = list if list
    end


    def set_tagname(str)
      @tagname = str if str
    end


    def set_logic(logic_str)
      stmt_list = _parse_logic_str(logic_str)
      @logic = stmt_list
    end


    def set_before(logic_str)
      stmt_list = _parse_logic_str(logic_str)
      @before = stmt_list
    end


    def set_after(logic_str)
      stmt_list = _parse_logic_str(logic_str)
      @after = stmt_list
    end


    def _parse_logic_str(logic_str)
      return unless logic_str
      stmt_list = []
      logic_str.each_line do |line|
        if line =~ /^\s*_(stag|cont|etag|elem)(?:\(\))?;?\s*(?:\#.*)?$/
          kind = $1
          stmt_list << ExpandStatement.new(kind.intern)
        elsif line =~ /^\s*(_(element|content)([-()'"\w\s]*));?\s*(?:\#.*)?$/
          str, kind, arg  = $1, $2, $3
          arg.strip!
          if arg =~ /\A\((.*)\)\z/ then arg = $1 end
          if arg.empty?
            raise parse_error("'#{str}': element name required.", nil)
          end
          case arg
          when /\A"(.*)"\z/   ;  name = $1
          when /\A'(.*)'\z/   ;  name = $1
          when /\A([-\w]+)\z/ ;  name = $1
          else
            raise parse_error("'#{str}': invalid pattern.", nil)
          end
          unless name =~ /\A[-\w]+\z/
            raise parse_error("'#{name}': invalid #{kind} name.", nil)
          end
          stmt_list << ExpandStatement.new(kind.intern, name)
        #elsif line =~ /^\s*print(?:\s+(\S+)|\((.+)\))\s*;?\s*(?:\#.*)?$/
        elsif line =~ /^\s*print(?:\s+(.*?)|\((.*)\))\s*;?\s*$/
          arg = $1 || $2
          stmt_list << PrintStatement.new([NativeExpression.new(arg)])
        else
          stmt_list << NativeStatement.new(line.chomp, nil)
        end
      end
      return stmt_list
    end


    def duplicate()
      ruleset = dup()
      r = ruleset
      r.selectors = nil
      r.attrs  = @attrs.dup()  if @attrs
      r.append = @append.dup() if @append
      r.remove = @remove.dup() if @remove
      r.logic  = @logic.dup()  if @logic
      r.before = @before.dup() if @before
      r.after  = @after.dup()  if @after
      return r
    end


    def merge(ruleset)
      r = ruleset
      r2 = duplicate()
      r2.stag  = r.stag  if r.stag
      r2.etag  = r.etag  if r.etag
      r2.cont  = r.cont  if r.cont
      r2.attrs.update(r.attrs) if r.attrs
      r2.append += r.append if r.append
      r2.remove += r.remove if r.remove
      r2.tagname = r.tagname if r.tagname
      r2.logic  = r.logic  if r.logic
      r2.before = r.before if r.before
      r2.after  = r.after  if r.after
      return r2
    end


    def _inspect(indent=0)
      space = '  ' * indent
      sb = []
      sb << space <<   "- selectors: #{@selectors.inspect}\n"
      sb << space <<   "  stag: #{@stag.code}\n" unless @stag.nil?
      sb << space <<   "  cont: #{@cont.code}\n" unless @cont.nil?
      sb << space <<   "  etag: #{@etag.code}\n" unless @etag.nil?
      sb << space <<   "  elem: #{@elem.code}\n" unless @elem.nil?
      #
      sb << space <<   "  attrs:\n" if @attrs
      @attrs.keys.sort.each do |key|
        val = @attrs[key]
        sb << space << "    - name:  #{key}\n"
        sb << space << "      value: #{val.code}\n"
      end if @attrs
      #
      sb << space <<   "  append:\n" if @append
      @append.each do |expr|
        sb << space << "    - #{expr.code}\n"
      end if @append
      #
      sb << space <<   "  remove:\n" if @remove
      @remove.each do |name|
        sb << space << "    - #{name}\n"
      end if @remove
      #
      sb << space <<   "  tagname: #{@tagname}\n" unless @tagname.nil?
      #
      sb << space <<   "  logic:\n" if @logic
      @logic.each do |stmt|
        sb << space << "    - " << stmt._inspect()
      end if @logic
      #
      sb << space <<   "  before:\n" if @before
      @before.each do |stmt|
        sb << space << "    - " << stmt._inspect()
      end if @before
      #
      sb << space <<   "  after:\n" if @after
      @after.each do |stmt|
        sb << space << "    - " << stmt._inspect()
      end if @after
      #
      return sb.join
    end


    protected


    def parse_error(message, linenum)
      return ParseError.new(message, linenum, nil)
    end


  end #class


end #module
