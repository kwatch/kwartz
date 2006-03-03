####
#### $Rev$
#### $Release$
#### $Copyright$
####


require 'kwartz/error'


module Kwartz


  class AssertionError < KwartzError
    def initialize(message)
      super(message)
    end
  end
  

  module Assertion
    
    def assert(message="")
      raise AssertionError.new("*** assertion failed: #{message}")
    end

    module_function :assert
  end


end
