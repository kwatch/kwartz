###
### copyright(c) 2005 kuwata-lab all rights reserved
###
### $Id$
###

module Kwartz

   ##
   ## abstract root error class
   ##
   class KwartzError < StandardError
      def initialize(message)
         super(message)
      end
      def initialize(message)
         super(message)
      end
   end
   
   class NotImplementedError < KwartzError
      def initialize(message="not implemented yet.")
         super(message)
      end
   end

   ##
   ## base error class for ParseError, ConvertionError, etc...
   ##
   class BaseError < KwartzError
       def initialize(errmsg, linenum=nil, filename=nil)
	   s =''
	   s << filename if filename
	   s << "(line #{linenum})" if linenum
	   s << ": " if !s.empty?
	   s << errmsg
	   super(s)
	   
	   @errmsg = errmsg
	   @linenum = linenum
	   @filename = filename
       end
       
       attr_reader :errmsg, :linenum, :filename
       
   end


   ## exception class for assertion
   class AssertionError < KwartzError
      def initialize(msg)
         super(msg)
      end
   end
   
   ## assertion
   def self.assert(message='')
      raise AssertionError.new(message)
   end

end
