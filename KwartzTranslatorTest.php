<?php

###
### KwartzTranslatorTest.php
###

require_once('PHPUnit.php');
require_once('KwartzTranslator.inc');
require_once('KwartzErubyTranslator.inc');
require_once('KwartzJspTranslator.inc');
require_once('KwartzScanner.inc');
require_once('KwartzParser.inc');

class KwartzTranslatorTest extends PHPUnit_TestCase {

	function __construct($name) {
		$this->PHPUnit_TestCase($name);
	}


	function _test($input, $expected, $lang, $flag_test=TRUE) {
		$input    = preg_replace('/^\t\t/m',  '',  $input);
		$input    = preg_replace('/^\n/',     '',  $input);
		$expected = preg_replace('/^\t\t/m',  '',  $expected);
		$expected = preg_replace('/^\n/',     '',  $expected);
		$scanner = new KwartzScanner($input);
		$parser  = new KwartzParser($scanner);
		$block   = $parser->parse();
		if ($lang == 'php') {
			$translator = new KwartzPhpTranslator($block);
		} elseif ($lang == 'eruby') {
			$translator = new KwartzErubyTranslator($block);
		} elseif ($lang == 'jsp') {
			$translator = new KwartzJspTranslator($block);
		} else {
			assert(false);
		}
		$code = $translator->translate();
		$actual = $code;
		if ($flag_test) {
			$this->assertEquals($expected, $actual);
		}
		return $translator;
	}

	function _test_php($input, $expected, $flag_test=TRUE) {
		$this->_test($input, $expected, 'php', $flag_test);
	}

	function _test_eruby($input, $expected, $flag_test=TRUE) {
		$this->_test($input, $expected, 'eruby', $flag_test);
	}

	function _test_jsp($input, $expected, $flag_test=TRUE) {
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
		<c:choose><c:when test="${x > y}">
		  <c:set var="hash[\'key\']" value="${x + 1}"/>
		</c:when><c:otherwise>
		  <c:set var="hash[\'key\']" value="${y - 1}"/>
		</c:otherwise></c:choose>
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
		<c:choose><c:when test="${a[i] > 0}">
		  <c:set var="a[i + 1]" value="${(x - 1) * 2}"/>
		</c:when><c:otherwise>
		  <c:set var="a[i + 1]" value="${y * 2}"/>
		</c:otherwise></c:choose>
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
		<c:choose><c:when test="${(a or b) and c}">
		  <c:set var="x" value="${true}"/>
		</c:when><c:otherwise>
		  <c:set var="x" value="${false}"/>
		</c:otherwise></c:choose>
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
		$expected = '
		<c:choose><c:when test="${x == null}">
		</c:when><c:otherwise>
		<c:out value="${x}" escapeXml="false"/></c:otherwise></c:choose>

		';
		$this->_test_jsp(KwartzTranslatorTest::input_null1, $expected);
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
		'<c:choose><c:when test="${cond1}">
		cond1
		</c:when></c:choose>
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
		'<c:choose><c:when test="${cond1}">
		aaa
		</c:when><c:otherwise>
		bbb
		</c:otherwise></c:choose>
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
		<c:choose><c:when test="${cond1}">
		aaa
		</c:when><c:when test="${cond2}">
		bbb
		</c:when><c:when test="${cond3}">
		ccc
		</c:when><c:otherwise>
		ddd
		</c:otherwise></c:choose>
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
		:expand(elem_foo)
		:macro(stag_foo)
		  :print("<span>")
		:end
		:macro(cont_foo)
		  :print(foo)
		:end
		:macro(etag_foo)
		  :print("</span>\n")
		:end
		:macro(elem_foo)
		  :expand(stag_foo)
		  :expand(cont_foo)
		  :expand(etag_foo)
		:end
		:macro(elem_foo)
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
		  <c:choose><c:when test="${ctr % 2 == 0}">
		    <c:set var="klass" value="even"/>
		  </c:when><c:when test="${ctr % 2 == 1}">
		    <c:set var="klass" value="odd"/>
		  </c:when><c:otherwise>
		    <c:set var="klass" value="never"/>
		  </c:otherwise></c:choose>
		  <tr class="<c:out value="${klass}" escapeXml="false"/>">
		    <td><c:out value="${item}" escapeXml="false"/></td>
		  </tr>
		</c:forEach>
		</table>
		';
		$this->_test_jsp(KwartzTranslatorTest::input_indent1, $expected);
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