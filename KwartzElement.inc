<?php

###
### KwartzElement.inc - class definition of Element, Expression, Statement, ...
###


###  class hierarchy:
###
###  Element
###	Expression
###	   Unary
###	   Binary
###	   Function
###	   Property
###	   Leaf
###	     Variable
###	     Numeric
###	     String
###	     Boolean
###	     Null
###	Statement
###	   Print
###	   Set
###	   If
###	   Foreach
###	   Macro
###	   Expand
###	   Rawcode
###

require_once('KwartzUtility.inc');

//namespace Kwartz {

	##
	## Element
	##
	abstract class KwartzElement {
		// instance vars
		private $token;

		// constructor
		function __construct($token) {
			$this->token = $token;
		}

		// instance methods
		function token() {
			return $this->token;
		}
		//function set_token($token) {
		//	$this->token = $token;
		//	return $this;
		//}
		function inspect($depth=0) {
			$s = $this->indent($depth);
			$s .= $this->token;
			$s .= "\n";
			return $s;
		}
		protected function indent($depth) {
			$s = '';
			for ($i = 0; $i < $depth; $i++) {
				$s .=  '  ';
			}
			return $s;
		}
		function pretty_print($depth=0) {
			echo $this->inspect($depth);
		}
	}


	##
	## Expression
	##
	abstract class KwartzExpression extends KwartzElement {
	}

	class KwartzUnaryExpression extends KwartzExpression {
		// instance vars
		private $child;		// expression

		// constructor
		function __construct($token, $child_expr) {
			parent::__construct($token);
			$this->child = $child_expr;
		}

		// instance methods
		function child() {
			return $this->child;
		}

		function inspect($depth=0) {
			$s = parent::inspect($depth);
			$s .= $this->child->inspect($depth + 1);
			return $s;
		}
	}

	class KwartzBinaryExpression extends KwartzExpression {
		// instance vars
		private $left;		// expression
		private $right;		// expression

		// constructor
		function __construct($token, $left, $right) {
			parent::__construct($token);
			$this->left  = $left;
			$this->right = $right;
		}

		// instance methods
		function left() {
			return $this->left;
		}
		function right() {
			return $this->right;
		}

		function inspect($depth=0) {
			$s = parent::inspect($depth);
			$s .= $this->left->inspect($depth + 1);
			$s .= $this->right->inspect($depth + 1);
			return $s;
		}
	}

	class KwartzFunctionExpression extends KwartzExpression {
		// constructor
		private $funcname;
		private $arglist;

		function __construct($funcname, $arglist) {
			parent::__construct('function');
			$this->funcname = $funcname;
			$this->arglist	= $arglist;
		}

		function funcname() { return $this->funcname; }
		function arglist()  { return $this->arglist; }

		function inspect($depth=0) {
			$s = parent::indent($depth);
			$s .= "{$this->funcname}()\n";
			foreach ($this->arglist as $expr) {
				$s .= $expr->inspect($depth+1);
			}
			return $s;
		}
	}


	class KwartzPropertyExpression extends KwartzExpression {
		// constructor
		private $object;		// expression
		private $property;		// string

		function __construct($token, $object_expr, $property_name) {
			parent::__construct($token);
			$this->object = $object_expr;
			$this->property = $property_name;
		}

		function object()   { return $this->object; }
		function property() { return $this->property; }

		function inspect($depth=0) {
			$s = parent::inspect($depth);
			$s .= $this->object->inspect($depth+1);
			$s .= $this->indent($depth+1);
			$s .= "'{$this->property}'\n";
			return $s;
		}
	}


	class KwartzConditionalExpression extends KwartzExpression {
		private $condition;
		private $left;
		private $right;

		function __construct($token, $condition_expr, $left_expr, $right_expr) {
			parent::__construct($token);
			$this->condition = $condition_expr;
			$this->left	 = $left_expr;
			$this->right	 = $right_expr;
		}

		function inspect($depth=0) {
			$s = parent::inspect($depth);
			$s .= $this->condition->inspect($depth+1);
			$s .= $this->left->inspect($depth+1);
			$s .= $this->right->inspect($depth+1);
			return $s;
		}

		function condition() {
			return $this->condition;
		}
		function left() {
			return $this->left;
		}
		function right() {
			return $this->right;
		}
	}

	//class KwartzListExpression extends KwartzExpression {
	//	private $list;		// array
	//
	//	function __construct($list) {
	//		$this->list = $list;
	//	}
	//
	//	function list() {
	//		return $this->list;
	//	}
	//}


	##
	## Leaf
	##
	abstract class KwartzLeafExpression extends KwartzExpression {
		// instance vars
		private $value;		// string

		// constructor
		function __construct($token, $value) {
			parent::__construct($token);
			$this->value = $value;
		}

		// instance methods
		function value() {
			return $this->value;
		}
		function set_value($value) {
			$this->value = $value;
			return $this;
		}
		function inspect($depth=0) {
			$token = $this->token();
			$value = $this->value();
			$s = $this->indent($depth);
			$s .= $this->value;
			$s .= "\n";
			return $s;
		}
	}


	class KwartzVariableExpression extends KwartzLeafExpression {
		// constructor
		function __construct($varname) {
			parent::__construct('variable', $varname);
		}
	}


	class KwartzNumericExpression extends KwartzLeafExpression {
		// constructor
		function __construct($value) {
			parent::__construct('number', $value);
		}
	}


	class KwartzStringExpression extends KwartzLeafExpression {
		// constructor
		function __construct($value) {
			parent::__construct('string', $value);
		}

		// instance methods
		function inspect($depth=0) {
			$s = $this->indent($depth);
			$s .= kwartz_inspect_str($this->value()) . "\n";
			return $s;
		}
	}

	class KwartzBooleanExpression extends KwartzLeafExpression {
		// constructor
		function __construct($value) {
			parent::__construct('boolean', $value);
		}
	}

	class KwartzNullExpression extends KwartzLeafExpression {
		// constructor
		function __construct($value='null') {
			parent::__construct('null', $value);
		}
	}

	//## property name
	//class KwartzNameExpression extends KwartzLeafExpression {
	//	// constructor
	//	function __construct($name) {
	//		parent::__construct('name', $name);
	//	}
	//
	//	// instance methods
	//	function name() {
	//		$this->value();
	//	}
	//	function inspect($depth=0) {
	//		$s = $this->indent($depth);
	//		$s .= "'" . $this->value() . "'\n";
	//		return $s;
	//	}
	//}


	##
	## Statement
	##
	abstract class KwartzStatement extends KwartzElement {
	}

	class KwartzBlockStatement extends KwartzStatement {
		// instance vars
		private $statements;		// array

		// constructor
		function __construct($statements=array()) {
			parent::__construct('<<block>>');
			$this->statements = $statements;
		}

		// instance methods
		function inspect($depth=0) {
			$s = parent::inspect($depth);
			foreach ($this->statements as $stmt) {
				$s .= $stmt->inspect($depth + 1);
			}
			return $s;
		}
		function statements() { return $this->statements; }
		
		function shift()         { return array_shift($this->statements); }
		function unshift(&$stmt) { return array_unshift($this->statements, $stmt); }
		function push(&$stmt)    { return array_push($this->statements, $stmt); }
		function pop()           { return array_pop($this->statements); }
	}

	class KwartzPrintStatement extends KwartzStatement {
		// instance vars
		private $expressions;		// array

		function __construct($expr_list) {
			parent::__construct(':print');
			$this->expressions = $expr_list;
		}

		function inspect($depth=0) {
			$s = parent::inspect($depth);
			foreach ($this->expressions as $expr) {
				$s .= $expr->inspect($depth + 1);
			}
			return $s;
		}
		
		function expressions() { return $this->expressions; }
	}

	class KwartzSetStatement extends KwartzStatement {
		private $assign_expr;

		function __construct($assign_expr) {
			parent::__construct(':set');
			$this->assign_expr = $assign_expr;
		}

		function inspect($depth=0) {
			$s = parent::inspect($depth);
			$s .= $this->assign_expr->inspect($depth + 1);
			return $s;
		}
		
		function assign_expr() { return $this->assign_expr; }
	}

	class KwartzIfStatement extends KwartzStatement {
		// instance vars
		private $condition;
		private $then_block;
		private $else_stmt;		// block or if-statement

		// constructor
		function __construct($condition_expr, $then_block, $else_stmt) {
			parent::__construct(':if');
			$this->condition  = $condition_expr;
			$this->then_block = $then_block;
			$this->else_stmt  = $else_stmt;
		}

		// instance methods
		function inspect($depth=0) {
			$s = parent::inspect($depth);
			$s .= $this->condition->inspect($depth + 1);
			$s .= $this->then_block->inspect($depth + 1);
			if ($this->else_stmt) {
				$s .= $this->else_stmt->inspect($depth + 1);
			}
			return $s;
		}
		
		function condition()  { return $this->condition; }
		function then_block() { return $this->then_block; }
		function else_stmt()  { return $this->else_stmt; }
	}

	class KwartzForeachStatement extends KwartzStatement {
		// instance vars
		private $loopvar_var;
		private $list_expr;
		private $body_block;

		// constructor
		function __construct($loopvar_var, $list_expr, $body_block) {
			parent::__construct(':foreach');
			$this->loopvar_var = $loopvar_var;
			$this->list_expr   = $list_expr;
			$this->body_block  = $body_block;
		}

		// instance methods
		function inspect($depth=0) {
			$s = parent::inspect($depth);
			$s .= $this->loopvar_var->inspect($depth + 1);
			$s .= $this->list_expr->inspect($depth + 1);
			$s .= $this->body_block->inspect($depth + 1);
			return $s;
		}
		
		function loopvar_expr() { return $this->loopvar_var; }
		function list_expr() { return $this->list_expr; }
		function body_block() { return $this->body_block; }
	}


	class KwartzWhileStatement extends KwartzStatement {
		// instance vars
		private $condition;		// expression
		private $body_block;

		// constructor
		function __construct($condition_expr, $body_block) {
			parent::__construct(':while');
			$this->condition  = $condition_expr;
			$this->body_block = $body_block;
		}

		// instance methods
		function inspect($depth=0) {
			$s = parent::inspect($depth);
			$s .= $this->condition->inspect($depth + 1);
			$s .= $this->body_block->inspect($depth + 1);
			return $s;
		}
		
		function condition()  { return $this->condition; }
		function body_block() { return $this->body_block; }
	}

	class KwartzMacroStatement extends KwartzStatement {
		private $macro_name;		// string
		private $body_block;		// BlockStatement

		function __construct($macro_name, $body_block) {
			parent::__construct(':macro');
			$this->macro_name  = $macro_name;
			$this->body_block = $body_block;
		}

		function inspect($depth=0) {
			$s = parent::inspect($depth);
			$s .= $this->indent($depth + 1);
			$s .= "'" . $this->macro_name . "'\n";
			$s .= $this->body_block->inspect($depth + 1);
			return $s;
		}
		
		function macro_name() { return $this->macro_name; }
		function body_block() { return $this->body_block; }
	}

	class KwartzExpandStatement extends KwartzStatement {
		private $macro_name;		// string

		function __construct($macro_name) {
			parent::__construct(':expand');
			$this->macro_name = $macro_name;
		}
		function inspect($depth=0) {
			$s = parent::inspect($depth);
			$s .= $this->indent($depth + 1);
			$s .= "'" . $this->macro_name . "'\n";
			return $s;
		}
		
		function macro_name() { return $this->macro_name; }
	}

	class KwartzRawcodeStatement extends KwartzStatement {
		private $rawcode;		// string

		function __construct($rawcode_str) {
			parent::__construct(':rawcode');
			$this->rawcode = $rawcode_str;
		}

		function inspect($depth=0) {
			$s = $this->indent($depth);
			$s .= ':::' . $this->rawcode . "\n";
			return $s;
		}
		
		function rawcode() { return $this->rawcode; }
	}

//} // end of namespace Kwartz
?>