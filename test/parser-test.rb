#!/usr/bin/ruby

###
### unit test for Parser
###

$: << 'lib'
$: << '../lib'
$: << 'test'

require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'assert-diff.rb'
require 'kwartz/parser'

include Kwartz


##
## parse expression test
##
class ParseExpressionTest < Test::Unit::TestCase

   ##
   def _test(input, expected, klass, properties={})
      s = caller().first
      s =~ /in `(.*)'/		#'
      testmethod = $1
      method_name = testmethod.sub(/\Atest_/, '').sub(/\d*\z/, '')
      #$stderr.puts "*** debug: method_name=#{method_name.inspect}"
      parser = Parser.new(input, properties)
      expr = parser.__send__(method_name)
      assert_equal(klass, expr.class)
      assert_equal_with_diff(expected, expr._inspect())
   end

   ##
   def _test_parse_arguments(input, expected, properties={})
      parser = Parser.new(input, {})
      arglist = parser.parse_arguments
      assert_equal(Array, arglist.class)
      actual = arglist.collect { |expr| expr._inspect() }.join()
      assert_equal_with_diff(expected, actual)
   end



   ##
   def test_parse_arguments1
      input = 'x, 10, "str"'
      expected = "x\n10\n\"str\"\n"
      _test_parse_arguments(input, expected)
   end

   def test_parse_arguments2
      input = "x, y+1, a<b?b: a, 'foo'"
      expected = <<'END'
x
+
  y
  1
?:
  <
    a
    b
  b
  a
"foo"
END
      _test_parse_arguments(input, expected)
   end

   ##
   def test_parse_item_expr1
      input = "x"
      expected = "x\n"
      _test(input, expected, VariableExpression)
   end

   def test_parse_item_expr2
      input = "f1()"
      expected = "f1()\n"
      _test(input, expected, FunctionExpression)
      input = "f2(x, y)"
      expected = "f2()\n  x\n  y\n"
      _test(input, expected, FunctionExpression)
   end

   def test_parse_item_expr3
      input = "(x + y)"
      expected = "+\n  x\n  y\n"
      _test(input, expected, BinaryExpression)
   end

   ##
   def test_parse_literal_expr1
      input = "123"
      expected = "123\n"
      _test(input, expected, NumericExpression)
   end

   def test_parse_literal_expr2
      input = "'foo\"bar'"
      expected = '"foo\\"bar"' + "\n"
      _test(input, expected, StringExpression)
      input = '"foo\'bar\r\n"'
      expected = '"foo\'bar\r\n"' + "\n"
      _test(input, expected, StringExpression)
   end

   def test_parse_literal_expr3
      input = "true"
      expected = "true\n"
      _test(input, expected, BooleanExpression)
      input = "false"
      expected = "false\n"
      _test(input, expected, BooleanExpression)
      input = "null"
      expected = "null\n"
      _test(input, expected, NullExpression)
   end

   def test_parse_literal_expr4
      input = "empty"
      expected = ""
      assert_raise(Kwartz::SyntaxError) do
         _test(input, expected, Expression)
      end
   end

   ##
   def test_parse_factor_expr1
      input = "x"
      expected = "x\n"
      _test(input, expected, VariableExpression)
   end

   def test_parse_factor_expr2
      input = "x[i+1]"
      expected = "[]\n  x\n  +\n    i\n    1\n"
      _test(input, expected, BinaryExpression)
   end

   def test_parse_factor_expr3
      input = "x[:key]"
      expected = "[:]\n  x\n  \"key\"\n"
      _test(input, expected, BinaryExpression)
   end

   def test_parse_factor_expr4
      input = "x.prop"
      expected = ".\n  x\n  prop\n"
      _test(input, expected, PropertyExpression)
      input = "x.prop(a, b)"
      expected = ".\n  x\n  prop\n    a\n    b\n"
      _test(input, expected, PropertyExpression)
   end

   ##
   def test_parse_term_expr1
      input = "x * y"
      expected = "*\n  x\n  y\n"
      _test(input, expected, BinaryExpression)
   end

   def test_parse_term_expr2
      input = "a * b / c % d"
      expected = <<'END'
%
  /
    *
      a
      b
    c
  d
END
      _test(input, expected, BinaryExpression)
   end

   ##
   def test_parse_unary_expr1
      input = "-1"
      expected = "-.\n  1\n"
      _test(input, expected, UnaryExpression)
      input = "+1"
      expected = "+.\n  1\n"
      _test(input, expected, UnaryExpression)
      input = "! flag"
      expected = "!\n  flag\n"
      _test(input, expected, UnaryExpression)
   end

   def test_parse_unary_expr2
      input = "1"
      expected = "1\n"
      _test(input, expected, NumericExpression)
   end

   ##
   def test_parse_arith_expr1
      input = "x + y"
      expected = "+\n  x\n  y\n"
      _test(input, expected, BinaryExpression)
   end

   def test_parse_arith_expr2
      input = "a + b - c .+ d"
      expected = <<'END'
.+
  -
    +
      a
      b
    c
  d
END
      _test(input, expected, BinaryExpression)
   end

   def test_parse_arith_expr3
      input = "! a + b * c - d % e"
      expected = <<'END'
-
  +
    !
      a
    *
      b
      c
  %
    d
    e
END
      _test(input, expected, BinaryExpression)
   end

   def test_parse_arith_expr4
      input = "- a * b * ! c"
      expected = ""
      assert_raise(Kwartz::SyntaxError) do
         _test(input, expected, Expression)
      end
   end

   ##
   def test_parse_compare_expr1
      input = "x == y"
      expected = "==\n  x\n  y\n"
      _test(input, expected, BinaryExpression)
      input = "x != y"
      expected = "!=\n  x\n  y\n"
      _test(input, expected, BinaryExpression)
      input = "x > y"
      expected = ">\n  x\n  y\n"
      _test(input, expected, BinaryExpression)
      input = "x >= y"
      expected = ">=\n  x\n  y\n"
      _test(input, expected, BinaryExpression)
      input = "x < y"
      expected = "<\n  x\n  y\n"
      _test(input, expected, BinaryExpression)
      input = "x <= y"
      expected = "<=\n  x\n  y\n"
      _test(input, expected, BinaryExpression)
   end

   def test_parse_compare_expr2
      input = "x + y <= x * y"
      expected = <<'END'
<=
  +
    x
    y
  *
    x
    y
END
      _test(input, expected, BinaryExpression)
   end

   def test_parse_compare_expr3
      input = "x == empty"
      expected = "empty\n  x\n"
      _test(input, expected, UnaryExpression)
      input = "x != empty"
      expected = "notempty\n  x\n"
      _test(input, expected, UnaryExpression)
   end

   def test_parse_compare_expr4
      input = "x > empty"
      expected = ""
      assert_raise(Kwartz::SyntaxError) do
         _test(input, expected, Expression)
      end
   end

   ##
   def test_parse_logical_and_expr1
      input = "0 < x && x < 10"
      expected = <<END
&&
  <
    0
    x
  <
    x
    10
END
      _test(input, expected, BinaryExpression)
   end

   ##
   def test_parse_logical_or_expr1
      input = "x < 0 || 10 < x"
      expected = <<END
||
  <
    x
    0
  <
    10
    x
END
      _test(input, expected, BinaryExpression)
   end

   def test_parse_logical_or_expr2
      input = "! flag || 0 < x && 10 >= x"
      expected = <<END
||
  !
    flag
  &&
    <
      0
      x
    >=
      10
      x
END
      _test(input, expected, BinaryExpression)
   end

   ##
   def test_parse_conditional_expr1
      input = "x > y ? x : y"
      expected = <<END
?:
  >
    x
    y
  x
  y
END
      _test(input, expected, ConditionalExpression)
   end

   def test_parse_conditional_expr2
      input = "x > y ? x : y > z ? y : z"
      expected = <<END
?:
  >
    x
    y
  x
  ?:
    >
      y
      z
    y
    z
END
      _test(input, expected, ConditionalExpression)
   end

   ##
   def test_parse_assignment_expr1
      input = "x = 1"
      expected = "=\n  x\n  1\n"
      _test(input, expected, BinaryExpression)
      input = "x += 1"
      expected = "+=\n  x\n  1\n"
      _test(input, expected, BinaryExpression)
      input = "x -= 1"
      expected = "-=\n  x\n  1\n"
      _test(input, expected, BinaryExpression)
      input = "x *= 1"
      expected = "*=\n  x\n  1\n"
      _test(input, expected, BinaryExpression)
      input = "x /= 1"
      expected = "/=\n  x\n  1\n"
      _test(input, expected, BinaryExpression)
      input = "x .+= 1"
      expected = ".+=\n  x\n  1\n"
      _test(input, expected, BinaryExpression)
   end

   def test_parse_assignment_expr2
      input = "x = y = z = null"
      expected = <<'END'
=
  x
  =
    y
    =
      z
      null
END
      _test(input, expected, BinaryExpression)
   end

   ##
   def test_parse_expression1
      input = "val = x > y ? x + 1 : y - 1"
      expected = <<'END'
=
  val
  ?:
    >
      x
      y
    +
      x
      1
    -
      y
      1
END
      _test(input, expected, BinaryExpression)
   end

end


##
## parse statement test
##
class ParseStatementTest < Test::Unit::TestCase

end



##
## main
##
if $0 == __FILE__
    Test::Unit::UI::Console::TestRunner.run(ParseExpressionTest)
    #Test::Unit::UI::Console::TestRunner.run(ParseStatementTest)
    #suite = Test::Unit::TestSuite.new()
    #suite << ParseExpressionTest.suite()
    #suite << ParseStatementTest.suite()
    #Test::Unit::UI::Console::TestRunner.run(suite)
end
