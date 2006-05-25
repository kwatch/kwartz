###
### $Rev$
### $Release$
### $Copyright$
###

require "#{File.dirname(__FILE__)}/test.rb"


class ConverterTest < Test::Unit::TestCase


  ## define test methods
  filename = __FILE__.sub(/\.rb$/, '.yaml')
  load_yaml_testdata(filename)


  def _test
    parser = Kwartz::PresentationLogicParser.get_class('css').new
    ruleset_list = parser.parse(@plogic)
    #handler = Kwartz::Handler.new(ruleset_list)
    handler = Kwartz::ErubyHandler.new(ruleset_list, :delspan=>true)
    converter = Kwartz::TextConverter.new(handler, :delspan=>true)
    stmt_list = converter.convert(@pdata)
    sb = ''
    stmt_list.each do |stmt|
      sb << (s = stmt._inspect)
      sb << "\n" unless s[-1] == ?\n
    end
    assert_text_equal(@expected, sb)
  end


end
