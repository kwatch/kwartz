<?php

###
### KwartzParser.inc
###

require_once('KwartzException.inc');
require_once('KwartzNode.inc');
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
	##   $block_stmt = $parser.parse();
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

		protected function token() {
			return $this->scanner->token();
		}

		protected function token_str() {
			return $this->scanner->token_str();
		}

		protected function scan() {
			return $this->scanner->scan();
		}

		protected function value() {
			return $this->scanner->token_str();
		}

		protected function token_check($token, $error_msg) {
			if ($this->token() != $token) {
				$this->syntax_error($error_msg);
			}
		}

		protected function token_check2($token, $error_msg) {
			if ($this->token() != $token) {
				$this->syntax_error($error_msg);
			}
			$this->scan();
		}

		protected function syntax_error($error_msg) {
			throw new KwartzSyntaxError($error_msg, $this->scanner);
		}

		protected function semantic_error($error_msg) {
			throw new KwartzSemanticError($error_msg, $this->scanner);
		}


		## * BNF:
		##    item ::= '$' variable | function '(' [expr {',' expr}] ')' | '(' expression ')'
		function parse_item($flag_php_mode=FALSE) {
			switch ($t = $this->token()) {
			case '$':				# variable
				if (! $flag_php_mode) {
					$this->syntax_error("'$': invalid character.");
				}
				$this->scan();
				$this->token_check('name', "'$' requires variable name.");
				$name = $this->value();
				$this->scan();
				return new KwartzVariableExpression($name);

			case 'name':				# function
				$name = $this->value();
				$this->scan();
				if ($this->token() != '(') {
					if ($flag_php_mode) {
						$this->syntax_error("'$name' invalid token: should be '\${$name}' or '{$name}()'.");
					} else {
						return new KwartzVariableExpression($name);
					}
				}
				## function
				$this->scan();
				$arglist = array();
				if ($this->token() != ')') {
					$arg_expr = $this->parse_expression($flag_php_mode);
					$arglist[] = $arg_expr;
					while ($this->token() == ',') {
						$this->scan();
						$arg_expr = $this->parse_expression($flag_php_mode);
						$arglist[] = $arg_expr;
					}
				}
				$this->token_check2(')', "function '$name(' is not closed by ')'.");
				return new KwartzFunctionExpression($name, $arglist);

			case '(':
				$this->scan();
				$expr = $this->parse_expression($flag_php_mode);
				$this->token_check2(')', "')' expected.");
				return $expr;
			}
			echo "*** assert(false): token=$t\n";
			assert(false);
		}


		## * BNF:
		##    array ::= item | post '[' expr ']' | post '{' expr '}' | post '[:' name ']'
		##                   | post '.' property | post '->' property
		##	    ::= item { '[' expr ']' | '{' expr '}' | '[:' name ']' | '.' propperty | '->' propperty }
		function parse_array($flag_php_mode=FALSE) {
			$expr = $this->parse_item($flag_php_mode);
			$property_op = $flag_php_mode ? '->' : '.';
			while (1) {
				$t = $this->token();
				if ($t == '[') {
					$this->scan();
					$index_expr = $this->parse_expression($flag_php_mode);
					$this->token_check2(']', "array '[' is not closed.");
					$expr = new KwartzBinaryExpression('[]', $expr, $index_expr);
				} elseif ($t == '{') {
					$this->scan();
					$key_expr = $this->parse_expression($flag_php_mode);
					$this->token_check2('}', "hash '{' is not closed.");
					$expr = new KwartzBinaryExpression('{}', $expr, $key_expr);
				} elseif ($t == '[:') {
					$this->scan();
					$this->token_check('name', "'[:' requires a word.");
					$word = $this->value();
					$key_expr = new KwartzStringExpression($word);
					$this->scan();
					$this->token_check2(']', "'[:' is not closed.");
					$expr = new KwartzBinaryExpression('[:]', $expr, $key_expr);
				} elseif ($t == $property_op) {
					$this->scan();
					$this->token_check('name', "invalid property name.");
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
		function parse_factor($flag_php_mode=FALSE) {
			switch ($t = $this->token()) {
			case '$':
				if (! $flag_php_mode) {
					$this->syntax_error("'$': invalid character.");
				}
				$expr = $this->parse_array($flag_php_mode);
				break;
			case 'name':
			case '(':
				$expr = $this->parse_array($flag_php_mode);
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
			case 'TRUE':
			case 'FALSE':
				$expr = new KwartzBooleanExpression($t);
				$this->scan();
				break;
			case 'null':
			case 'nil':
			case 'NULL':
				$expr = new KwartzNullExpression($t);
				$this->scan();
				break;
			case '-':
			case '!':
				$this->scan();
				$expr = $this->parse_factor($flag_php_mode);
				if ($t == '-') { $t = '-.'; }
				$expr = new KwartzUnaryExpression($t, $expr);
				break;
			case 'empty':
				$msg = "'empty' is allowed only in right-side of '==' or '!='.";
				throw new KwartzSyntaxError($msg, $this->scanner);
			default:
				echo "*** assert(false): t=", var_dump($t), "\n";
				assert(false);
			}
			return $expr;
		}


		## * BNF:
		##    term ::= factor '*' term | factor '/' term | factor '%' term | factor
		##	   ::= factor { ('*' | '/' | '%') factor }*
		function parse_term($flag_php_mode=FALSE) {
			$expr = $this->parse_factor($flag_php_mode);
			while (($t = $this->token()) == '*' || $t == '/' || $t == '%') {
				$this->scan();
				$expr2 = $this->parse_factor($flag_php_mode);
				$expr = new KwartzBinaryExpression($t, $expr, $expr2);
			}
			return $expr;
		}


		## * BNF:
		##    arith ::= term '+' arith | term '-' arith | term '.+' arith
		##	    ::= term { ('+' | '-' | '.+') term }
		function parse_arith($flag_php_mode=FALSE) {
			$expr = $this->parse_term($flag_php_mode);
			$concat_op = $flag_php_mode ? '.' : '.+';
			$t = $this->token();
			while ($t == '+' || $t == '-' || $t == $concat_op) {
				if (! $flag_php_mode && $t == '.')  { break; }
				if (  $flag_php_mode && $t == '.+') { break; }
				$this->scan();
				$expr2 = $this->parse_term($flag_php_mode);
				$expr = new KwartzBinaryExpression($t, $expr, $expr2);
				$t = $this->token();
			}
			return $expr;
		}


		## * BNF:
		##    compare-op ::=   '==' |  '!=' |  '>' |  '>=' |  '<' |  '<='
		##		    | '.==' | '.!=' | '.>' | '.>=' | '.<' | '.<='
		##    compare	 ::= arith compare-op arith | arith ['==' | '!='] 'empty'
		function parse_compare($flag_php_mode=FALSE) {
			$expr = $this->parse_arith($flag_php_mode);
			switch ($t = $this->token()) {
			case '==': case '!=':
			case '>':  case '>=':
			case '<':  case '<=':
				$this->scan();
				if ($this->token() == 'empty' && ($t == '==' || $t == '!=')) {
					$this->scan();
					$t2 = $t == '==' ? 'empty' : 'notempty';
					$expr = new KwartzUnaryExpression($t2, $expr);
				} else {
					$expr2 = $this->parse_arith($flag_php_mode);
					$expr = new KwartzBinaryExpression($t, $expr, $expr2);
				}
			}
			return $expr;
		}


		## * BNF:
		##    logical-and ::= compare '&&' logical-and
		##		  ::= compare { '&&' compare }
		function parse_logical_and($flag_php_mode=FALSE) {
			$expr = $this->parse_compare($flag_php_mode);
			while ($this->token() == '&&') {
				$this->scan();
				$expr2 = $this->parse_compare($flag_php_mode);
				$expr = new KwartzBinaryExpression('&&', $expr, $expr2);
			}
			return $expr;
		}


		## * BNF:
		##    logical-or ::= logical-and '||' logical-or
		##		 ::= logical-and { '||' logical-and }
		function parse_logical_or($flag_php_mode=FALSE) {
			$expr = $this->parse_logical_and($flag_php_mode);
			while ($this->token() == '||') {
				$this->scan();
				$expr2 = $this->parse_logical_and($flag_php_mode);
				$expr = new KwartzBinaryExpression('||', $expr, $expr2);
			}
			return $expr;
		}


		## * BNF:
		##    conditional ::= logical-or | logical-or '?' logical-or ':' logical-or
		##		  ::= logical-or { '?' logical-or ':' logical-or }
		function parse_conditional($flag_php_mode=FALSE) {
			$expr = $this->parse_logical_or($flag_php_mode);
			while ($this->token() == '?') {
				$cond = $expr;
				$this->scan();
				$left = $this->parse_logical_or($flag_php_mode);
				$this->token_check2(':', "':' expected.");
				$right = $this->parse_logical_or($flag_php_mode);
				$expr = new KwartzConditionalExpression('?', $cond, $left, $right);
			}
			return $expr;
		}

		## * BNF:
		##    assignment ::= conditional-expr  assign-op assignment | conditional-expr
		##		 ::= conditional-expr [ assign-op conditional-expr ]
		function parse_assignment($flag_php_mode=FALSE) {
			$expr = $this->parse_conditional($flag_php_mode);
			switch ($t = $this->token()) {
			case '=': case '+=':  case '-=':  case '*=':  case '/=':
			case '%=':  case '^=':	case '.+=':
				switch ($expr->token()) {
				case 'variable':
				case '[]':
				case '[:]':
				case '{}':
					# OK
					break;
				default:
					$this->semantic_error("cannot assign into invalid left-value.");
				}
				$this->scan();
				$expr2 = $this->parse_assignment($flag_php_mode);
				$expr = new KwartzBinaryExpression($t, $expr, $expr2);
			}
			return $expr;
		}


		## * BNF:
		##    expression ::= assignment
		function parse_expression($flag_php_mode=FALSE) {
			return $this->parse_assignment($flag_php_mode);
		}


		##
		function parse_expression_strictly($flag_php_mode=FALSE) {
			//$expr = $this->parse_assignment($flag_php_mode);
			$expr = $this->parse_expression($flag_php_mode);
			$this->token_check(NULL,  "invalid expression (token='{$this->token()}').");
			return $expr;
		}


		protected $dispatcher = array(
			':print'    => 'parse_print_stmt',
			#'print'    => 'parse_print_stmt',
			'echo'	    => 'parse_print_stmt',
			':set'	    => 'parse_set_stmt',
			'$'	    => 'parse_set_stmt',
			':if'	    => 'parse_if_stmt',
			'if'	    => 'parse_if_stmt',
			':foreach'  => 'parse_foreach_stmt',
			'foreach'   => 'parse_foreach_stmt',
			':while'    => 'parse_while_stmt',
			'while'	    => 'parse_while_stmt',
			':macro'    => 'parse_macro_stmt',
			'macro'	    => 'parse_macro_stmt',
			':element'  => 'parse_element_stmt',
			'element'   => 'parse_element_stmt',
			':elem'	    => 'parse_element_stmt',
			'elem'	    => 'parse_element_stmt',
			':expand'   => 'parse_expand_stmt',
			'expand'    => 'parse_expand_stmt',
			'@'	    => 'parse_expand_stmt',
			':::'	    => 'parse_rawcode_stmt',
			':rawcode'  => 'parse_rawcode_stmt',
		);


		## * BNF:
		##    stmt	::= set-stmt | if-stmt | while-stmt | foreach-stmt
		##		   | print-stmt | macro-stmt | expand-stmt | expand2-stmt
		##		   | element-stmt | rawcode-stmt | print2-stmt
		function parse_statement() {
			$t = $this->token();
			while ($t == ';') {			# ignore empty statement
				$this->scan();
				$t = $this->token();
			}
			if ($t == NULL) {
				return NULL;
			}
			if (array_key_exists($t, $this->dispatcher)) {
				$method_name = $this->dispatcher[$t];
				$stmt = $this->$method_name();
				return $stmt;
			}
			if ($t == ':end' || $t == '}' || $t == ':elseif' || $t == ':elsif' || $t == ':else') {
				return NULL;
			}
			//$flag_php_mode = true;
			//$stmt = $this->parse_set_stmt($flag_php_mode);
			$this->syntax_error("'$t': unexpected token.");
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
			$t = $this->token();
			$flag_php_mode = $t == '$';
			if ($flag_php_mode) {
				$expr = $this->parse_assignment($flag_php_mode);	// assignment or expression
				$this->token_check2(';',  "statement should be terminated by ';' but got '{$this->token()}'.");
				return new KwartzSetStatement($expr);
			} else {	# $t == ':set'
				$this->scan();
				$this->token_check2('(',  "'$t' requires '('.");
				$expr = $this->parse_expression($flag_php_mode);
				$this->token_check2(')',  "'$t(' is not closed by ')'.");
				return new KwartzSetStatement($expr);
			}
		}


		## * BNF:
		##    if-stmt ::= ':if' '(' expression ')' stmt-list
		##		 { ':elsif' '(' expression ')' stmt-list }
		##		 [ ':else' stmt-list ] ':end'
		function parse_if_stmt() {
			$t = $this->token();
			if ($t == ':if' || $t == ':elseif') {
				$flag_php_mode = FALSE;
				$linenum = $this->scanner->linenum();
				$this->scan();
				$this->token_check2('(', "'{$t}' requires '('.");
				$cond_expr = $this->parse_expression($flag_php_mode);
				$this->token_check2(')', "'{$t}(' is not closed by ')'.");
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
					$this->token_check2(':end', "':if' (at line $linenum) is not closed by ':end'.");
				}
				return new KwartzIfStatement($cond_expr, $then_block, $else_stmt);
			} elseif ($t == 'if' || $t == 'elseif') {
				$flag_php_mode = TRUE;
				$linenum = $this->scanner->linenum();
				$this->scan();
				$this->token_check2('(', "'{$t}' requires '('.");
				$cond_expr = $this->parse_expression($flag_php_mode);
				$this->token_check2(')', "'{$t}(' is not closed by ')'.");
				$this->token_check2('{',"'{' expected.");
				$then_block = $this->parse_block_stmt();
				$this->token_check2('}', "'}' expected.");
				if (($t = $this->token()) == 'elseif') {
					$else_stmt = $this->parse_if_stmt();
				} elseif ($t == 'else') {
					$this->scan();
					$this->token_check2('{', "'{' expected.");
					$else_stmt = $this->parse_block_stmt();
					$this->token_check2('}', "'}' expected.");
				} else {
					$else_stmt = NULL;
				}
				return new KwartzIfStatement($cond_expr, $then_block, $else_stmt);
			}
			assert(false);
		}


		## * BNF:
		##    while-stmt ::= ':while' '(' assignment ')' stmt-list ':end'
		function parse_while_stmt() {
			$t = $this->token();
			$flag_php_mode = $t[0] != ':';
			$linenum = $this->scanner->linenum();
			$this->scan();
			$this->token_check2('(', "'$t' requires '('.");
			$cond_expr = $this->parse_expression($flag_php_mode);
			$this->token_check2(')', "'{$t}(' is not closed by ')'.");
			if ($flag_php_mode) {
				$this->token_check2('{', "'{$t}()' required '{'..");
			}
			$body_block = $this->parse_block_stmt();
			$endtoken = $flag_php_mode ? '}' : ':end';
			$this->token_check2($endtoken, "'{$t}' (at line $linenum) is not closed by ':end' (current token is '{$this->token()}').");
			return new KwartzWhileStatement($cond_expr, $body_block);
		}


		## * BNF:
		##    foreach-stmt ::= ':foreach' '(' expression '=' expression ')' stmt-list ':end'
		function parse_foreach_stmt() {
			$t = $this->token();
			$flag_php_mode = $t[0] != ':';
			$linenum = $this->scanner->linenum();

			## parse 'foreach()' or ':foreach()'
			$this->scan();
			$this->token_check2('(', "'$t' requires '('.");
			if ($flag_php_mode) {
				$list_expr = $this->parse_expression($flag_php_mode);
				if ( ! ($this->token() == 'name' && $this->value() == 'as') ) {
					$this->syntax_error("'$t' requires 'as'.");
				}
				$this->scan();
				$loopvar_expr = $this->parse_expression($flag_php_mode);
			} else {
				$assign_expr = $this->parse_assignment($flag_php_mode);
				if ($assign_expr->token() != '=') {
					$this->syntax_error("'{$t}' is not '{$t}(loopvar=list)' format.");
				}
				$loopvar_expr = $assign_expr->left();
				$list_expr    = $assign_expr->right();
			}
			$this->token_check2(')', "'$t(' is not closed by ')'.");
			if ($loopvar_expr->token() != 'variable') {
				$this->syntax_error("'{$t}': invalid loop variable.");
			}

			## parse block
			if ($flag_php_mode) {
				$this->token_check2('{', "'{$t}()' requires '{'.");
			}
			$body_block = $this->parse_block_stmt();
			$endtoken = $flag_php_mode ? '}' : ':end';
			$this->token_check2($endtoken,	"'{$t}' (at line $linenum) is not closed by '$endtoken'.");
			return new KwartzForeachStatement($loopvar_expr, $list_expr, $body_block);
		}


		## * BNF:
		##    print-stmt ::= ':print'  '(' expression { ',' expression } ')'
		function parse_print_stmt() {
			$t = $this->token();
			$flag_php_mode = $t[0] != ':';
			$linenum = $this->scanner->linenum();

			$this->scan();
			if (! $flag_php_mode) {
				$this->token_check2('(', "'$t' requires '('.");
			}
			$expr_list = array();
			$t2 = $this->token();
			$endtoken = $flag_php_mode ? ';' : ')';
			if ($this->token() != $endtoken) {
				while (TRUE) {
					$expr = $this->parse_expression($flag_php_mode);
					$expr_list[] = $expr;
					if ($this->token() != ',') { break; }
					$this->scan();
				}
			}
			$this->token_check2($endtoken, "'$t' is not closed by '$endtoken'.");
			return new KwartzPrintStatement($expr_list);
		}


		## * BNF:
		##    macro-stmt   ::= ':macro' '(' name ')' stmt-list ':end'
		##    element-stmt ::= ':element' '(' name ')' stmt-list ':end'
		function parse_macro_stmt() {
			$t = $this->token();
			$flag_php_mode = $t[0] != ':';
			$flag_element = ($t != ':macro' && $t != 'macro');
			$linenum = $this->scanner->linenum();
			$this->scan();
			if (! $flag_php_mode) {
				$this->token_check2('(', "'$t' requires '('.");
			}
			$this->token_check('name', "'$t' should take a name.");
			$name = $this->value();
			$macro_name = $flag_element ? ('elem_' . $name) : $name;
			//$macro_name = $flag_element ? ('element_' . $name) : $name;
			$this->scan();
			if ($flag_php_mode) {
				$this->token_check2('{', "'$t()' requires '{'.");
			} else {
				$this->token_check2(')', "'$t(' is not closed by ')'.");
			}
			if (! $flag_element) {
				$body_block = $this->parse_block_stmt();
			} else {
				array_push($this->element_name_stack, $name);
				$this->current_element_name = $name;
				$body_block = $this->parse_block_stmt();
				array_pop($this->element_name_stack);
				$this->current_element_name = end($this->element_name_stack);
				//$this->current_element_name = array_pop($this->element_name_stack);
			}
			$endtoken = $flag_php_mode ? '}' : ':end';
			$this->token_check2($endtoken, "'$t' (at line $linenum) is not closed by '$endtoken' (current token is '{$this->token()}'.");
			return new KwartzMacroStatement($macro_name, $body_block);
		}


		## * BNF:
		##    element-stmt ::= ':element'  '(' name ')' stmt-list ':end'
		function parse_element_stmt() {
			$t = $this->token();
			if ($t == ':element' || $t == 'element') {
				return $this->parse_macro_stmt();
			}
			elseif ($t == 'element' || $t == 'elem') {
				return $this->parse_macro_stmt();
			}
			assert(false);
		}


		## * BNF:
		##    expand-stmt ::= ':expand' '(' macro-name ')'  | '@' macro-name
		function parse_expand_stmt() {
			$t = $this->token();
			if ($t == '@') {
				$macro_name = $this->value();
				$this->scan();
				switch ($macro_name) {
				case 'stag':
				case 'etag':
				case 'cont':
					if (! $this->current_element_name) {
						$msg = "'@{$macro_name}' should be in ':element' statement.";
						throw new KwartzSemanticError($msg, $this->scanner);
					}
					$macro_name .= '_' . $this->current_element_name;
					break;
				//default:
				//	if (preg_match(/^elem_(.*)$/, $macro_name, $m = array()) {
				//		$macro_name = 'element_' . $m[1];
				//	}
				}
				return new KwartzExpandStatement($macro_name);
			}
			$flag_php_mode = $t == 'expand';
			$this->scan();
			$flag_paren = true;
			if (! $flag_php_mode) {
				$this->token_check2('(', "'{$t}' requires '('.");
			} elseif ($this->token() == '(') {
				$this->scan();
			} else {
				$flag_paren = false;
			}
			$this->token_check('name', "'{$t}' requires macro-name.");
			$macro_name = $this->value();
			//if (preg_match('/^elem_(.*)$/', $macro_name, $m=array())) {
			//	$macro_name = 'element_' . $m[1];
			//}
			$this->scan();
			if ($flag_paren) {
				$this->token_check2(')', "'{$t}(' is not closed by ')'.");
			}
			if ($flag_php_mode) {
				$this->token_check2(';', "'{$t}' is not terminated by ';'.");
			}
			return new KwartzExpandStatement($macro_name);
		}


		## * BNF:
		##    rawcode ::= ':::' raw-string | '<?' raw-string | '<%' raw-string
		function parse_rawcode_stmt() {
			if ($this->token() == ':::' || $this->token() == ':rawcode') {
				$rawcode = $this->value();
				$this->scan();
				return new KwartzRawcodeStatement($rawcode);
			}
			assert(false);
		}


		## * BNF:
		##    load-stmt ::= ':load' '(' string ')'
		function parse_load_stmt() {
			$t = $this->token();
			$flag_php_mode = $t[0] != ':';
			$this->scan();
			$this->token_check2('(', "'{$t}' requires '('.");
			$this->token_check('string', "'{$t}()' should take filename as a string.");
			$filename = $this->value();
			$this->scan();
			$this->token_check2(')', "'{$t}(' is not closed by ')'.");
			if ($flag_php_mode) {
				$this->token_check2(';', "'{$t}()' is not terminated by ';'.");
			}

			## load file and parse it
			if (! file_exists($filename)) {
				$this->semantic_error("load file '$filename' is not exist.");
			}
			$input	 = file_get_contents($filename);
			$scanner = new KwartzScanner($input);
			$parser	 = new KwartzParser($scanner);
			$block	 = $parser->parse();
			return $block;
		}


		## * BNF:
		##    program ::= block-stmt
		function parse_program() {
			$block = $this->parse_block_stmt();
			$this->token_check(NULL, "EOF expected but '{$this->token()}'.");
			return $block;
		}


		##
		##
		function parse() {
			return $this->parse_program();
		}
	}  // end of class KwartzParser

//}  // end of namespace Kwartz
?>