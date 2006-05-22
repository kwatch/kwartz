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

    def initialize(message, filename, linenum, column=nil)
      super(message)
      @filename = filename || '-'
      @linenum = linenum
      @column = column
    end

    attr_accessor :filename, :linenum, :column

    def to_s
      return super unless @linenum
      #return "line #{@linenum}, column #{@column}: " + super
      if @column
        return "#{@filename}:#{@linenum}:#{@column}: " + super
      else
        return "#{@filename}:#{@linenum}: " + super
      end
    end

  end


end
