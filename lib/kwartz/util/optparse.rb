###
### copyright(c) 2005 kuwata-lab all rights reserved
###
### $Id$
###

require 'kwartz/exception'

module Kwartz

   module Util

      class OptparseError < KwartzError
         def initialize(message, type, key, arg=nil)
            super(message)
            @type = type
            @key  = key
            @arg  = arg
         end
         attr_reader :type, :key, :arg
         alias :optchar :key
         alias :propstr :key
      end

      ##
      ## ex.
      ##  require 'kwartz/util/optparse'
      ##  begin
      ##    options, properties = Kwartz::Util::optparse(ARGV, "hv", "f", "N", true)
      ##  rescue Kwartz::Util::OptoparseError => ex
      ##    type = ex.type    # kind of error
      ##    key  = ex.key     # option character or property string
      ##    arg  = ex.arg     # argument
      ##    ...
      ##  end
      ##  puts "'-h' specified."                if options[?h]
      ##  puts "'-v' specified."                if options[?v]
      ##  puts "'-f #{options[?f]}' specified." if options[?f]
      ##  if options[?N]
      ##    if options[?N] == true
      ##      puts "'-N' specified with no args."
      ##    else
      ##      puts "'-N #{options[?N]' specified."
      ##  end
      ##
      ## argv::      ARGV
      ## noargs::    command-line options which doesn't take any arguments.
      ## requires::  command-line options which takes arguments.
      ## optionals:: command-line options which can take an argument which is not required.
      ## flag_str2value:: specify whether string is converted into appropriate value (ex. "1"=>1, "yes"=>true, ...)
      ##
      def self.optparse(argv, noargs='', requires='', optionals='', flag_str2value=false)
         noargs    = '' if !noargs
         requires  = '' if !requires
         optionals = '' if !optionals
         options    = {}
         properties = {}
         
         while !argv.empty? && argv[0][0] == ?-
            opt = argv.shift
            if opt[1] == ?-			## properteis
               propstr = opt.sub(/^--/, '')
               unless propstr =~ /^([-\w]+)(?:=(.*))?$/
                  raise Kwartz::Util::OptparseError.new("invalid property.", :invalid_property, propstr)
               end
               name  = $1
               value = $2
               name.gsub!(/-/, '_')
               if !value || value.empty?
                  value = true
               elsif flag_str2value
                  value = self.str2value(value)
               end
               if name == 'help'
                  options[?h] = value
               else
                  properties[name.intern] = value
               end

            else				## options
               optstr = opt.sub(/^-/, '')
               while optstr && !optstr.empty?
                  optchar = optstr[0]
                  optstr = optstr[1, optstr.length-1]
                  if noargs.include?(optchar)
                     options[optchar] = true
                  elsif requires.include?(optchar)
                     arg = optstr && !optstr.empty? ? optstr : argv.shift
                     unless arg && !arg.empty?
                        raise Kwartz::Util::OptparseError.new("argument required.", :argument_required, optchar, arg)
                     end
                     options[optchar] = arg
                  elsif optionals.include?(optchar)
                     arg = optstr && !optstr.empty? ? optstr : true
                     options[optchar] = arg
                  else
                     raise Kwartz::Util::OptparseError.new("invalid option.", :invalid_option, optchar)
                  end
               end

            end   # if
         end   # while

         return options, properties
      end


      def self.str2value(str)
         case str
         when 'true', 'yes'
            return true
         when 'false', 'no'
            return false
         when 'null', 'nil'
            return nil
         when /^\d+$/
            return str.to_i
         when /^\d+\.\d+$/
            return str.to_f
         when /^\/.*\/$/
            return eval(str)
         when /^'.*'$/, /^".*"$/
            return eval(str)
         else
            return str
         end
      end

   end

end
