<?php

###
### KwartzErubyTranslator.inc
###

require_once('KwartzTranslator.inc');

// namespace Kwartz {

	class KwartzErubyTranslator extends KwartzBaseTranslator {
		private	$keywords = array(
			':if'         => '<% if ',
			':then'       => ' then %>',
			':else'       => '<% else %>',
			':elseif'     => '<% elsif ',
			':endif'      => '<% end %>',
			
			':while'      => '<% while ',
			':dowhile'    => ' do %>',
			':endwhile'   => '<% end %>',
			
			':foreach'    => '<% for ',
			':in'         => ' in ',
			':doforeach'  => ' do %>',
			':endforeach' => '<% end %>',
			
			':set'        => '<% ',
			':endset'     => ' %>',
			
			':print'      => '<%= ',
			':endprint'   => ' %>',
			':eprint'     => '<%= CGI.escapeHTML((',
			':endeprint'  => ').to_s) %>',
			
			':include'    => '<% include(',
			':endinclude' => '); %>',
			
			'true'        => 'true',
			'false'       => 'false',
			'null'        => 'nil',

			'-.'   => '-',
			'.+'   => '+',
			'.+='  => '+=',
			'{'    => '[',
			'}'    => ']',
			'[:'   => "[:",
			':]'   => "]",
			','    => ", ",
			
			'E('   => 'CGI.escapeHTML((',
			'E)'   => ').to_s)',
		);

		function __construct($block, $flag_escape=FALSE, $toppings=NULL) {
			parent::__construct($block, $flag_escape, $toppings);
		}

		protected function keyword($token) {
			return array_key_exists($token, $this->keywords) ? $this->keywords[$token] : $token;
		}

		protected function translate_unary_expression($expr) {
			$t = $expr->token();
			if ($t == 'empty' || $t == 'notempty') {
				if ($t == 'empty') {  $op1 = '==';  $op2 = '||'; }
				else               {  $op1 = '!=';  $op2 = '&&'; }
				$this->code .= '(';
				$expr1 = new KwartzBinaryExpression($op1, $expr->child(), new KwartzNullExpression("nil"));
				$expr2 = new KwartzBinaryExpression($op1, $expr->child(), new KwartzStringExpression(""));
				$expr3 = new KwartzBinaryExpression($op2, $expr1, $expr2);
				$this->translate_binary_expression($expr3);
				$this->code .= ')';
				return;
			}
			parent::translate_unary_expression($expr);
		}

		protected function translate_property_expression($expr) {
			$t = $expr->token();
			$op = $this->keyword($t);
			$this->translate_expr($expr->object(), $t, $expr->object()->token());
			$this->code .= $op;
			$this->code .= $expr->property();
			if ($expr->arglist() !== NULL && count($expr->arglist()) > 0) {
				$this->code .= $this->keyword('(');
				$ctr = 0;
				foreach ($expr->arglist() as $arg) {
					if ($ctr > 0) {
						$this->code .= $this->keyword(',');
					}
					$ctr += 1;
					$this->translate_expression($arg);
				}
				$this->code .= $this->keyword(')');
			}
		}

	}

// }  // end of namespace Kwartz
?>