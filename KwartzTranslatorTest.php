<?php

###
### KwartzTranslatorTest.php
###

require_once('PHPUnit.php');
require_once('KwartzTranslator.inc');
require_once('KwartzScanner.inc');
require_once('KwartzParser.inc');

class KwartzTranslatorTest extends PHPUnit_TestCase {

	function __construct($name) {
		$this->PHPUnit_TestCase($name);
	}



	function _test($input, $expected, $lang, $flag_test=TRUE) {
		$input    = preg_replace('/^\t\t/m', '', $input);
		$expected = preg_replace('/^\t\t/m', '', $expected);
		$scanner = new KwartzScanner($input);
		$parser  = new KwartzParser($scanner);
		$block   = $parser->parse();
		if ($lang == 'php') {
			$translator = new KwartzPhpTranslator($block);
		} elseif ($lang == 'eruby') {
			$translator = new KwartzErubyTranslator($block);
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


	const input_array1 = '
		:print(var, array[0], hash1[\'key1\'], hash2[:key2])
';
#	const input_array1 = ":print(var, array[0], hash1['key1'], hash2[:key2])";
	function test_php_array1() {
		$expected = <<<END
		<?php echo \$var; ?><?php echo \$array[0]; ?><?php echo \$hash1["key1"]; ?><?php echo \$hash2['key2']; ?>
END;
		$this->_test_php(KwartzTranslatorTest::input_array1, $expected);
	}
	
	function test_eruby_array1() {
		$expected = <<<END
<%= var %><%= array[0] %><%= hash1["key1"] %><%= hash2[:key2] %>
END;
		$this->_test_eruby(KwartzTranslatorTest::input_array1, $expected);
	}



	const input_arith1 = '
	:print(- (x+y)*(x-y) % z)
';
	function test_php_arith1() {
		$expected = <<<END
		<?php echo -(\$x + \$y) * (\$x - \$y) % \$z; ?>
END;
		$this->_test_php(KwartzTranslatorTest::input_arith1, $expected);
	}
	function test_eruby_arith1() {
		$expected = <<<END
		<%= -(x + y) * (x - y) % z %>
END;
		$this->_test_eruby(KwartzTranslatorTest::input_arith1, $expected);
	}



	const input_arith2 = '
		:print(- (x+y)*(x-y) % z, "\n")
		:set(a[i+1] = a[i] > 0 ? (x-1)*2 : y*2)
';

	function test_php_arith2() {
		$expected = <<<END
		<?php echo -(\$x + \$y) * (\$x - \$y) % \$z; ?>
		<?php \$a[\$i + 1] = \$a[\$i] > 0 ? (\$x - 1) * 2 : \$y * 2; ?>

END;
		$this->_test_php(KwartzTranslatorTest::input_arith2, $expected);
	}

	function test_eruby_arith2() {
		$expected = <<<END
		<%= -(x + y) * (x - y) % z %>
		<% a[i + 1] = a[i] > 0 ? (x - 1) * 2 : y * 2 %>

END;
		$this->_test_eruby(KwartzTranslatorTest::input_arith2, $expected);
	}


	const input_property1 = '
		:print(obj.child.name)
	';
	function test_php_property1() {
		$expected = <<<END
		<?php echo \$obj->child->name; ?>
END;
		$this->_test_php(KwartzTranslatorTest::input_property1, $expected);
	}

	function test_eruby_property1() {
		$expected = <<<END
		<%= obj.child.name %>
END;
		$this->_test_eruby(KwartzTranslatorTest::input_property1, $expected);
	}


	const input_function1 = '
		:print(func(x, y, z))
	';

	function test_php_function1() {
		$expected = <<<END
		<?php echo func(\$x, \$y, \$z); ?>
END;
		$this->_test_php(KwartzTranslatorTest::input_function1, $expected);
	}

	function test_eruby_function1() {
		$expected = <<<END
		<%= func(x, y, z) %>
END;
		$this->_test_eruby(KwartzTranslatorTest::input_function1, $expected);
	}


	const input_boolean1 = '
		:set(x = (a || b) && c ? true : false)
	';
	function test_php_boolean1() {
		$expected = <<<END
		<?php \$x = (\$a || \$b) && \$c ? TRUE : FALSE; ?>

END;
		$this->_test_php(KwartzTranslatorTest::input_boolean1, $expected);
	}
	
	function test_eruby_boolean1() {
		$expected = <<<END
		<% x = (a || b) && c ? true : false %>

END;
		$this->_test_eruby(KwartzTranslatorTest::input_boolean1, $expected);
	}



	const input_null1 = '
		:print(x == null ? "" : x)
	';
	function test_php_null1() {
		$expected = <<<END
		<?php echo \$x == NULL ? "" : \$x; ?>
END;
		$this->_test_php(KwartzTranslatorTest::input_null1, $expected);
	}
	
	function test_eruby_null1() {
		$expected = <<<END
		<%= x == nil ? "" : x %>
END;
		$this->_test_eruby(KwartzTranslatorTest::input_null1, $expected);
	}




	const input_print1 = '
		:print("hoge\\n")
	';
	function test_php_print1() {
		$expected = <<<END
		hoge

END;
		$this->_test_php(KwartzTranslatorTest::input_print1, $expected);
	}
	

	function test_eruby_print1() {
		$expected = <<<END
		hoge

END;
		$this->_test_eruby(KwartzTranslatorTest::input_print1, $expected);
	}



	const input_print2 = '
		:print("aaa", x+y, hash[\'key\'])
	';
	function test_php_print2() {
		$expected = <<<END
		aaa<?php echo \$x + \$y; ?><?php echo \$hash["key"]; ?>
END;
		$this->_test_php(KwartzTranslatorTest::input_print2, $expected);
	}

	function test_eruby_print2() {
		$expected = <<<END
		aaa<%= x + y %><%= hash["key"] %>
END;
		$this->_test_eruby(KwartzTranslatorTest::input_print2, $expected);
	}



	const input_set1 = '
		:set(x=1)
	';

	function test_php_set1() {
		$expected = <<<END
		<?php \$x = 1; ?>

END;
		$this->_test_php(KwartzTranslatorTest::input_set1, $expected);
	}
	
	function test_eruby_set1() {
		$expected = <<<END
		<% x = 1 %>

END;
		$this->_test_eruby(KwartzTranslatorTest::input_set1, $expected);
	}



	const input_foreach1 = '
		:foreach(item=list)
		  :print("<td>", item, "</td>\n")
		:end
	';
	function test_php_foreach1() {
		$expected = <<<END
		<?php foreach (\$list as \$item) { ?>
		<td><?php echo \$item; ?></td>
		<?php } ?>

END;
		$this->_test_php(KwartzTranslatorTest::input_foreach1, $expected);
	}
	
	function test_eruby_foreach1() {
		$expected = <<<END
		<% for item in list do %>
		<td><%= item %></td>
		<% end %>

END;
		$this->_test_eruby(KwartzTranslatorTest::input_foreach1, $expected);
	}



	const input_while1 = '
		:while(x>0)
		  :print(x)
		:end
	';

	function test_php_while1() {
		$expected = <<<END
		<?php while (\$x > 0) { ?>
		<?php echo \$x; ?><?php } ?>

END;
		$this->_test_php(KwartzTranslatorTest::input_while1, $expected);
	}

	function test_eruby_while1() {
		$expected = <<<END
		<% while x > 0 do %>
		<%= x %><% end %>

END;
		$this->_test_eruby(KwartzTranslatorTest::input_while1, $expected);
	}



	const input_if1 = '
		:if(cond1)
		  :print("cond1\n")
		:end
	';
	function test_php_if1() {
		$expected = <<<END
		<?php if (\$cond1) { ?>
		cond1
		<?php } ?>

END;
		$this->_test_php(KwartzTranslatorTest::input_if1, $expected);
	}

	function test_eruby_if1() {
		$expected = <<<END
		<% if cond1 then %>
		cond1
		<% end %>

END;
		$this->_test_eruby(KwartzTranslatorTest::input_if1, $expected);
	}



	const input_if2 = '
		:if(cond1)
		  :print("aaa\n")
		:else
		  :print("bbb\n")
		:end
	';

	function test_php_if2() {
		$expected = <<<END
		<?php if (\$cond1) { ?>
		aaa
		<?php } else { ?>
		bbb
		<?php } ?>

END;
		$this->_test_php(KwartzTranslatorTest::input_if2, $expected);
	}

	function test_eruby_if2() {
		$expected = <<<END
		<% if cond1 then %>
		aaa
		<% else %>
		bbb
		<% end %>

END;
		$this->_test_eruby(KwartzTranslatorTest::input_if2, $expected);
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
		$expected = <<<END
		<?php if (\$cond1) { ?>
		aaa
		<?php } elseif (\$cond2) { ?>
		bbb
		<?php } elseif (\$cond3) { ?>
		ccc
		<?php } else { ?>
		ddd
		<?php } ?>

END;
		$this->_test_php(KwartzTranslatorTest::input_if3, $expected);
	}

	function test_eruby_if3() {
		$expected = <<<END
		<% if cond1 then %>
		aaa
		<% elsif cond2 then %>
		bbb
		<% elsif cond3 then %>
		ccc
		<% else %>
		ddd
		<% end %>

END;
		$this->_test_eruby(KwartzTranslatorTest::input_if3, $expected);
	}



	const input_macro1 = '
		:expand(foo)
		:macro(foo)
		  :print("OK\n")
		:end
	';

	function test_php_macro1() {
		$expected = <<<END
		OK

END;
		$this->_test_php(KwartzTranslatorTest::input_macro1, $expected);
	}

	function test_eruby_macro1() {
		$expected = <<<END
		OK

END;
		$this->_test_eruby(KwartzTranslatorTest::input_macro1, $expected);
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
		$expected = <<<END
		<?php foreach (\$bar as \$foo) { ?>
		<span><?php echo \$foo; ?></span>
		<?php } ?>

END;
		$this->_test_php(KwartzTranslatorTest::input_macro2, $expected);
	}

	function test_eruby_macro2() {
		$expected = <<<END
		<% for foo in bar do %>
		<span><%= foo %></span>
		<% end %>

END;
		$this->_test_eruby(KwartzTranslatorTest::input_macro2, $expected);
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
		$expected = <<<END
		 <?php foreach (\$hash as \$key=>\$value) { ?>
		<?php echo \$key; ?> = <?php echo \$value; ?>
		 <?php } ?>

END;
		//$this->_test_php(KwartzTranslatorTest::input_rawcode1, $expected);
		$this->_test_php($input, $expected);
	}
	
	function test_eruby_rawcode1() {
		$input = '
		:::% foreach key,value in hash do
		:print(key, " = ", value, "\\n")
		:::% end
		';
		$expected = <<<END
		% foreach key,value in hash do
		<%= key %> = <%= value %>
		% end

END;
		//$this->_test_eruby(KwartzTranslatorTest::input_rawcode1, $expected);
		$this->_test_eruby($input, $expected);
	}



	const input_rawcode2 = '
		  <?php foreach (\$hash as \$key=>\$value) { ?>
		    <?= \$key ?> = <?= \$value ?>
		  <?php } ?>
	';

	function test_php_rawcode2() {
		$input = <<<END
		  <?php foreach (\$hash as \$key=>\$value) { ?>
		    <?= \$key ?> = <?= \$value ?>
		  <?php } ?>

END;
		$expected = <<<END
		<?php foreach (\$hash as \$key=>\$value) { ?>
		<?= \$key ?> = <?= \$value ?>
		<?php } ?>

END;
		$this->_test_php($input, $expected);
	}

	function test_eruby_rawcode2() {
		$input = '
		  <% for key,value in hash do %>
		    <%= key %> = <%= value %>
		  <% end %>
		';
		$expected = <<<END
		<% for key,value in hash do %>
		<%= key %> = <%= value %>
		<% end %>

END;
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
		$expected = <<<END
		<table>
		<?php \$ctr = 0; ?>
		<?php foreach (\$list as \$item) { ?>
		  <?php \$ctr += 1; ?>
		  <?php if (\$ctr % 2 == 0) { ?>
		    <?php \$klass = "even"; ?>
		  <?php } elseif (\$ctr % 2 == 1) { ?>
		    <?php \$klass = "odd"; ?>
		  <?php } else { ?>
		    <?php \$klass = "never"; ?>
		  <?php } ?>
		  <tr class="<?php echo \$klass; ?>">
		    <td><?php echo \$item; ?></td>
		  </tr>
		<?php } ?>
		</table>

END;
		$this->_test_php(KwartzTranslatorTest::input_indent1, $expected);
	}

	function test_eruby_indent1() {
		$expected = <<<END
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

END;
		$this->_test_eruby(KwartzTranslatorTest::input_indent1, $expected);
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