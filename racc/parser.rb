require 'strscan'
require 'common-strscan'
require 'expr-parser.tab'
require 'stmt-parser.tab'
require 'ruleset-parser.tab'
require 'node'


module Kwartz


  class Scanner < StringScanner::CommonScanner

  end


  class ParseError < StandardError

    def initialize(message, linenum, column)
      super(message)
      @message = message
      @linenum = linenum
      @column  = column
    end
    attr_accessor :linenum, :column

    def to_s
      return "%d:%d: %s" % [@linenum, @column, @message]
    end

  end


  class SyntaxError < ParseError
  end


  class SemanticError < ParseError
  end


  module Parser


    def initialize(input, properties={})
      @scanner = Scanner.new(input, properties)
      @properties = properties
      @builder = NodeBuilder.new()
    end
    attr_reader :start_linenum, :start_column, :end_linenum, :end_column


    @@keywords = {
      'print'    => :PRINT,
      'if'       => :IF,
      'else'     => :ELSE,
      'elseif'   => :ELSEIF,
      'else'     => :ELSE,
      'while'    => :WHILE,
      'foreach'  => :FOREACH,
      'break'    => :BREAK,
      'continue' => :CONTINUE,
      'true'     => :TRUE,
      'false'    => :FALSE,
      'null'     => :NULL,
      #'nil'      => :NULL,
      '_stag'    => :STAG,
      '_etag'    => :ETAG,
      '_cont'    => :CONT,
      '_elem'    => :ELEM,
      '_element' => :ELEMENT,
      '_content' => :CONTENT,
    }

    @@properties = {
      'stag'    =>  :P_STAG,
      'Stag'    =>  :P_STAG,
      'STAG'    =>  :P_STAG,
      'etag'    =>  :P_ETAG,
      'Etag'    =>  :P_ETAG,
      'ETAG'    =>  :P_ETAG,
      'cont'    =>  :P_CONT,
      'Cont'    =>  :P_CONT,
      'CONT'    =>  :P_CONT,
      'elem'    =>  :P_ELEM,
      'Elem'    =>  :P_ELEM,
      'ELEM'    =>  :P_ELEM,
      #
      'value'   =>  :P_VALUE,
      'Value'   =>  :P_VALUE,
      'VALUE'   =>  :P_VALUE,
      'attrs'   =>  :P_ATTRS,
      'Attrs'   =>  :P_ATTRS,
      'ATTRS'   =>  :P_ATTRS,
      'append'  =>  :P_APPEND,
      'Append'  =>  :P_APPEND,
      'APPEND'  =>  :P_APPEND,
      'remove'  =>  :P_REMOVE,
      'logic'   =>  :P_LOGIC,
      'tagname' =>  :P_TAGNAME,   # not used
      #
      'begin'   =>  :P_BEGIN,
      'end'     =>  :P_END,
      'global'  =>  :P_GLOBAL,
      'local'   =>  :P_LOCAL,
      'fixture' =>  :P_FIXTURE,   # not used
    }


    def parse()
      begin
        return do_parse()
      rescue Racc::ParseError => ex
        raise _error(ex.message, @scanner.linenum, @scanner.column)
      end
    end


    def linenum
      return @scanner.linenum
    end


    def column
      return @scanner.column
    end


    def next_token()
      tuple = @mode == :ruleset ? _next_token_for_ruleset()   \
                                : _next_token_for_statement()
      return nil unless tuple
      @token_id, @token_val = tuple
      #@end_linenum = @scanner.linenum
      #@end_column  = @scanner.column
      #return tuple
      return [@token_id, [@token_id, @token_val, @start_linenum, @start_column]]
    end


    private


    def _next_token_for_statement()
      scanner = @scanner

      scanner.scan_whitespace()
      return nil if scanner.eos?
      @start_linenum = @scanner.linenum
      @start_column  = @scanner.column

      if value = scanner.scan_ident()
        if keyword = @@keywords[value]
          return [keyword, nil]
        else
          return [:IDENT, value]
        end
      end

      if value = scanner.scan_float()
        return [:FLOAT, value]
      end

      if value = scanner.scan_integer()
        return [:INTEGER, value]
      end

      if value = scanner.scan_string()
        return [:STRING, value]
      end

      if scanner.scan(/\/\//)
        scanner.scan(/.*?\n/)
        return _next_token()
      end

      value = scanner.scan(/\[:|[\(\)\{\}\[\];,]/)      ||
              scanner.scan(/==|!=|<=|>=|<|>/)           ||
              scanner.scan(/=|\+=|-=|\*=|\/=|%=|\.\+=|\|\|=|&&=/)  ||
              scanner.scan(/&&|\|\||!/)                 ||
              scanner.scan(/[-+*\/%]|\.\+/)             ||
              scanner.scan(/[.]/)                       ||
              scanner.scan(/[\?:]/)
      if value
        return [value, value]
      end

      invalid_char = scanner.scan(/./)
      @error_code = :INVALID_CHARACTER
      return [:ERROR, invalid_char]

    end


    def _next_token_for_ruleset()
      scanner = @scanner

      scanner.scan_whitespace()
      return nil if scanner.eos?
      @start_linenum = @scanner.linenum
      @start_column  = @scanner.column

      if value = scanner.scan(/\#\w+/)
        return [:SELECTOR, value]
      end

      if value = scanner.scan(/[\{\}:;]/)
        return [value, value]
      end

      if value = scanner.scan(/@\w+/)
        return [:COMMAND, value[1..-1]]
      end

      if value = scanner.scan_string()
        return [:STRING, value]
      end

      if value = scanner.scan_ident
        if propname = @@properties[value]
          return [propname, value]
        else
          return [:IDENT, value]
        end
      end

      invalid_char = scanner.scan(/./)
      @error_code = :INVALID_CHARACTER
      return [:ERROR, invalid_char]

    end


    def _wrap(funcname, arg, kind=nil)
      return @builder.wrap(funcname, arg, kind)
    end


    protected


    def _error(message, linenum, column)
      return SyntaxError.new(message, linenum, column)
    end


    #--
    #def on_error( t, val, vstack )
    #  raise ParseError, sprintf("\nparse error on value %s (%s)",
    #                            val.inspect, token_to_str(t) || '?')
    #end
    #++
    def on_error(token, value, vstack)
      tuple = value
      token_id, value, linenum, column = tuple
      #super(token, value, vstack)
      msg = "parse error on value %s (%s)" % [ value.inspect, token_id.to_s.inspect ]
      raise _error(msg, linenum, column)
    end


    def handle_command(command, argstr)
      if command == 'import'
        filename = argstr
        parser = self.class.new(File.read(filename), @properties)
        stmts = @parser.parse()
        @rulesets.concat(stmts)
      end
    end


    def dprt(str)
      puts "*** debug: #{str}"
    end


  end



  class ExpressionParser
    include Parser
  end



  class StatementParser
    include Parser
  end



  class RulesetParser
    include Parser
    def initialize(*args)
      super(*args)
      @mode = :ruleset
      @rulesets = []
    end
  end


end


if $0 == __FILE__

  opt = ARGV.shift
  raise "option '-expr' or '-stmt' rquired." unless opt

  if opt == '-expr'
    while input = $stdin.gets()
      parser = Kwartz::ExpressionParser.new(input)
      expr = parser.parse()
      puts expr._inspect()
    end
  elsif opt == '-stmt'
    input = $stdin.read()
    parser = Kwartz::StatementParser.new(input)
    stmts = parser.parse()
    stmts.each do |stmt|
      puts stmt._inspect()
    end
  elsif opt == '-ruleset'
    input = $stdin.read()
    parser = Kwartz::RulesetParser.new(input)
    rulesets = parser.parse()
    rulesets.each do |ruleset|
      puts ruleset._inspect()
    end
  else
    raise "option '#{option}' is unknown."
  end

  #puts val if val != nil
  #while tuple = parser.next_token()
  #  token_id, token_val = tuple
  #  puts "%03d: %s: %s" % [parser.linenum, token_id.inspect, token_val.inspect]
  #end

end
