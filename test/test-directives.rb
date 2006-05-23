###
### $Rev$
### $Release$
### $Copyright$
###

require "#{File.dirname(__FILE__)}/test.rb"


class DirectivesTest < Test::Unit::TestCase

  ## define test methods
  filename = __FILE__.sub(/\.rb$/, '.yaml')
  #filename = 'test-directives.yaml'
  load_yaml_documents(filename) do |ydoc|
    name = ydoc['name']
    langs = defined?($lang) && $lang ? [$lang] : ydoc['pdata*'].keys
    langs.each do |lang|
      #$stderr.puts "*** debug: lang=#{lang.inspect}, name=#{name.inspect}" if $DEBUG
      pdata = ydoc['pdata*'][lang].gsub(/(\{\{\*|\*\}\})/, '')
      expected = ydoc['expected*'][lang].gsub(/(\{\{\*|\*\}\})/, '')
      eval <<-END
        def test_#{name}_#{lang}
          @name = #{name.inspect}
          @lang = #{lang.inspect}
          @pdata = #{pdata.inspect}
          @expected = #{expected.inspect}
          _test()
        end
      END
    end
  end


  def _test
    #$stderr.puts "*** debug: _test(): @lang=#{@lang.inspect}, @name=#{@name}"  if $DEBUG
    handler = Kwartz::Handler.get_class(@lang).new()
    converter = Kwartz::TextConverter.new(handler)
    stmt_list = converter.convert(@pdata)
    translator = Kwartz::Translator.get_class(@lang).new(:header=>'')
    actual = translator.translate(stmt_list)
    assert_text_equal(@expected, actual)
  end


end
