###
### converter.rb
###
### $Id$
###

require 'kwartz/exception'
require 'kwartz/utility'

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
	 @macro_codes = []
	 @linenum  = 1
	 @delta    = 0
	 @properties = properties
	 @kd_attr    = properties[:attr_name] || 'kd'   # or 'kd::kwartz'
	 @ruby_attr  = properties[:ruby_attr_name] || 'kd::ruby'
	 @delete_id_attr = properties[:delete_id_attr] || false
	 @even_value = properties[:even_value] || 'even'
	 @odd_value  = properties[:odd_value]  || 'odd'
	 @filename   = properties[:filename]
      end

      FETCH_PATTERN = /([ \t]*)<(\/?)([-:_\w]+)((?:\s+[-:_\w]+="[^"]*?")*)(\s*)(\/?)>([ \t]*\r?\n?)/	#"

      def fetch
	 if @input !~ FETCH_PATTERN
	    @linenum += @delta
	    return @tag_name = nil
	 end

	 @before_text  = $`
	 @before_space = $1
	 @slash_etag   = $2		# "" or "/"
	 @tag_name     = $3
	 @attr_str     = $4
	 @extra_space  = $5
	 @slash_empty  = $6		# "" or "/"
	 @after_space  = $7

	 @linenum  += @delta
	 @linenum  += $`.count("\n")
	 @delta    =  $&.count("\n")

	 @input    = $'
	 return @tag_name
      end


      def fetch_all
	 s = ''
	 while tag_name = fetch()
	    s << "linenum+delta: #{@linenum}+#{@delta}\n"
	    s << "tag_name:      #{@slash_etag}#{@tag_name}#{@slash_empty}\n"
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
	 newline = "\n"
	 codes = _convert(nil, 0)
	 code = ""
	 if @macro_codes.length > 0
	    code << @macro_codes.join(newline)
	    code << newline << newline
	 end
	 code << codes.join(newline)
	 code << newline
	 return code
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

      def _convert(etag_name, depth)
         current_linenum = start_linenum = @linenum
	 codes = []
	 if etag_name
	    current_linenum = @linenum
	    codes << create_print_code(build_tag_str(), start_linenum, depth)
	 end
	 just_before_dname = nil		# just before directive name
	 while tag_name = fetch()
	    current_linenum = @linenum
	    if !@before_text.empty?
	       print_codes = create_print_codes(@before_text, current_linenum, depth)
	       codes.concat(print_codes)
	       just_before_dname = nil
	    end
	    directive_name, directive_arg = parse_attr_str()
	    last_dname = nil
	    if @slash_empty == '/'		# empty tag
	       if directive_name
		  if @@empty_denied[directive_name]
		     msg = "'#{directive_name}' directive cannot use in empty element."
		     raise ConvertionError.new(msg, current_linenum, @filename)
		  end
		  incr = @@depths[directive_name]  # if 'set' or 'value' then 0 else 1
		  code = create_print_code(build_tag_str(), current_linenum, depth + incr)
		  if tag_name == 'span' && @attr_str == ''
		     code.sub!(/\A([ ]*)/, '\1##')
		  end
		  body_codes = [ code ]
		  handle_directive(directive_name, directive_arg, codes, body_codes, current_linenum, depth, just_before_dname)
		  last_dname = directive_name
	       else
		  codes << create_print_code(build_tag_str(), current_linenum, depth)
	       end
	    elsif @slash_etag == '/'		# end tag
	       codes << create_print_code(build_tag_str(), current_linenum, depth)
	       if tag_name == etag_name
		  return codes		# return
	       end
	    else				# start tag
	       if directive_name
		  incr = @@depths[directive_name]  # if 'set' or 'value' then 0 else 1
		  body_codes = _convert(tag_name, depth + incr)	# call recursively
		  if tag_name == 'span' && @attr_str == ''
		     ## comment out ':print("<span>")' and ':print("</span>")'
		     body_codes[0].sub!(/\A([ ]*)/, '\1##')
		     body_codes[-1].sub!(/\A([ ]*)/, '\1##')
		  end
		  handle_directive(directive_name, directive_arg, codes, body_codes, current_linenum, depth, just_before_dname)
		  last_dname = directive_name
	       elsif tag_name == etag_name
		  codes2 = _convert(tag_name, depth)		# call recursively
		  codes.concat(codes2)
	       else
		  codes << create_print_code(build_tag_str(), current_linenum, depth)
	       end
	    end
	    just_before_dname = last_dname
	 end
	 if etag_name
	    raise ConvertionError.new("'<#{etag_name}>' is not closed by end-tag.", start_line, @filename)
	 end
	 if !@input.empty?
	    print_codes = create_print_codes(@input, current_linenum, depth)
	    codes.concat(print_codes)
	 end
	 return codes;
      end


      def parse_attr_str()
	 attr_list = []
	 attr_hash = {}
	 str = @attr_str
	 while str =~ /\A(\s*)([-:_\w]+)="(.*?)"/
	    space      = $1
	    attr_name  = $2
	    attr_value = $3
	    attr_list << [space, attr_name, attr_value]
	    attr_hash[attr_name] = attr_value
	    str = $'
	 end
	 Kwartz::assert(str.empty?)

	 append_str = ""
	 flag_rebuild = false
	 if attr_hash['id']
	    dname, darg = parse_attr_idvalue(attr_hash['id'], attr_hash, append_str)
	    if dname;  directive_name = dname; directive_arg = darg;  end
	    flag_rebuild = true
	 end
	 if attr_hash[@kd_attr]
	    dname, darg = parse_attr_kdvalue(attr_hash[@kd_attr], attr_hash, append_str)
	    if dname;  directive_name = dname; directive_arg = darg;  end
	    flag_rebuild = true
	 end
	 if attr_hash[@ruby_attr]
	    dname, darg = parse_attr_rubyvalue(attr_hash[@ruby_attr], attr_hash, append_str)
	    if dname;  directive_name = dname; directive_arg = darg;  end
	    flag_rebuild = true
	 end

	 if flag_rebuild
	    str = ''
	    attr_list.each do |attr|
	       space = attr[0]
	       attr_name = attr[1]
	       attr_value = attr_hash[attr_name]
	       if attr_name == @ruby_attr || attr_name == @kd_attr
		  # nothing
	       elsif attr_name == 'id' && (@delete_id_attr || attr_value !~ /\A[-_\w]+\z/)
		  # nothing
	       else
		  str << "#{space}#{attr_name}=\"#{attr_value}\""
	       end
	       attr_hash.delete(attr_name)
	    end
	    if ! attr_hash.empty?
	       attr_hash.each do |a_name, a_value|
		  str << " #{a_name}=\"#{a_value}\""
	       end
	    end
	    @attr_str = str
	 end

	 @attr_str << append_str if ! append_str.empty?

	 return directive_name, directive_arg
      end


      def parse_attr_idvalue(attr_value, attr_hash, append_str)
	 if attr_value =~ /\A[-_\w]+\z/
	    if attr_value.index(?-)
	       return nil, nil
	    else
	       return :mark, attr_value
	    end
	 end
	 return parse_attr_kdvalue(attr_value, attr_hash, append_str)
      end


      def parse_attr_kdvalue(attr_value, attr_hash, append_str)
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
	       attr_hash[attr_name] = '#{' + "#{e1}#{attr_value}#{e2}" + '}#'
	    when :append, :Append, :APPEND
	       e1, e2 = @@escape_matrix[d_name]
	       append_str << ' #{' + "#{e1}#{d_arg}#{e2}" + '}#'
	    when :value, :Value, :VALUE, \
	         :foreach, :Foreach, :FOREACH, :loop, :Loop, :LOOP, :list, :List, :LIST, \
		 :if, :elsif, :elseif, :else, \
		 :set, :while, :mark, :replace, :dummy
	       if directive_name != nil
		  msg = "directive '#{directive_name}' and '#{d_name}': cannot specify two or more directives in one element."
		  raise ConvertionError.new(msg, self)
	       end
	       directive_name = d_name;  directive_arg  = d_arg
	    else
	       raise ConvertionError.new("'#{directive_name}': invalid directive name.", self)
	    end
	 end
	 return directive_name, directive_arg
      end


      def parse_attr_rubyvalue(attr_value, attr_hash, append_str)
	 return nil
      end


      def create_print_code(str, linenum, depth)
	 s = ''
	 s << indent(depth)
	 s << ":print("
	 flag = false
	 while str =~ /\#\{(.*?)\}\#/
	    expr_str = $1
	    before_text = $`
	    after_text = $'
	    if before_text && !before_text.empty?
	       s << ", " if flag
	       s << Kwartz::Util::dump_str(before_text)
	       flag = true
	    end
	    if expr_str && !expr_str.empty?
	       s << ", " if flag
	       s << expr_str
	       flag = true
	    end
	    str = $'
	 end
	 if str && !str.empty?
	    s << ", " if flag
	    s << Kwartz::Util::dump_str(str)
	 end
	 s << ")"
	 return s
      end


      def create_print_codes(str, linenum, depth)
	 list = []
	 idx = 0
	 str.each_line do |line|
	    list << create_print_code(line, idx+linenum, depth)
	    idx += 1
	 end
	 return list
      end


      def build_tag_str
	 return "#{@before_space}<#{@slash_etag}#{@tag_name}#{@attr_str}#{@extra_space}#{@slash_empty}>#{@after_space}"
      end


      def indent(depth)
	 s = ''
	 depth.times { s << '  ' }
	 return s
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

      def handle_directive(directive_name, directive_arg, codes, body_codes, linenum, depth, just_before_dname)
	 s = indent(depth)
	 case directive_name
	 when :value, :Value, :VALUE
	    codes << body_codes.shift
	    e1, e2 = @@escape_matrix[directive_name]
	    codes << "#{s}:print(#{e1}#{directive_arg}#{e2})"
	    codes << body_codes.pop

	 when :mark
	    name = directive_arg
	    stag_code  = body_codes.shift
	    etag_code  = body_codes.pop || "  ## nothing"
	    cont_codes = body_codes.length > 0 ? body_codes : [ "  ## nothing" ]
	    @macro_codes << ":macro(stag_#{name})"
	    @macro_codes << stag_code
	    @macro_codes << ":end"
	    @macro_codes << ":macro(cont_#{name})"
	    @macro_codes.concat(cont_codes)
	    @macro_codes << ":end"
	    @macro_codes << ":macro(etag_#{name})"
	    @macro_codes << etag_code
	    @macro_codes << ":end"
	    @macro_codes << ":macro(element_#{name})"
	    @macro_codes << "  :expand(stag_#{name})"
	    @macro_codes << "  :expand(cont_#{name})"
	    @macro_codes << "  :expand(etag_#{name})"
	    @macro_codes << ":end"
	    codes << "#{s}:expand(element_#{name})"

	 when :foreach, :Foreach, :FOREACH, :loop, :Loop, :LOOP, :list, :List, :LIST
	    unless directive_arg =~ /\A(\w+)\s*[:=]\s*(.*)/
	       msg = "'#{directive_name}:#{directive_arg}': invalid directive."
	       raise ConvertionError.new(msg, linenum, @filename)
	    end
	    loopvar  = $1
	    listexpr = $2
	    counter  = "#{loopvar}_ctr"
	    toggle   = "#{loopvar}_tgl"

	    flag_loop, flag_counter, flag_toggle = @@flag_matrix[directive_name]
	    if flag_loop
	       first_code = body_codes.shift
	       last_code  = body_codes.pop
	    else
	       first_code = last_code = nil
	    end

	    codes << first_code.sub(/\A  /, '')			if first_code
	    codes << "#{s}:set(#{counter} = 0)"			if flag_counter
	    codes << "#{s}:foreach(#{loopvar}=#{listexpr})"
	    codes << "#{s}  :set(#{counter} += 1)"		if flag_counter
	    codes << "#{s}  :set(#{toggle} = #{counter}%2==0 ? '#{@even_value}' : '#{@odd_value}')"  if flag_toggle
	    codes.concat(body_codes)
	    codes << "#{s}:end"
	    codes << last_code.sub(/\A  /, '')			if last_code

	 when :if
	    codes << "#{s}:if(#{directive_arg})"
	    codes.concat(body_codes)
	    codes << "#{s}:end"

	 when :elsif, :elseif, :else
	    d = just_before_dname
	    unless d == :if || d == :elseif || d == :elsif
	       msg = "'#{directive_name}' directive should be just after 'if' or 'elseif'."
	       raise ConvertionError.new(msg, linenum, @filename)
	    end
	    codes.pop		# ignore ':end' of if-statement
	    if directive_name == :else
	       codes << "#{s}:else"
	    else
	       codes << "#{s}:elseif(#{directive_arg})"
	    end
	    codes.concat(body_codes)
	    codes << "#{s}:end"

	 when :while
	    codes << "#{s}:while(#{directive_arg})"
	    codes.concat(body_codes)
	    codes << "#{s}:end"

	 when :set
	    if directive_arg =~ /\A(\w+):(.*)\z/
	       codes << "#{s}:set(#{$1} = #{$2})"
	    else
	       codes << "#{s}:set(#{directive_arg})"
	    end
	    codes.concat(body_codes)

	 when :replace
	    name = directive_arg
	    codes << "#{s}:expand(element_#{name})"

	 when :dummy
	    # nothing

	 else
	    msg = "'#{directive_name}': invalid directive name."
	    raise ConvertionError.new(msg, linenum, @filename)
	 end

	 return codes
      end

   end # class Convertion

end # module Kwartz
