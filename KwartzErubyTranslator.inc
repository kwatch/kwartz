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

		function __construct($block, $flag_escape=FALSE) {
			parent::__construct($block, $flag_escape);
		}

		protected function keyword($token) {
			return array_key_exists($token, $this->keywords) ? $this->keywords[$token] : $token;
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