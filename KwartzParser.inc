<?php

###
### KwartzParser.inc
###

require_once('KwartzException.inc');
require_once('KwartzElement.inc');
require_once('KwartzScanner.inc');

//namespace Kwartz {

	class KwartzParserException extends KwartzException {
		private $linenum;
		private $scanner;

		function __construct($prefix, $msg, $scanner, $linenum=NULL) {
			if (! $linenum) {
				$linenum = $scanner->linenum();
			}
			parent::__construct("{$prefix} (line {$linenum}): " . $msg);
			$this->scanner = $scanner;
			$this->linenum = $linenum;
		}
	}

	class KwartzSyntaxError extends KwartzParserException {
		function __construct($msg, $linenum) {
			parent::__construct('SyntaxError', $msg, $linenum);
		}
	}

	class KwartzSemanticError extends KwartzParserException {
		function __construct($msg, $linenum) {
			parent::__construct('SemanticError', $msg, $linenum);
		}
	}


	##
	## ex.
	##   $input   = "if ($foo > 0) { echo $foo; }";
	##   $scanner = new KwartzScanner($input);
	##   $parser  = new KwartzParser($scanner);
	##   $block_stmt = $parser.parse_all();
	##
	class KwartzParser {
		## instance vars
		private $scanner;
		private $element_name_stack;
		private $current_element_name;

		function __construct($scanner) {
			$this->scanner = $scanner;
			$this->scan();
			$this->element_name_stack = array();
		}

		private function token() {
			return $this->scanner->token();
		}

		private function token_str() {
			return $this->scanner->token_str();
		}

		private function scan() {
			return $this->scanner->scan();
		}

		private function value() {
			return $this->scanner->token_str();
		}


		## * BNF:
		##    item ::= variable | function '(' [expr {',' expr}] ')' | '(' expression ')'
		function parse_item() {
			$t = $this->token();
			if ($t == 'name') {
				$name = $this->value();
				$this->scan();
				if ($this->token() != '(') {		# variable
					$expr = new KwartzVariableExpression($name);
				} else {				# function
					$arglist = array();
					$this->scan();
					if ($this->token() != ')') {
						$arg_expr = $this->parse_expression();
						$arglist[] = $arg_expr;
						while ($this->token() == ',') {
							$this->scan();
							$arg_expr = $this->parse_expression();
							$arglist[] = $arg_expr;
						}
					}
					if ($this->token() != ')') {
						$msg = "function '{$name}(' is not closed.";
						throw new KwartzSyntaxError($msg, $this->scanner);
					}
					$this->scan();
					$expr = new KwartzFunctionExpression($name, $arglist);
				}
			} elseif ($t == '(') {
				$this->scan();
				$expr = $this->parse_expression();
				if ($this->token() != ')') {
					$msg = "')' expected.";
					throw new KwartzSyntaxError($msg, $this->scanner);
				}
				$this->scan();
			} else {
				# unreachable
				assert(false);
			}
			return $expr;
		}


		## * BNF:
		##    array ::= item | post[expr] | post{expr} | post[:name] | post.property
		##	    ::= item { [expr] | {expr} | [:name] | .propperty }
		function parse_array() {
			$expr = $this->parse_item();
			while (1) {
				if (($t = $this->token()) == '[') {
					$this->scan();
					$index_expr = $this->parse_expression();
					if ($this->token() != ']') {
						$msg = "array '[' is not closed.";
						throw new KwartzSyntaxError($msg, $this->scanner);
					}
					$this->scan();
					$expr = new KwartzBinaryExpression('[]', $expr, $index_expr);
				} elseif ($t == '{') {
					$this->scan();
					$key_expr = $this->parse_expression();
					if ($this->token() != '}') {
						$msg = "hash '{' is not closed.";
						throw new KwartzSyntaxError($msg, $this->scanner);
					}
					$this->scan();
					$expr = new KwartzBinaryExpression('{}', $expr, $key_expr);
				} elseif ($t == '[:') {
					$this->scan();
					if ($this->token() != 'name') {
						$msg = "'[:' requires a word.";
						throw new KwartzSyntaxError($msg, $this->scanner);
					}
					$word = $this->value();
					$key_expr = new KwartzStringExpression($word);
					$this->scan();
					if ($this->token() != ']') {
						$msg = "'[:' is not closed.";
						throw new KwartzSyntaxError($msg, $this->scanner);
					}
					$this->scan();
					$expr = new KwartzBinaryExpression('[:]', $expr, $key_expr);
				} elseif ($t == '.') {
					$this->scan();
					if ($this->token() != 'name') {
						$msg = "invalid property name.";
						throw new KwartzSyntaxError($msg, $this->scanner);
					}
					$property = $this->value();
					$this->scan();
					$expr = new KwartzPropertyExpression('.', $expr, $property);
				} else {
					break;
				}
			}
			return $expr;
		}


		## * BNF:
		##    factor ::= array | number | string | '-' factor | '!' factor | true | false | nil
		function parse_factor() {
			switch ($t = $this->token()) {
			case 'name':
			case '(':
				$expr = $this->parse_array();
				break;
			case 'integer':
				//$expr = new KwartzIntegerExpression($this->value());
				$expr = new KwartzNumericExpression($this->value());
				$this->scan();
				break;
			case 'float':
				//$expr = new KwartzFloatExpression($this->value());
				$expr = new KwartzNumericExpression($this->value());
				$this->scan();
				break;
			case 'string':
				$expr = new KwartzStringExpression($this->value());
				$this->scan();
				break;
			case 'true':
			case 'false':
				$expr = new KwartzBooleanExpression($t);
				$this->scan();
				break;
			case 'null':
			case 'nil':
				$expr = new KwartzNullExpression($t);
				$this->scan();
				break;
			case '-':
			case '!':
				$this->scan();
				$expr = $this->parse_factor();
				if ($t == '-') { $t = '-.'; }
				$expr = new KwartzUnaryExpression($t, $expr);
				break;
			case 'empty':
				$msg = "'empty' is allowed only in right-side of '==' or '!='.";
				throw new KwartzSyntaxError($msg, $this->scanner);
			default:
				echo "*** debug: t=", var_dump($t), "\n";
				assert(false);
			}
			return $expr;
		}


		## * BNF:
		##    term ::= factor '*' term | factor '/' term | factor '%' term | factor
		##	   ::= factor { ('*' | '/' | '%') factor }*
		function parse_term() {
			$expr = $this->parse_factor();
			while (($t = $this->token()) == '*' || $t == '/' || $t == '%') {
				$this->scan();
				$expr2 = $this->parse_factor();
				$expr = new KwartzBinaryExpression($t, $expr, $expr2);
			}
			return $expr;
		}


		## * BNF:
		##    arith ::= term '+' arith | term '-' arith | term '.+' arith
		##	    ::= term { ('+' | '-' | '.+') term }
		function parse_arith() {
			$expr = $this->parse_term();
			while (($t = $this->token()) == '+' || $t == '-' || $t == '.+') {
				$this->scan();
				$expr2 = $this->parse_term();
				$expr = new KwartzBinaryExpression($t, $expr, $expr2);
			}
			return $expr;
		}


		## * BNF:
		##    compare-op ::=   '==' |  '!=' |  '>' |  '>=' |  '<' |  '<='
		##		    | '.==' | '.!=' | '.>' | '.>=' | '.<' | '.<='
		##    compare	 ::= arith compare-op arith | arith ['==' | '!='] 'empty'
		function parse_compare() {
			$expr = $this->parse_arith();
			switch ($t = $this->token()) {
			case '==':
			case '!=':
			case '>':
			case '>=':
			case '<':
			case '<=':
				$this->scan();
				if ($this->token() == 'empty' && ($t == '==' || $t == '!=')) {
					$this->scan();
					$t2 = $t == '==' ? 'empty' : 'notempty';
					$expr = new KwartzUnaryExpression($t2, $expr);
				} else {
					$expr2 = $this->parse_arith();
					$expr = new KwartzBinaryExpression($t, $expr, $expr2);
				}
			}
			return $expr;
		}


		## * BNF:
		##    logical-and ::= compare '&&' logical-and
		##		  ::= compare { '&&' compare }
		function parse_logical_and() {
			$expr = $this->parse_compare();
			while ($this->token() == '&&') {
				$this->scan();
				$expr2 = $this->parse_compare();
				$expr = new KwartzBinaryExpression('&&', $expr, $expr2);
			}
			return $expr;
		}


		## * BNF:
		##    logical-or ::= logical-and '||' logical-or
		##		 ::= logical-and { '||' logical-and }
		function parse_logical_or() {
			$expr = $this->parse_logical_and();
			while ($this->token() == '||') {
				$this->scan();
				$expr2 = $this->parse_logical_and();
				$expr = new KwartzBinaryExpression('||', $expr, $expr2);
			}
			return $expr;
		}


		## * BNF:
		##    conditional ::= logical-or | logical-or '?' logical-or ':' logical-or
		##		       ::= logical-or { '?' logical-or ':' logical-or }
		function parse_conditional() {
			$expr = $this->parse_logical_or();
			while ($this->token() == '?') {
				$cond = $expr;
				$this->scan();
				$left = $this->parse_logical_or();
				if ($this->token() != ':') {
					throw KwartzSyntaxError("':' expected.", $this->scanner);
				}
				$this->scan();
				$right = $this->parse_logical_or();
				$expr = new KwartzConditionalExpression('?', $cond, $left, $right);
			}
			return $expr;
		}

		## * BNF:
		##    assignment ::= conditional-expr  assign-op assignment | conditional-expr
		##		 ::= conditional-expr [ assign-op conditional-expr ]
		function parse_assignment() {
			$expr = $this->parse_conditional();
			switch ($t = $this->token()) {
			case '=' :
			case '+=' :
			case '-=' :
			case '*=' :
			case '/=' :
			case '%=' :
			case '^=' :
			case '.+=' :
				switch ($expr->token()) {
				case 'variable':
				case '[]':
				case '[:]':
				case '{}':
					# OK
					break;
				default:
					$msg = "cannot assign into invalid left-value.";
					throw new KwartzSemanticError($msg, $this->scanner);
				}
				$this->scan();
				$expr2 = $this->parse_assignment();
				$expr = new KwartzBinaryExpression($t, $expr, $expr2);
			}
			return $expr;
		}

		## * BNF:
		##    expression ::= assignment
		function parse_expression() {
			return $this->parse_assignment();
		}

		## * BNF:
		##    stmt	::= set-stmt | if-stmt | while-stmt | foreach-stmt
		##		   | print-stmt | macro-stmt | expand-stmt | rawcode-stmt
		##		   | print2-stmt
		function parse_statement() {
			switch ($t = $this->token()) {
			case ':print':
				$stmt = $this->parse_print_stmt();
				break;
			case ':set':
				$stmt = $this->parse_set_stmt();
				break;
			case ':if':
				$stmt = $this->parse_if_stmt();
				break;
			case ':foreach':
				$stmt = $this->parse_foreach_stmt();
				break;
			case ':macro':
				$stmt = $this->parse_macro_stmt();
				break;
			case ':expand':
				$stmt = $this->parse_expand_stmt();
				break;
			case '@':
				$stmt = $this->parse_expand2_stmt();
				break;
			case ':elem':
				$stmt = $this->parse_elem_stmt();
				break;
			case ':rawcode':
				$stmt = $this->parse_rawcode_stmt();
				break;
			default:
				return NULL;
			}
			return $stmt;
		}


		## * BNF:
		##    block-stmtt ::= stmt*
		function parse_block_stmt() {
			$list = array();
			while (($stmt = $this->parse_statement()) != NULL) {
				$list[] = $stmt;
			}
			return new KwartzBlockStatement($list);
		}


		## * BNF:
		##    set-stmt ::= ':set' '(' assignment ')'
		function parse_set_stmt() {
			if ($this->token() == ':set') {
				$this->scan();
				if ($this->token() != '(') {
					$msg = "':set' requires '('.";
					throw new KwartzSyntaxError($msg, $this->scanner);
				}
				$this->scan();
				$expr = $this->parse_expression();
				if ($this->token() != ')') {
					$msg = "':set(' is not closed by ')'.";
					throw new KwartzSyntaxError($msg, $this->scanner);
				}
				$this->scan();
				return new KwartzSetStatement($expr);
			}
			assert(false);
		}


		## * BNF:
		##    if-stmt ::= ':if' '(' expression ')' stmt-list
		##		 { ':elsif' '(' expression ')' stmt-list }
		##		 [ ':else' stmt-list ] ':end'
		function parse_if_stmt() {
			if (($t = $this->token()) == ':if' || $t == ':elseif') {
				$linenum = $this->scanner->linenum();
				$this->scan();
				if ($this->token() != '(') {
					$msg = "'{$t}' requires '('.";
					throw new KwartzSyntaxError($msg, $this->scanner);
				}
				$this->scan();
				$cond_expr = $this->parse_expression();
				if ($this->token() != ')') {
					$msg = "'{$t}(' is not closed by ')'.";
					throw new KwartzSyntaxError($msg, $this->scanner);
				}
				$this->scan();
				$then_block = $this->parse_block_stmt();
				if (($t = $this->token()) == ':elseif') {
					$else_stmt = $this->parse_if_stmt();
				} elseif ($t == ':else') {
					$this->scan();
					$else_stmt = $this->parse_block_stmt();
				} else {
					$else_stmt = NULL;
				}
				if ($t != ':elseif') {
					if ($this->token() != ':end') {
						$msg = "':if' (at line $linenum) is not closed by ':end'.";
						throw new KwartzSyntaxError($msg, $this->scanner);
					}
				}
				return new KwartzIfStatement($cond_expr, $then_block, $else_stmt);
			}
			assert(false);
		}

		## * BNF:
		##    while-stmt ::= ':while' '(' assignment ')' stmt-list ':end'
		function parse_while_stmt() {
			if ($this->token() == ':while') {
				$linenum = $this->scanner->linenum();
				$this->scan();
				if ($this->token() != '(') {
					$msg = "':while' requires '('.";
					throw new KwartzSyntaxError($msg, $this->scanner);
				}
				$this->scan();
				$cond_expr = $this->parse_expression();
				if ($this->token() != ')') {
					$msg = "':while(' is not closed by ')'.";
					throw new KwartzSyntaxError($msg, $this->scanner);
				}
				$this->scan();
				$body_block = $this->parse_block_stmt();
				if ($this->token() != ':end') {
					$msg = "':while' (at line $linenum) is not closed by ':end'.";
					throw new KwartzSyntaxError($msg, $this->scanner);
				}
				$this->scan();
				return new KwartzWhileStatement($cond_expr, $body_block);
			}
			assert(false);
		}

		## * BNF:
		##    foreach-stmt ::= ':foreach' '(' expression '=' expression ')'
		##		       stmt-list ':end'
		function parse_foreach_stmt() {
			if ($this->token() == ':foreach') {
				$linenum = $this->scanner->linenum();
				$this->scan();
				if ($this->token() != '(') {
					$msg = "':foreach' requires '('.";
					throw new KwartzSyntaxError($msg, $this->scanner);
				}
				$this->scan();
				$assign_expr = $this->parse_assignment();
				if ($this->token() != ')') {
					$msg = "':foreach(' is not closed by ')'.";
					throw new KwartzSyntaxError($msg, $this->scanner);
				}
				$this->scan();
				if ($assign_expr->token() != '=') {
					$msg = "':foreach' requires normal assignment expression (ex. 'item = list').";
					throw new KwartzSyntaxError($msg, $this->scanner);
				}
				$loopvar_expr = $assign_expr->left();
				$list_expr    = $assign_expr->right();
				if ($loopvar_expr->token() != 'variable') {
					$msg = "invalid loop variable.";
					throw new KwartzSyntaxError($msg, $this->scanner);
				}
				$body_block = $this->parse_block_stmt();
				if ($this->token() != ':end') {
					$msg = "':foreach' (at line $linenum) is not closed by ':end'.";
					throw new KwartzSyntaxError($msg, $this->scanner);
				}
				return new KwartzForeachStatement($loopvar_expr, $list_expr, $body_block);
			}
			assert(false);
		}

		## * BNF:
		##    print-stmt ::= ':print'  '(' expression { ',' expression } ')'
		function parse_print_stmt() {
			if ($this->token() == ':print') {
				$linenum = $this->scanner->linenum();
				$this->scan();
				if ($this->token() != '(') {
					$msg = "':print' requires '('.";
					throw new KwartzSyntaxError($msg, $this->scanner);
				}
				$this->scan();
				$expr_list = array();
				if ($this->token() != ')') {
					while (true) {
						$expr = $this->parse_expression();
						$expr_list[] = $expr;
						if ($this->token() != ',') { break; }
						$this->scan();
					}
				}
				if ($this->token() != ')') {
					$msg = "':print(' is not closed by ')'.";
					throw new KwartzSyntaxError($msg, $this->scanner);
				}
				$this->scan();
				return new KwartzPrintStatement($expr_list);
			}
			assert(false);
		}

		## * BNF:
		##    macro-stmt ::= ':macro' '(' name ')' stmt-list ':end'
		##    elem-stmt	 ::= ':elem'  '(' name ')' stmt-list ':end'
		function parse_macro_stmt() {
			if (($t = $this->token()) == ':macro' || $t == ':elem') {
				$linenum = $this->scanner->linenum();
				$this->scan();
				if ($this->token() != '(') {
					$msg = "'$t' requires '('.";
					throw new KwartzSyntaxError($msg, $this->scanner);
				}
				$this->scan();
				if ($this->token() != 'name') {
					echo "*** debug: thos->token() = {$this->token()}\n";
					$msg = "'$t' should take a name.";
					throw new KwartzSyntaxError($msg, $this->scanner);
				}
				$name = $this->value();
				$macro_name = $t == ':elem' ? ('elem_' . $name) : $name;
				$this->scan();
				if ($this->token() != ')') {
					$msg = "'$t(' is not closed by ')'.";
					throw new KwartzSyntaxError($msg, $this->scanner);
				}
				$this->scan();
				if ($t == ':elem') {
					array_push($this->element_name_stack, $name);
					$this->current_element_name = $name;
					$body_block = $this->parse_block_stmt();
					array_pop($this->element_name_stack);
					$this->current_element_name = end($this->element_name_stack);
				} else {
					$body_block = $this->parse_block_stmt();
				}
				if ($this->token() != ':end') {
					$msg = "'$t' (at line $linenum) is not closed by ':end'.";
					throw new KwartzSyntaxError($msg, $this->scanner);
				}
				$this->scan();
				return new KwartzMacroStatement($macro_name, $body_block);
			}
			assert(false);
		}

		## * BNF:
		##    elem-stmt	 ::= ':elem'  '(' name ')' stmt-list ':end'
		function parse_elem_stmt() {
			if ($this->token() == ':elem') {
				return $this->parse_macro_stmt();
			}
			assert(false);
		}

		## * BNF:
		##    expand-stmt ::= ':expand' '(' name ')'
		##
		function parse_expand_stmt() {
			if ($this->token() == ':expand') {
				$this->scan();
				if ($this->token() != '(') {
					$msg = "':expand' requires '('.";
					throw new KwartzSyntaxError($msg, $this->scanner);
				}
				$this->scan();
				if ($this->token() != 'name') {
					$msg = "':expand()' requires macro-name.";
					throw new KwartzSyntaxError($msg, $this->scanner);
				}
				$macro_name = $this->value();
				$this->scan();
				if ($this->token() != ')') {
					$msg = "':expand(' is not closed by ')'.";
					throw new KwartzSyntaxError($msg, $this->scanner);
				}
				$this->scan();
				return new KwartzExpandStatement($macro_name);
			}
			assert(false);
		}

		## * BNF:
		##     expand2-stmt ::= '@' macro-name
		##
		function parse_expand2_stmt() {
			if ($this->token() == '@' || $this->token() == ':rawcode2') {
				$macro_name = $this->value();
				$this->scan();
				switch ($macro_name) {
				case 'stag':
				case 'etag':
				case 'cont':
					if (! $this->current_element_name) {
						$msg = "'@{$macro_name}' should be in ':elem' statement.";
						throw new KwartzSemanticError($msg, $this->scanner);
					}
					$macro_name .= '_';
					$macro_name .= $this->current_element_name;
				}
				return new KwartzExpandStatement($macro_name);
			}
			assert(false);
		}

		## * BNF:
		##    rawcode ::= ':::' raw-string | ':rawcode' '(' string ')'
		function parse_rawcode_stmt() {
			if ($this->token() == ':rawcode' || $this->token() == ':::') {
				$rawcode = $this->value();
				$this->scan();
				return new KwartzRawcodeStatement($rawcode);
			}
			assert(false);
		}

		## * BNF:
		##    load-stmt ::= ':load' '(' string ')'
		function parse_load_stmt() {
			if ($this->token() == ':load') {
				$this->scan();
				if ($this->token() != '(') {
					$msg = "':load' requires '('.";
					throw new KwartzSyntaxError($msg, $this->scanner);
				}
				$this->scan();
				if ($this->token() != 'string') {
					$msg = "':load()' should take filename as a string.";
					throw new KwartzSyntaxError($msg, $this->scanner);
				}
				$filename = $this->value();
				$this->scan();
				if ($this->token() != ')') {
					$msg = "':load(' is not closed by ')'.";
					throw new KwartzSyntaxError($msg, $this->scanner);
				}
				$this->scan();
				#
				//return new KwartzLoadStatement($filename);
				if (! file_exists($filename)) {
					$msg = "load file '$filename' is not exist.";
					throw new KwartzSemanticError($msg, $this->scanner);
				}
				$input	 = file_get_contents($filename);
				$scanner = new KwartzScanner($input);
				$parser	 = new KwartzParser($scanner);
				$block	 = $parser->parse_all();
				return $block;
			}
			assert(false);
		}

		##
		##
		function parse_all() {
			return $this->parse_block_stmt();
		}

	}

//}  // end of namespace Kwartz
?>