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
			':print2'     => '<%= CGI.escapeHTML((',
			':endprint2'  => ').to_s()) ?>',
			
			':include'    => '<?php include(',
			':endinclude' => '); ?>',
			
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
			
			'E('   => 'CGI.escapeHTML((',
			'E)'   => ').to_s())',
		);

		function __construct($block) {
			parent::__construct($block);
		}

		protected function keyword($token) {
			return array_key_exists($token, $this->keywords) ? $this->keywords[$token] : $token;
		}

	}

// }  // end of namespace Kwartz
?>