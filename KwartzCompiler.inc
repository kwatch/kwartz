<?php

###
### KwartzCompiler.inc
###

require_once('KwartzException.inc');
require_once('KwartzParser.inc');
require_once('KwartzConverter.inc');
require_once('KwartzTranslator.inc');
require_once('KwartzErubyTranslator.inc');
require_once('KwartzJspTranslator.inc');
require_once('KwartzPlphpTranslator.inc');
require_once('KwartzUtility.inc');


//namespace Kwartz {

	class KwartzCompilationError extends KwartzException {
		private $compiler;
		function __construct($msg, $compiler) {
			parent::__construct($msg);
			$this->compiler = $compiler;
		}
	}
	

	class KwartzCompiler {
		private $pdata;
		private $plogic;
		private $lang;
		private $toppings;
		private $flag_escape;
		
		function __construct($pdata_str=NULL, $plogic_code=NULL, $lang='php', $flag_escape=FALSE, $toppings=NULL) {
			$this->pdata = $pdata_str;
			$this->plogic = $plogic_code;
			$this->toppings = $toppings ? $toppings : array();
			switch ($lang) {
			case 'php':
			case 'eruby':
			case 'jsp':
			case 'plphp':
				# OK
				break;
			default:
				$msg = "language '{$lang}' not supported.";
				throw new KwartzCompilationError($msg, $this);
			}
			$this->lang = $lang;
			$this->flag_escape = $flag_escape;
		}
		
		function topping($name) {
			if (array_key_exists($name, $this->toppings)) {
				return $this->toppings[$name];
			}
			return NULL;
		}
		
		function compile() {
			## convert presentation data into block
			$pdata_block = NULL;
			$newline_char = NULL;
			if ($this->pdata) {
				$newline_char = kwartz_detect_newline_char($this->pdata);
				$converter = new KwartzConverter($this->pdata, $this->toppings);
				$pdata_block = $converter->convert();
			}
			
			## convert presentation logic code into block
			$plogic_block = NULL;
			if ($this->plogic) {
				$parser = new KwartzParser($this->plogic, $this->toppings);
				$plogic_block = $parser->parse();
			}
			
			## merge blocks and create a new block
			if (! ($pdata_block || $plogic_block)) {
				return NULL;
			}
			if ($pdata_block && $plogic_block) {
				$block = $pdata_block->merge($plogic_block);
			} else {
				$block = $pdata_block ? $pdata_block : $plogic_block;
			}
			
			## translate block into PHP code
			switch ($this->lang) {
			case 'php':
				$translator = new KwartzPhpTranslator($block, $this->flag_escape, $this->toppings);
				break;
			case 'eruby':
				$translator = new KwartzErubyTranslator($block, $this->flag_escape, $this->toppings);
				break;
			case 'jsp':
				$translator = new KwartzJspTranslator($block, $this->flag_escape, $this->toppings);
				break;
			case 'plphp':
				$translator = new KwartzPlphpTranslator($block, $this->flag_escape, $this->toppings);
				break;
			default:
				assert(false);
			}
			if ($newline_char) {
				$translator->set_newline_char($newline_char);
			}
			$code = $translator->translate();
			
			return $code;
		}

	}

//}  // end of namespace Kwartz

?>