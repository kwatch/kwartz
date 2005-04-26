###
### copyright(c) 2005 kuwata-lab all rights reserved
###
### $Id$
### $Release$
###

require 'kwartz/parser'
require 'kwartz/node'
require 'kwartz/element'


module Kwartz

   class PhonyParser

      def initialize(input, properties={})
         @input = input
         @properties = properties
         @filename = properties[:filename]
         @lines = input.split($/)
         @linenum = 0
      end

      attr_reader :filename, :linenum

      def parse
         return parse_declarations()
      end


      private


      def getline
         while true
            @line = @lines[@linenum]
            @linenum += 1
            break if @line !~ /\A\s*\#/
         end
         return @line
      end


      def currline
         @line
      end


      def parse_declarations
         decl_list = []
         while line = getline()
            case line
            when /\A\s*\z/
               #
            when /\Aelement\s+(\w+)\s+\{\s*$/
               elem_name = $1
               parts = parse_decl_parts(false)
               unless @line =~ /\A\}\s*$/
                  msg = "`element #{elem_name} {' is not closed by '}'."
                  raise SyntaxError.new(msg, linenum(), filename())
               end
               decl_list << Declaration.new(elem_name, parts)
            when /\Adocument\s+\{\s*$/
               elem_name = 'DOCUMENT'
               parts = parse_decl_parts(true)
               unless @line =~ /\A\}\s*$/
                  msg = "`document {' is not closed by '}'."
                  raise SyntaxError.new(msg, linenum(), filename())
               end
               decl_list << Declaration.new(elem_name, parts)
            else
               msg = "element or document declaration is required."
               raise SyntaxError.new(msg, linenum(), filename())
            end
         end
         return decl_list
      end


      def parse_decl_parts(flag_document_decl=false)
         parts = {}
         while line = getline()
            break if line =~ /\A\}\s*\z/
            next if line =~ /\A\s*\z/
            unless line =~ /\A\s*(\w+)\s+(.*)/
               msg = "`#{@line}': invalid line."
               raise SyntaxError.new(msg, linenum(), filename())
            end
            word = $1;  arg = $2
            if flag_document_decl
               parse_doc_decl_part(word, arg, parts)
            else
               parse_elem_decl_part(word, arg, parts)
            end
         end
         return parts
      end


      def parse_elem_decl_part(word, arg, parts)
         case word
         when 'value'
            parts[:value] = RawcodeExpression.new(arg)
         when 'attrs', 'attr'
            list = word == 'attr' ? [ arg ] : arg.split(',')
            list.each do |s|
               s.strip!
               if s =~ /\A'(.+?)'\s*=>\s*(.+)\z/ || s =~ /\A"(.+?)"\s*=>\s*(.+)\z/
                  aname = $1;  avalue = $2
                  (parts[:attrs] ||= {})[aname] = RawcodeExpression.new(avalue)
               else
                  msg = "`#{@line}': invalid 'attrs' format."
                  raise SyntaxError.new(msg, linenum(), filename())
               end
            end
         when 'append'
            (parts[:append] ||= []) << RawcodeExpression.new(arg.strip)
            #arg = $1
            #arg.split(',').each do |s|
            #   s.strip!
            #   (parts[:append] ||= []) << RawcodeExpresson.new(s)
            #end
         when 'remove'
            list = _parse_strings(word, arg)
            (parts[:remove] ||= []).concat(list)
         when 'tagname'
            parts[:tagname] = RawcodeExpression.new(arg)
         when 'plogic'
            block_stmt = _parse_block(word, arg)
            parts[:plogic] = block_stmt
         else
            msg = "`#{word}': invalid word"
            raise SyntaxError.new(msg, linenum(), filename())
         end
      end


      def parse_doc_decl_part(word, arg, parts)
         case word
         when 'requires'
            list = _parse_strings(word, arg)
            (parts[:require] ||= []).concat(list)
         when 'before'
            block_stmt = _parse_block(word, arg)
            parts[:before] = block_stmt
            parts[:begin]  = block_stmt
         when 'after'
            block_stmt = _parse_block(word, arg)
            parts[:after] = block_stmt
            parts[:end]   = block_stmt
         when 'global_vars'
            list = _parse_names(word, arg)
            (parts[:global_vars] ||= []).concat(list)
         when 'local_vars'
            list = _parse_names(word, arg)
            (parts[:local_vars] ||= []).concat(list)
         end
      end


      def _parse_names(word, arg)
         list = []
         arg.split(/,/).each do |name|
            name.strip!
            if name =~ /\A\w+\z/
               list << name
            else
               msg = "`#{name}': invalid name at `#{word}' part."
               raise SyntaxError.new(msg, linenum(), filename())
            end
         end
         return list
      end


      def _parse_strings(word, arg)
         list = []
         arg.split(/,/).each do |s|
            s.strip!
            if s =~ /\A'(.*)'\z/ || s =~ /\A"(.*)"\z/
               list << $1
            else
               msg = "`#{s}': invalid string at `#{word}' part."
               raise SyntaxError.new(msg, linenum(), filename())
            end
         end
         return list
      end


      def _parse_block(word, arg)
         unless arg == '{'
            msg = "#{word} part requires '{'."     # }
            raise SyntaxError.new(msg, linenum(), filename())
         end
         @line =~ /\A(\s+)/
         space = $1
         stmt_list = []
         while true
            unless line = getline()
               msg = "`#{word} {' is not closed."   # }
               raise SyntaxError.new(msg, linenum(), filename())
            end
            break if line =~ /\A#{space}\}\s*\z/
            case line
            when /\A\s*(stag|etag|cont|elem|element)(?:\((.*)\))?;?\z/
               key = $1.intern
               arg = $2
               if key == :element
                  unless arg && !arg.empty?
                     msg = "element name is required."
                     raise SyntaxError.new(msg, linenum(), filename())
                  end
                  unless arg =~ /\A\w+\z/
                     msg = "`element(#{arg})': invalid element name."
                     raise SyntaxError.new(msg, linenum(), filename())
                  end
               end
               stmt_list << ExpandStatement.new(key, arg)
            when /\A\s*print\s*(.*)/
               arglist = [ RawcodeExpression.new($1) ]
               stmt_list << PrintStatement.new(arglist)
            else
               stmt_list << RawcodeStatement.new(line)
            end
         end
         return BlockStatement.new(stmt_list)
      end

   end

end


if $0 == __FILE__
   input = ARGF.read()
   parser = Kwartz::PhonyParser.new(input, {})
   decl_list = parser.parse()
   decl_list.each do |decl|
      print decl._inspect()
   end
end
