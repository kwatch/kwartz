#!/usr/local/bin/php -q
<?php

###
### kwartz.php -- a template system for PHP, Ruby and Java.
###
### Type 'php kwartz.php --help' for help. 
###

//if (PHP_SAPI == 'cgi') {	# no effect (;_;)
//	# ignore HTTP Header
//	ob_start();
//	echo "*dummy*";
//	ob_end_clean();
//}

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
		## constants
		const revision   = '$Rev$';
		const lastupdate = '$Date$';
	
		## instance vars
		private $args;
		private $command_name;
		private $options = array();
		private $toppings = array();
		
		# for test
		function _args() { return $this->args; }
		function _command_name() { return $this->command_name; }
		function _options() { return $this->options; }
		function _toppings() { return $this->toppings; }
		
		## constructor
		function __construct(&$args) {
			$this->args = $args;
			//$this->command_name = $command_name;
		}

		## instance methods
		function main() {
			## parse $args and set $command_name, $options and $toppings
			$this->parse_args($this->args);
			
			//echo "*** debug: this->options=", var_dump($this->options);
			//echo "*** debug: this->toppigns=", var_dump($this->toppings);
			//echo "*** debug: this->args=", var_dump($this->args);

			## print usage/version message
			$flag_exit = FALSE;
			if ($this->option('h')) {
				$flag_exit = TRUE;
				echo $this->usage();
			}
			if ($this->option('v')) {
				$flag_exit = TRUE;
				echo $this->version();
			}
			if ($flag_exit) {
				return;
			}

			## check language
			if ($lang = $this->option('l')) {
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
			$flag_escape = ($this->option('s') || $this->option('e') || $this->topping('escape'));
			
			## topping handler
			$this->handle_toppings();
			
			## determine which action to do (default: 'compile')
			$action = $this->option('a') ? $this->option('a') : 'compile';

			## read presentation logic file
			$plogic_filename = NULL;
			$plogic = NULL;
			if ($this->option('p')) {
				$plogic_filename = $this->option('p');
				$plogic_filenames = preg_split('/,/', $plogic_filename);
				$plogic = '';
				foreach ($plogic_filenames as $fname) {
					if (! file_exists($fname)) {
						$msg = "'$fname': file not found.";
						throw new KwartzCommandOptionError($msg);
					}
					$plogic .= file_get_contents($fname);
				}
			}

			## read input
			$input_filename = NULL;
			$input = '';
			if (count($this->args) == 0) {
				$input = file_get_contents('php://stdin');
				$input_filename = NULL;
			} else {
				//foreach ($this->args as $filename) {
				//	if (! file_exists($filename)) {
				//		$msg = "$filename: file not found.";
				//		throw new KwartzCommandOptionError($msg);
				//	}
				//	$input .= file_get_contents($filename);
				//}
				$input_filename = $this->args[0];	## read only the first file
				if (! file_exists($input_filename)) {
					$mg = "$input_filename: file not found.";
					throw new KwartzCommandOptionError($msg);
				}
				$input = file_get_contents($input_filename);
			}

			## do action
			$output = $this->do_action($action, $input, $input_filename, $plogic, $plogic_filename,
							$lang, $flag_escape, $this->toppings);
			return $output;
		}


		function do_action(&$action, &$input, &$input_filename, &$plogic, &$plogic_filename,
					$lang, $flag_escape=FALSE, $toppings=NULL) {
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
				$toppings['pdata_filename'] = $input_filename;
				$toppings['plogic_filename'] = $plogic_filename;
				$compiler = new KwartzCompiler($input, $plogic, $lang, $flag_escape, $toppings);
				$output .= $compiler->compile();
				if ($this->has_topping('footer')) {
					$output .= $this->topping('footer');
				}
				break;

			case 'scan':
				$toppings['filename'] = $input_filename;
				$scanner = new KwartzScanner($input, $toppings);
				$output = $scanner->scan_all();
				break;
				
			case 'parse':
				$toppings['filename'] = $input_filename;
				$parser = new KwartzParser($input, $toppings);
				$block = $parser->parse();
				$output = $block->inspect();
				break;
				
			case '_convert':
				$toppings['filename'] = $input_filename;
				$converter = new KwartzConverter($input, $toppings);
				$block = $converter->convert();
				$output = $block->inspect();
				break;

			case 'convert':
				$toppings['filename'] = $input_filename;
				$converter = new KwartzConverter($input, $toppings);
				$block = $converter->convert();
				$translator = new KwartzPlphpTranslator($block, $flag_escape, $toppings);
				$output = $translator->translate();
				break;

			case 'translate':
				$toppings['filename'] = $input_filename;
				$parser = new KwartzParser($input, $toppings);
				$block = $parser->parse();
				switch ($lang) {
				case 'php':
					$translator = new KwartzPhpTranslator($block, $flag_escape, $toppings);
					break;
				case 'eruby':
					$translator = new KwartzErubyTranslator($block, $flag_escape, $toppings);
					break;
				case 'jsp':
					$translator = new KwartzJspTranslator($block, $flag_escape, $toppings);
					break;
				case 'plphp':
					$translator = new KwartzPlphpTranslator($block, $flag_escape, $toppings);
					break;
				}
				$output = $translator->translate();
				break;

			case 'analyze':
				$toppings['filename'] = $input_filename;
				$converter = new KwartzConverter($input, $toppings);
				$block = $converter->convert();
				if ($plogic) {
					$toppings['filename'] = $plogic_filename;
					$parser = new KwartzParser($plogic, $toppings);
					$plogic_block = $parser->parse();
					$block = $block->merge($plogic_block);
				}
				unset($toppings['filename']);
				//$toppings('pdata_fileanme') = $input_filename;
				//$toppings('plogic_filename') = $plogic_filename;
				$analyzer = new KwartzAnalyzer($block, $toppings);
				$analyzer->analyze();
				$output = $analyzer->result();
				break;

			default:
				$msg = "'{$action}': invalid action name.";
				throw new KwartzCommandOptionError($msg);
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

		function handle_toppings() {
			## inclde_path, load_path
			if ($s = $this->topping('include_path')) {
				$this->set_topping('include_path', preg_split('/,/', $s));
			}
			if ($s = $this->topping('load_path')) {
				$this->set_topping('load_path', preg_split('/,/', $s));
			}
			
			## indent width
			$indent_width = $this->option('i');
			if ($indent_width === NULL) {
				$indent_width = 0;
			} elseif ($indent_width === TRUE) {
				$indent_width = 2;		# default
			}
			$this->set_topping('indent_width', $indent_width);
		}


		function usage() {
			$usage = <<<END
Usage: {$this->command_name} [-p file.plogic] [..options..] file.html
  -h, --help	 : help
  -v		 : version
  -p file.plogic : presentation logic file
  -l lang	 : php/eruby/jsp (default 'php')
  -a action	 : compile/parse/translate/convert/analyze (default 'compile')
  -e, -s         : escape(sanitize)
  -i[N]          : indent (default N=2)
  --escape=true  : escape(sanitize)
  --header=text  : header text (default '<%@ taglib ...>' when jsp)
  --footer=text  : footer text
  --even_value=str  : even value of toggle in FOREACH & LOOP directive
  --odd_value=str   : odd value of toggle in FOREACH & LOOP directive
  --include_path=dir1,dir2,... : path list for 'include' directive
  --load_path=dir1,dir2,...    : path list for 'load' directive
  --delete_idattr=true         : delete or leave id attributes
  --attr_name=name             : attribute name of directive (default 'kd')
  --php_attr_name=name         : attribute name of directive (default 'kd:php')

END;
			return $usage;
		}

		function version() {
			$revision   = KwartzCommand::revision;
			$lastupdate = KwartzCommand::lastupdate;
			return "kwartz.php: $revision ($date)";
		}


		##
		## parse command options  and toppings
		##
		function parse_args(&$args=NULL, $noarg="hvse", $argrequired="apl", $argoptional="i") {
			if ($args === NULL) {
				$args =& $this->args;
			}
			// assert(count($args) > 0));
			$this->command_name = basename(array_shift($args));
			$error_msg = NULL;
			while (count($args) > 0 && $args[0][0] == '-') {
				$optstr = substr(array_shift($args), 1);
				
				# parse toppings
				if ($optstr[0] == '-') {
					if ($optstr == '-help') {	# --help
						$this->options['h'] = TRUE;
					} elseif (preg_match('/^-([-\w]+)(?:=(.*))/', $optstr, $m = array())) {
						$key   = $m[1];
						$value = $m[2];
						if ($value === NULL) {
							$value = TRUE;
						} else {
							switch ($value) {
							case 'true':  $value = TRUE;   break;
							case 'false': $value = FALSE;  break;
							case 'null':  $value = NULL;   break;
							default:
							}
						}
						$this->toppings[$key] = $value;
					} else {
						$error_msg = "'-${optstr}': invalid option.";
						throw new KwartzCommandOptionError($error_msg);
					}
					continue;
				}
				
				# parse command options
				while ($optstr) {
					$optch = $optstr[0];
					$optstr = substr($optstr, 1);
					if (strpos($noarg, $optch) !== FALSE) {
						$this->options[$optch] = TRUE;
					} elseif (strpos($argrequired, $optch) !== FALSE) {
						$arg = $optstr ? $optstr : array_shift($args);
						if ($arg === NULL) {
							$error_msg = "-${optch}: argument required.";
						} else {
							$this->options[$optch] = $arg;
						}
						break;
					} elseif (strpos($argoptional, $optch) !== FALSE) {
						$this->options[$optch] = $optstr ? $optstr : TRUE;
						break;
					} else {
						echo "*** debgu: noarg=$noarg, argrequired=$argrequired, argoptional=$argoptional\n";
						$error_msg = "'-${optch}${optstr}': invalid option.";
						break;
					}
				}
				if ($error_msg) {
					throw new KwartzCommandOptionError($error_msg);
				}
			}  // end of while
		}  // end of function

	}  // end of class KwartzCommand


//}  // end of namespace Kwartz


##
## main program
##
if (basename(__FILE__) == basename($argv[0])) {
	try {
		$kwartz = new KwartzCommand($argv);
		echo $kwartz->main();
	} catch (KwartzException $ex) {
		if (defined('STDERR')) {
			fwrite(STDERR, "ERROR: " . $ex->getMessage() . "\n");
		} else {
			$stderr = fopen("php://stderr", "r");
			fwrite($stderr, "ERROR: " . $ex->getMessage() . "\n");
			fclose($fstderr);
		} 
		exit(1);
	}
	exit(0);
}
?>