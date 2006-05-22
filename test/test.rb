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
  #require 'test-directives'
  #require 'test-handlers'
  #require 'test-parser'

  #suite = Test::Unit::TestSuite.new()
  #suite << CompileTest.suite()
  #suite << DirectivesTest.suite()
  #suite << ParserTest.suite()
  #require 'test/unit/ui/console/testrunner'
  #Test::Unit::UI::Console::TestRunner.run(suite)

end
