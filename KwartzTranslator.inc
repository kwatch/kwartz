<?php

###
### KwartzTranslator.inc
###

require_once('KwartzException.inc');
require_once('KwartzNode.inc');
require_once('KwartzUtility.inc');


// namespace Kwartz {


	class KwartzTranslationError extends KwartzException {
		private $translator;

		function __construct($msg, $translator) {
			parent::__construct($msg);
			$this->translator = $translator;
		}
	}

	abstract class KwartzTranslator {
		## should return code string
		abstract function translate_expression(&$expr, &$code);
		abstract function translate_statement(&$stmt, &$code, $depth);

		## should return code string
		abstract function translate();
	}

	abstract class KwartzBaseTranslator extends KwartzTranslator {
		protected $block;
		protected $macro_stmt_hash = array();
		protected $priorities = array(
				'variable' => 100,
				'number'   => 100,
				'boolean'  => 100,
				'string'   => 100,
				'null'	   => 100,

				'[]'	   =>  90,
				'{}'	   =>  90,
				'[:]'	   =>  90,
				'.'	   =>  90,

				'-.'	   =>  80,
				'!'	   =>  80,

				'*'	   =>  70,
				'/'	   =>  70,
				'%'	   =>  70,
				'^'	   =>  70,

				'+'	   =>  60,
				'-'	   =>  60,
				'.+'	   =>  60,

				'=='	   =>  50,
				'!='	   =>  50,
				'<'	   =>  50,
				'<='	   =>  50,
				'>'	   =>  50,
				'>='	   =>  50,

				'&&'	   =>  40,

				'||'	   =>  30,

				'?'	   =>  20,

				'='	   =>  10,
				'+='	   =>  10,
				'-='	   =>  10,
				'*='	   =>  10,
				'/='	   =>  10,
				'%='	   =>  10,
				'^='	   =>  10,
				'.+='	   =>  10,
			);

		protected $dispatcher = array(
				## expression
				'KwartzUnaryExpression'	      => 'translate_unary_expression',
				'KwartzBinaryExpression'      => 'translate_binary_expression',
				'KwartzFunctionExpression'    => 'translate_function_expression',
				'KwartzPropertyExpression'    => 'translate_property_expression',
				'KwartzConditionalExpression' => 'translate_conditional_expression',
				'KwartzVariableExpression'    => 'translate_variable_expression',
				'KwartzStringExpression'      => 'translate_string_expression',
				'KwartzNumericExpression'     => 'translate_numeric_expression',
				'KwartzBooleanExpression'     => 'translate_boolean_expression',
				'KwartzNullExpression'	      => 'translate_null_expression',

				## statement
				'KwartzPrintStatement'	      => 'translate_print_statement',
				'KwartzSetStatement'	      => 'translate_set_statement',
				'KwartzIfStatement'	      => 'translate_if_statement',
				'KwartzForeachStatement'      => 'translate_foreach_statement',
				'KwartzWhileStatement'	      => 'translate_while_statement',
				'KwartzMacroStatement'	      => 'translate_macro_statement',
				'KwartzExpandStatement'	      => 'translate_expand_statement',
				'KwartzBlockStatement'	      => 'translate_block_statement',
				'KwartzRawcodeStatement'      => 'translate_rawcode_statement',
			);
		protected $indent = array(
			0 => "",
			1 => "  ",
			2 => "    ",
			3 => "      ",
			4 => "        ",
			5 => "          ",
			6 => "            ",
			7 => "              ",
			8 => "                ",
			9 => "                  ",
			);
		protected $max_depth = 9;


		function __construct($block) {
			$this->block = $block;
		}


		//function translate_node(&$expr_or_stmt, &$code, $depth) {
		//	$class_name = get_class($expr_or_stmt);
		//	$method_name = $this->dispatcher[$class_name];
		//	return $this->$method_name($expr_or_stmt, $code, $depth);
		//}
		
		function translate_expression(&$expr, &$code) {
			$class_name = get_class($expr);
			$method_name = $this->dispatcher[$class_name];
			return $this->$method_name($expr, $code);
		}
		
		function translate_statement(&$stmt, &$code, $depth) {
			$class_name = get_class($stmt);
			$method_name = $this->dispatcher[$class_name];
			return $this->$method_name($stmt, $code, $depth);
		}


		function translate() {
			//$i = -1;
			$statements = $this->block->statements();
			foreach ($statements as $stmt) {
				//$i++;
				if ($stmt->token() == ':macro') {
					$this->add_macro($stmt->macro_name(), $stmt->body_block());
					//unset($block->statements()[$i]);
				}
			}
			$code = "";
			$this->translate_statement($this->block, $code, 0);
			return $code;
		}


		protected function translate_expr(&$expr, &$code, &$parent_token, &$child_token) {
			if ($this->priorities[$parent_token] > $this->priorities[$child_token]) {
				$code .= '(';
				$this->translate_expression($expr, $code);
				$code .= ')';
			} else {
				$this->translate_expression($expr, $code);
			}
			return $code;
		}


		abstract protected function translate_unary_expression(&$expr, &$code);
		abstract protected function translate_binary_expression(&$expr, &$code);
		abstract protected function translate_property_expression(&$expr, &$code);
		abstract protected function translate_function_expression(&$expr, &$code);
		abstract protected function translate_conditional_expression(&$expr, &$code);
		abstract protected function translate_variable_expression(&$expr, &$code);
		abstract protected function translate_string_expression(&$expr, &$code);
		abstract protected function translate_numeric_expression(&$expr, &$code);
		abstract protected function translate_boolean_expression(&$expr, &$code);
		abstract protected function translate_null_expression(&$expr, &$code);

		abstract protected function translate_print_statement(&$stmt, &$code, $depth);
		abstract protected function translate_set_statement(&$stmt, &$code, $depth);
		abstract protected function translate_if_statement(&$stmt, &$code, $depth);
		abstract protected function translate_foreach_statement(&$stmt, &$code, $depth);
		abstract protected function translate_while_statement(&$stmt, &$code, $depth);
		abstract protected function translate_macro_statement(&$stmt, &$code, $depth);
		abstract protected function translate_expand_statement(&$stmt, &$code, $depth);
		abstract protected function translate_block_statement(&$stmt, &$code, $depth);
		abstract protected function translate_rawcode_statement(&$stmt, &$code, $depth);


		protected function add_macro($macro_name, &$block) {
			$this->macro_stmt_hash[$macro_name] = $block;
		}

		protected function macro($macro_name) {
			if (array_key_exists($macro_name, $this->macro_stmt_hash)) {
				return $this->macro_stmt_hash[$macro_name];
			}
			return NULL;
		}
		
		protected function indent($depth) {
			if ($depth <= $this->max_depth) {
				return $this->indent[$depth];
			}
			$s = '';
			for ($i = 0; $i < $depth; $i++) {
				$s .= '  ';
			}
			return $s;
		}
		
		protected function add_indent(&$code, $depth) {
			if ($code && $code[strlen($code)-1] == "\n") {
				$code .= $this->indent($depth);
			}
		}
	}


	class KwartzPhpTranslator extends KwartzBaseTranslator {
		private	$keywords = array(
			'-.'   => '-',
			'.+'   => '.',
			'.+='  => '.=',
			'.'    => '->',
			'{'    => '[',
			'}'    => ']',
			'[:'   => "['",
			':]'   => "']",
		);

		function __construct($block) {
			parent::__construct($block);
		}

		protected function keyword($token) {
			return array_key_exists($token, $this->keywords) ? $this->keywords[$token] : $token;
		}

		protected function translate_unary_expression(&$expr, &$code) {
			$t = $expr->token();
			$code .= $this->keyword($t);
			$this->translate_expr($expr->child(), $code, $t, $expr->child()->token());
			return $code;
		}

		protected function translate_binary_expression(&$expr, &$code) {
			$t = $expr->token();
			$op = $this->keyword($t);

			switch ($t) {
			case '=':  case '+=': case '-=': case '*=': case '/=': case '%=':  case '^=':  case '.+=':
			case '+':  case '-':  case '*':	 case '/':  case '%':  case '^':
			case '==': case '!=': case '>':	 case '>=': case '<':  case '<=':
			case '&&': case '||':
				$this->translate_expr($expr->left(), $code, $t, $expr->left()->token());
				$code .= " $op ";
				$this->translate_expr($expr->right(), $code, $t, $expr->right()->token());
				break;

			case '[]': case '{}':
				if ($t == '[]') {
					$t1 = '[';  $t2 = ']';
				} else {
					$t1 = '{';  $t2 = '}';
				}
				$this->translate_expr($expr->left(), $code, $t, $expr->left()->token());
				$code .= $this->keyword($t1);
				$this->translate_expression($expr->right(), $code);
				$code .= $this->keyword($t2);
				break;

			case '[:]':
				$this->translate_expr($expr->left(), $code, $t, $expr->left()->token());
				$code .= $this->keyword('[:');
				$code .= $expr->right()->value();
				$code .= $this->keyword(':]');
				break;

			default:
				assert(false);
			}
			return $code;
		}

		protected function translate_property_expression(&$expr, &$code) {
			$t = $expr->token();
			$op = $this->keyword($t);
			$this->translate_expr($expr->object(), $code, $t, $expr->object()->token());
			$code .= $op;
			$code .= $expr->property();
			return $code;
		}

		protected function translate_function_expression(&$expr, &$code) {
			$t = $expr->token();
			$op = $this->keyword($t);
			$code .= $expr->funcname() . '(';
			$comma = '';
			foreach($expr->arglist() as $arg_expr) {
				$code .= $comma;
				$comma = ', ';
				$this->translate_expression($arg_expr, $code);
			}
			$code .= ')';
			return $code;
		}


		protected function translate_conditional_expression(&$expr, &$code) {
			$t = $expr->token();
			$op = $this->keyword($t);
			$this->translate_expr($expr->condition(), $code, $t, $expr->condition()->token());
			$code .= ' ? ';
			$this->translate_expr($expr->left(), $code, $t, $expr->left()->token());
			$code .= ' : ';
			$this->translate_expr($expr->right(), $code, $t, $expr->right()->token());
			return $code;
		}


		protected function translate_variable_expression(&$expr, &$code) {
			$code .= '$' . $expr->value();
			return $code;
		}

		protected function translate_string_expression(&$expr, &$code) {
			$code .= kwartz_inspect_str($expr->value());
			return $code;
		}

		protected function translate_numeric_expression(&$expr, &$code) {
			$code .= $expr->value();
			return $code;
		}

		protected function translate_boolean_expression(&$expr, &$code) {
			$code .= strtoupper($expr->value());
			return $code;
		}

		protected function translate_null_expression(&$expr, &$code) {
			$code .= 'NULL';
			return $code;
		}



		protected function translate_print_statement(&$stmt, &$code, $depth) {
			foreach ($stmt->expressions() as $expr) {
				if (($t = $expr->token()) == 'string') {
					$code .= $expr->value();
				} else {
					$code .= '<?php echo ';
					$this->translate_expression($expr, $code);
					$code .= '; ?>';
				}
			}
			return $code;
		}

		protected function translate_set_statement(&$stmt, &$code, $depth) {
			$this->add_indent($code, $depth);
			$expr = $stmt->assign_expr();
			$code .= "<?php ";
			$this->translate_expression($expr, $code);
			$code .= "; ?>\n";
			return $code;
		}

		protected function translate_if_statement(&$stmt, &$code, $depth) {
			$this->add_indent($code, $depth);
			$code .= "<?php if (";
			$this->translate_expression($stmt->condition(), $code);
			$code .= ") { ?>\n";
			$this->translate_statement($stmt->then_block(), $code, $depth+1);
			$st = $stmt;
			while (($st = $st->else_stmt()) != NULL && $st->token() == ':if') {
				$this->add_indent($code, $depth);
				$code .= "<?php } elseif (";
				$this->translate_expression($st->condition(), $code);
				$code .= ") { ?>\n";
				$this->translate_statement($st->then_block(), $code, $depth+1);
			}
			if ($st) {
				//assert($st.token() == '<<block>>');
				$this->add_indent($code, $depth);
				$code .= "<?php } else { ?>\n";
				$this->translate_statement($st, $code, $depth+1);
			}
			$this->add_indent($code, $depth);
			$code .= "<?php } ?>\n";
			return $code;
		}

		protected function translate_foreach_statement(&$stmt, &$code, $depth) {
			$this->add_indent($code, $depth);
			$code .= "<?php foreach (";
			$this->translate_expression($stmt->list_expr(), $code);
			$code .= " as ";
			$this->translate_expression($stmt->loopvar_expr(), $code);
			$code .= ") { ?>\n";
			$this->translate_statement($stmt->body_block(), $code, $depth+1);
			$this->add_indent($code, $depth);
			$code .= "<?php } ?>\n";
			return $code;
		}

		protected function translate_while_statement(&$stmt, &$code, $depth) {
			$this->add_indent($code, $depth);
			$code .= "<?php while (";
			$this->translate_expression($stmt->condition(), $code);
			$code .= ") { ?>\n";
			$this->translate_statement($stmt->body_block(), $code, $depth+1);
			$this->add_indent($code, $depth);
			$code .= "<?php } ?>\n";
			return $code;
		}

		protected function translate_macro_statement(&$stmt, &$code, $depth) {
			//$this->add_indent($code, $depth);
			//$this->add_macro($stmt->macro_name(), $stmt->body_block());
			# do nothing
			return $code;
		}

		protected function translate_expand_statement(&$stmt, &$code, $depth) {
			$block = $this->macro($stmt->macro_name());
			if (! $block) {
				$msg = "macro '{$stmt->macro_name()}' not defined.";
				throw new KwartzTranslationError($msg, $this);
			}
			$this->translate_statement($block, $code, $depth);
			return $code;
		}

		protected function translate_block_statement(&$block_stmt, &$code, $depth) {
			foreach ($block_stmt->statements() as $stmt) {
				$this->translate_statement($stmt, $code, $depth);
			}
			return $code;
		}

		protected function translate_rawcode_statement(&$stmt, &$code, $depth) {
			$this->add_indent($code, $depth);
			$code .= $stmt->rawcode();
			$code .= "\n";
			return $code;
		}
	}


// }  // end of namespace Kwartz
?>