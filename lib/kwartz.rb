###
### $Rev$
### $Release$
### $Copyright$
###


module Kwartz

  RELEASE = ('$Release: 0.0.0-beta $' =~ /\$Release: (\S+)\s*\$/) && $1

end

require 'kwartz/config'
require 'kwartz/error'
require 'kwartz/assert'
require 'kwartz/node'
require 'kwartz/parser'
require 'kwartz/converter'
require 'kwartz/translator'
require 'kwartz/defun'
