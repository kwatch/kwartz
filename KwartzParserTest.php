<?php

###
### KwartzParserTest.php
###
### $Id: KwartzParserTest.php,v 0.1 2004/08/16 14:08:06 kwatch Exp $
###

require_once('PHPUnit.php');
require_once('KwartzParser.inc');

class KwartzParserTest extends PHPUnit_TestCase {

	###
	### expression
	###

	function _test_expr($input, $expected, $method_name='parse_expression', $flag_test=true) {
		$scanner = new KwartzScanner($input);
		$parser	 = new KwartzParser($scanner);
		$expr	 = $parser->$method_name();
		$actual	 = $expr->inspect();
		if ($flag_test) {
			$this->assertEquals($expected, $actual);
		}
	}


	function test_parse_variable() {
		$input = "abc";
		$expected = "abc\n";
		$this->_test_expr($input, $expected, 'parse_item');
	}


	function test_parse_integer() {
		$input = "1";
		$expected = "1\n";
		$this->_test_expr($input, $expected, 'parse_factor');
	}

	function test_parse_float() {
		$input = "3.14";
		$expected = "3.14\n";
		$this->_test_expr($input, $expected, 'parse_factor');
	}

	function test_parse_boolean() {
		$input = "true";
		$expected = "true\n";
		$this->_test_expr($input, $expected, 'parse_factor');
		$input = "false";
		$expected = "false\n";
		$this->_test_expr($input, $expected, 'parse_factor');
	}

	function test_parse_null() {
		$input = "null";
		$expected = "null\n";
		$this->_test_expr($input, $expected, 'parse_factor');
	}

	function test_parse_string() {
		//$input = '"<tr class=\\"foo\\">\r\n"';
		//$expected = '"<tr class=\\"foo\\">\r\n"' . "\n";
		$input = "'hogera'";
		$expected= '"hogera"' . "\n";
		$this->_test_expr($input, $expected, 'parse_factor');
	}

	function test_parse_prefix1() {
		$input = "- 3";
		$expected = "-.\n  3\n";
		$this->_test_expr($input, $expected, 'parse_factor');
	}

	function test_parse_prefix2() {
		$input = "! flag";
		$expected = "!\n  flag\n";
		$this->_test_expr($input, $expected, 'parse_factor');
	}

	function test_parse_term1() {
		$input = "1 * 2 / 3 % 4";
		$expected = <<<END
%
  /
    *
      1
      2
    3
  4

END;
		$this->_test_expr($input, $expected, 'parse_term');
	}


	function test_parse_term2() {
		$input = "a*b*c*d";
		$expected = <<<END
*
  *
    *
      a
      b
    c
  d

END;
		$this->_test_expr($input, $expected, 'parse_term');
	}


	function test_parse_arith1() {
		$input = "1 + 2 - 3 + 4";
		$expected = <<<END
+
  -
    +
      1
      2
    3
  4

END;
		$this->_test_expr($input, $expected, 'parse_arith');
	}



	function test_parse_arith2() {
		$input = "'abc' .+ str1 + str2";
		$expected = <<<END
+
  .+
    "abc"
    str1
  str2

END;
		$this->_test_expr($input, $expected, 'parse_arith');
	}

	function test_parse_arith3() {
		$input = "1 * 2 / 3 + 4 % 5";
		$expected = <<<END
+
  /
    *
      1
      2
    3
  %
    4
    5

END;
		$this->_test_expr($input, $expected, 'parse_arith');
	}



	function test_parse_compare1() {
		$input = "x <= 2*r";
		$expected = <<<END
<=
  x
  *
    2
    r

END;
		$this->_test_expr($input, $expected, 'parse_compare');
	}


	function test_parse_logical_and1() {
		$input = "0 < x && x < 10";
		$expected = <<<END
&&
  <
    0
    x
  <
    x
    10

END;
		$this->_test_expr($input, $expected, 'parse_logical_and');
	}


	function test_parse_logical_or1() {
		$input = "x == 10 || y != 20";
		$expected = <<<END
||
  ==
    x
    10
  !=
    y
    20

END;
		$this->_test_expr($input, $expected, 'parse_logical_or');
	}


	function test_parse_logical1() {
		$input = "! flag || x >= 0 && y <= 0";
		$expected = <<<END
||
  !
    flag
  &&
    >=
      x
      0
    <=
      y
      0

END;
		$this->_test_expr($input, $expected, 'parse_logical_or');
	}


	function test_parse_conditional1() {
		$input = "x>y?x:y";
		$expected = <<<END
?
  >
    x
    y
  x
  y

END;
		$this->_test_expr($input, $expected, 'parse_conditional');
	}


	function test_parse_conditional2() {
		$input = "x>y?x-y:y-x";
		$expected = <<<END
?
  >
    x
    y
  -
    x
    y
  -
    y
    x

END;
		$this->_test_expr($input, $expected, 'parse_conditional');
	}


	function test_parse_assignment1() {
		$input = "x = a+1";
		$expected = <<<END
=
  x
  +
    a
    1

END;
		$this->_test_expr($input, $expected, 'parse_assignment');
	}


	function test_parse_assignment2() {
		$input = "x += 1";
		$expected = <<<END
+=
  x
  1

END;
		$this->_test_expr($input, $expected, 'parse_assignment');
	}


	function test_parse_assignment3() {
		$input = "x = y = z = 0";
		$expected = <<<END
=
  x
  =
    y
    =
      z
      0

END;
		$this->_test_expr($input, $expected, 'parse_assignment');
	}



	function test_parse_paren1() {
		$input = "(x)";
		$expected = <<<END
x

END;
		$this->_test_expr($input, $expected, 'parse_expression');
	}


	function test_parse_paren2() {
		$input = "n * (n + 1) / 2";
		$expected = <<<END
/
  *
    n
    +
      n
      1
  2

END;
		$this->_test_expr($input, $expected, 'parse_expression');
	}



	function test_parse_paren3() {
		$input = "(((x = y) != END) && flag)";
		$expected = <<<END
&&
  !=
    =
      x
      y
    END
  flag

END;
		$this->_test_expr($input, $expected, 'parse_expression');
	}


	function test_parse_array1() {
		$input = "array[10]";
		$expected = <<<END
[]
  array
  10

END;
		$this->_test_expr($input, $expected, 'parse_array');
	}


	function test_parse_array2() {
		$input = "array[x][y][z]";
		$expected = <<<END
[]
  []
    []
      array
      x
    y
  z

END;
		$this->_test_expr($input, $expected, 'parse_array');
	}


	function test_parse_hash1() {
		$input = "hash['key']";
		$expected = <<<END
[]
  hash
  "key"

END;
		$this->_test_expr($input, $expected, 'parse_array');
	}


	function test_parse_hash2() {
		$input = "hash[:key]";
		$expected = <<<END
[:]
  hash
  "key"

END;
		$this->_test_expr($input, $expected, 'parse_array');
	}


	function test_parse_hash3() {
		$input = "hash{'key'}";
		$expected = <<<END
{}
  hash
  "key"

END;
		$this->_test_expr($input, $expected, 'parse_array');
	}


	function test_parse_hash4() {
		$input = "hash['k1'][:k2]{'k3'}";
		$expected = <<<END
{}
  [:]
    []
      hash
      "k1"
    "k2"
  "k3"

END;
		$this->_test_expr($input, $expected, 'parse_array');
	}



	function test_parse_property1() {
		$input = "obj.property";
		$expected = <<<END
.
  obj
  'property'

END;
		$this->_test_expr($input, $expected, 'parse_array');
	}


	function test_parse_property2() {
		$input = "obj.p1.p2.p3";
		$expected = <<<END
.
  .
    .
      obj
      'p1'
    'p2'
  'p3'

END;
		$this->_test_expr($input, $expected, 'parse_array');
	}


	function test_parse_function1() {
		$input = "f(10, x+1, (3+4))";
		$expected = <<<END
f()
  10
  +
    x
    1
  +
    3
    4

END;
		$this->_test_expr($input, $expected, 'parse_expression');
	}



	###
	### statement
	###

}


###
### execute test
###
//if ($argv[0] == 'KwartzParserTest.php') {
	$suite = new PHPUnit_TestSuite('KwartzParserTest');
	$result = PHPUnit::run($suite);
	//echo $result->toHTML();
	echo $result->toString();
//}
?>
