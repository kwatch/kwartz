<?php

###
### KwartzParserTest.php
###

require_once('PHPUnit.php');
require_once('KwartzParser.inc');

class KwartzParserTest extends PHPUnit_TestCase {

	function __construct($name) {
		$this->PHPUnit_TestCase($name);
	}


	###
	### expression
	###

	function _test_expr($input, $expected, $method_name='parse_expression', $flag_test=true) {
	    //try {
		$input    = preg_replace('/^\t\t/m', '', $input);
		$expected = preg_replace('/^\t\t/m', '', $expected);
		$scanner = new KwartzScanner($input);
		$parser	 = new KwartzParser($scanner);
		$expr	 = $parser->$method_name();
		$actual	 = $expr->inspect();
		if ($flag_test) {
			$this->assertEquals($expected, $actual);
		}
	    //} catch (KwartzException $ex) {
	    //    echo $ex->getMessage();
	    //}
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

	function _test_stmt($input, $expected, $method_name='parse_statement', $flag_test=true) {
	    //try {
		$input    = preg_replace('/^\t\t/m', '', $input);
		$expected = preg_replace('/^\t\t/m', '', $expected);
		$scanner = new KwartzScanner($input);
		$parser  = new KwartzParser($scanner);
		$stmt = $parser->$method_name();
		$actual = $stmt->inspect();
		if ($flag_test) {
			$this->assertEquals($expected, $actual);
		}
		return $actual;
	    //} catch (KwartzException $ex) {
	    //    echo $ex->getMessage(), "\n";
	    //}
	}
	
	function test_parse_set_stmt1() {
		$input = ":set(v = 1)";
		$expected = <<<END
		:set
		  =
		    v
		    1

END;
		//$this->_test_stmt($input, $expected, 'parse_set_stmt');
		$this->_test_stmt($input, $expected);
	}


	function test_parse_print_stmt1() {
		$input = ":print(x, y+1, z)";
		$expected = <<<END
		:print
		  x
		  +
		    y
		    1
		  z

END;
		//$this->_test_stmt($input, $expected, 'parse_print_stmt');
		$this->_test_stmt($input, $expected);
	}


	function test_parse_block_stmt1() {
		$input = <<<END
		:set(x = 1)
		:print(x)
END;
		$expected = <<<END
		<<block>>
		  :set
		    =
		      x
		      1
		  :print
    x

END;
		$this->_test_stmt($input, $expected, 'parse_block_stmt');
		//$this->_test_stmt($input, $expected);		# NG
	}


	function test_parse_if_stmt1() {
		$input = ":if(x > 0) :print(x) :end";
		$expected = <<<END
		:if
		  >
		    x
		    0
		  <<block>>
		    :print
		      x

END;
		//$this->_test_stmt($input, $expected, 'parse_if_stmt');
		$this->_test_stmt($input, $expected);
	}


	function test_parse_if_stmt2() {
		$input = ":if(x > y) :set(max=x) :else :set(max=y) :end";
		$expected = <<<END
		:if
		  >
		    x
		    y
		  <<block>>
		    :set
		      =
		        max
		        x
		  <<block>>
		    :set
		      =
		        max
		        y

END;
		//$this->_test_stmt($input, $expected, 'parse_if_stmt');
		$this->_test_stmt($input, $expected);
	}



	function test_parse_if_stmt3() {
		$input = <<<END
		:if (x > 1000)
		  :print('A')
		:elseif (x > 100)
		  :print('B')
		:elseif (x > 10)
		  :print('C')
		:end
END;
		$expected = <<<END
		:if
		  >
		    x
		    1000
		  <<block>>
		    :print
		      "A"
		  :if
		    >
		      x
		      100
		    <<block>>
		      :print
		        "B"
		    :if
		      >
		        x
		        10
		      <<block>>
		        :print
		          "C"

END;
		//$this->_test_stmt($input, $expected, 'parse_if_stmt');
		$this->_test_stmt($input, $expected);
	}



	function test_parse_if_stmt4() {
		$input = <<<END
		:if (x > 1000)
		  :print('A')
		:elseif (x > 100)
		  :print('B')
		:elseif (x > 10)
		  :print('C')
		:else
		  :print('X')
		:end
END;
		$expected = <<<END
		:if
		  >
		    x
		    1000
		  <<block>>
		    :print
		      "A"
		  :if
		    >
		      x
		      100
		    <<block>>
		      :print
		        "B"
		    :if
		      >
		        x
		        10
		      <<block>>
		        :print
		          "C"
		      <<block>>
		        :print
		          "X"

END;
		//$this->_test_stmt($input, $expected, 'parse_if_stmt');
		$this->_test_stmt($input, $expected);
	}


	function test_foreach_stmt1() {
		$input = <<<END
		:foreach(item = list)
			:print("<td>", item.name, "</td>\n")
		:end
END;
		$expected = <<<END
		:foreach
		  item
		  list
		  <<block>>
		    :print
		      "<td>"
		      .
		        item
		        'name'
		      "</td>\\n"

END;
		//$this->_test_stmt($input, $expected, 'parse_foreach_stmt');
		$this->_test_stmt($input, $expected);
	}


	function test_while_stmt1() {
		$input = <<<END
		:while(row = s.next)
			:print("<td>", row[0], "</td>\n")
		:end
END;
		$expected = <<<END
		:while
		  =
		    row
		    .
		      s
		      'next'
		  <<block>>
		    :print
		      "<td>"
		      []
		        row
		        0
		      "</td>\\n"

END;
		//$this->_test_stmt($input, $expected, 'parse_while_stmt');
		$this->_test_stmt($input, $expected);
	}


	function test_macro_stmt1() {
		$input = <<<END
		:macro(stag_foo)
		  :print("<td>\n")
		:end
END;
		$expected = <<<END
		:macro
		  'stag_foo'
		  <<block>>
		    :print
		      "<td>\\n"

END;
		//$this->_test_stmt($input, $expected, 'parse_macro_stmt');
		$this->_test_stmt($input, $expected);
	}


	function test_expand_stmt1() {
		$input = ":expand(elem_foo)";
		$expected = <<<END
		:expand
		  'elem_foo'

END;
		//$this->_test_stmt($input, $expected, 'parse_expand_stmt');
		$this->_test_stmt($input, $expected);
	}

	function test_expand2_stmt1() {
		$input = "@elem_foo";
		$expected = <<<END
		:expand
		  'elem_foo'

END;
		//$this->_test_stmt($input, $expected, 'parse_expand2_stmt');
		$this->_test_stmt($input, $expected);
	}

	function test_expand2_stmt2() {
		$input = "@stag";
		$expected = NULL;
		try {
			$this->_test_stmt($input, $expected, 'parse_expand2_stmt', false);
		} catch (KwartzSemanticError $ex) {
			# OK
			return;
		}
		$this->fail("kwartzSemanticError expected.");
	}


	function test_element_stmt1() {
		$input = <<<END
		:element(foo)
		  @stag
		  @cont
		  @etag
		:end
END;
		$expected = <<<END
		:macro
		  'elem_foo'
		  <<block>>
		    :expand
		      'stag_foo'
		    :expand
		      'cont_foo'
		    :expand
		      'etag_foo'

END;
		//$this->_test_stmt($input, $expected, 'parse_element_stmt');
		$this->_test_stmt($input, $expected);
	}


	function test_element_stmt2() {
		$input = <<<END
		:element(foo)
		  @stag
		  @cont
		  @etag
		:end
		:element(bar)
		  @stag
		  @cont
		  @etag
		:end
		:element(baz)
		  @stag
		  @cont
		  @etag
		:end
END;
		$expected = <<<END
		<<block>>
		  :macro
		    'elem_foo'
		    <<block>>
		      :expand
		        'stag_foo'
		      :expand
		        'cont_foo'
		      :expand
		        'etag_foo'
		  :macro
		    'elem_bar'
		    <<block>>
		      :expand
		        'stag_bar'
		      :expand
		        'cont_bar'
		      :expand
		        'etag_bar'
		  :macro
		    'elem_baz'
		    <<block>>
		      :expand
		        'stag_baz'
		      :expand
		        'cont_baz'
		      :expand
		        'etag_baz'

END;
		$this->_test_stmt($input, $expected, 'parse_block_stmt');
	}


	function test_rawcode_stmt1() {
		$input = ":::<?php echo hoge; ?>\n";
		$expected = <<<END
		:::<?php echo hoge; ?>

END;
		//$this->_test_stmt($input, $expected, 'parse_rawcode_stmt');
		$this->_test_stmt($input, $expected);
	}



	function test_rawcode_stmt2() {
		$input = <<<END
		  <?php foreach (\$hash as \$key=>\$value) { ?>

END;
		$expected = <<<END
		:::<?php foreach (\$hash as \$key=>\$value) { ?>

END;
		//$this->_test_stmt($input, $expected, 'parse_rawcode_stmt');
		$this->_test_stmt($input, $expected);
	}


	function test_rawcode_stmt3() {
		$input = <<<END
		  <% for item in list do %>

END;
		$expected = <<<END
		:::<% for item in list do %>

END;
		//$this->_test_stmt($input, $expected, 'parse_rawcode_stmt');
		$this->_test_stmt($input, $expected);
	}



	function test_load_stmt1() {
		$content = <<<END
		:print(x)
END;
		$filename = '_load.plogic';
		$f = fopen($filename, 'w');
		fwrite($f, $content);
		fclose($f);
		$input = ":load('{$filename}')";
		$expected = <<<END
		<<block>>
		  :print
		    x

END;
		$this->_test_stmt($input, $expected, 'parse_load_stmt');
		unlink($filename);
	}


	function test_parse_complex_stmt1() {
		$input = <<<END
		:macro(stag_foo)
		  :print("<tr class=\"", klass, "\"\n")
		:end
		:macro(cont_foo)
		  :print("  <td>", item, "</td>\n")
		:end
		:macro(etag_foo)
		  :print("</tr>\n")
		:end
		:macro(elem_foo)
		  :expand(stag_foo)
		  :expand(cont_foo)
		  :expand(etag_foo)
		:end
		
		:element(foo)
		  :set(ctr = 0)
		  :foreach (item = list)
		    :set(ctr += 1)
		    :set(klass = ctr%2 == 0 ? 'even':'odd')
		    @stag
		    @cont
		    @etag
		  :end
		:end
END;
		$expected = <<<END
		<<block>>
		  :macro
		    'stag_foo'
		    <<block>>
		      :print
		        "<tr class=\\""
		        klass
		        "\\"\\n"
		  :macro
		    'cont_foo'
		    <<block>>
		      :print
		        "  <td>"
		        item
		        "</td>\\n"
		  :macro
		    'etag_foo'
		    <<block>>
		      :print
		        "</tr>\\n"
		  :macro
		    'elem_foo'
		    <<block>>
		      :expand
		        'stag_foo'
		      :expand
		        'cont_foo'
		      :expand
		        'etag_foo'
		  :macro
		    'elem_foo'
		    <<block>>
		      :set
		        =
		          ctr
		          0
		      :foreach
		        item
		        list
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
		                    ctr
		                    2
		                  0
		                "even"
		                "odd"
		          :expand
		            'stag_foo'
		          :expand
		            'cont_foo'
		          :expand
		            'etag_foo'

END;
		$this->_test_stmt($input, $expected, 'parse');
	}



	###
	### PHP parser test
	###
	function test_php_echo1() {
		$input = <<<END
		echo \$a;
END;
		$expected = <<<END
		<<block>>
		  :print
		    a

END;
		$this->_test_stmt($input, $expected, 'parse');
	}


	function test_php_expr1() {
		$input = <<<END
		echo \$a['foo']->property;
END;
		$expected = <<<END
		<<block>>
		  :print
		    .
		      []
		        a
		        "foo"
		      'property'

END;
		$this->_test_stmt($input, $expected, 'parse');
	}



	function test_php_set1() {
		$input = <<<END
		\$i = 0;
		\$i += 1;
		\$a[\$i] = \$x>\$y?\$x:\$y;
END;
		$expected = <<<END
		<<block>>
		  :set
		    =
		      i
		      0
		  :set
		    +=
		      i
		      1
		  :set
		    =
		      []
		        a
		        i
		      ?
		        >
		          x
		          y
		        x
		        y

END;
		$this->_test_stmt($input, $expected, 'parse');
	}



	function test_php_foreach1() {
		$input = <<<END
		foreach (\$list as \$item) {
		  echo "<td>", \$item->name, "<td>\n";
		}
END;
		$expected = <<<END
		<<block>>
		  :foreach
		    item
		    list
		    <<block>>
		      :print
		        "<td>"
		        .
		          item
		          'name'
		        "<td>\\n"

END;
		$this->_test_stmt($input, $expected, 'parse');
	}


	
	function test_php_if1() {
		$input = <<<END
		if (\$x > 0) {
		  echo "x is plus.";
		} elseif (\$x < 0) {
		  echo "x is minus.";
		} else {
		  echo "x is zero.";
		}
END;
		$expected = <<<END
		<<block>>
		  :if
		    >
		      x
		      0
		    <<block>>
		      :print
		        "x is plus."
		    :if
		      <
		        x
		        0
		      <<block>>
		        :print
		          "x is minus."
		      <<block>>
		        :print
		          "x is zero."

END;
		$this->_test_stmt($input, $expected, 'parse');
	}


	
	function test_php_while1() {
		$input = <<<END
\$x = read();
while (\$x != NULL) {
   echo \$x;
   \$x = read();
}
END;
		$expected = <<<END
<<block>>
  :set
    =
      x
      read()
  :while
    !=
      x
      null
    <<block>>
      :print
        x
      :set
        =
          x
          read()

END;
		$this->_test_stmt($input, $expected, 'parse');
	}



	function test_php_expand1() {
		$input = <<<END
expand stag_foo;
expand cont_foo;
expand etag_foo;
END;
		$expected = <<<END
<<block>>
  :expand
    'stag_foo'
  :expand
    'cont_foo'
  :expand
    'etag_foo'

END;
		$this->_test_stmt($input, $expected, 'parse');
	}



	
	function test_php_expand2() {
		$input = <<<END
		@stag;
		@cont;
		@etag;
END;
		$expected = "";
		try {
			$this->_test_stmt($input, $expected, 'parse');
		} catch (KwartzSemanticError $ex) {
			# OK
			return;
		}
		$this->fail("KwartzSemanticError should happen.");
	}



	
	function test_php_macro1() {
		$input = <<<END
macro stag_foo {
	echo "<tr>";
}
macro cont_foo {
	echo "<td>", \$item, "</td>";
}
macro stag_foo {
	echo "</tr>\\n";
}
END;
		$expected = <<<END
<<block>>
  :macro
    'stag_foo'
    <<block>>
      :print
        "<tr>"
  :macro
    'cont_foo'
    <<block>>
      :print
        "<td>"
        item
        "</td>"
  :macro
    'stag_foo'
    <<block>>
      :print
        "</tr>\\n"

END;
		$this->_test_stmt($input, $expected, 'parse');
	}



	function test_php_element1() {
		$input = <<<END
element foo {
	@stag;
	@cont;
	@etag;
}
END;
		$expected = <<<END
<<block>>
  :macro
    'elem_foo'
    <<block>>
      :expand
        'stag_foo'
      :expand
        'cont_foo'
      :expand
        'etag_foo'

END;
		$this->_test_stmt($input, $expected, 'parse');
	}



	function test_php_load1() {
		$content = <<<END
		echo \$x;
END;
		$filename = '_load_php.plogic';
		$f = fopen($filename, 'w');
		fwrite($f, $content);
		fclose($f);
		$input = "load('{$filename}');";
		$expected = <<<END
		<<block>>
		  :print
		    x

END;
		$this->_test_stmt($input, $expected, 'parse_load_stmt');
		unlink($filename);
	}


	
	function test_php_rawcode1() {
		$input = <<<END
element user {
	<?php foreach (\$hash as \$key=>\$value) { ?>
	echo \$key, "=", \$value, "\\n";
	<?php } ?>
}
END;
		$expected = <<<END
<<block>>
  :macro
    'elem_user'
    <<block>>
      :::<?php foreach (\$hash as \$key=>\$value) { ?>
      :print
        key
        "="
        value
        "\\n"
      :::<?php } ?>

END;
		$this->_test_stmt($input, $expected, 'parse');
	}



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
