<?php

###
### KwartzConverter.inc
###

require_once('KwartzException.inc');
require_once('KwartzElement.inc');
require_once('KwartzScanner.inc');
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
		private $before_text;
		private $after_text;
		private $before_space;
		private $after_space;
		private $flag_etag;
		private $flag_single;
		private $tag_name;
		private $attr_str;

		private $macro_stmt_list;

		//function _input()	   { return $this->input; }
		//function _before_text()  { return $this->before_text; }
		//function _after_text()   { return $this->after_text; }
		//function _before_space() { return $this->before_space; }
		//function _after_space()  { return $this->after_space; }
		//function _flag_etag()	   { return $this->flag_etag; }
		//function _flag_single()  { return $this->flag_single; }
		//function _tag_name()	   { return $this->tag_name; }
		function _attr_str()	   { return $this->attr_str; }		// for unit-test


		function __construct($input) {
			$this->input = $input;
			$this->macro_stmt_list = array();
		}


		function fetch() {
			//$pattern = '/(.*?)([ \t]*)<(\/?)([:\w]+)((?:\s+[:\w]=".*?")*)(\/?)>([ \t]*\r?\n?)(.*)/m';
			//$pattern = '/(.*)([ \t]*)<(\/?)([:\w]+)((?:\s+[:\w]=".*?")*)(\/?)>([ \t]*\r?\n?)(.*)/m';
			$pattern = '/((?:.|\n)*?)([ \t]*)<(\/?)([:\w]+)((?:\s+[:\w]+=".*?")*)(\/?)>([ \t]*\r?\n?)((?:.|\n)*)/';
			$m = array();
			if (preg_match($pattern, $this->input, $m)) {
				$this->before_text  = $m[1];
				$this->before_space = $m[2];
				$this->flag_etag    = $m[3];
				$this->tag_name	    = $m[4];
				$this->attr_str	    = $m[5];
				$this->flag_single  = $m[6];
				$this->after_space  = $m[7];
				$this->after_text   = $m[8];
				$this->input = $this->after_text;
			} else {
				//$this->before_text  = NULL;
				//$this->before_space = NULL;
				//$this->flag_etag    = NULL;
				$this->tag_name	    = NULL;
				//$this->attr_str     = NULL;
				//$this->flag_single  = NULL;
				//$this->after_space  = NULL;
				//$this->after_text   = NULL;
			}
			return $this->tag_name;
		}


		function fetch_all() {
			$s = '';
			while (($tag_name = $this->fetch()) != NULL) {
				$s .= kwartz_inspect_str($this->before_text);
				$s .= ' ' . kwartz_inspect_str($this->before_space);
				$s .= ' <' . ($this->flag_etag ? '/' : '') . $tag_name;
				$s .= ' ' . kwartz_inspect_str($this->attr_str);
				$s .= ($this->flag_single ? '/' : '') . '> ';
				$s .= kwartz_inspect_str($this->after_space);
				$s .= "\n";
				//$s .= kwartz_inspect_str($this->after_text) . "\n";
			}
			$s .= kwartz_inspect_str($this->input);
			return $s;
		}


		## helper method for convert()
		private function parse_attr_str($attr_str) {
			if ($attr_str === NULL) {
				$attr_str = $this->attr_str;
			}
			$pattern = '/(\s+)([:\w]+)="(.*?)"/';
			$m = array();
			preg_match_all($pattern, $attr_str, $m);
			$spaces	     = $m[1];
			$attr_names  = $m[2];
			$attr_values = $m[3];
			$kd_name = 'kd';
			$kd_value = NULL;
			$id_value = NULL;
			$i = -1;
			foreach ($attr_names as $name) {
				$i++;
				if ($name == 'id') {
					$id_value = $attr_values[$i];
				}
				if ($name == $kd_name) {
					$kd_value = $attr_values[$i];
				}
			}
			$directive = NULL;	// or tuple
			if ($id_value !== NULL || $kd_value !== NULL) {
				$attr_directives = array();	// hash
				$id_directive = $kd_directive = NULL;
				if ($id_value !== NULL) {
					$id_directive = $this->parse_directive_str($id_value, $attr_directives);
				}
				if ($kd_value !== NULL) {
					$kd_directive = $this->parse_directive_str($kd_value, $attr_directives);
				}
				$directive = $kd_directive ? $kd_directive : $id_directive;

				## rebuild $this->attr_str.
				##  (1) delete 'kd="..."' and 'id="..."'
				##  (2) if directive 'attr:expr' is specified then
				##	 - replace 'attr="value"' by 'attr="#{expr}"'
				##	 - or add 'attr="#{expr}"' if directive 'attr:expr' is specified
				$s = '';
				$i = -1;
				foreach ($attr_names as $name) {
					$i++;
					$space = $spaces[$i];
					$value = $attr_values[$i];
					if ($name == $kd_name || ($name == 'id' && !preg_match('/^[-\w]+$/', $value))) {
						# nothing
					} else {
						if (array_key_exists($name, $attr_directives)) {
							$value = '#{' . $attr_directives[$name] . '}#';
							unset($attr_directives[$name]);
						}
						$s .= "{$space}{$name}=\"{$value}\"";
					}
				}
				foreach ($attr_directives as $name => $value) {
					$s .= " {$name}=\"#{" . $value . '}#"';
				}
				$this->attr_str = $s;
			}
			return $directive;
		}


		## for test of parse_attr_str()
		function _parse_attr_str($attr_str) {
			return $this->parse_attr_str($attr_str);
		}


		## helper method for convert().
		## returns a tuple(==array($name, $value)).
		private function parse_directive_str(&$str, &$attr_directives) {	// why needs '&' ?
			$strs = preg_split('/;/', $str);
			foreach ($strs as $s) {
				$directive = NULL;
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
							$attr_directives[$attr_name] = $expr_str;
						} else {
							$msg = "'attr:\"'{$value}\"': invalid directive.";
							throw new KwartzConvertionError($msg, $this);
						}
						break;
					case 'value':
					case 'Value':
					case 'VALUE':
					case 'mark':
					case 'if':
					case 'unless':
					case 'while':
					case 'dummy':
						$directive = array($name, $value);
						break;
					case 'set':
						if (preg_match('/^\w+:/', $value)) {
							$value = preg_replace('/:/', '=', $value);
						}
						$directive = array($name, $value);
						break;
					case 'foreach':
					case 'loop':
					case 'Foreach':
					case 'Loop':
					case 'FOREACH':
					case 'LOOP':
						if (preg_match('/^\w+:/', $value)) {
							$value = preg_replace('/:/', '=', $value);
						}
						$directive = array($name, $value);
						break;
					default:
						# ignore
					}
				}
			}
			return $directive;
		}


		## test for parse_directive_str()
		function _parse_directive_str(&$str, &$attr_directives) {
			return $this->parse_directive_str($str, $attr_directives);
		}


		private function create_print_stmt($str) {
			if (! $str) {
				return NULL;
			}
			$list = array();
			$s = $str;
			$pattern = '/((?:.|\n)*?)\#\{(.*?)\}\#((?:.|\n)*)/m';
			while (preg_match($pattern, $s, $m = array())) {
				$text  = $m[1];
				$value = $m[2];
				$rest  = $m[3];
				if ($text)  {
					$list[] = new KwartzStringExpression($text);
				}
				if ($value) {
					$expr = $this->parse_expression($value);
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
			$revlist = array_reverse($this->macro_stmt_list);
			foreach ($revlist as $macro_stmt) {
				//array_push($statements, $macro_stmt);
				$block->unshift($macro_stmt);
			}
			return $block;
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
						if ($tag_name == 'span' && ! $this->attr_str) {
							$list = array();
							$flag_span_removed = TRUE;
						} else {
							$print_stmt = $this->create_print_stmt($this->create_tagstr());
							$list = array($print_stmt);
							$flag_span_removed = FALSE;
						}
						$block = new KwartzBlockStatement($list);
						$this->store_stmt_for_directive($directive, $block, $stmt_list, $flag_span_removed);
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
						$block = $this->_convert($tag_name);
						if ($tag_name == 'span' && ! $this->attr_str) {
							# ignore first and last statement
							$first_stmt = $block->shift(); //array_shift($block->statements());
							$last_stmt  = $block->pop();   //array_pop($block->statements());
							$flag_span_removed = TRUE;
						} else {
							$flag_span_removed = FALSE;
						}
						$this->store_stmt_for_directive($directive, $block, $stmt_list, $flag_span_removed);
					} else {										# directive not specified
						if ($tag_name == $end_tag_name) {
							$block = $this->_convert($tag_name);
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


		private function store_stmt_for_directive(&$directive, &$block, &$stmt_list, $flag_span_removed=FALSE) {
			$directive_name = $directive[0];
			$directive_arg	= $directive[1];
			switch ($directive_name) {
			case 'foreach':
			case 'loop':
			case 'Foreach':
			case 'Loop':
			case 'FOREACH':
			case 'LOOP':
				$expr = $this->parse_expression($directive_arg);
				if ($expr->token() != '=') {
					$msg = "invalid '$directive_name' directive.";
					throw new KwartzConvertionError($msg, $this);
				}
				if ($expr->left()->token() != 'variable') {
					$msg = "invalid loop variable in '$directive_name' directive.";
					throw new KwartzConvertionError($msg, $this);
				}
				$loopvar_expr = $expr->left();
				$list_expr = $expr->right();
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
					if (! $flag_span_removed) {
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
					if (! $flag_span_removed) {
						$stmt_list[] = $last_stmt;
					}
				}
				break;

			case 'set':
				$expr = $this->parse_expression($directive_arg);
				$stmt = new KwartzSetStatement($expr);
				$stmt_list[] = $stmt;
				//$stmt_list[] = $block;
				foreach ($block->statements() as $stmt) {
					$stmt_list[] = $stmt;
				}
				break;

			case 'value':
				$expr = $this->parse_expression($directive_arg);
				if ($flag_span_removed) {
					$stmt_list[] = new KwartzPrintStatement(array($expr));
				} else {
					$stmt_list[] = $block->shift();  //array_shift($block->statements());	// stag
					$stmt_list[] = new KwartzPrintStatement(array($expr));
					$stmt_list[] = $block->pop();    //array_pop($block->statements());	// etag
				}
				//echo "*** debug: stmt_list[0]={$stmt_list[0]->inspect()}\n";
				//echo "*** debug: stmt_list[1]={$stmt_list[1]->inspect()}\n";
				//echo "*** debug: stmt_list[2]={$stmt_list[2]->inspect()}\n";
				break;

			case 'if':
				$expr = $this->parse_expression($directive_arg);
				$stmt = new KwartzIfStatement($expr, $block, NULL);
				$stmt_list[] = $stmt;
				break;

			case 'unless':
				$expr = $this->parse_expression($directive_arg);
				$expr = new KwartzUnaryExpression('!', $expr);
				$stmt = new KwartzIfStatement($expr, $block, NULL);
				$stmt_list[] = $stmt;
				break;

			case 'while':
				$expr = $this->parse_expression($directive_arg);
				$stmt = new KwartzWhileStatement($expr, $block);
				$stmt_list[] = $stmt;
				break;

			case 'mark':
				$name = $directive_arg;
				if ($flag_span_removed) {
					$stag_list = array();
					$etag_list = array();
				} else {
					$stag_stmt = $block->shift();   //array_shift($block->statements());
					$etag_stmt = $block->pop();     //array_pop($block->statements());
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
				$this->macro_stmt_list[] = new KwartzMacroStatement("elem_$name", $elem_block);
				$stmt_list[] = new KwartzExpandStatement("elem_$name");
				break;

			case 'dummy':
				# do nothing;
				break;

			default:
				$msg = "'{$directive_name}': invalid directive name.";
				throw new KwartzConvertionException($msg, $this);
			}
		}


		private function parse_expression($str) {
			$scanner = new KwartzScanner($str);
			$parser	 = new KwartzParser($scanner);
			$expr	 = $parser->parse_expression_strictly();
			return $expr;
		}
	}

// }  // end of namespace Kwartz
?>