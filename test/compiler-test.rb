#!/usr/bin/ruby

###
### unit test for Compiler
###
### $Id$
###

$: << 'lib'
$: << '../lib'
$: << 'test'

require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'assert-diff.rb'
require 'kwartz/compiler'


class CompilerTest < Test::Unit::TestCase
   def setup
      @flag_suspend = false
   end


   def _test(pdata_str, plogic_str, expected, properties={})
      return if @flag_suspend
      compiler = Kwartz::Compiler.new(properties)
      actual = compiler.compile('eruby', pdata_str, plogic_str)
      assert_equal_with_diff(expected, actual)
   end


   ## --------------------
   def test_compile1		# marking
      pdata = <<'END'
<table>
 <tr id="mark:user_list">
  <td id="value:user.name">foo</td>
 </tr>
</table>
END
      plogic = <<'END'
#user_list {
	plogic: {
	  foreach(user in user_list) {
	    @stag;
	    @cont;
	    @etag;
	  }
	}
}
END
      expected = <<'END'
<table>
<% for user in user_list do %>
 <tr>
  <td><%= user.name %></td>
 </tr>
<% end %>
</table>
END
      _test(pdata, plogic, expected)
   end


   ## --------------------
   def test_compile2		# nested marking
      pdata = <<'END'
<table>
 <tr id="mark:user_list">
  <td id="mark:user">foo</td>
 </tr>
</table>
END
      plogic = <<'END'
#user {
	value: user[:name];
}
#user_list {
	plogic: {
	  foreach(user in user_list) {
	    @stag;
	    @cont;
	    @etag;
	  }
	}
}
END
      expected = <<'END'
<table>
<% for user in user_list do %>
 <tr>
  <td><%= user[:name] %></td>
 </tr>
<% end %>
</table>
END
      _test(pdata, plogic, expected)
   end



   ## --------------------
   def test_compile3		# remove: "id";
      pdata = <<'END'
<table>
 <tr id="user_list">
  <td id="user">foo</td>
 </tr>
</table>
END
      plogic = <<'END'
#user {
	value: user.name;
	remove: "id";
}
#user_list {
	remove: "id";
	plogic: {
	  foreach(user in user_list) {
	    @stag;
	    @cont;
	    @etag;
	  }
	}
}
END
      expected = <<'END'
<table>
<% for user in user_list do %>
 <tr>
  <td><%= user.name %></td>
 </tr>
<% end %>
</table>
END
      _test(pdata, plogic, expected)
   end



   ## --------------------
   def test_compile4
      pdata = <<'END'
<table id="table">
 <tr id="user_list">
  <td id="name">foo</td>
  <td id="email">foo@email</td>
 </tr>
</table>
END
      plogic = <<'END'
#table {
	attr: "summary" title;
}
#name {
	remove: "id";
	value: user['name'];
}
#email {
	remove: "id";
	value: user['email'];
}
#user_list {
	remove: "id";
	plogic: {
	  foreach(user in user_list) {
	    @stag;
	    @cont;
	    @etag;
	  }
	}
}
END
      expected = <<'END'
<table id="table" summary="<%= title %>">
<% for user in user_list do %>
 <tr>
  <td><%= user["name"] %></td>
  <td><%= user["email"] %></td>
 </tr>
<% end %>
</table>
END
      _test(pdata, plogic, expected)
   end


end


if $0 == __FILE__
    Test::Unit::UI::Console::TestRunner.run(CompilerTest)
end
