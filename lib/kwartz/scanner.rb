###
### scanner.rb
###
### $Id$
###

require 'kwartz/exception'
require 'kwartz/utility'

module Kwartz

   class ScanError < BaseError
      def initialize(errmsg, linenum, filename)
         super(errmsg, linenum, filename)
      end
   end


   module CharType

      ## return true if ch is white char
      def is_white(ch)
         case ch
         when ?\ , ?\n , ?\r , ?\t
            return true
         end
         return false
      end

      ## return true if ch is alphabet
      def is_alpha(ch)
         return ?a <= ch && ch <= ?z || ?A <= ch && ch <= ?Z
      end

      ## return true if ch is numeric
      def is_digit(ch)
         return ?0 <= ch && ch <= ?9
      end

      ## return true if ch is alphabet, number or underbar
      def is_word(ch)
         return ?a <= ch && ch <= ?z || ?A <= ch && ch <= ?Z || ?0 <= ch && ch <= ?9 || ch == ?_
      end

   end


   class Scanner
      include CharType

      def initialize(input, properties={})
         @properties = properties
         reset(input)
         @filename = @properties[:filename]
         @keywords = @@keywords
      end

      def reset(input, linenum=1)
         @input = input
         @lines = input.split(/\r?\n/)
         @linenum = linenum - 1
         @current_line = nil
         @token = nil
         @value = nil
         @index = -1
         #@ch = nil
      end

      attr_reader :token, :value, :linenum, :filename, :keywords


      @@keywords = {
         'expand'   =>   :expand,
         'element'  =>   :element,
         'macro'    =>   :macro,
         'value:'   =>   :value,
         'attr:'    =>   :attr,
         'append:'  =>   :append,
         'remove:'  =>   :remove,
         'tagname:' =>   :tagname,

         'print'    =>   :print,
         'while'    =>   :while,
         'foreach'  =>   :foreach,
         'for'      =>   :for,
         'in'       =>   :in,
         'if'       =>   :if,
         'else'     =>   :else,
         'elseif'   =>   :elseif,
         'require'  =>   :require,

         'true'	    =>   :true,
         'false'    =>   :false,
         'null'	    =>   :null,
         'empty'    =>   :empty,
      }


      def scan()

         while true
            unless @line
               @line = getline()
            end
            return @token = nil unless @line

            while @line && @line =~ /\A\s*\#/
               @line = getline()
            end
            return @token = nil unless @line

            @token = scan_line()
            #$stderr.puts "*** debug: token=#{token.to_s}, @line=#{@line.inspect}"

            if @token == ?\n
               @line = nil
               redo
            end

            return @token
         end

         Kwartz::assert(false)
      end


      def scan_all()
         s = ''
         while (token = scan()) != nil
            if token.is_a?(String)		# string
               s << token
               case token
               when '@', ':::'
                  s << @value
               when '#element', '#macro'
                  s << ' ' << @value
               end
            else				# symbol
               case token
               when :string
                  s << Kwartz::Util::dump_str(@value)
               when :numeric
                  s << @value
               when :name
                  s << @value
               when :true, :false, :null, :nil, :empty
                  s << ':' << token.id2name
               when :rawcode
                  s << ':::' << @value
               when :rubycode
                  s << ':rubycode' << @value
               else
                  s << ':' << token.id2name
               end
            end
            s << "\n"
         end
         return s
      end


      private


      def getline()
         @line = @lines[@linenum]
         @linenum += 1
         if @line
            @index = 0
            @ch = @line[0]
         end
         return @line
      end

      #def getline()
      #   line = @lines[@linenum]
      #   @linenum += 1
      #   return line
      #end


      #def reset_line()
      #   @index = -1
      #   @ch = getchar()
      #end


      def getchar()
         @index += 1
         return @line[@index]
      end


      def current_char()
         return @line[@index]
      end


      def scan_line()
         Kwartz::assert(@line != nil)

         ch = current_char()
         if ch == nil
            return ?\n		# end of line
         end

         ## ignore white space
         while (is_white(ch))
            ch = getchar()
         end

         ## ignore comment
         if ch == ?\#
            return ?\n		# end of line
         end

         ##
         if ch == ?:
            ch = getchar()
            return ':' if ch != ?:
            ch = getchar()
            return '::' if ch != ?:
            getchar()
            return ':::'
         end

         ##
         if is_alpha(ch) || ch == ?_
            s = ch.chr
            while (ch = getchar()) != nil && is_word(ch)
               s << ch.chr
            end
            @value = s
            
            begin
            if w = @keywords[@value]
               @token = w
            elsif ch == ?: && (w = @keywords[@value + ':'])
               @token = w
               getchar()
            else
               @token = :name
            end
            rescue TypeError => ex
               $stderr.puts "*** debug: @token=#{@token.inspect}"
               raise ex
            end
            return @token
         end

         ##
         if is_digit(ch)
            s = ch.chr
            while (ch = getchar()) != nil && is_digit(ch)
               s << ch.chr
            end
            if ch == ?.
               s << ch.chr
               while (ch = getchar()) != nil && is_digit(ch)
                  s << ch.chr
               end
            end
            @value = s
            return @token = :numeric
         end

         ##
         if ch == ?.
            ch = getchar()
            if ch == ?=
               getchar()
               return @token = '.='
            end
            if ch == ?+
               if (ch = getchar()) == ?=
                  getchar()
                  return @token = '.+='
               else
                  return @token = '.+'
               end
            end
            return '.'
         end

         ## string
         if ch == ?'					#'
            s = ""
            while (ch = getchar()) != nil && ch != ?'	#'
               if ch == ?\\
                  ch = getchar()
                  break if ch == nil
                  case ch
                  when ?\\ ;  s << '\\'
                  when ?'  ;  s << "'"				#"
                  else
                     s << '\\' << ch.chr
                  end
               else
                  s << ch.chr
               end
            end
            if ch == nil
               msg = 'string "\'" is not closed.'
               raise ScanError.new(msg, @linenum, @filename)
            end
            getchar()
            @value = s
            #print "*** debug: @value=#{@value.inspect}\n"
            #print "*** debug: dump_str(@value)=#{Kwartz::Util::dump_str(@value)}\n"
            return @token = :string
         end

         ## string
         if ch == ?"					#"
            s = ""
            while (ch = getchar()) != nil && ch != ?"	#"
               if ch == ?\\
                  if (ch = getchar()) == nil
                     break
                  end
                  case ch
                  when ?\\ ;  s << '\\'
                  when ?"  ;  s << '"'				#'
                  when ?n  ;  s << "\n"
                  when ?t  ;  s << "\t"
                  when ?r  ;  s << "\r"
                  else
                     s << '\\' << ch.chr
                  end
               else
                  s << ch.chr
               end
            end
            if ch == nil
               msg = "string '\"' is not closed."
               raise ScanError.new(msg, @linenum, @filename)
            end
            getchar()
            @value = s
            return @token = :string
         end

         ##
         if ch == ?+ || ch == ?- || ch == ?* || ch == ?/ || ch == ?% || ch == ?^
            if (ch2 = getchar()) != nil && ch2 == ?=
               getchar()
               return @token = ch.chr + '='	# += -= *= /= %= ^=
            else
               return @token = ch.chr		# +  -	*  /  %	 ^
            end
         end

         ##
         if ch == ?= || ch == ?! || ch == ?< || ch == ?>
            if (ch2 = getchar()) != nil && ch2 == ?=
               getchar()
               return @token = ch.chr + '='	# == != <= >=
            else
               return @token = ch.chr		# =  !	<  >
            end
         end

         ##
         if ch == ?& || ch == ?|
            if (ch2 = getchar()) != nil && ch2 == ch
               getchar()
               return @token = ch.chr + ch2.chr		## && ||
            else
               msg = "'#{ch.chr}': invalid char."
               raise ScanError.new(msg, @linenum, @filename)
            end
         end

         ## @macro
         if ch == ?@
            s = ''
            while (ch = getchar()) != nil && is_word(ch)
               s << ch.chr
            end
            if s.empty?
               msg = "'@' requires macro name."
               raise ScanError.new(msg, @linenum, @filename)
            end
            @value = s
            return @token = '@'
         end

         ##
         if ch == ?[
            if (ch = getchar()) != nil && ch == ?:
               getchar()
               return @token = '[:'
            else
               return @token = '['
            end
         end

         case ch
         when ?] , ?, , ?(, ?), ??, ?{, ?}, ?;
            getchar()
            return ch.chr
         end

         msg = "'#{ch.chr}': invalid char."
         raise ScanError.new(msg, @linenum, @filename)
      end

   end	# end of class Scanner


   class RubyScanner < Scanner
      def scan()
         while true
            if @line
               token = scan_line()
               if token == ?\n
                  @line = nil
                  redo
               end
               return token
            else
               @line = getline()
               return nil unless @line
               if @line =~ /\A(macro|element)\s+(\w+)\s*$/
                  @token = '#' + $1
                  @value = $2
                  @line  = nil
                  return @token
               elsif @line =~ /\Aend\s*$/
                  @token = '#end'
                  @value = nil
                  @line  = nil
                  return @token
               elsif @line =~ /\A\s*@(\w+)\s*$/
                  @token = '@'
                  @value = $1
                  @line	 = nil
                  return @token
               elsif @line =~ /\A\s*:/
                  #reset_line()
                  token = scan_line()
                  if token == ?\n
                     @line = nil
                     redo
                  end
                  return token
               elsif @line =~ /\A\s*\#/
                  @line	 = nil		# ignore comment
                  redo
               elsif @line =~ /\A\s+/
                  @token = :rubycode
                  @value = @line
                  @line	 = nil
                  return @token
               else
                  msg = "invalid statement: ruby code must start with white space."
                  raise ScanError.new(msg, @linenum, @filename)
               end
            end
         end
         Kwartz::assert(false)
      end

   end  # end of class RubyScanner


end   # end of module Kwartz
