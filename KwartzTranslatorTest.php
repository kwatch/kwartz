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



	function _test($input, $expected, $flag_test=TRUE) {
		$input    = preg_replace('/^\t\t/m', '', $input);
		$expected = preg_replace('/^\t\t/m', '', $expected);
		$scanner = new KwartzScanner($input);
		$parser  = new KwartzParser($scanner);
		$block   = $parser->parse();
		$translator = new KwartzPhpTranslator($block);
		$code = $translator->translate();
		$actual = $code;
		if ($flag_test) {
			$this->assertEquals($expected, $actual);
		}
		return $translator;
	}



	function test_php_array1() {
		$input = <<<END
		:print(var, array[0], hash1['key1'], hash2[:key2])
END;
		$expected = <<<END
		<?php echo \$var; ?><?php echo \$array[0]; ?><?php echo \$hash1["key1"]; ?><?php echo \$hash2['key2']; ?>
END;
		$this->_test($input, $expected);
	}



	function test_php_arith1() {
		$input = <<<END
		:print(- (x+y)*(x-y) % z)
END;
		$expected = <<<END
		<?php echo -(\$x + \$y) * (\$x - \$y) % \$z; ?>
END;
		$this->_test($input, $expected);
	}




	function test_php_arith2() {
		$input = <<<END
		:print(- (x+y)*(x-y) % z, "\n")
		:set(a[i+1] = a[i] > 0 ? (x-1)*2 : y*2)
END;
		$expected = <<<END
		<?php echo -(\$x + \$y) * (\$x - \$y) % \$z; ?>
		<?php \$a[\$i + 1] = \$a[\$i] > 0 ? (\$x - 1) * 2 : \$y * 2; ?>

END;
		$this->_test($input, $expected);
	}



	function test_php_property1() {
		$input = <<<END
		:print(obj.child.name)
END;
		$expected = <<<END
		<?php echo \$obj->child->name; ?>
END;
		$this->_test($input, $expected);
	}




	function test_php_function1() {
		$input = <<<END
		:print(func(x, y, z))
END;
		$expected = <<<END
		<?php echo func(\$x, \$y, \$z); ?>
END;
		$this->_test($input, $expected);
	}



	function test_php_boolean1() {
		$input = <<<END
		:set(x = (a || b) && c ? true : false)
END;
		$expected = <<<END
		<?php \$x = (\$a || \$b) && \$c ? TRUE : FALSE; ?>

END;
		$this->_test($input, $expected);
	}



	function test_php_null1() {
		$input = <<<END
		:print(x == null ? '' : x)
END;
		$expected = <<<END
		<?php echo \$x == NULL ? "" : \$x; ?>
END;
		$this->_test($input, $expected);
	}



	
	function test_php_print1() {
		$input = <<<END
		:print("hoge\\n")
END;
		$expected = <<<END
		hoge

END;
		$this->_test($input, $expected);
	}



	function test_php_print2() {
		$input = <<<END
		:print("aaa", x+y, hash['key'])
END;
		$expected = <<<END
		aaa<?php echo \$x + \$y; ?><?php echo \$hash["key"]; ?>
END;
		$this->_test($input, $expected);
	}



	function test_php_set1() {
		$input = <<<END
		:set(x=1)
END;
		$expected = <<<END
		<?php \$x = 1; ?>

END;
		$this->_test($input, $expected);
	}


	function test_php_foreach1() {
		$input = <<<END
		:foreach(item=list)
		  :print("<td>", item, "</td>\n")
		:end
END;
		$expected = <<<END
		<?php foreach (\$list as \$item) { ?>
		<td><?php echo \$item; ?></td>
		<?php } ?>

END;
		$this->_test($input, $expected);
	}



	function test_php_while1() {
		$input = <<<END
		:while(x>0)
		  :print(x)
		:end
END;
		$expected = <<<END
		<?php while (\$x > 0) { ?>
		<?php echo \$x; ?><?php } ?>

END;
		$this->_test($input, $expected);
	}




	function test_php_if1() {
		$input = <<<END
		:if(cond1)
		  :print("cond1\n")
		:end
END;
		$expected = <<<END
		<?php if (\$cond1) { ?>
		cond1
		<?php } ?>

END;
		$this->_test($input, $expected);
	}



	function test_php_if2() {
		$input = <<<END
		:if(cond1)
		  :print("aaa\n")
		:else
		  :print("bbb\n")
		:end
END;
		$expected = <<<END
		<?php if (\$cond1) { ?>
		aaa
		<?php } else { ?>
		bbb
		<?php } ?>

END;
		$this->_test($input, $expected);
	}



	function test_php_if3() {
		$input = <<<END
		:if(cond1)
		  :print("aaa\n")
		:elseif(cond2)
		  :print("bbb\n")
		:elseif(cond3)
		  :print("ccc\n")
		:else
		  :print("ddd\n")
		:end
END;
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
		$this->_test($input, $expected);
	}





	function test_php_macro1() {
		$input = <<<END
		:expand(foo)
		:macro(foo)
		  :print("OK\n")
		:end
END;
		$expected = <<<END
		OK

END;
		$this->_test($input, $expected);
	}





	function test_php_macro2() {
		$input = <<<END
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
END;
		$expected = <<<END
		<?php foreach (\$bar as \$foo) { ?>
		<span><?php echo \$foo; ?></span>
		<?php } ?>

END;
		$this->_test($input, $expected);
	}




	function test_php_rawcode1() {
		$input = <<<END
		::: <?php foreach (\$hash as \$key=>\$value) { ?>
		:print(key, " = ", value, "\\n")
		::: <?php } ?>

END;
		$expected = <<<END
		 <?php foreach (\$hash as \$key=>\$value) { ?>
		<?php echo \$key; ?> = <?php echo \$value; ?>
		 <?php } ?>

END;
		$this->_test($input, $expected);
	}



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
		$this->_test($input, $expected);
	}



	function test_php_rawcode3() {
		$input = <<<END
		  <% for item in list do %>
		    <?= \$key ?> = <?= \$value ?>
		  <% end %>

END;
		$expected = <<<END
		<% for item in list do %>
		<?= \$key ?> = <?= \$value ?>
		<% end %>

END;
		$this->_test($input, $expected);
	}




	function test_php_indent1() {
		$input = <<<END
:print("<table>\n")
:set(ctr = 0)
:foreach(item = list)
  :set(ctr += 1)
  :if(ctr % 2 == 0)
    :set(klass='even')
  :elseif(ctr % 2 == 1)
    :set(klass='odd')
  :else
    :set(klass='never')
  :end
  :print("  <tr class=\"", klass, "\">\n")
  :print("    <td>", item, "</td>\n")
  :print("  </tr>\n")
:end
:print("</table>\n")
END;
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
		$this->_test($input, $expected);
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