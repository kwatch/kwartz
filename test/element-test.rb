#!/usr/bin/ruby

###
### unit test for Element
###
### $Id$
###

$: << 'lib'
$: << '../lib'
$: << 'test'

require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'assert-diff.rb'
require 'kwartz/element'
require 'kwartz/node'

include Kwartz


##
## parse expression test
##
class ElementTest < Test::Unit::TestCase

   def setup
      @flag_suspend = false
   end


   def test_element1
      marking = 'user_list'
      tagname = 'li'
      content = Kwartz::PrintStatement.new( [ Kwartz::StringExpression.new("foo") ] )
      attr    = { "id" => "user_list", "bgcolor" => "color", "class"=>"user", }
      append  = []
      is_empty = false
      element = Kwartz::Element.new(marking, tagname, content, attr, append)

      part = {}
      part[:value] = Kwartz::VariableExpression.new("user")
      part[:attr]  = { "bgcolor" => Kwartz::VariableExpression.new('color') }
      part[:append] = [ Kwartz::StringExpression.new(" checked") ]
      part[:remove] = [ "id" ]
      part[:tagname] = nil
      part[:plogic] = Kwartz::ForeachStatement.new(
                         Kwartz::VariableExpression.new("user"),
                         Kwartz::VariableExpression.new("list"),
                         Kwartz::BlockStatement.new( [
                            Kwartz::ExpandStatement.new(:stag),
                            Kwartz::ExpandStatement.new(:cont),
                            Kwartz::ExpandStatement.new(:etag),
                            ]))
      decl = Kwartz::Declaration.new(marking, part)

      expected1 = <<'END'
#user_list {
  value:
    user
  attr:
    "bgcolor" color
  append:
    " checked"
  remove:
    "id"
  plogic:
    :foreach
      user
      list
      :block
        @stag
        @cont
        @etag
}
END
      expected2 = <<'END'
===== marking=user_list =====
[tagname]
li
[attrs]
bgcolor="color"
class="user"
id="user_list"
[content]
:print
  "foo"
[spaces]
["", "", "", ""]
[plogic]
:block
  @stag
  @cont
  @etag
END
      expected3 = <<'END'
===== marking=user_list =====
[tagname]
li
[attrs]
bgcolor=color
class="user"
[append]
" checked"
[content]
:print
  user
[spaces]
["", "", "", ""]
[plogic]
:foreach
  user
  list
  :block
    @stag
    @cont
    @etag
END
      assert_equal_with_diff(expected1, decl._inspect)
      assert_equal_with_diff(expected2, element._inspect)
      element.swallow(decl)
      assert_equal_with_diff(expected3, element._inspect)

      #print "------- elem_decl ---------\n"
      #print elem_decl._inspect
      #print "------- before ---------\n"
      #print element._inspect
      #print "------- after ---------\n"
      #element.swallow(elem_decl)
      #print element._inspect
   end

end

if $0 == __FILE__
    Test::Unit::UI::Console::TestRunner.run(ElementTest)
end
