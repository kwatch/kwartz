require 'kwartz/exception'

module Kwartz

   ###
   ### dump string
   ###
   def self.dump_str(str)
      str = str.dup
      str.gsub!(/\\/, '\\\\')
      str.gsub!(/"/, '\\"')	#'
      str.gsub!(/\n/, '\\n')
      str.gsub!(/\r/, '\\r')
      str.gsub!(/\t/, '\\t')
      return "\"#{str}\""
   end


   ##
   ## exception class for assertion
   ##
   class AssertionError < KwartzError
   end

   
   ##
   ## assertion
   ##
   def self.assert(condition, message=nil)
      unless condition
	 throw AssertionError.new(message)
      end
   end

end  # end of module Kwartz
