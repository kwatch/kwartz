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
  $script  = basedir + "/bin/kwartz"
end

require 'test/unit'
require 'yaml'
require 'kwartz'
require 'kwartz/main'
require 'assert-text-equal'
require 'testutil'



class HandlerTest < Test::Unit::TestCase


  ## define test methods
  filename = __FILE__.sub(/\.rb$/, '.yaml')
  load_yaml_testdata(filename)


  def _test
    handler    = Kwartz::Main.get_handler_class(@binding).new
    converter  = Kwartz::TextConverter.new(handler)
    stmt_list  = converter.convert(@pdata)
    translator = Kwartz::Main.get_translator_class(@binding).new
    actual = translator.translate(stmt_list)
    assert_text_equal(@expected, actual)
  end


end
