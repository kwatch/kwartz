<?php

###
### KwartzConverterTest.php
###

require_once('PHPUnit.php');
require_once('KwartzConverter.inc');

class KwartzConverterTest extends PHPUnit_TestCase {

	function __construct($name) {
		$this->PHPUnit_TestCase($name);
	}


	function _test_fetch($input, $expected, $flag_test=true) {
		$input    = preg_replace('/^\t\t/m', '', $input);
		$expected = preg_replace('/^\t\t/m', '', $expected);
		$converter = new KwartzConverter($input);
		$actual = $converter->fetch_all();
		if ($flag_test) {
			$this->assertEquals($expected, $actual);
		}
		return $converter;
	}


	function test_fetch1() {
		$input = <<<END
		<span>
		</span>

END;
#		$expected = <<<END
#		"" "" <span ""> "\\n"
#		"" "" </span ""> "\\n"
#		""
#END;
		$expected = <<<END
		before_text:  ""
		before_space: ""
		tag:          <span>
		attr_str:     ""
		after_space:  "\\n"
		
		before_text:  ""
		before_space: ""
		tag:          </span>
		attr_str:     ""
		after_space:  "\\n"
		rest:         ""


END;
		$this->_test_fetch($input, $expected);
	}



	function test_fetch2() {
		$input = <<<END
		hoge
		geji
		<span>

END;
#		$expected = <<<END
#		"hoge\\ngeji\\n" "" <span ""> "\\n"
#		""
#END;
		$expected = <<<END
		before_text:  "hoge\\ngeji\\n"
		before_space: ""
		tag:          <span>
		attr_str:     ""
		after_space:  "\\n"
		rest:         ""


END;

		$this->_test_fetch($input, $expected);
	}


	function test_fetch3() {
		$input = <<<END
		 <span/>

END;
		$expected = <<<END
		"" " " <span ""/> "\\n"
		""
END;
		$expected = <<<END
		before_text:  ""
		before_space: " "
		tag:          <span/>
		attr_str:     ""
		after_space:  "\\n"
		rest:         ""


END;
		$this->_test_fetch($input, $expected);
	}



	function test_fetch4() {
		$input = <<<END
		<span kd="value:foo">hello</span>

END;
#		$expected = <<<END
#		"" "" <span " kd=\\"value:foo\\""> ""
#		"hello" "" </span ""> "\\n"
#		""
#END;
		$expected = <<<END
		before_text:  ""
		before_space: ""
		tag:          <span>
		attr_str:     " kd=\"value:foo\""
		after_space:  ""
		
		before_text:  "hello"
		before_space: ""
		tag:          </span>
		attr_str:     ""
		after_space:  "\\n"
		rest:         ""


END;

		$this->_test_fetch($input, $expected);
	}


	function test_fetch5() {
		$input = <<<END
		<span id="foo" class="foo"
		      kd="attr:class=ctr%2==0?'even':'odd'">hello</span>

END;
#		$expected = <<<END
#		"" "" <span " id=\\"foo\\" class=\\"foo\\"\\n      kd=\\"attr:class=ctr%2==0?'even':'odd'\\""> ""
#		"hello" "" </span ""> "\\n"
#		""
#END;
		$expected = <<<END
		before_text:  ""
		before_space: ""
		tag:          <span>
		attr_str:     " id=\"foo\" class=\"foo\"\\n      kd=\"attr:class=ctr%2==0?'even':'odd'\""
		after_space:  ""
		
		before_text:  "hello"
		before_space: ""
		tag:          </span>
		attr_str:     ""
		after_space:  "\\n"
		rest:         ""


END;
		$this->_test_fetch($input, $expected);
	}


	function test_fetch6() {
		$input = <<<END
		<span id="foo" class="foo"
		      php="attr('class'=>\$user->ctr%2==0?'even':'odd')">hello</span>

END;
#		$expected = <<<END
#"" "" <span " id=\"foo\" class=\"foo\"\\n      php=\"attr('class'=>\$user->ctr%2==0?'even':'odd')\""> ""
#"hello" "" </span ""> "\\n"
#""
#END;
		$expected = <<<END
		before_text:  ""
		before_space: ""
		tag:          <span>
		attr_str:     " id=\"foo\" class=\"foo\"\\n      php=\"attr('class'=>\$user->ctr%2==0?'even':'odd')\""
		after_space:  ""
		
		before_text:  "hello"
		before_space: ""
		tag:          </span>
		attr_str:     ""
		after_space:  "\\n"
		rest:         ""


END;
		$this->_test_fetch($input, $expected);
	}


	function test_fetch7() {
		$input = <<<END
		<div kd="mark:foo">
		 <div id="bar">
		  <div id="baz">
		   test
		  </div>
		 </div>
		</div>
END;
		$expected = <<<END
		before_text:  ""
		before_space: ""
		tag:          <div>
		attr_str:     " kd=\"mark:foo\""
		after_space:  "\\n"
		
		before_text:  ""
		before_space: " "
		tag:          <div>
		attr_str:     " id=\"bar\""
		after_space:  "\\n"
		
		before_text:  ""
		before_space: "  "
		tag:          <div>
		attr_str:     " id=\"baz\""
		after_space:  "\\n"
		
		before_text:  "   test\\n"
		before_space: "  "
		tag:          </div>
		attr_str:     ""
		after_space:  "\\n"
		
		before_text:  ""
		before_space: " "
		tag:          </div>
		attr_str:     ""
		after_space:  "\\n"
		
		before_text:  ""
		before_space: ""
		tag:          </div>
		attr_str:     ""
		after_space:  ""
		rest:         ""


END;
		$this->_test_fetch($input, $expected, true);
	}


	###
	### helper method for convert()
	###

	function test_parse_directive_kdstr1() {
		$converter = new KwartzConverter('');
		$directive_str = "attr:class:klass;attr:id:item;value:expr";
		$attr_directives = array();
		$directive = $converter->_parse_directive_kdstr($directive_str, $attr_directives);
		$this->assertEquals('klass', $attr_directives['class']);
		$this->assertEquals('item', $attr_directives['id']);
		$this->assertEquals('value', $directive[0]);
		$this->assertEquals('expr', $directive[1]);
		//echo var_dump($attr_directives);
		//echo var_dump($directive);
	}
	

	function test_parse_attr_str1() {
		$input = <<<END
<tr id="foo" class="odd" kd="attr:class:klass;attr:align=item.align;set:klass=ctr%2==0?'even':'odd'">
  <td id="value:klass">hoge</td>
</tr>
END;
		$converter = new KwartzConverter($input);
		$tag_name = $converter->fetch();
		//echo "*** debug: before:" . $converter->_attr_str() . "\n";
		$directive = $converter->_parse_attr_str($converter->_attr_str());
		//echo "*** debug: after:" . $converter->_attr_str() . "\n";
		$this->assertEquals(' id="foo" class="#{klass}#" align="#{item.align}#"', $converter->_attr_str());
		//echo var_dump($directive);
		$this->assertEquals("set", $directive[0]);
		$this->assertEquals("klass=ctr%2==0?'even':'odd'", $directive[1]);
	}



	function test_parse_attr_str2() {
		$input = <<<END
<tr id="foo" class="odd" php="attr('class'=>\$klass,'align'=>\$item->align);foreach(\$list as \$item)">
  <td id="value:klass">hoge</td>
</tr>
END;
		$expected1 = ' id="foo" class="odd" php="attr(\'class\'=>$klass,\'align\'=>$item->align);foreach($list as $item)"';
		$expected2 = ' id="foo" class="@{$klass}@" align="@{$item->align}@"';

		$converter = new KwartzConverter($input);
		$tag_name = $converter->fetch();
		//echo "*** debug: before:" . kwartz_inspect_str($converter->_attr_str()) . "\n";
		$this->assertEquals($expected1, $converter->_attr_str());
		
		$directive = $converter->_parse_attr_str($converter->_attr_str());
		//echo "*** debug: after:" . kwartz_inspect_str($converter->_attr_str()) . "\n";
		$this->assertEquals($expected2, $converter->_attr_str());

		//echo var_dump($directive);
		$this->assertEquals("foreach", $directive[0]);
		$this->assertEquals("\$list as \$item", $directive[1]);
	}


	###
	### convert()
	###
	function _test_convert($input, $expected, $flag_test=true) {
		$input    = preg_replace('/^\t\t/m', '', $input);
		$expected = preg_replace('/^\t\t/m', '', $expected);
		$converter = new KwartzConverter($input);
		$block = $converter->convert();
		$actual = $block->inspect();
		if ($flag_test) {
			$this->assertEquals($expected, $actual);
		}
		return $converter;
	}
	
	
	function test_convert1() {
		$input = <<<END
		<span>
		</span>
END;
		$expected = <<<END
		<<block>>
		  :print
		    "<span>\\n"
		  :print
		    "</span>"

END;
		$this->_test_convert($input, $expected);
	}



	function test_convert_embedded1() {
		$input = <<<END
		aaa#{var}#bbb#{array[0]}#ccc
END;
		$expected = <<<END
		<<block>>
		  :print
		    "aaa"
		    var
		    "bbb"
		    []
		      array
		      0
		    "ccc"

END;
		$this->_test_convert($input, $expected);
	}



	function test_convert_embedded2() {
		$input = <<<END
		aaa
		bbb#{var}#
		ccc
END;
		$expected = <<<END
		<<block>>
		  :print
		    "aaa\\nbbb"
		    var
		    "\\nccc"

END;
		$this->_test_convert($input, $expected);
	}



	function test_convert_embedded3() {
		$input = <<<END
		<tr class="#{klass}#">
		  <td>#{item}#</td><td>#{mail}#</td>
		</tr>
END;
		$expected = <<<END
		<<block>>
		  :print
		    "<tr class=\\""
		    klass
		    "\\">\\n"
		  :print
		    "  <td>"
		  :print
		    item
		  :print
		    "</td>"
		  :print
		    "<td>"
		  :print
		    mail
		  :print
		    "</td>\\n"
		  :print
		    "</tr>"

END;
		$this->_test_convert($input, $expected);
	}




	function test_convert_mark() {
		$input = <<<END
		<div kd="mark:foo">
		hoge
		</div>
END;

		$input2 = <<<END
		<div php="mark(foo)">
		hoge
		</div>
END;
		$expected = <<<END
		<<block>>
		  :macro
		    'stag_foo'
		    <<block>>
		      :print
		        "<div>\\n"
		  :macro
		    'cont_foo'
		    <<block>>
		      :print
		        "hoge\\n"
		  :macro
		    'etag_foo'
		    <<block>>
		      :print
		        "</div>"
		  :macro
		    'element_foo'
		    <<block>>
		      :expand
		        'stag_foo'
		      :expand
		        'cont_foo'
		      :expand
		        'etag_foo'
		  :expand
		    'element_foo'

END;
		$this->_test_convert($input,  $expected);
		$this->_test_convert($input2, $expected);
	}



	function test_convert_value() {
		$input = <<<END
		<td kd="value:hash['key']">hoge</td>
END;
		$input2 = <<<END
		<td php="echo(\$hash['key'])">hoge</td>
END;
		$expected = <<<END
		<<block>>
		  :print
		    "<td>"
		  :print
		    []
		      hash
		      "key"
		  :print
		    "</td>"

END;
		$this->_test_convert($input,  $expected);
		$this->_test_convert($input2, $expected);
	}




	function test_convert_if() {
		$input = <<<END
		<font color="red" kd="if:flag!=true">
		ERROR
		</font>
END;
		$input2 = <<<END
		<font color="red" php="if(\$flag!=true)">
		ERROR
		</font>
END;
		$expected = <<<END
		<<block>>
		  :if
		    !=
		      flag
		      true
		    <<block>>
		      :print
		        "<font color=\\"red\\">\\n"
		      :print
		        "ERROR\\n"
		      :print
		        "</font>"

END;
		$this->_test_convert($input,  $expected);
		$this->_test_convert($input2, $expected);
	}




	function test_convert_unless() {
		$input = <<<END
		<font color="red" kd="unless:list.length>0">Empty.</font>
END;
#		$input2 = <<<END
#		<font color="red" php="unless(list.length>0)">Empty.</font>
#END;
		$expected = <<<END
		<<block>>
		  :if
		    !
		      >
		        .
		          list
		          'length'
		        0
		    <<block>>
		      :print
		        "<font color=\"red\">"
		      :print
		        "Empty."
		      :print
		        "</font>"

END;
		$this->_test_convert($input,  $expected);
		#$this->_test_convert($input2, $expected);
	}





	function test_convert_while() {
		$input = <<<END
		<li kd="while:i<max">foo</li>
END;
		$input2 = <<<END
		<li php="while(\$i<\$max)">foo</li>
END;
		$expected = <<<END
		<<block>>
		  :while
		    <
		      i
		      max
		    <<block>>
		      :print
		        "<li>"
		      :print
		        "foo"
		      :print
		        "</li>"

END;
		$this->_test_convert($input,  $expected);
		$this->_test_convert($input2, $expected);
	}





	function test_convert_dummy() {
		$input = <<<END
		<ul>
		<li kd="dummy:x1" class="even">bar</li>
		</ul>
END;
		$input2 = <<<END
		<ul>
		<li php="dummy(x1)" class="even">bar</li>
		</ul>
END;
		$expected = <<<END
		<<block>>
		  :print
		    "<ul>\\n"
		  :print
		    "</ul>"

END;
		$this->_test_convert($input,  $expected);
		$this->_test_convert($input2, $expected);
	}



	function test_convert_set1() {
		$input = <<<END
		<td kd="set:i=i+1">hoge</td>
END;
		$input2 = <<<END
		<td php="\$i=\$i+1">hoge</td>
END;
		$expected = <<<END
		<<block>>
		  :set
		    =
		      i
		      +
		        i
		        1
		  :print
		    "<td>"
		  :print
		    "hoge"
		  :print
		    "</td>"

END;
		$this->_test_convert($input,  $expected);
		$this->_test_convert($input2, $expected);
	}




	function test_convert_foreach1() {
		$input = <<<END
		<b kd="foreach:item=list">hoge</b>
END;
		$input2 = <<<END
		<b php="foreach(\$list as \$item)">hoge</b>
END;
		$expected = <<<END
		<<block>>
		  :foreach
		    item
		    list
		    <<block>>
		      :print
		        "<b>"
		      :print
		        "hoge"
		      :print
		        "</b>"

END;
		$this->_test_convert($input,  $expected);
		$this->_test_convert($input2, $expected);
	}




	function test_convert_foreach2() {
		$input = <<<END
		<b kd="Foreach:item=list">hoge</b>
END;
		$input2 = <<<END
		<b php="Foreach(\$list as \$item)">hoge</b>
END;
		$expected = <<<END
		<<block>>
		  :set
		    =
		      item_ctr
		      0
		  :foreach
		    item
		    list
		    <<block>>
		      :set
		        +=
		          item_ctr
		          1
		      :print
		        "<b>"
		      :print
		        "hoge"
		      :print
		        "</b>"

END;
		$this->_test_convert($input,  $expected);
		$this->_test_convert($input2, $expected);
	}



	function test_convert_foreach3() {
		$input = <<<END
		<b kd="FOREACH:item=list">hoge</b>
END;
		$input2 = <<<END
		<b php="FOREACH(\$list as \$item)">hoge</b>
END;
		$expected = <<<END
		<<block>>
		  :set
		    =
		      item_ctr
		      0
		  :foreach
		    item
		    list
		    <<block>>
		      :set
		        +=
		          item_ctr
		          1
		      :set
		        =
		          item_tgl
		          ?
		            ==
		              %
		                item_ctr
		                2
		              0
		            "even"
		            "odd"
		      :print
		        "<b>"
		      :print
		        "hoge"
		      :print
		        "</b>"

END;
		$this->_test_convert($input, $expected);
		$this->_test_convert($input2, $expected);
	}



	function test_convert_loop1() {
		$input = <<<END
		<b kd="loop:item=list">hoge</b>
END;
		$input2 = <<<END
		<b php="loop(\$list as \$item)">hoge</b>
END;
		$expected = <<<END
		<<block>>
		  :print
		    "<b>"
		  :foreach
		    item
		    list
		    <<block>>
		      :print
		        "hoge"
		  :print
		    "</b>"

END;
		$this->_test_convert($input,  $expected);
		$this->_test_convert($input2, $expected);
	}





	function test_convert_loop2() {
		$input = <<<END
		<b kd="Loop:item=list">hoge</b>
END;
		$input2 = <<<END
		<b php="Loop(\$list as \$item)">hoge</b>
END;
		$expected = <<<END
		<<block>>
		  :print
		    "<b>"
		  :set
		    =
		      item_ctr
		      0
		  :foreach
		    item
		    list
		    <<block>>
		      :set
		        +=
		          item_ctr
		          1
		      :print
		        "hoge"
		  :print
		    "</b>"

END;
		$this->_test_convert($input,  $expected);
		$this->_test_convert($input2, $expected);
	}




	function test_convert_loop3() {
		$input = <<<END
		<b kd="LOOP:item=list">hoge</b>
END;
		$input2 = <<<END
		<b php="LOOP(\$list as \$item)">hoge</b>
END;
		$expected = <<<END
		<<block>>
		  :print
		    "<b>"
		  :set
		    =
		      item_ctr
		      0
		  :foreach
		    item
		    list
		    <<block>>
		      :set
		        +=
		          item_ctr
		          1
		      :set
		        =
		          item_tgl
		          ?
		            ==
		              %
		                item_ctr
		                2
		              0
		            "even"
		            "odd"
		      :print
		        "hoge"
		  :print
		    "</b>"

END;
		$this->_test_convert($input,  $expected);
		$this->_test_convert($input2, $expected);
	}



	function test_convert_span1() {
		$input = <<<END
		<span id="set:var1=value1"/>
		  <span id="set:var2=value2"/>
		<span id="attr:class:var3;set:var3=value3"/>
END;
		$input2 = <<<END
		<span php="\$var1=\$value1"/>
		  <span php="\$var2=\$value2"/>
		<span php="attr('class'=>\$var3);\$var3=\$value3"/>
END;
		$expected = <<<END
		<<block>>
		  :set
		    =
		      var1
		      value1
		  :set
		    =
		      var2
		      value2
		  :set
		    =
		      var3
		      value3
		  :print
		    "<span class=\""
		    var3
		    "\"/>"

END;
		$this->_test_convert($input,  $expected);

		$c = '?';
		$expected2 = <<<END
		<<block>>
		  :set
		    =
		      var1
		      value1
		  :set
		    =
		      var2
		      value2
		  :set
		    =
		      var3
		      value3
		  :print
		    "<span class=\""
		    var3
		    "\"/>"

END;

		$this->_test_convert($input2, $expected2);
	}




	function test_convert_span2() {
		$input = <<<END
		<span kd="foreach:item=list">
		aaa
		</span>
		<span>
		bbb
		</span>
END;
		$input2 = <<<END
		<span php="foreach(\$list as \$item)">
		aaa
		</span>
		<span>
		bbb
		</span>
END;
		$expected = <<<END
		<<block>>
		  :foreach
		    item
		    list
		    <<block>>
		      :print
		        "aaa\\n"
		  :print
		    "<span>\\n"
		  :print
		    "bbb\\n"
		  :print
		    "</span>"

END;
		$this->_test_convert($input,  $expected);
		$this->_test_convert($input2, $expected);
	}



	function test_convert_span3() {		# bug
		$input = <<<END
<span id="value:day" class="holiday">&nbsp;</span>
END;
		$input2 = <<<END
<span php="echo(\$day)" class="holiday">&nbsp;</span>
END;
		$expected = <<<END
<<block>>
  :print
    "<span class=\\"holiday\\">"
  :print
    day
  :print
    "</span>"

END;
		$this->_test_convert($input, $expected);
		$this->_test_convert($input2, $expected);
	}



	function test_convert_span_removed1() {		# bug
		$input = <<<END
		<span id="mark:day">hoge</span>
END;
		$expected = <<<END
		<<block>>
		  :macro
		    'stag_day'
		    <<block>>
		  :macro
		    'cont_day'
		    <<block>>
		      :print
		        "hoge"
		  :macro
		    'etag_day'
		    <<block>>
		  :macro
		    'element_day'
		    <<block>>
		      :expand
		        'stag_day'
		      :expand
		        'cont_day'
		      :expand
		        'etag_day'
		  :expand
		    'element_day'

END;
		$this->_test_convert($input, $expected);
	}




	function test_convert_span_removed2() {		# bug
		$input = <<<END
		<span id="loop:item=list">hoge</span>
END;
		$expected = <<<END
<<block>>
  :foreach
    item
    list
    <<block>>
      :print
        "hoge"

END;
		$this->_test_convert($input, $expected);
	}


	function test_convert_span_removed3() {		# bug
		$input = <<<END
		<span id="value:item">hoge</span>
END;
		$expected = <<<END
<<block>>
  :print
    item

END;
		$this->_test_convert($input, $expected);
	}



	function test_convert_nested1() {
		$input = <<<END
		<div kd="mark:foo">
		 <div id="bar">
		  <div id="baz">
		   test
		  </div>
		 </div>
		</div>
END;
		$expected = <<<END
		<<block>>
		  :macro
		    'stag_baz'
		    <<block>>
		      :print
		        "  <div id=\\"baz\\">\\n"
		  :macro
		    'cont_baz'
		    <<block>>
		      :print
		        "   test\\n"
		  :macro
		    'etag_baz'
		    <<block>>
		      :print
		        "  </div>\\n"
		  :macro
		    'element_baz'
		    <<block>>
		      :expand
		        'stag_baz'
		      :expand
		        'cont_baz'
		      :expand
		        'etag_baz'
		  :macro
		    'stag_bar'
		    <<block>>
		      :print
		        " <div id=\\"bar\\">\\n"
		  :macro
		    'cont_bar'
		    <<block>>
		      :expand
		        'element_baz'
		  :macro
		    'etag_bar'
		    <<block>>
		      :print
		        " </div>\\n"
		  :macro
		    'element_bar'
		    <<block>>
		      :expand
		        'stag_bar'
		      :expand
		        'cont_bar'
		      :expand
		        'etag_bar'
		  :macro
		    'stag_foo'
		    <<block>>
		      :print
		        "<div>\\n"
		  :macro
		    'cont_foo'
		    <<block>>
		      :expand
		        'element_bar'
		  :macro
		    'etag_foo'
		    <<block>>
		      :print
		        "</div>"
		  :macro
		    'element_foo'
		    <<block>>
		      :expand
		        'stag_foo'
		      :expand
		        'cont_foo'
		      :expand
		        'etag_foo'
		  :expand
		    'element_foo'

END;
		$this->_test_convert($input, $expected);
	}



	function test_convert_nested2() {
		$input = <<<END
		<div kd="mark:foo">
		 <div class="bar">
		  <div>
		   test
		  </div>
		 </div>
		</div>
END;
		$expected = <<<END
		<<block>>
		  :macro
		    'stag_foo'
		    <<block>>
		      :print
		        "<div>\\n"
		  :macro
		    'cont_foo'
		    <<block>>
		      :print
		        " <div class=\\"bar\">\\n"
		      :print
		        "  <div>\\n"
		      :print
		        "   test\\n"
		      :print
		        "  </div>\\n"
		      :print
		        " </div>\\n"
		  :macro
		    'etag_foo'
		    <<block>>
		      :print
		        "</div>"
		  :macro
		    'element_foo'
		    <<block>>
		      :expand
		        'stag_foo'
		      :expand
		        'cont_foo'
		      :expand
		        'etag_foo'
		  :expand
		    'element_foo'

END;
		$this->_test_convert($input, $expected);
	}



	function test_convert_practice1() {
		$input = <<<END
		<table>
		  <span id="set:ctr=0"/>
		  <tbody id="loop:user:user_list">
		    <span id="set:ctr+=1"/>
		    <tr class="odd" id="attr:class:klass;set:klass=user_ctr%2==0?'even':'odd'">
		      <td id="value:user['name']">Foo</td>
		      <td id="value:user['mail']">foo@mail.org</td>
		    </tr>
		    <tr class="even" id="dummy:d1">
		      <td>Bar</td>
		      <td>bar@mail.com</td>
		    </tr>
		  </tbody>
		</table>
END;

		$input2 = <<<END
		<table>
		  <span php="\$ctr=0"/>
		  <tbody php="loop(\$user_list as \$user)">
		    <span php="\$ctr+=1"/>
		    <tr class="odd" php="attr('class'=>\$klass);\$klass=\$user_ctr%2==0?'even':'odd'">
		      <td php="echo(\$user['name'])">Foo</td>
		      <td php="echo(\$user['mail'])">foo@mail.org</td>
		    </tr>
		    <tr class="even" php="dummy(d1)">
		      <td>Bar</td>
		      <td>bar@mail.com</td>
		    </tr>
		  </tbody>
		</table>
END;

		$expected = <<<END
		<<block>>
		  :print
		    "<table>\\n"
		  :set
		    =
		      ctr
		      0
		  :print
		    "  <tbody>\\n"
		  :foreach
		    user
		    user_list
		    <<block>>
		      :set
		        +=
		          ctr
		          1
		      :set
		        =
		          klass
		          ?
		            ==
		              %
		                user_ctr
		                2
		              0
		            "even"
		            "odd"
		      :print
		        "    <tr class=\\""
		        klass
		        "\\">\\n"
		      :print
		        "      <td>"
		      :print
		        []
		          user
		          "name"
		      :print
		        "</td>\\n"
		      :print
		        "      <td>"
		      :print
		        []
		          user
		          "mail"
		      :print
		        "</td>\\n"
		      :print
		        "    </tr>\\n"
		  :print
		    "  </tbody>\\n"
		  :print
		    "</table>"

END;
		$this->_test_convert($input,  $expected);

		$expected2 = <<<END
		<<block>>
		  :print
		    "<table>\\n"
		  :set
		    =
		      ctr
		      0
		  :print
		    "  <tbody>\\n"
		  :foreach
		    user
		    user_list
		    <<block>>
		      :set
		        +=
		          ctr
		          1
		      :set
		        =
		          klass
		          ?
		            ==
		              %
		                user_ctr
		                2
		              0
		            "even"
		            "odd"
		      :print
		        "    <tr class=\""
		        klass
		        "\">\\n"
		      :print
		        "      <td>"
		      :print
		        []
		          user
		          "name"
		      :print
		        "</td>\\n"
		      :print
		        "      <td>"
		      :print
		        []
		          user
		          "mail"
		      :print
		        "</td>\\n"
		      :print
		        "    </tr>\\n"
		  :print
		    "  </tbody>\\n"
		  :print
		    "</table>"

END;

		$this->_test_convert($input2, $expected2);
	}

}


###
### execute test
###
//if ($argv[0] == 'KwartzConverterTest.php') {
	$suite = new PHPUnit_TestSuite('KwartzConverterTest');
	$result = PHPUnit::run($suite);
	//echo $result->toHTML();
	echo $result->toString();
//}
?>
