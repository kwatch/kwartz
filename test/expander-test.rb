#!/usr/bin/ruby

###
### unit test for Expander
###
### $Id$
###

$: << 'lib'
$: << '../lib'
$: << 'test'

require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'assert-diff.rb'
require 'kwartz/expander'

require 'kwartz/converter'
require 'kwartz/parser'
require 'kwartz/element'

class ExpanderTest < Test::Unit::TestCase
   def setup
      @flag_suspend = false
   end


   def _test(pdata_str, plogic_str, expected, properties={})
      return if @flag_suspend
      ## convert
      converter = Kwartz::Converter.new(pdata_str, properties)
      block_stmt = converter.convert()
      elem_list = converter.element_list
      ## parse plogic
      parser = Kwartz::Parser.new(plogic_str, properties)
      elem_decl_list = parser.parse_plogic()
      ## merge
      element_table = Kwartz::Element.merge(elem_list, elem_decl_list)
      ## expand
      expander = Kwartz::Expander.new(element_table, properties)
      expander.expand(block_stmt)
      ##
      actual = block_stmt._inspect
      assert_equal_with_diff(expected, actual)
   end


   ## --------------------
   def test_expander1		# marking
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
:block
  :print
    "<table>\n"
  :block
    :foreach
      user
      user_list
      :block
        :print
          " <tr"
          ">\n"
        :block
          :print
            "  <td>"
          :print
            .
              user
              name
          :print
            "</td>\n"
        :print
          " </tr>\n"
  :print
    "</table>\n"
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
:block
  :print
    "<table>\n"
  :block
    :foreach
      user
      user_list
      :block
        :print
          " <tr"
          ">\n"
        :block
          :block
            :print
              "  <td"
              ">"
            :print
              [:]
                user
                "name"
            :print
              "</td>\n"
        :print
          " </tr>\n"
  :print
    "</table>\n"
END
      _test(pdata, plogic, expected)
   end



   ## --------------------
   def test_expand3		# remove: "id";
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
:block
  :print
    "<table>\n"
  :block
    :foreach
      user
      user_list
      :block
        :print
          " <tr"
          ">\n"
        :block
          :block
            :print
              "  <td"
              ">"
            :print
              .
                user
                name
            :print
              "</td>\n"
        :print
          " </tr>\n"
  :print
    "</table>\n"
END
      _test(pdata, plogic, expected)
   end



   ## --------------------
   def test_compile4
      pdata = <<'END'
<table id="table" border="0">
 <tr id="user_list" bgcolor="#FFCCCC">
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
:block
  :block
    :print
      "<table"
      " border=\"0\""
      " id=\"table\""
      " summary=\""
      title
      "\""
      ">\n"
    :block
      :block
        :foreach
          user
          user_list
          :block
            :print
              " <tr"
              " bgcolor=\"#FFCCCC\""
              ">\n"
            :block
              :block
                :print
                  "  <td"
                  ">"
                :print
                  []
                    user
                    "name"
                :print
                  "</td>\n"
              :block
                :print
                  "  <td"
                  ">"
                :print
                  []
                    user
                    "email"
                :print
                  "</td>\n"
            :print
              " </tr>\n"
    :print
      "</table>\n"
END
      _test(pdata, plogic, expected)
   end


end


if $0 == __FILE__
    Test::Unit::UI::Console::TestRunner.run(ExpanderTest)
end
