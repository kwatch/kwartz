###
### copyright(c) 2005 kuwata-lab all rights reserved
###
### $Id$
### $Release$
###

module Kwartz

   ## abstract class
   class Defun
      def initialize(properties={})
         @properties = properties
      end
   
      ## abstract method
      def generate(body, context)
         raise NotImplementedError.new("#{self.class.name}#generate() is not implemented.")
      end
      
      def self.register(lang, klass)
         @@classes ||= {}
         @@classes[lang] = klass
      end

      def self.create(lang, properties={})
         klass = @@classes[lang]
         return klass.new(properties)
      end
      
      def function_name(filename='')
         base = File.basename(filename).sub(/\.\w+$/, '').gsub(/[^\w]/, '_')
         function = Kwartz::Config::DEFUN_FORMAT % base
         return function
      end
      protected :function_name

   end

   require 'erb'
   class ErubyDefun < Defun
   
      Defun.register('eruby', self)
      Defun.register('erb', self)
      
      def initialize(properties={})
         super(properties)
      end
      
      def generate(body, context)
         trim_mode = 2
         erb = ERB.new(body, $SAFE, trim_mode)
         body = erb.src
         body.gsub!(/_erbout.concat/, '_erbout <<')
         #body.sub!(/^_erbout = ''/, "_s = ''")
         #body.sub!(/_erbout\z/, "return _s")
         #body.gsub!(/_erbout.concat/, '_s <<')
         function = context[:function]
         function ||= function_name(context[:filename])
         prefix = context[:class] ? "self." : ""
         spc = context[:class] ? '' : '  '
         nl = (body =~ /(.?)\n/ && $1 == "\r") ? "\r\n" : "\n"
         s = ''
         s << "#{spc}require 'erb'" << nl       if context[:lang] == 'erb'
         s << "module #{context[:class]}" << nl if context[:class]
         s << "  include ERB::Util" << nl       if context[:lang] == 'erb' && context[:class]
         s << "  def #{prefix}#{function}(__args)" << nl
         context[:arguments].split(',').each do |arg|
            s << "    #{arg} = __args[:#{arg}]" << nl
         end if context[:arguments]
         s << "    return _#{function}(#{context[:arguments]})" << nl
         s << "  end" << nl
         s << "  def _#{function}(#{context[:arguments]})" << nl
         s << body.gsub(/^/, '    ')
         s << nl unless body[-1] == ?\n
         s << "  end" << nl
         s << "end" << nl                       if context[:class]
         return s
      end

   end


   class PhpDefun < Defun
      
      Defun.register('php', self)
      
      def initialize(properties={})
         super(properties)
      end
      
      def generate(body, context)
         function = context[:function]
         function ||= function_name(context[:filename])
         nl = (body =~ /(.?)\n/ && $1 == "\r") ? "\r\n" : "\n"
         s = "<?php" << nl
         s << "class #{context[:class]}" << nl if context[:class]
         s << "    function #{function}($__args) {" << nl
         context[:arguments].split(',').each do |arg|
            s << "    $#{arg} = $__args['#{arg}']" << nl
         end if context[:arguments]
         s << "        return _#{function}(#{context[:arguments]})" << nl
         s << "    }" << nl
         s << "    function _#{function}(#{context[:arguments]}) {" << nl
         s << "        ob_start();" << nl
         s << "?>" << body 
         s << "<?php" << nl
         s << "        $__s = ob_get_contents();" << nl
         s << "        ob_end_clean();" << nl
         s << "        return $__s;" << nl
         s << "    }" << nl
         s << "}" << nl if context[:class]
         s << "?>"
         return s
      end
      
   end
   
end
