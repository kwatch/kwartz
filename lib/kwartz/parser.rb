###
### parser.rb
###
### $Id$
###

require 'kwartz/exception'
require 'kwartz/scanner'
require 'kwartz/node'

module Kwartz

   class ParseError < BaseError
      def initialize(message, linenum, filename)
         super(message, linenum, filename)
      end
   end
   
   class SyntaxError < ParseError
      def initialize(message, linenum, filename)
         super(message, linenum, filename)
      end
   end

   class SemanticError < ParseError
      def initialize(message, linenum, filename)
         super(message, linenum, filename)
      end
   end

   
   class Parser
   
      def initialize(input, properties={})
         @scanner = Scanner.new(input, properties)
         @properties = properties
         _init()
      end
      attr_reader :properties
      
      def reset(input, linenum=nil)
         @scanner.reset(input, linenum)
         _init()
      end
      
      def _init()
         @scanner.scan()
         @element_name_stack = []
         @current_element_name = nil
      end
      private :_init

      def scan()
         return @scanner.scan()
      end
      
      def token()
         return @scanner.token()
      end
      
      def token_str()
         return @scanner.value()
      end
      
      def value()
         return @scanner.value()
      end
      
      def syntax_error(msg)
         raise SyntaxError.new(msg, @scanner.linenum, @scanner.filename)
      end

      def semantic_error(msg)
         raise SemanticError.new(msg, @scanner.linenum, @scanner.filename)
      end

      ##############################
      
      def parse_expression()
      end


      def parse_program()
         block = parse_block_statement()
         token_check(nil, "EOF expected but '#{token()}'.")
         return block
      end
      
      def parse()
         #return parse_program()
         s 
         while tkn = @scanner.scan()
            
         end
      end
      
      def _scan_all()
         s = ''
         s << @scanner.token.to_s << "\n"
         while tkn = @scanner.scan()
            s << tkn.to_s << "\n"
         end
         return s
      end

   end
end
