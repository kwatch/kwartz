<?PHP

###
### test for kwartz.inc
###
### $Id: test.php,v 0.1 2004/08/15 08:47:17 kwatch Exp $
###

require_once('PHPUnit.php');
require_once('kwartz.inc');

class KwartzTest extends PHPUnit_TestCase {

	var $int_expr;
	var $float_var;
	var $str_expr;
	var $var_expr;
	var $arith_expr;
	var $compare_expr;

	var $print_stmt;
	var $set_stmt;
	var $block_stmt;
	var $foreach_stmt;
	var $if_stmt;
	var $macro_stmt;
	var $expand_stmt;
	var $elem_stmt;			// ?
	var $rawcode_stmt;


	function NodeTest($mesg) {
		$this->TestCase($mesg);
	}


	function setUp() {
		##
		## Expression
		##
		$this->int_expr   = new NumericExpression(10);
		$this->float_expr = new NumericExpression(3.14);
		$this->str_expr   = new StringExpression('foobar');
		$this->var_expr   = new VariableExpression('x');
		$this->arith_expr   = new NodeExpression('*', $this->int_expr, $this->float_expr);
		$this->compare_expr = new NodeExpression('<', $this->arith_expr, $this->var_expr);

		##
		## Statement
		##

		## print-statement
		$expr_list = array($this->arith_expr, $this->str_expr, $this->int_expr);
		$this->print_stmt = new PrintStatement($expr_list);
		
		## set-statement
		$assign_expr = new NodeExpression('=', $this->var_expr, $this->arith_expr);
		$this->set_stmt = new SetStatement($assign_expr);
		
		## block-statement
		$stmt1 = new SetStatement(new NodeExpression('=', $this->var_expr, $this->int_expr));
		$stmt2 = new PrintStatement(array($this->str_expr));
		$stmt_list = array($stmt1, $stmt2);
		$this->block_stmt = new BlockStatement($stmt_list);
		
		## foreach-statement
		$loopvar_expr = new VariableExpression('item');
		$list_expr    = new VariableExpression('list');
		$body_block   = $this->block_stmt;
		$this->foreach_stmt = new ForeachStatement($loopvar_expr, $list_expr, $body_block);
		
		## if-statement
		$condition_expr = $this->compare_expr;
		$then_block = $this->block_stmt;
		$else_stmt  = $this->block_stmt;
		$this->if_stmt = new IfStatement($condition_expr, $then_block, $else_stmt);
		
		## expand-statement
		$this->expand_stmt = new ExpandStatement('foo');

		## macro-statement
		$list = array( new ExpandStatement('stag_foo'), new ExpandStatement('cont_foo'), new ExpandStatement('etag_foo') );
		$this->macro_stmt = new MacroStatement('foo', new BlockStatement($list));
		
		## rawcode-statement
		$rawcode = "<?php echo \$hoge; ?>\n";
		$this->rawcode_stmt = new RawcodeStatement($rawcode);
		
	}
	
	function tearDown() {
	}


	###
	### leaf
	###
	function test_leaf_expr1() {	// leaf expression
		//$expected = '';
		//$expected .= "10\n";
		//$expected .= "3.14\n";
		//$expected .= "\"foobar\"\n";
		//$expected .= "x\n";
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
	### node
	###
	function test_node_expr1() {
		//$expected = '';
		//$expected .= "<\n";
		//$expected .= "  *\n";
		//$expected .= "    10\n";
		//$expected .= "    3.14\n";
		//$expected .= "  x\n";
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
  foo

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
  foo
  <<block>>
    :expand
      stag_foo
    :expand
      cont_foo
    :expand
      etag_foo

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
		$this->assertEquals($expected, $actual);
	}


}



###
### execute test
###
$suite = new PHPUnit_TestSuite('KwartzTest');
$result = PHPUnit::run($suite);
//echo $result->toHTML();
echo $result->toString();

?>
