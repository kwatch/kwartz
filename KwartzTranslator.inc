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
		abstract function translate_expression($expr);
		abstract function translate_statement($stmt, $depth);

		## should return code string
		abstract function translate();
	}

	abstract class KwartzBaseTranslator extends KwartzTranslator {
		protected $code = "";
		protected $block;
		protected $macro_stmt_hash = array();
		protected $nl = "\n";			// newline char ("\n" or "\r\n")
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
		
		function code() { return $this->code; }
		
		function set_newline_char($newline) { $this->nl = $newline; }
		function newline_char() { return $this->nl; }
		function nl()           { return $this->nl; }

		//function translate_node($expr_or_stmt, $depth) {
		//	$class_name = get_class($expr_or_stmt);
		//	$method_name = $this->dispatcher[$class_name];
		//	return $this->$method_name($expr_or_stmt, $depth);
		//}
		


		### --------------------
		### utility funcitions
		### --------------------

		protected function add_macro($macro_name, $block) {
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
		
		protected function add_indent($depth) {
			if ($this->code && $this->code[strlen($this->code)-1] == "\n") {
				$this->code .= $this->indent($depth);
			}
		}
		


		### --------------------
		### translate expression
		### --------------------

		abstract protected function keyword($token);

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
			//$this->code = "";
			$this->translate_statement($this->block, 0);
			return $this->code;
		}



		### --------------------
		### translate expression
		### --------------------

		function translate_expression($expr) {
			$class_name = get_class($expr);
			$method_name = $this->dispatcher[$class_name];
			$this->$method_name($expr);
		}

		protected function translate_expr($expr, $parent_token, $child_token) {
			if ($this->priorities[$parent_token] > $this->priorities[$child_token]) {
				$this->code .= '(';
				$this->translate_expression($expr);
				$this->code .= ')';
			} else {
				$this->translate_expression($expr);
			}
		}

		
		protected function translate_unary_expression($expr) {
			$t = $expr->token();
			$this->code .= $this->keyword($t);
			$this->translate_expr($expr->child(), $t, $expr->child()->token());
		}

		protected function translate_binary_expression($expr) {
			$t = $expr->token();
			$op = $this->keyword($t);

			switch ($t) {
			case '=':  case '+=': case '-=': case '*=': case '/=': case '%=':  case '^=':  case '.+=':
			case '+':  case '-':  case '*':	 case '/':  case '%':  case '^':   case '.+':
			case '==': case '!=': case '>':	 case '>=': case '<':  case '<=':
			case '&&': case '||':
				$this->translate_expr($expr->left(), $t, $expr->left()->token());
				$this->code .= " $op ";
				$this->translate_expr($expr->right(), $t, $expr->right()->token());
				break;

			case '[]': case '{}':
				if ($t == '[]') {
					$t1 = '[';  $t2 = ']';
				} else {
					$t1 = '{';  $t2 = '}';
				}
				$this->translate_expr($expr->left(), $t, $expr->left()->token());
				$this->code .= $this->keyword($t1);
				$this->translate_expression($expr->right());
				$this->code .= $this->keyword($t2);
				break;

			case '[:]':
				$this->translate_expr($expr->left(), $t, $expr->left()->token());
				$this->code .= $this->keyword('[:');
				$this->code .= $expr->right()->value();
				$this->code .= $this->keyword(':]');
				break;

			default:
				assert(false);
			}
		}

		protected function translate_property_expression($expr) {
			$t = $expr->token();
			$op = $this->keyword($t);
			$this->translate_expr($expr->object(), $t, $expr->object()->token());
			$this->code .= $op;
			$this->code .= $expr->property();
		}

		protected function translate_function_expression($expr) {
			$t = $expr->token();
			$op = $this->keyword($t);
			$this->code .= $expr->funcname() . $this->keyword('(');
			$comma = '';
			foreach($expr->arglist() as $arg_expr) {
				$this->code .= $comma;
				$comma = ', ';
				$this->translate_expression($arg_expr);
			}
			$this->code .= $this->keyword(')');
		}


		protected function translate_conditional_expression($expr) {
			$t = $expr->token();
			$op = $this->keyword($t);
			$this->translate_expr($expr->condition(), $t, $expr->condition()->token());
			$this->code .= ' ? ';
			$this->translate_expr($expr->left(), $t, $expr->left()->token());
			$this->code .= ' : ';
			$this->translate_expr($expr->right(), $t, $expr->right()->token());
		}


		protected function translate_variable_expression($expr) {
			$this->code .= $expr->value();
		}

		protected function translate_string_expression($expr) {
			$this->code .= kwartz_inspect_str($expr->value());
		}

		protected function translate_numeric_expression($expr) {
			$this->code .= $expr->value();
		}

		protected function translate_boolean_expression($expr) {
			$this->code .= $this->keyword($expr->value());
		}

		protected function translate_null_expression($expr) {
			$this->code .= $this->keyword($expr->value());
		}


		### --------------------
		### translate statement
		### --------------------

		function translate_statement($stmt, $depth) {
			$class_name = get_class($stmt);
			$method_name = $this->dispatcher[$class_name];
			$this->$method_name($stmt, $depth);
		}

		protected function translate_print_statement($stmt, $depth) {
			foreach ($stmt->arglist() as $expr) {
				if (($t = $expr->token()) == 'string') {
					$this->code .= $expr->value();
				} else {
					$this->code .= $this->keyword(':print');
					$this->translate_expression($expr);
					$this->code .= $this->keyword(':endprint');
				}
			}
		}

		protected function translate_set_statement($stmt, $depth) {
			$this->add_indent($depth);
			$expr = $stmt->assign_expr();
			$this->code .= $this->keyword(':set');
			$this->translate_expression($expr);
			$this->code .= $this->keyword(':endset');
			$this->code .= $this->nl;
		}

		protected function translate_if_statement($stmt, $depth) {
			$this->add_indent($depth);
			$this->code .= $this->keyword(':if');
			$this->translate_expression($stmt->condition());
			$this->code .= $this->keyword(':then');
			$this->code .= $this->nl;
			$this->translate_statement($stmt->then_block(), $depth+1);
			$st = $stmt;
			while (($st = $st->else_stmt()) != NULL && $st->token() == ':if') {
				$this->add_indent($depth);
				$this->code .= $this->keyword(':elseif');
				$this->translate_expression($st->condition());
				$this->code .= $this->keyword(':then');
				$this->code .= $this->nl;
				$this->translate_statement($st->then_block(), $depth+1);
			}
			if ($st) {
				//assert($st.token() == '<<block>>');
				$this->add_indent($depth);
				$this->code .= $this->keyword(':else');
				$this->code .= $this->nl;
				$this->translate_statement($st, $depth+1);
			}
			$this->add_indent($depth);
			$this->code .= $this->keyword(':endif');
			$this->code .= $this->nl;
		}

		protected function translate_foreach_statement($stmt, $depth) {
			$this->add_indent($depth);
			$this->code .= $this->keyword(':foreach');
			$this->translate_expression($stmt->loopvar_expr());
			$this->code .= $this->keyword(':in');
			$this->translate_expression($stmt->list_expr());
			$this->code .= $this->keyword(':doforeach');
			$this->code .= $this->nl;
			$this->translate_statement($stmt->body_block(), $depth+1);
			$this->add_indent($depth);
			$this->code .= $this->keyword(':endforeach');
			$this->code .= $this->nl;
		}

		protected function translate_while_statement($stmt, $depth) {
			$this->add_indent($depth);
			$this->code .= $this->keyword(':while');
			$this->translate_expression($stmt->condition());
			$this->code .= $this->keyword(':dowhile');
			$this->code .= $this->nl;
			$this->translate_statement($stmt->body_block(), $depth+1);
			$this->add_indent($depth);
			$this->code .= $this->keyword(':endwhile');
			$this->code .= $this->nl;
		}

		protected function translate_macro_statement($stmt, $depth) {
			//$this->add_indent($depth);
			//$this->add_macro($stmt->macro_name(), $stmt->body_block());
			# do nothing
		}

		protected function translate_expand_statement($stmt, $depth) {
			$block = $this->macro($stmt->macro_name());
			if (! $block) {
				$msg = "macro '{$stmt->macro_name()}' not defined.";
				throw new KwartzTranslationError($msg, $this);
			}
			$this->translate_statement($block, $depth);
		}

		protected function translate_block_statement($block_stmt, $depth) {
			foreach ($block_stmt->statements() as $stmt) {
				$this->translate_statement($stmt, $depth);
			}
		}

		protected function translate_rawcode_statement($stmt, $depth) {
			$this->add_indent($depth);
			$this->code .= $stmt->rawcode();
			$this->code .= $this->nl;
		}
		
	}


	class KwartzPhpTranslator extends KwartzBaseTranslator {
		private	$keywords = array(
			':if'         => '<?php if (',
			':then'       => ') { ?>',
			':else'       => '<?php } else { ?>',
			':elseif'     => '<?php } elseif (',
			':endif'      => '<?php } ?>',
			
			':while'      => '<?php while (',
			':dowhile'    => ') { ?>',
			':endwhile'   => '<?php } ?>',
			
			':foreach'    => '<?php foreach (',
			':in'         => ' as ',
			':doforeach'  => ') { ?>',
			':endforeach' => '<?php } ?>',
			
			':set'        => '<?php ',
			':endset'     => '; ?>',
			
			':print'      => '<?php echo ',
			':endprint'   => '; ?>',

			':print'      => '<?php echo ',
			':endprint'   => '; ?>',
			':print2'     => '<?php echo htmlspecialchars(',
			':endprint2'  => '); ?>',
			
			':include'    => '<?php include(',
			':endinclude' => '); ?>',
			
			'true'        => 'TRUE',
			'false'       => 'FALSE',
			'null'        => 'NULL',

			'-.'   => '-',
			'.+'   => '.',
			'.+='  => '.=',
			'.'    => '->',
			'{'    => '[',
			'}'    => ']',
			'[:'   => "['",
			':]'   => "']",
			
			'E('   => 'htmlspecialchars(',
			'E)'   => ')',
		);
		
		function __construct($block) {
			parent::__construct($block);
		}

		protected function keyword($token) {
			return array_key_exists($token, $this->keywords) ? $this->keywords[$token] : $token;
		}

		protected function translate_variable_expression($expr) {
			$this->code .= '$' . $expr->value();
		}

		protected function translate_foreach_statement($stmt, $depth) {
			$this->add_indent($depth);
			$this->code .= $this->keyword(':foreach');
			$this->translate_expression($stmt->list_expr());
			$this->code .= $this->keyword(':in');
			$this->translate_expression($stmt->loopvar_expr());
			$this->code .= $this->keyword(':doforeach');
			$this->code .= $this->nl();
			$this->translate_statement($stmt->body_block(), $depth+1);
			$this->add_indent($depth);
			$this->code .= $this->keyword(':endforeach');
			$this->code .= $this->nl();
		}

	}

// }  // end of namespace Kwartz
?>