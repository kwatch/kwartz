<?php

###
### KwartzElement.inc - class definition of Element, Expression, Statement, ...
###
### $Id: KwartzElement.inc,v 0.1 2004/08/16 13:40:23 kwatch Exp $
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
			$this->arglist  = $arglist;
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
			$this->left      = $left_expr;
			$this->right     = $right_expr;
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
			$s .= '"' . $this->value() . "\"\n";
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
		private $stmt_list;		// array

		// constructor
		function __construct($stmt_list=array()) {
			parent::__construct('<<block>>');
			$this->stmt_list = $stmt_list;
		}

		// instance methods
		function inspect($depth=0) {
			$s = parent::inspect($depth);
			foreach ($this->stmt_list as $stmt) {
				$s .= $stmt->inspect($depth + 1);
			}
			return $s;
		}
	}

	class KwartzPrintStatement extends KwartzStatement {
		// instance vars
		private $expr_list;		// array

		function __construct($expr_list) {
			parent::__construct(':print');
			$this->expr_list = $expr_list;
		}

		function inspect($depth=0) {
			$s = parent::inspect($depth);
			foreach ($this->expr_list as $expr) {
				$s .= $expr->inspect($depth + 1);
			}
			return $s;
		}
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
	}

	class KwartzIfStatement extends KwartzStatement {
		// instance vars
		private $cond_expr;
		private $then_block;
		private $else_stmt;		// block or if-statement

		// constructor
		function __construct($cond_expr, $then_block, $else_stmt) {
			parent::__construct(':if');
			$this->cond_expr  = $cond_expr;
			$this->then_block = $then_block;
			$this->else_stmt  = $else_stmt;
		}

		// instance methods
		function inspect($depth=0) {
			$s = parent::inspect($depth);
			$s .= $this->cond_expr->inspect($depth + 1);
			$s .= $this->then_block->inspect($depth + 1);
			$s .= $this->else_stmt->inspect($depth + 1);
			return $s;
		}
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
			$s .= $this->macro_name . "\n";
			$s .= $this->body_block->inspect($depth + 1);
			return $s;
		}
	}

	class KwartzExpandStatement extends KwartzStatement {
		private $macro_name;

		function __construct($macro_name) {
			parent::__construct(':expand');
			$this->macro_name = $macro_name;
		}
		function inspect($depth=0) {
			$s = parent::inspect($depth);
			$s .= $this->indent($depth + 1);
			$s .= $this->macro_name . "\n";
			return $s;
		}
	}

	class KwartzRawcodeStatement extends KwartzStatement {
		private $code_str;

		function __construct($code_str) {
			parent::__construct(':::');
			$this->code_str = $code_str;
		}

		function inspect($depth=0) {
			$s = $this->indent($depth);
			$s .= ':::' . $this->code_str;
			return $s;
		}
	}


//} // end of namespace Kwartz
?>