###
### copyright(c) 2005 kuwata-lab all rights reserved
###
### $Id$
###

module Kwartz

   class Element
      def initialize(name, tagname, content_stmt, attrs={}, append_expr=[], is_empty=false, spaces=['','','',''])
         @name     = name
         @tagname  = tagname
         @content  = content_stmt
         @attrs    = attrs       || {}
         @append   = append_expr || []
         @is_empty = is_empty
         @spaces   = spaces
         list = [ ExpandStatement.new(:stag), ExpandStatement.new(:cont), ExpandStatement.new(:etag) ]
         @plogic   = BlockStatement.new(list)
         @remove   = []
      end
      attr_accessor :name, :tagname, :content, :attrs, :append, :is_empty, :spaces, :plogic
      alias :marking :name

      def swallow(elem_decl)
         return unless @name == elem_decl.name
         @tagname = elem_decl.tagname if elem_decl.tagname
         @content = PrintStatement.new([elem_decl.value]) if elem_decl.value
         elem_decl.attrs.each do |key,val|
            @attrs[key] = val
         end if elem_decl.attrs
         @append.concat(elem_decl.append) if elem_decl.append
         @remove.concat(elem_decl.remove) if elem_decl.remove
         @plogic = elem_decl.plogic if elem_decl.plogic
      end
      
      def self.create_from_taginfo(name, staginfo, etaginfo, body_stmt_list)
         Kwartz::assert unless !etaginfo || staginfo[:tagname] == etaginfo[:tagname]
         tagname      = staginfo[:tagname]
         content      = BlockStatement.new(body_stmt_list)
         attrs        = staginfo[:attr_values]
         append_expr  = staginfo[:append_expr]
         is_empty     = staginfo[:is_empty]
         spaces       = [  staginfo[:before_space],
                           staginfo[:after_space],
                           etaginfo ? etaginfo[:before_space] : '',
                           etaginfo ? etaginfo[:after_space]  : '',
                        ]
         stag_begend  = [ staginfo[:is_begline], staginfo[:is_endline ], ]
         etag_begend  = etaginfo ? [ etaginfo[:is_begline], etaginfo[:is_endline ], ] : nil
         return Element.new(name, tagname, content, attrs, append_expr, is_empty, spaces)
      end
      
      def stag_stmt(properties={})
         arguments = []
         if @tagname.is_a?(String)
            arguments << StringExpression.new("#{@spaces[0]}<#{@tagname}")
         elsif @tagname.is_a?(Expression)
            arguments << StringExpression.new("#{@spaces[0]}<")
            arguments << @tagname
         else
            Kwartz::assert
         end
         @attrs.each do |aname, avalue|
            if @remove && @remove.include?(aname)
               next
            elsif avalue.is_a?(String)
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
      def self.merge(element_list, element_decl_list)
         decl_table = {}
         element_decl_list.each do |decl|
            decl_table[decl.name] = decl
         end if element_decl_list
         element_table = {}
         element_list.each do |elem|
            decl = decl_table[elem.name]
            elem.swallow(decl) if decl
            element_table[elem.name] = elem
         end if element_list
         return element_table
      end
      
   end

   class ElementDeclaration
      def initialize(name, value=nil, attrs={}, append=[], remove=[], tagname=nil, plogic=nil)
         @name    = name
         @value   = value
         @attrs   = attrs
         @append  = append
         @remove  = remove
         @tagname = tagname
         @plogic  = plogic
      end

      attr_reader :name, :value, :attrs, :append, :remove, :tagname, :plogic
      alias :marking :name
   
      def self.create_from_hash(name, hash)
         name    = name
         value   = hash[:value]
         attrs   = hash[:attr] || hash[:attrs] || {}
         append  = hash[:append] || []
         remove  = hash[:remove] || []
         tagname = hash[:tagname]
         plogic  = hash[:plogic]
         return self.new(name, value, attrs, append, remove, tagname, plogic)
      end

      def _inspect()
         s = "\##{@name} {\n"
         s <<    "  value:\n" << @value._inspect(2) if @value
         if @attrs && !@attrs.empty?
            s << "  attrs:\n"
            @attrs.keys.sort.each do |key|
               s << "    \"#{key}\" " << @attrs[key]._inspect()
            end
         end
         #s << "  attrs:\n    "  << @attrs.keys.sort.collect { |key| "\"#{key}\" " + @attrs[key]._inspect() }.join("    ") if @attrs && !@attrs.empty?
         if @append
            s << "  append:\n"
            @append.each do |expr|
               s << expr._inspect(2)
            end
         end
         s << "  remove:\n    " << @remove.sort.collect{|aname| '"'+aname+'"'}.join(",") << "\n" if @remove && !@remove.empty?
         s << "  tagname:\n" << @tagname._inspect(2) if @tagname
         s << "  plogic:\n" << @plogic._inspect(2)  if @plogic
         s << "}\n"
         return s
      end
      
   end

end
