<?php
// vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4:

// $Id$

require_once('Kwartz/KwartzTranslator.php');

// namespace Kwartz {

/**
 *  translate node tree into eRuby code
 */
class KwartzErubyTranslator extends KwartzBaseTranslator {
    private $keywords = array(
        ':prefix'     => '<% ',
        ':postfix'    => ' %>',
        
        ':if'         => 'if ',
        ':then'       => ' then',
        ':else'       => 'else',
        ':elseif'     => 'elsif ',
        ':endif'      => 'end',
        
        ':while'      => 'while ',
        ':dowhile'    => ' do',
        ':endwhile'   => 'end',
        
        ':foreach'    => 'for ',
        ':in'         => ' in ',
        ':doforeach'  => ' do',
        ':endforeach' => 'end',
        
        ':set'        => '',
        ':endset'     => '',
        
        ':print'      => '<%= ',
        ':endprint'   => ' %>',
        ':eprint'     => '<%= CGI::escapeHTML((',
        ':endeprint'  => ').to_s) %>',
        
        ':include'    => 'include(',
        ':endinclude' => ')',
        
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
        
        'E('   => 'CGI::escapeHTML((',
        'E)'   => ').to_s)',
        );
    
    function __construct($block, $flag_escape=FALSE, $toppings=NULL) {
        parent::__construct($block, $flag_escape, $toppings);
    }
    
    protected function keyword($token) {
        return array_key_exists($token, $this->keywords) ? $this->keywords[$token] : $token;
    }
    
    
    private $method_names = array(
        'list_new'    => '[]',
        'list_length' => 'length',
        'list_empty'  => 'empty?',
        'hash_new'    => '{}',
        'hash_keys'   => 'keys',
        'hash_empty?' => 'hash_empty?',
        'str_length'  => 'length',
        'str_trim'    => 'trim',
        'str_tolower' => 'downcase',
        'str_toupper' => 'upcase',
        'str_index'   => 'index',
        'str_empty'   => 'empty?',
        );
    
    protected function function_name($func_name) {
        if (array_key_exists($func_name, $this->method_names)) {
            return $this->method_names[$func_name];
        }
        return NULL;
    }
    
    
    protected function translate_function_expression($expr) {
        $method = $this->function_name($expr->funcname());
        if (!$method) {
            parent::translate_function_expression($expr);
            return;
        }

        if ($method == '[]' || $method == '{}') {
            $this->code .= $method;
            return;
        }
        
        $arglist = $expr->arglist();
        if (count($arglist) == 0)
            return;
        $i = 0;
        foreach ($arglist as $arg_expr) {
            $i++;
            if ($i == 1) {
                $flag_paren = true;
                switch ($arg_expr->token()) {
                  case 'string':  case 'number':  case 'variable':
                  case 'boolean':  case 'null':
                  case '[]':  case '[:]'  : case '{}':
                    $flag_paren = false;
                }
                if ($flag_paren)
                    $this->code .= '(';
                $this->translate_expression($arg_expr);
                if ($flag_paren)
                    $this->code .= ')';
                $this->code .= ".$method";
            } else {
                $this->code .= ($i == 2 ? '(' : ', ');
                $this->translate_expression($arg_expr);
            }
        }
        if ($i >= 2) {
            $this->code .= ')';
        }
    }

    
    protected function translate_unary_expression($expr) {
        $t = $expr->token();
        if ($t == 'empty' || $t == 'notempty') {
            if ($t == 'empty') {  $op1 = '==';  $op2 = '||'; }
            else               {  $op1 = '!=';  $op2 = '&&'; }
            $this->code .= '(';
            $expr1 = new KwartzBinaryExpression($op1, $expr->child(), new KwartzNullExpression("nil"));
            $expr2 = new KwartzBinaryExpression($op1, $expr->child(), new KwartzStringExpression(""));
            $expr3 = new KwartzBinaryExpression($op2, $expr1, $expr2);
            $this->translate_binary_expression($expr3);
            $this->code .= ')';
            return;
        }
        parent::translate_unary_expression($expr);
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