<?php

###
### KwartzTranslatorTest.php
###

require_once('PHPUnit.php');
require_once('Kwartz/KwartzTranslator.php');
require_once('Kwartz/KwartzErubyTranslator.php');
require_once('Kwartz/KwartzJspTranslator.php');
require_once('Kwartz/KwartzParser.php');
require_once('Kwartz/KwartzUtility.php');

class KwartzTranslatorTest extends PHPUnit_TestCase {

	function __construct($name) {
		$this->PHPUnit_TestCase($name);
	}


	function _test($input, $expected, $lang, $flag_test=true, $flag_escape=FALSE, $toppings=NULL) {
		$input    = preg_replace('/^\t\t/m',  '',  $input);
		$input    = preg_replace('/^\n/',     '',  $input);
		$expected = preg_replace('/^\t\t/m',  '',  $expected);
		$expected = preg_replace('/^\n/',     '',  $expected);
		$parser  = new KwartzParser($input, $toppings);
		$block   = $parser->parse();
		if ($toppings == NULL) {
			$toppings = array();
		}
		$toppings['indent_width'] = 2;
		if ($lang == 'php') {
			$translator = new KwartzPhpTranslator($block, $flag_escape, $toppings);
		} elseif ($lang == 'eruby') {
			$translator = new KwartzErubyTranslator($block, $flag_escape, $toppings);
		} elseif ($lang == 'jsp') {
			$translator = new KwartzJspTranslator($block, $flag_escape, $toppings);
		} else {
			assert(false);
		}
		$code = $translator->translate();
		$actual = $code;
		if ($flag_test) {
			$this->assertEquals($expected, $actual);
		}
		//if ($expected != $actual) {
		//	echo "*** debug: ---\n", kwartz_inspect_str($expected), "\n----\n";
		//	echo "*** debug: ---\n", kwartz_inspect_str($actual), "\n----\n";
		//}
		return $translator;
	}
	
	function _test_escape($input, $expected, $lang, $flag_test=TRUE, $flag_escape=TRUE) {
		return $this->_test($input, $expected, $lang, $flag_test, $flag_escape);
	}

	function _test_php($input, $expected, $flag_test=true) {
		$this->_test($input, $expected, 'php', $flag_test);
	}

	function _test_eruby($input, $expected, $flag_test=true) {
		$this->_test($input, $expected, 'eruby', $flag_test);
	}

	function _test_jsp($input, $expected, $flag_test=true) {
		$this->_test($input, $expected, 'jsp', $flag_test);
	}


	const input_array1 = '
		:print(var, array[0], hash1[\'key1\'], hash2[:key2], "\n")
		';
#	const input_array1 = ":print(var, array[0], hash1['key1'], hash2[:key2])";
	function test_php_array1() {
		$expected = '
		<?php echo $var; ?><?php echo $array[0]; ?><?php echo $hash1["key1"]; ?><?php echo $hash2[\'key2\']; ?>
		';
		$this->_test_php(KwartzTranslatorTest::input_array1, $expected);
	}
	
	function test_eruby_array1() {
		$expected = '
		<%= var %><%= array[0] %><%= hash1["key1"] %><%= hash2[:key2] %>
		';
		$this->_test_eruby(KwartzTranslatorTest::input_array1, $expected);
	}

	function test_jsp_array1() {
		$expected = '
		<c:out value="${var}" escapeXml="false"/><c:out value="${array[0]}" escapeXml="false"/><c:out value="${hash1[\'key1\']}" escapeXml="false"/><c:out value="${hash2[\'key2\']}" escapeXml="false"/>
		';
		$this->_test_jsp(KwartzTranslatorTest::input_array1, $expected);
	}



	const input_arith1 = '
	:print(- (x+y)*(x-y) % z)
';
	function test_php_arith1() {
		$expected = '
		<?php echo -($x + $y) * ($x - $y) % $z; ?>';
		$this->_test_php(KwartzTranslatorTest::input_arith1, $expected);
	}
	function test_eruby_arith1() {
		$expected = '
		<%= -(x + y) * (x - y) % z %>';
		$this->_test_eruby(KwartzTranslatorTest::input_arith1, $expected);
	}
	function test_jsp_arith1() {
		$expected = '<c:out value="${-(x + y) * (x - y) % z}" escapeXml="false"/>';
		$this->_test_jsp(KwartzTranslatorTest::input_arith1, $expected);
	}



	const input_condop1 = '
		:set(hash[:key] = x > y ? x+1:y-1)
	';

	function test_php_condop1() {
		$expected = 
		'<?php $hash[\'key\'] = $x > $y ? $x + 1 : $y - 1; ?>
		';
		$this->_test_php(KwartzTranslatorTest::input_condop1, $expected);
	}
	
	function test_eruby_condop1() {
		$expected = 
		'<% hash[:key] = x > y ? x + 1 : y - 1 %>
		';
		$this->_test_eruby(KwartzTranslatorTest::input_condop1, $expected);
	}

	function test_jsp_condop1() {
		$expected = '
		<c:choose>
		  <c:when test="${x > y}">
		    <c:set var="hash[\'key\']" value="${x + 1}"/>
		  </c:when>
		  <c:otherwise>
		    <c:set var="hash[\'key\']" value="${y - 1}"/>
		  </c:otherwise>
		</c:choose>
		';
		$this->_test_jsp(KwartzTranslatorTest::input_condop1, $expected);
	}



	const input_arith2 = '
		:print(- (x+y)*(x-y) % z, "\n")
		:set(a[i+1] = a[i] > 0 ? (x-1)*2 : y*2)
		';

	function test_php_arith2() {
		$expected = '
		<?php echo -($x + $y) * ($x - $y) % $z; ?>
		<?php $a[$i + 1] = $a[$i] > 0 ? ($x - 1) * 2 : $y * 2; ?>
		';
		$this->_test_php(KwartzTranslatorTest::input_arith2, $expected);
	}

	function test_eruby_arith2() {
		$expected = '
		<%= -(x + y) * (x - y) % z %>
		<% a[i + 1] = a[i] > 0 ? (x - 1) * 2 : y * 2 %>
		';
		$this->_test_eruby(KwartzTranslatorTest::input_arith2, $expected);
	}
	function test_jsp_arigh3() {
		$expected = '
		<c:out value="${-(x + y) * (x - y) % z}" escapeXml="false"/>
		<c:choose>
		  <c:when test="${a[i] > 0}">
		    <c:set var="a[i + 1]" value="${(x - 1) * 2}"/>
		  </c:when>
		  <c:otherwise>
		    <c:set var="a[i + 1]" value="${y * 2}"/>
		  </c:otherwise>
		</c:choose>
		';
		$this->_test_jsp(KwartzTranslatorTest::input_arith2, $expected);
	}



	const input_property1 = '
		:print(obj.child.name)
		:print("\n")
	';
	function test_php_property1() {
		$expected = '
		<?php echo $obj->child->name; ?>
		';
		$this->_test_php(KwartzTranslatorTest::input_property1, $expected);
	}

	function test_eruby_property1() {
		$expected = '
		<%= obj.child.name %>
		';
		$this->_test_eruby(KwartzTranslatorTest::input_property1, $expected);
	}

	function test_jsp_property1() {
		$expected = '
		<c:out value="${obj.child.name}" escapeXml="false"/>
		';
		$this->_test_jsp(KwartzTranslatorTest::input_property1, $expected);
	}



	const input_property2 = '
		echo $obj->child()->name(), "\n";
		';
	function test_php_property2() {
		$expected = '
		<?php echo $obj->child()->name(); ?>
		';
		$this->_test_php(KwartzTranslatorTest::input_property2, $expected);
	}

	function test_eruby_property2() {
		$expected = '
		<%= obj.child.name %>
		';
		$this->_test_eruby(KwartzTranslatorTest::input_property2, $expected);
	}

	function test_jsp_property2() {
		$expected = '
		<c:out value="${obj.child.name}" escapeXml="false"/>
		';
		$this->_test_jsp(KwartzTranslatorTest::input_property2, $expected);
	}



	const input_property3 = '
		$v = $obj->prop1($a[0].$b[0], $x/$y)->prop2()->prop3();
		';
	function test_php_property3() {
		$expected = '
		<?php $v = $obj->prop1($a[0] . $b[0], $x / $y)->prop2()->prop3(); ?>
		';
		$this->_test_php(KwartzTranslatorTest::input_property3, $expected);
	}

	function test_eruby_property3() {
		$expected = '
		<% v = obj.prop1(a[0] + b[0], x / y).prop2.prop3 %>
		';
		$this->_test_eruby(KwartzTranslatorTest::input_property3, $expected);
	}

	function test_jsp_property3() {
		$expected = '';
		try {
			$this->_test_jsp(KwartzTranslatorTest::input_property3, $expected);
		} catch (KwartzTranslationError $ex) {
			# OK
			return;
		}
		$this->fail("KwartzTranslationError should happen.");
	}



	const input_function1 = '
		:print(func(x, y, z))
		:print("\n")
	';

	function test_php_function1() {
		$expected = '
		<?php echo func($x, $y, $z); ?>
		';
		$this->_test_php(KwartzTranslatorTest::input_function1, $expected);
	}

	function test_eruby_function1() {
		$expected = '
		<%= func(x, y, z) %>
		';
		$this->_test_eruby(KwartzTranslatorTest::input_function1, $expected);
	}

	function test_jsp_function1() {
		$expected = '
		';
		try {
			$this->_test_jsp(KwartzTranslatorTest::input_function1, $expected);
		} catch (KwartzTranslationError $ex) {
			# OK
			return;
		}
		$this->fail("KwartzTranslationError should happen but not.");
	}



	const input_boolean1 = '
		:set(x = (a || b) && c ? true : false)
	';
	function test_php_boolean1() {
		$expected = '
		<?php $x = ($a || $b) && $c ? TRUE : FALSE; ?>
		';
		$this->_test_php(KwartzTranslatorTest::input_boolean1, $expected);
	}
	
	function test_eruby_boolean1() {
		$expected = '
		<% x = (a || b) && c ? true : false %>
		';
		$this->_test_eruby(KwartzTranslatorTest::input_boolean1, $expected);
	}

	function test_jsp_boolean1() {
		$expected = '
		<c:choose>
		  <c:when test="${(a or b) and c}">
		    <c:set var="x" value="${true}"/>
		  </c:when>
		  <c:otherwise>
		    <c:set var="x" value="${false}"/>
		  </c:otherwise>
		</c:choose>
		';
		$this->_test_jsp(KwartzTranslatorTest::input_boolean1, $expected);
	}



	const input_null1 = '
		:print(x == null ? "" : x)
		:print("\n")
	';
	function test_php_null1() {
		$expected = '
		<?php echo $x == NULL ? "" : $x; ?>
		';
		$this->_test_php(KwartzTranslatorTest::input_null1, $expected);
	}
	
	function test_eruby_null1() {
		$expected = '
		<%= x == nil ? "" : x %>
		';
		$this->_test_eruby(KwartzTranslatorTest::input_null1, $expected);
	}

	function test_jsp_null1() {
		$expected = 
		'<c:choose>
		  <c:when test="${x == null}">
		  </c:when>
		  <c:otherwise>
		<c:out value="${x}" escapeXml="false"/></c:otherwise>
		</c:choose>
		
		';
		$this->_test_jsp(KwartzTranslatorTest::input_null1, $expected, true);
	}



	const input_print1 = '
		:print("hoge\\n")
	';
	function test_php_print1() {
		$expected = '
		hoge
		';
		$this->_test_php(KwartzTranslatorTest::input_print1, $expected);
	}
	

	function test_eruby_print1() {
		$expected = '
		hoge
		';
		$this->_test_eruby(KwartzTranslatorTest::input_print1, $expected);
	}

	function test_jsp_print1() {
		$expected = '
		hoge
		';
		$this->_test_jsp(KwartzTranslatorTest::input_print1, $expected);
	}



	const input_print2 = '
		:print("aaa", x+y, hash[\'key\'])
		:print("\n")
	';
	function test_php_print2() {
		$expected = '
		aaa<?php echo $x + $y; ?><?php echo $hash["key"]; ?>
		';
		$this->_test_php(KwartzTranslatorTest::input_print2, $expected);
	}

	function test_eruby_print2() {
		$expected = '
		aaa<%= x + y %><%= hash["key"] %>
		';
		$this->_test_eruby(KwartzTranslatorTest::input_print2, $expected);
	}

	function test_jsp_print2() {
		$expected = '
		aaa<c:out value="${x + y}" escapeXml="false"/><c:out value="${hash[\'key\']}" escapeXml="false"/>
		';
		$this->_test_jsp(KwartzTranslatorTest::input_print2, $expected);
	}



	const input_set1 = '
		:set(x=1)
	';

	function test_php_set1() {
		$expected = '
		<?php $x = 1; ?>
		';
		$this->_test_php(KwartzTranslatorTest::input_set1, $expected);
	}
	
	function test_eruby_set1() {
		$expected = '
		<% x = 1 %>
		';
		$this->_test_eruby(KwartzTranslatorTest::input_set1, $expected);
	}

	function test_jsp_set1() {
		$expected = '
		<c:set var="x" value="1"/>
		';
		$this->_test_jsp(KwartzTranslatorTest::input_set1, $expected);
	}



	const input_set2 = '
		:set(hash[:key] *= a+b)
	';

	function test_php_set2() {
		$expected = '
		<?php $hash[\'key\'] *= $a + $b; ?>
		';
		$this->_test_php(KwartzTranslatorTest::input_set2, $expected);
	}
	
	function test_eruby_set2() {
		$expected = '
		<% hash[:key] *= a + b %>
		';
		$this->_test_eruby(KwartzTranslatorTest::input_set2, $expected);
	}

	function test_jsp_set2() {		## normalize
		$expected = '
		<c:set var="hash[\'key\']" value="${hash[\'key\'] * (a + b)}"/>
		';
		$this->_test_jsp(KwartzTranslatorTest::input_set2, $expected);
	}



	const input_foreach1 = '
		:foreach(item=list)
		  :print("<td>", item, "</td>\n")
		:end
	';
	function test_php_foreach1() {
		$expected = '
		<?php foreach ($list as $item) { ?>
		<td><?php echo $item; ?></td>
		<?php } ?>
		';
		$this->_test_php(KwartzTranslatorTest::input_foreach1, $expected);
	}
	
	function test_eruby_foreach1() {
		$expected = '
		<% for item in list do %>
		<td><%= item %></td>
		<% end %>
		';
		$this->_test_eruby(KwartzTranslatorTest::input_foreach1, $expected);
	}

	function test_jsp_foreach1() {
		$expected =
		'<c:forEach var="item" items="${list}">
		<td><c:out value="${item}" escapeXml="false"/></td>
		</c:forEach>
		';
		$this->_test_jsp(KwartzTranslatorTest::input_foreach1, $expected);
	}



	const input_while1 = '
		:while(x>0)
		  :print(x)
		:end
	';

	function test_php_while1() {
		$expected = '
		<?php while ($x > 0) { ?>
		<?php echo $x; ?><?php } ?>
		';
		$this->_test_php(KwartzTranslatorTest::input_while1, $expected);
	}

	function test_eruby_while1() {
		$expected = '
		<% while x > 0 do %>
		<%= x %><% end %>
		';
		$this->_test_eruby(KwartzTranslatorTest::input_while1, $expected);
	}
	
	function test_jsp_while1() {
		$expected = NULL;
		try {
			$this->_test_jsp(KwartzTranslatorTest::input_while1, $expected);
		} catch (KwartzTranslationError $ex) {
			# OK
			return;
		}
		$this->fail("KwartzTranslationError should happen.");
	}



	const input_if1 = '
		:if(cond1)
		  :print("cond1\n")
		:end
		';
	function test_php_if1() {
		$expected = '
		<?php if ($cond1) { ?>
		cond1
		<?php } ?>
		';
		$this->_test_php(KwartzTranslatorTest::input_if1, $expected);
	}

	function test_eruby_if1() {
		$expected = '
		<% if cond1 then %>
		cond1
		<% end %>
		';
		$this->_test_eruby(KwartzTranslatorTest::input_if1, $expected);
	}

	function test_jsp_if1() {
		$expected = 
		'<c:if test="${cond1}">
		cond1
		</c:if>
		';
		$this->_test_jsp(KwartzTranslatorTest::input_if1, $expected);
	}



	const input_if2 = '
		:if(cond1)
		  :print("aaa\n")
		:else
		  :print("bbb\n")
		:end
		';

	function test_php_if2() {
		$expected = '
		<?php if ($cond1) { ?>
		aaa
		<?php } else { ?>
		bbb
		<?php } ?>
		';
		$this->_test_php(KwartzTranslatorTest::input_if2, $expected);
	}

	function test_eruby_if2() {
		$expected = '
		<% if cond1 then %>
		aaa
		<% else %>
		bbb
		<% end %>
		';
		$this->_test_eruby(KwartzTranslatorTest::input_if2, $expected);
	}

	function test_jsp_if2() {
		$expected = 
		'<c:choose>
		  <c:when test="${cond1}">
		aaa
		  </c:when>
		  <c:otherwise>
		bbb
		  </c:otherwise>
		</c:choose>
		';
		$this->_test_jsp(KwartzTranslatorTest::input_if2, $expected);
	}


	const input_if3 = '
		:if(cond1)
		  :print("aaa\n")
		:elseif(cond2)
		  :print("bbb\n")
		:elseif(cond3)
		  :print("ccc\n")
		:else
		  :print("ddd\n")
		:end
	';
	function test_php_if3() {
		$expected = '
		<?php if ($cond1) { ?>
		aaa
		<?php } elseif ($cond2) { ?>
		bbb
		<?php } elseif ($cond3) { ?>
		ccc
		<?php } else { ?>
		ddd
		<?php } ?>
		';
		$this->_test_php(KwartzTranslatorTest::input_if3, $expected);
	}

	function test_eruby_if3() {
		$expected = '
		<% if cond1 then %>
		aaa
		<% elsif cond2 then %>
		bbb
		<% elsif cond3 then %>
		ccc
		<% else %>
		ddd
		<% end %>
		';
		$this->_test_eruby(KwartzTranslatorTest::input_if3, $expected);
	}

	function test_jsp_if3() {
		$expected = '
		<c:choose>
		  <c:when test="${cond1}">
		aaa
		  </c:when>
		  <c:when test="${cond2}">
		bbb
		  </c:when>
		  <c:when test="${cond3}">
		ccc
		  </c:when>
		  <c:otherwise>
		ddd
		  </c:otherwise>
		</c:choose>
		';
		$this->_test_jsp(KwartzTranslatorTest::input_if3, $expected);
	}


	const input_macro1 = '
		:expand(foo)
		:macro(foo)
		  :print("OK\n")
		:end
	';

	function test_php_macro1() {
		$expected = '
		OK
		';
		$this->_test_php(KwartzTranslatorTest::input_macro1, $expected);
	}

	function test_eruby_macro1() {
		$expected = '
		OK
		';
		$this->_test_eruby(KwartzTranslatorTest::input_macro1, $expected);
	}

	function test_jsp_macro1() {
		$expected = '
		OK
		';
		$this->_test_jsp(KwartzTranslatorTest::input_macro1, $expected);
	}



	const input_macro2 = '
		:expand(element_foo)
		:macro(stag_foo)
		  :print("<span>")
		:end
		:macro(cont_foo)
		  :print(foo)
		:end
		:macro(etag_foo)
		  :print("</span>\n")
		:end
		:macro(element_foo)
		  :expand(stag_foo)
		  :expand(cont_foo)
		  :expand(etag_foo)
		:end
		:macro(element_foo)
		  :foreach(foo=bar)
		    :expand(stag_foo)
		    :expand(cont_foo)
		    :expand(etag_foo)
		  :end
		:end
	';

	function test_php_macro2() {
		$expected = '
		<?php foreach ($bar as $foo) { ?>
		<span><?php echo $foo; ?></span>
		<?php } ?>
		';
		$this->_test_php(KwartzTranslatorTest::input_macro2, $expected);
	}

	function test_eruby_macro2() {
		$expected = '
		<% for foo in bar do %>
		<span><%= foo %></span>
		<% end %>
		';
		$this->_test_eruby(KwartzTranslatorTest::input_macro2, $expected);
	}

	function test_jsp_macro2() {
		$expected = '
		<c:forEach var="foo" items="${bar}">
		<span><c:out value="${foo}" escapeXml="false"/></span>
		</c:forEach>
		';
		$this->_test_jsp(KwartzTranslatorTest::input_macro2, $expected);
	}



	const input_rawcode1 = '
		::: <?php foreach (\$hash as \$key=>\$value) { ?>
		:print(key, " = ", value, "\\n")
		::: <?php } ?>
	';

	function test_php_rawcode1() {
		$input = '
		::: <?php foreach ($hash as $key=>$value) { ?>
		:print(key, " = ", value, "\\n")
		::: <?php } ?>
		';
		$expected = '
		 <?php foreach ($hash as $key=>$value) { ?>
		<?php echo $key; ?> = <?php echo $value; ?>
		 <?php } ?>
		';
		//$this->_test_php(KwartzTranslatorTest::input_rawcode1, $expected);
		$this->_test_php($input, $expected);
	}
	
	function test_eruby_rawcode1() {
		$input = '
		:::% foreach key,value in hash do
		:print(key, " = ", value, "\\n")
		:::% end
		';
		$expected = '
		% foreach key,value in hash do
		<%= key %> = <%= value %>
		% end
		';
		//$this->_test_eruby(KwartzTranslatorTest::input_rawcode1, $expected);
		$this->_test_eruby($input, $expected);
	}



	const input_rawcode2 = '
		  <?php foreach ($hash as $key=>$value) { ?>
		    <?= $key ?> = <?= $value ?>
		  <?php } ?>
	';

	function test_php_rawcode2() {
		$input = '
		  <?php foreach ($hash as $key=>$value) { ?>
		    <?= $key ?> = <?= $value ?>
		  <?php } ?>
		';
		$expected = '
		<?php foreach ($hash as $key=>$value) { ?>
		<?= $key ?> = <?= $value ?>
		<?php } ?>
		';
		$this->_test_php($input, $expected);
	}

	function test_eruby_rawcode2() {
		$input = '
		  <% for key,value in hash do %>
		    <%= key %> = <%= value %>
		  <% end %>
		';
		$expected = '
		<% for key,value in hash do %>
		<%= key %> = <%= value %>
		<% end %>
		';
		//$this->_test_eruby(KwartzTranslatorTest::input_rawcode2, $expected);
		$this->_test_eruby($input, $expected);
	}



	const input_indent1 = '
		:print("<table>\n")
		:set(ctr = 0)
		:foreach(item = list)
		  :set(ctr += 1)
		  :if(ctr % 2 == 0)
		    :set(klass=\'even\')
		  :elseif(ctr % 2 == 1)
		    :set(klass=\'odd\')
		  :else
		    :set(klass=\'never\')
		  :end
		  :print("  <tr class=\"", klass, "\">\n")
		  :print("    <td>", item, "</td>\n")
		  :print("  </tr>\n")
		:end
		:print("</table>\n")
		';

	function test_php_indent1() {
		$expected = '
		<table>
		<?php $ctr = 0; ?>
		<?php foreach ($list as $item) { ?>
		  <?php $ctr += 1; ?>
		  <?php if ($ctr % 2 == 0) { ?>
		    <?php $klass = "even"; ?>
		  <?php } elseif ($ctr % 2 == 1) { ?>
		    <?php $klass = "odd"; ?>
		  <?php } else { ?>
		    <?php $klass = "never"; ?>
		  <?php } ?>
		  <tr class="<?php echo $klass; ?>">
		    <td><?php echo $item; ?></td>
		  </tr>
		<?php } ?>
		</table>
		';
		$this->_test_php(KwartzTranslatorTest::input_indent1, $expected);
	}

	function test_eruby_indent1() {
		$expected = '
		<table>
		<% ctr = 0 %>
		<% for item in list do %>
		  <% ctr += 1 %>
		  <% if ctr % 2 == 0 then %>
		    <% klass = "even" %>
		  <% elsif ctr % 2 == 1 then %>
		    <% klass = "odd" %>
		  <% else %>
		    <% klass = "never" %>
		  <% end %>
		  <tr class="<%= klass %>">
		    <td><%= item %></td>
		  </tr>
		<% end %>
		</table>
		';
		$this->_test_eruby(KwartzTranslatorTest::input_indent1, $expected);
	}


	function test_jsp_indent1() {
		$expected = '
		<table>
		<c:set var="ctr" value="0"/>
		<c:forEach var="item" items="${list}">
		  <c:set var="ctr" value="${ctr + 1}"/>
		  <c:choose>
		    <c:when test="${ctr % 2 == 0}">
		      <c:set var="klass" value="even"/>
		    </c:when>
		    <c:when test="${ctr % 2 == 1}">
		      <c:set var="klass" value="odd"/>
		    </c:when>
		    <c:otherwise>
		      <c:set var="klass" value="never"/>
		    </c:otherwise>
		  </c:choose>
		  <tr class="<c:out value="${klass}" escapeXml="false"/>">
		    <td><c:out value="${item}" escapeXml="false"/></td>
		  </tr>
		</c:forEach>
		</table>
		';
		$this->_test_jsp(KwartzTranslatorTest::input_indent1, $expected);
	}



	const input_escape1 = '
	:print(data, "\n")
	:print("aaa", array[i], x+y, "bbb\n");
	:print(x > y ? x : y, "\n")
	';

	function test_php_escape1() {
		$expected = '
		<?php echo htmlspecialchars($data); ?>
		aaa<?php echo htmlspecialchars($array[$i]); ?><?php echo htmlspecialchars($x + $y); ?>bbb
		<?php echo htmlspecialchars($x > $y ? $x : $y); ?>
		';
		$this->_test_escape(KwartzTranslatorTest::input_escape1, $expected, 'php');
	}

	function test_eruby_escape1() {
		$expected = '
		<%= CGI.escapeHTML((data).to_s) %>
		aaa<%= CGI.escapeHTML((array[i]).to_s) %><%= CGI.escapeHTML((x + y).to_s) %>bbb
		<%= CGI.escapeHTML((x > y ? x : y).to_s) %>
		';
		$this->_test_escape(KwartzTranslatorTest::input_escape1, $expected, 'eruby');
	}

	function test_jsp_escape1() {
		$expected = '
		<c:out value="${data}"/>
		aaa<c:out value="${array[i]}"/><c:out value="${x + y}"/>bbb
		<c:choose>
		  <c:when test="${x > y}">
		<c:out value="${x}"/>
		  </c:when>
		  <c:otherwise>
		<c:out value="${y}"/>
		  </c:otherwise>
		</c:choose>
		';
		$this->_test_escape(KwartzTranslatorTest::input_escape1, $expected, 'jsp');
	}



	const input_escape2 = '
	:print(data, "\n")
	:print("aaa", E(array[i]), X(x+y), "bbb\n");
	:print(x > y ? x : y, "\n")
	';

	function test_php_escape2() {
		$expected = '
		<?php echo $data; ?>
		aaa<?php echo htmlspecialchars($array[$i]); ?><?php echo $x + $y; ?>bbb
		<?php echo $x > $y ? $x : $y; ?>
		';
		$this->_test(KwartzTranslatorTest::input_escape2, $expected, 'php');
	}

	function test_eruby_escape2() {
		$expected = '
		<%= data %>
		aaa<%= CGI.escapeHTML((array[i]).to_s) %><%= x + y %>bbb
		<%= x > y ? x : y %>
		';
		$this->_test(KwartzTranslatorTest::input_escape2, $expected, 'eruby');
	}

	function test_jsp_escape2() {
		$expected = '
		<c:out value="${data}" escapeXml="false"/>
		aaa<c:out value="${array[i]}"/><c:out value="${x + y}" escapeXml="false"/>bbb
		<c:choose>
		  <c:when test="${x > y}">
		<c:out value="${x}" escapeXml="false"/>
		  </c:when>
		  <c:otherwise>
		<c:out value="${y}" escapeXml="false"/>
		  </c:otherwise>
		</c:choose>
		';
		$this->_test(KwartzTranslatorTest::input_escape2, $expected, 'jsp');
	}



	const input_escape3 = '
	:print(data, "\n")
	:print("aaa", E(array[i]), X(x+y), "bbb\n");
	:print(x > y ? x : y, "\n")
	';

	function test_php_escape3() {
		$expected = '
		<?php echo htmlspecialchars($data); ?>
		aaa<?php echo htmlspecialchars($array[$i]); ?><?php echo $x + $y; ?>bbb
		<?php echo htmlspecialchars($x > $y ? $x : $y); ?>
		';
		$this->_test_escape(KwartzTranslatorTest::input_escape3, $expected, 'php');
	}

	function test_eruby_escape3() {
		$expected = '
		<%= CGI.escapeHTML((data).to_s) %>
		aaa<%= CGI.escapeHTML((array[i]).to_s) %><%= x + y %>bbb
		<%= CGI.escapeHTML((x > y ? x : y).to_s) %>
		';
		$this->_test_escape(KwartzTranslatorTest::input_escape3, $expected, 'eruby');
	}

	function test_jsp_escape3() {
		$expected = '
		<c:out value="${data}"/>
		aaa<c:out value="${array[i]}"/><c:out value="${x + y}" escapeXml="false"/>bbb
		<c:choose>
		  <c:when test="${x > y}">
		<c:out value="${x}"/>
		  </c:when>
		  <c:otherwise>
		<c:out value="${y}"/>
		  </c:otherwise>
		</c:choose>
		';
		$this->_test_escape(KwartzTranslatorTest::input_escape3, $expected, 'jsp');
	}

	const input_escape4 = '
		echo $a > $b ? $a : $b, "\n", $x > $y ? true : false, "\n";
		echo "<input type=\"checkbox\"", $gender == "M" ? " checked=\"checked\"" : "", "/>\n";
		echo "<input type=\"checkbox\"", E($gender == "M" ? " checked=\"checked\"" : ""), "/>\n";
		echo "<input type=\"checkbox\"", X($gender == "M" ? " checked=\"checked\"" : ""), "/>\n";
	';
	//const input_escape4 = '
	//#{a>b?a:b}#
	//#{x>y?true:false}#
	//<input type="checkbox" kd="append:@C(gender==\'M\')"/>
	//<input type="checkbox" kd="Append:@C(gender==\'M\')"/>
	//<input type="checkbox" kd="APPEND:@C(gender==\'M\')"/>
	//';

	function test_php_escape4() {
		$expected = '
		<?php echo htmlspecialchars($a > $b ? $a : $b); ?>
		<?php echo $x > $y ? TRUE : FALSE; ?>
		<input type="checkbox"<?php echo $gender == "M" ? " checked=\"checked\"" : ""; ?>/>
		<input type="checkbox"<?php echo htmlspecialchars($gender == "M" ? " checked=\"checked\"" : ""); ?>/>
		<input type="checkbox"<?php echo $gender == "M" ? " checked=\"checked\"" : ""; ?>/>
		';
		$this->_test_escape(KwartzTranslatorTest::input_escape4, $expected, 'php');
	}

	function test_eruby_escape4() {
		$expected = '
		<%= CGI.escapeHTML((a > b ? a : b).to_s) %>
		<%= x > y ? true : false %>
		<input type="checkbox"<%= gender == "M" ? " checked=\"checked\"" : "" %>/>
		<input type="checkbox"<%= CGI.escapeHTML((gender == "M" ? " checked=\"checked\"" : "").to_s) %>/>
		<input type="checkbox"<%= gender == "M" ? " checked=\"checked\"" : "" %>/>
		';
		$this->_test_escape(KwartzTranslatorTest::input_escape4, $expected, 'eruby');
	}

	function test_jsp_escape4() {
		$expected = '
		<c:choose>
		  <c:when test="${a > b}">
		    <c:choose>
		      <c:when test="${x > y}">
		<c:out value="${a}"/>
		<c:out value="${true}" escapeXml="false"/>
		      </c:when>
		      <c:otherwise>
		<c:out value="${a}"/>
		<c:out value="${false}" escapeXml="false"/>
		      </c:otherwise>
		    </c:choose>
		  </c:when>
		  <c:when test="${x > y}">
		<c:out value="${b}"/>
		<c:out value="${true}" escapeXml="false"/>
		  </c:when>
		  <c:otherwise>
		<c:out value="${b}"/>
		<c:out value="${false}" escapeXml="false"/>
		  </c:otherwise>
		</c:choose>
		<c:choose>
		  <c:when test="${gender == \'M\'}">
		<input type="checkbox" checked="checked"/>
		  </c:when>
		  <c:otherwise>
		<input type="checkbox"/>
		  </c:otherwise>
		</c:choose>
		<c:choose>
		  <c:when test="${gender == \'M\'}">
		<input type="checkbox"<c:out value="${\' checked="checked"\'}"/>/>
		  </c:when>
		  <c:otherwise>
		<input type="checkbox"<c:out value="${\'\'}"/>/>
		  </c:otherwise>
		</c:choose>
		<c:choose>
		  <c:when test="${gender == \'M\'}">
		<input type="checkbox"<c:out value="${\' checked="checked"\'}" escapeXml="false"/>/>
		  </c:when>
		  <c:otherwise>
		<input type="checkbox"<c:out value="${\'\'}" escapeXml="false"/>/>
		  </c:otherwise>
		</c:choose>
		';
		$this->_test_escape(KwartzTranslatorTest::input_escape4, $expected, 'jsp');
	}



	const input_empty1 = 
		':set(v = s==empty ? \'checked\' : \'\')
		:print(s!=empty ? "aaa":"bbb", "\n")
		';
	const input_empty1_php = 
		'$v = $s==empty ? "checked" : "";
		 echo $s != empty ? "aaa" : "bbb", "\n";
		';
	function test_empty1_php() {
		$input = KwartzTranslatorTest::input_empty1;
		$expected =
		'<?php $v = ($s == "") ? "checked" : ""; ?>
		<?php echo ($s != "") ? "aaa" : "bbb"; ?>
		';
		$input = KwartzTranslatorTest::input_empty1;
		$this->_test($input, $expected, 'php');
		$input = KwartzTranslatorTest::input_empty1_php;
		$this->_test($input, $expected, 'php');
	}
	function test_empty1_eruby() {
		$expected =
		'<% v = (s == nil || s == "") ? "checked" : "" %>
		<%= (s != nil && s != "") ? "aaa" : "bbb" %>
		';
		$input = KwartzTranslatorTest::input_empty1;
		$this->_test($input, $expected, 'eruby');
		$input = KwartzTranslatorTest::input_empty1_php;
		$this->_test($input, $expected, 'eruby');
	}
	function test_empty1_jsp() {
		$expected =
		'<c:choose>
		  <c:when test="${(empty s)}">
		    <c:set var="v" value="checked"/>
		  </c:when>
		  <c:otherwise>
		    <c:set var="v" value=""/>
		  </c:otherwise>
		</c:choose>
		<c:choose>
		  <c:when test="${!(empty s)}">
		aaa
		  </c:when>
		  <c:otherwise>
		bbb
		  </c:otherwise>
		</c:choose>
		';
		$input = KwartzTranslatorTest::input_empty1;
		$this->_test($input, $expected, 'jsp');
		$input = KwartzTranslatorTest::input_empty1_php;
		$this->_test($input, $expected, 'jsp');
	}


        
	const input_func1 = '
		:set(a = list_new())
		:if (list_empty(a))
		  :print("list_length(a) == ", list_length(a), "\n");
		:end
		
		:set(h = hash_new())
		:if (hash_empty(h))
		  :print("hash_keys(h) == ", hash_keys(h), "\n");
		:end
		
		:set(len = str_length(s))
		:print(str_trim(s), str_tolower(s), str_toupper(s), "\n")
		:if (!str_empty(s))
		  :set(i = str_index(s, "."))
		:end
		:set(slen = str_length(s1 .+ s2))
		';
	function test_php_func1() {
		$expected = '
		<?php $a = (array()); ?>
		<?php if ((!($a) || count($a)==0)) { ?>
		list_length(a) == <?php echo count($a); ?>
		<?php } ?>
		<?php $h = (array()); ?>
		<?php if ((!($h) || count($h)==0)) { ?>
		hash_keys(h) == <?php echo array_keys($h); ?>
		<?php } ?>
		<?php $len = (strlen($s)); ?>
		<?php echo trim($s); ?><?php echo strtolower($s); ?><?php echo strtoupper($s); ?>
		<?php if (!(!$s)) { ?>
		  <?php $i = (strchr($s, ".")); ?>
		<?php } ?>
		<?php $slen = (strlen($s1 . $s2)); ?>
		';
		$this->_test_php(KwartzTranslatorTest::input_func1, $expected);
	}
	function test_eruby_func1() {
		$expected = '
		<% a = ([]) %>
		<% if a.empty? then %>
		list_length(a) == <%= a.length %>
		<% end %>
		<% h = ({}) %>
		<% if hash_empty(h) then %>
		hash_keys(h) == <%= h.keys %>
		<% end %>
		<% len = (s.length) %>
		<%= s.trim %><%= s.downcase %><%= s.upcase %>
		<% if !(s.empty?) then %>
		  <% i = (s.index(".")) %>
		<% end %>
		<% slen = ((s1 + s2).length) %>
		';
		$this->_test_eruby(KwartzTranslatorTest::input_func1, $expected);
	}
	function test_jsp_func1() {
		$expected = '
		';
		try {
			$this->_test_jsp(KwartzTranslatorTest::input_func1, $expected);
			$this->fail("KwartzTranslationError should be happened.");
		} catch (KwartzTranslationError $ex) {
			// ok
		}
	}


}


###
### execute test
###
//if ($argv[0] == 'KwartzTranslatorTest.php') {
	$suite = new PHPUnit_TestSuite('KwartzTranslatorTest');
	$result = PHPUnit::run($suite);
	//echo $result->toHTML();
	echo $result->toString();
//}
?>
