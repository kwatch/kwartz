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




class CompileTest < Test::Unit::TestCase


  ## define test methods
  filename = __FILE__.sub(/\.rb$/, '.yaml')
  load_yaml_documents(filename) do |ydoc|
    name = ydoc['name']
    desc = ydoc['desc']
    lang_list = defined?($lang) && $lang ? [ $lang ] : %w[erb php eperl]
    lang_list.each do |lang|
      pdata    = ydoc['pdata*'][lang]
      plogic   = ydoc['plogic*'][lang]
      expected = ydoc['expected*'][lang]
      #next unless pdata
      eval <<-END
        def test_#{lang}_#{name}
          @name = #{name.inspect}
          @lang = #{lang.inspect}
          @desc = #{desc.inspect}
          @pdata = #{pdata.inspect}
          @plogic = #{plogic.inspect}
          @expected = #{expected.inspect}
          _test()
        end
      END
    end
  end


  def _test
    parser = Kwartz::Main.get_parser_class('css').new
    ruleset_list = parser.parse(@plogic)
    handler = Kwartz::Main.get_handler_class(@lang).new(ruleset_list)
    converter = Kwartz::TextConverter.new(handler)
    stmt_list = converter.convert(@pdata)
    translator = Kwartz::Main.get_translator_class(@lang).new
    actual = translator.translate(stmt_list)
    assert_text_equal(@expected, actual)
  end


end
