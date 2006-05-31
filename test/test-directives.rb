###
### $Rev$
### $Release$
### $Copyright$
###

require "#{File.dirname(__FILE__)}/test.rb"


class DirectivesTest < Test::Unit::TestCase

  ## define test methods
  filename = __FILE__.sub(/\.rb$/, '.yaml')
  load_yaml_testdata_with_each_lang(filename, :langs=>%w[eruby php jstl eperl])


  def _test
    #$stderr.puts "*** debug: _test(): @lang=#{@lang.inspect}, @name=#{@name}"  if $DEBUG
    regexp = /(\{\{\*|\*\}\})/
    @pdata.gsub!(regexp, '')
    @expected.gsub!(regexp, '')  if @expected
    #
    handler = Kwartz::Handler.get_class(@lang).new()
    converter = Kwartz::TextConverter.new(handler)
    stmt_list = converter.convert(@pdata)
    translator = Kwartz::Translator.get_class(@lang).new(:header=>'')
    actual = translator.translate(stmt_list)
    assert_text_equal(@expected, actual)
  end


end
