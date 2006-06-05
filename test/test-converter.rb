###
### $Rev$
### $Release$
### $Copyright$
###

require "#{File.dirname(__FILE__)}/test.rb"


class ConverterTest < Test::Unit::TestCase


  ## define test methods
  filename = __FILE__.sub(/\.rb$/, '.yaml')
  #load_yaml_testdata(filename)
  load_yaml_testdata_with_each_lang(filename, :langs=>%w[eruby php])


  def _test
    #parser = Kwartz::PresentationLogicParser.get_class('css').new
    #ruleset_list = parser.parse(@plogic)
    ruleset_list = []
    (@properties ||= {}).each do |key, val|
      if key.is_a?(String)
        key = key.intern
        @properties.delete(key)
        @properties[key] = val
      end
    end
    handler = Kwartz::Handler.get_class(@lang).new(ruleset_list, @properties)
    converter = Kwartz::TextConverter.new(handler, @properties)
    stmt_list = converter.convert(@pdata)
    sb = ''
    stmt_list.each do |stmt|
      sb << (s = stmt._inspect)
      sb << "\n" unless s[-1] == ?\n
    end
    assert_text_equal(@expected, sb)
  end


end
