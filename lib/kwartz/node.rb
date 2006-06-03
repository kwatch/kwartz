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


    def initialize(kind, name)
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
  ## .[abstract] ruleset entry in presentation logic file
  ##
  class Ruleset
  end



  ##
  ## represents '#name { ... }' entry in presentation logic file
  ##
  class ElementRuleset < Ruleset


    def initialize(name)
      @name = name
    end


    attr_accessor :name, :stag, :cont, :etag, :elem
    attr_accessor :value, :attrs, :append, :remove, :tagname, :logic


    def set_stag(str, escape_flag=nil)
      @stag = NativeExpression.new(str, escape_flag)
    end


    def set_cont(str, escape_flag=nil)
      @cont = NativeExpression.new(str, escape_flag)
    end


    def set_etag(str, escape_flag=nil)
      @etag = NativeExpression.new(str, escape_flag)
    end


    def set_elem(str, escape_flag=nil)
      @elem = NativeExpression.new(str, escape_flag)
    end


    def set_value(str, escape_flag=nil)
      set_cont(str, escape_flag)
    end


    def set_attrs(hash, escape_flag=nil)
      hash.each do |name, expr_str|
        next if !expr_str || expr_str.empty?
        @attrs ||= {}
        @attrs[name] = NativeExpression.new(expr_str, escape_flag)
      end if hash
    end


    def set_append(list, escape_flag=nil)
      list.each do |expr_str|
        next if !expr_str || expr_str.empty?
        @append ||= []
        @append << NativeExpression.new(expr_str, escape_flag)
      end
    end


    def set_remove(list)
      @remove = list if list
    end


    def set_tagname(str)
      @tagname = str if str
    end


    def set_logic(logic_str)
      return unless logic_str
      stmt_list = []
      logic_str.each_line do |line|
        if line =~ /^\s*_(stag|cont|etag|elem)(?:\(\))?;?\s*(?:\#.*)?$/
          kind = $1
          stmt_list << ExpandStatement.new(kind.intern, @name)
        elsif line =~ /^\s*(_(element|content)([()'"\w\s]*));?\s*(?:\#.*)?$/
          str, kind, arg  = $1, $2, $3
          arg.strip!
          if arg =~ /\A\((.*)\)\z/ then arg = $1 end
          if arg.empty?
            raise parse_error("'#{str}': element name required.", nil)
          end
          case arg
          when /\A"(.*)"\z/  ;  name = $1
          when /\A'(.*)'\z/  ;  name = $1
          when /\A(\w+)\z/   ;  name = $1
          else
            raise parse_error("'#{str}': invalid pattern.", nil)
          end
          unless name =~ /\A\w+\z/
            raise parse_error("'#{name}': invalid #{kind} name.", nil)
          end
          stmt_list << ExpandStatement.new(kind.intern, name)
        #elsif line =~ /^\s*print(?:\s+(\S+)|\((.+)\))\s*;?\s*(?:\#.*)?$/
        elsif line =~ /^\s*print(?:\s+(.*?)|\((.+)\))\s*;?\s*$/
          arg = $1 || $2
          stmt_list << PrintStatement.new([NativeExpression.new(arg)])
        else
          stmt_list << NativeStatement.new(line.chomp, nil)
        end
      end
      @logic = stmt_list
    end


    def duplicate(name)
      ruleset = dup()
      ruleset.name   = name
      ruleset.attrs  = @attrs.dup()  if @attrs
      ruleset.append = @append.dup() if @append
      ruleset.remove = @remove.dup() if @remove
      ruleset.logic  = @logic.dup()  if @logic
      return ruleset
    end


    def _inspect(indent=0)
      space = '  ' * indent
      sb = []
      sb << space <<   "- name: #{@name}\n"
      #sb << space <<   "  value: #{@value == nil ? '' : @value}\n"
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
      return sb.join
    end


    protected


    def parse_error(message, linenum)
      return ParseError.new(message, linenum, nil)
    end


  end #class



  ##
  ## represents '#DOUMENT { ... }' entry in presentation logic file
  ##
  class DocumentRuleset < Ruleset


    def initialize(name='DOCUMENT')
      @name = name
    end
    attr_accessor :name, :global, :local, :fixture, :begin, :end  #:before, :after

    def set_global(list)
      @global = list if list
    end

    def set_local(list)
      @local = list if list
    end

    def set_fixture(str)
      @fixture = NativeStatement.new(str.chomp, nil) if str
    end

    def set_begin(str)
      stmt_list = _parse_stmts(str)
      @begin = stmt_list
    end

    def set_end(str)
      stmt_list = _parse_stmts(str)
      @end = stmt_list
    end


    private


    def _parse_stmts(str)
      return unless str
      stmt_list = []
      str.each_line do |line|
        #if line =~ /^\s*print(?:\s+(.*?)|\((.+)\))\s*;?\s*(?:\#.*)?$/
        if line =~ /^\s*print(?:\s+(.*?)|\((.+)\))\s*;?\s*$/
          arg = $1 || $2
          stmt_list << PrintStatement.new([NativeExpression.new(arg)])
        else
          stmt_list << NativeStatement.new(line.chomp, nil)
        end
      end
      return stmt_list
    end


    public


    def _inspect(indent=0)
      space = '  ' * indent
      sb = []
      sb << space <<   "- name: #{@name}\n"
      if @global
        sb << space <<   "  global:\n"
        @global.each do |item|
          sb << space << "    - #{item}\n"
        end
      end
      if @local
        sb << space <<   "  local:\n"
        @local.each do |item|
          sb << space << "    - #{item}\n"
        end
      end
      if @begin
        sb << space << "  begin:\n"
        @begin.each do |stmt|
          sb << space << "    - #{stmt._inspect}"
        end
      end
      if @end
        sb << space << "  end:\n"
        @end.each do |stmt|
          sb << space << "    - #{stmt._inspect}"
        end
      end
      #
      return sb.join
    end


  end #class



end #module
