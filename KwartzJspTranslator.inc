<?php

###
### KwartzJspTranslator.inc
###

require_once('KwartzTranslator.inc');
require_once('KwartzVisitor.inc');
require_once('KwartzNode.inc');

// namespace Kwartz {

	class KwartzJspTranslator extends KwartzBaseTranslator {
		protected $condfind_visitor;
		protected $deepcopy_visitor;
		private	$keywords = array(
			':if'	      => '<c:choose><c:when test="${',
			':then'	      => '}">',
			':elseif'     => '</c:when><c:when test="${',
			':else'	      => '</c:when><c:otherwise>',
			':endif'      => '</c:when></c:choose>',

			':while'      => NULL,
			':dowhile'    => NULL,
			':endwhile'   => NULL,

			':foreach'    => '<c:forEach var="',
			':in'	      => '" items="${',
			':doforeach'  => '}">',
			':endforeach' => '</c:forEach>',

			':set'	      => '<c:set var="',
			':endset'     => '}"/>',

			':print'      => '<c:out value="${',
			':endprint'   => '}" escapeXml="false"/>',
			':print2'     => '<c:out value="${',
			':endprint2'  => '}"/>',

			':include'    => NULL,
			':endinclude' => NULL,

			'true'	      => 'true',
			'false'	      => 'false',
			'null'	      => 'null',


			'-.'   => '-',
			'.+'   => '}${',
			'+='   => NULL,
			'-='   => NULL,
			'*='   => NULL,
			'/='   => NULL,
			'^='   => NULL,
			'.+='  => NULL,

			'='    => '" value="${',
			'{'    => '[',
			'}'    => ']',
			'[:'   => "['",
			':]'   => "']",

			'!'    => 'not ',
			'&&'   => 'and',
			'||'   => 'or',

			'E('   => NULL,
			'E)'   => NULL,
		);

		function __construct($block) {
			parent::__construct($block);
			$this->condfind_visitor = new KwartzConditionalExpressionFindVisitor();
			$this->deepcopy_visitor = new KwartzConditionalDeepCopyVisitor();
		}

		protected function keyword($token) {
			return array_key_exists($token, $this->keywords) ? $this->keywords[$token] : $token;
		}

		function translate_string_expression($expr) {
			$value = $expr->value();
			$this->code .= "'" . addcslashes($value, "'\\") . "'";
		}
		
		function translate_unary_expression($expr) {
			$t = $expr->token();
			switch ($t) {
			case ':empty':
				$this->code .= '(empty ';
				$this->translate_expression($expr->child());
				$this->code .= ')';
				break;
			case ':notempty':
				$this->code .= '!(empty ';
				$this->translate_expression($expr->child());
				$this->code .= ')';
				break;
			default:
				parent::translate_unary_expression($expr);
			}
		}

		function translate_function_expression($expr) {
			$funcname = $expr->funcname();
			$msg = "'$funcname()': JSP doesn't support function call expression.";
			throw new KwartzTranslationError($msg, $this);
		}


		function translate_if_statement($stmt, $depth) {
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
				$this->add_indent($depth);				#
				$this->code .= '</c:otherwise></c:choose>';		#
			} else {							#
				$this->add_indent($depth);				#
				$this->code .= '</c:when></c:choose>';			#
			}								#
			$this->code .= $this->nl;
		}


		function translate_set_statement($stmt, $depth) {
			$this->normalize_set_stmt($stmt);
			$this->add_indent($depth);
			$expr = $stmt->assign_expr();			# assign expression
			$rhs_token = "{$expr->right()->token()}";	## don't use $rhs_token = $expr->right()->token();
			if ($rhs_token == 'number' || $rhs_token == 'string') {
				$this->code .= $this->keyword(':set');
				$this->translate_expression($expr->left());
				$this->code .= '" value="';
				//$this->translate_expr($expr->right());
				$this->code .= $expr->right()->value();
				$this->code .= '"/>';
			} else {
				//parent::translate_set_statement($stmt, $depth);
				$this->code .= $this->keyword(':set');
				$l = $expr->left();
				$this->translate_expression($l);
				$this->code .= $this->keyword('=');
				$r = $expr->right();
				$this->translate_expression($r);
				$this->code .= $this->keyword(':endset');
			}
			$this->code .= $this->nl;
		}

		function translate_while_statement($stmt) {
			$error_msg = "JSP doesn't support 'while' statement.";
			throw new KwartzTranslationError($error_msg, $this);
		}


		function translate_block_statement($block, $depth) {
			$i = 0;
			foreach($block->statements() as $stmt) {
				$i++;
				$new_stmt = $this->expand_conditional_expr($stmt);
				$this->translate_statement($new_stmt, $depth);
			}
		}


		protected function normalize_assign_expr($assign_expr) {
			$t = $assign_expr->token();
			if ($t == '=') {
				return NULL;
			}
			switch ($t) {
			case '+=':
			case '-=':
			case '*=':
			case '/=':
			case '%=':
				$op = $t[0];
				break;
			case '.+=':
				$op = '.+';
				break;
			default:
				assert(false);
			}
			$lhs_expr = $assign_expr->left();
			$rhs_expr = $assign_expr->right();
			$new_rhs_expr = new KwartzBinaryExpression($op, $lhs_expr, $rhs_expr);
			return new KwartzBinaryExpression('=', $lhs_expr, $new_rhs_expr);
		}

		protected function normalize_set_stmt($stmt) {
			$assign_expr = $stmt->assign_expr();
			$new_assign_expr = $this->normalize_assign_expr($assign_expr);
			if ($new_assign_expr) {
				$stmt->set_assign_expr($new_assign_expr);
			}
		}


		protected function expand_conditional_expr($stmt) {
			## find conditional expression
			$cond_expr = $stmt->accept($this->condfind_visitor);
			if (! $cond_expr) {
				return $stmt;
			}

			## deepcopy statement
			$visitor = $this->deepcopy_visitor;
			$visitor->set_option('?left');
			$then_stmt = $stmt->accept($visitor);
			$then_block = new KwartzBlockStatement(array($then_stmt));
			$visitor->set_option('?right');
			$else_stmt = $stmt->accept($visitor);
			$visitor->set_option(NULL);

			## return if-statement
			return new KwartzIfStatement($cond_expr->condition(), $then_block, $else_stmt);
		}
	}


	class KwartzConditionalDeepCopyVisitor extends KwartzDeepCopyVisitor {
		protected $option;
		function option()	{ return $this->option; }
		function set_option($v) { $this->option = $v; }

		function visit_conditional_expr($expr) {
			if ($this->option == '?left') {
				$this->option = NULL;
				return $expr->left()->accept($this);
			} elseif ($this->option == '?right') {
				$this->option = NULL;
				return $expr->right()->accept($this);
			}
			return parent::visit_conditional_expr($expr);
		}
	}


	class KwartzConditionalExpressionFindVisitor extends KwartzVisitor {

		function visit_unary_expr($expr) {
			$child = $expr->child();
			return $child->accept($this);
		}
		function visit_binary_expr($expr) {
			if ($ret = $expr->left()->accept($this)) {
				return $ret;
			}
			$ret = $expr->right()->accept($this);
			return $ret;
		}
		function visit_property_expr($expr) {
			return $expr->object()->accept($this);
		}
		function visit_function_expr($expr) {
			$arglist = $expr->arglist();
			foreach ($arglist as $expr) {
				if ($ret = $expr->accept($this)) {
					return $ret;
				}
			}
			return NULL;
		}
		function visit_conditional_expr($expr) {
			return $expr;
		}
		function visit_leaf_expr($expr) {
			return NULL;
		}

		function visit_print_stmt($stmt) {
			$arglist = $stmt->arglist();
			foreach($arglist as $expr) {
				if ($ret = $expr->accept($this)) {
					return $ret;
				}
			}
			return NULL;
		}
		function visit_set_stmt($stmt) {
			$assign_expr = $stmt->assign_expr();
			return $assign_expr->accept($this);
		}
		function visit_if_stmt($stmt) {
			$cond_expr = $stmt->condition();
			return $cond_expr->accept($this);
		}
		function visit_while_stmt($stmt) {
			$cond_expr = $stmt->condition();
			return $cond_expr->accept($this);
		}
		function visit_foreach_stmt($stmt) {
			$list_expr = $stmt->list_expr();
			return $list_expr->accept($this);
		}
		function visit_macro_stmt($stmt) {
			return NULL;
		}
		function visit_expand_stmt($stmt) {
			return NULL;
		}
		function visit_block_stmt($stmt) {
			return NULL;
		}
		function visit_rawcode_stmt($stmt) {
			return NULL;
		}
	}

// }  // end of namespace Kwartz
?>