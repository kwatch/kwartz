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

   def test_parse_literal_expr1
      input = " 123"
      properties = {}
      parser = Parser.new(input, properties)
      expr = parser.parse_literal_expr()
      assert(NumericExpression, expr.class)
      expected = "123"
      #assert_equal_with_diff(expected, expr._inspect())
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
