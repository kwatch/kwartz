#!/usr/bin/ruby

###
### unit test for examples/
###
### $Id$
###

$: << 'lib'
$: << '../lib'
$: << 'test'

require 'test/unit'
require 'test/unit/ui/console/testrunner'

require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'assert-diff.rb'


class ExamplesTest < Test::Unit::TestCase

   def _test(path, filename)
      expected_filename = "#{path}/.expected/#{filename}"
      actual_filename   = "#{path}/#{filename}"
      expected = File.open(expected_filename) { |f| f.read() }
      actual   = File.open(actual_filename)   { |f| f.read() }
      assert_equal_with_diff(expected, actual)
   end


   if test(?d, './examples')
      @@basedir = './examples'
   elsif test(?d, '../examples')
      @@basedir = '../examples'
   else
      raise "directory 'examples' not found."
   end


   ## ---------------------------------------- test method


   def test_example_border1
      path = "#{@@basedir}/border1"
      `cd #{path}; make; make _test`
      _test(path, 'result.html')
      _test(path, 'border1.view')
      _test(path, 'border1.php')
      _test(path, 'border1.jstl11')
      _test(path, 'border1.jstl10')
      _test(path, 'border1.velocity')
      `cd #{path}; make clean; make _clean`
   end


   def test_example_border2
      path = "#{@@basedir}/border2"
      `cd #{path}; make; make _test`
      _test(path, 'result.html')
      _test(path, 'border2.view')
      _test(path, 'border2.php')
      _test(path, 'border2.jstl11')
      _test(path, 'border2.jstl10')
      _test(path, 'border2.velocity')
      `cd #{path}; make clean; make _clean`
   end


   def test_example_border3
      path = "#{@@basedir}/border3"
      `cd #{path}; make; make _test`
      _test(path, 'result.html')
      _test(path, 'border3.view')
      _test(path, 'border3.php')
      _test(path, 'border3.jstl11')
      _test(path, 'border3.jstl10')
      _test(path, 'border3.velocity')
      `cd #{path}; make clean; make _clean`
   end


   def test_example_breadcrumbs
      path = "#{@@basedir}/breadcrumbs"
      `cd #{path}; make; make _test`
      _test(path, 'result.html')
      _test(path, 'breadcrumbs.view')
      _test(path, 'breadcrumbs.php')
      _test(path, 'breadcrumbs.jstl11')
      _test(path, 'breadcrumbs.jstl10')
      _test(path, 'breadcrumbs.velocity')
      `cd #{path}; make clean; make _clean`
   end


   def test_example_calendar
      path = "#{@@basedir}/calendar"
      `cd #{path}; make; make _test`
      _test(path, 'result.html')
      _test(path, 'calendar-month.view')
      _test(path, 'calendar-page.view')
      _test(path, 'calendar-month.php')
      _test(path, 'calendar-page.php')
      `cd #{path}; make clean; make _clean`
   end


   def test_example_form1
      path = "#{@@basedir}/form1"
      `cd #{path}; make; make _test`
      _test(path, 'register.view')
      _test(path, 'finish.view')
      _test(path, 'finish.php')
      _test(path, 'finish.jstl11')
      _test(path, 'finish.jstl10')
      _test(path, 'finish.velocity')
      `cd #{path}; make clean; make _clean`
   end


   def test_example_pagelayout
      path = "#{@@basedir}/pagelayout"
      `cd #{path}; make; make _test`
      _test(path, 'result.html')
      _test(path, 'page.view')
      _test(path, 'page.php')
      _test(path, 'page.jstl11')
      _test(path, 'page.jstl10')
      _test(path, 'page.velocity')
      `cd #{path}; make clean; make _clean`
   end


   def test_example_thumbnail
      path = "#{@@basedir}/thumbnail"
      `cd #{path}; make; make _test`
      _test(path, 'thumbnail.view')
      _test(path, 'thumbnail.php')
      _test(path, 'thumbnail.jstl11')
      _test(path, 'thumbnail.jstl10')
      _test(path, 'thumbnail.velocity')
      `cd #{path}; make clean; make _clean`
   end


end


##
## main
##
if $0 == __FILE__
    Test::Unit::UI::Console::TestRunner.run(ExamplesTest)
    #suite = Test::Unit::TestSuite.new()
    #suite << Examples.suite()
    #Test::Unit::UI::Console::TestRunner.run(suite)
end
