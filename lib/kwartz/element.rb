###
### element.rb
###
### $Id$
###

module Kwartz

   class Element
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
