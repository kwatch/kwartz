###
### element.rb
###
### $Id$
###

module Kwartz

   class Element
      def initialize(name, tagname, content_stmt, attrs={}, append_expr=[], is_empty=false, spaces=['','','',''])
         @name     = name
         @tagname  = tagname
         @content  = content_stmt
         @attrs    = attrs
         @append   = append_expr
         @is_empty = is_empty
         @spaces   = spaces
         list = [ ExpandStatement.new(:stag), ExpandStatement.new(:cont), ExpandStatement.new(:etag) ]
         @plogic   = BlockStatement.new(list)
      end
      attr_accessor :name, :tagname, :content, :attrs, :append, :is_empty, :spaces, :plogic
      alias :marking :name

      def swallow(elem_decl)
         return unless @name == elem_decl.name
         @tagname = elem_decl.tagname if elem_decl.tagname
         @content = elem_decl.value if elem_decl.value
         elem_decl.attrs.each do |key,val|
            @attrs[key] = val
         end if elem_decl.attrs
         @append.concat(elem_decl.append) if elem_decl.append
         @plogic = elem_decl.plogic if elem_decl.plogic
      end
      
      def self.create_from_taginfo(name, staginfo, etaginfo, body_stmt_list)
         Kwartz::assert(staginfo[:tagname] == etaginfo[:tagname]) if etaginfo
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
         return Element.new(name, tagname, content, attrs, append_expr, is_empty, spaces)
      end
      
      def stag_stmt(properties={})
         arglist = []
         if @tagname.is_a?(String)
            arglist << StringExpression.new("#{@spaces[0]}<#{@tagname}")
         elsif @tagname.is_a?(Expression)
            arglist << StringExpression.new("#{@spaces[0]}<")
            arglist << @tagname
         else
            Kwartz::assert(false)
         end
         @attrs.each do |aname, avalue|
            if avalue.is_a?(String)
               arglist << StringExpression.new(" #{aname}=\"#{avalue}\"")
            elsif avalue.is_a?(Expression)
               arglist << StringExpression.new(" #{aname}=\"")
               arglist << avalue
               arglist << StringExpression.new("\"")
            else
               Kwartz::assert(false)
            end
         end
         s = (@is_empty && properties[:html] != true) ? ' /' : ''
         arglist << StringExpression.new("#{s}>#{spaces[1]}")
         arglist << @append if @append
         return PrintStatement.new(arglist)
      end
      
      def cont_stmt(properties={})
         Kwartz::assert(! (@is_empty && @content))
         return @content
      end
         
      def etag_stmt(properties={})
         return nil if @is_empty
         arglist = []
         if @tagname.is_a?(String)
            arglist << StringExpression.new("#{@spaces[3]}</#{@tagname}")
         elsif @tagname.is_a?(Expression)
            arglist << StringExpression.new("#{@spaces[3]}</")
            arglist << @tagname
            arglist << StringExpression.new(">#{@space[4]}")
         else
            Kwartz::assert(false)
         end
         return PrintStatement.new(arglist)
      end
      
      def _inspect()
         s = ''
         s << "===== marking=#{@name} =====\n"
         s << "[tagname]\n#{@tagname}#{@is_empty ? '/':''}\n"
         s << "[attrs]\n"
         @attrs.each do |key,val|
            s << "#{key}=" << (val.is_a?(Expression) ? val._inspect : '"'+val.to_s+"\"\n")
         end
         s << "[append]\n"
         @append.each do |expr|
            s << expr._inspect
         end if @append
         s << "[content]\n" << @content._inspect       if @content
         s << "[spaces]\n"  << @spaces.inspect << "\n" if @spaces
         s << "[plogic]\n"  << @plogic._inspect        if @plogic
         return s
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


