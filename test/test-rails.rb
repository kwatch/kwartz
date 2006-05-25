###
### $Rev$
### $Release$
### $Copyright$
###

require "#{File.dirname(__FILE__)}/test.rb"


class RailsTest < Test::Unit::TestCase


  ## define test methods
  filename = __FILE__.sub(/\.rb$/, '.yaml')
  load_yaml_testdata(filename)


  def _test
    handler    = Kwartz::Handler.get_class(@binding).new
    converter  = Kwartz::TextConverter.new(handler)
    stmt_list  = converter.convert(@pdata)
    translator = Kwartz::Translator.get_class(@binding).new
    actual = translator.translate(stmt_list)
    assert_text_equal(@expected, actual)
  end


end
