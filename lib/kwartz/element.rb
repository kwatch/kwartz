###
### element.rb
###
### $Id$
###

module Kwartz

   class Element
      def initialize(marking, tagname, content_stmt, attrs={}, append_expr=nil, is_empty=false, spaces=['','','',''])
         @marking  = marking
         @tagname  = tagname
         @content  = content_stmt
         @attrs    = attrs
         @append   = append_expr
         @is_empty = is_empty
         @spaces   = spaces
         list = [ ExpandStatement.new(:stag), ExpandStatement.new(:cont), ExpandStatement.new(:etag) ]
         @plogic   = BlockStatement.new(list)
      end
      attr_accessor :marking, :tagname, :content, :attrs, :append, :is_empty, :spaces, :plogic
      
      def self.create_from_taginfo(marking, staginfo, etaginfo, body_stmt_list)
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
         return Element.new(marking, tagname, content, attrs, append_expr, is_empty, spaces)
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
         s << "===== marking=#{@marking} =====\n"
         s << "[tagname]\n#{@tagname}#{@is_empty ? '/':''}\n"
         s << "[attrs]\n"
         @attrs.each do |key,val|
            s << "#{key}=" << (val.is_a?(Expression) ? val._inspect : '"'+val.to_s+'"') << "\n"
         end
         s << "[append]\n"  << @append._inspect        if @append
         s << "[content]\n" << @content._inspect       if @content
         s << "[spaces]\n"  << @spaces.inspect << "\n" if @spaces
         s << "[plogic]\n"  << @plogic._inspect        if @plogic
         return s
      end
      
   end

   class ElementDeclaration
      def initialize(name, hash)
         @name = name
         @hash = hash
         @value   = hash[:value]
         @attr    = hash[:attr] || {}
         @append  = hash[:append]
         @remove  = hash[:remove] || []
         @tagname = hash[:tagname]
         @plogic  = hash[:plogic]
      end
      attr_reader :name, :value, :attr, :append, :remove, :tagname, :plogic
   
      def merge(element)
         Kwartz::assert(@name == element.name)
         @value   = element.value       if element.value
         @attr.update(element.attr)     if element.attr
         @append  = element.append      if element.append
         @remove.concat(element.remove) if element.remove
         @tagname = element.tagname     if element.tagname
         @plogic  = element.plogic      if element.plogic
         return self
      end
      
      def _inspect()
         s = "\##{@name} {\n"
         s << "  value:\n" << @value._inspect(2) if @value
         s << "  attr:\n    "  << @attr.keys.sort.collect { |key| "\"#{key}\" " + @attr[key]._inspect() }.join("    ") if @attr && !@attr.empty?
         s << "  append:\n" << @append._inspect(2) if @append
         s << "  remove:\n    " << @remove.sort.collect{|aname| '"'+aname+'"'}.join(",") << "\n" if @remove && !@remove.empty?
         s << "  tagname:\n" << @tagname._inspect(2) if @tagname
         s << "  plogic:\n" << @plogic._inspect(2)  if @plogic
         s << "}\n"
         return s
      end
      
   end

end
