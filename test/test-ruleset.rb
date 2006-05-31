###
### $Rev$
### $Release$
### $Copyright$
###


require "#{File.dirname(__FILE__)}/test.rb"


class RulesetTest < Test::Unit::TestCase


  ## define test methods
  filename = __FILE__.sub(/\.rb$/, '.yaml')
  load_yaml_testdata_with_each_lang(filename, :langs=>%w[eruby php jstl eperl])


  def _test
    regexp = /(\{\{\*|\*\}\})/
    @pdata.gsub!(regexp, '')    if @pdata
    @plogic.gsub!(regexp, '')   if @plogic
    @expected.gsub!(regexp, '') if @expected
    #
    parser = Kwartz::PresentationLogicParser.get_class('css').new
    ruleset_list = parser.parse(@plogic)
    handler = Kwartz::Handler.get_class(@lang).new(ruleset_list)
    converter = Kwartz::TextConverter.new(handler)
    stmt_list = converter.convert(@pdata)
    translator = Kwartz::Translator.get_class(@lang).new
    actual = translator.translate(stmt_list)
    assert_text_equal(@expected, actual)
  end


end
