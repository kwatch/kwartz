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

class ExpressionTest < Test::Unit::TestCase

   def _test(expr, expected)
      actual = expr._inspect()
      assert_equal_with_diff(expected, actual)
   end

   
   ## leaf expressions
   
   def test_variable_expr1
      expr = VariableExpression.new("foo")
      expected = "foo\n"
      _test(expr, expected)
   end

   def test_numeric_expr1
      expr = NumericExpression.new("123")
      expected = "123\n"
      _test(expr, expected)
   end

   def test_string_expr1
      expr = StringExpression.new("Who's \"Who\"?\r\n")
      expected = '"Who\'s \\"Who\\"?\\r\\n"' + "\n"
      _test(expr, expected)
   end
   
   def test_boolean_expr1
      expr = BooleanExpression.new('true')
      expected = "true\n"
      _test(expr, expected)
      expr = BooleanExpression.new('false')
      expected = "false\n"
      _test(expr, expected)
   end

   def test_null_expr1
      expr = NullExpression.new()
      expected = "null\n"
      _test(expr, expected)
   end
      
   
   ## expressions
   
   def test_unary_expr1
      expr = UnaryExpression.new('!', VariableExpression.new('flag'))
      expected = "!\n  flag\n"
      _test(expr, expected)
   end

   def test_binary_expr1
      expr = BinaryExpression.new('+', VariableExpression.new('a'), NumericExpression.new('1'))
      expected = "+\n  a\n  1\n"
      _test(expr, expected)
   end


   def test_binary_expr1
      expr = BinaryExpression.new('+', VariableExpression.new('a'), NumericExpression.new('1'))
      expected = "+\n  a\n  1\n"
      _test(expr, expected)
   end
   
   def test_function_expr1
      arglist = [
         StringExpression.new("arg1"),
         VariableExpression.new("arg2"),
         BinaryExpression.new("!=", VariableExpression.new("arg3"), NullExpression.new()),
      ]
      expr = FunctionExpression.new('f1', arglist)
      expected = <<END
f1()
  "arg1"
  arg2
  !=
    arg3
    null
END
      _test(expr, expected)
   end

   def test_property_expr1
      arglist = [
         StringExpression.new("arg1"),
         VariableExpression.new("arg2"),
         BinaryExpression.new("!=", VariableExpression.new("arg3"), NullExpression.new()),
      ]
      expr = PropertyExpression.new(VariableExpression.new('obj'), 'p1', arglist)
      expected = <<END
.
  obj
  p1
    "arg1"
    arg2
    !=
      arg3
      null
END
      _test(expr, expected)
   end

   def test_conditional_expr1
      cond = BinaryExpression.new('==', VariableExpression.new('v'), StringExpression.new('yes'))
      left = StringExpression.new(' checked="checked"')
      right = StringExpression.new('')
      expr = ConditionalExpression.new(cond, left, right)
      expected = <<'END'
?:
  ==
    v
    "yes"
  " checked=\"checked\""
  ""
END
      _test(expr, expected)
   end

   
end


if $0 == __FILE__
    Test::Unit::UI::Console::TestRunner.run(ExpressionTest)
    #suite = Test::Unit::TestSuite.new()
    #suite << ConverterTest.suite()
    #Test::Unit::UI::Console::TestRunner.run(suite)
end
