###
### copyright(c) 2005 kuwata-lab all rights reserved
###
### $Id$
###

module Kwartz

   class Element
      def initialize(name, tagname, content_stmt, attrs={}, append_expr=[], is_empty=false, spaces=['','','',''], stag_whole_line=false, etag_whole_line=false)
         @name     = name
         @tagname  = tagname
         @content  = content_stmt
         @attrs    = attrs       || {}
         @append   = append_expr || []
         @is_empty = is_empty
         @spaces   = spaces
         @stag_whole_line = stag_whole_line
         @etag_whole_line = etag_whole_line
         list = [ ExpandStatement.new(:stag), ExpandStatement.new(:cont), ExpandStatement.new(:etag) ]
         @plogic   = BlockStatement.new(list)
      end
      attr_accessor :name, :tagname, :content, :attrs, :append, :is_empty, :spaces, :plogic
      alias :marking :name


      def swallow(decl)
         return unless @name == decl.name
         part = decl.part
         @tagname = part[:tagname] if part[:tagname]
         @content = PrintStatement.new([part[:value]]) if part[:value]
         part[:attr].each do |key,val|
            @attrs[key] = val
         end if part[:attr]
         part[:remove].each do |aname|
            @attrs.delete(aname)
         end if part[:remove]
         @append.concat(part[:append]) if part[:append]
         @plogic = part[:plogic] if part[:plogic]
      end


      def self.create_from_taginfo(name, staginfo, etaginfo, body_stmt_list)
         Kwartz::assert unless !etaginfo || staginfo[:tagname] == etaginfo[:tagname]
         tagname      = staginfo[:tagname]
         content      = BlockStatement.new(body_stmt_list)
         attrs        = staginfo[:attr_values]
         append_expr  = staginfo[:append_expr]
         is_empty     = staginfo[:is_empty]
         spaces       = [
            staginfo[:before_space],
            staginfo[:after_space],
            etaginfo ? etaginfo[:before_space] : '',
            etaginfo ? etaginfo[:after_space]  : '',
         ]
         stag_whole_line  = staginfo[:is_whole_line]
         etag_whole_line  = etaginfo ? etaginfo[:is_whole_line] : nil
         return Element.new(name, tagname, content, attrs, append_expr, is_empty, spaces, stag_whole_line, etag_whole_line)
      end


      def stag_stmt(properties={})
         arguments = []
         if @tagname == 'span' && @attrs.empty? && @append.empty?
            s = @stag_whole_line ? '' : spaces[0] + spaces[1]
            arguments << StringExpression.new(s) if !s.empty?
            return PrintStatement.new(arguments)
         end
         if @tagname.is_a?(String)
            arguments << StringExpression.new("#{@spaces[0]}<#{@tagname}")
         elsif @tagname.is_a?(Expression)
            arguments << StringExpression.new("#{@spaces[0]}<")
            arguments << @tagname
         else
            Kwartz::assert
         end
         @attrs.each do |aname, avalue|
            if avalue.is_a?(String)
               arguments << StringExpression.new(" #{aname}=\"#{avalue}\"")
            elsif avalue.is_a?(Expression)
               arguments << StringExpression.new(" #{aname}=\"")
               arguments << avalue
               arguments << StringExpression.new("\"")
            else
               Kwartz::assert
            end
         end
         @append.each do |expr|
            arguments << expr
         end if @append
         s = (@is_empty && properties[:html] != true) ? ' /' : ''
         arguments << StringExpression.new("#{s}>#{spaces[1]}")
         return PrintStatement.new(arguments)
      end


      def cont_stmt(properties={})
         #Kwartz::assert unless @is_empty && @content
         return @content
      end


      def etag_stmt(properties={})
         #return nil if @is_empty
         return BlockStatement.new([]) if @is_empty   # for bug 1110250
         arguments = []
         if @tagname == 'span' && @attrs.empty? && @append.empty?
            s = @etag_whole_line ? '' : spaces[2] + spaces[3]
            arguments << StringExpression.new(s) if !s.empty?
            return PrintStatement.new(arguments)
         end
         if @tagname.is_a?(String)
            arguments << StringExpression.new("#{@spaces[2]}</#{@tagname}>#{@spaces[3]}")
         elsif @tagname.is_a?(Expression)
            arguments << StringExpression.new("#{@spaces[2]}</")
            arguments << @tagname
            arguments << StringExpression.new(">#{@space[3]}")
         else
            Kwartz::assert
         end
         return PrintStatement.new(arguments)
      end


      def statement(properties={})
         list = []
         list << stag_stmt(properties)
         stmt = cont_stmt(properties)
         if stmt.token == :block
            list.concat(stmt.statements)
         else
            list << stmt
         end
         list << etag_stmt(properties)
         return BlockStatement.new(list)
      end


      def _inspect()
         s = ''
         s << "===== marking=#{@name} =====\n"
         s << "[tagname]\n#{@tagname}#{@is_empty ? '/':''}\n"
         s << "[attrs]\n"
         @attrs.each do |key,val|
            s << "#{key}=" << (val.is_a?(Expression) ? val._inspect : '"'+val.to_s+"\"\n")
         end
         if @append && !@append.empty?
            s << "[append]\n"
            @append.each do |expr|
               s << expr._inspect
            end
         end
         if @remove && !@remove.empty?
            s << "[remove]\n"
            @remove.each_with_index do |str, i|
               s << " " if i > 0
               s << str.dump
            end
            s << "\n"
         end
         s << "[content]\n" << @content._inspect       if @content
         s << "[spaces]\n"  << @spaces.inspect << "\n" if @spaces
         s << "[plogic]\n"  << @plogic._inspect        if @plogic
         return s
      end


      ## returns element_table (hash of element.name => element)
      def self.merge(element_list, decl_list)
         decl_table = {}
         decl_list.each do |decl|
            decl_table[decl.name] = decl
         end if decl_list
         element_table = {}
         element_list.each do |elem|
            decl = decl_table[elem.name]
            elem.swallow(decl) if decl
            element_table[elem.name] = elem
         end if element_list
         return element_table
      end

   end


   class Declaration
      def initialize(name, part={})
         @name = name
         @part = part
      end
      attr_reader :name, :part

      def _inspect()
         h = @part
         s = "\##{@name} {\n"
         s <<    "  value:\n" << h[:value]._inspect(2) if h[:value]
         if h[:attr]
            s << "  attr:\n"
            h[:attr].keys.sort.each do |key|
               s << "    \"#{key}\" " << h[:attr][key]._inspect()
            end
         end
         if h[:append]
            s << "  append:\n"
            h[:append].each do |expr|
               s << expr._inspect(2)
            end
         end
         s << "  remove:\n    " << h[:remove].sort.collect{|aname| '"'+aname+'"'}.join(",") << "\n" if h[:remove] && !h[:remove].empty?
         s << "  tagname:\n" << h[:tagname]._inspect(2) if h[:tagname]
         s << "  plogic:\n"  << h[:plogic]._inspect(2)  if h[:plogic]
         s << "  begin:\n"   << h[:begin]._inspect(2)   if h[:begin]
         s << "  end:\n"     << h[:end]._inspect(2)     if h[:end]
         s << "  global: "   << h[:global].join(', ') << ";\n" if h[:global]
         s << "  local: "    << h[:local].join(', ')  << ";\n" if h[:local]
         s << "}\n"
         return s
      end

   end

end
