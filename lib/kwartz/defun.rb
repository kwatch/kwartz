###
### copyright(c) 2005 kuwata-lab all rights reserved
###
### $Id$
### $Release$
###

module Kwartz

   ## abstract class
   ##
   ## ex.
   ##  defun = Kwartz::Defun.create('eruby')
   ##  context = {
   ##     :filename  => 'file.html',
   ##     :class     => nil,
   ##     :function  => nil,
   ##     :arguments => nil,
   ##     :lang      => nil,
   ##  }
   ##  defun.generate(source, context)
   ##
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

      def class_name(filename='')
         return _name(filename, Kwartz::Config::DEFUN_CLASS)
      end
      protected :class_name

      def function_name(filename='')
         return _name(filename, Kwartz::Config::DEFUN_FUNCTION)
      end
      protected :function_name

      def _name(filename, format)
         return nil unless format
         base = File.basename(filename).sub(/\.\w+$/, '').gsub(/[^\w]/, '_')
         return format % base
      end
      private :_name

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
         klass      = context[:class]    || class_name(context[:filename])
         function   = context[:function] || function_name(context[:filename])
         arguments  = context[:arguments]
         lang       = context[:lang]
         prefix = klass ? "self." : ""
         spc = klass ? '' : '  '
         nl = (body =~ /(.?)\n/ && $1 == "\r") ? "\r\n" : "\n"
         s = ''
         s << "#{spc}require 'erb'" << nl       if lang == 'erb'
         s << "module #{klass}" << nl           if klass
         s << "  include ERB::Util" << nl       if lang == 'erb' && klass
         s << "  def #{prefix}#{function}(__args)" << nl
         arguments.split(',').each do |arg|
            s << "    #{arg} = __args[:#{arg}]" << nl
         end if arguments
         s << "    return _#{function}(#{arguments})" << nl
         s << "  end" << nl
         s << "  def #{prefix}_#{function}(#{arguments})" << nl
         s << body.gsub(/^/, '    ')
         s << nl unless body[-1] == ?\n
         s << "  end" << nl
         s << "end" << nl                       if klass
         return s
      end

   end


   class PhpDefun < Defun

      Defun.register('php', self)

      def initialize(properties={})
         super(properties)
      end

      def generate(body, context)
         klass     = context[:class]    || class_name(context[:filename])
         function  = context[:function] || function_name(context[:filename])
         arguments = context[:arguments]

         nl = (body =~ /(.?)\n/ && $1 == "\r") ? "\r\n" : "\n"
         s = "<?php" << nl
         s <<    "class #{klass}" << nl if klass
         s <<    "    function #{function}($__args) {" << nl
         arguments.split(',').each do |arg|
            s << "        $#{arg} = $__args['#{arg}']" << nl
         end if arguments
         s <<    "        return _#{function}(#{arguments})" << nl
         s <<    "    }" << nl
         s <<    "    function _#{function}(#{arguments}) {" << nl
         s <<    "        ob_start();" << nl
         s <<    "?>" << body
         s <<    "<?php" << nl
         s <<    "        $__s = ob_get_contents();" << nl
         s <<    "        ob_end_clean();" << nl
         s <<    "        return $__s;" << nl
         s <<    "    }" << nl
         s <<    "}" << nl if klass
         s <<    "?>"
         return s
      end

   end

end
