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
      converter = Kwartz::Converter.new(properties)
      block_stmt = converter.convert(pdata_str)
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
   def test_expand4
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
        attr: "bgcolor" color;
	plogic: {
          i = 0;
	  foreach(user in user_list) {
            i += 1;
            if (i % 2 == 0) color = '#FFCCCC';
            else            color = '#CCCCFF';
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
      " id=\""
      "table"
      "\""
      " summary=\""
      title
      "\""
      ">\n"
    :block
      :block
        :expr
          =
            i
            0
        :foreach
          user
          user_list
          :block
            :expr
              +=
                i
                1
            :if
              ==
                %
                  i
                  2
                0
              :expr
                =
                  color
                  "#FFCCCC"
              :expr
                =
                  color
                  "#CCCCFF"
            :print
              " <tr"
              " bgcolor=\""
              color
              "\""
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



   ## --------------------
   def test_expand5	# empty tag
      pdata = <<'END'
<input type="text" id="username" />
END
      plogic = <<'END'
#username {
	attr: "value" user.name;
}
END
      expected = <<'END'
:block
  :block
    :print
      "<input"
      " type=\""
      "text"
      "\""
      " id=\""
      "username"
      "\""
      " value=\""
      .
        user
        name
      "\""
      " />\n"
    :block
    :block
END
      _test(pdata, plogic, expected)
   end


   ## --------------------
   def test_expand6	# empty tag and append
      pdata = <<'END'
checkbox:  <input type="checkbox" id="chkbox"/>
END
      plogic = <<'END'
#chkbox {
	remove: "checked";
	append: flag ? ' checked="checked"' : '';
}
END
      expected = <<'END'
:block
  :print
    "checkbox:"
  :block
    :print
      "  <input"
      " type=\""
      "checkbox"
      "\""
      " id=\""
      "chkbox"
      "\""
      ?:
        flag
        " checked=\"checked\""
        ""
      " />\n"
    :block
    :block
END
      _test(pdata, plogic, expected)
   end


   ## --------------------
   def test_expand7	# @element(name) and @content(name)
      pdata = <<'END'
<tr id="mark:list">
  <td id="mark:item">foo</td>
</tr>
 - - -
<div id="mark:space">...</div>
END

      plogic = <<'END'
#space {
  plogic: {
    if (cond1) @element(item);
    while (cond2) @content(list);
  }
}
END
      expected = <<'END'
:block
  :block
    :print
      "<tr"
      ">\n"
    :block
      :block
        :print
          "  <td"
          ">"
        :block
          :print
            "foo"
        :print
          "</td>\n"
    :print
      "</tr>\n"
  :print
    " - - -\n"
  :block
    :if
      cond1
      :block
        :print
          "  <td"
          ">"
        :block
          :print
            "foo"
        :print
          "</td>\n"
    :while
      cond2
      :block
        :block
          :print
            "  <td"
            ">"
          :block
            :print
              "foo"
          :print
            "</td>\n"
END
      _test(pdata, plogic, expected)
   end


end


if $0 == __FILE__
    Test::Unit::UI::Console::TestRunner.run(ExpanderTest)
end
