<?php

###
### KwartzParser.inc
###
### $Id: KwartzParser.inc,v 0.1 2004/08/16 14:07:20 kwatch Exp $
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

		function __construct($scanner) {
			$this->scanner = $scanner;
			$this->scan();
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
		##
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
		##
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
		##
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
		##
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
		##
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
		##
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
		##    stmt-list ::= stmt*

		## * BNF:
		##    set-stmt ::= ':set' '(' assignment ')'


		## * BNF:
		##    if-stmt ::= ':if' '(' expression ')' stmt-list
		##		 { ':elsif' '(' expression ')' stmt-list }
		##		 [ ':else' stmt-list ] ':end'

		## * BNF:
		##    while-stmt ::= ':while' '(' assignment ')' stmt-list ':end'

		## * BNF:
		##    foreach-stmt ::= ':foreach' '(' expression '=' expression ')'
		##		       stmt-list ':end'

		## * BNF:
		##    print-stmt ::= ':print'  '(' expression { ',' expression } ')'
		##

		## * BNF:
		##    macro-stmt ::= ':macro' '(' name ')' stmt-list ':end'
		##

		## * BNF:
		##    elem-stmt	 ::= ':elem'  '(' name ')' stmt-list ':end'

		## * BNF:
		##    expand-stmt ::= ':expand' '(' name ')'
		##

		## * BNF:
		##     expand2-stmt ::= '@' macro-name
		##

		## * BNF:
		##     special-expand-stmt ::= '@stag' | '@cont' | '@etag' | ':stag' | ':cont' | ':etag'


		## * BNF:
		##     value-stmt ::= ':value' '(' name '=' expression ')'
		##

		## * BNF:
		##    rawcode ::= ':::' raw-string | ':rawcode' '(' string ')'

		## * BNF:
		##    load-stmt ::= ':load' '(' string ')'



		function parse() {
		}

	}

//}  // end of namespace Kwartz
?>