<?php

###
### KwartzScannerTest.php
###
### $Id: KwartzScannerTest.php,v 0.1 2004/08/16 14:04:46 kwatch Exp $
###

require_once('PHPUnit.php');
require_once('KwartzScanner.inc');

class KwartzScannerTest extends PHPUnit_TestCase {

	###
	### test string
	###
	
	function _test_str($input, $expected_token_str, $flag_test = true) {
		$scanner   = new KwartzScanner($input);
		$token     = $scanner->scan();
		$token_str = $scanner->token_str();
		//echo "token=$token, token_str=", var_dump($token_str), "\n";
		if ($flag_test) {
			$this->assertEquals($expected_token_str, $token_str);
		}
	}

	function test_scan_str1() {
		$input     = '"hoge\\"\n\r\t"';
		$expected  = "hoge\"\n\r\t";
		$this->_test_str($input, $expected);
	}

	function test_scan_str2() {
		$input     = "'hoge\\'s\\n\\r\\t'";
		$expected  = 'hoge\'s\n\r\t';
		$this->_test_str($input, $expected);
	}


	function test_scan_str3() {
		$input     = '"hogeratta\n\n';
		try {
			$this->_test_str($input, '', false);
		} catch (KwartzScannerException $ex) {
			# OK
			return;
		}
		$this->fail('exception should be thrown.');
	}

	function test_scan_str4() {
		$input     = "'hogeratta\n\n";
		try {
			$this->_test_str($input, '', false);
		} catch (KwartzScannerException $ex) {
			# OK
			return;
		}
		$this->fail('exception should be thrown.');
	}



	###
	### 
	###

	function _test($input, $expected, $flag_test = true) {
		$scanner = new KwartzScanner($input);
		$actual = $scanner->scan_all();
		if ($flag_test) {
			$this->assertEquals($expected, $actual);
		}
	}


	function test_scan_basic1() {
		$input = <<<END
if (x > 0) {
	echo \$hoge;
} else {
	\$hoge = 0;
}
END;
		$expected = <<<END
if
(
x
>
0
)
{
print
$
hoge
;
}
else
{
$
hoge
=
0
;
}

END;
		$this->_test($input, $expected);
	}


	function test_scan_basic2() {
		$input = <<<END
:set(ctr = 0)
:foreach(item = list)
  :set(ctr += 1)
  :set(klass=ctr%2==0?even:odd)
  :print("<tr class=\"", klass, "\">\n")
  :print("  <td>", item.name, "</td>\n")
  :print("</tr>\n")
:end
END;

		$expected = <<<END
:set
(
ctr
=
0
)
:foreach
(
item
=
list
)
:set
(
ctr
+=
1
)
:set
(
klass
=
ctr
%
2
==
0
?
even
:
odd
)
:print
(
"<tr class=\\""
,
klass
,
"\\">\\n"
)
:print
(
"  <td>"
,
item
.
name
,
"</td>\\n"
)
:print
(
"</tr>\\n"
)
:end

END;
		$this->_test($input, $expected);
	}



	##
	## comments
	##
	function test_scan_comment1() {
		$input = <<<END
# foobar


END;
		$expected = '';
		$this->_test($input, $expected);
	}

	function test_scan_comment2() {
		$input = <<<END
foo # comment
# comment
bar
# comment
END;
		$expected = "foo\nbar\n";
		$this->_test($input, $expected);
	}
	
	
	##
	## invalid char
	##
	function test_scan_invalid1() {
		$input = '¤Û¤²';
		try {
			$this->_test($input, NULL, false);
		} catch (KwartzScannerException $ex) {
			# OK
			return;
		}
		$this->fail("KwartzScannerException should be thrown.");
	}
}


###
### execute test
###
//if ($argv[0] == 'KwartzScannerTest.php') {
	$suite = new PHPUnit_TestSuite('KwartzScannerTest');
	$result = PHPUnit::run($suite);
	//echo $result->toHTML();
	echo $result->toString();
//}
?>
