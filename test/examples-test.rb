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

   def _test(filename, path=@path)
      expected_filename = "#{path}/.expected/#{filename}"
      actual_filename   = "#{path}/#{filename}"
      expected = File.open(expected_filename) { |f| f.read() }
      actual   = File.open(actual_filename)   { |f| f.read() }
      assert_equal_with_diff(expected, actual)
   end


   @@langs = [ "php", "jstl11", "jstl10", "velocity" ]

   def _test_all(basename=nil)
      basename ||= (method_name() =~ /_([^_]+)\z/ && $1)
      @@langs.each do |lang|
         _test("#{basename}.#{lang}")
      end
   end


   if test(?d, './examples')
      @@basedir = './examples'
   elsif test(?d, '../examples')
      @@basedir = '../examples'
   else
      raise "directory 'examples' not found."
   end


   ## ---------------------------------------- test method


   def setup
      method_name() =~ /_([^_]+)\z/
      name = $1
      @path = "#{@@basedir}/#{name}"
      `cd #{@path}; rook :all; rook -b .expected/Rookbook :all`
   end

   def teardown
      `cd #{@path}; rook :clear; rook -b .expected/Rookbook :clean`
   end


   def test_example_border1
      _test('result.html')
      _test('border1.view')
      _test_all('border1')
   end


   def test_example_border2
      _test('result.html')
      _test('border2.view')
      _test_all('border2')
   end


   def test_example_border3
      _test('result.html')
      _test('border3.view')
      _test_all('border3')
   end


   def test_example_breadcrumbs
      _test('result.html')
      _test('breadcrumbs.view')
      _test_all('breadcrumbs')
   end


   def test_example_calendar
      _test('result.html')
      _test('calendar-month.view')
      _test('calendar-page.view')
      _test('calendar-month.php')
      _test('calendar-page.php')
   end


   def test_example_form1
      _test('register.view')
      _test('finish.view')
      _test_all('register')
      _test_all('finish')
   end


   def test_example_pagelayout
      _test('result1.html')
      _test('result2.html')
      _test('page1.view')
      _test('page1.view')
      _test_all('page1')
      _test_all('page2')
   end


   def test_example_thumbnail
      _test('thumbnail.view')
      _test_all('thumbnail')
   end


   def test_example_rails1
      _test('list.rhtml')
      _test('show.rhtml')
      _test('new.rhtml')
      _test('edit.rhtml')
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
