###
### copyright(c) 2005 kuwata-lab all rights reserved
###
### $Id$
###

require 'kwartz/exception'
require 'kwartz/utility'
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
      
      def initialize(input, properties={})
         @input = input
         #@macro_codes = []
         @linenum  = 1
         @delta    = 0
         @properties = properties
         @kd_attr    = properties[:attr_name] || 'kd'   # or 'kd::kwartz'
         #@ruby_attr  = properties[:ruby_attr_name] || 'kd::ruby'
         #@delete_id_attr = properties[:delete_id_attr] || false
         @even_value = properties[:even_value] || "'even'"
         @odd_value  = properties[:odd_value]  || "'odd'"
         @filename   = properties[:filename]
         @parser = Parser.new('', properties)
         @stmt_list = []
         @elem_list = []
      end
      attr_reader :stmt_list, :elem_list
      alias :element_list :elem_list
      
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
         @tagname     = $3
         @attr_str     = $4
         @extra_space  = $5
         @slash_empty  = $6		# "" or "/"
         @after_space  = $7
         
         @linenum  += @delta
         @linenum  += $`.count("\n")
         @delta    =  $&.count("\n")

         @attr_names  = []
         @attr_values = {}
         @attr_spaces = {}
         @append_exprs = []
         
         @input    = $'
         return @tagname
      end
      
      
      def fetch_all
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

      def convert
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
         return @parser.parse_expression()
      end
      
      def parse_expr_stmt(stmt_str)
         @parser.reset(stmt_str, 1)
         return @parser.parse_expr_stmt()
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
            :is_begline    => (@before_text || @before_text[-1] == ?\n),
            :is_endline    => (@after_space && @after_space[-1] == ?\n),
         }
         return hash
      end

      
      def _convert(etagname, stmt_list=[], flag_print_tag=true)
         start_linenum = @linenum
         if etagname
            Kwartz::assert(@tagname == etagname)
            stmt_list << build_print_node() if flag_print_tag
         end

         while tagname = fetch()
            if !@before_text.empty?
               stmt_list << create_print_node(@before_text, @linenum)
            end
            
            if @slash_etag == '/'		# end-tag
               if @tagname == etagname
                  stmt_list << create_print_node(@tag_str, @linenum) if flag_print_tag
                  return stmt_list
               else
                  stmt_list << create_print_node(@tag_str, @linenum)
               end
            elsif @slash_empty == '/'		# empty-tag
               directive_name, directive_arg = parse_attr_str(@attr_str)
               if directive_name
                  if directive_name == :mark
                     body_stmt_list = []
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
                  current_linenum = @linenum
                  staginfo = save_taginfo()
                  _convert(@tagname, body_stmt_list, directive_name != :mark)
                  etaginfo = save_taginfo()
                  handle_directive(directive_name, directive_arg, body_stmt_list, stmt_list, current_linenum, staginfo, etaginfo)
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
               stmt_list << parse_expr_stmt("#{ctr_name} = 0")
               body_stmt_list.unshift(parse_expr_stmt("#{ctr_name} += 1;"))
               stmt_list << ForeachStatement.new(loopvar_expr, list_expr, BlockStatement.new(body_stmt_list))
            elsif directive_name == :FOREACH || directive_name == :LOOP || directive_name == :LIST
               ctr_name = $1 + "_ctr"
               tgl_name = $1 + "_tgl"
               stmt_list << parse_expr_stmt("#{ctr_name} = 0;")
               body_stmt_list.unshift(parse_expr_stmt("#{tgl_name} = #{ctr_name} % 2 == 0 ? #{@even_value} : #{@odd_value};"))
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
         Kwartz::assert(str.empty?)
         
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


      def create_print_node(str, linenum)
         arguments = []
         while str =~ /\#\{(.*?)\}\#/
            expr_str = $1
            before_text = $`
            after_text = $'
            if before_text && !before_text.empty?
               arguments << StringExpression.new(before_text)
            end
            if expr_str && !expr_str.empty?
               arguments << parse_expression(expr_str, linenum)
            end
            str = after_text
         end
         if str && !str.empty?
            arguments << StringExpression.new(str)
         end
         return PrintStatement.new(arguments)
      end

      def build_print_node()
         arguments = []
         #flag_expr_exist = false
         #if @attr_values.values.find { |val| val.is_a?(Expression) }
         #   flag_expr_exist = true
         #elsif !@append_exprs.empty?
         #   flag_expr_exist = true
         #end
         #if !flag_expr_exist
         #   arguments << StringExpression.new(@tag_str)
         #   return PrintStatement.new(arguments)
         #end
         arguments << StringExpression.new("#{@before_space}<#{@slash_etag}#{@tagname}")
         @attr_names.each do |aname|
            avalue = @attr_values[aname]
            aspace = @attr_spaces[aname] || ' '
            if avalue.is_a?(Expression)
               arguments << StringExpression.new("#{aspace}#{aname}=\"")
               arguments << avalue
               arguments << StringExpression.new("\"")
            else
               arguments << StringExpression.new("#{aspace}#{aname}=\"#{avalue}\"")
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

      def build_tag_str
         s = "#{@before_space}<#{@slash_etag}#{@tagname}"
         @attr_names.each do |aname|
            s << "#{@attr_spaces[aname]}#{@attr_values[aname]}"
         end
         s << "#{@extra_space}#{@slash_empty}>#{@after_space}"
	 #return "#{@before_space}<#{@slash_etag}#{@tagname}#{@attr_str}#{@extra_space}#{@slash_empty}>#{@after_space}"
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

#      def handle_directive(directive_name, directive_arg, codes, body_codes, linenum, depth, just_before_dname)
#	 s = indent(depth)
#	 case directive_name
#	 when :value, :Value, :VALUE
#	    codes << body_codes.shift
#	    e1, e2 = @@escape_matrix[directive_name]
#	    codes << "#{s}:print(#{e1}#{directive_arg}#{e2})"
#	    codes << body_codes.pop
#
#	 when :mark
#	    name = directive_arg
#	    stag_code  = body_codes.shift
#	    etag_code  = body_codes.pop || "  ## nothing"
#	    cont_codes = body_codes.length > 0 ? body_codes : [ "  ## nothing" ]
#	    @macro_codes << ":macro(stag_#{name})"
#	    @macro_codes << stag_code
#	    @macro_codes << ":end"
#	    @macro_codes << ":macro(cont_#{name})"
#	    @macro_codes.concat(cont_codes)
#	    @macro_codes << ":end"
#	    @macro_codes << ":macro(etag_#{name})"
#	    @macro_codes << etag_code
#	    @macro_codes << ":end"
#	    @macro_codes << ":macro(element_#{name})"
#	    @macro_codes << "  :expand(stag_#{name})"
#	    @macro_codes << "  :expand(cont_#{name})"
#	    @macro_codes << "  :expand(etag_#{name})"
#	    @macro_codes << ":end"
#	    codes << "#{s}:expand(element_#{name})"
#
#	 when :foreach, :Foreach, :FOREACH, :loop, :Loop, :LOOP, :list, :List, :LIST
#	    unless directive_arg =~ /\A(\w+)\s*[:=]\s*(.*)/
#	       msg = "'#{directive_name}:#{directive_arg}': invalid directive."
#	       raise ConvertionError.new(msg, linenum, @filename)
#	    end
#	    loopvar  = $1
#	    listexpr = $2
#	    counter  = "#{loopvar}_ctr"
#	    toggle   = "#{loopvar}_tgl"
#
#	    flag_loop, flag_counter, flag_toggle = @@flag_matrix[directive_name]
#	    if flag_loop
#	       first_code = body_codes.shift
#	       last_code  = body_codes.pop
#	    else
#	       first_code = last_code = nil
#	    end
#
#	    codes << first_code.sub(/\A  /, '')			if first_code
#	    codes << "#{s}:set(#{counter} = 0)"			if flag_counter
#	    codes << "#{s}:foreach(#{loopvar}=#{listexpr})"
#	    codes << "#{s}  :set(#{counter} += 1)"		if flag_counter
#	    codes << "#{s}  :set(#{toggle} = #{counter}%2==0 ? '#{@even_value}' : '#{@odd_value}')"  if flag_toggle
#	    codes.concat(body_codes)
#	    codes << "#{s}:end"
#	    codes << last_code.sub(/\A  /, '')			if last_code
#
#	 when :if
#	    codes << "#{s}:if(#{directive_arg})"
#	    codes.concat(body_codes)
#	    codes << "#{s}:end"
#
#	 when :elsif, :elseif, :else
#	    d = just_before_dname
#	    unless d == :if || d == :elseif || d == :elsif
#	       msg = "'#{directive_name}' directive should be just after 'if' or 'elseif'."
#	       raise ConvertionError.new(msg, linenum, @filename)
#	    end
#	    codes.pop		# ignore ':end' of if-statement
#	    if directive_name == :else
#	       codes << "#{s}:else"
#	    else
#	       codes << "#{s}:elseif(#{directive_arg})"
#	    end
#	    codes.concat(body_codes)
#	    codes << "#{s}:end"
#
#	 when :while
#	    codes << "#{s}:while(#{directive_arg})"
#	    codes.concat(body_codes)
#	    codes << "#{s}:end"
#
#	 when :set
#	    if directive_arg =~ /\A(\w+):(.*)\z/
#	       codes << "#{s}:set(#{$1} = #{$2})"
#	    else
#	       codes << "#{s}:set(#{directive_arg})"
#	    end
#	    codes.concat(body_codes)
#
#	 when :replace
#	    name = directive_arg
#	    codes << "#{s}:expand(element_#{name})"
#
#	 when :dummy
#	    # nothing
#
#	 else
#	    msg = "'#{directive_name}': invalid directive name."
#	    raise ConvertionError.new(msg, linenum, @filename)
#	 end
#
#	 return codes
#      end

   end # class Convertion

end # module Kwartz


if __FILE__ == $0

   input = ARGF.read()
   converter = Kwartz::Converter.new(input)
   #--
   #print converter.fetch_all
   #--
   block_stmt = converter.convert()
   print block_stmt._inspect
   converter.elem_list.each do |elem|
      print elem._inspect
   end
end
