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
  load_yaml_testdata(filename)


  def _test
    parser = Kwartz::PresentationLogicParser.get_class('css').new
    ruleset_list = parser.parse(@plogic)
    #handler = Kwartz::Handler.new(ruleset_list)
    handler = Kwartz::ErubyHandler.new(ruleset_list, :delspan=>true)
    converter = Kwartz::TextConverter.new(handler, :delspan=>true)
    stmt_list = converter.convert(@pdata)
    sb = []
    stmt_list.each do |stmt|
      sb << stmt._inspect
    end
    assert_text_equal(@expected, sb.join)
  end


end
