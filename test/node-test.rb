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


##
## expression test
##
class ExpressionTest < Test::Unit::TestCase

   def _test(expr, expected)
      actual = expr._inspect()
      assert_equal_with_diff(expected, actual)
   end


   ####################################

   ##
   def test_variable_expr1
      expr = VariableExpression.new("foo")
      expected = "foo\n"
      _test(expr, expected)
   end

   ##
   def test_numeric_expr1
      expr = NumericExpression.new("123")
      expected = "123\n"
      _test(expr, expected)
   end

   ##
   def test_string_expr1
      expr = StringExpression.new("Who's \"Who\"?\r\n")
      expected = '"Who\'s \\"Who\\"?\\r\\n"' + "\n"
      _test(expr, expected)
   end

   ##
   def test_boolean_expr1
      expr = BooleanExpression.new('true')
      expected = "true\n"
      _test(expr, expected)
      expr = BooleanExpression.new('false')
      expected = "false\n"
      _test(expr, expected)
   end

   ##
   def test_null_expr1
      expr = NullExpression.new()
      expected = "null\n"
      _test(expr, expected)
   end


   ####################################

   ##
   def test_unary_expr1
      expr = UnaryExpression.new('!', VariableExpression.new('flag'))
      expected = "!\n  flag\n"
      _test(expr, expected)
   end

   ##
   def test_binary_expr1
      expr = BinaryExpression.new('+', VariableExpression.new('a'), NumericExpression.new('1'))
      expected = "+\n  a\n  1\n"
      _test(expr, expected)
   end

   ##
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

   ##
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

   ##
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



##
## statement test
##
class StatementTest < Test::Unit::TestCase

   def _test(stmt, expected)
      actual = stmt._inspect()
      assert_equal_with_diff(expected, actual)
   end


   ##
   def test_print_stmt1
      arglist = [
         StringExpression.new("<li>"),
         VariableExpression.new("item"),
         StringExpression.new("</li>\n"),
      ]
      stmt = PrintStatement.new(arglist)
      expected = <<'END'
:print
  "<li>"
  item
  "</li>\n"
END
      _test(stmt, expected)
   end


   ##
   def test_set_stmt1
      assign_expr = BinaryExpression.new('=', VariableExpression.new('i'), NumericExpression.new('10'))
      stmt = SetStatement.new(assign_expr)
      expected = <<'END'
:set
  =
    i
    10
END
      _test(stmt, expected)
   end


   ##
   def test_block_stmt1
      stmt1 = PrintStatement.new([ StringExpression.new("<div>") ])
      stmt2 = SetStatement.new(BinaryExpression.new('=', VariableExpression.new('i'), NumericExpression.new('10')))
      stmt3 = PrintStatement.new([ StringExpression.new("</div>\n") ])
      stmt = BlockStatement.new( [ stmt1, stmt2, stmt3, ] )
      expected = <<'END'
:block
  :print
    "<div>"
  :set
    =
      i
      10
  :print
    "</div>\n"
END
      _test(stmt, expected)
   end


   ##
   def test_if_stmt1
      cond  = UnaryExpression.new('!', BooleanExpression.new('false'))
      stmt1 = PrintStatement.new([ StringExpression.new("yes") ])
      stmt2 = PrintStatement.new([ StringExpression.new("no") ])
      stmt = IfStatement.new(cond, BlockStatement.new([stmt1]) )
      expected = <<'END'
:if
  !
    false
  :block
    :print
      "yes"
END
      _test(stmt, expected)
   end


   ##
   def test_else_stmt1
      cond  = UnaryExpression.new('!', BooleanExpression.new('false'))
      stmt1 = PrintStatement.new([ StringExpression.new("yes") ])
      stmt2 = PrintStatement.new([ StringExpression.new("no") ])
      stmt = IfStatement.new(cond, BlockStatement.new([stmt1]), BlockStatement.new([stmt2]) )
      expected = <<'END'
:if
  !
    false
  :block
    :print
      "yes"
  :block
    :print
      "no"
END
      _test(stmt, expected)
   end


   ##
   def test_elseif_stmt1
      cond  = UnaryExpression.new('!', BooleanExpression.new('false'))
      stmt1 = PrintStatement.new([ StringExpression.new("yes") ])
      stmt2 = PrintStatement.new([ StringExpression.new("no") ])
      cond2 = UnaryExpression.new('!', BooleanExpression.new('true'))
      stmt = IfStatement.new(cond,
                             BlockStatement.new([stmt1]),
			     IfStatement.new(cond2,
			                     BlockStatement.new([stmt2])))
      expected = <<'END'
:if
  !
    false
  :block
    :print
      "yes"
  :if
    !
      true
    :block
      :print
        "no"
END
      _test(stmt, expected)
   end


   ##
   def test_foreach_stmt1
      stmt = ForeachStatement.new(VariableExpression.new("item"),
                                  VariableExpression.new("list"),
                                  BlockStatement.new( [
                                     PrintStatement.new( [ StringExpression.new("foo") ] ),
                                     ] ))
      expected = <<'END'
:foreach
  item
  list
  :block
    :print
      "foo"
END
      _test(stmt, expected)
   end


   ##
   def test_while_stmt1
      stmt = WhileStatement.new(BinaryExpression.new('<', VariableExpression.new('i'), NumericExpression.new('10')),
                                BlockStatement.new( [
                                     PrintStatement.new( [ VariableExpression.new('i') ] ),
                                     ] ))
      expected = <<'END'
:while
  <
    i
    10
  :block
    :print
      i
END
      _test(stmt, expected)
   end


   ##
   def test_macro_stmt1
      stmt = MacroStatement.new('cont_foo',
                                BlockStatement.new([
				   PrintStatement.new([ StringExpression.new("foo") ]),
				]))
      expected = <<'END'
:macro(cont_foo)
  :block
    :print
      "foo"
END
      _test(stmt, expected)
   end


   ##
   def test_expand_stmt1
      stmt = ExpandStatement.new('foo')
      expected = <<'END'
:expand(foo)
END
      _test(stmt, expected)
   end


   ##
   def test_rawcode_stmt1
   	stmt = RawcodeStatement.new("<% time = Time.new.to_s %>\n")
	expected = <<'END'
::: <% time = Time.new.to_s %>
END
	_test(stmt, expected)
   end

end


##
## main
##
if $0 == __FILE__
    Test::Unit::UI::Console::TestRunner.run(ExpressionTest)
    Test::Unit::UI::Console::TestRunner.run(StatementTest)
    #suite = Test::Unit::TestSuite.new()
    #suite << ExpressionTest.suite()
    #suite << StatementTest.suite()
    #Test::Unit::UI::Console::TestRunner.run(suite)
end
