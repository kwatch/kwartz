###
### $Rev$
### $Release$
### $Copyright$
###

module Kwartz


  class KwartzError < StandardError
    def initialize(message)
      super(message)
    end
  end


  class BaseError < KwartzError

    def initialize(message, linenum, column)
      super(message)
      @linenum = linenum
      @column = column
    end
    
    attr_accessor :linenum, :column

    def to_s
      return super unless @linenum
      return "line #{@linenum}, column #{@column}: " + super
    end

  end

  
end
