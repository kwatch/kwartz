<?php

###
### KwartzElementTest.php
###
### $Id: KwartzElementTest.php,v 0.1 2004/08/16 14:04:10 kwatch Exp kwatch $
###

require_once('PHPUnit.php');
require_once('KwartzElement.inc');

class KwartzElementTest extends PHPUnit_TestCase {

	var $int_expr;
	var $float_var;
	var $str_expr;
	var $var_expr;
	var $arith_expr;
	var $compare_expr;
	var $conditional_expr;

	var $print_stmt;
	var $set_stmt;
	var $block_stmt;
	var $foreach_stmt;
	var $if_stmt;
	var $macro_stmt;
	var $expand_stmt;
	var $elem_stmt;			// ?
	var $rawcode_stmt;


	function KwartzElementTest($mesg) {
		$this->PHPUnit_TestCase($mesg);
	}


	function setUp() {
		##
		## Expression
		##
		$this->int_expr   = new KwartzNumericExpression(10);
		$this->float_expr = new KwartzNumericExpression(3.14);
		$this->str_expr   = new KwartzStringExpression('foobar');
		$this->var_expr   = new KwartzVariableExpression('x');
		$this->arith_expr   = new KwartzBinaryExpression('*', $this->int_expr, $this->float_expr);
		$this->compare_expr = new KwartzBinaryExpression('<', $this->arith_expr, $this->var_expr);
		$this->conditional_expr = new KwartzConditionalExpression('?', $this->var_expr, $this->int_expr, $this->float_expr);

		##
		## Statement
		##

		## print-statement
		$expr_list = array($this->arith_expr, $this->str_expr, $this->int_expr);
		$this->print_stmt = new KwartzPrintStatement($expr_list);
		
		## set-statement
		$assign_expr = new KwartzBinaryExpression('=', $this->var_expr, $this->arith_expr);
		$this->set_stmt = new KwartzSetStatement($assign_expr);
		
		## block-statement
		$stmt1 = new KwartzSetStatement(new KwartzBinaryExpression('=', $this->var_expr, $this->int_expr));
		$stmt2 = new KwartzPrintStatement(array($this->str_expr));
		$stmt_list = array($stmt1, $stmt2);
		$this->block_stmt = new KwartzBlockStatement($stmt_list);
		
		## foreach-statement
		$loopvar_expr = new KwartzVariableExpression('item');
		$list_expr    = new KwartzVariableExpression('list');
		$body_block   = $this->block_stmt;
		$this->foreach_stmt = new KwartzForeachStatement($loopvar_expr, $list_expr, $body_block);
		
		## if-statement
		$condition_expr = $this->compare_expr;
		$then_block = $this->block_stmt;
		$else_stmt  = $this->block_stmt;
		$this->if_stmt = new KwartzIfStatement($condition_expr, $then_block, $else_stmt);
		
		## expand-statement
		$this->expand_stmt = new KwartzExpandStatement('foo');

		## macro-statement
		$list = array( new KwartzExpandStatement('stag_foo'), new KwartzExpandStatement('cont_foo'), new KwartzExpandStatement('etag_foo') );
		$this->macro_stmt = new KwartzMacroStatement('foo', new KwartzBlockStatement($list));
		
		## rawcode-statement
		$rawcode = "<?php echo \$hoge; ?>";
		$this->rawcode_stmt = new KwartzRawcodeStatement($rawcode);
		
	}
	
	function tearDown() {
	}


	###
	### leaf
	###
	function test_leaf_expr1() {	// leaf expression
		$expected = <<<END
10
3.14
"foobar"
x

END;
		$actual = '';
		$actual .= $this->int_expr->inspect();
		$actual .= $this->float_expr->inspect();
		$actual .= $this->str_expr->inspect();
		$actual .= $this->var_expr->inspect();
		$this->assertEquals($expected, $actual);
	}


	###
	### binary
	###
	function test_binary_expr1() {
		$expected = <<<END
<
  *
    10
    3.14
  x

END;
		$actual = $this->compare_expr->inspect();
		$this->assertEquals($expected, $actual);
	}


	###
	### conditional
	###
	function test_conditional_expr1() {
		$expected = <<<END
?
  x
  10
  3.14

END;
		$actual = $this->conditional_expr->inspect();
		$this->assertEquals($expected, $actual);
	}


	###
	### print
	###
	function test_print_stmt1() {
		$expected = <<<END
:print
  *
    10
    3.14
  "foobar"
  10

END;
		$actual = $this->print_stmt->inspect();
		$this->assertEquals($expected, $actual);
	}


	###
	### set
	###
	function test_set_stmt1() {
		$expected = <<<END
:set
  =
    x
    *
      10
      3.14

END;
		$actual = $this->set_stmt->inspect();
		$this->assertEquals($expected, $actual);
	}

	
	###
	### block
	###
	function test_block_stmt1() {
		$expected = <<<END
<<block>>
  :set
    =
      x
      10
  :print
    "foobar"

END;
		$actual = $this->block_stmt->inspect();
		$this->assertEquals($expected, $actual);
	}


	###
	### foreach
	###
	function test_foreach_stmt1() {
		$expected = <<<END
:foreach
  item
  list
  <<block>>
    :set
      =
        x
        10
    :print
      "foobar"

END;
		$actual = $this->foreach_stmt->inspect();
		$this->assertEquals($expected, $actual);
	}


	###
	### if
	###
	function test_if_stmt1() {
		$expected = <<<END
:if
  <
    *
      10
      3.14
    x
  <<block>>
    :set
      =
        x
        10
    :print
      "foobar"
  <<block>>
    :set
      =
        x
        10
    :print
      "foobar"

END;
		$actual = $this->if_stmt->inspect();
		$this->assertEquals($expected, $actual);
	}

	
	###
	### expand statement
	###
	function test_expand_stmt1() {
		$expected = <<<END
:expand
  'foo'

END;
		$actual = $this->expand_stmt->inspect();
		$this->assertEquals($expected, $actual);
	}



	###
	### macro statement
	###
	function test_macro_stmt1() {
		$expected = <<<END
:macro
  'foo'
  <<block>>
    :expand
      'stag_foo'
    :expand
      'cont_foo'
    :expand
      'etag_foo'

END;
		$actual = $this->macro_stmt->inspect();
		$this->assertEquals($expected, $actual);
	}



	###
	### rawcode statement
	###
	function test_rawcode_stmt1() {
		$expected = <<<END
:::<?php echo \$hoge; ?>

END;
		$actual = $this->rawcode_stmt->inspect();
		//echo kwartz_inspect_str($expected), "\n";
		//echo kwartz_inspect_str($actual), "\n";
		$this->assertEquals($expected, $actual);
	}


}


###
### execute test
###
//if ($argv[0] == 'KwartzElementTest.php') {
	$suite = new PHPUnit_TestSuite('KwartzElementTest');
	$result = PHPUnit::run($suite);
	//echo $result->toHTML();
	echo $result->toString();
//}

?>