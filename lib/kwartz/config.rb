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
      LOCALVAR_PREFIX = nil		# or set '_'
      GLOBALVAR_PREFIX = nil		# set '@' if you are Rails user

      ## compiler
      LANG            = "eruby"

      ## converter
      ODD             = "'odd'"
      EVEN            = "'even'"
      DATTR           = "kw:d"
      INCDIRS         = [ '.' ]		# directories from which 'include' directive includes
      EMBED_PATTERN   = /@\{(.*?)\}@/	# or /\#\{(.*?)\}\#/

      ## converter & element
      NOEND           = [ "input", "br", "meta", "img", "hr" , "link" ]

      ## defun
      DEFUN_CLASS     = nil		#
      DEFUN_FUNCTION  = 'view_%s'       # or 'expand_%s' for compatible

      ## kwartz command
      CHARSET         = nil		# ex. UTF-8, EUC-JP
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

   end
end
