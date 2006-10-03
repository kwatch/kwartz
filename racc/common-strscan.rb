require 'strscan'
require 'date'



class StringScanner



   module LiteralEnhancer

      def scan_whitespace()
         return scan(/\s+/)
      end

      def get_whitespace()
         return scan_whitespace()
      end

      def scan_ident()
         return scan(/[a-zA-Z_]\w*\b/)
      end

      def get_ident()
         return scan_ident()
      end

      def scan_float(unary_op=false)
         rexp = unary_op ? /(?:(-)[ \t]*)?(\d+)\.(\d+)(?:[eE]([+-]?\d+))?\b/ \
                         : /(\d+)\.(\d+)(?:[eE]([+-]?\d+))?\b/
         return scan(rexp)
      end

      def get_float(unary_op=false)
         return (s = scan_float(unary_op)) ? s.to_f : s
      end

      def scan_integer(unary_op=false)
         rexp = unary_op ? /(?:(-)[ \t]*)?(\d+)(?:[eE]([+-]?\d+))?\b/        \
                         : /(\d+)(?:[eE]([+-]?\d+))?\b/
         return scan(rexp)
      end

      def get_ingeger(unary_op=false)
         return (s = scan_integer(unary_op)) ? s.to_f : s
      end

      def scan_number()
         return scan(/(?:(-)[ \t]*)?(\d+)(?:\.(\d+))?(?:[eE]([+-]?\d+))?\b/)
      end

      def get_number()
         s = scan_number()
         return s unless s
         return self[3] ? s.to_f : s.to_i
      end

      def scan_date()
         return scan(/(\d\d\d\d)-(\d\d)-(\d\d)/)
      end

      def get_date()
         s = scan_date()
         return s unless s
         year = self[1];  month = self[2];  day = self[3]
         return Date.new(year, month, day)
      end

      def scan_datetime()
         return scan(/(\d\d\d\d)-(\d\d)-(\d\d)(?:[Tt]|[ \t]+)(\d\d):(\d\d):(\d\d)(?:\.(\d*))?(Z|[ \t]*(?:[-+]\d\d?(?:\d\d?)?))?/)
      end

      def get_datetime()
         s = scan_datetime()
         return s unless s
         year, month, day, hour, min, sec, fraction, timezone = \
            self[1], self[2], self[3], self[4], self[5], self[6], self[7], self[8]
         return Time.local(year, month, day, hour, min, sec, faction)
      end

      def scan_boolean()
         return scan(/true\b|false\b/)
      end

      def get_boolean()
         return (s = scan_boolean()) ? s == 'true' : s
      end

      def scan_string(allow_newline=true)
         if scan(/"/)       #"
            return _scan_string_dquoted(allow_newline)
         elsif scan(/'/)    #'
            return _scan_string_quoted(allow_newline)
         else
            return nil
         end
      end

      def get_string(allow_newline=true)
         return scan_string(allow_newline)
      end

      def scan_string_dquoted(allow_newline=true)
         return scan(/'/) ? _scan_string_dquoted(allow_newline) : nil    #'
      end

      def get_string_dquoted(allow_newline=true)
         return scan_string_dquoted(allow_newline)
      end

      def scan_string_quoted(allow_newline=true)
         return scan(/'/) ? _scan_string_quoted(allow_newline) : nil    #'
      end

      def get_string_quoted(allow_newline=true)
         return scan_string_quoted(allow_newline)
      end

      protected

      def _scan_string_dquoted(allow_newline)
         s = ""
         while (ch = getch()) != nil && ch != '"'
            if ch == '\\'
               case ch = getch()
               when '"';  ch = '"'
               when "\\"; ch = "\\"
               when "\/"; ch = "/"
               when "b";  ch = "\b"
               when "f";  ch = "\f"
               when "n";  ch = "\n"
               when "r";  ch = "\r"
               when "t";  ch = "\t"
               else
                  return :string_eos unless ch
                  s << '\\'
               end
            elsif ch == "\n"
               return :string_newline unless allow_newline
            end
            s << ch
         end
         return ch ? s : :string_eos
      end

      def _scan_string_quoted(allow_newline)
         s = ""
         while (ch = getch()) != nil && ch != "'"
            if ch == '\\'
               case ch = getch()
               when "'";  ch = "'"
               when "\\"; ch = "\\"
               else
                  return :string_eos unless ch
                  s << '\\'
               end
            elsif ch == "\n"
               return :string_newline unless allow_newline
            end
            s << ch
         end
         return ch ? s : :string_eos
      end

   end



   class LinenumScanner < StringScanner

      def initialize(input, options={})
         super(input)
         @linenum = options[:linenum] || 1
         @column  = options[:column]  || 1
      end
      attr_accessor :linenum, :column

      def scan(regexp)
         s = super(regexp)
         if s
            n = s.count("\n")
            if n > 0
               @linenum += n
               @column   = s.length - s.rindex(?\n)
            else
               @column  += s.length
            end
         end
         return s
      end

      def getch()
         ch = super
         if ch == "\n"
            @linenum += 1
            @column   = 1
         else
            @column  += 1
         end
         return ch
      end

   end



   class CommonScanner < LinenumScanner
      include LiteralEnhancer

      def initialize(input, options={})
         super
      end

   end



end


if $0 == __FILE__

   input = <<'END'
line: "a\tb\n\"\\"
line: 'a\tb\n\'\\'
text: "foo
   bar
   baz"
text: 'foo
   bar
   baz'
integer: 123
float: 3.14
unclosed_str: "fooo
   bar
   baz
END
   #"
   scanner = StringScanner::CommonScanner.new(input)

   while true
      scanner.scan_whitespace
      break if scanner.eos?
      start_linenum = scanner.linenum
      start_column  = scanner.column
      if value = scanner.scan(/[\{\}\[\]:,]/)
         token = value
      elsif value = scanner.scan_string()
         token = :STRING
         if value == :string_eos || value == :string_newline
            $stderr.puts "*** error: #{start_linenum}:#{start_column}: unclosed string."
            break
         end
      elsif value = scanner.scan_number()
         token = :NUMBER
      elsif value = scanner.scan_word()
         token = :WORD
      else
         ch = scanner.getch
         $stderr.puts "*** error: '#{ch}': invalid char."
         break
      end
      n1, c1, n2, c2 = start_linenum, start_column, scanner.linenum, scanner.column
      puts "#{n1}:#{c1},#{n2}:#{c2}: #{token.inspect}, #{value.inspect}\n"
   end

end
