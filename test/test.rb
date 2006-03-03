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
