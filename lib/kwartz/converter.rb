###
### copyright(c) 2005 kuwata-lab all rights reserved
###
### $Id$
###

require 'kwartz/config'
require 'kwartz/exception'
require 'kwartz/utility'
require 'kwartz/util/orderedhash'
require 'kwartz/node'
require 'kwartz/parser'

module Kwartz

   class ConvertionError < BaseError
      def initialize(errmsg, linenum=nil, filename=nil)
         super(errmsg, linenum, filename)
      end
   end


   ##
   ## convert presentation data into presentation logic.
   ##
   ## ex.
   ##  input = '<tr id="foo"><td kd="value:data">foo</td></tr>'
   ##  converter = Kwartz::Converter.new(input)
   ##  plogic = converter.convert()
   ##  print plogic
   ##
   class Converter

      def initialize(properties={})
         @properties = properties
         @kd_attr    = properties[:attr] || Kwartz::Config::ATTR      # 'kd'
         #@ruby_attr  = properties[:ruby_attr_name] || 'kd::ruby'
         #@delete_id_attr = properties[:delete_id_attr] || false
         @even       = properties[:even] || Kwartz::Config::EVEN     # "'even'"
         @odd        = properties[:odd]  || Kwartz::Config::ODD      # "'odd'"
         @filename   = properties[:filename]
         @parser = Parser.new('', properties)
      end
      attr_reader :stmt_list, :elem_list
      alias :element_list :elem_list
      
      def reset(input)
         @input = input
         @parser.reset(input)
         @linenum = 1
         @delta   = 0
         @stmt_list = []
         @elem_list = []
      end

      FETCH_PATTERN = /([ \t]*)<(\/?)([-:_\w]+)((?:\s+[-:_\w]+="[^"]*?")*)(\s*)(\/?)>([ \t]*\r?\n?)/	#"

      def fetch
         if @input !~ FETCH_PATTERN
            @linenum += @delta
            return @tagname = nil
         end
         @tag_str      = $&
         @before_text  = $`
         @before_space = $1
         @slash_etag   = $2		# "" or "/"
         @tagname      = $3
         @attr_str     = $4
         @extra_space  = $5
         @slash_empty  = $6		# "" or "/"
         @after_space  = $7
         @after_text   = $'

         @linenum  += @delta
         @linenum  += $`.count("\n")
         @delta    =  $&.count("\n")

         @attr_names  = []
         @attr_values = Kwartz::Util::OrderedHash.new
         @attr_spaces = {}
         @append_exprs = []
         
         if ! @before_text.empty?
            @is_begline = @before_text[-1] == ?\n
         else
            @is_begline = @prev_last_char == ?\n || ! @prev_last_char
         end
         @is_endline = @tag_str[-1] == ?\n
         @is_whole_line = @is_begline && @is_endline
         @prev_last_char = @tag_str[-1]
         
         #if @is_begline && @is_endline
         #   # nothing
         #else
         #   @before_text += @before_space
         #   @before_space = ''
         #   @after_text   = @after_space + @after_text
         #   @after_space  = ''
         #end

         @input    = @after_text
         return @tagname
      end


      def fetch_all(input)
         reset(input)
         s = ''
         while tagname = fetch()
            s << "linenum+delta: #{@linenum}+#{@delta}\n"
            s << "tagname:       #{@slash_etag}#{@tagname}#{@slash_empty}\n"
            s << "before_text:   #{@before_text.inspect}\n"
            s << "before_space:  #{@before_space.inspect}\n"
            s << "attr_str:      #{@attr_str.inspect}\n"
            s << "after_space:   #{@after_space.inspect}\n"
            s << "\n"
         end
         s <<    "rest:          #{@input.inspect}\n"
         s <<    "linenum:       #{@linenum}\n"
         return s
      end

      def convert(input)
         reset(input)
         if !@properties.key?(:newline) && input =~ /(\r?\n)/
            @properties[:newline] = $1
         end
         _convert(nil, @stmt_list)
         return BlockStatement.new(@stmt_list)
      end

      ## 0 for :set and :value, 1 for other
      @@depths = { :set => 0, :value => 0, :Value => 0, :VALUE => 0 }
      @@depths.default = 1

      ## :value and :loop cannot be used with empty tag
      @@empty_denied = {
         :value => true, :Value => true, :VALUE => true,
         :loop  => true, :Loop  => true, :LOOP  => true,
         :list  => true, :List  => true, :LIST  => true,
      }

      private

      def parse_expression(expr_str, linenum)
         @parser.reset(expr_str, linenum)
         expr = @parser.parse_expression()
         unless @parser.token() == nil
            raise ConvertionError.new("'#{expr_str}': invalid expression.", linenum, @filename)
         end
         return expr
      end

      def parse_expr_stmt(stmt_str)
         @parser.reset(stmt_str, 1)
         stmt = @parser.parse_expr_stmt()
         unless @parser.token() == nil
            raise ConvertionError.new("'#{stmt_str}': invalid statement.", linenum, @filename)
         end
         return stmt
      end

      def save_taginfo()
         hash = {
            :tagname       => @tagname,
            :is_empty      => (@slash_empty == '/'),
            :attr_names    => @attr_names,
            :attr_values   => @attr_values,
            :attr_spaces   => @attr_spaces,
            :append_exprs  => @append_exprs,
            :before_space  => @before_space,
            :after_space   => @after_space,
            :extra_space   => @extra_space,
            :linenum       => @linenum,
            :is_whole_line => @is_whole_line,
            #:is_begline    => @is_begline,
            #:is_endline    => @is_endline,
         }
         return hash
      end


      def _convert(etagname, stmt_list=[], flag_tag_print=true)
         start_linenum = @linenum
         if etagname
            Kwartz::assert unless @tagname == etagname
            #if flag_tag_print
            #   if @tagname == 'span' && @attr_values.empty?
            #      stmt_list << create_print_node('', @linenum)
            #   else
            #      stmt_list << build_print_node()
            #   end
            #end
            if flag_tag_print
               if @tagname == 'span' && @attr_values.empty?
                  flag_spantag = true
                  s = @is_whole_line ? '' : @before_space + @after_space
                  stmt_list << create_print_node(s, @linenum)
               else
                  flag_spantag = false
                  stmt_list << build_print_node()
               end
            end
         end

         while tagname = fetch()
            if !@before_text.empty?
               stmt_list << create_print_node(@before_text, @linenum)
            end

            if @slash_etag == '/'		# end-tag
               if @tagname == etagname
                  #if flag_tag_print
                  #   if @tagname == 'span' && @attr_values.empty?
                  #      stmt_list << create_print_node('', @linenum)
                  #   else
                  #      stmt_list << build_print_node()
                  #   end
                  #end
                  if flag_tag_print
                     if flag_spantag
                        s = @is_whole_line ? '' : @before_space + @after_space
                        stmt_list << create_print_node(s, @linenum)
                     else
                        stmt_list << create_print_node(@tag_str, @linenum)
                     end
                  end
                  return stmt_list
               else
                  stmt_list << create_print_node(@tag_str, @linenum)
               end
            elsif @slash_empty == '/'		# empty-tag
               directive_name, directive_arg = parse_attr_str(@attr_str)
               if directive_name
                  if directive_name == :mark
                     body_stmt_list = []
                  elsif @tagname == 'span' && @attr_values.empty?
                     s = @is_whole_line ? '' : @before_space + @after_space
                     body_stmt = create_print_node(s, @linenum)
                     body_stmt_list = [ body_stmt ]
                  else
                     body_stmt = build_print_node()
                     body_stmt_list = [ body_stmt ]
                  end
                  taginfo = save_taginfo()
                  handle_directive(directive_name, directive_arg, body_stmt_list, stmt_list, @linenum, taginfo, nil)
               else
                  stmt_list << build_print_node()
               end
            else				# start-tag
               directive_name, directive_arg = parse_attr_str(@attr_str)
               if directive_name
                  body_stmt_list = []
                  stag_linenum = @linenum
                  staginfo = save_taginfo()
                  _convert(@tagname, body_stmt_list, directive_name != :mark)
                  etaginfo = save_taginfo()
                  handle_directive(directive_name, directive_arg, body_stmt_list, stmt_list, stag_linenum, staginfo, etaginfo)
               elsif @tagname == etagname
                  _convert(@tagname, stmt_list)
               else
                  stmt_list << build_print_node()
               end
            end
         end # of while

         if etagname
            raise ConvertionError.new("'<#{etagname}>' is not closed by end-tag.", start_linenum, @filename)
         end
         if !@input.empty?
            stmt_list << create_print_node(@input, @linenum)
         end
         return stmt_list
      end


      def handle_directive(directive_name, directive_arg, body_stmt_list, stmt_list, linenum, staginfo, etaginfo)
         case directive_name
         when :mark
            marking = directive_arg
            @elem_list << Element.create_from_taginfo(marking, staginfo, etaginfo, body_stmt_list)
            stmt_list << ExpandStatement.new(:element, marking)

         when :foreach, :Foreach, :FOREACH, :loop, :Loop, :LOOP, :list, :List, :LIST
            is_loop = (directive_name != :foreach && directive_name != :Foreach && directive_name != :FOREACH)
            if is_loop && !etaginfo
               msg = "directive '#{directive_name}' cannot use with empty tag."
               raise ConvertionError.new(msg, linenum, @filename)
            end
            unless directive_arg =~ /\A(\w+)\s*[:=]\s*(.*)/
               msg = "'#{directive_name}:#{directive_arg}': invalid directive."
               raise ConvertionError.new(msg, linenum, @filename)
            end
            var_name = $1
            list_str = $2
            loopvar_expr = VariableExpression.new(var_name)
            list_expr = parse_expression(list_str, linenum)
            if is_loop
               first_stmt = body_stmt_list.shift
               last_stmt  = body_stmt_list.pop
            end
            stmt_list << first_stmt if is_loop
            if directive_name == :foreach || directive_name == :loop || directive_name == :list
               stmt_list << ForeachStatement.new(loopvar_expr, list_expr, BlockStatement.new(body_stmt_list))
            elsif directive_name == :Foreach || directive_name == :Loop || directive_name == :List
               ctr_name = $1 + "_ctr"
               stmt_list << parse_expr_stmt("#{ctr_name} = 0;")
               body_stmt_list.unshift(parse_expr_stmt("#{ctr_name} += 1;"))
               stmt_list << ForeachStatement.new(loopvar_expr, list_expr, BlockStatement.new(body_stmt_list))
            elsif directive_name == :FOREACH || directive_name == :LOOP || directive_name == :LIST
               ctr_name = $1 + "_ctr"
               tgl_name = $1 + "_tgl"
               stmt_list << parse_expr_stmt("#{ctr_name} = 0;")
               body_stmt_list.unshift(parse_expr_stmt("#{tgl_name} = #{ctr_name} % 2 == 0 ? #{@even} : #{@odd};"))
               body_stmt_list.unshift(parse_expr_stmt("#{ctr_name} += 1;"))
               stmt_list << ForeachStatement.new(loopvar_expr, list_expr, BlockStatement.new(body_stmt_list))
            end
            stmt_list << last_stmt if is_loop

         when :value, :Value, :VALUE
            if !etaginfo
               msg = "directive '#{directive_name}' cannot use with empty tag."
               raise ConvertionError.new(msg, linenum, @filename)
            end
            expr = parse_expression(directive_arg, linenum)
            if directive_name == :Value
               expr = FunctionExpression.new("E", [ expr ])
            elsif directive_name == :VALUE
               expr = FunctionExpression.new("X", [ expr ])
            end
            first_stmt = body_stmt_list.shift
            last_stmt  = body_stmt_list.pop
            stmt_list << first_stmt
            stmt_list << PrintStatement.new( [ expr ] )
            stmt_list << last_stmt

         when :if
            expr = parse_expression(directive_arg, linenum)
            stmt_list << IfStatement.new(expr, BlockStatement.new(body_stmt_list))

         when :elseif
            expr = parse_expression(directive_arg, linenum)
            stmt = stmt_list[-1]
            while stmt.token() == :if && stmt.else_stmt != nil
               stmt = stmt.else_stmt
            end
            unless stmt.token() == :if
               raise ConvertionError.new("elseif-directive must be at just after the if-statement or elseif-statement.", linenum, @filename)
            end
            stmt.else_stmt = IfStatement.new(expr, BlockStatement.new(body_stmt_list))

         when :else
            stmt = stmt_list[-1]
            while stmt.token() == :if && stmt.else_stmt != nil
               stmt = stmt.else_stmt
            end
            unless stmt.token() == :if
               raise ConvertionError.new("else-directive must be at just after the if-statement or elseif-statement.", linenum, @filename)
            end
            stmt.else_stmt = BlockStatement.new(body_stmt_list)

         when :set
            expr = parse_expression(directive_arg, linenum)
            stmt_list << ExprStatement.new(expr)
            stmt_list.concat(body_stmt_list)

         when :while
            expr = parse_expression(directive_arg, linenum)
            stmt_list << WhileStatement.new(expr, BlockStatement.new(body_stmt_list))

         when :dummy
            # nothing

         when :replace
            name = directive_arg
            unless name =~ /\A\w+\z/
               raise ConvertionError.new("'#{name}': invalid name for replace-directive.", linenum, @filename)
            end
            stmt_list << ExpandStatement.new(:element, name)

         else
            raise ConvertionError.new("'#{directive_name}': invalid directive", linenum, @filename)
         end
      end


      def parse_attr_str(str=@attr_str)
         while str =~ /\A(\s*)([-:_\w]+)="(.*?)"/
            space      = $1
            attr_name  = $2
            attr_value = $3
            @attr_names << attr_name
            @attr_values[attr_name] = attr_value
            @attr_spaces[attr_name] = space
            str = $'
         end
         Kwartz::assert unless str.empty?

         if @attr_values['id']
            dname, darg = parse_attr_idvalue(@attr_values['id'])
            if dname
               directive_name = dname
               directive_arg = darg
            end
            if @attr_values['id'] !~ /\A[-_\w]+\z/
               @attr_values.delete('id')
               @attr_names.delete_if { |item| item=='id' }
            end
         end
         if @attr_values[@kd_attr]
            dname, darg = parse_attr_kdvalue(@attr_values[@kd_attr])
            if dname
               directive_name = dname
               directive_arg = darg
            end
            @attr_values.delete(@kd_attr)
            @attr_names.delete_if { |item| item==@kd_attr }
         end

         return directive_name, directive_arg
      end


      def parse_attr_idvalue(attr_value)
         if attr_value =~ /\A[-_\w]+\z/
            if attr_value.index(?-)
               return nil, nil
            else
               return :mark, attr_value
            end
         end
         return parse_attr_kdvalue(attr_value)
      end

      
      def parse_attr_kdvalue(attr_value)
         directive_name = directive_arg = nil
         attr_value.split(/;/).each do |str|
            #if str =~ /\A[_\w]+\z/
            #   directive_name = :mark
            #   directive_arg  = str
            #   next
            #end
            if str !~ /\A(\w+):(.*)\z/
               raise ConvertionError.new("'#{str}': invalid directive.", self)
            end
            d_name = $1.intern		# directive name
            d_arg  = $2		# directive arg
            case d_name
            when :attr, :Attr, :ATTR
               if d_arg !~ /^([-_\w]+(?::[-_\w]+)?)[:=](.*)$/
                  raise ConvertionError.new("'#{str}': invalid directive.", self)
               end
               attr_name = $1
               attr_value = $2
               e1, e2 = @@escape_matrix[d_name]
               s = "#{e1}#{attr_value}#{e2}"
               @attr_names << attr_name unless @attr_names.member?(attr_name)
               @attr_values[attr_name] = parse_expression(s, @linenum)
               #@attr_values[attr_name] = parse_expression("#{e1}#{attr_value}#{e2}", @linenum)
            when :append, :Append, :APPEND
               e1, e2 = @@escape_matrix[d_name]
               @append_exprs << parse_expression("#{e1}#{d_arg}#{e2}", @linenum)
            when :value, :Value, :VALUE, \
               :foreach, :Foreach, :FOREACH, :loop, :Loop, :LOOP, :list, :List, :LIST, \
               :if, :elsif, :elseif, :else, \
               :set, :while, :mark, :replace, :dummy
               if directive_name != nil
                  msg = "directive '#{directive_name}' and '#{d_name}': cannot specify two or more directives in an element."
                  raise ConvertionError.new(msg, self)
               end
               directive_name = d_name;  directive_arg  = d_arg
            else
               raise ConvertionError.new("'#{directive_name}': invalid directive name.", self)
            end
         end
         return directive_name, directive_arg
      end


      def build_print_node(linenum=@linenum)
         arguments = []
         arguments << StringExpression.new("#{@before_space}<#{@slash_etag}#{@tagname}")
         @attr_names.each do |aname|
            avalue = @attr_values[aname]
            aspace = @attr_spaces[aname] || ' '
            if avalue.is_a?(Expression)
               arguments << StringExpression.new("#{aspace}#{aname}=\"")
               arguments << avalue
               arguments << StringExpression.new("\"")
            else
               #arguments << StringExpression.new("#{aspace}#{aname}=\"#{avalue}\"")
               str  = "#{aspace}#{aname}=\"#{avalue}\""
               list = expand_embed_expr(str, linenum)
               arguments.concat(list)
            end
         end
         arguments.concat(@append_exprs) unless @append_exprs.empty?
         arguments << StringExpression.new("#{@extra_space}#{@slash_empty}>#{@after_space}")
         #
         arguments2 = []
         expr = nil
         arguments.each do |arg|
            if arg.is_a?(StringExpression)
               expr = expr ? StringExpression.new(expr.value + arg.value) : arg
            else
               if expr
                  arguments2 << expr
                  expr = nil
               end
               arguments2 << arg
            end
         end
         arguments2 << expr if expr
         return PrintStatement.new(arguments2)
      end

      
      def create_print_node(str, linenum)
         arguments = expand_embed_expr(str, linenum)
         return PrintStatement.new(arguments)
      end

      
      def expand_embed_expr(str, linenum)
         list = []
         while str =~ /\#\{(.*?)\}\#/
            front     = $`
            following = $'
            expr_str  = $1
            if front && !front.empty?
               list << StringExpression.new(front)
            end
            if expr_str && !expr_str.empty?
               list << parse_expression(expr_str, linenum)
            end
            str = following
         end
         if str && !str.empty?
            list << StringExpression.new(str)
         end
         return list
      end
      

      @@flag_matrix = {
         # directive_name => [ flag_loop, flag_counter, flag_toggle ]
         :foreach => [ false, false, false],
         :Foreach => [ false, true,  false],
         :FOREACH => [ false, true,  true ],
         :loop    => [ true,  false, false],
         :Loop    => [ true,  true,  false],
         :LOOP    => [ true,  true,  true ],
         :list    => [ true,  false, false],
         :List    => [ true,  true,  false],
         :LIST    => [ true,  true,  true ],
      }

      @@escape_matrix = {
         :attr   => [ '',   ''  ],
         :Attr   => [ 'E(', ')' ],
         :ATTR   => [ 'X(', ')' ],
         :append => [ '',   ''  ],
         :Append => [ 'E(', ')' ],
         :APPEND => [ 'X(', ')' ],
         :value  => [ '',   ''  ],
         :Value  => [ 'E(', ')' ],
         :VALUE  => [ 'X(', ')' ],
      }

   end # class Convertion

end # module Kwartz


if __FILE__ == $0

   input = ARGF.read()
   converter = Kwartz::Converter.new()
   #--
   #print converter.fetch_all
   #--
   block_stmt = converter.convert(input)
   print block_stmt._inspect
   converter.elem_list.each do |elem|
      print elem._inspect
   end
end
