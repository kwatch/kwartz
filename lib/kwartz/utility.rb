###
### copyright(c) 2005 kuwata-lab all rights reserved
###
### $Id$
###

require 'kwartz/exception'

module Kwartz

   module Util

      ## dump string
      def self.dump_str(str)
         str = str.dup
         str.gsub!(/\\/, '\\\\\\\\')		# wow!
         str.gsub!(/"/, '\\"')	#'
         str.gsub!(/\n/, '\\n')
         str.gsub!(/\r/, '\\r')
         str.gsub!(/\t/, '\\t')
         #str.gsub!(/\#/, '\\#')
         return "\"#{str}\""
      end

      ## quote string
      def self.quote_str(str)
         str = str.dup
         str.gsub!(/\\/, '\\\\\\\\')		# wow!
         str.gsub!(/'/, "\\\\\'")	#"
         return "'#{str}'"
      end

   end

end
