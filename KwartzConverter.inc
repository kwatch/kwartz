<?php

###
### KwartzConverter.inc
###

require_once('KwartzException.inc');
require_once('KwartzNode.inc');
require_once('KwartzParser.inc');
require_once('KwartzUtility.inc');

// namespace Kwartz {


	class KwartzConvertionError extends KwartzException {
		var $converter;

		function __construct($msg, $converter) {
			parent::__construct($msg);
			$this->converter = $converter;
		}
	}


	class KwartzConverter {
		private $input;		// string
		private $parser;
		private $toppings;

		private $before_text;
		private $before_space;
		private $after_space;
		private $slash_etag;
		private $slash_empty;
		private $tag_name;
		private $attr_str;

		private $macro_stmt_list;


		static $flags_foreach = array(
			# directive nanme => flag_loop, flag_counter, flag_toggle
			'foreach' => array(FALSE, FALSE, FALSE),
			'Foreach' => array(FALSE, TRUE,  FALSE),
			'FOREACH' => array(FALSE, TRUE,  TRUE),
			'loop'    => array(TRUE,  FALSE, FALSE),
			'Loop'    => array(TRUE,  TRUE,  FALSE),
			'LOOP'    => array(TRUE,  TRUE,  TRUE),
		);

		static $escapes = array(
			'attr'  => array( '',   ''  ),
			'Attr'  => array( 'E(', ')' ),
			'ATTR'  => array( 'X(', ')' ),
			'embed' => array( '',   ''  ),
			'Embed' => array( 'E(', ')' ),
			'EMBED' => array( 'X(', ')' ),
		);
		
		function _attr_str()	   { return $this->attr_str; }		// for unit-test


		function __construct($input, $toppings=NULL) {
			$this->input = $input;
			$this->toppings = $toppings ? $toppings : array();
			$this->macro_stmt_list = array();
			$this->parser = new KwartzParser(' ', $this->toppings);
		}
		
		function topping($name, $default_value=NULL) {
			if (array_key_exists($name, $this->toppings)) {
				return $this->toppings[$name];
			}
			return $default_value;
		}


		const fetch_pattern = '/((?:.|\n)*?)([ \t]*)<(\/?)([:\w]+)((?:\s+[:\w]+=".*?")*)(\s*)(\/?)>([ \t]*\r?\n?)/';

		function fetch() {
			if (preg_match(KwartzConverter::fetch_pattern, $this->input, $m = array())) {
				$this->before_text  = $m[1];
				$this->before_space = $m[2];
				$this->slash_etag   = $m[3];
				$this->tag_name	    = $m[4];
				$this->attr_str	    = $m[5];
				$this->extra_space  = $m[6];
				$this->slash_empty  = $m[7];
				$this->after_space  = $m[8];
				$matched_length = strlen($m[0]);
				$this->input = substr($this->input, $matched_length);
				return $this->tag_name;
			}
			return $this->tag_name = NULL;
		}


		function fetch_all() {
			$s = '';
			while (($tag_name = $this->fetch()) != NULL) {
				if ($s) { $s .= "\n"; }
				$s .= "before_text:  " . kwartz_inspect_str($this->before_text) . "\n";
				$s .= "before_space: " . kwartz_inspect_str($this->before_space). "\n";
				$s .= "tag:          " . "<{$this->slash_etag}{$tag_name}{$this->extra_space}{$this->slash_empty}>\n";
				$s .= "attr_str:     " . kwartz_inspect_str($this->attr_str) . "\n";
				$s .= "after_space:  " . kwartz_inspect_str($this->after_space) . "\n";
			}
			$s .= "rest:         " . kwartz_inspect_str($this->input) . "\n\n";
			return $s;
		}


		## helper method for _convert()
		private function parse_attr_str($attr_str=NULL) {
			if ($attr_str === NULL) {
				$attr_str = $this->attr_str;
			}
			$pattern = '/(\s+)([:\w]+)="(.*?)"/';
			preg_match_all($pattern, $attr_str, $m = array());
			$spaces	     = $m[1];
			$attr_names  = $m[2];
			$attr_values = $m[3];

			$attr_hash   = array();
			$i = 0;
			foreach ($attr_names as $name) {
				$attr_hash[$name] = $attr_values[$i++];
			}

			$kd_value = $id_value = $php_value = NULL;
			if (array_key_exists('id',  $attr_hash)) { $id_value  = $attr_hash['id'];  }
			if (array_key_exists('kd',  $attr_hash)) { $kd_value  = $attr_hash['kd'];  }
			if (array_key_exists('php', $attr_hash)) { $php_value = $attr_hash['php']; }
			
			$directive = NULL;	// or tuple
			if ($id_value !== NULL || $kd_value !== NULL || $php_value !== NULL) {
				$embed_str = '';
				$id_directive = $kd_directive = $php_directive = NULL;
				$directive = NULL;
				if ($id_value !== NULL) {
					$id_directive = $this->parse_directive_kdstr($id_value, $attr_hash, $embed_str);
					if ($id_directive) { $directive = $id_directive; }
				}
				if ($kd_value !== NULL) {
					$kd_directive = $this->parse_directive_kdstr($kd_value, $attr_hash, $embed_str);
					if ($kd_directive) { $directive = $kd_directive; }
				}
				if ($php_value != NULL) {
					$php_directive = $this->parse_directive_phpstr($php_value, $attr_hash, $embed_str);
					if ($php_directive) { $directive = $php_directive; }
				}

				## rebuild $this->attr_str, excepting kd/id/php attributes.
				$s = '';
				$i = 0;
				foreach ($attr_names as $attr_name) {
					$attr_value = $attr_hash[$attr_name];
					if ($attr_name == 'php' || $attr_name == 'kd' || ($attr_name == 'id' && !preg_match('/^[-\w]+$/', $attr_value))) {
						# nothing
					} else {
						$space = $spaces[$i];
						$s .= "{$space}{$attr_name}=\"{$attr_value}\"";
					}
					unset($attr_hash[$attr_name]);
					$i++;
				}
				if (count($attr_hash) > 0) {
					foreach ($attr_hash as $attr_name => $attr_value) {
						$s .= " {$attr_name}=\"{$attr_value}\"";
					}
				}
				if ($embed_str) {
					$s .= $embed_str;
				}
				$this->attr_str = $s;
			}
			return $directive;
		}


		## for test of parse_attr_str()
		function _parse_attr_str(&$attr_str) {
			return $this->parse_attr_str($attr_str);
		}


		## helper method for convert().
		## - args:
		##     - $str : directive string.
		##		ex. "attr:class=klass;rowspan=rowspan"
		##     - $attr_exprs: hash of attribute string.
		##		ex. array('class'=>'klass', 'rowspan'=>'rowspan')
		##     - $embed_exprs: array of attribute string
		##		ex. array('flag ? "checked" : ""')
		## - return: a tuple of directive name and argument.
		##		ex. array('foreach', 'item=list')
		private function parse_directive_kdstr(&$str, &$attr_hash, &$embed_str) {
			$strs = preg_split('/;/', $str);
			$directive = NULL;
			foreach ($strs as $s) {
				if (preg_match('/^\w+$/', $s)) {
					$directive = array('mark', $s);
				} elseif (preg_match('/^(\w+):(.*)$/', $s, $matches = array())) {
					$dname = $matches[1];		// directive name
					$darg  = trim($matches[2]);	// directive arg
					switch ($dname) {
					case 'attr':  case 'Attr':  case 'ATTR':
						if (! preg_match('/^(\w+(?::\w+)?)[:=](.*)$/', $darg, $m=array())) {
							$msg = "'attr:\"'{$darg}\"': invalid directive.";
							throw new KwartzConvertionError($msg, $this);
						}
						$attr_name = $m[1];
						$expr_str  = $m[2];
						list($e1, $e2) = KwartzConverter::$escapes[$dname];	// 'E(' ')' or 'X(' ')'
						$attr_hash[$attr_name] = "#{{$e1}{$expr_str}{$e2}}#";
						//if     ($dname == 'Attr') { $attr_hash[$attr_name] = '#{E(' . $expr_str . ')}#'; }
						//elseif ($dname == 'ATTR') { $attr_hash[$attr_name] = '#{X(' . $expr_str . ')}#'; }
						//else                      { $attr_hash[$attr_name] = '#{'   . $expr_str .  '}#'; }
						break;
					//case 'embed':
					//	$embed_str .= ' #{'   . $darg .  '}#';
					//	break;
					//case 'Embed':
					//	$embed_str .= ' #{E(' . $darg . ')}#';
					//	break;
					//case 'EMBED':
					//	$embed_str .= ' #{X(' . $darg . ')}#';
					//	break;
					case 'embed':  case 'Embed':  case 'EMBED':
						list($e1, $e2) = KwartzConverter::$escapes[$dname];	// 'E(' ')' or 'X(' ')'
						$embed_str .= " #{{$e1}{$darg}{$e2}}#";
						break;
					case 'value':  case 'Value':  case 'VALUE':
					case 'mark':
					case 'replace':
					case 'if':  case 'elsif':  case 'elseif':  case 'else':  case 'unless':
					case 'while':
					case 'include':
					case 'dummy':
						$directive = array($dname, $darg);
						break;
					case 'set':
						if (preg_match('/^\w+:/', $darg)) {
							$darg = preg_replace('/:/', '=', $darg);
						}
						$directive = array($dname, $darg);
						break;
					case 'foreach': case 'Foreach': case 'FOREACH':
					case 'loop':	case 'Loop':	case 'LOOP':
						if (preg_match('/^\w+:/', $darg)) {
							$darg = preg_replace('/:/', '=', $darg);
						}
						$directive = array($dname, $darg);
						break;
					case 'include':  case 'load':
						if (! preg_match('/^\'(.*)\'$/', $darg, $m=array())) {
							$msg = "directive '$dname' requires filename as string.";
							throw new KwartzConvertionError($msg, $this);
						}
						$directive = array($dname, $darg);
						break;
					default:
						$msg = "'$s': invalid directive.";
						throw new KwartzConvertionError($msg, $this);
					}
				} else {
					$msg = "'$s': invalid directive.";
					throw new KwartzConvertionError($msg, $this);
				}
			}
			if ($directive) {
				$directive[2] = FALSE;		// $flag_php_mode false
			}
			return $directive;
		}


		## helper method for convert().
		## - args:
		##     - $str : directive string.
		##		ex. "attr('class'=>$klass,'rowspan'=>$rowspan);foreach($list as $item)"
		##     - $attr_exprs: hash of attribute string.
		##		ex. array('class'=>'$klass', 'rowspan'=>'$rowspan')
		##     - $embed_exprs: array of attribute string
		##		ex. array('$flag ? "checked" : ""')
		## - return: a tuple of directive name and argument.
		##		ex. array('foreach', '$list as $item')
		private function parse_directive_phpstr(&$str, &$attr_hash, &$embed_str) {
			$strs = preg_split('/;/', $str);
			$directive = NULL;
			foreach ($strs as $s) {
				if (preg_match('/^\w+$/', $s)) {
					$directive = $s == 'else' ? array('else', NULL) : array('mark', $s);
				} elseif (preg_match('/^(\w+)\((.*)\)$/', $s, $matches = array())) {
					$dname = $matches[1];
					$darg  = trim($matches[2]);
					switch ($dname) {
					case 'attr':  case 'Attr':  case 'ATTR':
						$pairs = preg_split('/,/', $darg);
						foreach ($pairs as $pair) {
							if (!preg_match('/^\'([-:\w]+)\'=>(.*)/', $pair, $m=array())) {
								$msg = "'attr:\"'{$pair}\"': invalid directive.";
								throw new KwartzConvertionError($msg, $this);
							}
							$attr_name = $m[1];
							$expr_str  = $m[2];
							#if     ($dname == 'Attr') { $expr_str = "E($expr_str)"; }
							#elseif ($dname == 'ATTR') { $expr_str = "X($expr_str)"; }
							#$attr_hash[$attr_name] = '@{' . $expr_str . '}@';
							list($e1, $e2) = KwartzConverter::$escapes[$dname];	// 'E(' ')' or 'X(' ')'
							$attr_hash[$attr_name] = "@{{$e1}{$expr_str}{$e2}}@";
						}
						break;
					//case 'embed':
					//	$embed_str .= ' @{'   . $darg .  '}@';
					//	break;
					//case 'Embed':
					//	$embed_str .= ' @{E(' . $darg . ')}@';
					//	break;
					//case 'EMBED':
					//	$embed_str .= ' @{X(' . $darg . ')}@';
					//	break;
					case 'embed':  case 'Embed':  case 'EMBED':
						list($e1, $e2) = KwartzConverter::$escapes[$dname];	// 'E(' ')' or 'X(' ')'
						$embed_str .= " @{{$e1}{$darg}{$e2}}@";
						break;
					case 'echo':  case 'Echo':  case 'ECHO':
					case 'mark':
					case 'replace':
					case 'if':  case 'elseif':  case 'else':
					case 'while':
					case 'set':
					case 'foreach': case 'Foreach': case 'FOREACH':
					case 'loop':	case 'Loop':	case 'LOOP':
					case 'dummy':
						$directive = array($dname, $darg);
						break;
					case 'include':  case 'load':
						if (!preg_match('/^\'(.*)\'$/', $darg, $m=array())) {
							$msg = "directive '$dname' requires filename as string.";
							throw new KwartzConvertionError($msg, $this);
						}
						$directive = array($dname, $darg);
						break;
					default:
						$msg = "'$dname': invalid directive.";
						throw new KwartzConvertionError($msg, $this);
					}
				} else {
					$directive = array('set', $s);		## regard as assign statement
				}
			}
			if ($directive) {
				$directive[2] = TRUE;		// $flag_php_mode true
			}
			return $directive;
		}


		## test for parse_directive_kdstr()
		function _parse_directive_kdstr(&$str, &$attr_exprs, &$embed_exprs) {
			return $this->parse_directive_kdstr($str, $attr_exprs, $embed_exprs);
		}
		function _parse_directive_phpstr(&$str, &$attr_exprs, &$embed_exprs) {
			return $this->parse_directive_phpstr($str, $attr_exprs, $embed_exprs);
		}


		private function create_print_stmt($str) {
			if (! $str) {
				return NULL;
			}
			$list = array();
			$s = $str;
			$pattern = '/((?:.|\n)*?)(?:\#\{(.*?)\}\#|@\{(.*?)\}@)((?:.|\n)*)/m';
			while (preg_match($pattern, $s, $m = array())) {
				$text     = $m[1];
				//$value    = $m[2];
				//$phpvalue = $m[3];
				$rest     = $m[4];
				if ($m[2]) {
					$value = $m[2];
					$flag_php_mode = false;
				} elseif ($m[3]) {
					$value = $m[3];
					$flag_php_mode = true;
				} else {
					$value = NULL;
				}
				if ($text)  {
					$list[] = new KwartzStringExpression($text);
				}
				if ($value) {
					if (preg_match('/^@([CSD])\((.*)\)$/', $value, $m=array())) {
						switch ($m[1]) {
						case 'C':  $csd = 'checked="checked"'  ;  break;
						case 'S':  $csd = 'selected="selected"';  break;
						case 'D':  $csd = 'disabled="disabled"';  break;
						}
						$cond_expr = $this->parse_expression($m[2], $flag_php_mode);
						$expr = new KwartzConditionalExpression('?', $cond_expr,
								new KwartzStringExpression($csd), new KwartzStringExpression(''));
					} else {
						$expr = $this->parse_expression($value, $flag_php_mode);
					}
					$list[] = $expr;
				}
				$s = $rest;
			}
			if ($s) {
				$list[] = new KwartzStringExpression($s);
			}
			$print_stmt = new KwartzPrintStatement($list);
			return $print_stmt;
		}


		private function create_tagstr() {
			$s = "{$this->before_space}<{$this->slash_etag}{$this->tag_name}{$this->attr_str}{$this->extra_space}{$this->slash_empty}>{$this->after_space}";
			return $s;
		}


		function convert() {
			$block = $this->_convert(NULL);
			$list = $this->macro_stmt_list;
			foreach ($block->statements() as $stmt) {
				$list[] = $stmt;
			}
			return new KwartzBlockStatement($list);
		}


		private function _convert($end_tag_name) {
			$stmt_list = array();
			if ($end_tag_name) {
				$print_stmt = $this->create_print_stmt($this->create_tagstr());
				$stmt_list[] = $print_stmt;
			}
			while (($tag_name = $this->fetch()) != NULL) {
				if ($this->before_text) {
					$print_stmt = $this->create_print_stmt($this->before_text);
					$stmt_list[] = $print_stmt;
				}
				if ($this->slash_empty) {		# empty tag
					if ($this->attr_str && ($directive = $this->parse_attr_str($this->attr_str)) != NULL) {
						$flag_remove_span = ($tag_name == 'span' && ! $this->attr_str);
						if ($flag_remove_span) {
							$list = array();
						} else {
							$print_stmt = $this->create_print_stmt($this->create_tagstr());
							$list = array($print_stmt);
						}
						$block = new KwartzBlockStatement($list);
						$this->handle_directive($directive, $block, $stmt_list, $flag_remove_span);
					} else {
						$print_stmt = $this->create_print_stmt($this->create_tagstr());
						$stmt_list[] = $print_stmt;
					}
				} elseif ($this->slash_etag) {		# end tag
					$print_stmt = $this->create_print_stmt($this->create_tagstr());
					$stmt_list[] = $print_stmt;
					if ($tag_name == $end_tag_name) {
						$block = new KwartzBlockStatement($stmt_list);
						return $block;
					}
				} else {				# start tag
					if ($this->attr_str && ($directive = $this->parse_attr_str($this->attr_str)) != NULL) { # directive specifed
						$flag_remove_span = ($tag_name == 'span' && ! $this->attr_str);
						$block = $this->_convert($tag_name);			# call recursively
						if ($flag_remove_span) {
							# ignore first and last statement
							$first_stmt = $block->shift(); //array_shift($block->statements());
							$last_stmt  = $block->pop();   //array_pop($block->statements());
						}
						$this->handle_directive($directive, $block, $stmt_list, $flag_remove_span);
					} else {										# directive not specified
						if ($tag_name == $end_tag_name) {
							$block = $this->_convert($tag_name);		# call recursively
							foreach ($block->statements() as $stmt) {
								$stmt_list[] = $stmt;
							}
						} else {
							$print_stmt = $this->create_print_stmt($this->create_tagstr());
							$stmt_list[] = $print_stmt;
						}
					}
				}
			}
			if ($end_tag_name) {
				$msg = "end tag '</{$end_tag_name}>' not found.";
				throw new KwartzConvertionError($msg, $this);
			}
			# when $end_tag_name == NULL
			if ($this->input) {
				$print_stmt = $this->create_print_stmt($this->input);
				$stmt_list[] = $print_stmt;
			}
			$block = new KwartzBlockStatement($stmt_list);
			return $block;
		}


		static $handler_dispatcher = array(
			# directive name => handler name
			'foreach' => 'handle_directive_foreach',
			'Foreach' => 'handle_directive_foreach',
			'FOREACH' => 'handle_directive_foreach',
			'loop'    => 'handle_directive_foreach',
			'Loop'    => 'handle_directive_foreach',
			'LOOP'    => 'handle_directive_foreach',

			'value'   => 'handle_directive_value',
			'Value'   => 'handle_directive_value',
			'VALUE'   => 'handle_directive_value',
			'echo'    => 'handle_directive_value',
			'Echo'    => 'handle_directive_value',
			'ECHO'    => 'handle_directive_value',

			'if'      => 'handle_directive_if',
			'unless'  => 'handle_directive_if',
			'elseif'  => 'handle_directive_else',
			'elsif'   => 'handle_directive_else',
			'else'    => 'handle_directive_else',

			'set'     => 'handle_directive_set',
			'while'   => 'handle_directive_while',
			'mark'    => 'handle_directive_mark',
			'replace' => 'handle_directive_replace',
			'load'    => 'handle_directive_load',
			'include' => 'handle_directive_load',
			'dummy'   => 'handle_directive_dummy',
		);

		private function handle_directive(&$directive, &$block, &$stmt_list, $flag_remove_span=FALSE) {
			$directive_name = $directive[0];
			$directive_arg	= $directive[1];
			$flag_php_mode	= $directive[2];
			if (array_key_exists($directive_name, KwartzConverter::$handler_dispatcher)) {
				$handler = KwartzConverter::$handler_dispatcher[$directive_name];
				$this->$handler($directive_name, $directive_arg, $flag_php_mode, $block, $stmt_list, $flag_remove_span);
			} else {
				$msg = "'internal error: {$directive_name}': invalid directive name.";
				throw new KwartzConvertionError($msg, $this);
			}
		}

		private function handle_directive_foreach($directive_name, $directive_arg, $flag_php_mode, &$block, &$stmt_list, &$flag_remove_span) {
			if ($flag_php_mode) {
				if ($ary = preg_split('/\sas\s/', $directive_arg)) {
					$list_expr    = $this->parse_expression($ary[0], $flag_php_mode);
					$loopvar_expr = $this->parse_expression($ary[1], $flag_php_mode);
				} else {
					$msg = "invalid '$directive_name' directive.";
					throw new KwartzConvertionError($msg, $this);
				}
			} else {
				$expr = $this->parse_expression($directive_arg, $flag_php_mode);
				if ($expr->token() != '=') {
					$msg = "invalid '$directive_name' directive.";
					throw new KwartzConvertionError($msg, $this);
				}
				$loopvar_expr = $expr->left();
				$list_expr = $expr->right();
			}
			if ($loopvar_expr->token() != 'variable') {
				$msg = "invalid loop variable in '$directive_name' directive.";
				throw new KwartzConvertionError($msg, $this);
			}

			list($flag_loop, $flag_count, $flag_toggle) = KwartzConverter::$flags_foreach[$directive_name];

			$loopvar_name = $loopvar_expr->value();
			$ctr_name     = $loopvar_name . '_ctr';
			$toggle_name  = $loopvar_name . '_tgl';
			if ($flag_loop) {
				if (! $flag_remove_span) {
					$first_stmt = $block->shift(); //array_shift($block->statements());
					$last_stmt  = $block->pop();   //array_pop($block->statements());
					$stmt_list[] = $first_stmt;
				}
			}
			if ($flag_toggle) {
				$toggle_expr = new KwartzVariableExpression($toggle_name);
				$ctr_expr = new KwartzVariableExpression($ctr_name);
				$expr = new KwartzBinaryExpression('%', $ctr_expr, new KwartzNumericExpression(2));
				$expr = new KwartzBinaryExpression('==', $expr, new KwartzNumericExpression(0));
				$expr = new KwartzConditionalExpression('?', $expr, 
							new KwartzStringExpression($this->topping('even_var', 'even')),
							new KwartzStringExpression($this->topping('odd_var', 'odd')));
				$expr = new KwartzBinaryExpression('=', $toggle_expr, $expr);
				$assign_stmt = new KwartzSetStatement($expr);
				array_unshift($block->statements(), $assign_stmt);
			}
			if ($flag_count) {
				$ctr_expr = new KwartzVariableExpression($ctr_name);
				$init_expr = new KwartzBinaryExpression('=',  $ctr_expr, new KwartzNumericExpression(0));
				$init_stmt = new KwartzSetStatement($init_expr);
				$incr_expr = new KwartzBinaryExpression('+=', $ctr_expr, new KwartzNumericExpression(1));
				$incr_stmt = new KwartzSetStatement($incr_expr);
				$stmt_list[] = $init_stmt;
				array_unshift($block->statements(), $incr_stmt);
			}
			$stmt = new KwartzForeachStatement($loopvar_expr, $list_expr, $block);
			$stmt_list[] = $stmt;
			if ($flag_loop) {
				if (! $flag_remove_span) {
					$stmt_list[] = $last_stmt;
				}
			}
		}

		private function handle_directive_set($directive_name, $directive_arg, $flag_php_mode, &$block, &$stmt_list, $flag_remove_span) {
			$expr = $this->parse_expression($directive_arg, $flag_php_mode);
			$stmt = new KwartzSetStatement($expr);
			$stmt_list[] = $stmt;
			//$stmt_list[] = $block;
			foreach ($block->statements() as $stmt) {
				$stmt_list[] = $stmt;
			}
		}

		private function handle_directive_value($directive_name, $directive_arg, $flag_php_mode, &$block, &$stmt_list, $flag_remove_span) {
			$expr = $this->parse_expression($directive_arg, $flag_php_mode);
			if ($directive_name == 'Value' || $directive_name == 'Echo') {
				$expr = new KwartzFunctionExpression('E', array($expr));
			} elseif ($directive_name == 'VALUE' || $directive_name == 'ECHO') {
				$expr = new KwartzFunctionExpression('X', array($expr));
			}
			if ($flag_remove_span) {
				$stmt_list[] = new KwartzPrintStatement(array($expr));
			} else {
				$stmt_list[] = $block->shift();	 //array_shift($block->statements());	// stag
				$stmt_list[] = new KwartzPrintStatement(array($expr));
				$stmt_list[] = $block->pop();	 //array_pop($block->statements());	// etag
			}
		}

		private function handle_directive_if($directive_name, $directive_arg, $flag_php_mode, &$block, &$stmt_list, $flag_remove_span) {
			$expr = $this->parse_expression($directive_arg, $flag_php_mode);
			if ($directive_name == 'unless') {
				$expr = new KwartzUnaryExpression('!', $expr);
			}
			$stmt = new KwartzIfStatement($expr, $block, NULL);
			$stmt_list[] = $stmt;
		}

		private function handle_directive_else($directive_name, $directive_arg, $flag_php_mode, &$block, &$stmt_list, $flag_remove_span) {
			$last_stmt = end($stmt_list);
			if ($last_stmt->token() != ':if') {
				$msg = "'$directive_name' directive should be placed just after 'if' or 'elseif' statement.";
				throw new KwartzConvertionError($msg, $this);
			}
			if ($directive_name == 'else') {	// 'else'
				$stmt = $block;
			} else {				// 'elseif', 'elsif'
				$expr = $this->parse_expression($directive_arg, $flag_php_mode);
				$stmt = new KwartzIfStatement($expr, $block, NULL);
			}
			$st = $last_stmt;
			while ($st->token() == ':if' && $st->else_stmt() != NULL) {
				$st = $st->else_stmt();
			}
			if ($st->token() != ':if') {
				$msg = "'$directive_name' directive cannot find corresponding if-statement.";
				throw new KwartzConvertionError($msg, $this);
			}
			$st->set_else_stmt($stmt);
		}

		private function handle_directive_while($directive_name, $directive_arg, $flag_php_mode, &$block, &$stmt_list, $flag_remove_span) {
			$expr = $this->parse_expression($directive_arg, $flag_php_mode);
			$stmt = new KwartzWhileStatement($expr, $block);
			$stmt_list[] = $stmt;
		}

		private function handle_directive_mark($directive_name, $directive_arg, $flag_php_mode, &$block, &$stmt_list, $flag_remove_span) {
			$name = $directive_arg;
			if ($flag_remove_span) {
				$stag_list = array();
				$etag_list = array();
			} else {
				$stag_stmt = $block->shift();	//array_shift($block->statements());
				$etag_stmt = $block->pop();	//array_pop($block->statements());
				$stag_list = array($stag_stmt);
				$etag_list = array($etag_stmt);
			}
			$stag_block = new KwartzBlockStatement($stag_list);
			$etag_block = new KwartzBlockStatement($etag_list);
			$cont_block = $block;
			$list = array(	new KwartzExpandStatement("stag_$name"),
					new KwartzExpandStatement("cont_$name"),
					new KwartzExpandStatement("etag_$name") );
			$elem_block = new KwartzBlockStatement($list);
			$this->macro_stmt_list[] = new KwartzMacroStatement("stag_$name", $stag_block);
			$this->macro_stmt_list[] = new KwartzMacroStatement("cont_$name", $cont_block);
			$this->macro_stmt_list[] = new KwartzMacroStatement("etag_$name", $etag_block);
			//$this->macro_stmt_list[] = new KwartzMacroStatement("elem_$name", $elem_block);
			$this->macro_stmt_list[] = new KwartzMacroStatement("element_$name", $elem_block);	## element_ or elem_
			$stmt_list[] = new KwartzExpandStatement("element_$name");
		}

		private function handle_directive_replace($directive_name, $directive_arg, $flag_php_mode, &$block, &$stmt_list, $flag_remove_span) {
			//$macro_name = 'elem_' . $directive_arg;
			$macro_name = 'element_' . $directive_arg;						## element_ or elem_
			$stmt_list[] = new KwartzExpandStatement($macro_name);	# ignore $body
		}

		private function handle_directive_load($directive_name, $directive_arg, $flag_php_mode, &$block, &$stmt_list, $flag_remove_span) {
			$expr = $this->parse_expression($directive_arg, $flag_php_mode);
			if ($expr->token() != 'string') {
				$msg = "'$directive_name' directive requires filename as string.";
				throw KwartzConvertionError($msg, $this);
			}
			$filename = $expr->value();
			$topping_name = $directive_name == 'include' ? 'include_path' : 'load_path';
			if ($this->topping($topping_name)) {
				foreach ($this->topping($topping_name) as $dir) {
					if (file_exists("$dir/$filename")) {
						$filename = "$dir/$filename";
						break;
					}
				}
			}
			if (! file_exists($filename)) {
				$msg = "'$directive_name' directive: file '$filename' not found.";
				throw new KwartzConvertionError($msg, $this);
			}
			$first_stmt = $block->shift();
			$last_stmt = $block->pop();
			$input = file_get_contents($filename);
			if ($directive_name == 'include') {
				$pdata =& $input;
				$converter = new KwartzConverter($pdata);
				$block = $converter->convert();
			} else {
				$plogic =& $input;
				$parser = new KwartzParser($plogic);
				$block = $parser->parse();
			}
			$stmt_list[] = $first_stmt;
			foreach ($block->statements() as $stmt) {
				$stmt_list[] = $stmt;
			}
			$stmt_list[] = $last_stmt;
		}

		private function handle_directive_dummy($directive_name, $directive_arg, $flag_php_mode, &$block, &$stmt_list, $flag_remove_span) {
			# do nothing;
		}


		private function parse_expression($str, $flag_php_mode=FALSE) {
			$this->parser->reset($str);
			$expr = $this->parser->parse_expression_strictly($flag_php_mode);
			return $expr;
		}
	}

// }  // end of namespace Kwartz
?>