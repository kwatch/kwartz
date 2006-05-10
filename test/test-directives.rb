###
### $Rev$
### $Release$
### $Copyright$
###

unless defined?(TESTDIR)
  TESTDIR = File.dirname(File.expand_path(__FILE__))
  basedir = File.dirname(TESTDIR)
  libdir  = basedir + "/lib"
  $LOAD_PATH << libdir << TESTDIR
end

require 'test/unit'
require 'yaml'
require 'kwartz'
require 'kwartz/main'
require 'assert-text-equal'
require 'testutil'



class DirectivesTest < Test::Unit::TestCase


  ## define test methods
  filename = __FILE__.sub(/\.rb$/, '.yaml')
  #filename = 'test-directives.yaml'
  load_yaml_documents(filename) do |ydoc|
    name = ydoc['name']
    langs = defined?($lang) && $lang ? [$lang] : ydoc['pdata*'].keys
    langs.each do |lang|
      #$stderr.puts "*** debug: lang=#{lang.inspect}, name=#{name.inspect}" if $DEBUG
      eval <<-END
        def test_#{name}_#{lang}
          @name = #{name.inspect}
          @lang = #{lang.inspect}
          @pdata = #{ydoc['pdata*'][lang].inspect}
          @expected = #{ydoc['expected*'][lang].inspect}
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
