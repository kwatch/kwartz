#!/usr/bin/ruby

###
### unit test for Expression and Statement
###

$: << 'lib'
$: << '../lib'
$: << 'test'

require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'assert-diff.rb'
require 'kwartz/node'

include Kwartz

class NodeTest < Test::Unit::TestCase

   def test_variable_expr1
      expr = VariableExpression.new("foo")
      actual = expr._inspect()
      expected = "foo\n"
      assert_equal_with_diff(expected, actual)
   end

   def test_numeric_expr1
      expr = NumericExpression.new("123")
      actual = expr._inspect()
      expected = "123\n"
      assert_equal_with_diff(expected, actual)
   end

   def test_string_expr1
      expr = StringExpression.new("Who's \"Who\"?\r\n")
      actual = expr._inspect()
      expected = '"Who\'s \\"Who\\"?\\r\\n"' + "\n"
      assert_equal_with_diff(expected, actual)
   end

   
end


if $0 == __FILE__
    Test::Unit::UI::Console::TestRunner.run(NodeTest)
    #suite = Test::Unit::TestSuite.new()
    #suite << ConverterTest.suite()
    #Test::Unit::UI::Console::TestRunner.run(suite)
end
