<?php

###
### KwartzErubyTranslator.inc
###

require_once('KwartzTranslator.inc');

// namespace Kwartz {

	class KwartzPlphpTranslator extends KwartzBaseTranslator {
		private	$keywords = array(
			':if'         => 'if (',
			':then'       => ') {',
			':else'       => '} else {',
			':elseif'     => '} elseif {',
			':endif'      => '}',
			
			':while'      => 'while (',
			':dowhile'    => ') {',
			':endwhile'   => '}',
			
			':foreach'    => 'foreach (',
			':in'         => ' as ',
			':doforeach'  => ') {',
			':endforeach' => '}',
			
			':set'        => '',
			':endset'     => ';',
			
			':print'      => 'echo ',
			':endprint'   => ';',
			':eprint'     => 'echo E(',
			':endeprint'  => ');',
			
			':macro'      => 'macro ',
			':beginmacro' => ' {',
			':endmacro'   => '}',

			':expand'     => 'expand(',
			':endexpand'  => ');',
			
			//':include'    => 'include(',
			//':endinclude' => ');',
			
			'true'        => 'true',
			'false'       => 'false',
			'null'        => 'null',
			'empty'       => 'empty',

			'-.'   => '-',
			'.+'   => '.',
			'.+='  => '.=',
			'{'    => '[',
			'}'    => ']',
			'[:'   => "[:",
			':]'   => "]",
			','    => ", ",
			
			'E('   => 'E(',
			'E)'   => ')',
		);

		function __construct($block, $flag_escape=FALSE, $toppings=NULL) {
			parent::__construct($block, $flag_escape, $toppings);
			$this->flag_supress_begin = TRUE;
			$this->flag_supress_end   = TRUE;
		}

		protected function keyword($token) {
			return array_key_exists($token, $this->keywords) ? $this->keywords[$token] : $token;
		}

		protected function translate_variable_expression($expr) {
			$this->code .= '$' . $expr->value();
		}
		
		protected function translate_print_statement($stmt, $depth) {
			$this->add_indent($depth);
			$this->code .= $this->keyword(':print');
			$arglist = $stmt->arglist();
			$i = 0;
			foreach ($arglist as $expr) {
				$i += 1;
				if ($i > 1) {
					$this->code .= $this->keyword(',');
				}
				$this->translate_expression($expr);
			}
			$this->code .= $this->keyword(':endprint');
			$this->code .= $this->nl();
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
		
		protected function translate_macro_statement($stmt, $depth) {
			$this->add_indent($depth);
			$this->code .= $this->keyword(':macro');
			$this->code .= $stmt->macro_name();
			$this->code .= $this->keyword(':beginmacro');
			$this->code .= $this->nl();
			$this->translate_statement($stmt->body_block(), $depth+1);
			$this->add_indent($depth);
			$this->code .= $this->keyword(':endmacro');
			$this->code .= $this->nl();
			$this->code .= $this->nl();
		}
		
		protected function translate_expand_statement($stmt, $depth) {
			$this->add_indent($depth);
			$this->code .= $this->keyword(':expand');
			$this->code .= $stmt->macro_name();
			$this->code .= $this->keyword(':endexpand');
			$this->code .= $this->nl();
		}

	}

// }  // end of namespace Kwartz
?>