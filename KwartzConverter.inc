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
		private $flag_etag;
		private $flag_single;
		private $tag_name;
		private $attr_str;

		private $macro_stmt_list;
		
		function _attr_str()	   { return $this->attr_str; }		// for unit-test


		function __construct($input, $toppings=NULL) {
			$this->input = $input;
			$this->toppings = $toppings ? $toppings : array();
			$this->macro_stmt_list = array();
			$this->parser = new KwartzParser(' ', $this->toppings);
		}
		
		function topping($name) {
			if (array_key_exists($name, $this->toppings)) {
				return $this->toppings[$name];
			}
			return NULL;
		}


		//const fetch_pattern = '/((?:.|\n)*?)([ \t]*)<(\/?)([:\w]+)((?:\s+[:\w]+=".*?")*)(\/?)>([ \t]*\r?\n?)((?:.|\n)*)/';
		//const fetch_pattern = '/((?:.|\n)*?)([ \t]*)<(\/?)([:\w]+)((?:\s+[:\w]+=".*?")*)(\/?)>([ \t]*\r?\n?)/';
		const fetch_pattern = '/((?:.|\n)*?)([ \t]*)<(\/?)([:\w]+)((?:\s+[:\w]+=".*?")*)(\/?)>([ \t]*\r?\n?)/';

		function fetch() {
			if (preg_match(KwartzConverter::fetch_pattern, $this->input, $m = array())) {
				$this->before_text  = $m[1];
				$this->before_space = $m[2];
				$this->flag_etag    = $m[3];
				$this->tag_name	    = $m[4];
				$this->attr_str	    = $m[5];
				$this->flag_single  = $m[6];
				$this->after_space  = $m[7];
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
				$s .= "tag:          " . "<" .  ($this->flag_etag ? '/' : '') . $tag_name . ($this->flag_single ? '/' : '') . ">\n";
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
			$m = array();
			preg_match_all($pattern, $attr_str, $m);
			$spaces	     = $m[1];
			$attr_names  = $m[2];
			$attr_values = $m[3];
			$kd_value = NULL;
			$id_value = NULL;
			$php_value = NULL;
			$i = -1;
			foreach ($attr_names as $name) {
				$i++;
				if ($name == 'id') {
					$id_value  = $attr_values[$i];
				} elseif ($name == 'kd') {
					$kd_value  = $attr_values[$i];
				} elseif ($name == 'php') {
					$php_value = $attr_values[$i];
				}
			}
			$directive = NULL;	// or tuple
			if ($id_value !== NULL || $kd_value !== NULL || $php_value !== NULL) {
				$kd_attr_exprs = array();	// hash
				$php_attr_exprs = array();	// hash
				$id_directive = $kd_directive = $php_directive = NULL;
				$directive = NULL;
				if ($id_value !== NULL) {
					$id_directive = $this->parse_directive_kdstr($id_value, $kd_attr_exprs);
					if ($id_directive) { $directive = $id_directive; }
				}
				if ($kd_value !== NULL) {
					$kd_directive = $this->parse_directive_kdstr($kd_value, $kd_attr_exprs);
					if ($kd_directive) { $directive = $kd_directive; }
				}
				if ($php_value != NULL) {
					$php_directive = $this->parse_directive_phpstr($php_value, $php_attr_exprs);
					if ($php_directive) { $directive = $php_directive; }
				}

				## deploy attribute expression strings which are specified as directive.
				$this->deploy_attr_exprs($kd_attr_exprs,  $spaces, $attr_names, $attr_values, '#{', '}#');
				$this->deploy_attr_exprs($php_attr_exprs, $spaces, $attr_names, $attr_values, '@{', '}@');

				## rebuild $this->attr_str, excepting kd/id/php attributes.
				$s = '';
				$i = -1;
				foreach ($attr_names as $attr_name) {
					$i++;
					$value = $attr_values[$i];
					if ($attr_name == 'php' || $attr_name == 'kd' || ($attr_name == 'id' && !preg_match('/^[-\w]+$/', $value))) {
						# nothing
					} else {
						$space = $spaces[$i];
						$s .= "{$space}{$attr_name}=\"{$value}\"";
					}
				}
				$this->attr_str = $s;
			}
			return $directive;
		}


		## deploy attribute expression string.
		##   - replace 'attr="value"' by 'attr="#{expr}#"'
		##   - add 'attr="#{expr}#"'
		private function deploy_attr_exprs(&$attr_exprs, &$spaces, &$attr_names, &$attr_values, $prefix, $postfix) {
			if (count($attr_exprs) == 0) {
				return;
			}
			$i = -1;
			foreach ($attr_names as $attr_name) {
				$i++;
				if (array_key_exists($attr_name, $attr_exprs)) {
					$expr_str = $attr_exprs[$attr_name];
					$new_value = $prefix . $expr_str . $postfix;
					$attr_values[$i] = $new_value;
					unset($attr_exprs[$attr_name]);
				}
			}
			foreach ($attr_exprs as $attr_name => $expr_str) {
				$spaces[] = ' ';
				$attr_names[] = $attr_name;
				$attr_values[] = $prefix . $expr_str . $postfix;
			}
		}


		## for test of parse_attr_str()
		function _parse_attr_str(&$attr_str) {
			return $this->parse_attr_str($attr_str);
		}


		## helper method for convert().
		## returns a tuple(==array($name, $value)).
		private function parse_directive_kdstr(&$str, &$kd_attr_exprs) {
			$strs = preg_split('/;/', $str);
			$directive = NULL;
			foreach ($strs as $s) {
				if (preg_match('/^\w+$/', $s)) {
					$directive = array('mark', $s);
				} elseif (preg_match('/^(\w+):(.*)$/', $s, $matches = array())) {
					$name  = $matches[1];
					$value = trim($matches[2]);
					switch ($name) {
					case 'attr':
						if (preg_match('/^(\w+(?::\w+)?)[:=](.*)$/', $value, $m=array())) {
							$attr_name = $m[1];
							$expr_str  = $m[2];
							$kd_attr_exprs[$attr_name] = $expr_str;
						} else {
							$msg = "'attr:\"'{$value}\"': invalid directive.";
							throw new KwartzConvertionError($msg, $this);
						}
						break;
					case 'value':  case 'Value':  case 'VALUE':
					case 'mark':
					case 'replace':
					case 'if':  case 'elsif':  case 'elseif':  case 'else':  case 'unless':
					case 'while':
					case 'include':
					case 'dummy':
						$directive = array($name, $value);
						break;
					case 'set':
						if (preg_match('/^\w+:/', $value)) {
							$value = preg_replace('/:/', '=', $value);
						}
						$directive = array($name, $value);
						break;
					case 'foreach': case 'Foreach': case 'FOREACH':
					case 'loop':	case 'Loop':	case 'LOOP':
						if (preg_match('/^\w+:/', $value)) {
							$value = preg_replace('/:/', '=', $value);
						}
						$directive = array($name, $value);
						break;
					case 'include':  case 'load':
						if (! preg_match('/^\'(.*)\'$/', $value, $m=array())) {
							$msg = "directive '$name' requires filename as string.";
							throw new KwartzConvertionError($msg, $this);
						}
						$directive = array($name, $value);
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
		##     - $kd_attr_exprs: hash of attributes.
		##		ex. array('class'=>'$klass', 'rowspan'=>'$rowspan')
		## - return: a tuple of directive name and argument.
		##		ex. array('foreach', '$list as $item')
		private function parse_directive_phpstr(&$str, &$attr_exprs) {
			$strs = preg_split('/;/', $str);
			$directive = NULL;
			foreach ($strs as $s) {
				if (preg_match('/^\w+$/', $s)) {
					$directive = $s == 'else' ? array('else', NULL) : array('mark', $s);
				} elseif (preg_match('/^(\w+)\((.*)\)$/', $s, $matches = array())) {
					$name  = $matches[1];
					$value = trim($matches[2]);
					switch ($name) {
					case 'attr':  case 'Attr':  case 'ATTR':
						$flag_escape = $name != 'ATTR';
						$pairs = preg_split('/,/', $value);
						foreach ($pairs as $pair) {
							if (preg_match('/^\'([-:\w]+)\'=>(.*)/', $pair, $m=array())) {
								$attr_name = $m[1];
								$expr_str  = $m[2];
								//$expr_str  = $flag_escape ? "htmlspecialchars({$m[2]})" : $m[2];
								$attr_exprs[$attr_name] = $expr_str;
							} else {
								$msg = "'attr:\"'{$pair}\"': invalid directive.";
								throw new KwartzConvertionError($msg, $this);
							}
						}
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
						$directive = array($name, $value);
						break;
					case 'include':  case 'load':
						if (!preg_match('/^\'(.*)\'$/', $value, $m=array())) {
							$msg = "directive '$name' requires filename as string.";
							throw new KwartzConvertionError($msg, $this);
						}
						$directive = array($name, $value);
						break;
					default:
						$msg = "'$name': invalid directive.";
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
		function _parse_directive_kdstr(&$str, &$attr_exprs) {
			return $this->parse_directive_kdstr($str, $attr_exprs);
		}
		function _parse_directive_phpstr(&$str, &$attr_exprs) {
			return $this->parse_directive_phpstr($str, $attr_exprs);
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
			$slash1 = $this->flag_etag ? "/" : "";
			$slash2 = $this->flag_single ? "/" : "";
			$s = "{$this->before_space}<{$slash1}{$this->tag_name}{$this->attr_str}{$slash2}>{$this->after_space}";
			return $s;
		}


		function convert() {
			$block = $this->_convert(NULL);
			//$revlist = array_reverse($this->macro_stmt_list);
			//foreach ($revlist as $macro_stmt) {
			//	//array_push($statements, $macro_stmt);
			//	$block->unshift($macro_stmt);
			//}
			//return $block;
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
				if ($this->flag_single) {		# single tag
					if ($this->attr_str && ($directive = $this->parse_attr_str($this->attr_str)) != NULL) {
						$flag_remove_span = ($tag_name == 'span' && ! $this->attr_str);
						if ($flag_remove_span) {
							$list = array();
						} else {
							$print_stmt = $this->create_print_stmt($this->create_tagstr());
							$list = array($print_stmt);
						}
						$block = new KwartzBlockStatement($list);
						$this->store_stmt_for_directive($directive, $block, $stmt_list, $flag_remove_span);
					} else {
						$print_stmt = $this->create_print_stmt($this->create_tagstr());
						$stmt_list[] = $print_stmt;
					}
				} elseif ($this->flag_etag) {		# end tag
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
						$this->store_stmt_for_directive($directive, $block, $stmt_list, $flag_remove_span);
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


		private function store_stmt_for_directive(&$directive, &$block, &$stmt_list, $flag_remove_span=FALSE) {
			$directive_name = $directive[0];
			$directive_arg	= $directive[1];
			$flag_php_mode	= $directive[2];

			switch ($directive_name) {
			case 'foreach':
			case 'loop':
			case 'Foreach':
			case 'Loop':
			case 'FOREACH':
			case 'LOOP':
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
				$flag_loop = $flag_toggle = $flag_count = FALSE;
				switch ($directive_name) {
				case 'FOREACH':
					$flag_toggle = TRUE;
					# don't break
				case 'Foreach':
					$flag_count  = TRUE;
					# don't break
				case 'foreach':
					break;
				case 'LOOP':
					$flag_toggle = TRUE;
					# don't break
				case 'Loop':
					$flag_count  = TRUE;
					# don't break
				case 'loop':
					$flag_loop   = TRUE;
					break;
				}

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
					$expr = new KwartzConditionalExpression('?', $expr, new KwartzStringExpression('even'),
											new KwartzStringExpression('odd'));
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
				break;

			case 'set':
				$expr = $this->parse_expression($directive_arg, $flag_php_mode);
				$stmt = new KwartzSetStatement($expr);
				$stmt_list[] = $stmt;
				//$stmt_list[] = $block;
				foreach ($block->statements() as $stmt) {
					$stmt_list[] = $stmt;
				}
				break;

			case 'value':  case 'Value':  case 'VALUE':
			case 'echo':   case 'Echo':   case 'ECHO':
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
				break;

			case 'if':
				$expr = $this->parse_expression($directive_arg, $flag_php_mode);
				$stmt = new KwartzIfStatement($expr, $block, NULL);
				$stmt_list[] = $stmt;
				break;

			case 'unless':
				$expr = $this->parse_expression($directive_arg, $flag_php_mode);
				$expr = new KwartzUnaryExpression('!', $expr);
				$stmt = new KwartzIfStatement($expr, $block, NULL);
				$stmt_list[] = $stmt;
				break;

			case 'elseif':
			case 'else':
				$last_stmt = end($stmt_list);
				if ($last_stmt->token() != ':if') {
					$msg = "'$directive_name' directive should be placed just after 'if' statement.";
					throw new KwartzConvertionError($msg, $this);
				}
				if ($directive_name == 'else') {
					$stmt = $block;
				} else {
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
				break;

			case 'while':
				$expr = $this->parse_expression($directive_arg, $flag_php_mode);
				$stmt = new KwartzWhileStatement($expr, $block);
				$stmt_list[] = $stmt;
				break;

			case 'mark':
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
				break;

			case 'replace':
				//$macro_name = 'elem_' . $directive_arg;
				$macro_name = 'element_' . $directive_arg;						## element_ or elem_
				$stmt_list[] = new KwartzExpandStatement($macro_name);	# ignore $body
				break;

			case 'include':
			case 'load':
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
				break;

			case 'dummy':
				# do nothing;
				break;

			default:
				$msg = "'{$directive_name}': invalid directive name.";
				throw new KwartzConvertionError($msg, $this);
			}
		}


		private function parse_expression($str, $flag_php_mode=FALSE) {
			$this->parser->reset($str);
			$expr = $this->parser->parse_expression_strictly($flag_php_mode);
			return $expr;
		}
	}

// }  // end of namespace Kwartz
?>