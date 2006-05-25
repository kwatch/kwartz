###
### $Rev$
### $Release$
### $Copyright$
###

unless defined?(TESTDIR)
  TESTDIR = File.dirname(File.expand_path(__FILE__))
  BASEDIR = File.dirname(TESTDIR)
  LIBDIR  = BASEDIR + "/lib"
  $LOAD_PATH << LIBDIR << TESTDIR
end

require 'test/unit'
require 'yaml'
require 'assert-text-equal'
require 'testutil'
require 'kwartz'
require 'kwartz/main'


if $0 == __FILE__

  #require 'test-compile'
  #require 'test-ruleset'
  #require 'test-converter'
  #require 'test-directives'
  #require 'test-rails'
  #require 'test-parser'
  #require 'test-main'
  #
  #suite = Test::Unit::TestSuite.new()
  #suite << CompileTest.suite()
  #suite << RulesetTest.suite()
  #suite << ConverterTest.suite()
  #suite << DirectivesTest.suite()
  #suite << RailsTest.suite()
  #suite << ParserTest.suite()
  #suite << MainTest.suite()
  #
  #require 'test/unit/ui/console/testrunner'
  #Test::Unit::UI::Console::TestRunner.run(suite)

end
