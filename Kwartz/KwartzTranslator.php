<?php
// vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4:

// $Id$

require_once('Kwartz/KwartzException.php');
require_once('Kwartz/KwartzNode.php');
require_once('Kwartz/KwartzUtility.php');


// namespace Kwartz {

class KwartzTranslationError extends KwartzError {
    function __construct($msg) {
        parent::__construct($msg, NULL, NULL);
    }
}


/**
 *  translate node tree into a certain language code
 */
abstract class KwartzTranslator {
    // should return code string
    abstract function translate_expression($expr);
    abstract function translate_statement($stmt, $depth);
    
    // should return code string
    abstract function translate();
}


/**
 *  base class of translator which is a kind of PHP, eRuby, JSP, ...
 */
abstract class KwartzBaseTranslator extends KwartzTranslator {
    protected $code = "";
    protected $block;
    protected $flag_escape = false;
    protected $macro_stmt_hash = array();
    protected $nl = "\n";			// newline char ("\n" or "\r\n")
    protected $indent_spaces;
    protected $max_depth;
    protected $flag_supress_begin = FALSE;	// supress BEGIN macro
    protected $flag_supress_end   = FALSE;	// supress END macro
    
    // class vars
    static $priorities = array(
        'variable' => 100,
        'number'   => 100,
        'boolean'  => 100,
        'string'   => 100,
        'null'	   => 100,
        
        '[]'	   =>  90,
        '{}'	   =>  90,
        '[:]'	   =>  90,
        '.'	   =>  90,
        
        '-.'	   =>  80,
        '!'	   =>  80,
        'empty'    =>  80,
        'notempty' =>  80,
        
        '*'	   =>  70,
        '/'	   =>  70,
        '%'	   =>  70,
        '^'	   =>  70,
        
        '+'	   =>  60,
        '-'	   =>  60,
        '.+'	   =>  60,
        
        '=='	   =>  50,
        '!='	   =>  50,
        '<'	   =>  50,
        '<='	   =>  50,
        '>'	   =>  50,
        '>='	   =>  50,
        
        '&&'	   =>  40,
        
        '||'	   =>  30,
        
        '?'	   =>  20,
        
        '='	   =>  10,
        '+='	   =>  10,
        '-='	   =>  10,
        '*='	   =>  10,
        '/='	   =>  10,
        '%='	   =>  10,
        '^='	   =>  10,
        '.+='	   =>  10,
        );
    
    static $dispatcher = array(
        // expression
        'KwartzUnaryExpression'	      => 'translate_unary_expression',
        'KwartzBinaryExpression'      => 'translate_binary_expression',
        'KwartzFunctionExpression'    => 'translate_function_expression',
        'KwartzPropertyExpression'    => 'translate_property_expression',
        'KwartzConditionalExpression' => 'translate_conditional_expression',
        'KwartzVariableExpression'    => 'translate_variable_expression',
        'KwartzStringExpression'      => 'translate_string_expression',
        'KwartzNumericExpression'     => 'translate_numeric_expression',
        'KwartzBooleanExpression'     => 'translate_boolean_expression',
        'KwartzNullExpression'	      => 'translate_null_expression',
        
        // statement
        'KwartzPrintStatement'	      => 'translate_print_statement',
        'KwartzSetStatement'	      => 'translate_set_statement',
        'KwartzIfStatement'	      => 'translate_if_statement',
        'KwartzForeachStatement'      => 'translate_foreach_statement',
        'KwartzWhileStatement'	      => 'translate_while_statement',
        'KwartzMacroStatement'	      => 'translate_macro_statement',
        'KwartzExpandStatement'	      => 'translate_expand_statement',
        'KwartzBlockStatement'	      => 'translate_block_statement',
        'KwartzRawcodeStatement'      => 'translate_rawcode_statement',
        );
    
    function __construct($block, $flag_escape=FALSE, $toppings=NULL) {
        $this->block       = $block->rearrange();
        $this->flag_escape = $flag_escape;
        $this->toppings    = $toppings ? $toppings : array();
        if ($flag_escape) {
            $this->print_key    = ':eprint';
            $this->endprint_key = ':endeprint';
        } else {
            $this->print_key    = ':print';
            $this->endprint_key = ':endprint';
        }
        $indent_width = $this->topping('indent_width');
        $indent_space = '';
        for ($i = 0; $i < $indent_width; $i++) {
            $indent_space .= ' ';
        }
        //$this->indent_width = $indent_width;
        $this->indent_space = $indent_space;
        $this->max_depth = 10;
        $this->_init_indent_spaces($indent_space, $this->max_depth);
    }
    
    
    // --------------------
    // utility funcitions
    // --------------------
    
    function topping($name) {
        if (array_key_exists($name, $this->toppings)) {
            return $this->toppings[$name];
        }
        return NULL;
    }
    
    function code() { return $this->code; }
    function flag_escape() { return $this->flag_escape; }
    
    function set_newline_char($newline) { $this->nl = $newline; }
    function newline_char() { return $this->nl; }
    function nl()           { return $this->nl; }
    
    //function translate_node($expr_or_stmt, $depth) {
    //	$class_name = get_class($expr_or_stmt);
    //	$method_name = KwartzBaseTranslator::$dispatcher[$class_name];
    //	return $this->$method_name($expr_or_stmt, $depth);
    //}
    
    protected function add_macro($macro_name, $block) {
        $this->macro_stmt_hash[$macro_name] = $block;
    }
    
    protected function macro($macro_name) {
        if (array_key_exists($macro_name, $this->macro_stmt_hash)) {
            return $this->macro_stmt_hash[$macro_name];
        }
        return NULL;
    }
    
    function _init_indent_spaces($indent_space, $max_depth) {
        $this->_indent_spaces = array();
        $s = '';
        for ($i = 0; $i < $max_depth; $i++) {
            $this->_indent_spaces[] = $s;
            $s .= $indent_space;
        }
    }
    
    protected function indent($depth) {
        if ($depth <= $this->max_depth) {
            return $this->_indent_spaces[$depth];
        }
        $s = '';
        for ($i = 0; $i < $depth; $i++) {
            $s .= $this->indent_space;
        }
        return $s;
    }
    
    protected function add_indent($depth) {
        if ($this->code && $this->code[strlen($this->code)-1] == "\n") {
            $this->code .= $this->indent($depth);
        }
    }
    
    protected function add_prefix($depth) {
        if ($this->code && $this->code[strlen($this->code)-1] == "\n") {
            $this->code .= $this->keyword(':prefix');
            $this->code .= $this->indent($depth);
        } else {
            $this->code .= $this->keyword(':prefix');
        }
    }
    
    protected function add_postfix($flag_newline=true) {
        $this->code .= $this->keyword(':postfix');
        if ($flag_newline) {
            $this->code .= $this->nl;
        }
    }
    
    
    
    // --------------------
    // translate expression
    // --------------------
    
    abstract protected function keyword($token);
    
    function translate() {
        $statements = $this->block->statements();
        foreach ($statements as $stmt) {
            if ($stmt->token() == ':macro') {
                $this->add_macro($stmt->macro_name(), $stmt->body_block());
            }
        }
        if (! $this->flag_supress_begin && $this->macro('BEGIN')) {
            $this->translate_statement($this->macro('BEGIN'), 0);
        }
        $this->translate_statement($this->block, 0);
        if (! $this->flag_supress_end && $this->macro('END')) {
            $this->translate_statement($this->macro('END'), 0);
        }
        return $this->code;
    }
    
    
    
    // --------------------
    // translate expression
    // --------------------
    
    function translate_expression($expr) {
        $class_name = get_class($expr);
        $method_name = KwartzBaseTranslator::$dispatcher[$class_name];
        $this->$method_name($expr);
    }
    
    protected function translate_expr($expr, $parent_token, $child_token) {
        if (KwartzBaseTranslator::$priorities[$parent_token] > KwartzBaseTranslator::$priorities[$child_token]) {
            $this->code .= '(';
            $this->translate_expression($expr);
            $this->code .= ')';
        } else {
            $this->translate_expression($expr);
        }
    }
    
    
    protected function translate_unary_expression($expr) {
        $t = $expr->token();
        $this->code .= $this->keyword($t);
        $this->translate_expr($expr->child(), $t, $expr->child()->token());
    }
    
    protected function translate_binary_expression($expr) {
        $t = $expr->token();
        $op = $this->keyword($t);
        
        switch ($t) {
          case '=':  case '+=': case '-=': case '*=': case '/=': case '%=':  case '^=':  case '.+=':
          case '+':  case '-':  case '*':	 case '/':  case '%':  case '^':   case '.+':
          case '==': case '!=': case '>':	 case '>=': case '<':  case '<=':
          case '&&': case '||':
            $this->translate_expr($expr->left(), $t, $expr->left()->token());
            $this->code .= " $op ";
            $this->translate_expr($expr->right(), $t, $expr->right()->token());
            break;
            
          case '[]': case '{}':
            if ($t == '[]') {
                $t1 = '[';  $t2 = ']';
            } else {
                $t1 = '{';  $t2 = '}';
            }
            $this->translate_expr($expr->left(), $t, $expr->left()->token());
            $this->code .= $this->keyword($t1);
            $this->translate_expression($expr->right());
            $this->code .= $this->keyword($t2);
            break;
            
          case '[:]':
            $this->translate_expr($expr->left(), $t, $expr->left()->token());
            $this->code .= $this->keyword('[:');
            $this->code .= $expr->right()->value();
            $this->code .= $this->keyword(':]');
            break;
            
          default:
            echo "*** assert(false): t=$t\n";
            assert(false);
        }
    }
    
    protected function translate_property_expression($expr) {
        $t = $expr->token();
        $op = $this->keyword($t);
        $this->translate_expr($expr->object(), $t, $expr->object()->token());
        $this->code .= $op;
        $this->code .= $expr->property();
        if ($expr->arglist() !== NULL) {
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
    
    protected function translate_function_expression($expr) {
        $t = $expr->token();
        $op = $this->keyword($t);
        $func_name = $this->function_name($expr->funcname());
        if (! $func_name) {
            $func_name = $expr->funcname();
        }
        $this->code .= $func_name . $this->keyword('(');
        $comma = '';
        foreach($expr->arglist() as $arg_expr) {
            $this->code .= $comma;
            $comma = ', ';
            $this->translate_expression($arg_expr);
        }
        $this->code .= $this->keyword(')');
    }
    
    
    //
    // convert $func_name into appropriate function name.
    // eg.
    //   $func_name     PHP           JSTL1.1
    //   ---------------------------------------------
    //   list_length    count         fn:length
    //   str_length     strlen        fn:length
    //
    abstract protected function function_name($func_name);

    
    protected function translate_conditional_expression($expr) {
        $t = $expr->token();
        $op = $this->keyword($t);
        $this->translate_expr($expr->condition(), $t, $expr->condition()->token());
        $this->code .= ' ? ';
        $this->translate_expr($expr->left(), $t, $expr->left()->token());
        $this->code .= ' : ';
        $this->translate_expr($expr->right(), $t, $expr->right()->token());
    }
    
    
    protected function translate_variable_expression($expr) {
        $this->code .= $expr->value();
    }
    
    protected function translate_string_expression($expr) {
        $this->code .= kwartz_inspect_str($expr->value());
    }
    
    protected function translate_numeric_expression($expr) {
        $this->code .= $expr->value();
    }
    
    protected function translate_boolean_expression($expr) {
        $this->code .= $this->keyword($expr->value());
    }
    
    protected function translate_null_expression($expr) {
        $this->code .= $this->keyword($expr->value());
    }
    
    
    // --------------------
    // translate statement
    // --------------------
    
    function translate_statement($stmt, $depth) {
        $class_name = get_class($stmt);
        $method_name = KwartzBaseTranslator::$dispatcher[$class_name];
        $this->$method_name($stmt, $depth);
    }
    
    protected function translate_print_statement($stmt, $depth) {
        foreach ($stmt->arglist() as $expr) {
            $t = $expr->token();
            if ($t == 'string' || $t == 'number') {
                $this->code .= $expr->value();
            } else {
                $startkey = $endkey = NULL;
                if ($expr->token() == 'function') {
                    $fname = $expr->funcname();
                    if ($fname == 'E' || $fname == 'X') {
                        if ($fname == 'E') {
                            $startkey = ':eprint';
                            $endkey   = ':endeprint';
                        } else {
                            $startkey = ':print';
                            $endkey   = ':endprint';
                        }
                        $arglist = $expr->arglist();
                        if ($arglist == NULL || count($arglist) != 1) {
                            $msg = "number of arguments of '{$funcname}()' is not 1.";
                            throw new KwartzTranslationError($msg);
                        }
                        $expr = $arglist[0];
                    }
                }
                if (! $startkey) {
                    if (KwartzBaseTranslator::is_const($expr)) {
                        $startkey = ':print';
                        $endkey   = ':endprint';
                    } else {
                        $startkey = $this->print_key;
                        $endkey   = $this->endprint_key;
                    }
                }
                $this->code .= $this->keyword($startkey);	// 'print' or 'eprint'
                $this->translate_expression($expr);
                $this->code .= $this->keyword($endkey);		// 'endprint' or 'endeprint'
            }
        }
    }
    
    protected function translate_set_statement($stmt, $depth) {
        $this->add_prefix($depth);
        $expr = $stmt->assign_expr();
        $this->code .= $this->keyword(':set');
        $this->translate_expression($expr);
        $this->code .= $this->keyword(':endset');
        $this->add_postfix();
    }
    
    protected function translate_if_statement($stmt, $depth) {
        //$this->add_prefix($depth);
        $this->add_prefix($depth);
        $this->code .= $this->keyword(':if');
        $this->translate_expression($stmt->condition());
        $this->code .= $this->keyword(':then');
        //$this->add_postfix();
        $this->add_postfix();
        $this->translate_statement($stmt->then_block(), $depth+1);
        $st = $stmt;
        while (($st = $st->else_stmt()) != NULL && $st->token() == ':if') {
            //$this->add_prefix($depth);
            $this->add_prefix($depth);
            $this->code .= $this->keyword(':elseif');
            $this->translate_expression($st->condition());
            $this->code .= $this->keyword(':then');
            //$this->add_postfix();
            $this->add_postfix();
            $this->translate_statement($st->then_block(), $depth+1);
        }
        if ($st) {
            //assert($st.token() == '<<block>>');
            //$this->add_prefix($depth);
            $this->add_prefix($depth);
            $this->code .= $this->keyword(':else');
            //$this->add_postfix();
            $this->add_postfix();
            $this->translate_statement($st, $depth+1);
        }
        //$this->add_prefix($depth);
        $this->add_prefix($depth);
        $this->code .= $this->keyword(':endif');
        //$this->add_postfix();
        $this->add_postfix();
    }
    
    protected function translate_foreach_statement($stmt, $depth) {
        $this->add_prefix($depth);
        $this->code .= $this->keyword(':foreach');
        $this->translate_expression($stmt->loopvar_expr());
        $this->code .= $this->keyword(':in');
        $this->translate_expression($stmt->list_expr());
        $this->code .= $this->keyword(':doforeach');
        $this->add_postfix();
        $this->translate_statement($stmt->body_block(), $depth+1);
        $this->add_prefix($depth);
        $this->code .= $this->keyword(':endforeach');
        $this->add_postfix();
    }
    
    protected function translate_while_statement($stmt, $depth) {
        $this->add_prefix($depth);
        $this->code .= $this->keyword(':while');
        $this->translate_expression($stmt->condition());
        $this->code .= $this->keyword(':dowhile');
        $this->add_postfix();
        $this->translate_statement($stmt->body_block(), $depth+1);
        $this->add_prefix($depth);
        $this->code .= $this->keyword(':endwhile');
        $this->add_postfix();
    }
    
    protected function translate_macro_statement($stmt, $depth) {
        //$this->add_prefix($depth);
        //$this->add_macro($stmt->macro_name(), $stmt->body_block());
        // do nothing
    }
    
    protected function translate_expand_statement($stmt, $depth) {
        $block = $this->macro($stmt->macro_name());
        if (! $block) {
            $msg = "macro '{$stmt->macro_name()}' not defined.";
            throw new KwartzTranslationError($msg);
        }
        $this->translate_statement($block, $depth);
    }
    
    protected function translate_block_statement($block_stmt, $depth) {
        foreach ($block_stmt->statements() as $stmt) {
            $this->translate_statement($stmt, $depth);
        }
    }
    
    protected function translate_rawcode_statement($stmt, $depth) {
        $this->add_indent($depth);
        $this->code .= $stmt->rawcode();
        $this->code .= $this->nl;
    }
    
    // --------------------
    // utility function
    // --------------------
    function is_const($expr) {
        $t = $expr->token();
        switch ($t) {
          case 'string':
          case 'number':
          //case 'true':
          //case 'false':
          case 'boolean':
          case 'null':
            return TRUE;
          case '?':
            if (! KwartzBaseTranslator::is_const($expr->left())) {
                return FALSE;
            }
            return  KwartzBaseTranslator::is_const($expr->right());
          default:
            return FALSE;
        }
    }
    
}


/**
 *  translate node tree into PHP code
 */
class KwartzPhpTranslator extends KwartzBaseTranslator {
    private	$keywords = array(
        ':prefix'     => '<?php ',	// statement prefix
        ':postfix'    => ' ?>',		// statement postfix
        
        ':if'         => 'if (',
        ':then'       => ') {',
        ':else'       => '} else {',
        ':elseif'     => '} elseif (',
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
        
        // ':print' statement doesn't print prefix and suffix,
        // so you should include prefix and suffix in ':print'/':endprint' keywords
        ':print'      => '<?php echo ',		
        ':endprint'   => '; ?>',		
        ':eprint'     => '<?php echo htmlspecialchars(',
        ':endeprint'  => '); ?>',
        
        ':include'    => 'include(',
        ':endinclude' => ');',
        
        'true'        => 'TRUE',
        'false'       => 'FALSE',
        'null'        => 'NULL',
        
        '-.'   => '-',
        '.+'   => '.',
        '.+='  => '.=',
        '.'    => '->',
        '{'    => '[',
        '}'    => ']',
        '[:'   => "['",
        ':]'   => "']",
        ','    => ", ",
        
        'E('   => 'htmlspecialchars(',
        'E)'   => ')',
        );
    
    function __construct($block, $flag_escape=FALSE, $toppings=NULL) {
        parent::__construct($block, $flag_escape, $toppings);
    }
    
    protected function keyword($token) {
        return array_key_exists($token, $this->keywords) ? $this->keywords[$token] : $token;
    }
    
    protected function translate_variable_expression($expr) {
        $this->code .= '$' . $expr->value();
    }
  
    private $func_names = array(
        'list_new'    => 'array',
        'list_length' => 'count',
        'list_empty'  => NULL,
        'hash_new'    => 'array',
        'hash_keys'   => 'array_keys',
        'hash_empty'  => NULL,
        'str_length'  => 'strlen',
        'str_trim'    => 'trim',
        'str_tolower' => 'strtolower',
        'str_toupper' => 'strtoupper',
        'str_index'   => 'strchr',
        'str_empty'   => NULL,
        );
        
    protected function function_name($func_name) {
        if (array_key_exists($func_name, $this->func_names))
            return $this->func_names[$func_name];
        return NULL;
    }

    
    protected function translate_function_expression($expr) {
        switch ($expr->funcname()) {
          case 'list_empty':
          case 'hash_empty':
            $arglist = $expr->arglist();
            $this->code .= '(!(';
            $this->translate_expression($arglist[0]);
            $this->code .= ') || count(';
            $this->translate_expression($arglist[0]);
            $this->code .= ')==0)';
            return;
          case 'str_empty':
            $arglist = $expr->arglist();
            $this->code .= '!';
            $this->translate_expression($arglist[0]);
            return;
        }
        
        parent::translate_function_expression($expr);
    }

    
    protected function translate_unary_expression($expr) {
        $t = $expr->token();
        if ($t == 'empty' || $t == 'notempty') {
            $op = $t == 'empty' ? '==' : '!=';
            $expr = new KwartzBinaryExpression($op, $expr->child(), new KwartzStringExpression(""));
            $this->code .= '(';
            $this->translate_binary_expression($expr);
            $this->code .= ')';
            return;
        }
        parent::translate_unary_expression($expr);
    }
    
    protected function translate_foreach_statement($stmt, $depth) {
        $this->add_prefix($depth);
        $this->code .= $this->keyword(':foreach');
        $this->translate_expression($stmt->list_expr());
        $this->code .= $this->keyword(':in');
        $this->translate_expression($stmt->loopvar_expr());
        $this->code .= $this->keyword(':doforeach');
        $this->add_postfix();
        $this->translate_statement($stmt->body_block(), $depth+1);
        $this->add_prefix($depth);
        $this->code .= $this->keyword(':endforeach');
        $this->add_postfix();
    }
    
}

// }  // end of namespace Kwartz
?>