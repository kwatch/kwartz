#!/usr/bin/ruby

###
### unit test for Analyzer
###
### $Id$
###

$: << 'lib'
$: << '../lib'
$: << 'test'

require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'assert-diff.rb'
require 'kwartz/analyzer'
require 'kwartz/compiler'


class AnalyzerTest < Test::Unit::TestCase
   def setup
      @flag_suspend = false
   end

   def _test(pdata_str, plogic_str, expected, properties={})
      return if @flag_suspend
      compiler = Kwartz::Compiler.new(properties)
      
      ## convert
      block_stmt, element_list = compiler.convert(pdata_str)
      ## parse presentation logic
      elem_decl_list = compiler.parse_plogic(plogic_str)
      ## merge
      element_table = compiler.merge(element_list, elem_decl_list)
      ## expand
      compiler.expand(block_stmt, element_table)
      #print block_stmt._inspect
      
      ## analyze
      analyzer = Kwartz::Analyzer.create('scope', properties)
      analyzer.analyze(block_stmt)
      actual = analyzer.result
      assert_equal_with_diff(expected, actual)
   end


   ## ---------------------------------------- basic

   def test_analyze1
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
Global variable(s): title user_list
Local  variable(s): i user color
END
      _test(pdata, plogic, expected)
   end



   ## ---------------------------------------- use global var as loopvar in foreach-stmt
   
   def test_analyze2	# use global var as loopvar in foreach-stmt
      pdata = <<'END'
<div id="value:item">hoge</div>
<ul id="list">
  <li id="item">foo</li>
</ul>
END
      plogic = <<'END'
#item {
	value: item;
}
#list {
	plogic: {
		@stag;
		foreach (item in list) {
			@cont;
		}
		@etag;
	}
}
END
      expected = <<'END'
Global variable(s): item list
Local  variable(s): 
Warning: using a global variable 'item' as loopvar in foreach-statement.
END
      _test(pdata, plogic, expected)
   end


   ## ---------------------------------------- assignment into a global variable
   
   def test_analyze3	# use global var as loopvar in foreach-stmt
      pdata = <<'END'
<div id="value:user_ctr">hoge</div>
<ul id="Loop:user=user_list">
  <li id="user">foo</li>
</ul>
END
      plogic = <<'END'
#user {
	value: user;
}
END
      expected = <<'END'
Global variable(s): user_ctr user_list
Local  variable(s): user
Warning: assignment into a global variable 'user_ctr'.
END
      _test(pdata, plogic, expected)
   end


   ## ---------------------------------------- unsupported funcion
   
   def test_analyze4	# unsupported function
      pdata = <<'END'
<div id="value:list_length(list)">foo</div>
<div id="value:hash_length(hash)">foo</div>
END
      plogic = <<'END'
END
      expected = <<'END'
Global variable(s): list hash
Local  variable(s): 
Warning: unsupported function 'hash_length' is used.
END
      _test(pdata, plogic, expected)
   end


   ## ---------------------------------------- i += 1 ; j = j+1
   
   def test_analyze5	# unsupported function
      pdata = <<'END'
<div id="foo">foo</div>
END
      plogic = <<'END'
#foo {
	plogic: {
		i += 1;
		j = j+1;
	}
}
END
      expected = <<'END'
Global variable(s): i j
Local  variable(s): 
Warning: assignment into a global variable 'i'.
Warning: assignment into a global variable 'j'.
END
      _test(pdata, plogic, expected)
   end
   
end
