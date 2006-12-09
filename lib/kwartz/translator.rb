####
#### $Rev$
#### $Release$
#### $Copyright$
####


require 'kwartz/node'
require 'abstract'



module Kwartz


  ##
  ## .[abstract] translate list of Statement into target code (eRuby, PHP, ...)
  ##
  class Translator


    ## .[abstract] translate list of Statement into String and return it
    def translate(stmt_list)
      not_implemented
    end


    ## .[abstract] translate NativeStatement using visitor pattern
    def translate_native_stmt(stmt)
      not_implemented
    end


    ## .[abstract] translate PrintStatement using visitor pattern
    def translate_print_stmt(stmt)
      not_implemented
    end


    ## .[abstract] translate NativeExpression using visitor pattern
    def translate_native_expr(expr)
      not_implemented
    end


    ## .[abstract] translate String using visitor pattern
    def translate_string(str)
      not_implemented
    end


#    ## [abstract] translate TextExpression using visitor pattern
#    def translate_text_expr(expr)
#      not_implemented
#    end


    @@class_table = {}


    def self.register_class(lang, klass)
      @@class_table[lang] = klass
    end


    def self.get_class(lang)
      return @@class_table[lang]
    end


  end #class



  ##
  ## concrete class for visitor pattern
  ##
  ## see ErbTranslator, PhpTranslator, JstlTranslator, and so on for detail.
  ##
  class BaseTranslator < Translator


    def initialize(marks=[], properties={})
      @stmt_l, @stmt_r, @expr_l, @expr_r, @escape_l, @escape_r = marks
      @nl = properties[:nl] || "\n"
      @escape = properties[:escape]
      @escape = Config::PROPERTY_ESCAPE if @escape == nil
      @header = properties[:header]
      @footer = properties[:footer]
    end


    attr_accessor :escape, :header, :footer


    def translate(stmt_list)
      @sb = ''
      @sb << @header if @header
      stmt_list.each do |stmt|
        stmt.accept(self)
      end
      @sb << @footer if @footer
      return @sb
    end


    def translate_native_stmt(stmt)
      @sb << @stmt_l << stmt.code << @stmt_r   # ex. <% stmt.code %>
      @sb << @nl unless stmt.no_newline
    end


    def translate_print_stmt(stmt)
      stmt.args.each do |arg|
        #arg.accept(self)
        if arg.is_a?(String)
          #translate_string(arg)
          parse_embedded_expr(arg)
        elsif arg.is_a?(NativeExpression)
          translate_native_expr(arg)
        else
          assert
        end
      end
    end


    def translate_native_expr(expr)
      assert unless expr.is_a?(NativeExpression)
      flag_escape = expr.escape?
      flag_escape = @escape if flag_escape == nil
      if flag_escape
        add_escaped_expr(expr.code)
      else
        add_plain_expr(expr.code)
      end
    end


    def translate_string(str)
      @sb << str
    end


#    def translate_text_expr(expr)
#      @sb << expr.text
#    end


    protected


    def parse_embedded_expr(text)
      pos = 0
      text.scan(/@(!*)\{(.*?)\}@/) do |indicator, expr_str|
        m = Regexp.last_match
        s = text[pos, m.begin(0) - pos]
        pos = m.end(0)
        translate_string(s) unless s.empty?
        expr_str = parse_expr_str!(expr_str)
        case indicator
        when nil, ''  ;  add_escaped_expr(expr_str)
        when '!'      ;  add_plain_expr(expr_str)
        when '!!'     ;  add_debug_expr(expr_str)
        else          ;  # do nothing
        end
      end
      rest = pos == 0 ? text : $'
      translate_string(rest) unless rest.empty?
    end


    ## (abstract) convert expression to native expression string.
    ## ex. 'item.name' => '$item->name', '$item->name' => '$item->name'
    def parse_expr_str!(expr_str)
      not_implemented
    end


    def add_plain_expr(expr_code)
      @sb << @expr_l << expr_code << @expr_r       # ex. <%= expr_code %>
    end


    def add_escaped_expr(expr_code)
      @sb << @escape_l << expr_code << @escape_r   # ex. <%=h expr_code %>
    end


    def add_debug_expr(expr_code)
      not_implemented
    end


    ## concat several print statements into a statement
    def optimize_print_stmts(stmt_list)
      stmt_list2 = []
      args = []
      stmt_list.each do |stmt|
        if stmt.is_a?(PrintStatement)
          args += stmt.args
        else
          if !args.empty?
            args = _compact_args(args)
            stmt_list2 << PrintStatement.new(args)
            args = []
          end
          stmt_list2 << stmt
        end
      end
      if !args.empty?
        args = _compact_args(args)
        stmt_list2 << PrintStatement.new(args)
      end
      return stmt_list2
    end


    private


    ## concat several string arguments into a string in arguments
    def _compact_args(args)
      args2 = []
      s = ''
      args.each do |arg|
        if arg.is_a?(NativeExpression)
          args2 << s unless s.empty?
          s = ''
          args2 << arg
        else
          s << arg
        end
      end
      args2 << s unless s.empty?
      return args2
    end


  end #class



  module NoTextEnhancer  # :nodoc:


    def translate_string(str)
      @sb << (@nl * str.count("\n"))
      pos = str.rindex("\n")
      len = pos ? str.length - pos - 1 : str.length
      @sb << (' ' * len)
    end


  end



end #module
