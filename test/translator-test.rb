#!/usr/bin/ruby

###
### unit test for Translator
###
### $Id$
###

$: << 'lib'
$: << '../lib'
$: << 'test'

require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'assert-diff.rb'
require 'kwartz/translator'
require 'kwartz/parser'


##
## translator test
##
class TranslatorTest < Test::Unit::TestCase

   def setup
      @flag_suspend = false
   end

   def _test(input, expected, properties={})
      parser = Kwartz::Parser.new(input, properties)
      block_stmt = parser.parse()
      translator = Kwartz::BaseTranslator.new(block_stmt, properties)
      actual = translator.translate()
      assert_equal_with_diff(expected, actual)
   end


   def test_expr_stmt1
      input = "a = 1;"
      expected = "<% a = 1 %>\n"
      _test(input, expected)
   end


   def test_expr_stmt2
      input = "a[i] += x>y ? x : y;"
      expected = "<% a[i] += x > y ? x : y %>\n"
      _test(input, expected)
   end


   def test_print_stmt1
      input = 'print("foo", a+b, "\n");'
      expected = "foo<%= a + b %>\n"
      _test(input, expected)
   end

   def test_if_stmt1
      input = 'if (x>y) print(x); else print(y);'
      expected = <<'END'
<% if x > y then %>
<%= x %><% else %>
<%= y %><% end %>
END
      _test(input, expected)
   end

   def test_if_stmt2
      input = 'if (x>y) print(x); else if (y>z) print(y);'
      expected = <<'END'
<% if x > y then %>
<%= x %><% elsif y > z then %>
<%= y %><% end %>
END
      _test(input, expected)
   end


   def test_if_stmt3
      input = <<'END'
if (x>y && x>z) {
  max = x;
} else if (y>x && y>z) {
  max = y;
} else if (z>x && z>x) {
  max = z;
} else {
  max = -1;
}
END
      expected = <<'END'
<% if x > y && x > z then %>
<%   max = x %>
<% elsif y > x && y > z then %>
<%   max = y %>
<% elsif z > x && z > x then %>
<%   max = z %>
<% else %>
<%   max = -1 %>
<% end %>
END
      _test(input, expected)
   end


   def test_foreach_stmt1
      input = <<'END'
foreach (item in list)
  print("<li>", item, "</li>\n");
END
      expected = <<'END'
<% for item in list do %>
<li><%= item %></li>
<% end %>
END
      _test(input, expected)
   end


   def test_foreach_stmt2
      input = <<'END'
foreach (item in list) {
  print("<li>", item, "</li>\n");
}
END
      expected = <<'END'
<% for item in list do %>
<li><%= item %></li>
<% end %>
END
      _test(input, expected)
   end


   def test_while_stmt1
      input = <<'END'
while (i<len) i += i;
END
      expected = <<'END'
<% while i < len do %>
<%   i += i %>
<% end %>
END
      _test(input, expected)
   end


end


##
## main
##
if $0 == __FILE__
    Test::Unit::UI::Console::TestRunner.run(TranslationTest)
end
