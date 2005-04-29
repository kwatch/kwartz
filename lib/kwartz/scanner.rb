###
### copyright(c) 2005 kuwata-lab all rights reserved
###
### $Id$
### $Release$
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
      def is_white?(ch)
         case ch
         when ?\ , ?\n , ?\r , ?\t
            return true
         end
         return false
      end

      ## return true if ch is alphabet
      def is_alpha?(ch)
         return ?a <= ch && ch <= ?z || ?A <= ch && ch <= ?Z
      end

      ## return true if ch is numeric
      def is_digit?(ch)
         return ?0 <= ch && ch <= ?9
      end

      ## return true if ch is alphabet, number or underbar
      def is_word?(ch)
         return ?a <= ch && ch <= ?z || ?A <= ch && ch <= ?Z || ?0 <= ch && ch <= ?9 || ch == ?_
      end

   end


   ##
   ## ex.
   ##  input = ARGF.read()
   ##  properties = {}
   ##  scanner = Scanner.new(input, properties)
   ##  while scanner.scan()
   ##     if scanner.token().is_a?(String)
   ##        puts scanner.token()
   ##     elsif scanner.token().is_a?(Symbol)
   ##        puts scanner.token(), "(value=#{scanner.value()})"
   ##     end
   ##  end
   ##
   class Scanner
      include CharType

      def initialize(input, properties={})
         reset(input, 0)
         @properties = properties
         @filename = @properties[:filename]
         @keywords = @@keywords
      end

      def reset(input, base_linenum=0)
         @input = input
         @base_linenum = base_linenum
         @index = 0
         @char = @input[@index]
         @linenum = 1
         @token = nil
         @value = nil
      end

      attr_reader :input, :filename, :token, :value
      
      def linenum
         #return @linenum + @base_linenum
         n = @linenum + @base_linenum
         return @char == ?\n ? n - 1 : n
      end

      def getchar()
         @index += 1
         @char = @input[@index]
         @linenum += 1 if @char == ?\n
         return @char
      end

      @@keywords = {
         'expand'   =>   :expand,
         'element'  =>   :element,
         'macro'    =>   :macro,

         'print'    =>   :print,
         'while'    =>   :while,
         'foreach'  =>   :foreach,
         'for'      =>   :for,
         'in'       =>   :in,
         'if'       =>   :if,
         'else'     =>   :else,
         'elseif'   =>   :elseif,
         #'require'  =>   :require,

         'true'	    =>   :true,
         'false'    =>   :false,
         'null'	    =>   :null,
         'empty'    =>   :empty,
      }


      def scan()
         ## skip white spaces
         ch = @char
         ch = getchar() while ch && is_white?(ch)

         ## EOF
         if ch == nil
            return @token = nil
         end

         ## line comment or region comment
         if ch == ?/
            ch = getchar()
            if ch == ?/			## line comment
               ch = getchar()
               ch = getchar() while ch != nil && ch != ?\n
               getchar()
               return scan()
            elsif ch == ?*		## region comment
               while ch = getchar()
                  break if ch == ?* && (ch = getchar()) == ?/
               end
               unless ch != nil
                  msg = "region comment is not closed."
                  raise ScanError.new(msg, linenum(), filename())
               end
               getchar()
               return scan()
            elsif ch == ?=
               getchar()
               return @token = '/='	## /=
            else
               return @token = '/'	## /
            end
         end

         ## :  ::  :::
         if ch == ?:
            ch = getchar()
            return @token = ':' if ch != ?:
            ch = getchar()
            return @token = '::' if ch != ?:
            s = ''
            s << ch.chr while (ch = getchar()) != nil && ch != ?\n
            @value = s
            #return @token = ':::'
            return @token = :rawcode
         end

         ## name
         if is_alpha?(ch) || ch == ?_
            s = ch.chr
            while (ch = getchar()) != nil && is_word?(ch)
               s << ch.chr
            end
            @value = s
            w = @keywords[@value]
            @token = w ? w : :name
            return @token
         end

         ## numeric
         if is_digit?(ch)
            s = ch.chr
            while (ch = getchar()) != nil && is_digit?(ch)
               s << ch.chr
            end
            if ch == ?.
               s << ch.chr
               while (ch = getchar()) != nil && is_digit?(ch)
                  s << ch.chr
               end
            end
            @value = s
            return @token = :numeric
         end

         ## .  .=  .+  .+=
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
            return @token = '.'
         end

         ## quoted string
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
               raise ScanError.new(msg, linenum(), filename())
            end
            getchar()
            @value = s
            #print "*** debug: @value=#{@value.inspect}\n"
            #print "*** debug: dump_str(@value)=#{Kwartz::Util::dump_str(@value)}\n"
            return @token = :string
         end

         ## double-quoted string
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
               raise ScanError.new(msg, linenum(), filename())
            end
            getchar()
            @value = s
            return @token = :string
         end

         ## +  -  *  /  %  ^
         if ch == ?+ || ch == ?- || ch == ?* || ch == ?/ || ch == ?% || ch == ?^
            if (ch2 = getchar()) != nil && ch2 == ?=
               getchar()
               return @token = ch.chr + '='	# += -= *= /= %= ^=
            else
               return @token = ch.chr		# +  -	*  /  %	 ^
            end
         end

         ## <  <=  <%  <?
         if ch == ?<
            ch2 = getchar()
            if ch2 == ?=
               getchar()
               @token = '<='
            elsif ch2 == ?% || ch2 == ??
               #@value = '<' + ch2.chr + getrest()
               #@token = :rawcode
               s = ''
               ch = getchar()
               @token = ch == ?= ? :rawexpr : :rawcode
               ch = getchar() if ch == ?=
               while true
                  unless ch
                     msg = "`<#{ch2.chr}#{@token == :rawexpr ? '=' : ''}' is not closed."
                     raise ScanError.new(msg, linenum(), @filename)
                  end
                  if ch != ch2
                     s << ch.chr
                  elsif (ch = getchar()) == ?>
                     getchar()
                     break
                  else
                     s << ch2.chr
                     s << ch.chr
                  end
                  ch = getchar()
               end
               @value = s
            else
               @token = '<'
            end
            return @token
         end

         ## =  !  >  ==  !=  >=
         if ch == ?= || ch == ?! || ch == ?< || ch == ?>
            if (ch2 = getchar()) != nil && ch2 == ?=
               getchar()
               return @token = ch.chr + '='	# == != <= >=
            else
               return @token = ch.chr		# =  !	<  >
            end
         end

         ## &&  ||
         if ch == ?& || ch == ?|
            if (ch2 = getchar()) != nil && ch2 == ch
               getchar()
               return @token = ch.chr + ch2.chr		## && ||
            else
               msg = "'#{ch.chr}': invalid char."
               raise ScanError.new(msg, linenum(), filename())
            end
         end

         ## @stag, @cont, @etag, @element(marking)
         if ch == ?@
            s = ''
            while (ch = getchar()) != nil && is_word?(ch)
               s << ch.chr
            end
            if s.empty?
               msg = "'@' requires macro name."
               raise ScanError.new(msg, linenum(), filename())
            end
            @value = s
            return @token = '@'
         end

         ##  [:  [
         if ch == ?[
            if (ch = getchar()) != nil && ch == ?:
               getchar()
               return @token = '[:'
            else
               return @token = '['
            end
         end

         ##  #  ]  ,  (  )  ?  {  }  ;
         case ch
         when ?# , ?] , ?, , ?(, ?), ??, ?{, ?}, ?;
            getchar()
            return @token = ch.chr
         end

         ## invalid char
         msg = "'#{ch.chr}': invalid char."
         raise ScanError.new(msg, linenum(), filename())
      end


      def scan_all()
         s = ''
         scan()		# don't change to `while scan()' ! 
         while token() != nil
            if token().is_a?(String)		# string
               s << token()
               case token()
               when '@', ':::'
                  s << value()
               when '#element', '#macro'
                  s << ' ' << value()
               end
            else				# symbol
               case token()
               when :string
                  s << Kwartz::Util::dump_str(value())
               when :numeric
                  s << value()
               when :name
                  s << value()
               when :true, :false, :null, :nil, :empty
                  s << ':' << token().id2name
               when :rawcode
                  s << "<%#{value()}%>"
               when :rawexpr
                  s << "<%=#{value()}%>"
               when :rubycode
                  s << ':rubycode' << value()
               else
                  s << ':' << token().id2name
               end
            end
            s << "\n"
            scan()
         end
         return s
      end

   end	# end of class Scanner


end   # end of module Kwartz

if __FILE__ == $0
   input = ARGF.read()
   scanner = Kwartz::Scanner.new(input)
   print scanner.scan_all()
end
