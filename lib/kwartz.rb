###
### kwartz.rb
###
### $Id$
### $Release$
###

module Kwartz
   VERSION   = ('$Rev: 42$' =~ /\d+(?:\.\d+)*/ && $&)
   RELEASE   = ('$Release: 2.0.0-pre1$' =~ /Release: (.*)\$/ && $1)
end

require 'kwartz/config'
require 'kwartz/exception'
require 'kwartz/parser'
require 'kwartz/converter'
require 'kwartz/expander'
require 'kwartz/translator'
#require 'kwartz/translator/eruby'
#require 'kwartz/translator/php'
#require 'kwartz/translator/jstl'
require 'kwartz/compiler'
require 'kwartz/analyzer'
