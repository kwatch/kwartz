###
### copyright(c) 2005 kuwata-lab all rights reserved
###
### $Id$
### $Release$
###

module Kwartz
   module Config
      
      ## translator
      ESCAPE          = false
      NEWLINE         = "\n"
      INDENT          = "  "
      RENAME          = false        # rename local var or not
      RENAME_PREFIX   = '_'          # ex. var => _var
      
      ## compiler
      LANG            = "eruby"
      
      ## converter
      ODD             = "'odd'"
      EVEN            = "'even'"
      DATTR           = "kw:d"
      EMBED_PATTERN   = /@\{(.*?)\}@/  # or /\#\{(.*?)\}\#/
      
      ## converter & element
      NOEND           = [ "input", "br", "meta", "img", "hr" , "link" ]
      
      ## kwartz command
      HEADER_JSTL11   = <<END
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
END
      HEADER_JSTL10   = <<END
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
END
      HEADER_JSP_CHARSET = <<END
<%@ page contentType="text/html; charset=__CHARSET__" %>
END
      CHARSET         = nil		# ex. UTF-8, EUC-JP

   end
end
