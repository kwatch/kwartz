#!/usr/bin/env php
<?php

###
### kwartz.php -- a template system for PHP, Ruby and Java.
###
### Type 'php kwartz.php --help' for help. 
###

if (PHP_SAPI == 'cgi') {
	
}

require_once('KwartzException.inc');
require_once('KwartzNode.inc');
require_once('KwartzScanner.inc');
require_once('KwartzParser.inc');
require_once('KwartzConverter.inc');
require_once('KwartzTranslator.inc');
require_once('KwartzErubyTranslator.inc');
require_once('KwartzJspTranslator.inc');
require_once('KwartzPlphpTranslator.inc');
require_once('KwartzCompiler.inc');
require_once('KwartzAnalyzer.inc');


//namespace Kwartz {

	class KwartzCommandOptionError extends KwartzException {
		function __construct($msg) {
			parent::__construct($msg);
		}
	}

	class KwartzCommand {

		const revision   = '$Rev$';
		const lastupdate = '$Date$';
	
		private $command_name;
		private $options = array();
		private $toppings = array();
		
		function __construct() {
			//$this->command_name = $command_name;
		}

		function main(&$argv) {
			## parse $argv and set $command_name, $options and $toppings
			$this->parse_argv($argv);

			## print usage/version message
			$flag_exit = FALSE;
			if ($this->option('-h')) {
				$flag_exit = TRUE;
				echo $this->usage();
			}
			if ($this->option('-v')) {
				$flag_exit = TRUE;
				echo $this->version();
			}
			if ($flag_exit) {
				return;
			}

			## check language
			if ($lang = $this->option('-l')) {
				switch ($lang) {
				case 'php':
				case 'eruby':
				case 'jsp':
				case 'plphp':
					# OK
					break;
				default:
					$msg = "'$lang': unsupported language name.";
					throw new KwartzCommandOptionError($msg);
				}
			} else {
				$lang = 'php';
			}
			
			## flag escape
			$flag_escape = ($this->option('-s') || $this->option('-e') || $this->topping('escape'));
			
			## topping handler
			$this->check_toppings();
			
			## determine which action to do (default: 'compile')
			$action = 'compile';
			if ($this->option('-a')) {
				switch ($action = $this->option('-a')) {
				//case 'scan':
				case 'parse':
				case 'convert':
				case'_convert':
				case 'translate':
				case 'compile':
				case 'analyze':
					# OK
					break;
				default:
					$msg = "'{$action}': invalid action name.";
					throw new KwartzCommandOptionError($msg);
				}
			}

			## read presentation logic file
			$plogic_filename = NULL;
			$plogic_code = NULL;
			if ($this->option('-p')) {
				$plogic_filename = $this->option('-p');
				$plogic_filenames = preg_split('/,/', $plogic_filename);
				$plogic_code = '';
				foreach ($plogic_filenames as $fname) {
					if (! file_exists($fname)) {
						$msg = "'$fname': file not found.";
						throw new KwartzCommandOptionError($msg);
					}
					$plogic_code .= file_get_contents($fname);
				}
			}

			## read input
			$input = '';
			if (count($argv) == 0) {
				$input = file_get_contents('php://stdin');
			} else {
				foreach ($argv as $filename) {
					if (! file_exists($filename)) {
						$msg = "$filename: file not found.";
						throw new KwartzCommandOptionError($msg);
					}
					$input .= file_get_contents($filename);
				}
			}

			## do action
			$output = $this->do_action($action, $input, $plogic_code, $lang, $flag_escape, $this->toppings);
			echo $output;
		}


		function do_action(&$action, &$input, &$plogic_code, $lang, $flag_escape=FALSE, $toppings=NULL) {
			switch ($action) {
			case 'compile':
				$output = '';
				if ($lang == 'jsp') {
					$newline = kwartz_detect_newline_char($input);
					if (! $newline) {
						$newline = "\n";
					}
					if ($charset = $this->topping('charset')) {
						$output .= "<%@ page contentType=\"text/html; charset=$charset\" %>$newline";
					}
					if ($this->has_topping('header')) {
						$output .= $this->topping('header');
					} else {
						$output .= "<%@ taglib prefix=\"c\" uri=\"http://java.sun.com/jstl/core\" %>$newline";
					}
				} else {
					if ($this->has_topping('header')) {
						$output .= $this->topping('header');
					}
				}
				$compiler = new KwartzCompiler($input, $plogic_code, $lang, $flag_escape, $toppings);
				$output .= $compiler->compile();
				if ($this->has_topping('footer')) {
					$output .= $this->topping('footer');
				}
				break;

			case 'parse':
				$parser = new KwartzParser($input);
				$block = $parser->parse();
				$output = $block->inspect();
				break;
				
			case '_convert':
				$converter = new KwartzConverter($input, $toppings);
				$block = $converter->convert();
				$output = $block->inspect();
				break;

			case 'convert':
				$converter = new KwartzConverter($input, $toppings);
				$block = $converter->convert();
				$translator = new KwartzPlphpTranslator($block, $toppings);
				$output = $translator->translate();
				break;

			case 'translate':
				$parser = new KwartzParser($input, $flag_escape, $toppings);
				$block = $parser->parse();
				switch ($lang) {
				case 'php':
					$translator = new KwartzPhpTranslator($block, $toppings);
					break;
				case 'eruby':
					$translator = new KwartzErubyTranslator($block, $toppings);
					break;
				case 'jsp':
					$translator = new KwartzJspTranslator($block, $toppings);
					break;
				case 'plphp':
					$translator = new KwartzPlphpTranslator($block, $toppings);
					break;
				}
				$output = $translator->translate();
				break;

			case 'analyze':
				$converter = new KwartzConverter($input, $toppings);
				$block = $converter->convert();
				if ($plogic_code) {
					$parser = new KwartzParser($plogic_code);
					$plogic_block = $parser->parse();
					$block = $block->merge($plogic_block);
				}
				$analyzer = new KwartzAnalyzer($block);
				$analyzer->analyze();
				$output = $analyzer->result();
				break;

			default:
				assert(false);
			}
			return $output;
		}


		function option($key) {
			if (array_key_exists($key, $this->options)) {
				return $this->options[$key];
			}
			return NULL;
		}

		function topping($key) {
			if (array_key_exists($key, $this->toppings)) {
				return $this->toppings[$key];
			}
			return NULL;
		}

		function set_topping($key, $value) {
			$this->toppings[$key] = $value;
		}

		function has_topping($key) {
			return array_key_exists($key, $this->toppings);
		}

		function check_toppings() {
			if ($s = $this->topping('include_path')) {
				$this->set_topping('include_path', preg_split('/,/', $s));
			}
			if ($s = $this->topping('load_path')) {
				$this->set_topping('load_path', preg_split('/,/', $s));
			}
		}


		function usage() {
			$usage = <<<END
Usage: {$this->command_name} [..options..] [filenames...]
  -h		 : help
  -v		 : version
  -l lang	 : php/eruby (default 'php')
  -a action	 : compile/parse/translate/convert/analyze (default 'compile')
  -p file.plogic : presentation logic file
  -e             : escape(sanitize)
  -s             : escape(sanitize)
  --escape=true  : escape(sanitize)
  --header=text  : header text (default '<%@ taglib ...>' when jsp)
  --footer=text  : footer text
  --include_path=dir1,dir2,... : path list for 'include' directive
  --load_path=dir1,dir2,...    : path list for 'load' directive

END;
			return $usage;
		}

		function version() {
			$revision   = KwartzCommand::revision;
			$lastupdate = KwartzCommand::lastupdate;
			return "kwartz.php: $revision ($date)";
		}


		function parse_argv(&$argv) {
			$command_filename = array_shift($argv);
			$this->comand = basename($command_filename);

			$error_msg = NULL;
			while (count($argv) > 0 && preg_match('/^-/', $argv[0])) {
				$opt = array_shift($argv);

				switch ($opt) {
				case '-h':
				case '-v':
				case '-s':
				case '-e':
					$this->options[$opt] = TRUE;
					break;

				case '-a':
				case '-p':
				case '-l':
					$arg = array_shift($argv);
					if ($arg === NULL) {
						$error_msg = "command option '$opt': argument required.";
					} else {
						$this->options[$opt] = $arg;
					}
					break;

				case '--help':
					$this->options['-h'] = TRUE;
					break;

				default:
					if (preg_match('/^--([-\w]+)(?:=(.*))/', $opt, $m = array())) {
						$key   = $m[1];
						$value = $m[2];
						if ($value === NULL) {
							$value = TRUE;
						} else {
							switch ($value) {
							case 'true':
							case 'TRUE':
								$value = TRUE;
								break;
							case 'false':
							case 'FALSE':
								$value = FALSE;
								break;
							case 'null':
							case 'NULL':
								$value = NULL;
								break;
							default:
							}
						}
						$this->set_topping($key, $value);
					} else {
						$error_msg = "'${opt}': invalid option.";
						break;
					}
				}
				if ($error_msg) {
					throw new KwartzCommandOptionError($error_msg);
					return $error_msg;
				}
			}
		}

	}  // end of class KwartzCommand


//}  // end of namespace Kwartz


##
## main program
##
if (basename(__FILE__) == basename($argv[0])) {
	try {
		$kwartz = new KwartzCommand();
		$kwartz->main($argv);
	} catch (KwartzException $ex) {
		fwrite(STDERR, "ERROR: " . $ex->getMessage() . "\n");
		exit(1);
	}
	exit(0);
}
?>