###
### scanner.rb
###

require 'kwartz/exception'
require 'kwartz/utility'

module Kwartz

   class ScanError < BaseError
      def initialize(errmsg, linenum, filename)
	 super(errmsg, linenum, filename)
      end
   end


   class Scanner

       def initialize(input, properties={})
	 @properties = properties
	 reset(input)
	 @filename = @properties[:filename]
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

      attr_reader :token, :value, :linenum, :filename


      @@keywords = {
	 ':end'	     =>	   :end,

	 ':macro'    =>	   :macro,
	 ':expand'   =>	   :expand,
	 ':elem'     =>	   :elem,
	 ':element'  =>	   :element,

	 ':print'    =>	   :print,
	 ':set'	     =>	   :set,
	 ':while'    =>	   :while,
	 ':foreach'  =>	   :foreach,
	 ':load'     =>	   :load,
	 ':rawcode'  =>	   :rawcode,
	 ':rubycode' =>	   :rubycode,

	 ':if'	     =>	   :if,
	 ':else'     =>	   :else,
	 ':elsif'    =>	   :elsif,
	 ':elseif'   =>	   :elseif,

	 'true'	     =>	   :true,
	 'false'     =>	   :false,
	 'null'	     =>	   :null,
	 'nil'	     =>	   :null,
	 'empty'     =>	   :empty,
      }


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
		  reset_line()
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
		when :number
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
	 line = @lines[@linenum]
	 @linenum += 1
	 return line
      end


      def reset_line()
	 @index = -1
	 @ch = getchar()
      end


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
	    if ch == ?:
	       if (ch = getchar()) == ?:
		  getchar()
		  return @token = ':::'
	       else
		  return @token = '::'
	       end
	    end
	    if (is_alpha(ch))
	       s = ':' + ch.chr
	       while (ch = getchar()) != nil && is_alpha(ch)
		  s << ch.chr
	       end
	       unless @@keywords[s]
	          msg = "'#{s}': invalid keyword."
		  raise ScanError.new(msg, @linenum, @filename)
	       end
	       return @token = @@keywords[s]
	    end
	    return ':'
	 end

	 ##
	 if is_alpha(ch) || ch == ?_
	    s = ch.chr
	    while (ch = getchar()) != nil && is_word(ch)
	       s << ch.chr
	    end
	    @value = s
	    @token = (w = @@keywords[s]) != nil ? w : :name
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
	    return @token = :number
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
	       raise ScanError(msg, @linenum, @filename)
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
	 when ?] , ?, , ?(, ?), ??
	    getchar()
	    return ch.chr
	 end

	 msg = "'#{ch.chr}': invalid char."
	 raise ScanError.new(msg, @linenum, @filename)
      end


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


   end	# end of class Scanner

end   # end of module Kwartz
